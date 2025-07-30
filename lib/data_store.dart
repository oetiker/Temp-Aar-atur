import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';


class DataStore {
  static final DataStore _singleton = DataStore._internal();

  static final Map<String, List<Map<String,dynamic>>> 
    _dataReadings = {};

  Map<String, List<Map<String,dynamic>>> 
    get data => _dataReadings;
  
  bool _isOffline = false;
  bool get isOffline => _isOffline;
  
  factory DataStore() {
    return _singleton;
  }

  // r is for raw string so that \ escapes are not active
  static int _lastCall =
      (DateTime.now().millisecondsSinceEpoch / 1000).floor() - 14 * 24 * 3600;
  
  Future<bool> updateStore({int maxRetries = 3}) async {
    int now = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
    int interval = now - _lastCall;
    if (interval < 10) {
      return true;
    }

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final response = await http.get(
          Uri.parse(
              'https://temperaare.ch/REST/v1/fetch/waterTempFaehrweg,airTempFaehrweg,batFaehrweg?last=${interval}s'),
          headers: {
            HttpHeaders.acceptHeader: 'application/json',
            HttpHeaders.authorizationHeader: 'as8jkhaksdlfhahjsfdf'
          },
        ).timeout(const Duration(seconds: 10));
        
        switch (response.statusCode) {
          case 200:
            // If the call to the server was successful, parse the JSON.
            Map data = json.decode(response.body);
            for (String key in data.keys) {
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
            _isOffline = false;
            continue ok;
          ok:
          case 204: // no content
            _lastCall = now;
            _isOffline = false;
            return true;
          default:
            // If this is the last attempt, mark as offline and return false
            if (attempt == maxRetries - 1) {
              _isOffline = true;
              return false;
            }
            // Otherwise, continue to next retry attempt
            break;
        }
      } catch (e) {
        // Handle network errors, timeouts, etc.
        if (attempt == maxRetries - 1) {
          _isOffline = true;
          return false;
        }
        // Wait before retrying (exponential backoff)
        await Future.delayed(Duration(seconds: (attempt + 1) * 2));
      }
    }
    
    _isOffline = true;
    return false;
  }

    DataStore._internal();
}
