import '../repositories/temperature_repository.dart';
import '../models/data_loading_level.dart';
import 'service_locator.dart';

class TemperatureService {
  final TemperatureRepository _repository;

  TemperatureService() : _repository = ServiceLocator().get<TemperatureRepository>();

  Map<String, List<Map<String, dynamic>>> get data => _repository.data;
  bool get isOffline => _repository.isOffline;
  List<DataRange> get loadedRanges => _repository.loadedRanges;

  /// Load latest data for current temperature display
  Future<bool> updateLatestData({int maxRetries = 3}) async {
    return await _repository.updateLatestData(maxRetries: maxRetries);
  }

  /// Load data for a specific time range with buffer for smooth navigation
  Future<bool> loadDataForTimeRange(DateTime start, DateTime end, {Duration? buffer, int maxRetries = 3}) async {
    final requestedRange = DataRange(start: start, end: end);
    final rangeWithBuffer = buffer != null ? requestedRange.withBuffer(buffer) : requestedRange;
    
    return await _repository.loadDataForRange(rangeWithBuffer, maxRetries: maxRetries);
  }

  /// Check if we have data for a specific time range
  bool hasDataForTimeRange(DateTime start, DateTime end) {
    final range = DataRange(start: start, end: end);
    return _repository.hasDataForRange(range);
  }

  /// Get filtered data for a specific time range
  Map<String, List<Map<String, dynamic>>> getDataForTimeRange(DateTime start, DateTime end) {
    final range = DataRange(start: start, end: end);
    return _repository.getDataForRange(range);
  }

  /// Backwards compatibility method
  Future<bool> updateTemperatureData({int maxRetries = 3}) async {
    return await updateLatestData(maxRetries: maxRetries);
  }

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