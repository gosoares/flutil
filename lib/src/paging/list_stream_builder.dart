import 'dart:async';

import 'package:flutter/material.dart';

typedef OnDataWidgetBuilder<T> = Widget Function(BuildContext context, List<T> data);

/// A StreamBuilder for a list of items that builds:
/// [onDataBuilder] when the stream emits a no empty list of items
/// [onLoadBuilder] when the stream emits null
/// [onEmptyBuilder] when the streams emits a empty list
class ListStreamBuilder<T> extends StatelessWidget {
  const ListStreamBuilder({
    @required this.stream,
    @required this.onDataBuilder,
    @required this.onEmptyBuilder,
    @required this.onLoadBuilder,
    this.initialData,
    this.doOnEvent,
  });

  final Stream<List<T>> stream;

  final List<T> initialData;

  final OnDataWidgetBuilder<T> onDataBuilder;
  final WidgetBuilder onLoadBuilder;
  final WidgetBuilder onEmptyBuilder;

  /// executes independently of the data status
  final VoidCallback doOnEvent;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<T>>(
      stream: stream,
      initialData: initialData,
      builder: (context, snapshot) {
        doOnEvent?.call();

        if (!snapshot.hasData) {
          return onLoadBuilder(context);
        } else if (snapshot.data.isEmpty) {
          return onEmptyBuilder(context);
        } else {
          return onDataBuilder(context, snapshot.data);
        }
      },
    );
  }
}
