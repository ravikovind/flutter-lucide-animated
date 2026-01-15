import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import '../models/models.dart';
import '../painters/painters.dart';
import 'controller.dart';

/// [LucideAnimatedIcon] displays an animated Lucide icon.
///
/// Supports multiple animation triggers: [AnimationTrigger.onTap],
/// [AnimationTrigger.onHover], [AnimationTrigger.loop], and
/// [AnimationTrigger.manual].
class LucideAnimatedIcon extends StatefulWidget {
  /// The icon data to display
  final LucideAnimatedIconData icon;

  /// Size of the icon (width and height)
  final double size;

  /// Color of the icon strokes
  final Color color;

  /// How the animation should be triggered
  final AnimationTrigger trigger;

  /// Controller for manual animation control
  final LucideAnimatedIconController? controller;

  /// Callback when the icon is tapped
  final VoidCallback? onTap;

  /// Override the default animation duration
  final Duration? duration;

  /// Override the default animation curve
  final Curve? curve;

  /// Stroke width override (defaults to icon's strokeWidth)
  final double? strokeWidth;

  const LucideAnimatedIcon({
    super.key,
    required this.icon,
    this.size = 24,
    this.color = const Color(0xFFFFFFFF),
    this.trigger = AnimationTrigger.onTap,
    this.controller,
    this.onTap,
    this.duration,
    this.curve,
    this.strokeWidth,
  });

  @override
  State<LucideAnimatedIcon> createState() => _LucideAnimatedIconState();
}

