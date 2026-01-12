import 'package:flutter/widgets.dart';
import 'animation.dart';
import 'element.dart';

/// Data class representing an animated Lucide icon
class LucideAnimatedIconData {
  /// Icon name (e.g., 'flame', 'arrow_right')
  final String name;

  /// SVG viewBox dimensions
  final double viewBoxWidth;
  final double viewBoxHeight;

  /// Default stroke width
  final double strokeWidth;

  /// SVG elements that make up the icon
  final List<IconElement> elements;

  /// Icon-level animation (applies to entire icon, e.g., rotation)
  final ElementAnimation? animation;

  const LucideAnimatedIconData({
    required this.name,
    this.viewBoxWidth = 24,
    this.viewBoxHeight = 24,
    this.strokeWidth = 2,
    required this.elements,
    this.animation,
  });

  /// ViewBox as Rect for convenience
  Rect get viewBox => Rect.fromLTWH(0, 0, viewBoxWidth, viewBoxHeight);
}

/// Animation trigger modes
enum AnimationTrigger {
  /// Animate on tap
  onTap,

  /// Animate on mouse enter (web/desktop)
  onHover,

  /// Continuous loop animation
  loop,

  /// Manual control via controller
  manual,
}
