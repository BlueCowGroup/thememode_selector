import 'package:flutter/material.dart';
import 'package:thememode_selector/src/focus_background.dart';
import 'package:thememode_selector/thememode_selector.dart';
import 'celestial_transition.dart';
import 'flare.dart';
import 'moon.dart';
import 'star.dart';
import 'sun.dart';

class _ThemeModeSelectorConsts {
  late Size size;
  late EdgeInsets padding;
  late EdgeInsets focusPadding;
  late Size inset;
  late double toggleDiameter;
  List<dynamic> stars = [];
  List<dynamic> flares = [];

  _ThemeModeSelectorConsts(double height) {
    focusPadding = EdgeInsets.all(2);
    height = height - focusPadding.bottom - focusPadding.top;
    var width = height * 100 / 56;
    size = Size(width, height);
    padding = EdgeInsets.fromLTRB(
        width * .11, width * .085, width * .11, width * .085);
    var insetWidth = width - padding.left - padding.right;

    var insetHeight = height - padding.top - padding.bottom;
    toggleDiameter = insetHeight;
    inset = Size(insetWidth, toggleDiameter);

    var center = insetWidth / 2;

    stars.add({
      "from": Offset(center, 0.112 * insetHeight),
      "to": Offset(0.482 * insetWidth, 0.112 * insetHeight),
      "size": 0.03 * width
    });
    stars.add({
      "from": Offset(center, 0.332 * insetHeight),
      "to": Offset(0.335 * insetWidth, 0.332 * insetHeight),
      "size": 0.03 * width
    });
    stars.add({
      "from": Offset(center, 0.112 * insetHeight),
      "to": Offset(0.133 * insetWidth, 0.112 * insetHeight),
      "size": 0.1 * width
    });
    stars.add({
      "from": Offset(center, 0.551 * insetHeight),
      "to": Offset(0.042 * insetWidth, 0.551 * insetHeight),
      "size": 0.03 * width
    });
    stars.add({
      "from": Offset(center, 0.661 * insetHeight),
      "to": Offset(0.335 * insetWidth, 0.661 * insetHeight),
      "size": 0.05 * width
    });
    flares.add({
      "from": Offset(0.739 * insetWidth, 0.039 * insetHeight),
      "to": Offset(center, 0.039 * insetHeight),
      "size": 0.10 * width
    });
    flares.add({
      "from": Offset(0.628 * insetWidth, 0.368 * insetHeight),
      "to": Offset(center, 0.368 * insetHeight),
      "size": 0.043 * width
    });
  }
}

/// A ThemeMode Selector widget designed by Zhenya Karapetyan
class ThemeModeSelector extends StatefulWidget {
  final int _durationInMs;
  final Color? _lightBackgroundColor;
  final Color? _darkBackgroundColor;
  final Color? _lightToggleColor;
  final Color? _darkToggleColor;
  final _ThemeModeSelectorConsts _consts;
  final ValueChanged<ThemeMode> _onChanged;

  /// Creates a ThemeMode Selector.
  ///
  /// This selector maintains its own state and the widget calls the
  /// [onChanged] callback when its state is changed.
  ///
  /// * [height] allows the user to control the height of the widget and
  ///    a default height of 39 is used.
  /// * [onChanged] is called while the user is selecting a new value for the
  ///   slider.
  /// * [lightBackground] and [lightToggle] are colors which control the
  ///   foreground and background colors representing the "light" theme mode
  /// * [darkBackground] and [darkToggle] are colors which control the
  ///   foreground and background colors representing the "dark" theme mode
  ///
  ThemeModeSelector({
    Key? key,
    durationInMs = 750,
    Color? lightBackground,
    Color? lightToggle,
    Color? darkBackground,
    Color? darkToggle,
    double height = 39,
    required ValueChanged<ThemeMode> onChanged,
  })   : _durationInMs = durationInMs,
        _onChanged = onChanged,
        _lightBackgroundColor = lightBackground,
        _lightToggleColor = lightToggle,
        _darkBackgroundColor = darkBackground,
        _darkToggleColor = darkToggle,
        _consts = _ThemeModeSelectorConsts(height),
        super(key: key);

  @override
  _ThemeModeSelectorState createState() => _ThemeModeSelectorState();
}

