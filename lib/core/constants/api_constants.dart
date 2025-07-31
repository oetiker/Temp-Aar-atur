/// API and data management related constants
class ApiConstants {
  // Data refresh timing - prevents excessive API calls
  static const Duration dataRefreshInterval = Duration(seconds: 700); // 10 minutes + buffer
  
  // Progressive loading strategy for large datasets
  static const Duration initialDataPeriod = Duration(hours: 1); // Current temperature display
  static const Duration chartDataPeriod = Duration(days: 7); // Initial chart view
  static const Duration extendedDataPeriod = Duration(days: 30); // Extended navigation
  static const Duration fullDataPeriod = Duration(days: 365); // Full historical data
}