import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_lucide_animated/flutter_lucide_animated.dart';

void main() {
  group('LucideAnimatedIconData', () {
    test('creates icon data with default values', () {
      const icon = LucideAnimatedIconData(name: 'test', elements: []);

      expect(icon.name, 'test');
      expect(icon.viewBoxWidth, 24);
      expect(icon.viewBoxHeight, 24);
      expect(icon.strokeWidth, 2);
      expect(icon.elements, isEmpty);
    });

    test('icon with path element has correct structure', () {
      const icon = LucideAnimatedIconData(
        name: 'test-path',
        elements: [
          PathElement(
            d: 'M8.5 14.5A2.5 2.5 0 0 0 11 12c0-1.38-.5-2-1-3',
            animation: PathLengthAnimation(
              from: 0,
              to: 1,
              duration: Duration(milliseconds: 400),
            ),
          ),
        ],
      );

      expect(icon.name, 'test-path');
      expect(icon.elements.length, 1);
      expect(icon.elements.first, isA<PathElement>());
    });

    test('icon with icon-level animation', () {
      const icon = LucideAnimatedIconData(
        name: 'test-rotate',
        elements: [
          PathElement(d: 'M12 2v4'),
          CircleElement(cx: 12, cy: 12, r: 3),
        ],
        animation: RotateAnimation(
          fromDegrees: 0,
          toDegrees: 180,
          duration: Duration(milliseconds: 400),
        ),
      );

      expect(icon.name, 'test-rotate');
      expect(icon.animation, isNotNull);
      expect(icon.animation, isA<RotateAnimation>());
    });

    test('icon with keyframe animation', () {
      const icon = LucideAnimatedIconData(
        name: 'test-shake',
        elements: [PathElement(d: 'M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9')],
        animation: RotateKeyframeAnimation(
          keyframes: [0, -10, 10, -10, 0],
          duration: Duration(milliseconds: 400),
        ),
      );

      expect(icon.name, 'test-shake');
      expect(icon.animation, isA<RotateKeyframeAnimation>());
    });
  });

  group('PathCache', () {
    test('caches parsed paths', () {
      const pathData = 'M0 0 L10 10';

      // First call parses
      final path1 = PathCache.get(pathData);

      // Second call returns cached
      final path2 = PathCache.get(pathData);

      expect(identical(path1, path2), isTrue);
    });

    test('clear removes all cached paths', () {
      PathCache.get('M0 0 L10 10');
      PathCache.clear();

      // After clear, new path should be created
      final path = PathCache.get('M0 0 L10 10');
      expect(path, isNotNull);
    });
  });
}
