/// The `newton_particles` library provides a highly configurable particle emitter to create
/// captivating animations, such as rain, smoke, or explosions, in Flutter apps.
///
/// To use the `newton` library, import it in your Dart code and add a `Newton` widget
/// to your widget tree. The `Newton` widget allows you to add and manage different particle
/// effects by providing a list of `Effect` instances. It handles the animation and rendering
/// of the active particle effects on a custom canvas.
library newton_particles;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:newton_particles/src/effects/effect.dart';
import 'package:newton_particles/src/newton_painter.dart';

/// The `Newton` widget is the entry point for creating captivating particle animations.
///
/// Use the `Newton` widget to add and manage different particle effects like rain, smoke,
/// or explosions in your Flutter app. Pass a list of `Effect` instances to the `activeEffects`
/// parameter to create the desired particle animations. The `Newton` widget handles the animation
/// and rendering of the active particle effects on a custom canvas.
class Newton extends StatefulWidget {
  /// The list of active particle effects to be rendered.
  final List<Effect> activeEffects;

  const Newton({this.activeEffects = const [], super.key});

  @override
  State<Newton> createState() => NewtonState();
}

/// The `NewtonState` class represents the state for the `Newton` widget.
///
/// The `NewtonState` class extends `State` and implements `SingleTickerProviderStateMixin`,
/// allowing it to create a ticker for handling animations. It manages the active particle effects
/// and handles their animation updates. Additionally, it uses a `CustomPainter` to render the
/// particle effects on a custom canvas.
class NewtonState extends State<Newton> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  int _lastElapsedMillis = 0;
  final List<Effect> _activeEffects = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    _activeEffects.addAll(widget.activeEffects);
    _ticker = createTicker((elapsed) {
      _activeEffects.removeWhere((effect) => effect.isDead);
      if (_activeEffects.isNotEmpty) {
        for (var element in _activeEffects) {
          element.forward(elapsed.inMilliseconds - _lastElapsedMillis);
        }
        _lastElapsedMillis = elapsed.inMilliseconds;
        setState(() {});
      }
    });
    _ticker.start();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      for (var effect in _activeEffects) {
        effect.surfaceSize = constraints.biggest;
      }
      return CustomPaint(
        painter: NewtonPainter(
          effects: _activeEffects,
        ),
      );
    });
  }

  /// Adds a new particle effect to the list of active effects.
  ///
  /// The `addEffect` method allows you to dynamically add a new particle effect to the list
  /// of active effects. Simply provide an `Effect` instance representing the desired effect,
  /// and the `Newton` widget will render it on the canvas.
  addEffect(Effect effect) {
    setState(() {
      effect.surfaceSize = MediaQuery.of(context).size;
      _activeEffects.add(effect);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _ticker.stop();
  }

  void clearEffects() {
    _activeEffects.clear();
  }

  @override
  void didUpdateWidget(Newton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _activeEffects.clear();
    _activeEffects.addAll(widget.activeEffects);
  }
}
