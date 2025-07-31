/// Simple, immutable data class representing battery information
/// Follows Flutter style guide pattern for model classes
class BatteryInfo {
  final double voltage;
  final DateTime timestamp;

  const BatteryInfo({
    required this.voltage,
    required this.timestamp,
  });

  /// Create from API response data
  factory BatteryInfo.fromJson(Map<String, dynamic> json) {
    return BatteryInfo(
      voltage: (json['v'] as num).toDouble(),
      timestamp: json['t'] as DateTime,
    );
  }

  /// Convert to API format
  Map<String, dynamic> toJson() {
    return {
      'v': voltage,
      't': timestamp,
    };
  }

  /// Format voltage for display
  String get displayText => '${voltage.toStringAsFixed(2)} V';

  /// Check if battery level is healthy (>= 3.0V typical for sensor)
  bool get isHealthy => voltage >= 3.0;

  /// Check if reading is recent (within last hour)
  bool get isRecent => DateTime.now().difference(timestamp).inHours < 1;

  @override
  String toString() => 'BatteryInfo($displayText at $timestamp)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BatteryInfo &&
          runtimeType == other.runtimeType &&
          voltage == other.voltage &&
          timestamp == other.timestamp;

  @override
  int get hashCode => voltage.hashCode ^ timestamp.hashCode;
}