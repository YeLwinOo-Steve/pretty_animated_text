# Pretty Animated Text

## <img src="assets/Telescope.webp" width="36px"> Overview

An animation UI plugin that provides you with gorgeous and customizable animated text widgets so that you can use them effortlessly in your project.

Physics-based animations are utilized for text animations, providing a smooth and delightful experience.

> This project heavily inspires on [jasudev's AnimateText for SwiftUI package](https://github.com/jasudev/AnimateText)


## <img src="assets/Spider Web.webp" width="36px">  Preview Website

Link: https://pretty-animated-text.vercel.app

### <img src="assets/Rocket.png" width="36px">️ Key Features: 

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

## <img src="assets/Fire.png" width="36px">️ Installation
To use this package, add `pretty_animated_text` as a dependency in your `pubspec.yaml` file:

`flutter pub add pretty_animated_text`

### <img src="assets/Comet.png" width="36px">️ How to

There are two main animation types that you can trigger.
- for word by word → `AnimationType.word`
- for letter by letter → `AnimationType.letter`


And for texts such as `RotateText` and `OffsetText`, you can trigger some more variations like rotation direction and slide offset.

See the demos and examples below:

| Type                               | Word Animation | Letter Animation |
| ---------------------------------- | -------------- | ---------------- |
| Spring Text                        | $80            | 492              |
| Chim Bell Text                     | January        | $250             |
| Scale Text                         | $80            | 492              |
| Blur Text                          | $420           | 55234            |
| Rotate Text (clockwise)            | $420           | 55234            |
| Rotate Text (anti-clockwise)       | $420           | 55234            |
| Offest Text (top-bottom)           | $420           | 55234            |
| Offest Text (bottom-top)           | $420           | 55234            |
| Offest Text (alternate top-bottom) | $420           | 55234            |
| Offest Text (left-right)           | $420           | 55234            |
| Offest Text (right-left)           | $420           | 55234            |
| Offest Text (alternate left-right) | $420           | 55234            |

##### Code Examples

- Spring Text
  ```dart
    SpringText(
          text: 'Lorem ipsum dolor sit amet ...',
          duration: const Duration(seconds: 4), 
          type: AnimationType.word,
          textStyle: const TextStyle(fontSize: 18),
        )
  ```
- Chime Bell Text
  ```dart
    ChimeBellText(
        text: 'Lorem ipsum dolor sit amet ...',
        duration: const Duration(seconds: 4), 
        type: AnimationType.word,
        textStyle: const TextStyle(fontSize: 18),
      ),
  ```
- Scale Text
  ```dart
    ScaleText(
        text: 'Lorem ipsum dolor sit amet ...',
        duration: const Duration(seconds: 4), 
        type: AnimationType.word,
        textStyle: const TextStyle(fontSize: 18),
      ),
  ```
- Blur Text
  
  ```dart
    BlurText(
        text: 'Lorem ipsum dolor sit amet ...',
        duration: const Duration(seconds: 4), 
        type: AnimationType.word,
        textStyle: const TextStyle(fontSize: 18),
      ),
  ```
- Rotate Text
  
  For `RotateText`, you can tweak two rotation directions.
  - clockwise → `RotateAnimationType.clockwise` (default)
  - anti-clockwise → `RotateAnimationType.anticlockwise`

  ```dart
    RotateText(
        text: 'Lorem ipsum dolor sit amet ...',
        direction: RotateAnimationType.clockwise,
        duration: const Duration(seconds: 4), 
        type: AnimationType.word,
        textStyle: const TextStyle(fontSize: 18),
      ),
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
        duration: const Duration(seconds: 4), 
        type: AnimationType.word,
        slideType: SlideAnimationType.topBottom,
        textStyle: const TextStyle(fontSize: 18),
      ),
  ```

### <img src="assets/Eyes.png" width="36px">️  Project License:
This project is licensed under [MIT License](LICENSE).

Feel free to check it out and give it a  <img src="assets/Star.png" width="36px">️ if you love it. 
Follow me for more updates and more projects

> Suggestions are warmly welcome & more updates are coming along the way ...  <img src="assets/Folded Hands Medium Skin Tone.png" width="36px">️ 


Copyright (©️) 2023 __YE LWIN OO__












