import 'package:flutter/material.dart';
import 'package:pretty_animated_text/pretty_animated_text.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'core/constants.dart';
import 'demos/demo_wrappers.dart';
import 'models/animation_demo_item.dart';
import 'widgets/control_button.dart';
import 'widgets/header.dart';
import 'widgets/mode_toggle_round.dart';
import 'widgets/variation_selector.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  AnimatedTextController? _currentController;
  final PageController _pageController = PageController();
  final Duration _pageTransitionDuration = const Duration(milliseconds: 400);
  final Curve _curve = Curves.fastOutSlowIn;

  bool _isWordMode = false;
  int _currentPage = 0;

  /// Tracks the selected variation index for each demo page.
  late final List<int> _variationIndices;

  late final List<AnimationDemoItem> _demos;

  // ─── Slide variation options ───────────────────────────────────────
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

  // ─── Rotate variation options ──────────────────────────────────────
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
        buildLetter: (onCreated, _) =>
            ScaleTextDemo(onControllerCreated: onCreated),
        buildWord: (onCreated, _) => ScaleTextDemo(
            type: AnimationType.word,
            duration: wordAnimationDuration,
            onControllerCreated: onCreated),
      ),
      AnimationDemoItem(
        title: 'Slide',
        variations: _slideVariations,
        buildLetter: (onCreated, vi) => SlideTextDemo(
            slideType: _slideVariations[vi].value,
            onControllerCreated: onCreated),
        buildWord: (onCreated, vi) => SlideTextDemo(
            type: AnimationType.word,
            duration: wordAnimationDuration,
            slideType: _slideVariations[vi].value,
            onControllerCreated: onCreated),
      ),
      AnimationDemoItem(
        title: 'Rotate',
        variations: _rotateVariations,
        buildLetter: (onCreated, vi) => RotateTextDemo(
            direction: _rotateVariations[vi].value,
            onControllerCreated: onCreated),
        buildWord: (onCreated, vi) => RotateTextDemo(
            type: AnimationType.word,
            duration: wordAnimationDuration,
            direction: _rotateVariations[vi].value,
            onControllerCreated: onCreated),
      ),
      AnimationDemoItem(
        title: 'Chime Bell',
        buildLetter: (onCreated, _) =>
            ChimeBellDemo(onControllerCreated: onCreated),
        buildWord: (onCreated, _) => ChimeBellDemo(
            type: AnimationType.word,
            duration: wordAnimationDuration,
            onControllerCreated: onCreated),
      ),
      AnimationDemoItem(
        title: 'Spring',
        buildLetter: (onCreated, _) =>
            SpringDemo(onControllerCreated: onCreated),
        buildWord: (onCreated, _) => SpringDemo(
            type: AnimationType.word,
            duration: wordAnimationDuration,
            onControllerCreated: onCreated),
      ),
      AnimationDemoItem(
        title: 'Blur',
        buildLetter: (onCreated, _) =>
            BlurTextDemo(onControllerCreated: onCreated),
        buildWord: (onCreated, _) => BlurTextDemo(
            type: AnimationType.word,
            duration: wordAnimationDuration,
            onControllerCreated: onCreated),
      ),
    ];

    _variationIndices = List.filled(_demos.length, 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handlePlay() => _currentController?.play();
  void _handlePause() => _currentController?.pause();
  void _handleRepeat() => _currentController?.repeat();

  void _onModeChanged(bool isWord) {
    if (_isWordMode == isWord) return;
    setState(() {
      _isWordMode = isWord;
    });
    // Give time for widget to build and controller to be registered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleRepeat();
    });
  }

  void _onVariationChanged(int pageIndex, int variationIndex) {
    if (_variationIndices[pageIndex] == variationIndex) return;
    setState(() {
      _variationIndices[pageIndex] = variationIndex;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleRepeat();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return SelectionArea(
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 48.0 : 24.0,
                  vertical: 24.0,
                ),
                child: Column(
                  children: [
                    Header(colorScheme: colorScheme),
                    const SizedBox(height: 32),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (isDesktop) ...[
                            Expanded(
                                flex: 1,
                                child: _buildSideNavigation(colorScheme)),
                            const SizedBox(width: 32),
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

  Widget _buildSideNavigation(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Animations',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: _demos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final isSelected = _currentPage == index;
                return InkWell(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: _pageTransitionDuration,
                      curve: _curve,
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primaryContainer
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary.withValues(alpha: 0.3)
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _demos[index].title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.arrow_forward_ios,
                              size: 14, color: colorScheme.primary),
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

  Widget _buildMainContent(ColorScheme colorScheme, bool isDesktop) {
    final currentDemo = _demos[_currentPage];
    final currentVariationIndex = _variationIndices[_currentPage];

    return Column(
      children: [
        Expanded(
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              currentDemo.title,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ModeToggleRound(
                        isWordMode: _isWordMode,
                        onChanged: _onModeChanged,
                        colorScheme: colorScheme,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _handleRepeat();
                      });
                    },
                    itemCount: _demos.length,
                    itemBuilder: (context, index) {
                      final demo = _demos[index];
                      final isCurrentPage = index == _currentPage;
                      final vi = _variationIndices[index];

                      void onControllerCreated(AnimatedTextController c) {
                        if (isCurrentPage) {
                          _currentController = c;
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.fromLTRB(48, 0, 48, 48),
                        child: Center(
                          key: ValueKey(
                              '${demo.title}_${_isWordMode}_${vi}_$isCurrentPage'),
                          child: _isWordMode
                              ? demo.buildWord(onControllerCreated, vi)
                              : demo.buildLetter(onControllerCreated, vi),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (currentDemo.hasVariations) ...[
                        const SizedBox(width: 16),
                        Flexible(
                          child: VariationSelector(
                            variations: currentDemo.variations,
                            selectedIndex: currentVariationIndex,
                            onChanged: (index) =>
                                _onVariationChanged(_currentPage, index),
                            colorScheme: colorScheme,
                          ),
                        ),
                      ] else ...[
                        const SizedBox.shrink()
                      ],
                      _buildBottomControls(colorScheme, isDesktop),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls(ColorScheme colorScheme, bool isDesktop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (!isDesktop) ...[
          SmoothPageIndicator(
            controller: _pageController,
            count: _demos.length,
            effect: ExpandingDotsEffect(
              activeDotColor: colorScheme.primary,
              dotColor: colorScheme.outlineVariant,
              dotHeight: 8,
              dotWidth: 8,
              expansionFactor: 3,
            ),
            onDotClicked: (index) {
              _pageController.animateToPage(
                index,
                duration: _pageTransitionDuration,
                curve: _curve,
              );
            },
          ),
        ] else
          const SizedBox.shrink(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
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
              const SizedBox(width: 8),
              ControlButton(
                icon: Icons.pause_rounded,
                tooltip: 'Pause',
                onPressed: _handlePause,
                colorScheme: colorScheme,
              ),
              const SizedBox(width: 8),
              ControlButton(
                icon: Icons.play_arrow_rounded,
                tooltip: 'Play',
                onPressed: _handlePlay,
                colorScheme: colorScheme,
                isPrimary: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
