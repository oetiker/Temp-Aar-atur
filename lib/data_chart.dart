import 'dart:async';
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'linear_nice_dates.dart';
import 'size_config.dart';
import 'services/service_locator.dart';
import 'services/temperature_service.dart';
import 'services/chart_data_manager.dart';
import 'constants.dart';
import 'l10n/app_localizations.dart';
import 'package:intl/intl.dart' as intl;

class DataChart extends StatefulWidget {
  final TemperatureService? temperatureService;
  
  const DataChart({super.key, this.temperatureService});

  @override
  State<DataChart> createState() => _DataChartState();
}

class _DataChartState extends State<DataChart> {
  late DateTime _minTime;
  late DateTime _maxTime;
  late TemperatureService _temperatureService;
  late ChartDataManager _chartDataManager;
  bool _isLoadingData = false;
  
  // Throttling for data loading during fast gestures
  DateTime _lastDataLoadRequest = DateTime.fromMillisecondsSinceEpoch(0);
  static const Duration _dataLoadThrottle = Duration(milliseconds: 300);

  final _gestureStream = StreamController<GestureEvent>.broadcast();

  // Common styles for AxisGuide components
  static final _commonLineStyle = PaintStyle(strokeColor: Colors.white, strokeWidth: 1, dash: [1, 1]);
  static final _commonTickLineStyle = TickLine(
    style: PaintStyle(strokeColor: Colors.white, strokeWidth: 1),
    length: 4,
  );
  static final _commonLabelStyle = LabelStyle(
    textStyle: const TextStyle(
      color: Colors.white,
      fontSize: AppConstants.chartLabelSize,
    ),
    offset: const Offset(0, 10),
  );

  @override
  void initState() {
    super.initState();
    _temperatureService = widget.temperatureService ?? ServiceLocator().get<TemperatureService>();
    _chartDataManager = ChartDataManager(_temperatureService);
    _initializeTimeRange();
    _updateValueRange();
    _loadInitialChartData();

    _gestureStream.stream.listen(_handleGesture);
  }

