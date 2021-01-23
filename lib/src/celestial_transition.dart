import 'package:flutter/material.dart';

class CelestialTransition extends StatelessWidget {
  final Widget child;
  final Animation<RelativeRect> relativeRectAnimation;
  final Animation<double> alphaAnimation;

  const CelestialTransition({
    Key key,
    this.child,
    this.relativeRectAnimation,
    this.alphaAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PositionedTransition(
      rect: relativeRectAnimation,
      child: FadeTransition(
        opacity: alphaAnimation,
        child: child,
      ),
    );
  }
}
