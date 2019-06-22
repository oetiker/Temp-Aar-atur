import 'dart:io';
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
    RegExp exp = new RegExp(r"(.+\.\d{1,6})\d*.*Z");
    var match = exp.firstMatch(json[0]['time']);
    return TempReading(
      celsius1: json[0]['celsius1'],
      celsius2: json[0]['celsius2'],
      volt: json[0]['volt'],
      time: DateTime.parse(match[1] + 'Z'),
    );
  }
}

void main() => runApp(TempAar(tempi: fetchTemperature()));

class TempAar extends StatelessWidget {
  final Future<TempReading> tempi;

  TempAar({Key key, this.tempi}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aare Temperature',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Aare Temperature'),
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
                  ]
                );
              } else if (reading.hasError) {
                return Text("${reading.error}");
              }
              return CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
