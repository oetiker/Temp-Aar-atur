import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import '../services/chart_data_manager.dart';

class ChartGestureHandler {
  final ChartDataManager chartDataManager;
  final Function(DateTime, DateTime) onTimeRangeChanged;
  final Function(bool) onLoadingChanged;
  
  DateTime _lastDataLoadRequest = DateTime.fromMillisecondsSinceEpoch(0);
  static const Duration _dataLoadThrottle = Duration(milliseconds: 800);

  ChartGestureHandler({
    required this.chartDataManager,
    required this.onTimeRangeChanged,
    required this.onLoadingChanged,
  });

  void handleGesture(GestureEvent event, DateTime minTime, DateTime maxTime, Size screenSize) {
    final gesture = event.gesture;
    
    if (gesture.details == null) return;
    
    dynamic details = gesture.details;
    final detailsType = details.runtimeType.toString();
    
      debugPrint('Gesture type: $detailsType');
    
    if (detailsType == 'ScaleUpdateDetails') {
      _processScaleGesture(details, minTime, maxTime, screenSize);
    } else if (detailsType == 'DragUpdateDetails') {
      _processDragGesture(details, minTime, maxTime, screenSize);
    }
  }

  void _processScaleGesture(dynamic details, DateTime minTime, DateTime maxTime, Size screenSize) {
    try {
      final delta = details.focalPointDelta as Offset;
        debugPrint('Scale gesture: dx=${delta.dx}, dy=${delta.dy}');
      
      if (delta.dx.abs() <= 0.5 && delta.dy.abs() <= 0.5) return;
      
      final timeSpan = maxTime.millisecondsSinceEpoch - minTime.millisecondsSinceEpoch;
      
      DateTime newMinTime;
      DateTime newMaxTime;
      
      // Prioritize horizontal movement for panning - treat as pan if there's any significant horizontal movement
      if (delta.dx.abs() > 0.1) {
          debugPrint('Processing as PAN: dx=${delta.dx}');
        final result = _handlePan(delta.dx, timeSpan.toDouble(), minTime, maxTime, screenSize.width);
        newMinTime = result['min']!;
        newMaxTime = result['max']!;
      } else if (delta.dy.abs() > 1.0) {
        // Only zoom if there's significant vertical movement and minimal horizontal movement
          debugPrint('Processing as ZOOM: dy=${delta.dy}');
        final result = _handleZoom(delta.dy, timeSpan.toDouble(), minTime, maxTime, screenSize.height);
        newMinTime = result['min']!;
        newMaxTime = result['max']!;
      } else {
          debugPrint('Gesture too small, ignoring');
        return;
      }
      
        debugPrint('Time range change: ${minTime.toIso8601String()} -> ${newMinTime.toIso8601String()}');
        debugPrint('                  ${maxTime.toIso8601String()} -> ${newMaxTime.toIso8601String()}');
      
      onTimeRangeChanged(newMinTime, newMaxTime);
      _checkDataLoading(newMinTime, newMaxTime, minTime, maxTime);
    } catch (e) {
        debugPrint('Gesture handling error: $e');
    }
  }

  void _processDragGesture(dynamic details, DateTime minTime, DateTime maxTime, Size screenSize) {
    try {
      final delta = details.delta as Offset;
        debugPrint('Drag gesture: dx=${delta.dx}, dy=${delta.dy}');
      
      if (delta.dx.abs() <= 0.5 && delta.dy.abs() <= 0.5) return;
      
      final timeSpan = maxTime.millisecondsSinceEpoch - minTime.millisecondsSinceEpoch;
      
      DateTime newMinTime;
      DateTime newMaxTime;
      
      if (delta.dx.abs() > delta.dy.abs()) {
        final result = _handlePan(delta.dx, timeSpan.toDouble(), minTime, maxTime, screenSize.width);
        newMinTime = result['min']!;
        newMaxTime = result['max']!;
      } else {
        final result = _handleZoom(delta.dy, timeSpan.toDouble(), minTime, maxTime, screenSize.height);
        newMinTime = result['min']!;
        newMaxTime = result['max']!;
      }
      
      onTimeRangeChanged(newMinTime, newMaxTime);
      _checkDataLoading(newMinTime, newMaxTime, minTime, maxTime);
    } catch (e) {
        debugPrint('Drag gesture handling error: $e');
    }
  }

