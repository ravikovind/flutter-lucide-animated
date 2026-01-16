# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.4] - 2026-01-16

### Added
- `PathLengthKeyframeAnimation` for keyframe-based stroke animations
- Responsive example app with adaptive grid layout

### Fixed
- Fixed fingerprint icon animation (now uses full keyframe sequence)
- Fixed sync.js to properly handle pathLength keyframe arrays

## [0.0.3] - 2026-01-15

### Fixed
- Fixed screenshot URL in README

## [0.0.2] - 2026-01-15

### Changed
- Simplified package structure: all 375 icons in single `icons.dart` file
- Updated documentation with `[ClassName]` doc comment style
- Improved README with badges and cleaner format
- Homepage updated to [lucide-animated.com](https://lucide-animated.com/)

### Added
- Screenshot for pub.dev listing

## [0.0.1] - 2026-01-15

### Added
- Initial release
- 375 animated Lucide icons (tree-shakeable)
- `LucideAnimatedIcon` widget with animation support
- `LucideAnimatedIconController` for manual animation control
- Animation triggers: `onTap`, `onHover`, `loop`, `manual`
- Path caching for smooth 60fps animations
- RepaintBoundary for optimized rendering

### Animation Types Supported
- `PathLengthAnimation` - Stroke drawing effect
- `OpacityAnimation` - Fade in/out
- `RotateAnimation` - Rotation transform
- `RotateKeyframeAnimation` - Keyframe-based rotation (shake effect)
- `TranslateAnimation` - Position transform
- `TranslateKeyframeAnimation` - Keyframe-based position
- `ScaleAnimation` - Scale transform
- `CombinedAnimation` - Multiple animations combined

### SVG Elements Supported
- Path, Circle, Rect, Line, Polyline, Polygon
