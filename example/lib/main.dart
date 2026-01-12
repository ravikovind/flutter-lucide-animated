import 'package:flutter/material.dart';
import 'package:flutter_lucide_animated/flutter_lucide_animated.dart';
import 'lucide_animated/lucide_animated.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lucide Animated - Package Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Lucide Animated')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('1. Flame - pathLength (onTap)'),
            _IconRow(
              icon: flame,
              color: Colors.orange,
              trigger: AnimationTrigger.onTap,
            ),
            const SizedBox(height: 32),

            _SectionTitle('2. Check - pathLength (onTap)'),
            _IconRow(
              icon: check,
              color: Colors.green,
              trigger: AnimationTrigger.onTap,
            ),
            const SizedBox(height: 32),

            _SectionTitle('3. Settings - rotate (onHover)'),
            _IconRow(
              icon: settings,
              color: Colors.grey.shade300,
              trigger: AnimationTrigger.onHover,
            ),
            const SizedBox(height: 32),

            _SectionTitle('4. Bell - shake keyframes (onHover)'),
            _IconRow(
              icon: bell,
              color: Colors.yellow.shade300,
              trigger: AnimationTrigger.onHover,
            ),
            const SizedBox(height: 32),

            _SectionTitle('5. Arrow Right - translate (onHover)'),
            _IconRow(
              icon: arrow_right,
              color: Colors.blue.shade300,
              trigger: AnimationTrigger.onHover,
            ),
            const SizedBox(height: 32),

            _SectionTitle('6. Copy - multi-element (onHover)'),
            _IconRow(
              icon: copy,
              color: Colors.purple.shade300,
              trigger: AnimationTrigger.onHover,
            ),
            const SizedBox(height: 32),

            _SectionTitle('7. Manual Controller'),
            const _ManualControllerDemo(),
            const SizedBox(height: 32),

            _SectionTitle('8. Loop Animation'),
            _IconRow(
              icon: settings,
              color: Colors.teal,
              trigger: AnimationTrigger.loop,
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _IconRow extends StatelessWidget {
  final LucideAnimatedIconData icon;
  final Color color;
  final AnimationTrigger trigger;

  const _IconRow({
    required this.icon,
    required this.color,
    required this.trigger,
  });

  @override
  Widget build(BuildContext context) {
    final triggerText = switch (trigger) {
      AnimationTrigger.onTap => 'Tap to animate',
      AnimationTrigger.onHover => 'Hover to animate',
      AnimationTrigger.loop => 'Looping',
      AnimationTrigger.manual => 'Manual control',
    };

    return Row(
      children: [
        LucideAnimatedIcon(
          icon: icon,
          size: 64,
          color: color,
          trigger: trigger,
        ),
        const SizedBox(width: 16),
        Text(triggerText),
      ],
    );
  }
}

class _ManualControllerDemo extends StatefulWidget {
  const _ManualControllerDemo();

  @override
  State<_ManualControllerDemo> createState() => _ManualControllerDemoState();
}

class _ManualControllerDemoState extends State<_ManualControllerDemo> {
  final _controller = LucideAnimatedIconController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        LucideAnimatedIcon(
          icon: flame,
          size: 64,
          color: Colors.red,
          trigger: AnimationTrigger.manual,
          controller: _controller,
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () => _controller.animate(),
          child: const Text('Play'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => _controller.reverse(),
          child: const Text('Reverse'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => _controller.reset(),
          child: const Text('Reset'),
        ),
      ],
    );
  }
}
