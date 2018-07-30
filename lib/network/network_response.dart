import 'dart:io';

import 'package:flutter/foundation.dart';

/// A response for a HTTP request
class NetworkResponse<T> {
  const NetworkResponse._(
    this.code, {
    @required this.isSuccessful,
    this.data,
    this.errorBody,
    this.headers,
  });

  /// a HTTP status code
  final int code;

  /// Returns true if [code] is in range [200, 300)
  final bool isSuccessful;

  /// The deserialized response body of a successful response
  final T data;

  /// The response body of a error response
  final dynamic errorBody;

  /// HTTP headers
  final Map<String, String> headers;

  /// Returns true if [code] is [HttpStatus.UNAUTHORIZED]
  bool get isUnauthorized => code == HttpStatus.UNAUTHORIZED;

  /// Creates a successful response
  factory NetworkResponse.success(int code, [T data, Map<String, String> headers]) {
    assert(code >= 200 && code < 300);
    return NetworkResponse<T>._(
      code,
      isSuccessful: true,
      data: data,
      headers: headers,
    );
  }

  /// Creates a error response
  factory NetworkResponse.error(int code, [dynamic body, Map<String, String> headers]) {
    assert(code >= 400);
    return NetworkResponse._(
      code,
      errorBody: body ?? '',
      isSuccessful: false,
      headers: headers,
    );
  }
}
