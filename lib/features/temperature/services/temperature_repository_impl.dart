import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'temperature_repository.dart';
import '../models/data_loading_level.dart';
import '../../../core/exceptions/temperature_exceptions.dart';

class TemperatureRepositoryImpl implements TemperatureRepository {
  static final Map<String, List<Map<String, dynamic>>> _dataReadings = {};
  static final List<DataRange> _loadedRanges = [];
  static final Map<String, Future<bool>> _inflightRequests = {}; // Track in-flight requests
  static final List<DataRange> _requestQueue = []; // Queue for sequential processing
  static bool _processingQueue = false;
  static Function()? _onDataUpdated; // Callback for when data is updated
  
  @override
  Map<String, List<Map<String, dynamic>>> get data => _dataReadings;
  
  @override
  List<DataRange> get loadedRanges => List.unmodifiable(_loadedRanges);
  
  bool _isOffline = false;
  
  @override
  bool get isOffline => _isOffline;
  
  static int _lastLatestCall =
      (DateTime.now().millisecondsSinceEpoch / 1000).floor() - 14 * 24 * 3600;
  
  @override
  Future<bool> updateLatestData({int maxRetries = 3}) async {
    int now = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
    int interval = now - _lastLatestCall;
    if (interval < 10) {
      return true;
    }

    return await _fetchWithLastParameter(interval, maxRetries: maxRetries);
  }
  
  @override
  Future<bool> updateData({int maxRetries = 3}) async {
    return await updateLatestData(maxRetries: maxRetries);
  }
  
  @override
  Future<bool> loadDataForRange(DataRange range, {int maxRetries = 3}) async {
    final missingRanges = getMissingRanges(range);
    
    if (missingRanges.isEmpty) {
      return true; // Already have all the data
    }
    
    // Break down large ranges and add to queue for sequential processing
    for (final missingRange in missingRanges) {
      final expandedRange = _expandToMinimumDuration(missingRange);
      final chunks = _splitIntoSevenDayChunks(expandedRange);
      
      // Add chunks to queue
      for (final chunk in chunks) {
        if (!_isRangeInQueueOrProcessing(chunk)) {
          _requestQueue.add(chunk);
          debugPrint('[TemperatureRepositoryImpl] Added range to queue: ${chunk.start} to ${chunk.end}');
        }
      }
    }
    
    // Start processing queue if not already running
    _startQueueProcessing(maxRetries);
    
    // Wait for our ranges to be processed
    return await _waitForRangeCompletion(range);
  }

  List<DataRange> _splitIntoSevenDayChunks(DataRange range) {
    const maxDays = 7;
    final chunks = <DataRange>[];
    
    DateTime currentStart = range.start;
    while (currentStart.isBefore(range.end)) {
      final currentEnd = currentStart.add(const Duration(days: maxDays));
      final chunkEnd = currentEnd.isAfter(range.end) ? range.end : currentEnd;
      
      chunks.add(DataRange(start: currentStart, end: chunkEnd));
      currentStart = chunkEnd;
    }
    
    // Reverse chunks to process newest data first (users typically pan backwards in time)
    final reversedChunks = chunks.reversed.toList();
    debugPrint('[TemperatureRepositoryImpl] Split range into ${chunks.length} chunks of max 7 days each (reversed for newest-first processing)');
    return reversedChunks;
  }

  bool _isRangeInQueueOrProcessing(DataRange range) {
    final requestKey = '${range.startEpoch}-${range.endEpoch}';
    
    // Check if already in queue
    if (_requestQueue.any((r) => r.startEpoch == range.startEpoch && r.endEpoch == range.endEpoch)) {
      return true;
    }
    
    // Check if already in flight
    if (_inflightRequests.containsKey(requestKey)) {
      return true;
    }
    
    return false;
  }

