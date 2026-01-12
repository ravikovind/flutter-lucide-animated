# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-01-12

### Added
- Initial release
- 370+ animated Lucide icons
- `LucideAnimatedIcon` widget with animation support
- `LucideAnimatedIconController` for manual animation control
- Animation triggers: `onTap`, `onHover`, `loop`, `manual`
- Animation types: pathLength, opacity, rotate, translate, scale, keyframes
- CLI commands: `add`, `list`, `remove`, `update`
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
