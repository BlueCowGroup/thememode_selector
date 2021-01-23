import 'package:flutter/material.dart';

class Moon extends StatelessWidget {
  final double size;
  final Color color;

  const Moon({Key key, this.size, this.color = Colors.white}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MoonPainter(color),
      child: Container(width: size, height: size),
    );
  }
}

class _MoonPainter extends CustomPainter {
  final Color color;

  _MoonPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = color;

    Path path = Path();

    path.lineTo(size.width * 0.46, 0);
    path.cubicTo(size.width * 0.76, 0, size.width, size.height * 0.22,
        size.width, size.height / 2);
    path.cubicTo(size.width, size.height * 0.78, size.width * 0.76, size.height,
        size.width * 0.46, size.height);
    path.cubicTo(size.width * 0.22, size.height, size.width * 0.11,
        size.height * 0.91, size.width * 0.02, size.height * 0.8);
    path.cubicTo(-0.06, size.height * 0.69, size.width * 0.11,
        size.height * 0.74, size.width / 5, size.height * 0.74);
    path.cubicTo(size.width * 0.42, size.height * 0.74, size.width * 0.6,
        size.height * 0.57, size.width * 0.6, size.height * 0.37);
    path.cubicTo(size.width * 0.6, size.height / 5, size.width * 0.38,
        size.height * 0.09, size.width * 0.37, size.height * 0.04);
    path.cubicTo(
        size.width * 0.35, 0, size.width * 0.41, 0, size.width * 0.46, 0);
    path.cubicTo(
        size.width * 0.46, 0, size.width * 0.46, 0, size.width * 0.46, 0);

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
