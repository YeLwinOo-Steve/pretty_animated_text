import 'package:pretty_animated_text/src/dto/dto.dart';

extension TextTransformation on String {
  List<EffectDto> get splittedLetters => split('')
      .indexed
      .map((e) => EffectDto(index: e.$1, text: e.$2))
      .toList(); // split each characters

  List<EffectDto> get splittedWords {
    if (isEmpty) return [];

    // Split text keeping spaces with words
    final List<String> words = [];
    final RegExp pattern = RegExp(r'\S+\s*');

    for (final match in pattern.allMatches(this)) {
      words.add(match.group(0)!);
    }

    return words.indexed
        .map((e) => EffectDto(index: e.$1, text: e.$2))
        .toList();
  }
}
