import 'dart:async';

import 'package:flutil/src/paging/data_status.dart';
import 'package:flutter/material.dart';

/// A StreamBuilder that builds:
/// [onReadyBuilder] when the stream emits [DataStatus.ready]
/// [onLoadBuilder] when the stream emits [DataStatus.loading]
/// [onErrorBuilder] when the streams emits [DataStatus.error]
class StatusStreamBuilder extends StatelessWidget {
  const StatusStreamBuilder({
    @required this.stream,
    this.onReadyBuilder,
    this.onLoadBuilder,
    this.onErrorBuilder,
    this.initialStatus = DataStatus.loading,
    this.doOnEvent,
  });

  final Stream<DataStatus> stream;

  final DataStatus initialStatus;

  final WidgetBuilder onReadyBuilder;
  final WidgetBuilder onLoadBuilder;
  final WidgetBuilder onErrorBuilder;

  /// executes independently of the data status
  final VoidCallback doOnEvent;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DataStatus>(
      stream: stream,
      initialData: initialStatus,
      builder: (context, snapshot) {
        assert(!snapshot.hasError);
        assert(snapshot.hasData);

        doOnEvent?.call();

        switch (snapshot.data) {
          case DataStatus.ready:
            return onReadyBuilder?.call(context) ?? Container();

          case DataStatus.loading:
            return onLoadBuilder?.call(context) ?? Container();

          case DataStatus.error:
            return onErrorBuilder?.call(context) ?? Container();
        }
      },
    );
  }
}
