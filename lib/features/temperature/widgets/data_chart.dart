import 'dart:async';
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import '../services/temperature_service.dart';
import '../services/temperature_repository_impl.dart';
import '../../../l10n/app_localizations.dart';
import 'temperature_chart.dart';
import 'chart_gesture_handler.dart';
import '../services/chart_data_manager.dart';

class DataChart extends StatefulWidget {
  final TemperatureService? temperatureService;

  const DataChart({super.key, this.temperatureService});

  @override
  State<DataChart> createState() => _DataChartState();
}

class _DataChartState extends State<DataChart> {
  late TemperatureService _tempService;
  bool _loading = true;
  bool _dataLoadInProgress = false;
  late DateTime _minTime;
  late DateTime _maxTime;
  final Duration _window = const Duration(days: 7);
  late ChartGestureHandler _gestureHandler;
  late ChartDataManager _chartDataManager;
  final _gestureStream = StreamController<GestureEvent>.broadcast();
  Timer? _debounceTimer;
  DateTime? _pendingMinTime;
  DateTime? _pendingMaxTime;

  @override
  void initState() {
    super.initState();
    _tempService = widget.temperatureService ?? TemperatureService();
    _chartDataManager = ChartDataManager(_tempService);
    final now = DateTime.now();
    _maxTime = now;
    _minTime = now.subtract(_window);
    _gestureHandler = ChartGestureHandler(
      chartDataManager: _chartDataManager,
      onTimeRangeChanged: _onTimeRangeChanged,
      onLoadingChanged: (bool _) {},
    );
    _gestureStream.stream.listen(_handleGesture);
    
    // Set up callback to receive notifications when data chunks arrive
    TemperatureRepositoryImpl.setDataUpdatedCallback(_onDataChunkReceived);
    
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
    });
    await _tempService.load(_minTime, _maxTime);
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  void _onTimeRangeChanged(DateTime newMin, DateTime newMax) {
    // Check if the time range is essentially the same (within 1 second tolerance)
    if (_timeRangesEqual(newMin, newMax, _minTime, _maxTime)) {
        debugPrint('DataChart: Ignoring duplicate time range change');
      return;
    }

      debugPrint('DataChart._onTimeRangeChanged: ${newMin.toIso8601String()} -> ${newMax.toIso8601String()}');
    
    // Update UI immediately for responsive visual feedback
    setState(() {
      _minTime = newMin;
      _maxTime = newMax;
    });
    
    // Store pending time range for data loading
    _pendingMinTime = newMin;
    _pendingMaxTime = newMax;
    
    // Cancel previous debounce timer
    _debounceTimer?.cancel();
    
    // Use shorter debounce for better responsiveness during panning
    final timeSpan = newMax.difference(newMin);
    final debounceDelay = timeSpan.inDays > 180 ? 400 : 150; // 400ms for >6 months, 150ms otherwise
    
      debugPrint('DataChart: Using ${debounceDelay}ms debounce for ${timeSpan.inDays} day span');
    
    // Set debounce timer for data loading only
    _debounceTimer = Timer(Duration(milliseconds: debounceDelay), () {
      _loadDataForTimeRange(_pendingMinTime!, _pendingMaxTime!);
    });
  }

  bool _timeRangesEqual(DateTime newMin, DateTime newMax, DateTime currentMin, DateTime currentMax) {
    const tolerance = Duration(seconds: 1);
    return (newMin.difference(currentMin).abs() < tolerance) &&
           (newMax.difference(currentMax).abs() < tolerance);
  }

  Future<void> _loadDataForTimeRange(DateTime newMin, DateTime newMax) async {
    if (!mounted) return;
    
    // Prevent overlapping data loads
    if (_dataLoadInProgress) {
        debugPrint('DataChart: Data load already in progress, skipping');
      return;
    }

      debugPrint('DataChart: Loading data for debounced time range change');
    _dataLoadInProgress = true;
    
    try {
        debugPrint('DataChart: calling temperatureService.load()');
      await _tempService.load(newMin, newMax);
      
      if (mounted) {
          debugPrint('DataChart: Data loading completed, triggering chart update');
        // Trigger a rebuild to display the new data
        setState(() {
          // Data has been loaded, charts need to redraw
        });
      }
    } finally {
      _dataLoadInProgress = false;
    }
  }


  void _handleGesture(GestureEvent event) {
    final screenSize = MediaQuery.of(context).size;
    _gestureHandler.handleGesture(event, _minTime, _maxTime, screenSize);
  }

  void _onDataChunkReceived() {
    if (mounted) {
        debugPrint('DataChart: Received data chunk notification - triggering chart update');
      setState(() {
        // Trigger chart rebuild when individual data chunks arrive
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _gestureStream.close();
    // Clear the callback when widget is disposed
    TemperatureRepositoryImpl.clearDataUpdatedCallback();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        Flexible(
          flex: 1,
          child: TemperatureChart(
            dataKey: 'airTempFaehrweg',
            title: AppLocalizations.of(context)!.airTemperature.split(' ').first,
            unit: '°C',
            color: const Color.fromARGB(255, 49, 125, 238),
            temperatureService: _tempService,
            minTime: _minTime,
            maxTime: _maxTime,
            gestureStream: _gestureStream,
          ),
        ),
        Flexible(
          flex: 1,
          child: TemperatureChart(
            dataKey: 'waterTempFaehrweg',
            title: AppLocalizations.of(context)!.waterTemperature.split(' ').first,
            unit: '°C',
            color: Colors.greenAccent,
            temperatureService: _tempService,
            minTime: _minTime,
            maxTime: _maxTime,
            gestureStream: _gestureStream,
          ),
        ),
      ],
    );
  }
}
