import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import '../../../core/constants/constants.dart';

class ChartAxisBuilder {
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

  static List<AxisGuide> buildAxes(List<double> minorDateTicks, List<double> minorTemperatureTicks) {
    return [
      // Horizontal axis (time) with major ticks and grid
      AxisGuide(
        dim: Dim.x,
        line: _commonLineStyle,
        tickLine: _commonTickLineStyle,
        label: _commonLabelStyle,
        grid: PaintStyle(strokeColor: Colors.white.withValues(alpha: 0.3), strokeWidth: 0.6, dash: [1, 1]),
      ),
      // Minor horizontal grid only
      AxisGuide(
        variable: 'minorTime',
        dim: Dim.x,
        line: PaintStyle(strokeColor: Colors.transparent),
        tickLine: TickLine(
          style: PaintStyle(strokeColor: Colors.transparent),
          length: 0,
        ),
        label: LabelStyle(
          textStyle: const TextStyle(color: Colors.transparent, fontSize: 0),
        ),
        grid: PaintStyle(strokeColor: Colors.white.withValues(alpha: 0.3), strokeWidth: 0.5, dash: [1, 1]),
      ),
      // Main vertical axis (temperature) with labels and major grid
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
        grid: PaintStyle(strokeColor: Colors.white.withValues(alpha: 0.5), strokeWidth: 1.0, dash: [1, 1]),
      ),
      // Minor temperature grid only
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
        grid: PaintStyle(strokeColor: Colors.white.withValues(alpha: 0.3), strokeWidth: 0.5, dash: [1, 1]),
      ),
    ];
  }

  static Map<String, List<double>> generateTemperatureTicks(double min, double max) {
    final span = max - min;
    final List<double> majorTicks = [];
    final List<double> minorTicks = [];

    double majorInterval;
    if (span <= 2) {
      majorInterval = 0.5;
    } else if (span <= 10) {
      majorInterval = 1.0;
    } else if (span <= 20) {
      majorInterval = 2.0;
    } else {
      majorInterval = 5.0;
    }

    double minorInterval;
    if (majorInterval == 0.5) {
      minorInterval = 0.1;
    } else if (majorInterval <= 2.0) {
      minorInterval = majorInterval / 5;
    } else {
      minorInterval = majorInterval / 5;
    }

    final startMajor = (min / majorInterval).floor() * majorInterval;
    final endMajor = (max / majorInterval).ceil() * majorInterval;

    for (double major = startMajor; major <= endMajor + majorInterval; major += majorInterval) {
      if (major >= min - majorInterval && major <= max + majorInterval) {
        majorTicks.add(major);
      }
    }

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
}