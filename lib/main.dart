
import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart' as intl;
import 'package:page_view_indicator/page_view_indicator.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:text_to_path_maker/text_to_path_maker.dart';
import 'temperature_store.dart';




void main() {
  runApp(new MaterialApp(
    home: new TemperAare(),
    title: 'TemperAare - Olten',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
  ));
}

class TemperAare extends StatefulWidget {
  @override
  TemperAareState createState() => new TemperAareState();
}

class TemperAareState extends State<TemperAare> {
  final pageIndexNotifier = ValueNotifier<int>(0);
  final tenMinutes = const Duration(seconds: 800);
  static const length = 3;

  @override
  Widget build(BuildContext context) {
    Timer(tenMinutes, () {
      // setState will call the build method again and thus trigger a data
      // refresh
      setState(() {});
    });
    const Color barColor = Color.fromRGBO(31, 123, 129, 0.7);

    return Stack(
      children: [
        Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text('Aare Temperature in Olten'),
            backgroundColor: barColor,
            elevation: 0.0,
          ),
          body: SafeArea(
            top: false,
            // height: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                //Text('Hello'),
                Flexible(
                  flex: 1,
                  child: PageView(
                    onPageChanged: (index) => pageIndexNotifier.value = index,
                    children: [
                      _tempCards(),
                      _tempList(),
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                        child: ClipRect(
                          clipBehavior: Clip.antiAlias,
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                            child: Card(

                              margin: EdgeInsets.all(0),
                              color: Color.fromRGBO(255, 255, 255, 0.6),
                              child: Column(

                                children: [
                                  Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 3)),
                                  Flexible(
                                    flex: 1,
                                    child: DateTimeComboLinePointChart(
                                    DateTimeComboLinePointChart
                                        ._createSampleData(),
                                    animate: true,
                                  ),
                                  ),
                                  Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 3)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                _pageViewIndicator(3),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _tempList() {
    final items = List<String>.generate(1000, (i) => "Item $i");
    return Container(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: ClipRect(
        clipBehavior: Clip.antiAlias,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Card(
            margin: EdgeInsets.all(0),
            color: Color.fromRGBO(255, 255, 255, 0.6),
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Text('Hello'),
                      Text('Du'),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _tempCards() {
    Future<bool> storeReady = TemperatureStore().updateStore();
    return FutureBuilder<bool>(
      future: storeReady,
      builder: (context, reading) {
        if (reading.hasData) {
          TemperatureReading data = TemperatureStore().data.last;
          return Column(children: [
            blurCard(
              icon: Icons.wb_sunny,
              title: 'Air temperature next to the river',
              subtitle: data.celsius2.toStringAsFixed(1) + ' °C',
              marginTop: 10,
            ),
            Spacer(flex: 1),
            blurCard(
              icon: Icons.opacity,
              title: 'Water temperature at -40cm',
              subtitle: data.celsius1.toStringAsFixed(1) + ' °C',
              marginBottom: 0,
              footer: intl.DateFormat("d.M.yyyy H:mm")
                  .format(data.time.toLocal()),
            ),
          ]);
        } else if (reading.hasError) {
          return Center(
            child: Card(
              child: Text("${reading.error}"),
            ),
          );
        }
        return Center(
          child: CircularProgressIndicator(
            backgroundColor: Colors.transparent,
          ),
        );
      },
    );
  }

  Widget blurCard(
      {String title,
      String subtitle,
      IconData icon,
      double marginTop: 0,
      double marginBottom: 0,
      String footer}) {
    const double iconSize = 50;
    const double titleScale = 0.8;
    const double subtitleScale = 2.5;
    const Color iconColor = Colors.black54;
    const Color cardColor = Color.fromRGBO(255, 255, 255, 0.5);
    return Container(
      padding: EdgeInsets.fromLTRB(10, marginTop, 10, marginBottom),
      child: ClipRect(
        clipBehavior: Clip.antiAlias,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Card(
            margin: EdgeInsets.all(0),
            color: cardColor,
            child: Column(
              children: [
                Padding(padding: EdgeInsets.symmetric(vertical: 3)),
                ListTile(
                  leading: Icon(icon, size: iconSize, color: iconColor),
                  title: Text(
                    title,
                    textScaleFactor: titleScale,
                  ),
                  subtitle: Text(
                    subtitle,
                    textScaleFactor: subtitleScale,
                  ),
                ),
                if (footer != null)
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Text(footer),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 8)),
                  ]),
                Padding(padding: EdgeInsets.symmetric(vertical: 3)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PageViewIndicator _pageViewIndicator(length) {
    return PageViewIndicator(
      pageIndexNotifier: pageIndexNotifier,
      length: length,
      normalBuilder: (animationController, index) => ScaleTransition(
            scale: CurvedAnimation(
              parent: animationController,
              curve: Curves.ease,
            ),
            child: Circle(size: 6, color: Colors.white54),
          ),
      highlightedBuilder: (animationController, index) => ScaleTransition(
            scale: CurvedAnimation(
              parent: animationController,
              curve: Curves.ease,
            ),
            child: Circle(size: 6, color: Colors.white),
          ),
    );
  }
}
// reading.data.volt.toStringAsFixed(2) + ' V'

class DateTimeComboLinePointChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  DateTimeComboLinePointChart(this.seriesList, {this.animate});

  /// Creates a [TimeSeriesChart] with sample data and no transition.
  factory DateTimeComboLinePointChart.withSampleData() {
    return new DateTimeComboLinePointChart(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new charts.TimeSeriesChart(
      seriesList,

      animate: animate,
      // Configure the default renderer as a line renderer. This will be used
      // for any series that does not define a rendererIdKey.
      //
      // This is the default configuration, but is shown here for  illustration.
      defaultRenderer: new charts.LineRendererConfig(),
      // Custom renderer configuration for the point series.
      customSeriesRenderers: [
        new charts.PointRendererConfig(
            // ID used to link series to this renderer.
            customRendererId: 'customPoint')
      ],
      // Optionally pass in a [DateTimeFactory] used by the chart. The factory
      // should create the same type of [DateTime] as the data provided. If none
      // specified, the default creates local date time.
      dateTimeFactory: const charts.LocalDateTimeFactory(),
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<TimeSeriesSales, DateTime>> _createSampleData() {
    final desktopSalesData = [
      new TimeSeriesSales(new DateTime(2017, 9, 19), 5),
      new TimeSeriesSales(new DateTime(2017, 9, 26), 25),
      new TimeSeriesSales(new DateTime(2017, 10, 3), 100),
      new TimeSeriesSales(new DateTime(2017, 10, 10), 75),
    ];

    final tableSalesData = [
      new TimeSeriesSales(new DateTime(2017, 9, 19), 10),
      new TimeSeriesSales(new DateTime(2017, 9, 26), 50),
      new TimeSeriesSales(new DateTime(2017, 10, 3), 200),
      new TimeSeriesSales(new DateTime(2017, 10, 10), 150),
    ];

    final mobileSalesData = [
      new TimeSeriesSales(new DateTime(2017, 9, 19), 10),
      new TimeSeriesSales(new DateTime(2017, 9, 26), 50),
      new TimeSeriesSales(new DateTime(2017, 10, 3), 200),
      new TimeSeriesSales(new DateTime(2017, 10, 10), 150),
    ];

    return [
      new charts.Series<TimeSeriesSales, DateTime>(
        id: 'Desktop',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeriesSales sales, _) => sales.time,
        measureFn: (TimeSeriesSales sales, _) => sales.sales,
        data: desktopSalesData,
      ),
      new charts.Series<TimeSeriesSales, DateTime>(
        id: 'Tablet',
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        domainFn: (TimeSeriesSales sales, _) => sales.time,
        measureFn: (TimeSeriesSales sales, _) => sales.sales,
        data: tableSalesData,
      ),
      new charts.Series<TimeSeriesSales, DateTime>(
          id: 'Mobile',
          colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
          domainFn: (TimeSeriesSales sales, _) => sales.time,
          measureFn: (TimeSeriesSales sales, _) => sales.sales,
          data: mobileSalesData)
        // Configure our custom point renderer for this series.
        ..setAttribute(charts.rendererIdKey, 'customPoint'),
    ];
  }
}

/// Sample time series data type.
class TimeSeriesSales {
  final DateTime time;
  final int sales;

  TimeSeriesSales(this.time, this.sales);
}
