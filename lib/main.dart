import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  Future<TempReading> tempi = fetchTemperature();
  // var _count = 0;
  final tenMinutes = const Duration(seconds:600);
  @override
  Widget build(BuildContext context) {
    Timer(tenMinutes,   () {
      // setState will call the build method again and thus trigger a data
      // refresh
      setState(() {});
    });
    return Scaffold(
        appBar: AppBar(
          title: Text('Aare Temperatur'),
        ),
        body: Center(
          child: FutureBuilder<TempReading>(
            future: tempi,
            builder: (context, reading) {
              if (reading.hasData) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(reading.data.celsius1.toStringAsFixed(2)+'C',
                      style: TextStyle(fontSize: 32, color: Colors.black87)),
                    Text(reading.data.celsius2.toStringAsFixed(2)+'C',
                      style: TextStyle(fontSize: 32, color: Colors.black87)),
                    Text(reading.data.volt.toStringAsFixed(2) +
                    'V',
                      style: TextStyle(fontSize: 32, color: Colors.black87)),
                    Text(reading.data.time.toLocal().toString(),
                      style: TextStyle(fontSize: 20, color: Colors.black87)),
                    // Text((_count++).toString()),
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
