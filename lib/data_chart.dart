import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'linear_nice_dates.dart';
import 'data_store.dart';
import 'size_config.dart';
import 'package:intl/intl.dart' as intl;

class DataChart extends StatefulWidget {
  const DataChart({Key? key}) : super(key: key);

  @override
  State<DataChart> createState() => _DataChartState();
}

class _DataChartState extends State<DataChart> {
  late DateTime _minTime;
  late DateTime _maxTime;

  final _gestureStream = StreamController<GestureEvent>.broadcast();

  // Common styles for AxisGuide components
  static final _commonLineStyle = PaintStyle(strokeColor: Colors.white, strokeWidth: 1, dash: [1, 1]);
  static final _commonTickLineStyle = TickLine(
    style: PaintStyle(strokeColor: Colors.white, strokeWidth: 1),
    length: 4,
  );
  static final _commonLabelStyle = LabelStyle(
    textStyle: TextStyle(color: Colors.white),
    offset: Offset(0, 10),
  );

  @override
  void initState() {
    super.initState();
    final data = DataStore().data;
    _minTime = data['waterTempFaehrweg']?.first['t'] ?? DateTime.now();
    _maxTime = data['waterTempFaehrweg']?.last['t'] ?? DateTime.now();
    _updateValueRange();

    _gestureStream.stream.listen(_handleGesture);
  }

  void _updateValueRange() {
    // This is now handled per chart in the timeSeriesChart method
    // No global range needed anymore
  }

  Map<String, double> _getValueRangeForKey(String key) {
    // Calculate min/max values from visible data for specific key in current time window
    final data = DataStore().data;
    final keyData = data[key];
    double minVal = double.infinity;
    double maxVal = double.negativeInfinity;
    
    if (keyData != null) {
      for (var point in keyData) {
        final pointTime = point['t'] as DateTime;
        if (pointTime.isAfter(_minTime) && pointTime.isBefore(_maxTime)) {
          final value = point['v'] as double;
          if (value < minVal) minVal = value;
          if (value > maxVal) maxVal = value;
        }
      }
    }
    
    if (minVal != double.infinity && maxVal != double.negativeInfinity) {
      final padding = (maxVal - minVal) * 0.15; // 15% padding for better visibility
      return {
        'min': minVal - padding,
        'max': maxVal + padding,
      };
    } else {
      // Fallback values
      return {
        'min': 0.0,
        'max': 30.0,
      };
    }
  }

  DateTime get _dataMinTime {
    final data = DataStore().data;
    return data['waterTempFaehrweg']?.first['t'] ?? DateTime.now();
  }

  DateTime get _dataMaxTime {
    final data = DataStore().data;
    return data['waterTempFaehrweg']?.last['t'] ?? DateTime.now();
  }



  

  Map<String, List<double>> _generateTemperatureTicks(double min, double max) {
    final span = max - min;
    final List<double> majorTicks = [];
    final List<double> minorTicks = [];

    // Determine major tick interval (full degrees)
    double majorInterval;
    if (span <= 2) {
      majorInterval = 0.5; // Half degrees when zoomed in
    } else if (span <= 10) {
      majorInterval = 1.0; // Full degrees
    } else if (span <= 20) {
      majorInterval = 2.0; // 2 degree intervals
    } else {
      majorInterval = 5.0; // 5 degree intervals
    }

    // Calculate minor tick interval
    double minorInterval;
    if (majorInterval == 0.5) {
      minorInterval = 0.1; // 5 minor lines between 0.5°C majors
    } else if (majorInterval <= 2.0) {
      minorInterval = majorInterval / 5; // 5 minor lines between majors
    } else {
      minorInterval = majorInterval / 5; // 5 minor lines for larger intervals
    }

    // Generate major ticks
    final startMajor = (min / majorInterval).floor() * majorInterval;
    final endMajor = (max / majorInterval).ceil() * majorInterval;

    for (double major = startMajor; major <= endMajor + majorInterval; major += majorInterval) {
      if (major >= min - majorInterval && major <= max + majorInterval) {
        majorTicks.add(major);
      }
    }

    // Generate minor ticks
    for (double major = startMajor; major <= endMajor + majorInterval; major += majorInterval) {
      if (major >= min - majorInterval && major <= max + majorInterval) {
        if (major < endMajor) {
          for (int i = 1; i < 5; i++) {
            double minor = major + (i * minorInterval);
            if (minor >= min && minor <= max && !majorTicks.contains(minor)) {
              minorTicks.add(minor);
            }
          }
        }
      }
    }
    
    majorTicks.sort();
    minorTicks.sort();

    return {'major': majorTicks, 'minor': minorTicks};
  }

