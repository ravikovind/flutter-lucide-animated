import 'animation.dart';

/// [IconElement] is the base class for all SVG icon elements.
sealed class IconElement {
  /// Animation for this element (null if static)
  final ElementAnimation? animation;

  const IconElement({this.animation});
}

/// [PathElement] represents an SVG path element.
class PathElement extends IconElement {
  /// SVG path data (d attribute)
  final String d;

  const PathElement({required this.d, super.animation});
}

/// [CircleElement] represents an SVG circle element.
class CircleElement extends IconElement {
  /// Center X coordinate
  final double cx;

  /// Center Y coordinate
  final double cy;

  /// Circle radius
  final double r;

  const CircleElement({
    required this.cx,
    required this.cy,
    required this.r,
    super.animation,
  });
}

/// [RectElement] represents an SVG rectangle element.
class RectElement extends IconElement {
  /// X position of top-left corner
  final double x;

  /// Y position of top-left corner
  final double y;

  /// Rectangle width
  final double width;

  /// Rectangle height
  final double height;

  /// Horizontal corner radius
  final double rx;

  /// Vertical corner radius
  final double ry;

  const RectElement({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.rx = 0,
    this.ry = 0,
    super.animation,
  });
}

/// [LineElement] represents an SVG line element.
class LineElement extends IconElement {
  /// Start X coordinate
  final double x1;

  /// Start Y coordinate
  final double y1;

  /// End X coordinate
  final double x2;

  /// End Y coordinate
  final double y2;

  const LineElement({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    super.animation,
  });
}

/// [PolylineElement] represents an SVG polyline element.
class PolylineElement extends IconElement {
  /// List of points as "x1,y1 x2,y2 x3,y3..."
  final String points;

  const PolylineElement({required this.points, super.animation});
}

/// [PolygonElement] represents an SVG polygon element (closed polyline).
class PolygonElement extends IconElement {
  /// List of points as "x1,y1 x2,y2 x3,y3..."
  final String points;

  const PolygonElement({required this.points, super.animation});
}
