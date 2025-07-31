import 'package:flutter/material.dart';
import '../services/temperature_service.dart';
import 'data_chart.dart';

/// Wrapper widget for the temperature chart with blur background
class ChartWrapperWidget extends StatelessWidget {
  final TemperatureService temperatureService;
  const ChartWrapperWidget({super.key, required this.temperatureService});

  @override
  Widget build(BuildContext context) {
    return DataChart(temperatureService: temperatureService);
  }
}
