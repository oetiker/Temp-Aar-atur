import 'package:temp_aar_ature/features/temperature/services/temperature_repository.dart';
import 'package:temp_aar_ature/features/temperature/models/data_loading_level.dart';

class MockTemperatureRepository implements TemperatureRepository {
  Map<String, List<Map<String, dynamic>>> _mockData = {};
  final List<DataRange> _loadedRanges = [];
  bool _isOffline = false;
  bool _updateResult = true;
  int _updateDataCallCount = 0;
  int _lastMaxRetries = 3;

  @override
  Map<String, List<Map<String, dynamic>>> get data => _mockData;

  @override
  bool get isOffline => _isOffline;

  @override
  List<DataRange> get loadedRanges => _loadedRanges;

  @override
  Future<void> updateLatestData({int maxRetries = 3}) async {
    _updateDataCallCount++;
    _lastMaxRetries = maxRetries;
    if (!_updateResult) {
      throw Exception('Mock update failed');
    }
  }

  @override
  Future<void> updateData({int maxRetries = 3}) async {
    return await updateLatestData(maxRetries: maxRetries);
  }

  @override
  Future<void> loadDataForRange(DataRange range, {int maxRetries = 3}) async {
    _updateDataCallCount++;
    _lastMaxRetries = maxRetries;
    if (!_updateResult) {
      throw Exception('Mock load failed');
    }
  }

  @override
  bool hasDataForRange(DataRange range) {
    return _updateResult;
  }

  @override
  List<DataRange> getMissingRanges(DataRange requestedRange) {
    return _updateResult ? [] : [requestedRange];
  }

  @override
  void clearData() {
    _mockData.clear();
    _loadedRanges.clear();
  }

  @override
  Map<String, List<Map<String, dynamic>>> getDataForRange(DataRange range) {
    return _mockData;
  }

  // Test helper methods
  void setMockData(Map<String, List<Map<String, dynamic>>> data) {
    _mockData = data;
  }

  void setOfflineStatus(bool offline) {
    _isOffline = offline;
  }

  void setUpdateResult(bool result) {
    _updateResult = result;
  }

  int get updateDataCallCount => _updateDataCallCount;
  int get lastMaxRetries => _lastMaxRetries;

  void reset() {
    _mockData = {};
    _isOffline = false;
    _updateResult = true;
    _updateDataCallCount = 0;
    _lastMaxRetries = 3;
  }
}