import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'pretty_animated_text_method_channel.dart';

abstract class PrettyAnimatedTextPlatform extends PlatformInterface {
  /// Constructs a PrettyAnimatedTextPlatform.
  PrettyAnimatedTextPlatform() : super(token: _token);

  static final Object _token = Object();

  static PrettyAnimatedTextPlatform _instance = MethodChannelPrettyAnimatedText();

  /// The default instance of [PrettyAnimatedTextPlatform] to use.
  ///
  /// Defaults to [MethodChannelPrettyAnimatedText].
  static PrettyAnimatedTextPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PrettyAnimatedTextPlatform] when
  /// they register themselves.
  static set instance(PrettyAnimatedTextPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
