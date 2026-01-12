# Flutter Lucide Animated - Architecture (Post-PoC)

## Validated Approach

Based on the proof of concept, **CustomPainter + PathMetrics** is the right approach for Flutter.

---

## Animation Support Matrix

| Animation Type | Framer Motion | Flutter Implementation | Status |
|----------------|---------------|------------------------|--------|
| `pathLength` | `pathLength: [0, 1]` | `PathMetrics.extractPath()` | Validated |
| `opacity` | `opacity: [0, 1]` | `Paint.color.withAlpha()` | Validated |
| `rotate` | `rotate: 180` | `Transform.rotate` / `RotationTransition` | Validated |
| `rotate` (keyframes) | `rotate: [0, -10, 10, 0]` | `TweenSequence` | Validated |
| `translateX/Y` | `translateX: 3` | `Transform.translate` | Validated |
| `scale` | `scale: 1.2` | `Transform.scale` | Validated |
| `spring` | `stiffness: 160, damping: 17` | `Curves.elasticOut` or `SpringSimulation` | Validated |
| `pathOffset` | `pathOffset: [0, 1]` | `PathMetrics.extractPath(start, end)` | Supported |
| Path morphing | `d: ['M...', 'M...']` | Skip for v1 | Deferred |

---

## Data Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         BUILD TIME (GitHub Actions)                      │
│                                                                          │
│  pqoqubbw/icons/*.tsx ──► Parser (Node.js) ──► JSON ──► GitHub Pages    │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         CLI TIME (User's machine)                        │
│                                                                          │
│  flutter pub run flutter_lucide_animated:add flame                       │
│       │                                                                  │
│       ▼                                                                  │
│  Fetch JSON from CDN ──► Generate .g.dart ──► lib/lucide_animated/      │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         RUNTIME (User's app)                             │
│                                                                          │
│  LucideAnimatedIcon(icon: flame) ──► CustomPainter ──► Canvas           │
│                                                                          │
│  Path parsing: ONCE at startup (cached)                                  │
│  Animation: 60fps via AnimationController                                │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Core Data Models

### 1. Icon Data (Generated .g.dart)

```dart
// flame.g.dart - GENERATED CODE
import 'package:flutter_lucide_animated/flutter_lucide_animated.dart';

const flame = LucideAnimatedIconData(
  name: 'flame',
  viewBox: (0, 0, 24, 24),
  elements: [
    PathElement(
      d: 'M8.5 14.5A2.5 2.5 0 0 0 11 12c0-1.38-.5-2-1-3...',
      animation: PathLengthAnimation(
        duration: Duration(milliseconds: 400),
        delay: Duration(milliseconds: 100),
        curve: Curves.easeOut,
      ),
    ),
  ],
);
```

### 2. Animation Types

```dart
/// Base class for element animations
sealed class ElementAnimation {
  final Duration duration;
  final Duration delay;
  final Curve curve;
}

/// Stroke drawing animation (pathLength: 0 -> 1)
class PathLengthAnimation extends ElementAnimation {
  final double from; // 0.0
  final double to;   // 1.0
}

/// Opacity animation
class OpacityAnimation extends ElementAnimation {
  final double from; // 0.0
  final double to;   // 1.0
}

/// Rotation animation
class RotateAnimation extends ElementAnimation {
  final double fromDegrees;
  final double toDegrees;
  final Alignment origin; // e.g., Alignment.topCenter for bell
}

/// Keyframe rotation (shake effect)
class RotateKeyframeAnimation extends ElementAnimation {
  final List<double> keyframes; // [0, -10, 10, -10, 0]
  final Alignment origin;
}

/// Translation animation
class TranslateAnimation extends ElementAnimation {
  final double fromX, toX;
  final double fromY, toY;
}

/// Scale animation
class ScaleAnimation extends ElementAnimation {
  final double from; // 1.0
  final double to;   // 1.2
}
```

### 3. Element Types

```dart
sealed class IconElement {
  final ElementAnimation? animation;
}

class PathElement extends IconElement {
  final String d; // SVG path data
}

class CircleElement extends IconElement {
  final double cx, cy, r;
}

class RectElement extends IconElement {
  final double x, y, width, height, rx, ry;
}

class LineElement extends IconElement {
  final double x1, y1, x2, y2;
}
```

---

## Widget Architecture

### LucideAnimatedIcon Widget

```dart
class LucideAnimatedIcon extends StatefulWidget {
  final LucideAnimatedIconData icon;
  final double size;
  final Color color;
  final AnimationTrigger trigger;
  final LucideAnimatedIconController? controller;
  final VoidCallback? onTap;
  final Duration? duration; // Override default
  final Curve? curve;       // Override default

  const LucideAnimatedIcon({
    required this.icon,
    this.size = 24,
    this.color = Colors.white,
    this.trigger = AnimationTrigger.onTap,
    this.controller,
    this.onTap,
    this.duration,
    this.curve,
  });
}

enum AnimationTrigger {
  onTap,      // Animate on tap
  onHover,    // Animate on mouse enter (web/desktop)
  loop,       // Continuous loop
  manual,     // Controlled via controller
}
```

### Controller

```dart
class LucideAnimatedIconController {
  void animate();       // Play forward
  void reverse();       // Play backward
  void reset();         // Reset to start
  void stop();          // Stop animation
  bool get isAnimating;
}
```

---

## Painter Architecture

### Optimized Path Caching

```dart
/// Global cache for parsed SVG paths
class PathCache {
  static final Map<String, Path> _cache = {};

  static Path get(String svgPath) {
    return _cache.putIfAbsent(svgPath, () => _parsePath(svgPath));
  }

  static Path _parsePath(String svgPath) {
    final path = Path();
    writeSvgPathDataToPath(svgPath, FlutterPathProxy(path));
    return path;
  }
}
```

### AnimatedPathPainter

```dart
class AnimatedPathPainter extends CustomPainter {
  final Path path;           // Pre-cached
  final double progress;     // 0.0 to 1.0
  final double opacity;
  final Color color;
  final double strokeWidth;
  final double viewBoxSize;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / viewBoxSize;
    final matrix = Matrix4.diagonal3Values(scale, scale, 1.0);
    final scaledPath = path.transform(matrix.storage);

    final paint = Paint()
      ..color = color.withAlpha((opacity * 255).round())
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Extract partial path for pathLength animation
    for (final metric in scaledPath.computeMetrics()) {
      final extractedPath = metric.extractPath(0, metric.length * progress);
      canvas.drawPath(extractedPath, paint);
    }
  }
}
```

---

## JSON Format (CDN)

### registry.json

```json
{
  "version": "1.0.0",
  "updatedAt": "2026-01-12T00:00:00Z",
  "icons": ["flame", "settings", "check", "bell", "arrow_right", "copy"]
}
```

### icons/flame.json

```json
{
  "name": "flame",
  "viewBox": [0, 0, 24, 24],
  "elements": [
    {
      "type": "path",
      "d": "M8.5 14.5A2.5 2.5 0 0 0 11 12c0-1.38-.5-2-1-3...",
      "animation": {
        "type": "pathLength",
        "from": 0,
        "to": 1,
        "duration": 400,
        "delay": 100,
        "curve": "easeOut"
      }
    }
  ]
}
```

### icons/bell.json (Keyframe example)

```json
{
  "name": "bell",
  "viewBox": [0, 0, 24, 24],
  "elements": [
    {
      "type": "path",
      "d": "M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9"
    },
    {
      "type": "path",
      "d": "M10.3 21a1.94 1.94 0 0 0 3.4 0"
    }
  ],
  "animation": {
    "type": "rotateKeyframes",
    "keyframes": [0, -10, 10, -10, 0],
    "duration": 500,
    "curve": "easeInOut",
    "origin": "topCenter"
  }
}
```

### icons/copy.json (Multi-element example)

```json
{
  "name": "copy",
  "viewBox": [0, 0, 24, 24],
  "elements": [
    {
      "type": "path",
      "d": "M4 16c-1.1 0-2-.9-2-2V4c0-1.1.9-2 2-2h10c1.1 0 2 .9 2 2",
      "animation": {
        "type": "translate",
        "fromX": 0, "toX": -3,
        "fromY": 0, "toY": -3,
        "duration": 300,
        "curve": "elasticOut"
      }
    },
    {
      "type": "path",
      "d": "M8 8h10a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2H8...",
      "animation": {
        "type": "translate",
        "fromX": 0, "toX": 3,
        "fromY": 0, "toY": 3,
        "duration": 300,
        "curve": "elasticOut"
      }
    }
  ]
}
```

---

## CLI Commands

```bash
# Add icons
dart run flutter_lucide_animated:add flame check settings

# List available
dart run flutter_lucide_animated:list

# List installed
dart run flutter_lucide_animated:list --installed

# Search
dart run flutter_lucide_animated:list --search arrow

# Remove
dart run flutter_lucide_animated:remove flame

# Update all
dart run flutter_lucide_animated:update

# Custom output
dart run flutter_lucide_animated:add flame --output lib/icons
```

---

## Package Structure

```
flutter_lucide_animated/
├── bin/
│   └── flutter_lucide_animated.dart    # CLI entry
├── lib/
│   ├── flutter_lucide_animated.dart    # Public exports
│   └── src/
│       ├── models/
│       │   ├── icon_data.dart
│       │   ├── element.dart
│       │   └── animation.dart
│       ├── widgets/
│       │   ├── animated_lucide_icon.dart
│       │   └── controller.dart
│       ├── painters/
│       │   ├── path_painter.dart
│       │   └── path_cache.dart
│       └── cli/
│           ├── commands/
│           │   ├── add.dart
│           │   ├── remove.dart
│           │   ├── list.dart
│           │   └── update.dart
│           ├── fetcher.dart
│           └── generator.dart
├── pubspec.yaml
└── README.md
```

---

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  path_parsing: ^1.1.0

dev_dependencies:
  args: ^2.4.2
  http: ^1.2.0
  test: ^1.24.0
```

---

## Implementation Order

1. **Core models** - `LucideAnimatedIconData`, `ElementAnimation`, `IconElement`, etc.
2. **Path cache** - `PathCache` singleton
3. **Painters** - `AnimatedPathPainter`
4. **Widget** - `LucideAnimatedIcon` with triggers
5. **Controller** - `LucideAnimatedIconController`
6. **CLI** - `add`, `list`, `remove`, `update` commands
7. **TSX Parser** - Node.js script for GitHub Actions
8. **GitHub Actions** - Weekly sync workflow

---

## Next Steps

Ready to start implementation. Which component first?
- [ ] Core models + painters (foundation)
- [ ] CLI (developer experience)
- [ ] TSX parser (data pipeline)
