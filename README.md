# Flutter Lucide Animated

Beautiful, customizable animated Lucide icons for Flutter.

[![pub package](https://img.shields.io/pub/v/flutter_lucide_animated.svg)](https://pub.dev/packages/flutter_lucide_animated)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

**[Live Demo](https://ravikovind.github.io/flutter-lucide-animated/)**

Bring the smooth, delightful animations from [lucide-animated](https://github.com/pqoqubbw/icons) to your Flutter apps.

## Features

- **375 animated icons** - All icons from lucide-animated
- **Multiple animation types** - pathLength, rotate, translate, scale, opacity, keyframes
- **Flexible triggers** - onTap, onHover, loop, or manual control
- **Tree-shakeable** - Only icons you import are included in your bundle
- **Customizable** - Size, color, duration, curve overrides

## Installation

```bash
flutter pub add flutter_lucide_animated
```

## Usage

```dart
import 'package:flutter_lucide_animated/flutter_lucide_animated.dart';

// Simple usage
LucideAnimatedIcon(icon: flame)

// With customization
LucideAnimatedIcon(
  icon: settings,
  size: 32,
  color: Colors.blue,
  trigger: AnimationTrigger.onHover,
)
```

## Animation Triggers

```dart
// Animate on tap
LucideAnimatedIcon(
  icon: flame,
  trigger: AnimationTrigger.onTap,
)

// Animate on hover (great for web/desktop)
LucideAnimatedIcon(
  icon: settings,
  trigger: AnimationTrigger.onHover,
)

// Continuous loop
LucideAnimatedIcon(
  icon: loader_pinwheel,
  trigger: AnimationTrigger.loop,
)

// Manual control
LucideAnimatedIcon(
  icon: check,
  trigger: AnimationTrigger.manual,
  controller: myController,
)
```

## Manual Control

```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final _controller = LucideAnimatedIconController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LucideAnimatedIcon(
          icon: flame,
          size: 64,
          color: Colors.red,
          trigger: AnimationTrigger.manual,
          controller: _controller,
        ),
        Row(
          children: [
            ElevatedButton(
              onPressed: () => _controller.animate(),
              child: Text('Play'),
            ),
            ElevatedButton(
              onPressed: () => _controller.reverse(),
              child: Text('Reverse'),
            ),
            ElevatedButton(
              onPressed: () => _controller.reset(),
              child: Text('Reset'),
            ),
          ],
        ),
      ],
    );
  }
}
```

## Customization

```dart
LucideAnimatedIcon(
  icon: bell,
  size: 48,
  color: Colors.amber,
  trigger: AnimationTrigger.onHover,
  duration: Duration(milliseconds: 600),
  curve: Curves.elasticOut,
  strokeWidth: 2.5,
  onTap: () => print('Icon tapped!'),
)
```

## Animation Types

| Type | Description | Example Icons |
|------|-------------|---------------|
| `pathLength` | Stroke drawing animation | flame, check, heart |
| `rotate` | Rotation animation | settings, refresh_cw |
| `rotateKeyframe` | Keyframe rotation (shake) | bell, vibrate |
| `translate` | Position animation | arrow_right, copy |
| `scale` | Scale animation | plus, play |
| `opacity` | Fade animation | eye, eye_off |
| `combined` | Multiple animations | flame (pathLength + opacity) |

## Available Icons

375 icons available including:

- **Actions**: check, x, plus, minus, copy, download, upload
- **Arrows**: arrow_right, arrow_left, arrow_up, arrow_down, chevron_*
- **Communication**: bell, mail_check, message_circle, message_square
- **Device**: smartphone_*, battery_*, bluetooth_*, wifi
- **Media**: play, volume, mic, mic_off
- **Navigation**: menu, home, search, settings
- **Social**: github, twitter, instagram, linkedin, youtube
- **Weather**: sun, moon, cloud_*, snowflake

## For Package Maintainers

To update icons when upstream changes:

```bash
cd scripts
npm install
node sync.js
```

This regenerates all Dart files from [pqoqubbw/icons](https://github.com/pqoqubbw/icons).

## Credits

- Icons and animations from [pqoqubbw/icons](https://github.com/pqoqubbw/icons)
- Original icon designs from [Lucide](https://lucide.dev)

## License

MIT License - see [LICENSE](LICENSE) for details.
