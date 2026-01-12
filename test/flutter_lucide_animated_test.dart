import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_lucide_animated/flutter_lucide_animated.dart';

void main() {
  group('LucideAnimatedIconData', () {
    test('creates icon data with default values', () {
      const icon = LucideAnimatedIconData(
        name: 'test',
        elements: [],
      );

      expect(icon.name, 'test');
      expect(icon.viewBoxWidth, 24);
      expect(icon.viewBoxHeight, 24);
      expect(icon.strokeWidth, 2);
      expect(icon.elements, isEmpty);
    });

    test('sample flame icon has correct structure', () {
      expect(flame.name, 'flame');
      expect(flame.elements.length, 1);
      expect(flame.elements.first, isA<PathElement>());
    });

    test('sample settings icon has icon-level animation', () {
      expect(settings.name, 'settings');
      expect(settings.animation, isNotNull);
      expect(settings.animation, isA<RotateAnimation>());
    });

    test('sample bell icon has keyframe animation', () {
      expect(bell.name, 'bell');
      expect(bell.animation, isA<RotateKeyframeAnimation>());
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
