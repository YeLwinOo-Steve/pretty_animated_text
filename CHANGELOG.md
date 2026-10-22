## 3.3.0

* Fixed a memory leak in `BlurText`, `ScaleText`, `OffsetText`, `SpringText`, `RotateText`, `ChimeBellText`, `SlideText` and `ScrambleText`. Every frame created a new `CurvedAnimation` per glyph that stayed subscribed to the controller until the widget was removed: 300 glyphs piled up ~113k listeners over one run, and the frame where the animation completed took ~27× longer than a normal frame.
* Improved performance on long text. Effects no longer rebuild every glyph on every frame: each glyph rebuilds only while its own animation is moving, and glyphs that haven't started or have finished are skipped. The eight effects above are 8–13× faster per frame at 2,000 letters. Rendering is unchanged.
* Added `rebuildOnTick` to `AnimatedTextBase` (defaults to `true`, the previous behavior). Custom builders that listen to the per-segment animations they receive can pass `false` to get the same speed-up.
* The per-segment `animations` passed to an `AnimatedTextBase` builder now notify listeners only when their own value changes, instead of on every controller tick. A custom builder that listens to `animations[i]` as a per-frame tick (for example to read overall progress) stops being notified once that segment finishes; read `AnimatedTextController.progress` in a builder with `rebuildOnTick: true` instead.
* Fixed `AnimatedTextBase` ignoring changes to `text` and to the letter/word `type` after the first build. The text is now re-split, the controller is set to the full overlapped duration instead of a single segment's, and the animation restarts from the beginning.
* Disposed the per-segment animations `AnimatedTextBase` creates, when they are rebuilt and when the widget is removed.
* Fixed new `onPlay`/`onComplete`/`onRepeat`/`onPause`/`onResume`/`onDismissed` callbacks being ignored when a rebuilt `AnimationConfig` was otherwise equal to the previous one.

## 3.2.0

* Added `GlitchText` - a slice/tear glitch effect. All characters stay visible and readable while a random, rotating subset glitches by tearing into horizontal slices that shear sideways: at most one word at a time in word mode, or a random group of 2-3 letters in letter mode, covering every segment once per forward pass and reshuffling on each repeat. Because the slices are disjoint bands, each glyph is drawn exactly once (no ghosting). Customizable via `GlitchStyle` (`shadows` toggles a chromatic tinted tear vs a monochrome one, plus the tint colors); the caller's `TextStyle` is preserved and the glitch loops continuously when `config.repeat` is enabled.
* Added `SquashBounceText` - a SplitText-inspired squash bounce. Each glyph drops, squashes vertically, and rotates, then elastically settles back to rest. The glyphs animate as a continuous traveling wave: each runs its full drop→squash→return over a wide window while start times are packed tightly, so many are mid-flight at slightly offset phases. Controller-driven (auto-plays on mount; honors repeat/reverse/pause). Customizable via `SquashBounceStyle` (`dropFraction`, `squashScaleY`, `rotateDegrees`, `squashPhase`, and `waveSpread` to tune how tight vs sequential the wave is); the caller's `TextStyle` is preserved.

## 3.1.0

* Added Swift Package Manager (SPM) support for iOS and macOS, alongside the existing CocoaPods podspecs.
* Declared macOS as a supported plugin platform.

## 3.0.1

- Improve README rendering on pub.dev.
- Fix image and GIF display issues.

## 3.0.0

* Added `GravityText` - a real 2D rigid-body physics effect (Box2D via `forge2d`): letters fall, collide, pile up on the floor between walls, carry linear + angular momentum, and push their neighbours. Tap to kick a letter or drag to throw it; play/pause/restart control the simulation
* Added `ScrambleText` - characters cycle through random glyphs then resolve left-to-right into the final text
* Added `RevealText` - text reveals behind a sliding cursor, transitioning each segment from dim to full opacity

## 2.0.0

* Added more custom controls over text animation & animation modes ( forward, repeat, reverse, repeat with reverse )
* Animation control from outside classes ( pause, play, repeat, repeat count, etc )
* Improved interval adjustments

## 1.0.3

* Updated docs and added github link

## 1.0.2

* Updated docs and usage guide

## 1.0.1

* Added more customizations and controls for text animations


## 1.0.0

* Added multiple animated text widgets and their variations
  - SpringText
  - ChimeBellText
  - ScaleText
  - RotateText
  - BlurText
  - OffsetText

## 0.0.1

* TODO: Describe initial release.
