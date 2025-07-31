import 'dart:async';
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import '../../../core/utils/linear_nice_dates.dart';
import '../../../core/utils/size_config.dart';
import '../services/temperature_service.dart';
import '../../../core/constants/constants.dart';
import '../../../l10n/app_localizations.dart';
import 'package:intl/intl.dart' as intl;
import 'chart_header.dart';
import 'chart_axis_builder.dart';

class TemperatureChart extends StatefulWidget {
  final String dataKey;
  final String title;
  final String unit;
  final Color color;
  final TemperatureService temperatureService;
  final bool isLoading;
  final DateTime? minTime;
  final DateTime? maxTime;
  final StreamController<GestureEvent>? gestureStream;

  const TemperatureChart({
    super.key,
    required this.dataKey,
    required this.title,
    required this.unit,
    required this.color,
    required this.temperatureService,
    this.isLoading = false,
    this.minTime,
    this.maxTime,
    this.gestureStream,
  });

  @override
  State<TemperatureChart> createState() => _TemperatureChartState();
}

class _TemperatureChartState extends State<TemperatureChart> {
  late DateTime _minTime;
  late DateTime _maxTime;
  late StreamController<GestureEvent> _gestureStream;
  bool _ownsGestureStream = false;
  Timer? _dataCheckTimer;
  bool _lastBuildHadData = true;

  @override
  void initState() {
    super.initState();
    final data = widget.temperatureService.data[widget.dataKey];
    _minTime = widget.minTime ?? data?.first['t'] ?? DateTime.now();
    _maxTime = widget.maxTime ?? data?.last['t'] ?? DateTime.now();
      debugPrint('TemperatureChart.initState [${widget.dataKey}]: ${_minTime.toIso8601String()} -> ${_maxTime.toIso8601String()}');
    if (widget.gestureStream != null) {
      _gestureStream = widget.gestureStream!;
      _ownsGestureStream = false;
    } else {
      _gestureStream = StreamController<GestureEvent>.broadcast();
      _ownsGestureStream = true;
    }
    _gestureStream.stream.listen(_handleGesture);
    _startDataCheckTimer();
  }

  void _startDataCheckTimer() {
    // Only start timer when we're in "no data" state
    if (_lastBuildHadData) {
        debugPrint('TemperatureChart [${widget.dataKey}]: Skipping timer start - chart has data');
      return;
    }
    
    _dataCheckTimer?.cancel();
      debugPrint('TemperatureChart [${widget.dataKey}]: Starting data check timer (no data state)');
    _dataCheckTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) {
        timer.cancel();
          debugPrint('TemperatureChart [${widget.dataKey}]: Timer cancelled - widget disposed');
        return;
      }
      
      // Only check if we're still in "no data" state
      if (_lastBuildHadData) {
        timer.cancel();
          debugPrint('TemperatureChart [${widget.dataKey}]: Timer cancelled - chart now has data');
        return;
      }
      
