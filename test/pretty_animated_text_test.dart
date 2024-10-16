import 'package:flutter_test/flutter_test.dart';
import 'package:pretty_animated_text/pretty_animated_text_platform_interface.dart';
import 'package:pretty_animated_text/pretty_animated_text_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPrettyAnimatedTextPlatform
    with MockPlatformInterfaceMixin
    implements PrettyAnimatedTextPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final PrettyAnimatedTextPlatform initialPlatform =
      PrettyAnimatedTextPlatform.instance;

  test('$MethodChannelPrettyAnimatedText is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPrettyAnimatedText>());
  });

  // test('getPlatformVersion', () async {
  //   PrettyAnimatedText prettyAnimatedTextPlugin = PrettyAnimatedText();
  //   MockPrettyAnimatedTextPlatform fakePlatform = MockPrettyAnimatedTextPlatform();
  //   PrettyAnimatedTextPlatform.instance = fakePlatform;

  //   expect(await prettyAnimatedTextPlugin.getPlatformVersion(), '42');
  // });
}
