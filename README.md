# Flutter Lucide Animated

Beautiful, customizable animated Lucide icons for Flutter with on-demand CLI fetching.

[![pub package](https://img.shields.io/pub/v/flutter_lucide_animated.svg)](https://pub.dev/packages/flutter_lucide_animated)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

**[Live Demo](https://ravikovind.github.io/flutter-lucide-animated/)**

Bring the smooth, delightful animations from [lucide-animated](https://github.com/pqoqubbw/icons) to your Flutter apps. 370+ animated icons with multiple animation types and triggers.

## Features

- **370+ animated icons** - All icons from lucide-animated
- **Multiple animation types** - pathLength (stroke drawing), rotate, translate, scale, opacity, keyframes
- **Flexible triggers** - onTap, onHover, loop, or manual control
- **On-demand fetching** - Only add the icons you need via CLI
- **Tree-shakeable** - Generated code, no unused icons in your bundle
- **Customizable** - Size, color, duration, curve overrides

## Installation

```bash
flutter pub add flutter_lucide_animated
```

## Quick Start

### 1. Add icons to your project

```bash
# Add specific icons
dart run flutter_lucide_animated add flame settings bell

# Search available icons
dart run flutter_lucide_animated list --search arrow

# Add all icons (370+)
dart run flutter_lucide_animated add --all
```

### 2. Use in your app

```dart
import 'package:flutter/material.dart';
import 'package:flutter_lucide_animated/flutter_lucide_animated.dart';
import 'lucide_animated/lucide_animated.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LucideAnimatedIcon(
      icon: flame,
      size: 32,
      color: Colors.orange,
      trigger: AnimationTrigger.onTap,
    );
  }
}
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
  // Override animation duration
  duration: Duration(milliseconds: 600),
  // Override animation curve
  curve: Curves.elasticOut,
  // Override stroke width
  strokeWidth: 2.5,
  // Callback on tap
  onTap: () => print('Icon tapped!'),
)
```

## CLI Commands

```bash
# Add icons (generates .g.dart files)
dart run flutter_lucide_animated add flame settings home

# List all available icons
dart run flutter_lucide_animated list

# Search icons
dart run flutter_lucide_animated list --search arrow

# List installed icons
dart run flutter_lucide_animated list --installed

# Remove icons
dart run flutter_lucide_animated remove flame

# Update installed icons to latest
dart run flutter_lucide_animated update

# Custom output directory
dart run flutter_lucide_animated add flame --output lib/icons
```

## Animation Types

| Type | Description | Example Icons |
|------|-------------|---------------|
| `pathLength` | Stroke drawing animation | flame, check, heart |
| `rotate` | Rotation animation | settings, refresh-cw |
| `rotateKeyframe` | Keyframe rotation (shake) | bell, vibrate |
| `translate` | Position animation | arrow-right, copy |
| `translateKeyframe` | Keyframe position | arrow-right |
| `scale` | Scale animation | plus, minus |
| `opacity` | Fade animation | eye, eye-off |
| `combined` | Multiple animations | flame (pathLength + opacity) |

## Available Icons

370+ icons available. Run `dart run flutter_lucide_animated list` to see all.

Popular icons include:
- **Actions**: check, x, plus, minus, copy, download, upload
- **Arrows**: arrow-right, arrow-left, arrow-up, arrow-down, chevron-*
- **Communication**: bell, mail-check, message-circle, message-square
- **Device**: smartphone-*, battery-*, bluetooth-*, wifi
- **Media**: play, volume, mic, mic-off
- **Navigation**: menu, home, search, settings
- **Social**: github, twitter, instagram, linkedin, youtube
- **Weather**: sun, moon, cloud-*, snowflake

## How It Works

1. **CDN**: Icon animation data is hosted on GitHub Pages
2. **CLI**: Fetches icon data and generates Dart code
3. **Widget**: Renders animations using CustomPainter + AnimationController
4. **Caching**: Path parsing is cached for smooth 60fps animations

## Development

### Build Docs (Example + Icons CDN)

```bash
# Build example for GitHub Pages
./scripts/build-docs.sh

# Sync icons from pqoqubbw/icons and build example
./scripts/build-docs.sh --sync

# Only sync icons (no example build)
./scripts/build-docs.sh --sync --no-example
```

### Sync Icons Only

```bash
cd scripts
npm install
node sync.js           # Sync all icons
node sync.js --limit 20  # Test with first 20 icons
```

## Credits

- Icons and animations from [pqoqubbw/icons](https://github.com/pqoqubbw/icons)
- Original icon designs from [Lucide](https://lucide.dev)

## License

MIT License - see [LICENSE](LICENSE) for details.
