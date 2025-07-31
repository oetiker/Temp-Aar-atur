/// Represents a time range for progressive data loading strategy.
/// Prevents memory issues with large datasets by loading only visible chart regions.
class DataRange {
  final DateTime start;
  final DateTime end;
  
  DataRange({required this.start, required this.end});
  
  /// Convert to epoch seconds for API
  int get startEpoch => (start.millisecondsSinceEpoch / 1000).floor();
  int get endEpoch => (end.millisecondsSinceEpoch / 1000).floor();
  
  /// Duration of this range
  Duration get duration => end.difference(start);
  
  /// Check if this range contains a specific time
  bool contains(DateTime time) {
    return time.isAfter(start) && time.isBefore(end);
  }
  
  /// Check if this range overlaps with another range
  bool overlaps(DataRange other) {
    return start.isBefore(other.end) && end.isAfter(other.start);
  }
  
  /// Merge this range with another range
  DataRange merge(DataRange other) {
    return DataRange(
      start: start.isBefore(other.start) ? start : other.start,
      end: end.isAfter(other.end) ? end : other.end,
    );
  }
  
  /// Expand this range by a buffer amount
  DataRange withBuffer(Duration buffer) {
    return DataRange(
      start: start.subtract(buffer),
      end: end.add(buffer),
    );
  }
  
  @override
  String toString() => 'DataRange(${start.toIso8601String()} - ${end.toIso8601String()})';
}