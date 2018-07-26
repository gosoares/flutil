import 'package:flutil/src/paging/data_source.dart';

/// thrown when there's a error loading data in a [DataSource]
class DataLoadException implements Exception {
  final String cause;
  const DataLoadException([this.cause = '']);

  /// create a data load exception from a
  /// [exception] and a [stackTrace]
  const DataLoadException.from(dynamic exception, dynamic stackTrace)
      : this('Redirecting Exception: $exception \n Redirected StackTrace:\n$stackTrace');
}
