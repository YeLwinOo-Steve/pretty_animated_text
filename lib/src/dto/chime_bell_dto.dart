part of 'dto.dart';

class ChimeBellDto {
  final int index;
  final String text;
  double get value => 1.0;
  double get invValue => 1.0 - value;

  ChimeBellDto({
    required this.index,
    required this.text,
  });
}
