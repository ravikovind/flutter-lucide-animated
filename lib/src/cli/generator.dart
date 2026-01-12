import 'fetcher.dart';

/// Generates Dart code for animated Lucide icons
class Generator {
  /// Generate Dart code for a single icon
  String generateIcon(IconData icon) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln('// flutter_lucide_animated');
    buffer.writeln('// ignore_for_file: constant_identifier_names');
    buffer.writeln();
    buffer.writeln("import 'package:flutter_lucide_animated/flutter_lucide_animated.dart';");
    buffer.writeln();

    // Parse viewBox
    final viewBoxParts = icon.viewBox.split(' ').map((s) => double.parse(s)).toList();
    final viewBoxWidth = viewBoxParts.length > 2 ? viewBoxParts[2] : 24.0;
    final viewBoxHeight = viewBoxParts.length > 3 ? viewBoxParts[3] : 24.0;

    // Variable name (snake_case)
    final varName = _toSnakeCase(icon.name);

    // Generate icon constant
    buffer.writeln('const $varName = LucideAnimatedIconData(');
    buffer.writeln("  name: '${icon.name}',");
    buffer.writeln('  viewBoxWidth: $viewBoxWidth,');
    buffer.writeln('  viewBoxHeight: $viewBoxHeight,');
    buffer.writeln('  strokeWidth: ${icon.strokeWidth},');

    // Icon-level animation (if any)
    if (icon.animation != null) {
      buffer.writeln('  animation: ${_generateAnimation(icon.animation!)},');
    }

    // Elements
    buffer.writeln('  elements: [');
    for (final element in icon.elements) {
      buffer.writeln('    ${_generateElement(element)},');
    }
    buffer.writeln('  ],');

    buffer.writeln(');');

