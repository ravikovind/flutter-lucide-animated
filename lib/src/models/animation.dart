import 'package:flutter/widgets.dart';

/// Base class for all element animations
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

/// Stroke drawing animation (pathLength: 0 -> 1)
/// Animates the stroke from invisible to fully drawn
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

/// Opacity animation (fade in/out)
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

/// Rotation animation (simple from -> to)
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

/// Keyframe rotation animation (shake effect)
/// Example: [0, -10, 10, -10, 0] for bell shake
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

/// Translation animation
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

/// Keyframe translation animation
/// Example: translateX: [0, 3, 0] for arrow bounce
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

/// Scale animation
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

/// Combined animation for elements that have multiple properties animated
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
