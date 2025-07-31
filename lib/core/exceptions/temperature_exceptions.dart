class TemperatureAuthException implements Exception {
  final String message;
  TemperatureAuthException([this.message = 'Authentication failed']);
  @override
  String toString() => 'TemperatureAuthException: $message';
}

class TemperatureNotFoundException implements Exception {
  final String message;
  TemperatureNotFoundException([this.message = 'Temperature data not found']);
  @override
  String toString() => 'TemperatureNotFoundException: $message';
}

class TemperatureApiException implements Exception {
  final String message;
  TemperatureApiException([this.message = 'Unexpected API error']);
  @override
  String toString() => 'TemperatureApiException: $message';
}
