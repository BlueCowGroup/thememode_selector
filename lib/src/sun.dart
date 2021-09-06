import 'package:flutter/material.dart';

class Sun extends StatelessWidget {
  final double size;
  final Color color;

  const Sun({Key? key, required this.size, this.color = Colors.white})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
