import 'package:flutter/material.dart';
import 'package:pretty_animated_text/src/animation_config.dart';
import 'package:pretty_animated_text/src/utils/text_transformation.dart';
import 'package:pretty_animated_text/src/enums/animation_type.dart';
import 'package:pretty_animated_text/src/animated_text_controller.dart';
import 'package:pretty_animated_text/src/utils/interval_step_by_overlap_factor.dart';
import 'package:pretty_animated_text/src/utils/custom_curved_animation.dart';
import 'package:pretty_animated_text/src/utils/total_duration.dart';

/// Base widget for text animations that provides efficient animation handling.
///
/// This widget creates a Flutter [AnimationController] and attaches it to the
/// [AnimatedTextController]. The controller is the single source of truth
/// for all animation state and control logic.
class AnimatedTextBase extends StatefulWidget {
  /// The text to animate
  final String text;

  /// The style to apply to the text
  final TextStyle? style;

  /// The text alignment
  final TextAlign textAlign;

  /// The animation configuration
  final AnimationConfig config;

  /// The builder function that creates the animated text
  final Widget Function(BuildContext context,
      List<Animation<double>> animations, List<String> segments) builder;

  /// Optional external controller to control the animation.
  /// If not provided, an internal controller is created.
  final AnimatedTextController? controller;

  /// Callback when the controller is created/available.
  /// Fires in initState and whenever the callback reference changes.
  final void Function(AnimatedTextController)? onControllerCreated;

  const AnimatedTextBase({
    super.key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.start,
    required this.config,
    required this.builder,
    this.controller,
    this.onControllerCreated,
  });

  @override
  State<AnimatedTextBase> createState() => _AnimatedTextBaseState();
}

class _AnimatedTextBaseState extends State<AnimatedTextBase>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;
  late List<String> _segments;
  late AnimatedTextController _textController;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();

    // Split text into segments based on animation type
    _segments = widget.config.type == AnimationType.letter
        ? widget.text.splittedLetters.map((dto) => dto.text).toList()
        : widget.text.splittedWords.map((dto) => dto.text).toList();

    // Create the Flutter AnimationController
    final int totalDuration = getTotalDuration(
      wordCount: _segments.length,
      duration: widget.config.duration,
      overlapFactor: widget.config.overlapFactor,
    );

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: totalDuration),
      reverseDuration: Duration(milliseconds: totalDuration),
    );

    // Use external controller or create internal one
    if (widget.controller != null) {
      _textController = widget.controller!;
      _ownsController = false;
    } else {
      _textController = AnimatedTextController();
      _ownsController = true;
    }

    // Attach the Flutter AnimationController to the text controller
    _textController.attach(_controller, widget.config);

    // Notify parent about controller availability
    widget.onControllerCreated?.call(_textController);

    // Create overlapped animations for each segment
    _buildSegmentAnimations();

    // Start the initial animation
    _textController.startInitialAnimation();
  }

  void _buildSegmentAnimations() {
    final segmentCount = _segments.length;
    final intervalStep =
        intervalStepByOverlapFactor(segmentCount, widget.config.overlapFactor);

    _animations = List.generate(segmentCount, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        curvedAnimation(
          _controller,
          index,
          intervalStep,
          widget.config.overlapFactor,
          curve: Curves.easeInOut,
        ),
      );
    });
  }

  @override
  void didUpdateWidget(AnimatedTextBase oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Re-notify controller when the callback changes (e.g., page becomes current)
    if (oldWidget.onControllerCreated != widget.onControllerCreated) {
      widget.onControllerCreated?.call(_textController);
    }

    if (oldWidget.config != widget.config || oldWidget.text != widget.text) {
      _controller.duration = widget.config.duration;

      // Update the config on the controller
      _textController.updateConfig(widget.config);

      // Recreate segment animations with new configuration
      _buildSegmentAnimations();

      // Restart the animation
      _textController.startInitialAnimation();
    }
  }

  @override
  void dispose() {
    // Detach the controller (makes it inert, safe for stale references)
    _textController.detach();

    // Dispose the Flutter AnimationController
    _controller.dispose();

    // Only dispose the text controller if we own it (created internally)
    if (_ownsController) {
      _textController.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return widget.builder(context, _animations, _segments);
      },
    );
  }
}
