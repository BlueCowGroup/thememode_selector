import 'package:flutter/material.dart';
import 'celestial_transition.dart';
import 'flare.dart';
import 'moon.dart';
import 'star.dart';
import 'sun.dart';

class ThemeModeSelectorConsts {
  Size size;
  EdgeInsets padding;
  Size inset;
  double toggleDiameter;
  List<dynamic> stars = [];
  List<dynamic> flares = [];

  ThemeModeSelectorConsts(double height) {
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

class ThemeModeSelector extends StatefulWidget {
  final int _durationInMs;
  final ValueChanged<ThemeMode> _onChanged;
  Color _lightBackground;
  Color _darkBackground;
  Color _lightToggle;
  Color _darkToggle;
  ThemeModeSelectorConsts _consts;

  ThemeModeSelector({
    Key key,
    durationInMs = 750,
    double height = 339,
    Color lightBackground,
    Color lightToggle,
    Color darkBackground,
    Color darkToggle,
    ValueChanged<ThemeMode> onChanged,
  })  : _durationInMs = durationInMs,
        _onChanged = onChanged,
        _lightBackground = lightBackground ?? Color(0xFF689DFF),
        _lightToggle = lightToggle ?? Colors.white,
        _darkBackground = darkBackground ?? Color(0xFF040507),
        _darkToggle = darkToggle ?? Colors.white,
        super(key: key) {
    _consts = ThemeModeSelectorConsts(height);
  }

  @override
  _ThemeModeSelectorState createState() => _ThemeModeSelectorState();
}

class _ThemeModeSelectorState extends State<ThemeModeSelector>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<Alignment> _alignmentAnimation;
  Animation<double> _starFade;
  Animation<double> _flareFade;
  Animation<double> _starToggleFade;
  Animation<double> _flareToggleFade;
  Animation<Color> _bgColorAnimation;

  bool isChecked = false;

  @override
  void initState() {
    super.initState();

    // We may need context to look up Theme information; this is an approach to make that happen
    // https://stackoverflow.com/a/49458289
    () async {
      await initialize(context);
    }();
  }

  initialize(BuildContext context) {
    Duration _duration = Duration(milliseconds: widget._durationInMs);

    _animationController = AnimationController(
      vsync: this,
      duration: _duration,
    );

    _bgColorAnimation = ColorTween(
      begin: widget._lightBackground,
      end: widget._darkBackground,
    ).animate(_animationController);

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

  void _handleChanged(ThemeMode value) {
    assert(widget._onChanged != null);
    widget._onChanged(value);
  }

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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
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
          child: Container(
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
                              size: star['size'], color: widget._darkToggle),
                          relativeRectAnimation:
                              slide(star['from'], star['to'], star['size']),
                        ))
                    .toList(),
                ...widget._consts.flares
                    .map((flare) => CelestialTransition(
                          alphaAnimation: _flareFade,
                          child: Flare(
                              size: flare['size'], color: widget._lightToggle),
                          relativeRectAnimation:
                              slide(flare['from'], flare['to'], flare['size']),
                        ))
                    .toList(),
                Align(
                  alignment: _alignmentAnimation.value,
                  child: Stack(children: [
                    FadeTransition(
                      opacity: _flareToggleFade,
                      child: Sun(
                        color: widget._lightToggle,
                        size: widget._consts.inset.height,
                      ),
                    ),
                    FadeTransition(
                      opacity: _starToggleFade,
                      child: Moon(
                        color: widget._darkToggle,
                        size: widget._consts.inset.height,
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
