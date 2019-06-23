import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

Future<TempReading> fetchTemperature() async {
  final response = await http.get(
      'https://aare-tempi.data.thethingsnetwork.org/api/v2/query/tempi-sensor-aarweg?last=2h',
      headers: {
        HttpHeaders.acceptHeader: 'application/json',
        HttpHeaders.authorizationHeader:
            'key ttn-account-v2.vO1iK1sVuNaUq-zm8aDVNK53d_uHv9eEO8lrDbMbyX0'
      });

  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON.
    return TempReading.fromJson(json.decode(response.body));
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }
}

class TempReading {
  final num celsius1;
  final num celsius2;
  final num volt;
  final DateTime time;

  TempReading({this.celsius1, this.celsius2, this.volt, this.time});

  factory TempReading.fromJson(List<dynamic> json) {
    // the timestamp returned from the website has more
    // than 6 digits precision ... dart can not deal with this
    // so we have to make sure there are only 6 digits.
    var t = json.last;
    RegExp exp = new RegExp(r"(.+\.\d{1,6})\d*.*Z");
    var match = exp.firstMatch(t['time']);
    return TempReading(
      celsius1: t['celsius1'],
      celsius2: t['celsius2'],
      volt: t['volt'],
      time: DateTime.parse(match[1] + 'Z'),
    );
  }
}

void main() {

  runApp(new MaterialApp(
    home: new TempAar(),
    title: 'Aare Temperature',
    theme: ThemeData(
        primarySwatch: Colors.blue,
    ),
  ));
}

class TempAar extends StatefulWidget {
  @override
  TempAarState createState() => new TempAarState();
}

class TempAarState extends State<TempAar> {

  // var _count = 0;
  final tenMinutes = const Duration(seconds:800);
  @override
  Widget build(BuildContext context) {
    Future<TempReading> tempi = fetchTemperature();
    Timer(tenMinutes,   () {
      // setState will call the build method again and thus trigger a data
      // refresh
      setState(() {});
    });
    const double iconSize = 30;
    const double titleScale = 0.8;
    const double subtitleScale = 1.8;
    return Scaffold(
        appBar: AppBar(
          title: Text('River Aare in Olten'),
        ),

        body: Center(
          child: FutureBuilder<TempReading>(
            future: tempi,
            builder: (context, reading) {
              if (reading.hasData) {
                return Column(
                  children: [
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.opacity,size: iconSize),
                        title: Text('Water Temperature',textScaleFactor: titleScale,),
                        subtitle: Text(reading.data.celsius1.toStringAsFixed(1)+' C',textScaleFactor: subtitleScale),
                      )
                    ),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.wb_cloudy,size:iconSize),
                        title: Text('Air Temperature',textScaleFactor: titleScale,),
                        subtitle: Text(reading.data.celsius2.toStringAsFixed(1)+' C',textScaleFactor: subtitleScale),
                      )
                    ),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.battery_std,size:iconSize),
                        title: Text('Battery Voltage',textScaleFactor: titleScale,),
                        subtitle: Text(reading.data.volt.toStringAsFixed(2) + 'V',textScaleFactor: subtitleScale,),
                      )
                    ),
                    Spacer(flex:1),
                    ListTile(
                        leading: const Icon(Icons.watch_later,size:iconSize),
                        title: Text('Last Measurement',textScaleFactor: titleScale,),
                        subtitle: Text(DateFormat("H:mm:ss d.M.yyyy").format(reading.data.time.toLocal()),textScaleFactor: 1.2),
                    )
                  ]
                );
              } else if (reading.hasError) {
                return Text("${reading.error}");
              }
              return CircularProgressIndicator();
            },
          ),
        ),
      );
  }
}
