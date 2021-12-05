import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart' as intl;
import 'temperature_store.dart';
import 'temperature_chart.dart';
import 'size_config.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

void main() {
  runApp(MaterialApp(
    home: const TemperAare(),
    title: 'TemperAare - Olten',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
  ));
}

_launchURL(String href) async {
  if (await canLaunch(href)) {
    await launch(href);
  } else {
    throw 'Could not launch $href';
  }
}

class TemperAare extends StatefulWidget {
  const TemperAare({Key? key}) : super(key: key);

  @override
  TemperAareState createState() => TemperAareState();
}

class TemperAareState extends State<TemperAare> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        setState(() {});
        break;
      default:
        break;
    }
  }

  final pageIndexNotifier = ValueNotifier<int>(0);
  final tenMinutes = const Duration(seconds: 700);
  static const length = 3;

  int _cIndex = 0;

  void reloader() {
    Timer(tenMinutes, () {
      // setState will call the build method again
      // and thus trigger a data refresh
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _children = [_tempCards(), _tempChart(), _info()];
    reloader();
    const Color barColor = Color.fromRGBO(31, 123, 129, 0.7);

    void _incrementTab(int index) {
      _cIndex = index;
      setState(() {});
    }

    return Stack(
      children: [
        Container(
          height: double.infinity,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Aare-Temperatur in Olten'),
            backgroundColor: barColor,
            elevation: 0.0,
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: barColor,
            selectedItemColor: const Color.fromRGBO(255, 255, 255, 1),
            unselectedItemColor: const Color.fromRGBO(255, 255, 255, 0.5),
            elevation: 0.0,
            currentIndex: _cIndex,
            onTap: _incrementTab,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.wb_sunny,
                ),
                label: 'Jetzt',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.date_range,
                ),
                label: 'Vergangenheit',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.info,
                ),
                label: 'Info',
              ),
            ],
          ),
          body: _children[_cIndex],
        ),
      ],
    );
  }

  Widget _tempChart() {
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
              child: TemperatureChart(),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _info() {
    String _markdownData = """# Über TemperAare

Die Temperatur der Aare in Olten ist natürlich nicht massiv anders als in Solothurn oder Aarau, aber trotzdem habe ich mich immer daran gestört, dass der Bund in Olten keine [Hydrodaten-Messtation](https://www.hydrodaten.admin.ch/) an der Aare betreibt, sondern nur an der Dünnern.

Ich habe daher eine eigene kleine Temperaturmessstation mit zwei Temperatursensoren gebaut und sie am Ufer der Aare deponiert. Der eine Sensor misst die Umgebungstemparatur, der andere liegt ca. 40 cm unter der Wasseroberfläche.

Das Messgerät arbeitet mit einer 3000 mAh-Li-Ion-Batterie. Dank ausgeklügelter Programmierung kann es während vieler Wochen alle paar Minuten die Temperaturen messen und die Resultate via LoRaWAN an den Server senden. Die [App](https://github.com/oetiker/Temp-Aar-atur) bezieht ihre Daten direkt vom Server und bereitet sie lokal für die Darstellung auf.

Viel Spass beim Aareschwimmen!

[Tobias Oetiker](mailto:tobi@oetiker.ch?subject=TemperAare)

""";
    TextTheme textTheme =
        Typography.material2018(platform: TargetPlatform.android).black.merge(
              const TextTheme(
                bodyText2: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                  height: 1.2,
                ),
                bodyText1: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                ),
                headline5: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                headline6: TextStyle(
                  fontSize: 18.0,
                  color: Colors.white,
                ),
                subtitle1: TextStyle(
                  fontSize: 18.0,
                  color: Colors.white,
                ),
              ),
            );
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: ClipRect(
        clipBehavior: Clip.antiAlias,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 2,
            sigmaY: 2,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 10,
            ),
            color: const Color.fromRGBO(0, 0, 0, 0.4),
            child: Scrollbar(
              child: Markdown(
                  data: _markdownData,
                  onTapLink: (text, url, title) {
                    _launchURL(url!);
                  },
                  styleSheet: MarkdownStyleSheet.fromTheme(
                      ThemeData.dark().copyWith(textTheme: textTheme))),
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
        // print("temp card");
        SizeConfig().init(context);
        if (reading.hasData) {
          TemperatureReading data = TemperatureStore().data.last;

          final baseSize = min(SizeConfig.screenWidth, SizeConfig.screenHeight);
          final isHorizontal = SizeConfig.screenHeight < SizeConfig.screenWidth;

          return Stack(children: [
            Positioned(
              top: 30,
              right: 30,
              child: blurCircle(
                width: baseSize / 2.3,
                text: data.celsius2.toStringAsFixed(1) + ' °C',
                subtitle: 'Luft',
                backgroundColor: const Color.fromRGBO(119, 170, 252, 0.5),
              ),
            ),
            Positioned(
                bottom: isHorizontal ? 10 : 60,
                left: 30,
                child: blurCircle(
                  width: baseSize * 0.8 - 80,
                  text: data.celsius1.toStringAsFixed(1) + ' °C',
                  subtitle: 'Aare',
                  backgroundColor: const Color.fromRGBO(31, 123, 129, 0.5),
                )),
            Positioned(
              bottom: isHorizontal ? 10 : 10,
              right: 30,
              child: blurRect(
                  text: intl.DateFormat("d.M.yyyy H:mm")
                          .format(data.time.toLocal()) +
                      ' / ' +
                      data.volt.toStringAsFixed(2) +
                      'V',
                  width: baseSize * 0.4,
                  backgroundColor: const Color.fromRGBO(0, 0, 0, 0.3)),
            ),
          ]);
        } else if (reading.hasError) {
          // showDialog(
          //     context: context,
          //     builder: (BuildContext context) {
          //       // return object of type Dialog
          //       return AlertDialog(
          //         title: new Text("Server access problem"),
          //         content: new Text("${reading.error}"),
          //         actions: <Widget>[
          //           // usually buttons at the bottom of the dialog
          //           new FlatButton(
          //             child: new Text("Retry"),
          //             onPressed: () {
          //               //TemperatureStore().updateStore();
          //               //setState((){});
          //             },
          //           ),
          //         ],
          //       );
          //     });
          return Center(
            child: Text("${reading.error}"),
          );
        }
        return const Center(
          child: CircularProgressIndicator(
            backgroundColor: Colors.transparent,
          ),
        );
      },
    );
  }

  static Widget blurCircle({
    required String text,
    required String subtitle,
    Color? backgroundColor,
    required double width,
  }) {
    return SizedBox(
      width: width,
      height: width,
      child: ClipOval(
        clipBehavior: Clip.antiAlias,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 1.5,
            sigmaY: 1.5,
          ),
          child: Container(
            color: backgroundColor,
            padding: EdgeInsets.all(width / 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FractionallySizedBox(
                  widthFactor: 1,
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Text(text,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontFeatures: [FontFeature.proportionalFigures()],
                          color: Colors.white,
                        )),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 25,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget blurRect({
    required String text,
    Color? backgroundColor,
    required double width,
  }) {
    return SizedBox(
      width: width,
      child: ClipRect(
        clipBehavior: Clip.antiAlias,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 1.5,
            sigmaY: 1.5,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: width / 22,
              horizontal: width / 12,
            ),
            color: backgroundColor,
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(
                text,
                style: const TextStyle(
                  // fontWeight: FontWeight.bold,
                  fontFeatures: [
                    FontFeature.proportionalFigures(),
                    // FontFeature.oldstyleFigures(),
                  ],
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// reading.data.volt.toStringAsFixed(2) + ' V'
