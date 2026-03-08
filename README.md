# Pretty Animated Text

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-orange.svg)](https://buymeacoffee.com/yloo2)

## Overview

A text animation UI plugin that provides you with gorgeous and customizable animated text widgets so that you can use them effortlessly in your project.

Physics-based animations are utilized for text animations, providing a smooth and delightful experience.

> This project heavily inspires on [jasudev's AnimateText for SwiftUI package](https://github.com/jasudev/AnimateText)


##  Preview Website

Link: https://pretty-animated-text.vercel.app

### Key Features: 

- Various text animation types:
  - Spring animation
  - Chime bell animation
  - Scale animation
  - Rotate animation
  - Blur animation
  - Offset (slide) animation
- Supports both letter-by-letter and word-by-word animations
- Customizable animation duration and styles
- Easy to integrate into existing Flutter projects

## Installation
To use this package, add `pretty_animated_text` as a dependency in your `pubspec.yaml` file:

`flutter pub add pretty_animated_text`

### How to

Animations are configured using `AnimationConfig`. There are two main animation types that you can trigger inside the config:
- for word by word → `AnimationType.word`
- for letter by letter → `AnimationType.letter`

You can also pass callbacks to react to animation lifecycle events:
- `onPlay`: Triggered when the animation starts.
- `onComplete`: Triggered when the animation finishes.
- `onPause`, `onResume`, `onDismissed`, etc.

And for texts such as `RotateText` and `OffsetText`, you can trigger some more variations like rotation direction and slide offset.

Currently, the plugin supports default Flutter text alignments:
  - `TextAlign.start`
  - `TextAlign.center`
  - `TextAlign.end`



#### See the demos and examples below:

| Type                               | Word Animation                                                                | Letter Animation                                                                |
| ---------------------------------- | ----------------------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| Spring Text                        | ![Word Springg Text](assets/gifs/words/w_spring_text.gif)                     | ![Letter Springg Text](assets/gifs/letters/spring_text.gif)                     |
| Chime Bell Text                    | ![Word Chime Bell Text](assets/gifs/words/w_chime_bell_text.gif)              | ![Letter Chime Bell Text](assets/gifs/letters/chime_bell_text.gif)️              |
| Scale Text                         | ![Word Scale Text](assets/gifs/words/w_scale_text.gif)                        | ![Letter Scale Text](assets/gifs/letters/scale_text.gif)                        |
| Blur Text                          | ![Word Blur Text](assets/gifs/words/w_blur_text.gif)                          | ![Letter Blur Text](assets/gifs/letters/blur_text.gif)                          |
| Rotate Text (clockwise)            | ![Word Rotate Text (c)](assets/gifs/words/w_rotate_text_clockwise.gif)        | ![Letter Rotate Text (c)](assets/gifs/letters/rotate_text_clockwise.gif)        |
| Rotate Text (anti-clockwise)       | ![Word Rotate Text (anti)](assets/gifs/words/w_rotate_text_anticlockwise.gif) | ![Letter Rotate Text (anti)](assets/gifs/letters/rotate_text_anticlockwise.gif) |
| Offest Text (top-bottom)           | ![Word Offset Text(tb)](assets/gifs/words/w_offset_text_top_bottom.gif)       | ![Letter Offset Text(tb)](assets/gifs/letters/offset_text_top_bottom.gif)       |
| Offest Text (bottom-top)           | ![Word Offset Text(bt)](assets/gifs/words/w_offset_text_bottom_top.gif)       | ![Letter Offset Text(bt)](assets/gifs/letters/offset_text_bottom_top.gif)       |
| Offest Text (alternate top-bottom) | ![Word Offset Text(a-tb)](assets/gifs/words/w_offset_text_alternate_tb.gif)   | ![Letter Offset Text(a-tb)](assets/gifs/letters/offset_text_alternate_tb.gif)   |
| Offest Text (left-right)           | ![Word Offset Text(lr)](assets/gifs/words/w_offset_text_left_right.gif)       | ![Letter Offset Text(lr)](assets/gifs/letters/offset_text_left_right.gif)       |
| Offest Text (right-left)           | ![Word Offset Text(rl)](assets/gifs/words/w_offset_text_right_left.gif)       | ![Letter Offset Text(rl)](assets/gifs/letters/offset_text_right_left.gif)       |
| Offest Text (alternate left-right) | ![Word Offset Tetx(a-lr)](assets/gifs/words/w_offset_text_alternate_lr.gif)   | ![Letter Offset Tetx(a-lr)](assets/gifs/letters/offset_text_alternate_lr.gif)️   |

##### Code Examples

- Spring Text
  ```dart
    SpringText(
      text: 'Lorem ipsum dolor sit amet ...',
      style: const TextStyle(fontSize: 18),
      config: AnimationConfig(
        duration: const Duration(seconds: 4), 
        type: AnimationType.word,
        onPlay: (controller) => print('Animation started'),
        onComplete: (controller) => print('Animation completed'),
      ),
    )
  ```
- Chime Bell Text
  ```dart
    ChimeBellText(
      text: 'Lorem ipsum dolor sit amet ...',
      style: const TextStyle(fontSize: 18),
      config: const AnimationConfig(
        duration: Duration(seconds: 4), 
        type: AnimationType.word,
      ),
    )
  ```
- Scale Text
  ```dart
    ScaleText(
      text: 'Lorem ipsum dolor sit amet ...',
      style: const TextStyle(fontSize: 18),
      config: const AnimationConfig(
        duration: Duration(seconds: 4), 
        type: AnimationType.word,
      ),
    )
  ```
- Blur Text
  
  ```dart
    BlurText(
      text: 'Lorem ipsum dolor sit amet ...',
      style: const TextStyle(fontSize: 18),
      config: const AnimationConfig(
        duration: Duration(seconds: 4), 
        type: AnimationType.word,
      ),
    )
  ```
- Rotate Text
  
  For `RotateText`, you can tweak two rotation directions.
  - clockwise → `RotateAnimationType.clockwise` (default)
  - anti-clockwise → `RotateAnimationType.anticlockwise`

  ```dart
    RotateText(
      text: 'Lorem ipsum dolor sit amet ...',
      direction: RotateAnimationType.clockwise,
      style: const TextStyle(fontSize: 18),
      config: const AnimationConfig(
        duration: Duration(seconds: 4), 
        type: AnimationType.word,
      ),
    )
  ```
- Offset Text
  
  `OffsetText` has multiple slide effects that you can tweak according to your needs.
  - Top to bottom → `SlideAnimationType.topBottom` (default)
  - Bottom to top → `SlideAnimationType.bottomTop`
  - Alternate top-bottom → `SlideAnimationType.alternateTB`
  - Left to right → `SlideAnimationType.leftRight`
  - Right to left → `SlideAnimationType.rightLeft`
  - Alternate left-right → `SlideAnimationType.alternateLR` 

  ```dart
    OffsetText(
      text: 'Lorem ipsum dolor sit amet ...',
      slideType: SlideAnimationType.topBottom,
      style: const TextStyle(fontSize: 18),
      config: const AnimationConfig(
        duration: Duration(seconds: 4), 
        type: AnimationType.word,
      ),
    )
  ```

###  Project License:
This project is licensed under [MIT License](LICENSE).

Feel free to check it out and give it a  <img src="assets/Star.png" width="36px">️ if you love it. 
Follow me for more updates and more projects

> Suggestions are warmly welcome & more updates are coming along the way ...️ 


Copyright (©️) 2024 __YE LWIN OO__












