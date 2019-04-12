import 'dart:async';

import 'package:flutil/src/paging/data_load_exception.dart';
import 'package:flutil/src/paging/data_status.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

typedef Retry = Future<Null> Function();

/// base class for items [T] that are loaded in pages
abstract class DataSource<T> {
  final int initialLoadSize;
  final int pageSize;

  DataSource(
    this.pageSize, [
    int initialLoadSize,
  ]) : this.initialLoadSize = initialLoadSize ?? pageSize;

  /// streams the data status: ready, loading or error
  final BehaviorSubject<DataStatus> _initialDataStatusSubject =
      BehaviorSubject<DataStatus>.seeded(DataStatus.ready);
  Stream<DataStatus> get initialDataStatus => _initialDataStatusSubject.stream;

  /// streams the data status: ready, loading or error
  final BehaviorSubject<DataStatus> _dataStatusSubject = BehaviorSubject<DataStatus>.seeded(DataStatus.ready);
  Stream<DataStatus> get dataStatus => _dataStatusSubject.stream;

  /// streams the loaded items
  final BehaviorSubject<List<T>> _itemsSubject = BehaviorSubject<List<T>>.seeded(<T>[]);
  Stream<List<T>> get items => _itemsSubject.stream;

  /// whether this data source is valid
  bool _valid = true;

  /// whether this data source loaded all the data
  bool _finished = false;

  /// loads the first [initialLoadSize] items of [T]
  @protected
  Future<List<T>> loadInitialData(int startPosition, int initialLoadSize);

  /// loads more items of [T]
  @protected
  Future<List<T>> loadRangeData(int startPosition, int loadSize);

  /// load first items and adds on items subject
  Future<Null> loadInitial() async {
    assert(_itemsSubject.value.isEmpty);
    assert(_initialDataStatusSubject.value == DataStatus.ready);

    _initialDataStatusSubject.add(DataStatus.loading);
    _dataStatusSubject.add(DataStatus.loading);
    try {
      final items = await loadInitialData(0, initialLoadSize);

      if (items.isEmpty) _finished = true;

      if (_valid) {
        _itemsSubject.add(items);
        _initialDataStatusSubject.add(DataStatus.ready);
        _dataStatusSubject.add(DataStatus.ready);
      }
    } on DataLoadException catch (e, s) {
      if (_valid) {
        _itemsSubject.addError(e, s);
        _initialDataStatusSubject.add(DataStatus.error);
        _dataStatusSubject.add(DataStatus.error);
      }
    }
  }

  /// load next page of items and adds on the items subject
  Future<Null> _loadNextPage() async {
    _dataStatusSubject.add(DataStatus.loading);
    try {
      final items = await loadRangeData(_itemsSubject.value.length, pageSize);

      if (items.isEmpty) {
        _finished = true;
      } else if (_valid) {
        _itemsSubject.add(_itemsSubject.value..addAll(items));
      }

      if (_valid) _dataStatusSubject.add(DataStatus.ready);
    } on DataLoadException catch (e, s) {
      if (_valid) {
        _itemsSubject.addError(e, s);
        _dataStatusSubject.add(DataStatus.error);
      }
    }
  }

  Future<Null> loadNextPage() async {
    // loads next page if there is no page loading and its not finished
    if (_dataStatusSubject.value == DataStatus.ready && !_finished) {
      await _loadNextPage();
    }
  }

  /// Just call in case of a error loading the data
  Future<Null> retry() {
    assert(_dataStatusSubject.value == DataStatus.error);

    if (_itemsSubject.value.isEmpty) {
      return loadInitial();
    } else {
      return _loadNextPage();
    }
  }

  /// invalidates the data source
  /// if overwritten should call super function and the end of the call
  @mustCallSuper
  void invalidate() {
    _valid = false;
    _initialDataStatusSubject.close();
    _dataStatusSubject.close();
    _itemsSubject.close();
  }
}