  void _startQueueProcessing(int maxRetries) async {
    if (_processingQueue) return;
    
    _processingQueue = true;
    debugPrint('[TemperatureRepositoryImpl] Starting sequential queue processing');
    
    while (_requestQueue.isNotEmpty) {
      final range = _requestQueue.removeAt(0);
      final requestKey = '${range.startEpoch}-${range.endEpoch}';
      
      debugPrint('[TemperatureRepositoryImpl] Processing queued range: ${range.start} to ${range.end}');
      
      final requestFuture = _fetchWithStartEndParameters(
        range.startEpoch, 
        range.endEpoch, 
        maxRetries: maxRetries
      ).then((success) {
        _inflightRequests.remove(requestKey);
        if (success) {
          _addLoadedRange(range);
        }
        return success;
      });
      
      _inflightRequests[requestKey] = requestFuture;
      await requestFuture; // Wait for completion before processing next
    }
    
    _processingQueue = false;
    debugPrint('[TemperatureRepositoryImpl] Queue processing completed');
  }

  Future<bool> _waitForRangeCompletion(DataRange range) async {
    // Poll until our range is fully loaded
    while (!hasDataForRange(range)) {
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Check if processing failed (no more queue items and not processing)
      if (!_processingQueue && _requestQueue.isEmpty && !hasDataForRange(range)) {
        return false;
      }
    }
    return true;
  }
  
  @override
  bool hasDataForRange(DataRange range) {
    return getMissingRanges(range).isEmpty;
  }
  
  @override
  List<DataRange> getMissingRanges(DataRange requestedRange) {
    // Combine loaded ranges with in-flight request ranges
    final allRanges = <DataRange>[];
    allRanges.addAll(_loadedRanges);
    
    // Add ranges from in-flight requests
    for (final requestKey in _inflightRequests.keys) {
      final parts = requestKey.split('-');
      if (parts.length == 2) {
        final startEpoch = int.tryParse(parts[0]);
        final endEpoch = int.tryParse(parts[1]);
        if (startEpoch != null && endEpoch != null) {
          allRanges.add(DataRange(
            start: DateTime.fromMillisecondsSinceEpoch(startEpoch * 1000),
            end: DateTime.fromMillisecondsSinceEpoch(endEpoch * 1000),
          ));
        }
      }
    }
    
    if (allRanges.isEmpty) {
      return [requestedRange];
    }
    
    List<DataRange> missing = [];
    DateTime currentStart = requestedRange.start;
    
    // Sort all ranges (loaded + in-flight) by start time
    final sortedRanges = List<DataRange>.from(allRanges)
      ..sort((a, b) => a.start.compareTo(b.start));
    
    for (final loadedRange in sortedRanges) {
      // If there's a gap before this loaded range
      if (currentStart.isBefore(loadedRange.start) && 
          loadedRange.start.isBefore(requestedRange.end)) {
        final gapEnd = loadedRange.start.isBefore(requestedRange.end) 
            ? loadedRange.start 
            : requestedRange.end;
        missing.add(DataRange(start: currentStart, end: gapEnd));
      }
      
      // Only move past this loaded range if it actually overlaps with our current position
      if (loadedRange.end.isAfter(currentStart) && loadedRange.start.isBefore(requestedRange.end)) {
        currentStart = loadedRange.end;
      }
      
      // If we've covered the entire requested range
      if (currentStart.isAfter(requestedRange.end) || 
          currentStart.isAtSameMomentAs(requestedRange.end)) {
        break;
      }
    }
    
    // If there's still uncovered area at the end
    if (currentStart.isBefore(requestedRange.end)) {
      missing.add(DataRange(start: currentStart, end: requestedRange.end));
    }
    
    return missing;
  }
  
  @override
  void clearData() {
    _dataReadings.clear();
    _loadedRanges.clear();
    _inflightRequests.clear(); // Also clear in-flight requests
  }
  
