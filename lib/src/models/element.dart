import 'animation.dart';

/// Base class for all SVG icon elements
sealed class IconElement {
  /// Animation for this element (null if static)
  final ElementAnimation? animation;

  const IconElement({this.animation});
}

/// SVG path element
class PathElement extends IconElement {
  /// SVG path data (d attribute)
  final String d;

  const PathElement({
    required this.d,
    super.animation,
  });
}

/// SVG circle element
class CircleElement extends IconElement {
  final double cx;
  final double cy;
  final double r;

  const CircleElement({
    required this.cx,
    required this.cy,
    required this.r,
    super.animation,
  });
}

/// SVG rectangle element
class RectElement extends IconElement {
  final double x;
  final double y;
  final double width;
  final double height;
  final double rx;
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

/// SVG line element
class LineElement extends IconElement {
  final double x1;
  final double y1;
  final double x2;
  final double y2;

  const LineElement({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    super.animation,
  });
}

/// SVG polyline element
class PolylineElement extends IconElement {
  /// List of points as "x1,y1 x2,y2 x3,y3..."
  final String points;

  const PolylineElement({
    required this.points,
    super.animation,
  });
}
