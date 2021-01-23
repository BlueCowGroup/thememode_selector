# ThemeModeSelector Widget

I am currently working with the concept of Theme's in Flutter and I wanted to build a widget which would allow me to switch between light and dark themes. Seeking a design for a simple toggle, I was lucky enough to stumble into some of [Zhenya Karapetyan's](https://dribbble.com/jenkarapetyan) amazing work on [Dribbble](https://dribbble.com/). Zhenya's simple yet fun design of a toggle component would look very nice in Flutter, and it has some really cool animations which I wanted to learn.

![Zhenya Karapetyan's Light/Dark Toggle](https://github.com/BlueCowGroup/thememode_selector/raw/main/screenshot/Light-Dark-mode-toggle-switcher.gif)

https://dribbble.com/shots/7635203-Light-Dark-mode-toggle-switcher/attachments/396864?mode=media

# thememode_selector

A widget to toggle between a light or dark `ThemeMode`

## Features

* Configurable colors for background and foreground colors for both light and dark modes
* API similar to standard Material Slider widget

## Supported Platforms

* Flutter Android
* Flutter iOS
* Flutter Web
* Flutter Desktop

## Installation

Add `thememode_selector: ^0.1.0` to your `pubspec.yaml` configuration.

```dart
import 'package:thememode_selector/thememode_selector.dart'
```

## How to use

```dart
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
          ThemeModeManager.of(context).themeMode = mode;
        },
      ),
    ),
  );
}
```

## License

MIT



