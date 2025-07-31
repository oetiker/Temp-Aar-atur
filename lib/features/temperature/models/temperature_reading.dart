/// Simple, immutable data class representing a temperature reading
/// Follows Flutter style guide pattern for model classes
class TemperatureReading {
  final double value;
  final DateTime timestamp;
  final String unit;

  const TemperatureReading({
    required this.value,
    required this.timestamp,
    this.unit = '°C',
  });

  /// Create from API response data
  factory TemperatureReading.fromJson(Map<String, dynamic> json) {
    return TemperatureReading(
      value: (json['v'] as num).toDouble(),
      timestamp: json['t'] as DateTime,
      unit: json['unit'] as String? ?? '°C',
    );
  }

  /// Convert to API format
  Map<String, dynamic> toJson() {
    return {
      'v': value,
      't': timestamp,
      'unit': unit,
    };
  }

  /// Format temperature value for display
  String get displayText => '${value.toStringAsFixed(1)} $unit';

  /// Check if reading is recent (within last hour)
  bool get isRecent => DateTime.now().difference(timestamp).inHours < 1;

  @override
  String toString() => 'TemperatureReading($displayText at $timestamp)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TemperatureReading &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          timestamp == other.timestamp &&
          unit == other.unit;

  @override
  int get hashCode => value.hashCode ^ timestamp.hashCode ^ unit.hashCode;
}