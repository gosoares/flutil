import 'dart:math';

import 'package:flutter/material.dart';

typedef PageTapListener = void Function(int index);

class Carousel extends StatefulWidget {
  const Carousel({
    this.pages,
    this.onPageClick,
    this.gradient = false,
  });

  final List<Widget> pages;

  final PageTapListener onPageClick;

  final bool gradient;

  @override
  _CarouselState createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  final _controller = PageController();

  static const _kDuration = Duration(milliseconds: 300);

  static const _kCurve = Curves.ease;

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => widget.onPageClick?.call(_controller.page.round()),
      child: Container(
        color: Colors.white,
        child: Stack(
          children: <Widget>[
            widget.gradient
                ? Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.center,
                              colors: [
                                Color(0x50000000),
                                Color(0x00000000),
                              ]),
                        ),
                      ),
                    ),
                  )
                : Container(),
            PageView(
              controller: _controller,
              children: widget.pages,
            ),
            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: Container(
                padding: EdgeInsets.all(20.0),
                child: Center(
                  child: DotsIndicator(
                    controller: _controller,
                    itemCount: widget.pages.length,
                    onPageSelected: (int page) {
                      _controller.animateToPage(
                        page,
                        duration: _kDuration,
                        curve: _kCurve,
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// An indicator showing the currently selected page of a PageController
class DotsIndicator extends AnimatedWidget {
  const DotsIndicator({
    this.controller,
    this.itemCount,
    this.onPageSelected,
    this.color = Colors.amber,
  }) : super(listenable: controller);

  /// The PageController that this DotsIndicator is representing.
  final PageController controller;

  /// The number of items managed by the PageController
  final int itemCount;

  /// Called when a dot is tapped
  final ValueChanged<int> onPageSelected;

  /// The color of the dots.
  ///
  /// Defaults to `Colors.white`.
  final Color color;

  // The base size of the dots
  static const double _kDotSize = 6.0;

  // The increase in the size of the selected dot
  static const double _kMaxZoom = 1.75;

  // The distance between the center of each dot
  static const double _kDotSpacing = 15.0;

  Widget _buildDot(int index) {
    final double selectedness = Curves.easeOut.transform(
      max(
        0.0,
        1.0 - ((controller.page ?? controller.initialPage) - index).abs(),
      ),
    );
    final double zoom = 1.0 + (_kMaxZoom - 1.0) * selectedness;
    return Container(
      width: _kDotSpacing,
      child: Center(
        child: Material(
          color: color,
          type: MaterialType.circle,
          child: Container(
            width: _kDotSize * zoom,
            height: _kDotSize * zoom,
            child: InkWell(
              onTap: () => onPageSelected(index),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: new List<Widget>.generate(itemCount, _buildDot),
    );
  }
}
