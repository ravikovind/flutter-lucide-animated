# Flutter Lucide Animated - Final Plan

## Overview

A Flutter package that brings pqoqubbw/lucide-animated icons to Flutter with a CLI for on-demand icon fetching and a widget for rendering animations.

---

## Architecture

```
┌────────────────────────────────────────────────────────────────────┐
│                         SYNC PIPELINE                              │
│                     (GitHub Actions - Weekly)                      │
│                                                                    │
│  pqoqubbw/icons/*.tsx ──► Parser ──► JSON ──► GitHub Pages CDN    │
└────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌────────────────────────────────────────────────────────────────────┐
│                        GITHUB PAGES CDN                            │
│           ravikovind.github.io/flutter-lucide-animated/            │
│                                                                    │
│  /v1/registry.json          (icon list + metadata)                 │
│  /v1/icons/flame.json       (full animation data)                  │
│  /v1/icons/settings.json                                           │
│  /v1/icons/...                                                     │
└────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌────────────────────────────────────────────────────────────────────┐
│                      FLUTTER PACKAGE                               │
│                   flutter_lucide_animated                          │
│                                                                    │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────────┐ │
│  │    CLI      │  │   Widget    │  │     Animation Engine        │ │
│  │             │  │             │  │                             │ │
│  │ • add       │  │ Animated    │  │ • Path drawing (pathLength) │ │
│  │ • remove    │  │ LucideIcon  │  │ • Opacity                   │ │
│  │ • list      │  │             │  │ • Scale / Rotate            │ │
│  │ • update    │  │             │  │ • Staggered animations      │ │
│  └─────────────┘  └─────────────┘  └─────────────────────────────┘ │
└────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌────────────────────────────────────────────────────────────────────┐
│                       USER'S PROJECT                               │
│                                                                    │
│  lib/                                                              │
│  └── lucide_animated/                                              │
│      ├── icons/                                                    │
│      │   ├── flame.g.dart         (generated)                      │
│      │   ├── settings.g.dart      (generated)                      │
│      │   └── home.g.dart          (generated)                      │
│      └── lucide_animated.g.dart   (barrel export)                  │
└────────────────────────────────────────────────────────────────────┘
```

---

## Repository Structure

```
flutter-lucide-animated/
├── .github/
│   └── workflows/
│       └── sync.yml                 # Weekly sync from pqoqubbw/icons
│
├── docs/                            # GitHub Pages (CDN)
│   └── v1/
│       ├── registry.json
│       └── icons/
│           ├── flame.json
│           ├── settings.json
│           └── ...
│
├── scripts/
│   └── sync.js                      # TSX → JSON parser
│
├── packages/
│   └── flutter_lucide_animated/     # The Flutter package
│       ├── bin/
│       │   └── flutter_lucide_animated.dart   # CLI entry point
│       ├── lib/
│       │   ├── flutter_lucide_animated.dart   # Public API
│       │   └── src/
│       │       ├── cli/
│       │       │   ├── commands/
│       │       │   │   ├── add.dart
│       │       │   │   ├── remove.dart
│       │       │   │   ├── list.dart
│       │       │   │   └── update.dart
│       │       │   ├── generator.dart         # Dart code generator
│       │       │   └── fetcher.dart           # CDN client
│       │       ├── models/
│       │       │   ├── icon_data.dart
│       │       │   ├── animation_data.dart
│       │       │   └── path_data.dart
│       │       ├── widgets/
│       │       │   └── animated_lucide_icon.dart
│       │       └── painters/
│       │           └── animated_path_painter.dart
│       ├── pubspec.yaml
│       └── README.md
│
└── README.md
```

---

## Data Models

### CDN: registry.json
```json
{
  "version": "1.0.0",
  "updated_at": "2026-01-11T00:00:00Z",
  "total": 350,
  "icons": [
    "a-arrow-down",
    "a-arrow-up",
    "flame",
    "settings",
    "home"
  ]
}
```

### CDN: icons/flame.json
```json
{
  "name": "flame",
  "viewBox": "0 0 24 24",
  "strokeWidth": 2,
  "strokeLinecap": "round",
  "strokeLinejoin": "round",
  "elements": [
    {
      "type": "path",
      "d": "M8.5 14.5A2.5 2.5 0 0 0 11 12c0-1.38-.5-2-1-3-1.072-2.143-.224-4.054 2-6 .5 2.5 2 4.9 4 6.5 2 1.6 3 3.5 3 5.5a7 7 0 1 1-14 0c0-1.153.433-2.294 1-3a2.5 2.5 0 0 0 2.5 2.5z",
      "animations": {
        "normal": {
          "pathLength": 1,
          "opacity": 1
        },
        "animate": {
          "pathLength": [0, 1],
          "opacity": [0, 1],
          "transition": {
            "duration": 400,
            "delay": 100,
            "easing": "easeOut"
          }
        }
      }
    }
  ]
}
```

