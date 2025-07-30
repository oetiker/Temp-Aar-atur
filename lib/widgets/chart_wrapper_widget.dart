import 'dart:ui';
import 'package:flutter/material.dart';
import '../data_chart.dart';

/// Wrapper widget for the temperature chart with blur background
class ChartWrapperWidget extends StatelessWidget {
  const ChartWrapperWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: ClipRect(
        clipBehavior: Clip.antiAlias,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Container(
            margin: const EdgeInsets.all(0),
            color: const Color.fromRGBO(0, 0, 0, 0.4),
            child: const Padding(
              padding: EdgeInsets.all(5),
              child: DataChart(),
            ),
          ),
        ),
      ),
    );
  }
}