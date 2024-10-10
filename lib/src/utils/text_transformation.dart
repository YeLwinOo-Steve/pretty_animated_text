import 'package:pretty_animated_text/src/dto/dto.dart';

extension TextTransformation on String {
  List<EffectDto> get splittedLetters => split('')
      .indexed
      .map((e) => EffectDto(index: e.$1, text: e.$2))
      .toList(); // split each characters
  List<EffectDto> get splittedWords => split(' ')
      .indexed
      .map((e) => EffectDto(index: e.$1, text: '${e.$2} '))
      .toList(); // split by space
}
