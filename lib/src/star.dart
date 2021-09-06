import 'dart:math' as math;

import 'package:flutter/material.dart';

class Star extends StatelessWidget {
  final double size;
  final Color color;

  const Star({Key? key, required this.size, required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StarPainter(diameter: size, color: color),
    );
  }
}

class _StarPainter extends CustomPainter {
  final double diameter;
  final Color color;
  final int sides = 10;

  _StarPainter({required this.diameter, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    var path = Path();
    var angle = math.pi * 2 / sides;
    var radius = diameter / 2;
    var radians = -math.pi / 2; // Starting at 90° for the point of the star

    path.moveTo(radius, 0);

    for (int i = 0; i <= 10; i++) {
      var curRadius = (i.isOdd) ? radius * 0.65 : radius;
      var x = curRadius * math.cos(radians + angle * i) + radius;
      var y = curRadius * math.sin(radians + angle * i) + radius;
      path.lineTo(x, y);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
