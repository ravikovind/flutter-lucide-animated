import 'package:flutter/rendering.dart';
import 'path_cache.dart';

/// CustomPainter for animating SVG path elements
class AnimatedPathPainter extends CustomPainter {
  /// SVG path data string
  final String pathData;

  /// Animation progress for pathLength (0.0 to 1.0)
  final double progress;

  /// Opacity (0.0 to 1.0)
  final double opacity;

  /// Stroke color
  final Color color;

  /// Stroke width (in viewBox units)
  final double strokeWidth;

  /// ViewBox size (assumes square, typically 24)
  final double viewBoxSize;

  AnimatedPathPainter({
    required this.pathData,
    this.progress = 1.0,
    this.opacity = 1.0,
    required this.color,
    this.strokeWidth = 2.0,
    this.viewBoxSize = 24.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scaleFactor = size.width / viewBoxSize;

    // Create paint
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * scaleFactor
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Draw partial path based on progress
    if (progress >= 1.0) {
      // Full path - use cached scaled path
      final scaledPath = PathCache.getScaled(pathData, scaleFactor);
      canvas.drawPath(scaledPath, paint);
    } else if (progress > 0.0) {
      // Partial path - use cached metrics
      final metrics = PathCache.getMetrics(pathData, scaleFactor);
      for (final metric in metrics) {
        final extractedPath = metric.extractPath(0, metric.length * progress);
        canvas.drawPath(extractedPath, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant AnimatedPathPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.opacity != opacity ||
        oldDelegate.color != color ||
        oldDelegate.pathData != pathData;
  }
}

/// CustomPainter for multiple static paths (no pathLength animation)
class MultiPathPainter extends CustomPainter {
  /// List of SVG path data strings
  final List<String> paths;

  /// Opacity (0.0 to 1.0)
  final double opacity;

  /// Stroke color
  final Color color;

  /// Stroke width (in viewBox units)
  final double strokeWidth;

  /// ViewBox size (assumes square, typically 24)
  final double viewBoxSize;

  MultiPathPainter({
    required this.paths,
    this.opacity = 1.0,
    required this.color,
    this.strokeWidth = 2.0,
    this.viewBoxSize = 24.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scaleFactor = size.width / viewBoxSize;

    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * scaleFactor
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final pathData in paths) {
      final scaledPath = PathCache.getScaled(pathData, scaleFactor);
      canvas.drawPath(scaledPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant MultiPathPainter oldDelegate) {
    return oldDelegate.opacity != opacity ||
        oldDelegate.color != color ||
        oldDelegate.paths != paths;
  }
}

/// CustomPainter for circle elements
class CirclePainter extends CustomPainter {
  final double cx;
  final double cy;
  final double r;
  final double opacity;
  final Color color;
  final double strokeWidth;
  final double viewBoxSize;

  CirclePainter({
    required this.cx,
    required this.cy,
    required this.r,
    this.opacity = 1.0,
    required this.color,
    this.strokeWidth = 2.0,
    this.viewBoxSize = 24.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scaleFactor = size.width / viewBoxSize;

    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * scaleFactor
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawCircle(
      Offset(cx * scaleFactor, cy * scaleFactor),
      r * scaleFactor,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CirclePainter oldDelegate) {
    return oldDelegate.opacity != opacity ||
        oldDelegate.color != color ||
        oldDelegate.cx != cx ||
        oldDelegate.cy != cy ||
        oldDelegate.r != r;
  }
}
