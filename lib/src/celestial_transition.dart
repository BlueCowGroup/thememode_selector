import 'package:flutter/material.dart';

class CelestialTransition extends StatelessWidget {
  final Widget child;
  final Animation<RelativeRect> relativeRectAnimation;
  final Animation<double> alphaAnimation;

  const CelestialTransition({
    Key? key,
    required this.child,
    required this.relativeRectAnimation,
    required this.alphaAnimation,
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
