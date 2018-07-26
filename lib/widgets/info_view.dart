import 'package:flutter/material.dart';

class InfoView extends StatelessWidget {
  const InfoView({
    @required this.image,
    @required this.text,
    this.after = const [],
  });

  final Image image;
  final String text;

  final List<Widget> after;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 64.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            image,
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 25.0,
                ),
              ),
            ),
          ]..addAll(after),
        ),
      ),
    );
  }
}