class _ThemeModeSelectorState extends State<ThemeModeSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Set<MaterialState> _states = {};

  late Animation<Alignment> _alignmentAnimation;
  late Animation<double> _starFade;
  late Animation<double> _flareFade;
  late Animation<double> _starToggleFade;
  late Animation<double> _flareToggleFade;
  late Animation<Color?> _bgColorAnimation;

  bool isChecked = false;

  @override
  void initState() {
    super.initState();

    // Setup the global animation controller using the duration parameter
    _initializeAnimationController();
  }

  @override
  void didUpdateWidget(ThemeModeSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    // rebuild the global animation controller using the duration parameter
    _initializeAnimationController();
  }

  _initializeAnimationController() {
    Duration _duration = Duration(milliseconds: widget._durationInMs);

    _animationController = AnimationController(
      vsync: this,
      duration: _duration,
    );
  }

  initialize(BuildContext context, ThemeModeSelectorThemeData myTheme) {
    // Setup the tween for the background colors
    _bgColorAnimation = ColorTween(
      begin: lightBackgroundColor(myTheme),
      end: darkBackgroundColor(myTheme),
    ).animate(_animationController);

    // the tween for the toggle button (left and right)
    _alignmentAnimation = AlignmentTween(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.9, curve: Curves.easeOutBack),
        reverseCurve: Interval(0.0, 0.9, curve: Curves.easeInBack),
      )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            widget._onChanged(ThemeMode.dark);
          } else if (status == AnimationStatus.dismissed) {
            widget._onChanged(ThemeMode.light);
          }
        }),
    );

    // Tweens and animation for the stars and flares
    var earlyFade = CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 0.5, curve: Curves.elasticOut),
      reverseCurve: Interval(0.5, 1.0, curve: Curves.elasticIn),
    );

    _starFade = Tween(begin: 0.0, end: 1.0).animate(earlyFade);
    _flareFade = Tween(begin: 1.0, end: 0.0).animate(earlyFade);
    _starToggleFade = Tween(begin: 0.0, end: 1.0).animate(earlyFade);
    _flareToggleFade = Tween(begin: 1.0, end: 0.0).animate(earlyFade);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Builds the semi-complex tween for the stars and flares which aninate to
  // and fro from the center of the widget
  Animation<RelativeRect> slide(Offset from, Offset to, double size) {
    var container = Rect.fromLTWH(
        0, 0, widget._consts.inset.width, widget._consts.inset.height);
    return RelativeRectTween(
      begin: RelativeRect.fromRect(
          Rect.fromLTWH(from.dx, from.dy, size, size), container),
      end: RelativeRect.fromRect(
          Rect.fromLTWH(to.dx, to.dy, size, size), container),
    ).animate(
        // _animationController
        CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeOut.flipped,
    ));
  }

  lightToggleColor(myTheme) =>
      widget._lightToggleColor ?? myTheme.lightToggleColor ?? Colors.white;

  lightBackgroundColor(myTheme) =>
      widget._lightBackgroundColor ??
      myTheme.lightBackgroundColor ??
      Color(0xFF689DFF);

  darkToggleColor(myTheme) =>
      widget._darkToggleColor ?? myTheme.darkToggleColor ?? Colors.white;

  darkBackgroundColor(myTheme) =>
      widget._darkBackgroundColor ??
      myTheme.darkBackgroundColor ??
      Color(0xFF040507);

  void _handleFocusHighlight(bool value) {
    print('_handleFocusHighlight($value)');
    bool modified = value
        ? _states.add(MaterialState.focused)
        : _states.remove(MaterialState.focused);
    if (modified) setState(() {});
  }

  void _handleHoverHighlight(bool value) {
    print('_handleHoverHighlight($value)');
    bool modified = value
        ? _states.add(MaterialState.hovered)
        : _states.remove(MaterialState.hovered);
    if (modified) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ThemeModeSelectorThemeData myTheme = ThemeModeSelectorTheme.of(context);
    initialize(context, myTheme);

    return FocusableActionDetector(
      onShowFocusHighlight: _handleFocusHighlight,
      onShowHoverHighlight: _handleHoverHighlight,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return GestureDetector(
            onTap: () {
              setState(() {
                if (_animationController.isCompleted) {
                  _animationController.reverse();
                } else {
                  _animationController.forward();
                }

                isChecked = !isChecked;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: widget._consts.size.width,
                  height: widget._consts.size.height,
                  padding: widget._consts.padding,
                  decoration: BoxDecoration(
                    color: _bgColorAnimation.value,
                    borderRadius: BorderRadius.all(
                      Radius.circular(widget._consts.size.height),
                    ),
                  ),
                  child: Stack(
                    children: <Widget>[
                      ...widget._consts.stars
                          .map((star) => CelestialTransition(
                                alphaAnimation: _starFade,
                                child: Star(
                                    size: star['size'],
                                    color: lightToggleColor(myTheme)),
                                relativeRectAnimation: slide(
                                    star['from'], star['to'], star['size']),
                              ))
                          .toList(),
                      ...widget._consts.flares
                          .map((flare) => CelestialTransition(
                                alphaAnimation: _flareFade,
                                child: Flare(
                                    size: flare['size'],
                                    color: lightToggleColor(myTheme)),
                                relativeRectAnimation: slide(
                                    flare['from'], flare['to'], flare['size']),
                              ))
                          .toList(),
                      Align(
                        alignment: _alignmentAnimation.value,
                        child: Stack(children: [
                          FadeTransition(
                            opacity: _flareToggleFade,
                            child: Sun(
                              color: lightToggleColor(myTheme),
                              size: widget._consts.inset.height,
                            ),
                          ),
                          FadeTransition(
                            opacity: _starToggleFade,
                            child: Moon(
                              color: darkToggleColor(myTheme),
                              size: widget._consts.inset.height,
                            ),
                          ),
                        ]),
                      ),
                    ],
                  ),
                ),
                FocusBackground(
                  padding: widget._consts.focusPadding,
                  focused: _states.contains(MaterialState.focused),
                  width: widget._consts.size.width,
                  height: widget._consts.size.height,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
