import 'package:flutter/widgets.dart';

/// [LucideAnimatedIconController] provides manual control over icon animations.
///
/// Use with [AnimationTrigger.manual] for programmatic animation control.
class LucideAnimatedIconController extends ChangeNotifier {
  AnimationController? _animationController;
  bool _isAnimating = false;

  /// Whether the animation is currently running
  bool get isAnimating => _isAnimating;

  /// Current animation value (0.0 to 1.0)
  double get value => _animationController?.value ?? 0.0;

  /// Attach an AnimationController (called internally by LucideAnimatedIcon)
  void attach(AnimationController controller) {
    _animationController = controller;
    _animationController?.addStatusListener(_onStatusChanged);
  }

  /// Detach the AnimationController (called internally)
  void detach() {
    _animationController?.removeStatusListener(_onStatusChanged);
    _animationController = null;
  }

  void _onStatusChanged(AnimationStatus status) {
    final wasAnimating = _isAnimating;
    _isAnimating =
        status == AnimationStatus.forward || status == AnimationStatus.reverse;
    if (wasAnimating != _isAnimating) {
      notifyListeners();
    }
  }

  /// Play the animation forward
  void animate() {
    _animationController?.forward(from: 0.0);
  }

  /// Play the animation in reverse
  void reverse() {
    _animationController?.reverse();
  }

  /// Reset the animation to the fully visible state
  void reset() {
    _animationController?.value = 1.0;
    notifyListeners();
  }

  /// Stop the animation at current position
  void stop() {
    _animationController?.stop();
    _isAnimating = false;
    notifyListeners();
  }

  /// Toggle animation (play if stopped, reverse if completed)
  void toggle() {
    if (_animationController == null) return;

    if (_animationController!.status == AnimationStatus.completed) {
      _animationController!.reverse();
    } else if (_animationController!.status == AnimationStatus.dismissed) {
      _animationController!.forward();
    } else if (_animationController!.isAnimating) {
      _animationController!.stop();
    } else {
      _animationController!.forward();
    }
  }

  @override
  void dispose() {
    detach();
    super.dispose();
  }
}