  void _loadInitialChartData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingData = true;
    });
    
    // Debug: Test range loading
    // print('=== DEBUG: Testing range loading on chart init ===');
    // await _chartDataManager.testRangeLoading();
    
    // Load data for initial chart view (last 7 days) with buffer
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    
    await _chartDataManager.ensureDataForChartView(weekAgo, now);
    
    // Update time range based on available data
    _initializeTimeRange();
    
    if (!mounted) return;
    
    setState(() {
      _isLoadingData = false;
    });
    
    // Pre-load adjacent data for smooth navigation
    _chartDataManager.preloadAdjacentData(_minTime, _maxTime);
  }

  void _initializeTimeRange() {
    final data = _temperatureService.data;
    final waterData = data['waterTempFaehrweg'];
    
    if (waterData != null && waterData.isNotEmpty) {
      _minTime = waterData.first['t'] ?? DateTime.now();
      _maxTime = waterData.last['t'] ?? DateTime.now();
    } else {
      // Default time range if no data is available yet
      final now = DateTime.now();
      _maxTime = now;
      _minTime = now.subtract(const Duration(hours: 24));
    }
  }

  void _updateValueRange() {
    // This is now handled per chart in the timeSeriesChart method
    // No global range needed anymore
  }

  Map<String, double> _getValueRangeForKey(String key) {
    // Calculate min/max values from visible data for specific key in current time window
    final data = _temperatureService.data;
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

  void refreshData() {
    _initializeTimeRange();
    setState(() {});
  }

  void _loadDataForNavigation(DateTime previousMinTime, DateTime previousMaxTime) async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingData = true;
    });
    
    await _chartDataManager.handleChartNavigation(
      _minTime, 
      _maxTime,
      previousMinTime: previousMinTime,
      previousMaxTime: previousMaxTime,
    );
    
    if (!mounted) return;
    
    setState(() {
      _isLoadingData = false;
    });
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

  Widget _buildChartHeader(String title, bool showTimestamp) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppConstants.chartLeftPadding,
        right: AppConstants.chartRightPadding,
        bottom: AppConstants.chartTitleSpacing,
      ),
      child: showTimestamp 
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppConstants.chartTitleSize,
                  color: Colors.white,
                ),
              ),
              Text(
                intl.DateFormat('yyyy-MM-dd HH:mm').format(_maxTime.toLocal()),
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: AppConstants.chartTimestampSize,
                  color: Colors.white70,
                ),
              ),
            ],
          )
        : Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppConstants.chartTitleSize,
                color: Colors.white,
              ),
            ),
          ),
    );
  }

  void _handleGesture(GestureEvent event) {
    final gesture = event.gesture;
    
    if (gesture.details == null) return;
    
    dynamic details = gesture.details;
    
    // Handle ScaleUpdateDetails which contain focalPointDelta
    if (details.runtimeType.toString() == 'ScaleUpdateDetails') {
      _processScaleGesture(details);
    }
  }

  void _processScaleGesture(dynamic details) {
    try {
      final delta = details.focalPointDelta as Offset;
      if (delta.dx.abs() <= 0.1 && delta.dy.abs() <= 0.1) return; // Only process significant movements
      
      if (!mounted) return;
      
      setState(() {
        final timeSpan = _maxTime.millisecondsSinceEpoch - _minTime.millisecondsSinceEpoch;
        
        if (delta.dx.abs() > delta.dy.abs()) {
          _handlePanGesture(delta.dx, timeSpan.toDouble());
        } else {
          _handleZoomGesture(delta.dy, timeSpan.toDouble());
        }
      });
    } catch (e) {
      // Log error instead of silently ignoring
      debugPrint('Gesture handling error: $e');
    }
  }

  void _handlePanGesture(double deltaX, double timeSpan) async {
    // Store previous times for progressive loading
    final previousMinTime = _minTime;
    final previousMaxTime = _maxTime;
    
    // Debug: print('Pan DEBUG: deltaX=$deltaX, timeSpan=$timeSpan, currentRange=${_minTime} to ${_maxTime}');
    
    // Horizontal drag: pan time window
    final timeOffset = -(deltaX / SizeConfig.screenWidth) * timeSpan * 1.0;
    var newMinTime = DateTime.fromMillisecondsSinceEpoch((_minTime.millisecondsSinceEpoch + timeOffset).round());
    var newMaxTime = DateTime.fromMillisecondsSinceEpoch((_maxTime.millisecondsSinceEpoch + timeOffset).round());
    
    // Debug: print('Pan DEBUG: timeOffset=$timeOffset, newRange=$newMinTime to $newMaxTime');
    
    // Constrain panning to available data bounds
    final constrainedTimes = _constrainPanTimes(newMinTime, newMaxTime);
    _minTime = constrainedTimes['min']!;
    _maxTime = constrainedTimes['max']!;
    
    // Debug: print('Pan DEBUG: constrainedRange=${_minTime} to ${_maxTime}');
    
    // Load data progressively if needed (with throttling to prevent rapid requests)
    final now = DateTime.now();
    if (now.difference(_lastDataLoadRequest) > _dataLoadThrottle) {
      // Debug: print('Pan: Checking if more data needed for ${_minTime} to ${_maxTime}');
      if (_chartDataManager.needsMoreData(_minTime, _maxTime)) {
        // Debug: print('Pan: Loading data for navigation');
        _lastDataLoadRequest = now;
        _loadDataForNavigation(previousMinTime, previousMaxTime);
      } else {
        // Debug: print('Pan: No additional data needed');
      }
    }
    
    _updateValueRange();
  }

  void _handleZoomGesture(double deltaY, double timeSpan) async {
    // Store previous times for progressive loading
    final previousMinTime = _minTime;
    final previousMaxTime = _maxTime;
    
    // Vertical movement: zoom
    final zoomFactor = 1.0 - (deltaY / SizeConfig.screenHeight) * 2.0;
    final newTimeSpan = (timeSpan * zoomFactor).clamp(
      Duration(minutes: 1).inMilliseconds.toDouble(), 
      Duration(days: 365).inMilliseconds.toDouble() // Allow zooming out to full year
    );
    
    final timeCenter = (_minTime.millisecondsSinceEpoch + _maxTime.millisecondsSinceEpoch) / 2;
    var newMinTime = DateTime.fromMillisecondsSinceEpoch((timeCenter - newTimeSpan / 2).round());
    var newMaxTime = DateTime.fromMillisecondsSinceEpoch((timeCenter + newTimeSpan / 2).round());
    
    // Constrain zooming to available data bounds
    final constrainedTimes = _constrainZoomTimes(newMinTime, newMaxTime);
    _minTime = constrainedTimes['min']!;
    _maxTime = constrainedTimes['max']!;
    
    // Load data progressively if needed (with throttling to prevent rapid requests)
    final now = DateTime.now();
    if (now.difference(_lastDataLoadRequest) > _dataLoadThrottle) {
      // Debug: print('Zoom: Checking if more data needed for ${_minTime} to ${_maxTime}');
      if (_chartDataManager.needsMoreData(_minTime, _maxTime)) {
        // Debug: print('Zoom: Loading data for navigation');
        _lastDataLoadRequest = now;
        _loadDataForNavigation(previousMinTime, previousMaxTime);
      } else {
        // Debug: print('Zoom: No additional data needed');
      }
    }
    
    _updateValueRange();
  }
  
  Map<String, DateTime> _constrainPanTimes(DateTime newMinTime, DateTime newMaxTime) {
    // Allow panning beyond loaded data to trigger progressive loading
    // But never allow scrolling into the future - temperature data can't exist in the future
    final earliestAllowed = DateTime(2020, 1, 1);
    final latestAllowed = DateTime.now(); // No future data allowed
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
    // Allow zooming beyond loaded data to trigger progressive loading
    // But never allow zooming into the future - temperature data can't exist in the future
    final earliestAllowed = DateTime(2020, 1, 1);
    final latestAllowed = DateTime.now(); // No future data allowed
    
    if (newMinTime.isBefore(earliestAllowed)) {
      newMinTime = earliestAllowed;
    }
    if (newMaxTime.isAfter(latestAllowed)) {
      newMaxTime = latestAllowed;
    }
    
    // Allow reasonable zoom range (up to 5 years)
    final maxSpan = const Duration(days: 365 * 5).inMilliseconds;
    if (newMaxTime.millisecondsSinceEpoch - newMinTime.millisecondsSinceEpoch > maxSpan) {
      final center = (newMinTime.millisecondsSinceEpoch + newMaxTime.millisecondsSinceEpoch) / 2;
      newMinTime = DateTime.fromMillisecondsSinceEpoch((center - maxSpan / 2).round());
      newMaxTime = DateTime.fromMillisecondsSinceEpoch((center + maxSpan / 2).round());
    }
    
    return {'min': newMinTime, 'max': newMaxTime};
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
            title: AppLocalizations.of(context)!.airTemperature.split(' ').first, // "Luft" from "Lufttemperatur"
            unit: 'C',
            color: const Color.fromARGB(255, 49, 125, 238),
          ),
        ),
        Flexible(
          flex: 1,
          child: timeSeriesChart(
            'waterTempFaehrweg',
            title: AppLocalizations.of(context)!.waterTemperature.split(' ').first, // "Wasser" from "Wassertemperatur"
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
    final rawData = _temperatureService.data[key] ?? [];
    
    // Sort data by time and filter for current time window to prevent connecting lines
    final data = rawData
        .where((point) {
          final pointTime = point['t'] as DateTime;
          return pointTime.isAfter(_minTime.subtract(const Duration(minutes: 1))) && 
                 pointTime.isBefore(_maxTime.add(const Duration(minutes: 1)));
        })
        .toList()
        ..sort((a, b) => (a['t'] as DateTime).compareTo(b['t'] as DateTime));
    
    // If no data in the current time window, return a placeholder
    if (data.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.noDataForPeriod,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      );
    }
    
    final double width = SizeConfig.screenWidth;
    
    // Create text style that matches what the chart will use for labels
    const labelTextStyle = TextStyle(
      color: Colors.white,
      fontSize: AppConstants.chartLabelSize,
    );
    
    final niceDateData = linearNiceDates(_minTime, _maxTime, width, 1, textStyle: labelTextStyle);
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
        child: _buildChartHeader(title, key == 'airTempFaehrweg'),
      ),
      Flexible(
        flex: 1,
        child: Stack(
          children: [
            Semantics(
              label: AppLocalizations.of(context)!.temperatureChart(title),
              child: Chart(
            data: data,
            padding: (size) => const EdgeInsets.only(
              left: AppConstants.chartLeftPadding, 
              right: AppConstants.chartRightPadding,
              bottom: 40,
            ),
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
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: AppConstants.chartLabelSize,
                  ),
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
          ),
        ),
            // Loading indicator overlay
            if (_isLoadingData)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                  ),
                ),
              ),
          ],
        ),
      )
    ]);
  }

}