  @override
  void dispose() {
    _gestureStream.close();
    super.dispose();
  }

  void _handleGesture(GestureEvent event) {
    final gesture = event.gesture;
    
    if (gesture.details != null) {
      dynamic details = gesture.details;
      
      // Handle ScaleUpdateDetails which contain focalPointDelta
      if (details.runtimeType.toString() == 'ScaleUpdateDetails') {
        try {
          final delta = details.focalPointDelta as Offset;
          if (delta.dx.abs() > 0.1 || delta.dy.abs() > 0.1) { // Only process significant movements
            setState(() {
              final timeSpan = _maxTime.millisecondsSinceEpoch - _minTime.millisecondsSinceEpoch;
              
              // Horizontal drag: pan time window (improved responsiveness)
              if (delta.dx.abs() > delta.dy.abs()) {
                // Primarily horizontal movement - pan
                final timeOffset = -(delta.dx / SizeConfig.screenWidth) * timeSpan * 1.0;
                var newMinTime = DateTime.fromMillisecondsSinceEpoch((_minTime.millisecondsSinceEpoch + timeOffset).round());
                var newMaxTime = DateTime.fromMillisecondsSinceEpoch((_maxTime.millisecondsSinceEpoch + timeOffset).round());
                
                // Constrain panning to available data bounds
                final dataMin = _dataMinTime;
                final dataMax = _dataMaxTime;
                final currentSpan = newMaxTime.millisecondsSinceEpoch - newMinTime.millisecondsSinceEpoch;
                
                if (newMinTime.isBefore(dataMin)) {
                  newMinTime = dataMin;
                  newMaxTime = DateTime.fromMillisecondsSinceEpoch(dataMin.millisecondsSinceEpoch + currentSpan);
                }
                if (newMaxTime.isAfter(dataMax)) {
                  newMaxTime = dataMax;
                  newMinTime = DateTime.fromMillisecondsSinceEpoch(dataMax.millisecondsSinceEpoch - currentSpan);
                }
                
                _minTime = newMinTime;
                _maxTime = newMaxTime;
                _updateValueRange(); // Update value range after panning
              } else {
                // Primarily vertical movement - zoom
                final zoomFactor = 1.0 - (delta.dy / SizeConfig.screenHeight) * 2.0; // Increased sensitivity
                final newTimeSpan = (timeSpan * zoomFactor).clamp(
                  Duration(minutes: 1).inMilliseconds.toDouble(), 
                  Duration(days: 30).inMilliseconds.toDouble()
                );
                final timeCenter = (_minTime.millisecondsSinceEpoch + _maxTime.millisecondsSinceEpoch) / 2;
                var newMinTime = DateTime.fromMillisecondsSinceEpoch((timeCenter - newTimeSpan / 2).round());
                var newMaxTime = DateTime.fromMillisecondsSinceEpoch((timeCenter + newTimeSpan / 2).round());
                
                // Constrain zooming to available data bounds
                final dataMin = _dataMinTime;
                final dataMax = _dataMaxTime;
                
                if (newMinTime.isBefore(dataMin)) {
                  newMinTime = dataMin;
                }
                if (newMaxTime.isAfter(dataMax)) {
                  newMaxTime = dataMax;
                }
                
                // Ensure we don't zoom out beyond the full data range
                final maxSpan = dataMax.millisecondsSinceEpoch - dataMin.millisecondsSinceEpoch;
                if (newMaxTime.millisecondsSinceEpoch - newMinTime.millisecondsSinceEpoch > maxSpan) {
                  newMinTime = dataMin;
                  newMaxTime = dataMax;
                }
                
                _minTime = newMinTime;
                _maxTime = newMaxTime;
                _updateValueRange(); // Update value range after zooming
              }
            });
          }
        } catch (e) {
          // Ignore errors
        }
      }
    }
  }