  Map<String, DateTime> _handlePan(double deltaX, double timeSpan, DateTime minTime, DateTime maxTime, double screenWidth) {
    // Fix direction: dragging right (positive deltaX) should move backward in time (show earlier data)
    // dragging left (negative deltaX) should move forward in time (show later data)
    final timeOffset = -(deltaX / screenWidth) * timeSpan * 2.0;
      debugPrint('Pan calculation: deltaX=$deltaX, timeOffset=$timeOffset ms');
    
    var newMinTime = DateTime.fromMillisecondsSinceEpoch((minTime.millisecondsSinceEpoch + timeOffset).round());
    var newMaxTime = DateTime.fromMillisecondsSinceEpoch((maxTime.millisecondsSinceEpoch + timeOffset).round());
    
    return _constrainPanTimes(newMinTime, newMaxTime);
  }

  Map<String, DateTime> _handleZoom(double deltaY, double timeSpan, DateTime minTime, DateTime maxTime, double screenHeight) {
    // Increase zoom sensitivity from 2.0 to 5.0 for more responsive zooming
    final zoomFactor = 1.0 - (deltaY / screenHeight) * 5.0;
      debugPrint('Zoom calculation: deltaY=$deltaY, zoomFactor=$zoomFactor');
    
    final newTimeSpan = (timeSpan * zoomFactor).clamp(
      Duration(hours: 4).inMilliseconds.toDouble(),      // Minimum 4 hours view
      Duration(days: 30 * 14).inMilliseconds.toDouble()  // Maximum 14 months view
    );
    
    final timeCenter = (minTime.millisecondsSinceEpoch + maxTime.millisecondsSinceEpoch) / 2;
    var newMinTime = DateTime.fromMillisecondsSinceEpoch((timeCenter - newTimeSpan / 2).round());
    var newMaxTime = DateTime.fromMillisecondsSinceEpoch((timeCenter + newTimeSpan / 2).round());
    
    return _constrainZoomTimes(newMinTime, newMaxTime);
  }

  Map<String, DateTime> _constrainPanTimes(DateTime newMinTime, DateTime newMaxTime) {
    final earliestAllowed = DateTime(2020, 1, 1);
    final latestAllowed = DateTime.now();
    final currentSpan = newMaxTime.millisecondsSinceEpoch - newMinTime.millisecondsSinceEpoch;
    
    if (newMinTime.isBefore(earliestAllowed)) {
      newMinTime = earliestAllowed;
      newMaxTime = DateTime.fromMillisecondsSinceEpoch(earliestAllowed.millisecondsSinceEpoch + currentSpan);
    }
    if (newMaxTime.isAfter(latestAllowed)) {
      newMaxTime = latestAllowed;
      newMinTime = DateTime.fromMillisecondsSinceEpoch(latestAllowed.millisecondsSinceEpoch - currentSpan);
    }
    
    return {'min': newMinTime, 'max': newMaxTime};
  }
  
  Map<String, DateTime> _constrainZoomTimes(DateTime newMinTime, DateTime newMaxTime) {
    final earliestAllowed = DateTime(2020, 1, 1);
    final latestAllowed = DateTime.now();
    
    if (newMinTime.isBefore(earliestAllowed)) {
      newMinTime = earliestAllowed;
    }
    if (newMaxTime.isAfter(latestAllowed)) {
      newMaxTime = latestAllowed;
    }
    
    final maxSpan = const Duration(days: 30 * 14).inMilliseconds;  // Allow max 14 months view
    if (newMaxTime.millisecondsSinceEpoch - newMinTime.millisecondsSinceEpoch > maxSpan) {
      final center = (newMinTime.millisecondsSinceEpoch + newMaxTime.millisecondsSinceEpoch) / 2;
      newMinTime = DateTime.fromMillisecondsSinceEpoch((center - maxSpan / 2).round());
      newMaxTime = DateTime.fromMillisecondsSinceEpoch((center + maxSpan / 2).round());
    }
    
    return {'min': newMinTime, 'max': newMaxTime};
  }

  void _checkDataLoading(DateTime newMinTime, DateTime newMaxTime, DateTime previousMinTime, DateTime previousMaxTime) async {
    final now = DateTime.now();
    if (now.difference(_lastDataLoadRequest) > _dataLoadThrottle) {
      if (chartDataManager.needsMoreData(newMinTime, newMaxTime)) {
        _lastDataLoadRequest = now;
        onLoadingChanged(true);
        await chartDataManager.handleChartNavigation(
          newMinTime, 
          newMaxTime,
          previousMinTime: previousMinTime,
          previousMaxTime: previousMaxTime,
        );
        onLoadingChanged(false);
      }
    }
  }
}
