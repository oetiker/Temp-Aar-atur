import 'package:flutter/foundation.dart';
import 'temperature_repository.dart';
import 'temperature_repository_impl.dart';
import '../models/data_loading_level.dart';

class TemperatureService {
  final TemperatureRepository _repository;
  static int _lastLoggedCount = 0;

  TemperatureService({TemperatureRepository? repository})
      : _repository = repository ?? TemperatureRepositoryImpl();

  Map<String, List<Map<String, dynamic>>> get data {
    final repoData = _repository.data;
    final totalPoints = repoData.values.fold<int>(0, (sum, list) => sum + list.length);
    // Only log when data count changes significantly to avoid spam
    if ((totalPoints - _lastLoggedCount).abs() > 100) {
        debugPrint('[TemperatureService] Data accessed: $totalPoints total points across ${repoData.keys.length} sensors');
      _lastLoggedCount = totalPoints;
    }
    return repoData;
  }
  bool get isOffline => _repository.isOffline;
  List<DataRange> get loadedRanges => _repository.loadedRanges;

  /// Load latest temperature readings for display on current tab.
  /// Implements 10-second minimum interval to prevent excessive API calls during rapid screen transitions.
  Future<bool> update({int maxRetries = 3}) async {
    try {
      await _repository.updateLatestData(maxRetries: maxRetries);
      return true;
    } catch (e) {
      // For backward compatibility, catch exceptions and return false
      return false;
    }
  }

  /// Load temperature data for chart display with intelligent buffering.
  /// Buffer prevents gaps during pan/zoom gestures by pre-loading adjacent time periods.
  Future<bool> load(DateTime start, DateTime end, {Duration? buffer, int maxRetries = 3}) async {
    try {
      final requestedRange = DataRange(start: start, end: end);
      final rangeWithBuffer = buffer != null ? requestedRange.withBuffer(buffer) : requestedRange;
      
      await _repository.loadDataForRange(rangeWithBuffer, maxRetries: maxRetries);
      return true;
    } catch (e) {
      // For backward compatibility, catch exceptions and return false
      return false;
    }
  }

  /// Check if we have data for a specific time range
  bool hasData(DateTime start, DateTime end) {
    final range = DataRange(start: start, end: end);
    return _repository.hasDataForRange(range);
  }

  /// Get filtered data for a specific time range
  Map<String, List<Map<String, dynamic>>> get(DateTime start, DateTime end) {
    final range = DataRange(start: start, end: end);
    return _repository.getDataForRange(range);
  }

  /// Legacy method names for backward compatibility
  @Deprecated('Use update() instead')
  Future<bool> updateLatestData({int maxRetries = 3}) => update(maxRetries: maxRetries);
  
  @Deprecated('Use load() instead') 
  Future<bool> loadDataForTimeRange(DateTime start, DateTime end, {Duration? buffer, int maxRetries = 3}) =>
      load(start, end, buffer: buffer, maxRetries: maxRetries);
      
  @Deprecated('Use hasData() instead')
  bool hasDataForTimeRange(DateTime start, DateTime end) => hasData(start, end);
  
  @Deprecated('Use get() instead')
  Map<String, List<Map<String, dynamic>>> getDataForTimeRange(DateTime start, DateTime end) => get(start, end);
  
  @Deprecated('Use update() instead')
  Future<bool> updateTemperatureData({int maxRetries = 3}) => update(maxRetries: maxRetries);

  // Helper methods for accessing specific temperature data
  double? get currentWaterTemperature {
    final waterData = data['waterTempFaehrweg'];
    if (waterData != null && waterData.isNotEmpty) {
      return waterData.last['v'] as double?;
    }
    return null;
  }

  double? get currentAirTemperature {
    final airData = data['airTempFaehrweg'];
    if (airData != null && airData.isNotEmpty) {
      return airData.last['v'] as double?;
    }
    return null;
  }

  double? get currentBatteryVoltage {
    final batteryData = data['batFaehrweg'];
    if (batteryData != null && batteryData.isNotEmpty) {
      return batteryData.last['v'] as double?;
    }
    return null;
  }

  DateTime? get lastMeasurementTime {
    final batteryData = data['batFaehrweg'];
    if (batteryData != null && batteryData.isNotEmpty) {
      return batteryData.last['t'] as DateTime?;
    }
    return null;
  }
}
