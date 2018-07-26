import 'dart:async';

import 'package:flutter/material.dart';

typedef OnErrorWidgetBuilder = Widget Function(BuildContext context, Object error);

typedef OnDataWidgetBuilder<T> = Widget Function(BuildContext context, T data);

/// A StreamBuilder that builds:
/// [onDataBuilder] when the stream emits data
/// [onLoadBuilder] when the stream emits null
/// [onErrorBuilder] when the streams emits a error
class LoadStreamBuilder<T> extends StatelessWidget {
  const LoadStreamBuilder({
    @required this.stream,
    @required this.onDataBuilder,
    @required this.onLoadBuilder,
    @required this.onErrorBuilder,
    this.initialData,
    this.doOnEvent,
  });

  final Stream<T> stream;

  final T initialData;

  final OnDataWidgetBuilder<T> onDataBuilder;
  final WidgetBuilder onLoadBuilder;
  final OnErrorWidgetBuilder onErrorBuilder;

  /// executes independently of the data status
  final VoidCallback doOnEvent;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: stream,
      initialData: initialData,
      builder: (context, snapshot) {
        doOnEvent?.call();
        if (snapshot.hasData) {
          return onDataBuilder(context, snapshot.data);
        } else if (snapshot.hasError) {
          return onErrorBuilder(context, snapshot.error);
        } else {
          return onLoadBuilder(context);
        }
      },
    );
  }
}
