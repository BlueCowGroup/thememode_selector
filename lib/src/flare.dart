import 'package:flutter/material.dart';

class Flare extends StatelessWidget {
  final double size;
  final Color color;

  const Flare({Key key, this.size, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
