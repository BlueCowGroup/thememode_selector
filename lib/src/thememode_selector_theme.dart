import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ThemeModeSelectorTheme extends InheritedWidget {
  final ThemeModeSelectorThemeData data;

  const ThemeModeSelectorTheme(
      {Key? key, required this.data, required Widget child})
      : super(key: key, child: child);

  static ThemeModeSelectorThemeData of(BuildContext context) {
    var theme =
        context.dependOnInheritedWidgetOfExactType<ThemeModeSelectorTheme>();
    return theme?.data ?? ThemeModeSelectorThemeData();
  }

  @override
  bool updateShouldNotify(ThemeModeSelectorTheme oldWidget) {
    return oldWidget.data == data;
  }
}

class ThemeModeSelectorThemeData with Diagnosticable {
  final Color? lightToggleColor;
  final Color? lightBackgroundColor;
  final Color? darkToggleColor;
  final Color? darkBackgroundColor;
  final double? height;

  ThemeModeSelectorThemeData({
    this.lightToggleColor,
    this.lightBackgroundColor,
    this.darkToggleColor,
    this.darkBackgroundColor,
    this.height,
  });

  ThemeModeSelectorThemeData copyWith({
    Color? lightToggleColor,
    Color? lightBackgroundColor,
    Color? darkToggleColor,
    Color? darkBackgroundColor,
    double? height,
  }) =>
      ThemeModeSelectorThemeData(
        lightToggleColor: lightToggleColor ?? this.lightToggleColor,
        lightBackgroundColor: lightBackgroundColor ?? this.lightBackgroundColor,
        darkToggleColor: darkToggleColor ?? this.darkToggleColor,
        darkBackgroundColor: darkBackgroundColor ?? this.darkBackgroundColor,
        height: height ?? this.height,
      );

  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is ThemeModeSelectorThemeData &&
        other.lightToggleColor == lightToggleColor &&
        other.lightBackgroundColor == lightBackgroundColor &&
        other.darkToggleColor == darkToggleColor &&
        other.darkBackgroundColor == darkBackgroundColor &&
        other.height == height;
  }

  @override
  int get hashCode => hashValues(
        lightToggleColor,
        lightBackgroundColor,
        darkToggleColor,
        darkBackgroundColor,
        height,
      );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Color>(
        'lightToggleColor', lightToggleColor,
        defaultValue: null));
    properties.add(DiagnosticsProperty<Color>(
        'lightBackgroundColor', lightBackgroundColor,
        defaultValue: null));
    properties.add(DiagnosticsProperty<Color>(
        'darkToggleColor', darkToggleColor,
        defaultValue: null));
    properties.add(DiagnosticsProperty<Color>(
        'darkBackgroundColor', darkBackgroundColor,
        defaultValue: null));
    properties.add(DiagnosticsProperty<double>('height', height,
        defaultValue:
            39.0)); // Feels dirty to do this here; default is actually set in widget
  }

  // Linearly interpolate between two [SwitchThemeData]s.
  static ThemeModeSelectorThemeData lerp(
      ThemeModeSelectorThemeData a, ThemeModeSelectorThemeData b, double t) {
    return ThemeModeSelectorThemeData(
      lightToggleColor: Color.lerp(a.lightToggleColor, b.lightToggleColor, t),
      lightBackgroundColor:
          Color.lerp(a.lightBackgroundColor, b.lightBackgroundColor, t),
      darkToggleColor: Color.lerp(a.darkToggleColor, b.darkToggleColor, t),
      darkBackgroundColor:
          Color.lerp(a.darkBackgroundColor, b.darkBackgroundColor, t),
      height: lerpDouble(a.height, b.height, t),
    );
  }
}
