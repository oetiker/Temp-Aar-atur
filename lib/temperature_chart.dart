import 'dart:math';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'temperature_store.dart';
import 'size_config.dart';

// https://pub.dev/documentation/charts_common/latest/common/common-library.html

// https://github.com/google/charts/issues/287#issuecomment-521999694
class DateTimeAxisSpecWorkaround extends charts.DateTimeAxisSpec {
  const DateTimeAxisSpecWorkaround({
    charts.RenderSpec<DateTime>? renderSpec,
    charts.DateTimeTickProviderSpec? tickProviderSpec,
    charts.DateTimeTickFormatterSpec? tickFormatterSpec,
    bool? showAxisLine, viewport
  }) : super(
            renderSpec: renderSpec,
            tickProviderSpec: tickProviderSpec,
            tickFormatterSpec: tickFormatterSpec,
            showAxisLine: showAxisLine, viewport: viewport);

  @override
  configure(charts.Axis<DateTime> axis, charts.ChartContext context,
      charts.GraphicsFactory graphicsFactory) {
    super.configure(axis, context, graphicsFactory);
    axis.autoViewport = false;
  }
}

class TemperatureChart extends StatelessWidget {
  const TemperatureChart({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final int fontSize =
        (min(SizeConfig.screenWidth, SizeConfig.screenHeight) / 40).round();
    return Column(
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
    );
  }

  Widget _timeSeriesChart(list, title, fontSize) {
    final labelStyle = charts.TextStyleSpec(
      fontSize: fontSize, // size in Pts.
      color: charts.MaterialPalette.white,
    );
    final lineStyle = charts.LineStyleSpec(
      color: charts.ColorUtil.fromDartColor(const Color.fromRGBO(255, 255, 255, 0.4)),
    );

    var chart = charts.TimeSeriesChart(
      list,
      animate: false,
      defaultRenderer: charts.LineRendererConfig(
        includeArea: true,
        stacked: false,
        areaOpacity: 0.6,
        includePoints: false,
        includeLine: true,
        strokeWidthPx: 1,
      ),
      behaviors: [
        // charts.SeriesLegend(entryTextStyle: labelStyle),
        charts.ChartTitle(
          title,
          titleStyleSpec: charts.TextStyleSpec(
            fontSize: (fontSize * 1.5).round(),
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
        charts.PanAndZoomBehavior(),
      ],
      dateTimeFactory: const charts.LocalDateTimeFactory(),
      domainAxis: DateTimeAxisSpecWorkaround(
        renderSpec: charts.GridlineRendererSpec(
          labelOffsetFromAxisPx: 8,
          labelStyle: labelStyle,
          lineStyle: lineStyle,
        ),
        tickFormatterSpec: const charts.AutoDateTimeTickFormatterSpec(
          day: charts.TimeFormatterSpec(
            format: 'd.M',
            transitionFormat: 'd.M',
          ),
          hour: charts.TimeFormatterSpec(
            format: 'HH:mm',
            transitionFormat: 'd.M HH:mm',
          ),
          minute: charts.TimeFormatterSpec(
            format: 'HH:mm:ss',
            transitionFormat: 'd.M HH:mm:ss',
          ),
        ),
        tickProviderSpec:
            const charts.AutoDateTimeTickProviderSpec(includeTime: true),
      ),
      primaryMeasureAxis: charts.NumericAxisSpec(
        showAxisLine: true,
        renderSpec: charts.GridlineRendererSpec(
          // Tick and Label styling here.
          labelStyle: labelStyle,
          // Change the line colors to match text color.
          lineStyle: lineStyle,
        ),
        tickProviderSpec: const charts.BasicNumericTickProviderSpec(
          dataIsInWholeNumbers: true,
          desiredMinTickCount: 8,
          desiredMaxTickCount: 12,
          desiredTickCount: 12,
          zeroBound: false,
        ),
      ),
    );
    return chart;
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<dynamic, DateTime>> _waterSeriesList() {
    return [
      charts.Series<TemperatureReading, DateTime>(
        id: 'Water',
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        domainFn: (TemperatureReading reading, _) => reading.time,
        measureFn: (TemperatureReading reading, _) => reading.celsius1,
        data: TemperatureStore().data,
        domainLowerBoundFn: (_, __) => DateTime.now().subtract(const Duration(days: 7)),
        domainUpperBoundFn: (_, __) => DateTime.now(),
      ),
    ];
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<dynamic, DateTime>> _airSeriesList() {
    return [
      charts.Series<TemperatureReading, DateTime>(
        id: 'Air',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TemperatureReading reading, _) => reading.time,
        measureFn: (TemperatureReading reading, _) => reading.celsius2,
        data: TemperatureStore().data,
       domainLowerBoundFn: (_, __) => DateTime.now().subtract(const Duration(days: 7)),
        domainUpperBoundFn: (_, __) => DateTime.now(),
      )
    ];
  }
}

