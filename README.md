# flutter_lucide_animated

[![pub package](https://img.shields.io/pub/v/flutter_lucide_animated.svg)](https://pub.dartlang.org/packages/flutter_lucide_animated)
[![Score](https://img.shields.io/pub/points/flutter_lucide_animated?label=Score&logo=dart)](https://pub.dartlang.org/packages/flutter_lucide_animated/score)
[![Platform](https://img.shields.io/badge/Platform-Android%20|%20iOS%20|%20Web%20|%20macOS%20|%20Windows%20|%20Linux%20-blue.svg?logo=flutter)](https://pub.dartlang.org/packages/flutter_lucide_animated)
![GitHub stars](https://img.shields.io/github/stars/ravikovind/flutter-lucide-animated)
![GitHub forks](https://img.shields.io/github/forks/ravikovind/flutter-lucide-animated)
![GitHub issues](https://img.shields.io/github/issues/ravikovind/flutter-lucide-animated)
![GitHub pull requests](https://img.shields.io/github/issues-pr/ravikovind/flutter-lucide-animated)
![GitHub contributors](https://img.shields.io/github/contributors/ravikovind/flutter-lucide-animated)
![GitHub last commit](https://img.shields.io/github/last-commit/ravikovind/flutter-lucide-animated)

A Flutter package providing **375+ beautiful animated icons** from [Lucide Animated](https://lucide-animated.com/). Each icon features smooth, carefully crafted animations including stroke drawing, rotation, translation, scale, and opacity effects.

![Lucide Animated](https://github.com/ravikovind/flutter-lucide-animated/raw/dev/screenshots/og.png)

## Live Demo

[ravikovind.github.io/flutter-lucide-animated](https://ravikovind.github.io/flutter-lucide-animated/)

## Features

- **375+ Animated Icons** - Comprehensive collection of animated Lucide icons
- **Tree Shaking** - Only include icons you actually use
- **Cross Platform** - Works on Android, iOS, Web, macOS, Windows, and Linux
- **Multiple Animation Triggers** - onTap, onHover, loop, or manual control
- **Customizable** - Control size, color, duration, and curves
- **60fps Animations** - Path caching for smooth performance

## Installation

Add `flutter_lucide_animated` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_lucide_animated: ^0.0.2
```

Then run:

```bash
flutter pub get
```

## Quick Start

1. **Import the package** in your Dart file:

```dart
import 'package:flutter_lucide_animated/flutter_lucide_animated.dart';
```

2. **Use any icon** in your widgets:

```dart
// Animate on tap (default)
LucideAnimatedIcon(icon: heart)

// Animate on hover
LucideAnimatedIcon(icon: search, trigger: AnimationTrigger.onHover)

// Continuous loop
LucideAnimatedIcon(icon: loader_pinwheel, trigger: AnimationTrigger.loop)

// Customize appearance
LucideAnimatedIcon(
  icon: bell,
  size: 48,
  color: Colors.blue,
  duration: Duration(milliseconds: 600),
)
```

## Animation Triggers

| Trigger                    | Description                                |
| -------------------------- | ------------------------------------------ |
| `AnimationTrigger.onTap`   | Animate when tapped (default)              |
| `AnimationTrigger.onHover` | Animate on mouse enter (web/desktop)       |
| `AnimationTrigger.loop`    | Continuous animation loop                  |
| `AnimationTrigger.manual`  | Control via `LucideAnimatedIconController` |

## Manual Control

```dart
final controller = LucideAnimatedIconController();

LucideAnimatedIcon(
  icon: heart,
  trigger: AnimationTrigger.manual,
  controller: controller,
)

// Control the animation
controller.animate();  // Play forward
controller.reverse();  // Play backward
controller.reset();    // Reset to start
controller.toggle();   // Toggle state
```

## Animation Types

Icons support various animation types:

- **PathLength** - Stroke drawing effect
- **Opacity** - Fade in/out
- **Rotate** - Rotation with keyframe support
- **Translate** - Position movement with keyframe support
- **Scale** - Size scaling with keyframe support
- **Combined** - Multiple animations together

## Contributing

We welcome contributions! Please see our issues page for details.

- **Bug reports**: [Open an issue](https://github.com/ravikovind/flutter-lucide-animated/issues)
- **Feature requests**: [Open an issue](https://github.com/ravikovind/flutter-lucide-animated/issues)
- **Pull requests**: [Submit a PR](https://github.com/ravikovind/flutter-lucide-animated/pulls)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Links

- **Lucide Animated**: [lucide-animated.com](https://lucide-animated.com/)
- **Lucide Icons**: [lucide.dev](https://lucide.dev/)
- **Original Animations**: [github.com/pqoqubbw/icons](https://github.com/pqoqubbw/icons)

## Maintainers

- [Ravi Kovind](https://ravikovind.github.io/) - **Available for hire!**

## Disclaimer

This is not an official Lucide package. The animated icons are based on work by [pqoqubbw/icons](https://github.com/pqoqubbw/icons). All assets are owned by their respective owners. This package is created to help the Flutter community.
