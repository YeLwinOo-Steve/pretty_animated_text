// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

import 'pretty_animated_text_platform_interface.dart';

/// A web implementation of the PrettyAnimatedTextPlatform of the PrettyAnimatedText plugin.
class PrettyAnimatedTextWeb extends PrettyAnimatedTextPlatform {
  /// Constructs a PrettyAnimatedTextWeb
  PrettyAnimatedTextWeb();

  static void registerWith(Registrar registrar) {
    PrettyAnimatedTextPlatform.instance = PrettyAnimatedTextWeb();
  }

  /// Returns a [String] containing the version of the platform.
  @override
  Future<String?> getPlatformVersion() async {
    final version = web.window.navigator.userAgent;
    return version;
  }
}
