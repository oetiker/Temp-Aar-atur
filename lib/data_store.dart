import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';


class DataStore {
  static final DataStore _singleton = DataStore._internal();

  static final Map<String, List<Map<String,dynamic>>> 
    _dataReadings = {};

  Map<String, List<Map<String,dynamic>>> 
    get data => _dataReadings;
  
  factory DataStore() {
    return _singleton;
  }

  // r is for raw string so that \ escapes are not active
  static int _lastCall =
      (DateTime.now().millisecondsSinceEpoch / 1000).floor() - 14 * 24 * 3600;
  
  Future<bool> updateStore() async {
    int now = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
    int interval = now - _lastCall;
    if (interval < 10) {
      return true;
    }

    final response = await http.get(
      Uri.parse(
          'https://temperaare.ch/REST/v1/fetch/waterTempFaehrweg,airTempFaehrweg,batFaehrweg?last=${interval}s'),
      headers: {
        HttpHeaders.acceptHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'as8jkhaksdlfhahjsfdf'
      },
    );
    // print(response.statusCode);
    switch (response.statusCode) {
      case 200:
        // If the call to the server was successful, parse the JSON.
        Map data = json.decode(response.body);
        for (String key in data.keys) {
          //print("Loading ${key}");
          for (List<dynamic> row in data[key]) {
            if (!_dataReadings.containsKey(key)){
              _dataReadings[key] = [];
            }
            _dataReadings[key]?.add({
              't': DateTime.parse(row[0]), 
              'v':double.parse(row[1])
            });
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

    DataStore._internal();
}
