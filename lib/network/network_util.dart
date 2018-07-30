import 'package:http/http.dart' as http;

/// Utility functions related to networking
class NetworkUtil {
  /// Verify whether or not the http response is successful
  static bool isSuccessful(http.Response response) {
    return response.statusCode >= 200 && response.statusCode < 300;
  }
}
