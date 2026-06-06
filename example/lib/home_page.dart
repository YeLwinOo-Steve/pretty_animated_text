import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pretty_animated_text/pretty_animated_text.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'core/constants.dart';
import 'demos/demo_wrappers.dart';
import 'models/animation_demo_item.dart';
import 'widgets/control_button.dart';
import 'widgets/header.dart';
import 'widgets/mode_toggle_round.dart';
import 'widgets/speed_selector.dart';
import 'widgets/text_align_toggle.dart';
import 'widgets/variation_selector.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  AnimatedTextController? _currentController;
  final ValueNotifier<AnimatedTextController?> _controllerNotifier =
      ValueNotifier(null);
  final PageController _pageController = PageController();
  final Duration _pageTransitionDuration = const Duration(milliseconds: 400);
  final Curve _curve = Curves.fastOutSlowIn;

  bool _isWordMode = false;
  int _currentPage = 0;
  TextAlign _textAlign = TextAlign.start;
  int _speedIndex = 1; // 0=slow, 1=medium, 2=fast

  Duration get _letterDuration => letterDurations[_speedIndex];
  Duration get _wordDuration => wordDurations[_speedIndex];

  late final List<int> _variationIndices;
  late final List<AnimationDemoItem> _demos;

  static const _slideVariations = [
    VariationOption<SlideAnimationType>(
      icon: Icons.arrow_forward,
      value: SlideAnimationType.leftRight,
    ),
    VariationOption<SlideAnimationType>(
      icon: Icons.arrow_back,
      value: SlideAnimationType.rightLeft,
    ),
    VariationOption<SlideAnimationType>(
      icon: Icons.arrow_downward,
      value: SlideAnimationType.topBottom,
    ),
    VariationOption<SlideAnimationType>(
      icon: Icons.arrow_upward,
      value: SlideAnimationType.bottomTop,
    ),
    VariationOption<SlideAnimationType>(
      icon: Icons.swap_vert,
      value: SlideAnimationType.alternateTB,
    ),
    VariationOption<SlideAnimationType>(
      icon: Icons.swap_horiz,
      value: SlideAnimationType.alternateLR,
    ),
  ];

  static const _rotateVariations = [
    VariationOption<RotateAnimationType>(
      label: 'Clockwise',
      icon: Icons.rotate_right,
      value: RotateAnimationType.clockwise,
    ),
    VariationOption<RotateAnimationType>(
      label: 'Anti-clockwise',
      icon: Icons.rotate_left,
      value: RotateAnimationType.anticlockwise,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _demos = [
      AnimationDemoItem(
        title: 'Scale',
        buildLetter: (onCreated, _, ta, dur) => ScaleTextDemo(
            duration: dur, textAlign: ta, onControllerCreated: onCreated),
        buildWord: (onCreated, _, ta, dur) => ScaleTextDemo(
            type: AnimationType.word,
            duration: dur,
            textAlign: ta,
            onControllerCreated: onCreated),
      ),
      AnimationDemoItem(
        title: 'Slide',
        variations: _slideVariations,
        buildLetter: (onCreated, vi, ta, dur) => SlideTextDemo(
            duration: dur,
            slideType: _slideVariations[vi].value,
            textAlign: ta,
            onControllerCreated: onCreated),
        buildWord: (onCreated, vi, ta, dur) => SlideTextDemo(
            type: AnimationType.word,
            duration: dur,
            slideType: _slideVariations[vi].value,
            textAlign: ta,
            onControllerCreated: onCreated),
      ),
      AnimationDemoItem(
        title: 'Rotate',
        variations: _rotateVariations,
        buildLetter: (onCreated, vi, ta, dur) => RotateTextDemo(
            duration: dur,
            direction: _rotateVariations[vi].value,
            textAlign: ta,
            onControllerCreated: onCreated),
        buildWord: (onCreated, vi, ta, dur) => RotateTextDemo(
            type: AnimationType.word,
            duration: dur,
            direction: _rotateVariations[vi].value,
            textAlign: ta,
            onControllerCreated: onCreated),
      ),
      AnimationDemoItem(
        title: 'Chime Bell',
        buildLetter: (onCreated, _, ta, dur) => ChimeBellDemo(
            duration: dur, textAlign: ta, onControllerCreated: onCreated),
        buildWord: (onCreated, _, ta, dur) => ChimeBellDemo(
            type: AnimationType.word,
            duration: dur,
            textAlign: ta,
            onControllerCreated: onCreated),
      ),
      AnimationDemoItem(
        title: 'Spring',
        buildLetter: (onCreated, _, ta, dur) => SpringDemo(
            duration: dur, textAlign: ta, onControllerCreated: onCreated),
        buildWord: (onCreated, _, ta, dur) => SpringDemo(
            type: AnimationType.word,
            duration: dur,
            textAlign: ta,
            onControllerCreated: onCreated),
      ),
      AnimationDemoItem(
        title: 'Blur',
        buildLetter: (onCreated, _, ta, dur) => BlurTextDemo(
            duration: dur, textAlign: ta, onControllerCreated: onCreated),
        buildWord: (onCreated, _, ta, dur) => BlurTextDemo(
            type: AnimationType.word,
            duration: dur,
            textAlign: ta,
            onControllerCreated: onCreated),
      ),
      AnimationDemoItem(
        title: 'Reveal',
        buildLetter: (onCreated, _, ta, dur) => RevealTextDemo(
            duration: dur, textAlign: ta, onControllerCreated: onCreated),
        buildWord: (onCreated, _, ta, dur) => RevealTextDemo(
            type: AnimationType.word,
            duration: dur,
            textAlign: ta,
            onControllerCreated: onCreated),
      ),
      AnimationDemoItem(
        title: 'Scramble',
        buildLetter: (onCreated, _, ta, dur) => ScrambleTextDemo(
            duration: dur, textAlign: ta, onControllerCreated: onCreated),
        buildWord: (onCreated, _, ta, dur) => ScrambleTextDemo(
            type: AnimationType.word,
            duration: dur,
            textAlign: ta,
            onControllerCreated: onCreated),
      ),
      AnimationDemoItem(
        title: 'Gravity',
        buildLetter: (onCreated, _, ta, dur) => GravityTextDemo(
            duration: dur, textAlign: ta, onControllerCreated: onCreated),
        buildWord: (onCreated, _, ta, dur) => GravityTextDemo(
            type: AnimationType.word,
            duration: dur,
            textAlign: ta,
            onControllerCreated: onCreated),
      ),
    ];

    _variationIndices = List.filled(_demos.length, 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controllerNotifier.dispose();
    super.dispose();
  }

  void _handlePlay() {
    if (_currentController == null) return;
    if (_currentController!.isAnimating) return;
    if (_currentController!.isPaused || _currentController!.isRepeating) {
      _currentController!.resume();
    } else {
      _currentController!.play();
    }
  }

  void _handlePlayPause() {
    final c = _currentController;
    if (c == null) return;
    if (c.isAnimating) {
      c.pause();
    } else {
      _handlePlay();
    }
  }

  void _handleRepeat() => _currentController?.repeat();

  void _onModeChanged(bool isWord) {
    if (_isWordMode == isWord) return;
    setState(() => _isWordMode = isWord);
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleRepeat());
  }

  void _onVariationChanged(int pageIndex, int variationIndex) {
    if (_variationIndices[pageIndex] == variationIndex) return;
    setState(() => _variationIndices[pageIndex] = variationIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleRepeat());
  }

  void _onTextAlignChanged(TextAlign align) {
    if (_textAlign == align) return;
    setState(() => _textAlign = align);
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleRepeat());
  }

  void _onSpeedChanged(int index) {
    if (_speedIndex == index) return;
    setState(() => _speedIndex = index);
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleRepeat());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return SelectionArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 48.0 : 20.0,
                  vertical: 24.0,
                ),
                child: Column(
                  children: [
                    Header(colorScheme: colorScheme),
                    const SizedBox(height: 28),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (isDesktop) ...[
                            Expanded(
                              flex: 1,
                              child: _buildSideNavigation(colorScheme),
                            ),
                            const SizedBox(width: 20),
                          ],
                          Expanded(
                            flex: 3,
                            child: _buildMainContent(colorScheme, isDesktop),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Side navigation ──────────────────────────────────────────────────────

  Widget _buildSideNavigation(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: kCardShadows,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Animations',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_demos.length} types',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: _demos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final isSelected = _currentPage == index;
                final icon =
                    kDemoIcons[_demos[index].title] ?? Icons.animation_rounded;
                return InkWell(
                  onTap: () => _pageController.animateToPage(
                    index,
                    duration: _pageTransitionDuration,
                    curve: _curve,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 14),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(colors: [
                              colorScheme.primaryContainer,
                              colorScheme.primaryContainer
                                  .withValues(alpha: 0.55),
                            ])
                          : null,
                      color: isSelected ? null : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isSelected ? kNavSelectedShadows : null,
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primary.withValues(alpha: 0.12)
                                : colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Icon(
                            icon,
                            size: 16,
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _demos[index].title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.arrow_forward_ios_rounded,
                              size: 11, color: colorScheme.primary),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Main content card ────────────────────────────────────────────────────

  Widget _buildMainContent(ColorScheme colorScheme, bool isDesktop) {
    final currentDemo = _demos[_currentPage];
    final currentVariationIndex = _variationIndices[_currentPage];

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: kCardShadows,
      ),
      child: Column(
        children: [
          _buildCardHeader(colorScheme, currentDemo),
          _buildToolbar(colorScheme),
          Expanded(child: _buildCanvas()),
          _buildFooter(
              colorScheme, isDesktop, currentDemo, currentVariationIndex),
        ],
      ),
    );
  }

  // Card header: title + status chip only
  Widget _buildCardHeader(
      ColorScheme colorScheme, AnimationDemoItem currentDemo) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 14),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            transitionBuilder: (child, animation) {
              final offset = Tween<Offset>(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                  parent: animation, curve: Curves.easeOutCubic));
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(position: offset, child: child),
              );
            },
            child: Text(
              currentDemo.title,
              key: ValueKey(currentDemo.title),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
                letterSpacing: -0.4,
              ),
            ),
          ),
          const SizedBox(width: 10),
          _statusChip(colorScheme),
        ],
      ),
    );
  }

  // Toolbar shelf: all controls in one horizontal scrollable band
  Widget _buildToolbar(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.22),
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ModeToggleRound(
            isWordMode: _isWordMode,
            onChanged: _onModeChanged,
            colorScheme: colorScheme,
          ),
          SpeedSelector(
            selectedIndex: _speedIndex,
            onChanged: _onSpeedChanged,
            colorScheme: colorScheme,
          ),
          TextAlignToggle(
            selected: _textAlign,
            onChanged: _onTextAlignChanged,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  // Canvas: animation PageView with gradient background
  Widget _buildCanvas() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [kCanvasGradientA, kCanvasGradientB, kCanvasGradientA],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _currentPage = index);
          WidgetsBinding.instance.addPostFrameCallback((_) => _handleRepeat());
        },
        itemCount: _demos.length,
        itemBuilder: (context, index) {
          final demo = _demos[index];
          final isCurrentPage = index == _currentPage;
          final vi = _variationIndices[index];

          void onControllerCreated(AnimatedTextController c) {
            if (isCurrentPage && _currentController != c) {
              _currentController = c;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _controllerNotifier.value = c;
              });
            }
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Center(
              key: ValueKey(
                  '${demo.title}_${_isWordMode}_${vi}_${_textAlign}_${_speedIndex}_$isCurrentPage'),
              child: _isWordMode
                  ? demo.buildWord(
                      onControllerCreated, vi, _textAlign, _wordDuration)
                  : demo.buildLetter(
                      onControllerCreated, vi, _textAlign, _letterDuration),
            ),
          );
        },
      ),
    );
  }

  // Footer: variation selector OR page dots on left, play controls on right
  Widget _buildFooter(
    ColorScheme colorScheme,
    bool isDesktop,
    AnimationDemoItem currentDemo,
    int currentVariationIndex,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.22),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: variations if present, else page dots on mobile
          if (currentDemo.hasVariations)
            VariationSelector(
              variations: currentDemo.variations,
              selectedIndex: currentVariationIndex,
              onChanged: (i) => _onVariationChanged(_currentPage, i),
              colorScheme: colorScheme,
            )
          else if (!isDesktop)
            SmoothPageIndicator(
              controller: _pageController,
              count: _demos.length,
              effect: ExpandingDotsEffect(
                activeDotColor: colorScheme.primary,
                dotColor: colorScheme.outlineVariant,
                dotHeight: 7,
                dotWidth: 7,
                expansionFactor: 3,
              ),
              onDotClicked: (index) => _pageController.animateToPage(
                index,
                duration: _pageTransitionDuration,
                curve: _curve,
              ),
            )
          else
            const SizedBox.shrink(),
          // Right: play controls
          _buildPlayControls(colorScheme),
        ],
      ),
    );
  }

  // ── Status chip ──────────────────────────────────────────────────────────

  ValueListenableBuilder<AnimatedTextController?> _statusChip(
      ColorScheme colorScheme) {
    return ValueListenableBuilder<AnimatedTextController?>(
      valueListenable: _controllerNotifier,
      builder: (context, controller, _) {
        return ListenableBuilder(
          listenable: controller ?? ChangeNotifier(),
          builder: (context, _) {
            String statusText;
            Color chipBg;
            Color chipFg;
            IconData chipIcon;

            if (controller == null) {
              statusText = 'Stopped';
              chipBg = kStatusStoppedBg;
              chipFg = kStatusStopped;
              chipIcon = Icons.stop_circle_outlined;
            } else if (controller.isAnimating) {
              statusText = controller.repeatCount > 0
                  ? 'Repeat ${controller.repeatCount}'
                  : 'Playing';
              chipBg = kStatusPlayingBg;
              chipFg = kStatusPlaying;
              chipIcon = Icons.play_circle_outline_rounded;
            } else if (controller.isPaused) {
              statusText = 'Paused';
              chipBg = kStatusPausedBg;
              chipFg = kStatusPaused;
              chipIcon = Icons.pause_circle_outline_rounded;
            } else if (controller.isCompleted) {
              statusText = 'Completed';
              chipBg = kStatusCompleteBg;
              chipFg = kStatusComplete;
              chipIcon = Icons.check_circle_outline_rounded;
            } else {
              statusText = 'Stopped';
              chipBg = kStatusStoppedBg;
              chipFg = kStatusStopped;
              chipIcon = Icons.stop_circle_outlined;
            }

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, anim) => ScaleTransition(
                scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: Container(
                key: ValueKey(statusText),
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: chipBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(chipIcon, size: 12, color: chipFg),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: GoogleFonts.plusJakartaSans(
                        color: chipFg,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── Play controls pill ───────────────────────────────────────────────────

  Widget _buildPlayControls(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        boxShadow: kControlPillShadows,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ControlButton(
            icon: Icons.refresh_rounded,
            tooltip: 'Repeat',
            onPressed: _handleRepeat,
            colorScheme: colorScheme,
          ),
          const SizedBox(width: 4),
          ValueListenableBuilder<AnimatedTextController?>(
            valueListenable: _controllerNotifier,
            builder: (context, controller, _) {
              return ListenableBuilder(
                listenable: controller ?? ChangeNotifier(),
                builder: (context, _) {
                  final isPlaying = controller?.isAnimating ?? false;
                  return ControlButton(
                    icon: isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    tooltip: isPlaying ? 'Pause' : 'Play',
                    onPressed: _handlePlayPause,
                    colorScheme: colorScheme,
                    isPrimary: true,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
