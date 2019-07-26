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
    final int fontSize =
        (min(SizeConfig.screenWidth, SizeConfig.screenHeight) / 40).round();
    return Container(
      child: Column(
        children: [
          Flexible(
            flex: 1,
            child: _timeSeriesChart(_airSeriesList(), 'Luft', fontSize),
          ),
          Flexible(
            flex: 1,
            child: _timeSeriesChart(_waterSeriesList(), 'Aare', fontSize),
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
      animate: true,
      defaultRenderer: charts.LineRendererConfig(
         includeArea: true,
         stacked: true,
      ),
      behaviors: [
        // charts.SeriesLegend(entryTextStyle: labelStyle),
        charts.ChartTitle(
          title,
          titleStyleSpec: charts.TextStyleSpec(
            fontSize: (fontSize * 1.3).round(),
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
          showVerticalFollowLine:
              charts.LinePointHighlighterFollowLineType.nearest,
        ),
        //charts.PanAndZoomBehavior(
          // https://github.com/google/charts/issues/271
          // panningCompletedCallback: () {},
        //),
      ],
      dateTimeFactory: const charts.LocalDateTimeFactory(),
      domainAxis: charts.DateTimeAxisSpec(
        // viewport: charts.DateTimeExtents(
        //     start: list[0].data.first.time, end: list[0].data.last.time),
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
          hour: charts.TimeFormatterSpec(
            format: 'h:mm',
            transitionFormat: 'h:mm',
          ),
          minute: charts.TimeFormatterSpec(
            format: 'h:mm:ss',
            transitionFormat: 'h:mm:ss',
          ),
        ),
        tickProviderSpec: charts.DayTickProviderSpec(
          increments: [1],
        ),
      ),
      primaryMeasureAxis: charts.NumericAxisSpec(
        showAxisLine: true,
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