      // Check if data became available
      final hasDataNow = _hasDataForCurrentRange();
      if (hasDataNow) {
          debugPrint('TemperatureChart [${widget.dataKey}]: Timer detected data became available - forcing rebuild');
        timer.cancel();
        if (mounted) {
          setState(() {
            // Force rebuild to show newly available data
          });
        }
      }
    });
  }

  void _stopDataCheckTimer() {
    if (_dataCheckTimer != null) {
        debugPrint('TemperatureChart [${widget.dataKey}]: Stopping data check timer');
      _dataCheckTimer?.cancel();
      _dataCheckTimer = null;
    }
  }

  bool _hasDataForCurrentRange() {
    final rawData = widget.temperatureService.data[widget.dataKey] ?? [];
    final rangeStart = _minTime.subtract(const Duration(minutes: 1));
    final rangeEnd = _maxTime.add(const Duration(minutes: 1));
    
    final filteredData = rawData.where((point) {
      final pointTime = point['t'] as DateTime;
      final inRange = pointTime.isAfter(rangeStart) && pointTime.isBefore(rangeEnd);
      return inRange;
    }).toList();
    
    return filteredData.isNotEmpty;
  }

  @override
  void dispose() {
    _dataCheckTimer?.cancel();
    if (_ownsGestureStream) {
      _gestureStream.close();
    }
    super.dispose();
  }

  void _handleGesture(GestureEvent event) {
    // Implement pan/zoom logic as in the old DataChart if needed
  }

  int _getWeekNumber(DateTime date) {
    // ISO 8601 week number calculation
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
    final weekDay = date.weekday;
    final weekNumber = ((dayOfYear - weekDay + 10) / 7).floor();
    return weekNumber == 0 ? 53 : weekNumber > 52 ? 1 : weekNumber;
  }

  Map<String, double> _getValueRange() {
    final data = widget.temperatureService.data;
    final keyData = data[widget.dataKey];
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
      final padding = (maxVal - minVal) * 0.15;
      return {
        'min': minVal - padding,
        'max': maxVal + padding,
      };
    } else {
      return {
        'min': 0.0,
        'max': 30.0,
      };
    }
  }

  @override
  void didUpdateWidget(TemperatureChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newMinTime = widget.minTime ?? _minTime;
    final newMaxTime = widget.maxTime ?? _maxTime;
    
    // Check if time range changed
    bool timeRangeChanged = newMinTime != _minTime || newMaxTime != _maxTime;
    
    // More robust data change detection
    bool dataChanged = false;
    
    // Check if the service reference changed
    if (widget.temperatureService != oldWidget.temperatureService) {
      dataChanged = true;
    }
    
    // Check if data content changed (including new data in the same count)
    final currentData = widget.temperatureService.data[widget.dataKey];
    final oldData = oldWidget.temperatureService.data[widget.dataKey];
    
    if (currentData != oldData) {
      // Check if data count changed
      if ((currentData?.length ?? 0) != (oldData?.length ?? 0)) {
        dataChanged = true;
      }
      // Check if data content changed (different timestamps even with same count)
      else if (currentData != null && oldData != null && currentData.isNotEmpty && oldData.isNotEmpty) {
        final currentFirst = currentData.first['t'] as DateTime;
        final currentLast = currentData.last['t'] as DateTime;
        final oldFirst = oldData.first['t'] as DateTime;
        final oldLast = oldData.last['t'] as DateTime;
        
        if (currentFirst != oldFirst || currentLast != oldLast) {
          dataChanged = true;
        }
      }
    }
    
    if (timeRangeChanged || dataChanged) {
      if (timeRangeChanged) {
          debugPrint('TemperatureChart.didUpdateWidget [${widget.dataKey}]: time range changed');
          debugPrint('  Old: ${_minTime.toIso8601String()} -> ${_maxTime.toIso8601String()}');
          debugPrint('  New: ${newMinTime.toIso8601String()} -> ${newMaxTime.toIso8601String()}');
      }
      if (dataChanged) {
          debugPrint('TemperatureChart.didUpdateWidget [${widget.dataKey}]: data changed');
      }
      
      setState(() {
        _minTime = newMinTime;
        _maxTime = newMaxTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
      debugPrint('TemperatureChart [${widget.dataKey}]: build() called');
    SizeConfig().init(context);
    final rawData = widget.temperatureService.data[widget.dataKey] ?? [];
    final data = rawData
        .where((point) {
          final pointTime = point['t'] as DateTime;
          return pointTime.isAfter(_minTime.subtract(const Duration(minutes: 1))) &&
                 pointTime.isBefore(_maxTime.add(const Duration(minutes: 1)));
        })
        .toList()
        ..sort((a, b) => (a['t'] as DateTime).compareTo(b['t'] as DateTime));

    // Track data state change for timer management
    final hadData = _lastBuildHadData;
    final hasData = data.isNotEmpty;
    _lastBuildHadData = hasData;
    
    // Log data state transitions
    if (hadData != hasData) {
        debugPrint('TemperatureChart [${widget.dataKey}]: Data state changed: $hadData -> $hasData');
      if (!hasData) {
        // Switched from "has data" to "no data" - start timer
        _startDataCheckTimer();
      } else {
        // Switched from "no data" to "has data" - stop timer
        _stopDataCheckTimer();
      }
    }
    
    if (data.isEmpty) {
        debugPrint('TemperatureChart [${widget.dataKey}]: SHOWING "No data" for range ${_minTime.toIso8601String()} -> ${_maxTime.toIso8601String()}');
        debugPrint('  Total raw data available: ${rawData.length}');
      if (rawData.isNotEmpty) {
          debugPrint('  Raw data spans: ${(rawData.first['t'] as DateTime).toIso8601String()} to ${(rawData.last['t'] as DateTime).toIso8601String()}');
      }
      return Center(
        child: Text(
          AppLocalizations.of(context)!.noDataForPeriod,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      );
    }
    
      debugPrint('TemperatureChart [${widget.dataKey}]: RENDERING chart with ${data.length} data points');

    final double width = SizeConfig.screenWidth;
    const labelTextStyle = TextStyle(
      color: Colors.white,
      fontSize: AppConstants.chartLabelSize,
    );

    final niceDateData = linearNiceDates(_minTime, _maxTime, width, 1, textStyle: labelTextStyle);
    final majorDateTicks = niceDateData['majorTicks'] ?? [];
    final minorDateTicks = niceDateData['minorTicks'] ?? [];
    final dateFormat = niceDateData['format'];

    final valueRange = _getValueRange();
    final chartMinValue = valueRange['min']!;
    final chartMaxValue = valueRange['max']!;

    final temperatureTicks = ChartAxisBuilder.generateTemperatureTicks(chartMinValue, chartMaxValue);
    final majorTemperatureTicks = temperatureTicks['major']!;
    final minorTemperatureTicks = temperatureTicks['minor']!;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(0, ChartConstants.titleTopSpacing, 0, 0),
          child: ChartHeader(
            title: widget.title,
            maxTime: _maxTime,
            showTimestamp: widget.dataKey == 'airTempFaehrweg',
          ),
        ),
        Flexible(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.fromLTRB(
              ChartConstants.chartLeftMargin,
              ChartConstants.chartTopMargin,
              ChartConstants.chartRightMargin,
              ChartConstants.chartBottomMargin,
            ),
            child: Stack(
              children: [
                // Background panel for better grid visibility
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: ChartConstants.backgroundAlpha),
                    borderRadius: BorderRadius.circular(ChartConstants.borderRadius),
                  ),
                ),
                Semantics(
                  label: AppLocalizations.of(context)!.temperatureChart(widget.title),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      ChartConstants.chartInsetLeft,
                      ChartConstants.chartInsetTop,
                      ChartConstants.chartInsetRight,
                      ChartConstants.chartInsetBottom,
                    ),
                    child: Chart(
                      data: data,
                      gestureStream: _gestureStream,
                      variables: {
                        'time': Variable(
                          accessor: (dynamic map) => (map['t'] ?? DateTime.now()) as DateTime,
                          scale: TimeScale(
                            min: _minTime,
                            max: _maxTime,
                            ticks: majorDateTicks,
                            formatter: (t) => dateFormat == "WEEK_NUMBER_FORMAT"
                                ? "KW ${_getWeekNumber(t.toLocal())}"
                                : intl.DateFormat(dateFormat).format(t.toLocal()),
                          ),
                        ),
                        'minorTime': Variable(
                          accessor: (dynamic map) => (map['t'] ?? DateTime.now()) as DateTime,
                          scale: TimeScale(
                            min: _minTime,
                            max: _maxTime,
                            ticks: minorDateTicks,
                            formatter: (t) => "",
                          ),
                        ),
                        'value': Variable(
                          accessor: (dynamic map) => (map['v'] ?? double.nan) as num,
                          scale: LinearScale(
                            min: chartMinValue,
                            max: chartMaxValue,
                            formatter: (v) => '${v.toStringAsFixed(1)} ${widget.unit}',
                            ticks: majorTemperatureTicks,
                          ),
                        ),
                        'minorTemp': Variable(
                          accessor: (dynamic map) => (map['v'] ?? double.nan) as num,
                          scale: LinearScale(
                            min: chartMinValue,
                            max: chartMaxValue,
                            ticks: minorTemperatureTicks,
                            formatter: (v) => "",
                          ),
                        ),
                      },
                      marks: [
                        AreaMark(
                          shape: ShapeEncode(value: BasicAreaShape(smooth: false)),
                          position: Varset('time') * Varset('value'),
                          color: ColorEncode(value: widget.color.withValues(alpha: 140/255.0)),
                        ),
                        LineMark(
                          shape: ShapeEncode(value: BasicLineShape(smooth: false)),
                          size: SizeEncode(value: 1),
                          position: Varset('time') * Varset('value'),
                          color: ColorEncode(value: widget.color),
                        ),
                      ],
                      axes: [
                        // Major X-axis (time) with labels and major grid
                        AxisGuide(
                          dim: Dim.x,
                          variable: 'time',
                          line: PaintStyle(strokeColor: Colors.white, strokeWidth: 1, dash: [1, 1]),
                          tickLine: TickLine(
                            style: PaintStyle(strokeColor: Colors.white, strokeWidth: 1),
                            length: 4,
                          ),
                          label: LabelStyle(
                            textStyle: const TextStyle(color: Colors.white, fontSize: AppConstants.chartLabelSize),
                            offset: const Offset(0, 10),
                          ),
                          grid: PaintStyle(strokeColor: Colors.white.withValues(alpha: ChartConstants.majorGridAlpha), strokeWidth: ChartConstants.majorGridWidth, dash: [1, 1]),
                        ),
                        // Minor X-axis (time) - grid only, no labels
                        AxisGuide(
                          dim: Dim.x,
                          variable: 'minorTime',
                          line: PaintStyle(strokeColor: Colors.transparent),
                          tickLine: TickLine(
                            style: PaintStyle(strokeColor: Colors.transparent),
                            length: 0,
                          ),
                          label: LabelStyle(
                            textStyle: const TextStyle(color: Colors.transparent, fontSize: 0),
                            offset: const Offset(0, 0),
                          ),
                          grid: PaintStyle(strokeColor: Colors.white.withValues(alpha: ChartConstants.minorGridAlpha), strokeWidth: ChartConstants.minorGridWidth, dash: [1, 1]),
                        ),
                        // Major Y-axis (temperature) with labels and major grid
                        AxisGuide(
                          dim: Dim.y,
                          variable: 'value',
                          line: PaintStyle(strokeColor: Colors.white, strokeWidth: 1, dash: [1, 1]),
                          tickLine: TickLine(
                            style: PaintStyle(strokeColor: Colors.white, strokeWidth: 1),
                            length: 4,
                          ),
                          label: LabelStyle(
                            textStyle: const TextStyle(color: Colors.white, fontSize: AppConstants.chartLabelSize),
                            offset: const Offset(-10, 0),
                          ),
                          grid: PaintStyle(strokeColor: Colors.white.withValues(alpha: ChartConstants.majorGridAlpha), strokeWidth: ChartConstants.majorGridWidth, dash: [1, 1]),
                        ),
                        // Minor Y-axis (temperature) - grid only, no labels
                        AxisGuide(
                          dim: Dim.y,
                          variable: 'minorTemp',
                          line: PaintStyle(strokeColor: Colors.transparent),
                          tickLine: TickLine(
                            style: PaintStyle(strokeColor: Colors.transparent),
                            length: 0,
                          ),
                          label: LabelStyle(
                            textStyle: const TextStyle(color: Colors.transparent, fontSize: 0),
                            offset: const Offset(0, 0),
                          ),
                          grid: PaintStyle(strokeColor: Colors.white.withValues(alpha: ChartConstants.minorGridAlpha), strokeWidth: ChartConstants.minorGridWidth, dash: [1, 1]),
                        ),
                      ],
                    ),
                  ),
                ),
                if (widget.isLoading)
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
          ),
        )
      ],
    );
  }
}
