import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutil/widgets/info_view.dart';
import 'package:flutter/material.dart';

class ErrorView extends StatefulWidget {
  const ErrorView({
    @required this.image,
    @required this.text,
    @required this.onRetry,
    this.autoRetry = true,
  });

  final Image image;
  final String text;

  final VoidCallback onRetry;

  final bool autoRetry;

  @override
  _ErrorViewState createState() => _ErrorViewState();
}

class _ErrorViewState extends State<ErrorView> {
  StreamSubscription subscription;
  bool noInternet;

  @override
  void initState() {
    super.initState();
    if (widget.autoRetry) {
      _initAutoRetry();
    }
  }

  Future<Null> _initAutoRetry() async {
    final connectivity = Connectivity();
    final result = await connectivity.checkConnectivity();

    if (result == ConnectivityResult.none) {
      // no internet
      subscription = connectivity.onConnectivityChanged.listen((result) {
        if (result != ConnectivityResult.none) {
          // internet available
          widget.onRetry.call();
        }
      });
    }
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InfoView(
      image: widget.image,
      text: widget.text,
      after: <Widget>[
        FlatButton(
          child: Text(
            'TENTAR NOVAMENTE',
            style: TextStyle(color: Colors.blue),
          ),
          onPressed: widget.onRetry,
        ),
      ],
    );
  }
}