class _LucideAnimatedIconState extends State<LucideAnimatedIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    // Determine initial value based on trigger:
    // - onTap/onHover/manual: start at 1.0 so icon is fully visible
    // - loop: start at 0.0
    final initialValue = widget.trigger == AnimationTrigger.loop ? 0.0 : 1.0;

    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration ?? _getDefaultDuration(),
      value: initialValue,
    );

    // Attach controller if provided
    widget.controller?.attach(_animationController);

    // Start looping if trigger is loop
    if (widget.trigger == AnimationTrigger.loop) {
      _animationController.repeat();
    }

    // Add listener for state updates
    _animationController.addListener(_onAnimationUpdate);
  }

  Duration _getDefaultDuration() {
    // Get duration from icon-level animation or first element animation
    if (widget.icon.animation != null) {
      return widget.icon.animation!.duration;
    }
    for (final element in widget.icon.elements) {
      if (element.animation != null) {
        return element.animation!.duration;
      }
    }
    return const Duration(milliseconds: 400);
  }

  void _onAnimationUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(LucideAnimatedIcon oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update controller attachment
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.detach();
      widget.controller?.attach(_animationController);
    }

    // Update duration
    if (oldWidget.duration != widget.duration) {
      _animationController.duration = widget.duration ?? _getDefaultDuration();
    }

    // Handle trigger changes
    if (oldWidget.trigger != widget.trigger) {
      if (widget.trigger == AnimationTrigger.loop) {
        _animationController.repeat();
      } else if (oldWidget.trigger == AnimationTrigger.loop) {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  @override
  void dispose() {
    widget.controller?.detach();
    _animationController.removeListener(_onAnimationUpdate);
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.onTap?.call();
    if (widget.trigger == AnimationTrigger.onTap) {
      _animationController.forward(from: 0.0);
    }
  }

  void _handleHoverEnter() {
    if (widget.trigger == AnimationTrigger.onHover) {
      // Start animation from beginning on hover
      _animationController.forward(from: 0.0);
    }
  }

  void _handleHoverExit() {
    if (widget.trigger == AnimationTrigger.onHover) {
      // For hover exit, we could reverse or just let it complete
      // Reversing provides visual feedback that hover ended
      // But if already at 1.0, we let it stay visible
      if (_animationController.isAnimating) {
        _animationController.stop();
        _animationController.value = 1.0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child = _buildIcon();

    // Apply icon-level animation (if any)
    child = _applyIconAnimation(child);

    // Wrap with RepaintBoundary to isolate repaints
    child = RepaintBoundary(child: child);

    // Wrap with gesture/mouse handlers based on trigger
    if (widget.trigger == AnimationTrigger.onTap || widget.onTap != null) {
      child = GestureDetector(onTap: _handleTap, child: child);
    }

    if (widget.trigger == AnimationTrigger.onHover) {
      child = MouseRegion(
        onEnter: (_) => _handleHoverEnter(),
        onExit: (_) => _handleHoverExit(),
        child: child,
      );
    }

    return child;
  }

  Widget _buildIcon() {
    final elements = widget.icon.elements;

    if (elements.isEmpty) {
      return SizedBox(width: widget.size, height: widget.size);
    }

    // Build each element
    final children = <Widget>[];
    for (int i = 0; i < elements.length; i++) {
      final element = elements[i];
      children.add(_buildElement(element, i));
    }

    if (children.length == 1) {
      return children.first;
    }

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(children: children),
    );
  }

  Widget _buildElement(IconElement element, int index) {
    Widget child;

    // Build the base painter
    switch (element) {
      case PathElement(:final d):
        child = _buildPathElement(d, element.animation);
      case CircleElement(:final cx, :final cy, :final r):
        child = _buildCircleElement(cx, cy, r, element.animation);
      case RectElement():
        // Convert rect to path
        child = _buildRectElement(element);
      case LineElement(:final x1, :final y1, :final x2, :final y2):
        child = _buildLineElement(x1, y1, x2, y2, element.animation);
      case PolylineElement():
        child = _buildPolylineElement(element);
      case PolygonElement():
        child = _buildPolygonElement(element);
    }

    // Apply element-level transforms (translate, rotate, scale)
    child = _applyElementTransforms(child, element.animation);

    return child;
  }

  Widget _buildPathElement(String d, ElementAnimation? animation) {
    double progress = 1.0;
    double opacity = 1.0;

    if (animation != null) {
      final curve = widget.curve ?? animation.curve;
      final curvedValue = curve.transform(_animationController.value);

      switch (animation) {
        case PathLengthAnimation(:final from, :final to):
          progress = from + (to - from) * curvedValue;
        case OpacityAnimation(:final from, :final to):
          opacity = from + (to - from) * curvedValue;
        case CombinedAnimation(:final pathLength, opacity: final opacityAnim):
          if (pathLength != null) {
            progress =
                pathLength.from +
                (pathLength.to - pathLength.from) * curvedValue;
          }
          if (opacityAnim != null) {
            opacity =
                opacityAnim.from +
                (opacityAnim.to - opacityAnim.from) * curvedValue;
          }
        default:
          break;
      }
    }

    return CustomPaint(
      size: Size(widget.size, widget.size),
      painter: AnimatedPathPainter(
        pathData: d,
        progress: progress,
        opacity: opacity,
        color: widget.color,
        strokeWidth: widget.strokeWidth ?? widget.icon.strokeWidth,
        viewBoxSize: widget.icon.viewBoxWidth,
      ),
    );
  }

  Widget _buildCircleElement(
    double cx,
    double cy,
    double r,
    ElementAnimation? animation,
  ) {
    double opacity = 1.0;

    if (animation != null) {
      final curve = widget.curve ?? animation.curve;
      final curvedValue = curve.transform(_animationController.value);

      if (animation case OpacityAnimation(:final from, :final to)) {
        opacity = from + (to - from) * curvedValue;
      }
    }

    return CustomPaint(
      size: Size(widget.size, widget.size),
      painter: CirclePainter(
        cx: cx,
        cy: cy,
        r: r,
        opacity: opacity,
        color: widget.color,
        strokeWidth: widget.strokeWidth ?? widget.icon.strokeWidth,
        viewBoxSize: widget.icon.viewBoxWidth,
      ),
    );
  }

  Widget _buildRectElement(RectElement element) {
    // Convert rect to path
    final d =
        'M${element.x},${element.y} h${element.width} v${element.height} h${-element.width} Z';
    return _buildPathElement(d, element.animation);
  }

  Widget _buildLineElement(
    double x1,
    double y1,
    double x2,
    double y2,
    ElementAnimation? animation,
  ) {
    final d = 'M$x1,$y1 L$x2,$y2';
    return _buildPathElement(d, animation);
  }

  Widget _buildPolylineElement(PolylineElement element) {
    // Convert polyline points to path
    final points = element.points.trim().split(RegExp(r'\s+'));
    if (points.isEmpty) {
      return SizedBox(width: widget.size, height: widget.size);
    }

    final buffer = StringBuffer('M${points.first}');
    for (int i = 1; i < points.length; i++) {
      buffer.write(' L${points[i]}');
    }
    return _buildPathElement(buffer.toString(), element.animation);
  }

  Widget _buildPolygonElement(PolygonElement element) {
    // Convert polygon points to closed path
    final points = element.points.trim().split(RegExp(r'\s+'));
    if (points.isEmpty) {
      return SizedBox(width: widget.size, height: widget.size);
    }

    final buffer = StringBuffer('M${points.first}');
    for (int i = 1; i < points.length; i++) {
      buffer.write(' L${points[i]}');
    }
    buffer.write(' Z'); // Close the path
    return _buildPathElement(buffer.toString(), element.animation);
  }

  Widget _applyElementTransforms(Widget child, ElementAnimation? animation) {
    if (animation == null) return child;

    final curve = widget.curve ?? animation.curve;
    final curvedValue = curve.transform(_animationController.value);

    switch (animation) {
      case TranslateAnimation(
        :final fromX,
        :final toX,
        :final fromY,
        :final toY,
      ):
        final dx = fromX + (toX - fromX) * curvedValue;
        final dy = fromY + (toY - fromY) * curvedValue;
        final scale = widget.size / widget.icon.viewBoxWidth;
        return Transform.translate(
          offset: Offset(dx * scale, dy * scale),
          child: child,
        );

      case TranslateKeyframeAnimation(:final keyframesX, :final keyframesY):
        final dx = _interpolateKeyframes(keyframesX, curvedValue);
        final dy = _interpolateKeyframes(keyframesY, curvedValue);
        final scale = widget.size / widget.icon.viewBoxWidth;
        return Transform.translate(
          offset: Offset(dx * scale, dy * scale),
          child: child,
        );

      case RotateAnimation(:final fromDegrees, :final toDegrees, :final origin):
        final angle = fromDegrees + (toDegrees - fromDegrees) * curvedValue;
        return Transform.rotate(
          angle: angle * (math.pi / 180),
          alignment: origin,
          child: child,
        );

      case RotateKeyframeAnimation(:final keyframes, :final origin):
        final angle = _interpolateKeyframes(keyframes, curvedValue);
        return Transform.rotate(
          angle: angle * (math.pi / 180),
          alignment: origin,
          child: child,
        );

      case ScaleAnimation(:final from, :final to):
        final scale = from + (to - from) * curvedValue;
        return Transform.scale(scale: scale, child: child);

      case ScaleKeyframeAnimation(:final keyframes):
        final scale = _interpolateKeyframes(keyframes, curvedValue);
        return Transform.scale(scale: scale, child: child);

      default:
        return child;
    }
  }

  Widget _applyIconAnimation(Widget child) {
    final animation = widget.icon.animation;
    if (animation == null) return child;

    final curve = widget.curve ?? animation.curve;
    final curvedValue = curve.transform(_animationController.value);

    switch (animation) {
      case RotateAnimation(:final fromDegrees, :final toDegrees, :final origin):
        final angle = fromDegrees + (toDegrees - fromDegrees) * curvedValue;
        return Transform.rotate(
          angle: angle * (math.pi / 180),
          alignment: origin,
          child: child,
        );

      case RotateKeyframeAnimation(:final keyframes, :final origin):
        final angle = _interpolateKeyframes(keyframes, curvedValue);
        return Transform.rotate(
          angle: angle * (math.pi / 180),
          alignment: origin,
          child: child,
        );

      case ScaleAnimation(:final from, :final to):
        final scale = from + (to - from) * curvedValue;
        return Transform.scale(scale: scale, child: child);

      case ScaleKeyframeAnimation(:final keyframes):
        final scale = _interpolateKeyframes(keyframes, curvedValue);
        return Transform.scale(scale: scale, child: child);

      default:
        return child;
    }
  }

  /// Interpolate between keyframe values
  double _interpolateKeyframes(List<double> keyframes, double t) {
    if (keyframes.isEmpty) return 0;
    if (keyframes.length == 1) return keyframes.first;

    final segments = keyframes.length - 1;
    final segmentIndex = (t * segments).floor().clamp(0, segments - 1);
    final segmentT = (t * segments) - segmentIndex;

    return keyframes[segmentIndex] +
        (keyframes[segmentIndex + 1] - keyframes[segmentIndex]) * segmentT;
  }
}
