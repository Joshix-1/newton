import 'dart:math';

import 'package:flutter/animation.dart';
import 'package:newton_particles/src/particles/particle.dart';
import 'package:vector_math/vector_math.dart';

/// The `AnimatedParticle` class represents a particle with animation properties.
///
/// The `AnimatedParticle` class combines a [Particle] with animation-specific properties,
/// such as animation duration, distance, angle, fading in/out effects, scaling, and more.
class AnimatedParticle {
  /// The [Particle] associated with this animated particle.
  final Particle particle;

  /// The duration of the animation for this particle in milliseconds.
  final int animationDuration;

  /// The start time of the animation for this particle in milliseconds.
  final double startTime;

  /// The distance that the particle travels during the animation.
  final double distance;

  /// The curve used to control the distance animation progress.
  final Curve distanceCurve;

  /// The angle (in degrees) at which the particle travels during the animation.
  final double angle;

  /// The threshold at which the particle starts to fade out during the animation.
  final double fadeOutThreshold;

  /// The curve used to control the fade-out animation progress.
  final Curve fadeOutCurve;

  /// The limit at which the particle starts to fade in during the animation.
  final double fadeInLimit;

  /// The curve used to control the fade-in animation progress.
  final Curve fadeInCurve;

  /// The range of scaling applied to the particle during the animation.
  final Tween<double> scaleRange;

  /// The curve used to control the scaling animation progress.
  final Curve scaleCurve;

  /// The cosine value of the `angle` used for trigonometric calculations.
  final double _angleCos;

  /// The sine value of the `angle` used for trigonometric calculations.
  final double _angleSin;

  AnimatedParticle({
    required this.particle,
    required this.startTime,
    required this.animationDuration,
    required this.distance,
    required this.distanceCurve,
    required this.angle,
    required this.fadeInLimit,
    required this.fadeInCurve,
    required this.fadeOutThreshold,
    required this.fadeOutCurve,
    required this.scaleRange,
    required this.scaleCurve,
  })  : _angleCos = cos(radians(angle)),
        _angleSin = sin(radians(angle));

  /// Called when the animation updates to apply transformations and positioning to the particle.
  ///
  /// The `progress` parameter represents the animation progress in a range from 0.0 to 1.0.
  /// Based on the progress, the particle's opacity, size, and position will be updated
  /// according to the specified animation properties.
  onAnimationUpdate(double progress) {
    if (progress <= fadeInLimit && fadeInLimit != 0) {
      final fadeInProgress = progress / fadeInLimit;
      final opacity = fadeInCurve.transform(fadeInProgress);
      particle.paint.color = particle.configuration.color.withOpacity(opacity);
    }

    if (progress >= fadeOutThreshold && fadeOutThreshold != 1) {
      var fadeOutProgress =
          (progress - fadeOutThreshold) / (1 - fadeOutThreshold);
      final opacity = 1 - fadeOutCurve.transform(fadeOutProgress);
      particle.paint.color = particle.configuration.color.withOpacity(opacity);
    }

    final currentScale = scaleRange.transform(scaleCurve.transform(progress));
    particle.size = Size(
      particle.initialSize.width * currentScale,
      particle.initialSize.height * currentScale,
    );

    var distanceProgress = distanceCurve.transform(progress);
    particle.position = Offset(
      particle.initialPosition.dx + (distance * distanceProgress) * _angleCos,
      particle.initialPosition.dy + (distance * distanceProgress) * _angleSin,
    );
  }

  /// Called when the surface size changes to adjust the particle's position if needed.
  ///
  /// The `oldSize` parameter represents the previous size of the surface.
  /// The `newSize` parameter represents the new size of the surface.
  onSurfaceSizeChanged(Size oldSize, Size newSize) {}
}