### Dart: Generated icon file
```dart
// GENERATED CODE - DO NOT MODIFY BY HAND
// flutter_lucide_animated v1.0.0

import 'package:flutter_lucide_animated/flutter_lucide_animated.dart';

const flameIcon = LucideAnimatedIconData(
  name: 'flame',
  viewBox: ViewBox(0, 0, 24, 24),
  elements: [
    AnimatedPathElement(
      d: 'M8.5 14.5A2.5 2.5 0 0 0 11 12c0-1.38-.5-2-1-3-1.072-2.143-.224-4.054 2-6 .5 2.5 2 4.9 4 6.5 2 1.6 3 3.5 3 5.5a7 7 0 1 1-14 0c0-1.153.433-2.294 1-3a2.5 2.5 0 0 0 2.5 2.5z',
      animation: PathAnimation(
        property: AnimatedProperty.pathLength,
        from: 0.0,
        to: 1.0,
        duration: Duration(milliseconds: 400),
        delay: Duration(milliseconds: 100),
        curve: Curves.easeOut,
      ),
    ),
  ],
);
```

---

## CLI Commands

```bash
# Add icons (fetches from CDN, generates .g.dart files)
dart run flutter_lucide_animated:add flame settings home

# List all available icons
dart run flutter_lucide_animated:list

# List installed icons in current project
dart run flutter_lucide_animated:list --installed

# Search icons
dart run flutter_lucide_animated:list --search arrow

# Remove icons
dart run flutter_lucide_animated:remove flame

# Update all installed icons to latest
dart run flutter_lucide_animated:update

# Add all icons (warns about size)
dart run flutter_lucide_animated:add --all

# Specify output directory
dart run flutter_lucide_animated:add flame --output lib/icons
```

---

## Widget API

```dart
import 'package:flutter_lucide_animated/flutter_lucide_animated.dart';
import 'package:your_app/lucide_animated/icons/flame.g.dart';

// Basic usage
AnimatedLucideIcon(
  icon: flameIcon,
  size: 24,
  color: Colors.orange,
)

// With trigger
AnimatedLucideIcon(
  icon: flameIcon,
  size: 32,
  color: Colors.red,
  trigger: AnimationTrigger.onTap,      // onHover, onTap, loop, manual
  onTap: () => print('tapped'),
)

// Manual control
class _MyWidgetState extends State<MyWidget> {
  final _controller = AnimatedLucideIconController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedLucideIcon(
          icon: flameIcon,
          controller: _controller,
          trigger: AnimationTrigger.manual,
        ),
        ElevatedButton(
          onPressed: () => _controller.animate(),
          child: Text('Play'),
        ),
      ],
    );
  }
}

// Loop with custom duration
AnimatedLucideIcon(
  icon: settingsIcon,
  trigger: AnimationTrigger.loop,
  duration: Duration(milliseconds: 800),
  curve: Curves.easeInOut,
)
```

---

## Animation Properties Supported

| Property | Description | Flutter Implementation |
|----------|-------------|------------------------|
| `pathLength` | Stroke drawing animation | `CustomPainter` + `PathMetrics.extractPath()` |
| `pathOffset` | Stroke offset animation | `CustomPainter` + `PathMetrics` |
| `opacity` | Fade in/out | `Opacity` / `FadeTransition` |
| `scale` | Scale transform | `Transform.scale` / `ScaleTransition` |
| `rotate` | Rotation transform | `Transform.rotate` / `RotationTransition` |
| `translateX/Y` | Position transform | `Transform.translate` |
| `stagger` | Delayed child animations | `Interval` curves per element |

---

## Implementation Phases

### Phase 1: Foundation (Week 1)
- [ ] Set up repository structure
- [ ] Create TSX → JSON parser script
- [ ] Set up GitHub Pages + Actions for sync
- [ ] Parse 10-20 icons as test

### Phase 2: Core Package (Week 2)
- [ ] Data models (`LucideAnimatedIconData`, `AnimatedPathElement`, etc.)
- [ ] `AnimatedPathPainter` (CustomPainter for pathLength)
- [ ] `AnimatedLucideIcon` widget with basic triggers
- [ ] Animation controller

### Phase 3: CLI (Week 3)
- [ ] CLI scaffolding with `args` package
- [ ] `add` command - fetch + generate
- [ ] `list` command
- [ ] `remove` command
- [ ] `update` command
- [ ] Local caching (~/.flutter_lucide_animated/cache/)

### Phase 4: Polish (Week 4)
- [ ] Full icon sync (all 350)
- [ ] Error handling + helpful messages
- [ ] Documentation + examples
- [ ] Publish to pub.dev
- [ ] Example app

---

## Dependencies

```yaml
# pubspec.yaml
name: flutter_lucide_animated
description: Animated Lucide icons for Flutter with CLI support

dependencies:
  flutter:
    sdk: flutter
  path_parsing: ^1.0.1        # SVG path parsing
  http: ^1.2.0                # CDN fetching (CLI only)

dev_dependencies:
  args: ^2.4.2                # CLI argument parsing
  test: ^1.24.0
```

---

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| pqoqubbw changes TSX format | Versioned parser, pin to known commit |
| License ambiguity on animations | Reach out to @pqoqubbw for blessing |
| GitHub Pages downtime | Bundle fallback registry in package |
| Complex animations not mapping 1:1 | Start with simple icons, expand coverage |
| CLI conflicts with existing files | Check before overwrite, `--force` flag |

---

## Success Metrics

- [ ] 350 icons available
- [ ] <100ms icon generation time
- [ ] <2MB total CDN size
- [ ] Works offline after first fetch (caching)
- [ ] 90%+ animation fidelity vs React version