  // Size _textSize(String text, TextStyle style) {
  //   final TextPainter textPainter = TextPainter(
  //     text: TextSpan(text: text, style: style),
  //     maxLines: 1,
  //     textDirection: TextDirection.ltr,
  //   )..layout(
  //       minWidth: 0,
  //       maxWidth: double.infinity,
  //     );
  //   return textPainter.size;
  // }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(
          flex: 1,
          child: timeSeriesChart(
            'airTempFaehrweg',
            title: 'Luft',
            unit: 'C',
            color: const Color.fromARGB(255, 49, 125, 238),
          ),
        ),
        Flexible(
          flex: 1,
          child: timeSeriesChart(
            'waterTempFaehrweg',
            title: 'Aare',
            color: Colors.greenAccent,
            unit: 'C',
          ),
        ),
        // Flexible(
        //   flex: 1,
        //   child: timeSeriesChart(
        //     'levelTrimbach',
        //     context,
        //     title: 'Wasserstand',
        //     color: Colors.yellow,
        //     unit: 'm',
        //   ),
        // )
      ],
    );
  }

  Widget timeSeriesChart(
    String key, {
    String title = 'No Title',
    String unit = '?',
    Color color = Colors.red,
  }) {
    SizeConfig().init(context);
    final data = DataStore().data[key] ?? [];
    final double fontSize =
        (min(SizeConfig.screenWidth, SizeConfig.screenHeight) / 40);
    final double width = SizeConfig.screenWidth;
    final niceDateData = linearNiceDates(_minTime, _maxTime, width, 1);
    final niceDateTicks = niceDateData['ticks'];
    final majorDateTicks = niceDateData['majorTicks'] ?? [];
    final minorDateTicks = niceDateData['minorTicks'] ?? [];
    final dateFormat = niceDateData['format'];
    
    // Get independent value range for this specific chart
    final valueRange = _getValueRangeForKey(key);
    final chartMinValue = valueRange['min']!;
    final chartMaxValue = valueRange['max']!;

    final temperatureTicks = _generateTemperatureTicks(chartMinValue, chartMaxValue);
    final majorTemperatureTicks = temperatureTicks['major']!;
    final minorTemperatureTicks = temperatureTicks['minor']!;

    return Column(children: <Widget>[
      Container(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: Text(
          title,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
              color: Colors.white),
        ),
      ),
      Flexible(
          flex: 1,
          child: Chart(
            data: data,
            padding: (size) => const EdgeInsets.only(left: 70, bottom: 40),
            variables: {
              'time': Variable(
                accessor: (dynamic map) =>
                    (map['t'] ?? DateTime.now()) as DateTime,
                scale: TimeScale(
                  min: _minTime,
                  max: _maxTime, 
                  ticks: majorDateTicks, // Use only major ticks for horizontal axis
                  formatter: (t) {
                    // Always show labels for major ticks
                    if (dateFormat == "WEEK_NUMBER_FORMAT") {
                      return "KW ${getWeekNumber(t.toLocal())}";
                    }
                    return intl.DateFormat(dateFormat).format(t.toLocal());
                  },
                ),
              ),
              'value': Variable(
                accessor: (dynamic map) => (map['v'] ?? double.nan) as num,
                scale: LinearScale(
                  min: chartMinValue,
                  max: chartMaxValue,
                  formatter: (v) {
                    // Show labels for all ticks since we're only using major ticks now
                    return '${v.toStringAsFixed(1)} $unit';
                  },
                  // Use only major ticks for main scale
                  ticks: majorTemperatureTicks,
                ),
              ),
              'minorTemp': Variable(
                accessor: (dynamic map) => (map['v'] ?? double.nan) as num,
                scale: LinearScale(
                  min: chartMinValue,
                  max: chartMaxValue,
                  ticks: minorTemperatureTicks,
                  formatter: (v) => "", // No labels for minor ticks
                ),
              ),
              // New variable for minor time ticks
              'minorTime': Variable(
                accessor: (dynamic map) => (map['t'] ?? DateTime.now()) as DateTime,
                scale: TimeScale(
                  min: _minTime,
                  max: _maxTime,
                  ticks: minorDateTicks, // Use only minor ticks for this variable
                  formatter: (t) => "", // No labels for minor time ticks
                ),
              )
            },
            marks: [
              AreaMark(
                shape: ShapeEncode(value: BasicAreaShape(smooth: false)),
                color: ColorEncode(value: color.withAlpha(140)),
              ),
              LineMark(
                shape: ShapeEncode(value: BasicLineShape(smooth: false)),
                size: SizeEncode(value: 1),
                color: ColorEncode(value: color),
              ),
            ],
            axes: [
              // Horizontal axis (time) with only major ticks and grid
              AxisGuide(
                dim: Dim.x, // Explicitly set dimension to x
                line: _commonLineStyle,
                tickLine: _commonTickLineStyle,
                label: _commonLabelStyle,
                // Grid for major time ticks with consistent styling
                grid: PaintStyle(strokeColor: Colors.white.withValues(alpha: 0.3), strokeWidth: 0.6, dash: [1, 1]),
              ),
              // Minor horizontal grid only (no labels, no axis line, no ticks)
              AxisGuide(
                variable: 'minorTime',
                dim: Dim.x, // Explicitly set dimension to x
                line: PaintStyle(strokeColor: Colors.transparent),
                tickLine: TickLine(
                  style: PaintStyle(strokeColor: Colors.transparent),
                  length: 0,
                ),
                label: LabelStyle(
                  textStyle: const TextStyle(color: Colors.transparent, fontSize: 0),
                ),
                // Minor horizontal grid lines for time - same pattern as major but more transparent
                grid: PaintStyle(strokeColor: Colors.white.withValues(alpha: 0.3), strokeWidth: 0.5, dash: [1, 1]),
              ),
              // Main vertical axis (temperature) with labels and MAJOR grid only
              AxisGuide(
                variable: 'value',
                line: _commonLineStyle,
                tickLine: _commonTickLineStyle,
                label: LabelStyle(
                  textStyle: const TextStyle(color: Colors.white),
                  offset: const Offset(-10, 0),
                ),
                // Major grid lines for temperature - more prominent
                grid: PaintStyle(strokeColor: Colors.white.withValues(alpha: 0.5), strokeWidth: 1.0, dash: [1, 1]),
              ),
              // Minor temperature grid only (no labels, no axis line, no ticks) - horizontal lines
              AxisGuide(
                variable: 'minorTemp',
                line: PaintStyle(strokeColor: Colors.transparent),
                tickLine: TickLine(
                  style: PaintStyle(strokeColor: Colors.transparent),
                  length: 0,
                ),
                label: LabelStyle(
                  textStyle: const TextStyle(color: Colors.transparent, fontSize: 0),
                ),
                // Minor horizontal grid lines for temperature - same pattern as major but more transparent
                grid: PaintStyle(strokeColor: Colors.white.withValues(alpha: 0.3), strokeWidth: 0.5, dash: [1, 1]),
              ),
            ],
            
            selections: {},
            tooltip: TooltipGuide(
              followPointer: [true, true],
              align: Alignment.topLeft,
              offset: const Offset(-20, -20),
            ),
            crosshair: CrosshairGuide(followPointer: [true, false]),
            gestureStream: _gestureStream,
          ))
    ]);
  }

}
