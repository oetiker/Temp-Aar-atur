import 'dart:math';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'temperature_store.dart';
import 'size_config.dart';
// https://pub.dev/documentation/charts_common/latest/common/common-library.html
class TemperatureChart extends StatelessWidget {
  TemperatureChart();

  /// Create random data.

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final int fontSize = (min(SizeConfig.screenWidth,SizeConfig.screenHeight)/40).round();
    return Container(
      child: Column(
        children: [
          Flexible(
            flex: 1,
            child: _timeSeriesChart(_airSeriesList(), 'Luft',fontSize),
          ),
          Flexible(
            flex: 1,
            child: _timeSeriesChart(_waterSeriesList(), 'Aare',fontSize),
          )
        ],
      ),
    );
  }

  Widget _timeSeriesChart(list, title, fontSize) {
    final labelStyle = charts.TextStyleSpec(
      fontSize: fontSize, // size in Pts.
      color: charts.MaterialPalette.white,
    );
    final lineStyle = charts.LineStyleSpec(
      color: charts.ColorUtil.fromDartColor(Color.fromRGBO(255, 255, 255, 0.4)),
    );

    return charts.TimeSeriesChart(
      list,
      animate: false,
      behaviors: [
        //charts.SeriesLegend(entryTextStyle: labelStyle),
        charts.ChartTitle(
          title,
          titleStyleSpec: charts.TextStyleSpec(
            fontSize: (fontSize*1.3).round(),
            color: charts.MaterialPalette.white,
          ),
        ),
        charts.LinePointHighlighter(
          selectionModelType: charts.SelectionModelType.info,
          defaultRadiusPx: 0,
          radiusPaddingPx: 0,
          drawFollowLinesAcrossChart: true,
          showHorizontalFollowLine:
              charts.LinePointHighlighterFollowLineType.nearest,
          showVerticalFollowLine: charts.LinePointHighlighterFollowLineType.nearest,
        ),
      ],
      dateTimeFactory: const charts.LocalDateTimeFactory(),
      domainAxis: charts.DateTimeAxisSpec(
        renderSpec: charts.GridlineRendererSpec(
          labelOffsetFromAxisPx: 8,
          labelStyle: labelStyle,
          lineStyle: lineStyle,
        ),
        tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(
          day: charts.TimeFormatterSpec(
            format: 'd.M',
            transitionFormat: 'd.M',
          ),
        ),
        tickProviderSpec: charts.DayTickProviderSpec(
          increments: [1],
        ),
      ),
      primaryMeasureAxis: charts.NumericAxisSpec(
        renderSpec: charts.GridlineRendererSpec(
          // Tick and Label styling here.
          labelStyle: labelStyle,
          // Change the line colors to match text color.
          lineStyle: lineStyle,
        ),
        tickProviderSpec: charts.BasicNumericTickProviderSpec(
          //dataIsInWholeNumbers: true,
          desiredMinTickCount: 8,
          desiredMaxTickCount: 12,
          desiredTickCount: 12,
          zeroBound: false,
        ),
      ),
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<TemperatureReading, DateTime>> _waterSeriesList() {
    return [
      new charts.Series<TemperatureReading, DateTime>(
        id: 'Water',
        strokeWidthPxFn: (_, __) => 3,
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TemperatureReading reading, _) => reading.time,
        measureFn: (TemperatureReading reading, _) => reading.celsius1,
        data: TemperatureStore().data,
        domainLowerBoundFn: (_, __) => TemperatureStore().data.first.time,
        domainUpperBoundFn: (_, __) => TemperatureStore().data.last.time,
      ),
    ];
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<TemperatureReading, DateTime>> _airSeriesList() {
    return [
      new charts.Series<TemperatureReading, DateTime>(
        id: 'Air',
        strokeWidthPxFn: (_, __) => 3,
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        domainFn: (TemperatureReading reading, _) => reading.time,
        measureFn: (TemperatureReading reading, _) => reading.celsius2,
        data: TemperatureStore().data,
        domainLowerBoundFn: (_, __) => TemperatureStore().data.first.time,
        domainUpperBoundFn: (_, __) => TemperatureStore().data.last.time,
      )
    ];
  }
}
