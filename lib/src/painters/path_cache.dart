import 'dart:ui';
import 'package:flutter/rendering.dart' show Matrix4;
import 'package:path_parsing/path_parsing.dart';

/// Global cache for parsed SVG paths to avoid re-parsing on every paint
class PathCache {
  static final Map<String, Path> _cache = {};
  static final Map<String, Path> _scaledCache = {};
  static final Map<String, List<PathMetric>> _metricsCache = {};

  /// Get or parse an SVG path string
  static Path get(String svgPath) {
    return _cache.putIfAbsent(svgPath, () => _parsePath(svgPath));
  }

  /// Get a scaled version of a path (cached)
  static Path getScaled(String svgPath, double scaleFactor) {
    final key = '$svgPath@$scaleFactor';
    return _scaledCache.putIfAbsent(key, () {
      final path = get(svgPath);
      final matrix = Matrix4.diagonal3Values(scaleFactor, scaleFactor, 1.0);
      return path.transform(matrix.storage);
    });
  }

  /// Get path metrics (cached)
  static List<PathMetric> getMetrics(String svgPath, double scaleFactor) {
    final key = '$svgPath@$scaleFactor';
    return _metricsCache.putIfAbsent(key, () {
      final scaledPath = getScaled(svgPath, scaleFactor);
      return scaledPath.computeMetrics().toList();
    });
  }

  /// Clear the entire cache
  static void clear() {
    _cache.clear();
    _scaledCache.clear();
    _metricsCache.clear();
  }

  /// Remove a specific path from cache
  static void remove(String svgPath) {
    _cache.remove(svgPath);
    // Also remove any scaled versions
    _scaledCache.removeWhere((key, _) => key.startsWith('$svgPath@'));
    _metricsCache.removeWhere((key, _) => key.startsWith('$svgPath@'));
  }

  /// Parse SVG path string to Flutter Path
  static Path _parsePath(String svgPath) {
    final path = Path();
    writeSvgPathDataToPath(svgPath, _FlutterPathProxy(path));
    return path;
  }
}

/// Adapter to convert path_parsing callbacks to Flutter Path
class _FlutterPathProxy implements PathProxy {
  final Path path;

  _FlutterPathProxy(this.path);

  @override
  void close() => path.close();

  @override
  void cubicTo(
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) =>
      path.cubicTo(x1, y1, x2, y2, x3, y3);

  @override
  void lineTo(double x, double y) => path.lineTo(x, y);

  @override
  void moveTo(double x, double y) => path.moveTo(x, y);
}
