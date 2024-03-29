import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TemperatureStore {
  static final TemperatureStore _singleton = TemperatureStore._internal();
  static final List<TemperatureReading> _temperatureReadings = [
      //     TemperatureReading(celsius1: 0.0, celsius2: 0.0,volt: 0.0,time: DateTime.now().subtract(const Duration(days: 5))),
      // TemperatureReading(celsius1: 0.0, celsius2: 0.0,volt: 0.0,time: DateTime.now()),
];

  List<TemperatureReading> get data => _temperatureReadings;

  factory TemperatureStore() {
    return _singleton;
  }
  final RegExp _timeParser = RegExp(r"(.+\.\d{1,6})\d*.*Z");
  static int _lastCall = (DateTime.now().millisecondsSinceEpoch / 1000).floor() - 14*24*3600;
  static String? _prevMatch = '2020-02-26T08:22:11.900979';
  Future<bool> updateStore() async {
    int now = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
    int interval = now - _lastCall;
    if (interval < 10) {
      return true;
    }

    final response = await http.get(
     Uri.parse(
      'https://temperaare.ch/REST/v1/query/faehrweg?last=${interval}s'),
      headers: {
        HttpHeaders.acceptHeader: 'application/json',
        HttpHeaders.authorizationHeader:
            'as8jkhaksdlfhahjsfdf'
      },
    );
    // print(response.statusCode);
    switch (response.statusCode) {
      case 200:
            // If the call to the server was successful, parse the JSON.
        for (Map item in json.decode(response.body)) {
          // skip if we get bad data;
          if (!item.containsKey('celsius1')) {
            continue;
          }
          var match = _timeParser.firstMatch(item['time']);
          if (match != null && match[1]!.compareTo(_prevMatch!) > 0) {
            _temperatureReadings.add(TemperatureReading(
              celsius1: item['celsius1'],
              celsius2: item['celsius2'],
              volt: item['volt'],
              time: DateTime.parse(match[1]! + 'Z')
            ));
            _prevMatch = match[1];
            // print(_prevMatch);
          }
        }
        continue ok;
      ok:
      case 204: // no content
        _lastCall = now;
        return true;
      default:
         // If that call was not successful, throw an error.
        throw Exception(response.reasonPhrase);
    }
  }

  TemperatureStore._internal();
}

class TemperatureReading {
  final num celsius1;
  final num celsius2;
  final num volt;
  final DateTime time;

  TemperatureReading({required this.celsius1, required this.celsius2, required this.volt, required this.time});
}
