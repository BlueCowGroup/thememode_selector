import 'package:flutter/material.dart';
import 'package:thememode_selector/thememode_selector.dart';

void main() {
  runApp(MyApp());
}

// Simple Stateful Widget allows for the ThemeMode to be changed and
// the widget tree to rebuild. This implementation is not important as
// you could be using any state management to update the ThemeData variable.
class ThemeModeManager extends StatefulWidget {
  final Widget Function(ThemeMode themeMode) builder;
  final ThemeMode defaultThemeMode;

  const ThemeModeManager(
      {Key? key, required this.builder, required this.defaultThemeMode})
      : super(key: key);

  @override
  _ThemeModeManagerState createState() =>
      _ThemeModeManagerState(themeMode: defaultThemeMode);

  static _ThemeModeManagerState? of(BuildContext context) {
    return context.findAncestorStateOfType<_ThemeModeManagerState>();
  }
}

class _ThemeModeManagerState extends State<ThemeModeManager> {
  ThemeMode _themeMode;

  _ThemeModeManagerState({required ThemeMode themeMode})
      : _themeMode = themeMode;

  set themeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      setState(() {
        _themeMode = mode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(_themeMode);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ThemeModeManager(
      defaultThemeMode: ThemeMode.light,
      builder: (themeMode) {
        return MaterialApp(
          title: 'ThemeMode Selector',
          themeMode: themeMode,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          home: HomePage(title: 'ThemeModeSelector Demo'),
        );
      },
    );
  }
}

class HomePage extends StatelessWidget {
  final String title;

  const HomePage({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: ThemeModeSelector(
          height: 39,
          onChanged: (mode) {
            print('ThemeMode changed to $mode');
            // Again, this could be using whatever approach to state
            // management you like
            ThemeModeManager.of(context)!.themeMode = mode;
          },
        ),
      ),
    );
  }
}
