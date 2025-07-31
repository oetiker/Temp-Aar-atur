import '../services/temperature_service.dart';
import '../models/data_loading_level.dart';

class ChartDataManager {
  final TemperatureService _temperatureService;
  
  // Buffer settings for smooth navigation
  static const Duration _panBuffer = Duration(hours: 6); // Buffer for panning
  static const Duration _zoomBuffer = Duration(hours: 12); // Buffer for zooming
  
  ChartDataManager(this._temperatureService);
  
  /// Ensure data is available for the chart's current view with buffers for navigation
  Future<bool> ensureDataForChartView(DateTime minTime, DateTime maxTime) async {
    // Debug:  debugPrint'ensureDataForChartView: $minTime to $maxTime');
    
    // Check if we already have data for this range
    if (_temperatureService.hasData(minTime, maxTime)) {
      // Debug:  debugPrint'Data already available for range');
      return true;
    }
    
    // Debug:  debugPrint'Loading new data for range');
    
    // Calculate buffer based on the current time span
    final timeSpan = maxTime.difference(minTime);
    Duration buffer;
    
    if (timeSpan.inHours <= 24) {
      buffer = _panBuffer; // Smaller buffer for detailed views
    } else if (timeSpan.inDays <= 7) {
      buffer = _zoomBuffer; // Medium buffer for weekly views  
    } else {
      buffer = const Duration(days: 2); // Larger buffer for long-term views
    }
    
    final result = await _temperatureService.load(
      minTime, 
      maxTime, 
      buffer: buffer,
    );
    
    // Debug:  debugPrint'Data loading result: $result');
    return result;
  }
  
  /// Progressive loading strategy based on user interaction
  Future<bool> handleChartNavigation(DateTime newMinTime, DateTime newMaxTime, {
    DateTime? previousMinTime,
    DateTime? previousMaxTime,
  }) async {
    
    // If this is the first load or a major jump, load with larger buffer
    if (previousMinTime == null || previousMaxTime == null) {
      return await ensureDataForChartView(newMinTime, newMaxTime);
    }
    
    // Calculate how much the view has moved
    final minDelta = newMinTime.difference(previousMinTime);
    final maxDelta = newMaxTime.difference(previousMaxTime);
    final viewSpan = newMaxTime.difference(newMinTime);
    
    // If it's a small pan (less than 50% of view), use smaller buffer
    if (minDelta.abs() < viewSpan * 0.5 && maxDelta.abs() < viewSpan * 0.5) {
      return await _temperatureService.load(
        newMinTime,
        newMaxTime,
        buffer: _panBuffer,
      );
    }
    
    // For larger movements or zooms, use bigger buffer
    return await ensureDataForChartView(newMinTime, newMaxTime);
  }
  
  /// Pre-load data for likely next navigation areas
  Future<void> preloadAdjacentData(DateTime minTime, DateTime maxTime) async {
    final viewSpan = maxTime.difference(minTime);
    
    // Pre-load data before and after current view (fire and forget)
    _temperatureService.load(
      minTime.subtract(viewSpan),
      minTime,
      buffer: const Duration(hours: 1),
    ).ignore(); // Don't wait for completion
    
    _temperatureService.load(
      maxTime,
      maxTime.add(viewSpan),
      buffer: const Duration(hours: 1),
    ).ignore(); // Don't wait for completion
  }
  
  /// Debug method to test range loading
  Future<void> testRangeLoading() async {
    final now = DateTime.now();
    final twoWeeksAgo = now.subtract(const Duration(days: 14));
    
    // Debug:  debugPrint'=== Testing Range Loading ===');
    // Debug:  debugPrint'Requesting data from $twoWeeksAgo to $now');
    
    await _temperatureService.load(
      twoWeeksAgo,
      now,
      buffer: const Duration(hours: 1),
    );
    
    // Debug:  debugPrint'Range loading result: $result');
    // Debug:  debugPrint'Loaded ranges: ${_temperatureService.loadedRanges}');
    // Debug:  debugPrint'=== End Test ===');
  }

  /// Get loading progress for UI feedback
  String getLoadingProgress() {
    final ranges = _temperatureService.loadedRanges;
    if (ranges.isEmpty) {
      return 'No data loaded';
    }
    
    final totalDuration = ranges.fold<Duration>(
      Duration.zero,
      (total, range) => total + range.duration,
    );
    
    if (totalDuration.inDays > 365) {
      return 'Full historical data loaded';
    } else if (totalDuration.inDays > 30) {
      return '${totalDuration.inDays} days of historical data';
    } else if (totalDuration.inDays > 1) {
      return '${totalDuration.inDays} days of data loaded';
    } else {
      return '${totalDuration.inHours} hours of data loaded';
    }
  }
  
  /// Check if we need to load more data based on chart bounds
  bool needsMoreData(DateTime minTime, DateTime maxTime, {Duration safetyMargin = const Duration(hours: 2)}) {
    final expandedRange = DataRange(
      start: minTime.subtract(safetyMargin),
      end: maxTime.add(safetyMargin),
    );
    
    final hasData = _temperatureService.hasData(
      expandedRange.start,
      expandedRange.end,
    );
    
    final needsData = !hasData;
    
    // Debug logging with more detail
    // Debug:  debugPrint'needsMoreData: $needsData for range ${expandedRange.start} to ${expandedRange.end}');
    // Debug:  debugPrint'Current loaded ranges: ${_temperatureService.loadedRanges}');
    // Debug:  debugPrint'hasDataForTimeRange returned: $hasData');
    
    return needsData;
  }
}