    return buffer.toString();
  }

  /// Generate Dart code for an element
  String _generateElement(ElementData element) {
    switch (element.type) {
      case 'path':
        return _generatePathElement(element);
      case 'circle':
        return _generateCircleElement(element);
      case 'rect':
        return _generateRectElement(element);
      case 'line':
        return _generateLineElement(element);
      case 'polyline':
        return _generatePolylineElement(element);
      default:
        // Unknown element type, try to convert to path
        return "PathElement(d: '', animation: null)";
    }
  }

  String _generatePathElement(ElementData element) {
    final d = element.attributes['d'] as String? ?? '';
    final animation = element.animation != null
        ? _generateAnimation(element.animation!)
        : null;

    if (animation != null) {
      return "PathElement(d: '$d', animation: $animation)";
    }
    return "PathElement(d: '$d')";
  }

  String _generateCircleElement(ElementData element) {
    final cx = element.attributes['cx'] ?? 0;
    final cy = element.attributes['cy'] ?? 0;
    final r = element.attributes['r'] ?? 0;
    final animation = element.animation != null
        ? _generateAnimation(element.animation!)
        : null;

    if (animation != null) {
      return 'CircleElement(cx: $cx, cy: $cy, r: $r, animation: $animation)';
    }
    return 'CircleElement(cx: $cx, cy: $cy, r: $r)';
  }

  String _generateRectElement(ElementData element) {
    final x = element.attributes['x'] ?? 0;
    final y = element.attributes['y'] ?? 0;
    final width = element.attributes['width'] ?? 0;
    final height = element.attributes['height'] ?? 0;
    final rx = element.attributes['rx'] ?? 0;
    final ry = element.attributes['ry'] ?? 0;
    final animation = element.animation != null
        ? _generateAnimation(element.animation!)
        : null;

    if (animation != null) {
      return 'RectElement(x: $x, y: $y, width: $width, height: $height, rx: $rx, ry: $ry, animation: $animation)';
    }
    return 'RectElement(x: $x, y: $y, width: $width, height: $height, rx: $rx, ry: $ry)';
  }

  String _generateLineElement(ElementData element) {
    final x1 = element.attributes['x1'] ?? 0;
    final y1 = element.attributes['y1'] ?? 0;
    final x2 = element.attributes['x2'] ?? 0;
    final y2 = element.attributes['y2'] ?? 0;
    final animation = element.animation != null
        ? _generateAnimation(element.animation!)
        : null;

    if (animation != null) {
      return 'LineElement(x1: $x1, y1: $y1, x2: $x2, y2: $y2, animation: $animation)';
    }
    return 'LineElement(x1: $x1, y1: $y1, x2: $x2, y2: $y2)';
  }

  String _generatePolylineElement(ElementData element) {
    final points = element.attributes['points'] as String? ?? '';
    final animation = element.animation != null
        ? _generateAnimation(element.animation!)
        : null;

    if (animation != null) {
      return "PolylineElement(points: '$points', animation: $animation)";
    }
    return "PolylineElement(points: '$points')";
  }

  /// Generate animation code from animation data
  String _generateAnimation(Map<String, dynamic> animation) {
    final type = animation['type'] as String?;
    final duration = animation['duration'] as int? ?? 400;
    final delay = animation['delay'] as int? ?? 0;
    final easing = animation['easing'] as String? ?? 'easeOut';

    final curve = _easingToCurve(easing);
    final durationMs = 'Duration(milliseconds: $duration)';
    final delayMs = delay > 0 ? 'delay: Duration(milliseconds: $delay),' : '';

    switch (type) {
      case 'pathLength':
        final from = animation['from'] ?? 0.0;
        final to = animation['to'] ?? 1.0;
        return 'PathLengthAnimation(from: $from, to: $to, duration: $durationMs, $delayMs curve: $curve)';

      case 'opacity':
        final from = animation['from'] ?? 0.0;
        final to = animation['to'] ?? 1.0;
        return 'OpacityAnimation(from: $from, to: $to, duration: $durationMs, $delayMs curve: $curve)';

      case 'rotate':
        final from = animation['from'] ?? 0.0;
        final to = animation['to'] ?? 360.0;
        final origin = animation['origin'] as String? ?? 'center';
        return 'RotateAnimation(fromDegrees: $from, toDegrees: $to, duration: $durationMs, $delayMs curve: $curve, origin: ${_originToAlignment(origin)})';

      case 'rotateKeyframe':
        final keyframes = animation['keyframes'] as List? ?? [0.0];
        final origin = animation['origin'] as String? ?? 'center';
        return 'RotateKeyframeAnimation(keyframes: $keyframes, duration: $durationMs, $delayMs curve: $curve, origin: ${_originToAlignment(origin)})';

      case 'translate':
        final fromX = animation['fromX'] ?? 0.0;
        final toX = animation['toX'] ?? 0.0;
        final fromY = animation['fromY'] ?? 0.0;
        final toY = animation['toY'] ?? 0.0;
        return 'TranslateAnimation(fromX: $fromX, toX: $toX, fromY: $fromY, toY: $toY, duration: $durationMs, $delayMs curve: $curve)';

      case 'translateKeyframe':
        final keyframesX = animation['keyframesX'] as List? ?? [0.0];
        final keyframesY = animation['keyframesY'] as List? ?? [0.0];
        return 'TranslateKeyframeAnimation(keyframesX: $keyframesX, keyframesY: $keyframesY, duration: $durationMs, $delayMs curve: $curve)';

      case 'scale':
        final from = animation['from'] ?? 1.0;
        final to = animation['to'] ?? 1.0;
        return 'ScaleAnimation(from: $from, to: $to, duration: $durationMs, $delayMs curve: $curve)';

      case 'combined':
        final parts = <String>[];
        if (animation['pathLength'] != null) {
          final pl = animation['pathLength'] as Map<String, dynamic>;
          parts.add('pathLength: PathLengthAnimation(from: ${pl['from'] ?? 0.0}, to: ${pl['to'] ?? 1.0}, duration: $durationMs, curve: $curve)');
        }
        if (animation['opacity'] != null) {
          final op = animation['opacity'] as Map<String, dynamic>;
          parts.add('opacity: OpacityAnimation(from: ${op['from'] ?? 0.0}, to: ${op['to'] ?? 1.0}, duration: $durationMs, curve: $curve)');
        }
        return 'CombinedAnimation(${parts.join(', ')}, duration: $durationMs, $delayMs curve: $curve)';

      default:
        // Default to pathLength animation
        return 'PathLengthAnimation(from: 0.0, to: 1.0, duration: $durationMs, $delayMs curve: $curve)';
    }
  }

  String _easingToCurve(String easing) {
    switch (easing) {
      case 'linear':
        return 'Curves.linear';
      case 'easeIn':
        return 'Curves.easeIn';
      case 'easeOut':
        return 'Curves.easeOut';
      case 'easeInOut':
        return 'Curves.easeInOut';
      case 'easeInSine':
        return 'Curves.easeInSine';
      case 'easeOutSine':
        return 'Curves.easeOutSine';
      case 'easeInOutSine':
        return 'Curves.easeInOutSine';
      case 'easeInQuad':
        return 'Curves.easeInQuad';
      case 'easeOutQuad':
        return 'Curves.easeOutQuad';
      case 'easeInOutQuad':
        return 'Curves.easeInOutQuad';
      case 'easeInCubic':
        return 'Curves.easeInCubic';
      case 'easeOutCubic':
        return 'Curves.easeOutCubic';
      case 'easeInOutCubic':
        return 'Curves.easeInOutCubic';
      case 'easeInBack':
        return 'Curves.easeInBack';
      case 'easeOutBack':
        return 'Curves.easeOutBack';
      case 'easeInOutBack':
        return 'Curves.easeInOutBack';
      case 'elasticIn':
        return 'Curves.elasticIn';
      case 'elasticOut':
        return 'Curves.elasticOut';
      case 'elasticInOut':
        return 'Curves.elasticInOut';
      case 'bounceIn':
        return 'Curves.bounceIn';
      case 'bounceOut':
        return 'Curves.bounceOut';
      case 'bounceInOut':
        return 'Curves.bounceInOut';
      default:
        return 'Curves.easeOut';
    }
  }

  String _originToAlignment(String origin) {
    switch (origin) {
      case 'center':
        return 'Alignment.center';
      case 'topLeft':
        return 'Alignment.topLeft';
      case 'topRight':
        return 'Alignment.topRight';
      case 'bottomLeft':
        return 'Alignment.bottomLeft';
      case 'bottomRight':
        return 'Alignment.bottomRight';
      case 'topCenter':
        return 'Alignment.topCenter';
      case 'bottomCenter':
        return 'Alignment.bottomCenter';
      case 'centerLeft':
        return 'Alignment.centerLeft';
      case 'centerRight':
        return 'Alignment.centerRight';
      default:
        return 'Alignment.center';
    }
  }

  String _toSnakeCase(String input) {
    // Convert kebab-case to snake_case
    return input.replaceAll('-', '_');
  }

  /// Generate barrel export file for all icons
  String generateBarrelExport(List<String> iconNames) {
    final buffer = StringBuffer();
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln('// flutter_lucide_animated');
    buffer.writeln();

    for (final name in iconNames) {
      final fileName = name.replaceAll('-', '_');
      buffer.writeln("export '$fileName.g.dart';");
    }

    return buffer.toString();
  }
}
