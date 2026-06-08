import 'package:flutter/material.dart';
import 'package:pretty_animated_text/src/animation_config.dart';

/// A controller for animated text widgets
///
/// - The widget creates a Flutter [AnimationController] and attaches it
/// - External code (e.g. parent widget) controls animations via
///   [play], [pause], [resume], [repeat], [restart], [reverse]
/// - When the widget is disposed, it detaches the animation controller
class AnimatedTextController with ChangeNotifier {
  AnimationController? _animationController;
  AnimationConfig? _config;
  int _repeatCount = 0;
  bool _isReversing = false;
  bool _isRepeating = false;
  bool _hasPlayedOnce = false;
  bool _isDisposed = false;

  void Function(AnimationStatus)? _statusCallback;
  void Function(double)? _progressCallback;

  /// Current progress of the animation (0.0 to 1.0)
  double get progress => _animationController?.value ?? 0.0;

  /// Current repeat count
  int get repeatCount => _repeatCount;

  /// Whether the animation is currently animating
  bool get isAnimating => _animationController?.isAnimating ?? false;

  /// Whether the animation is paused (stopped mid-way)
  bool get isPaused => !isAnimating && progress > 0.0 && progress < 1.0;

  /// Whether the animation is currently repeating
  bool get isRepeating => _isRepeating;

  /// Whether the animation has completed
  bool get isCompleted =>
      _animationController?.status == AnimationStatus.completed;

  /// Whether the animation is dismissed
  bool get isDismissed =>
      _animationController?.status == AnimationStatus.dismissed;

  /// Current status of the animation
  AnimationStatus? get status => _animationController?.status;

  /// Whether this controller is attached to an [AnimationController]
  bool get isAttached => _animationController != null && !_isDisposed;

  /// Attach a Flutter [AnimationController] and [AnimationConfig] to this
  /// controller. Called by the widget's State in initState.
  void attach(AnimationController controller, AnimationConfig config) {
    detach();
    _animationController = controller;
    _config = config;
    _animationController!.addStatusListener(_handleAnimationStatus);
    _animationController!.addListener(_handleProgressChange);
  }

  /// Detach the current [AnimationController]. Called by the widget's State
  /// in dispose. After this, all control methods become no-ops.
  void detach() {
    if (_animationController != null) {
      _animationController!.removeStatusListener(_handleAnimationStatus);
      _animationController!.removeListener(_handleProgressChange);
      _animationController = null;
    }
    _config = null;
  }

  /// Update the [AnimationConfig] without detaching.
  /// Called on [didUpdateWidget] when the config changes.
  void updateConfig(AnimationConfig config) {
    _config = config;
  }

  /// Play the animation from the beginning (resets state).
  void play() {
    if (!isAttached) return;
    _repeatCount = 0;
    _isReversing = false;
    _hasPlayedOnce = false;
    _isRepeating = false;
    _animationController!.reset();
    _animationController!.forward();
    notifyListeners();
  }

  /// Pause (stop) the animation at the current position.
  void pause() {
    if (!isAttached) return;
    _animationController!.stop();
    _config?.onPause?.call(this);
    notifyListeners();
  }

  /// Resume the animation from the current position.
  /// Preserves repeat/reverse state.
  void resume() {
    if (!isAttached) return;
    if (_isReversing) {
      _animationController!.reverse();
    } else {
      _animationController!.forward();
    }
    _config?.onResume?.call(this);
    notifyListeners();
  }

  /// Reverse the animation direction.
  void reverse() {
    if (!isAttached) return;
    if (_animationController!.value == 0.0) {
      _animationController!.forward();
    } else {
      _isReversing = true;
      _animationController!.reverse();
    }
    notifyListeners();
  }

  /// Restart the animation from the beginning.
  void restart() {
    if (!isAttached) return;
    _repeatCount = 0;
    _isReversing = false;
    _hasPlayedOnce = false;
    _isRepeating = false;
    _animationController!.reset();
    Future.delayed(const Duration(milliseconds: 10), () {
      if (isAttached) {
        _animationController!.forward();
      }
    });
  }

  /// Start repeating the animation. Honors [AnimationConfig.repeatCount].
  void repeat({bool reverse = false}) {
    if (!isAttached) return;
    _repeatCount = 0;
    _isReversing = false;
    _hasPlayedOnce = false;
    _isRepeating = true;
    _animationController!.reset();
    _animationController!.forward();
    notifyListeners();
  }

  /// Start the initial animation (called internally after attach).
  /// Respects [AnimationConfig.delay].
  void startInitialAnimation() {
    if (!isAttached) return;
    _repeatCount = 0;
    _isReversing = false;
    _hasPlayedOnce = false;
    _isRepeating = false;

    final delay = _config?.delay ?? Duration.zero;
    if (delay > Duration.zero) {
      Future.delayed(delay, () {
        if (isAttached) {
          _animationController!.forward();
        }
      });
    } else {
      _animationController!.forward();
    }
    notifyListeners();
  }

  /// Set a callback for animation status changes
  set onStatusChange(void Function(AnimationStatus) callback) =>
      _statusCallback = callback;

  /// Set a callback for animation progress changes
  set onProgressChange(void Function(double) callback) =>
      _progressCallback = callback;

  void _handleAnimationStatus(AnimationStatus status) {
    // Forward external listener
    _statusCallback?.call(status);

    switch (status) {
      case AnimationStatus.forward:
        if (!_hasPlayedOnce) {
          _hasPlayedOnce = true;
          _config?.onPlay?.call(this);
        }
        break;
      case AnimationStatus.completed:
        _config?.onComplete?.call(this);
        if (_config?.reverse == true && !_isReversing) {
          _isReversing = true;
          _animationController?.reverse();
        } else if (_isRepeating || _config?.repeat == true) {
          _handleRepeat();
        }
        break;
      case AnimationStatus.dismissed:
        _config?.onDismissed?.call(this);
        if (_config?.reverse == true) {
          _isReversing = false;
          if (_isRepeating || _config?.repeat == true) {
            _handleRepeat();
          }
        }
        break;
      case AnimationStatus.reverse:
        break;
    }
    notifyListeners();
  }

  void _handleRepeat() {
    if (_config?.repeatCount != null) {
      _repeatCount++;
      if (_repeatCount >= _config!.repeatCount!) {
        _isRepeating = false;
        return;
      }
    }

    _config?.onRepeat?.call(this, _repeatCount);

    final repeatDelay = _config?.repeatDelay ?? Duration.zero;
    if (repeatDelay > Duration.zero) {
      Future.delayed(repeatDelay, () {
        if (isAttached) {
          _animationController!.reset();
          _animationController!.forward();
        }
      });
    } else if (isAttached) {
      _animationController!.reset();
      _animationController!.forward();
    }
    notifyListeners();
  }

  void _handleProgressChange() {
    _progressCallback?.call(progress);
  }

  /// Dispose the controller. After this, the controller should not be used.
  @override
  void dispose() {
    detach();
    _progressCallback = null;
    _isDisposed = true;
    super.dispose();
  }
}