  @override
  Map<String, List<Map<String, dynamic>>> getDataForRange(DataRange range) {
    final filteredData = <String, List<Map<String, dynamic>>>{};
    
    for (final key in _dataReadings.keys) {
      final keyData = _dataReadings[key]!;
      final filteredKeyData = keyData.where((point) {
        final pointTime = point['t'] as DateTime;
        return range.contains(pointTime);
      }).toList();
      
      if (filteredKeyData.isNotEmpty) {
        filteredData[key] = filteredKeyData;
      }
    }
    
    return filteredData;
  }
  
  /// Expand small data ranges to minimum 1 day to avoid tiny API requests
  DataRange _expandToMinimumDuration(DataRange range) {
    const minDurationHours = 24; // Always request at least 1 day
    final currentDuration = range.duration;
    
    if (currentDuration.inHours >= minDurationHours) {
      return range; // Already large enough
    }
    
    // Calculate how much to expand (split the difference before and after)
    final neededDuration = Duration(hours: minDurationHours) - currentDuration;
    final expandBefore = Duration(milliseconds: neededDuration.inMilliseconds ~/ 2);
    final expandAfter = neededDuration - expandBefore;
    
    var newStart = range.start.subtract(expandBefore);
    var newEnd = range.end.add(expandAfter);
    
    // Don't expand before 2020 or into the future
    final earliestAllowed = DateTime(2020, 1, 1);
    final latestAllowed = DateTime.now();
    
    if (newStart.isBefore(earliestAllowed)) {
      newStart = earliestAllowed;
      // If we can't expand backwards, expand more forwards (but not past now)
      final compensation = earliestAllowed.difference(range.start.subtract(expandBefore));
      newEnd = (newEnd.add(compensation).isBefore(latestAllowed)) 
          ? newEnd.add(compensation) 
          : latestAllowed;
    }
    
    if (newEnd.isAfter(latestAllowed)) {
      newEnd = latestAllowed;
      // If we can't expand forwards, expand more backwards (but not before 2020)
      final compensation = range.end.add(expandAfter).difference(latestAllowed);
      newStart = (newStart.subtract(compensation).isAfter(earliestAllowed))
          ? newStart.subtract(compensation)
          : earliestAllowed;
    }
    
    return DataRange(start: newStart, end: newEnd);
  }

  void _addLoadedRange(DataRange newRange) {
    // Merge overlapping ranges to keep the list clean
    final overlapping = _loadedRanges.where((range) => range.overlaps(newRange)).toList();
    
    if (overlapping.isEmpty) {
      _loadedRanges.add(newRange);
    } else {
      // Remove overlapping ranges and add merged range
      _loadedRanges.removeWhere((range) => overlapping.contains(range));
      
      DataRange merged = newRange;
      for (final range in overlapping) {
        merged = merged.merge(range);
      }
      _loadedRanges.add(merged);
    }
  }
  
