import 'package:flutter/widgets.dart';

/// [ElementAnimation] is the base class for all element animations.
sealed class ElementAnimation {
  final Duration duration;
  final Duration delay;
  final Curve curve;

  const ElementAnimation({
    required this.duration,
    this.delay = Duration.zero,
    this.curve = Curves.easeOut,
  });
}

/// [PathLengthAnimation] animates stroke drawing (pathLength: 0 -> 1).
///
/// Animates the stroke from invisible to fully drawn.
class PathLengthAnimation extends ElementAnimation {
  final double from;
  final double to;

  const PathLengthAnimation({
    this.from = 0.0,
    this.to = 1.0,
    super.duration = const Duration(milliseconds: 400),
    super.delay,
    super.curve,
  });
}

/// [PathLengthKeyframeAnimation] animates stroke drawing through keyframes.
///
/// Example: `[0.1, 0.3, 0.5, 0.7, 0.9, 1]` for progressive reveal.
class PathLengthKeyframeAnimation extends ElementAnimation {
  final List<double> keyframes;

  const PathLengthKeyframeAnimation({
    required this.keyframes,
    super.duration = const Duration(milliseconds: 400),
    super.delay,
    super.curve,
  });
}

/// [OpacityAnimation] animates opacity (fade in/out).
class OpacityAnimation extends ElementAnimation {
  final double from;
  final double to;

  const OpacityAnimation({
    this.from = 0.0,
    this.to = 1.0,
    super.duration = const Duration(milliseconds: 300),
    super.delay,
    super.curve,
  });
}

/// [RotateAnimation] animates rotation (simple from -> to).
class RotateAnimation extends ElementAnimation {
  final double fromDegrees;
  final double toDegrees;
  final Alignment origin;

  const RotateAnimation({
    this.fromDegrees = 0.0,
    required this.toDegrees,
    this.origin = Alignment.center,
    super.duration = const Duration(milliseconds: 500),
    super.delay,
    super.curve,
  });
}

/// [RotateKeyframeAnimation] animates rotation through keyframes (shake effect).
///
/// Example: `[0, -10, 10, -10, 0]` for bell shake.
class RotateKeyframeAnimation extends ElementAnimation {
  final List<double> keyframes;
  final Alignment origin;

  const RotateKeyframeAnimation({
    required this.keyframes,
    this.origin = Alignment.center,
    super.duration = const Duration(milliseconds: 500),
    super.delay,
    super.curve,
  });
}

/// [TranslateAnimation] animates position translation.
class TranslateAnimation extends ElementAnimation {
  final double fromX;
  final double toX;
  final double fromY;
  final double toY;

  const TranslateAnimation({
    this.fromX = 0.0,
    this.toX = 0.0,
    this.fromY = 0.0,
    this.toY = 0.0,
    super.duration = const Duration(milliseconds: 300),
    super.delay,
    super.curve,
  });
}

/// [TranslateKeyframeAnimation] animates translation through keyframes.
///
/// Example: `keyframesX: [0, 3, 0]` for arrow bounce.
class TranslateKeyframeAnimation extends ElementAnimation {
  final List<double> keyframesX;
  final List<double> keyframesY;

  const TranslateKeyframeAnimation({
    this.keyframesX = const [0],
    this.keyframesY = const [0],
    super.duration = const Duration(milliseconds: 400),
    super.delay,
    super.curve,
  });
}

/// [ScaleAnimation] animates scale transformation.
class ScaleAnimation extends ElementAnimation {
  final double from;
  final double to;

  const ScaleAnimation({
    this.from = 1.0,
    this.to = 1.0,
    super.duration = const Duration(milliseconds: 300),
    super.delay,
    super.curve,
  });
}

/// [ScaleKeyframeAnimation] animates scale through keyframes.
///
/// Example: `[1, 0.85, 1]` for pulse effect.
class ScaleKeyframeAnimation extends ElementAnimation {
  final List<double> keyframes;

  const ScaleKeyframeAnimation({
    required this.keyframes,
    super.duration = const Duration(milliseconds: 400),
    super.delay,
    super.curve,
  });
}

/// [CombinedAnimation] combines multiple animation properties.
class CombinedAnimation extends ElementAnimation {
  final PathLengthAnimation? pathLength;
  final OpacityAnimation? opacity;
  final RotateAnimation? rotate;
  final TranslateAnimation? translate;
  final ScaleAnimation? scale;

  const CombinedAnimation({
    this.pathLength,
    this.opacity,
    this.rotate,
    this.translate,
    this.scale,
    super.duration = const Duration(milliseconds: 400),
    super.delay,
    super.curve,
  });
}
