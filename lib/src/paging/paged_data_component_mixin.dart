import 'dart:async';

import 'package:flutil/src/paging/data_source.dart';
import 'package:flutil/src/paging/data_status.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

/// mixin for components responsible for loading paged data
abstract class PagedDataComponentMixin<T, DS extends DataSource<T>> {
  final BehaviorSubject<DS> _dataSourceSubject = BehaviorSubject<DS>();

  /// streams the data
  Stream<List<T>> get items => _dataSourceSubject.flatMap((ds) => ds.items);

  /// streams the initial load status
  Stream<DataStatus> get initialDataStatus => _dataSourceSubject.flatMap((ds) => ds.initialDataStatus);

  /// streams the load  status
  Stream<DataStatus> get dataStatus => _dataSourceSubject.flatMap((ds) => ds.dataStatus);

  /// current used data source
  @protected
  DS get currentDataSource => _dataSourceSubject.value;

  /// creates a data source
  /// called every time the data source is invalidated
  @protected
  DS createDataSource();

  /// must be called in the bloc constructor
  void initPaging() {
    final ds = createDataSource()..loadInitial();
    _dataSourceSubject.add(ds);
  }

  /// called to request load more items
  Future<Null> loadMore() {
    return currentDataSource.loadNextPage();
  }

  /// in case of a error, call this to retry
  Future<Null> retry() {
    return currentDataSource.retry();
  }

  /// reloads data from zero
  Future<Null> reload() => invalidateDataSource();

  /// invalidates the current data source, creates a new one and load initial data.
  @protected
  Future<Null> invalidateDataSource() {
    final prevDataSource = _dataSourceSubject.value;
    final newDataSource = createDataSource();
    _dataSourceSubject.add(newDataSource);
    prevDataSource.invalidate();
    return currentDataSource.loadInitial();
  }

  @mustCallSuper
  void dispose() {
    _dataSourceSubject.value.invalidate();
    _dataSourceSubject.close();
  }
}
