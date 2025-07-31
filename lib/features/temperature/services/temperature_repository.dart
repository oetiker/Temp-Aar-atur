import '../models/data_loading_level.dart';

/// Repository interface for temperature data following Flutter style guide patterns
/// Throws exceptions instead of returning boolean success/failure values
abstract class TemperatureRepository {
  Map<String, List<Map<String, dynamic>>> get data;
  bool get isOffline;
  List<DataRange> get loadedRanges;
  
  /// Load latest data (equivalent to current API call with 'last' parameter)
  /// Throws [ApiException] if server returns error status
  /// Throws [NetworkException] if network connectivity fails
  /// Throws [DataParsingException] if response data is malformed
  Future<void> updateLatestData({int maxRetries = 3});
  
  /// Load data for a specific time range using range parameter
  /// Throws [ApiException] if server returns error status
  /// Throws [NetworkException] if network connectivity fails
  /// Throws [DataParsingException] if response data is malformed
  /// Throws [DataNotAvailableException] if requested range is not available
  Future<void> loadDataForRange(DataRange range, {int maxRetries = 3});
  
  /// Backwards compatibility method - delegates to updateLatestData
  Future<void> updateData({int maxRetries = 3});
  
  /// Check if data is available for a given time range
  bool hasDataForRange(DataRange range);
  
  /// Get missing data ranges that need to be fetched for the requested range
  List<DataRange> getMissingRanges(DataRange requestedRange);
  
  /// Clear all cached data
  void clearData();
  
  /// Get data filtered to a specific time range
  Map<String, List<Map<String, dynamic>>> getDataForRange(DataRange range);
}