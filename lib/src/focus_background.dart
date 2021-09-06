import 'package:flutter/material.dart';

class FocusBackground extends StatelessWidget {
  final double _height;
  final double _width;
  final EdgeInsets _padding;
  final bool _focused;

  const FocusBackground({
    Key? key,
    required EdgeInsets padding,
    required bool focused,
    required double height,
    required double width,
  })   : _padding = padding,
        _focused = focused,
        _height = height,
        _width = width,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _focused ? 1.0 : 0.0,
      duration: Duration(milliseconds: 100),
      child: Container(
        height: _height,
        width: _width,
        padding: _padding,
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.all(Radius.circular(_height)),
        ),
      ),
    );
  }
}