  Future<bool> _fetchWithLastParameter(int intervalSeconds, {int maxRetries = 3}) async {
    int now = (DateTime.now().millisecondsSinceEpoch / 1000).floor();

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        debugPrint('[TemperatureRepositoryImpl] Fetching latest data (interval: $intervalSeconds s, attempt: $attempt)');
        final response = await http.get(
          Uri.parse(
              'https://temperaare.ch/REST/v1/fetch/waterTempFaehrweg,airTempFaehrweg,batFaehrweg?last=${intervalSeconds}s'),
          headers: {
            HttpHeaders.acceptHeader: 'application/json',
            HttpHeaders.authorizationHeader: 'as8jkhaksdlfhahjsfdf'
          },
        ).timeout(const Duration(seconds: 100));

        debugPrint('[TemperatureRepositoryImpl] Response status: ${response.statusCode}');
        if (response.statusCode != 200 && response.statusCode != 204) {
          debugPrint('[TemperatureRepositoryImpl] Response body: ${response.body}');
        }

      switch (response.statusCode) {
        case 200:
          try {
            _processResponseData(json.decode(response.body));
            _isOffline = false;
            _lastLatestCall = now;
            return true;
          } catch (e, stack) {
            debugPrint('[TemperatureRepositoryImpl] Exception in _processResponseData: $e\n$stack');
            rethrow;
          }
        case 204: // no content
          _lastLatestCall = now;
          _isOffline = false;
          return true;
        case 401:
          throw TemperatureAuthException();
        case 404:
          throw TemperatureNotFoundException();
        default:
          throw TemperatureApiException(
              'Unexpected status: ${response.statusCode}');
      }
      } catch (e) {
        debugPrint('[TemperatureRepositoryImpl] Exception during fetch: $e');
        if (attempt == maxRetries - 1) {
          _isOffline = true;
          return false;
        }
        await Future.delayed(Duration(seconds: (attempt + 1) * 2));
      }
    }

    _isOffline = true;
    return false;
  }
  
  Future<bool> _fetchWithStartEndParameters(int startEpoch, int endEpoch, {int maxRetries = 3}) async {
    // Safety check: Never request data from the future
    final nowEpoch = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
    if (endEpoch > nowEpoch) {
      endEpoch = nowEpoch;
    }
    if (startEpoch > nowEpoch) {
      // If start is in future, no valid data range exists
      return false;
    }

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        debugPrint('[TemperatureRepositoryImpl] Fetching data for range $startEpoch-$endEpoch (attempt: $attempt)');
        final response = await http.get(
          Uri.parse(
              'https://temperaare.ch/REST/v1/fetch/waterTempFaehrweg,airTempFaehrweg,batFaehrweg?range=$startEpoch-$endEpoch'),
          headers: {
            HttpHeaders.acceptHeader: 'application/json',
            HttpHeaders.authorizationHeader: 'as8jkhaksdlfhahjsfdf'
          },
        ).timeout(const Duration(seconds: 10));

        debugPrint('[TemperatureRepositoryImpl] Response status: ${response.statusCode}');
        if (response.statusCode != 200 && response.statusCode != 204) {
          debugPrint('[TemperatureRepositoryImpl] Response body: ${response.body}');
        }

        switch (response.statusCode) {
          case 200:
            _processResponseData(json.decode(response.body));
            _isOffline = false;
            return true;
          case 204: // no content
            _isOffline = false;
            return true;
          default:
            debugPrint('[TemperatureRepositoryImpl] Unexpected status code: ${response.statusCode}');
            if (attempt == maxRetries - 1) {
              _isOffline = true;
              return false;
            }
            break;
        }
      } catch (e) {
        debugPrint('[TemperatureRepositoryImpl] Exception during fetch: $e');
        if (attempt == maxRetries - 1) {
          _isOffline = true;
          return false;
        }
        await Future.delayed(Duration(seconds: (attempt + 1) * 2));
      }
    }

    _isOffline = true;
    return false;
  }
  
  void _processResponseData(Map<String, dynamic> responseData) {
    bool dataAdded = false;
    
    for (String key in responseData.keys) {
      if (!_dataReadings.containsKey(key)) {
        _dataReadings[key] = [];
      }
      
      final existingData = _dataReadings[key]!;
      final existingTimes = existingData.map((point) => point['t'] as DateTime).toSet();
      
      for (List<dynamic> row in responseData[key]) {
        final dateTime = DateTime.parse(row[0]);
        final value = double.parse(row[1]);
        
        // Only add if we don't already have this timestamp
        if (!existingTimes.contains(dateTime)) {
          existingData.add({
            't': dateTime,
            'v': value,
          });
          dataAdded = true;
        }
      }
      
      // Keep data sorted by time
      existingData.sort((a, b) => (a['t'] as DateTime).compareTo(b['t'] as DateTime));
    }
    
    // Notify listeners that data was updated
    if (dataAdded && _onDataUpdated != null) {
      debugPrint('[TemperatureRepositoryImpl] Notifying data updated callback');
      _onDataUpdated!();
    }
  }

  /// Set callback to be notified when data is updated
  static void setDataUpdatedCallback(Function() callback) {
    _onDataUpdated = callback;
  }

  /// Clear the data updated callback
  static void clearDataUpdatedCallback() {
    _onDataUpdated = null;
  }
}
