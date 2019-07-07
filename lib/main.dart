import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart' as intl;
import 'package:page_view_indicator/page_view_indicator.dart';
import 'temperature_store.dart';
import 'temperature_chart.dart';
import 'size_config.dart';

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
            title: Text('Aare-Termperatur in Olten'),
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
                      _tempChart(),
                    ],
                  ),
                ),
                _pageViewIndicator(2),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _tempChart() {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: ClipRect(
        clipBehavior: Clip.antiAlias,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Card(
            margin: EdgeInsets.all(0),
            color: Color.fromRGBO(0, 0, 0, 0.2),
            child: Padding(
              padding: EdgeInsets.all(5),
              child: TemperatureChart(),
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
                backgroundColor: Color.fromRGBO(119, 170, 252, 0.5),
              ),
            ),
            Positioned(
                bottom: isHorizontal ? 0 : 60,
                left: 30,
                child: blurCircle(
                  width: baseSize * 0.8 - 60,
                  text: data.celsius1.toStringAsFixed(1) + ' °C',
                  subtitle: 'Aare (-40cm)',
                  backgroundColor: Color.fromRGBO(31, 123, 129, 0.5),
                )),
            Positioned(
              bottom: isHorizontal ? 0 : 0,
              right: 30,
              child: blurRect(
                  text: intl.DateFormat("d.M.yyyy H:mm")
                      .format(data.time.toLocal()),
                  width: baseSize * 0.3,
                  backgroundColor: Color.fromRGBO(0, 0, 0, 0.3)),
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
        return Center(
          child: CircularProgressIndicator(
            backgroundColor: Colors.transparent,
          ),
        );
      },
    );
  }

  Widget blurCircle({
    String text,
    String subtitle,
    Color backgroundColor,
    double width,
  }) {
    return Container(
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )),
                ),
                ),
                Text(
                      subtitle,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 20,
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

  Widget blurRect({
    String text,
    Color backgroundColor,
    double width,
  }) {
    return Container(
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
                style: TextStyle(
                  //fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  PageViewIndicator _pageViewIndicator(length) {
    return PageViewIndicator(
      pageIndexNotifier: pageIndexNotifier,
      indicatorPadding: EdgeInsets.fromLTRB(5, 10, 5, 4),
      length: length,
      normalBuilder: (animationController, index) => ScaleTransition(
            scale: CurvedAnimation(
              parent: animationController,
              curve: Curves.ease,
            ),
            child: Circle(size: 7, color: Colors.white54),
          ),
      highlightedBuilder: (animationController, index) => ScaleTransition(
            scale: CurvedAnimation(
              parent: animationController,
              curve: Curves.ease,
            ),
            child: Circle(size: 7, color: Colors.white),
          ),
    );
  }
}
// reading.data.volt.toStringAsFixed(2) + ' V'
