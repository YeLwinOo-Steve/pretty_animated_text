import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'pretty_animated_text_platform_interface.dart';

/// An implementation of [PrettyAnimatedTextPlatform] that uses method channels.
class MethodChannelPrettyAnimatedText extends PrettyAnimatedTextPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('pretty_animated_text');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
