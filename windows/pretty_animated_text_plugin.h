#ifndef FLUTTER_PLUGIN_PRETTY_ANIMATED_TEXT_PLUGIN_H_
#define FLUTTER_PLUGIN_PRETTY_ANIMATED_TEXT_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace pretty_animated_text {

class PrettyAnimatedTextPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  PrettyAnimatedTextPlugin();

  virtual ~PrettyAnimatedTextPlugin();

  // Disallow copy and assign.
  PrettyAnimatedTextPlugin(const PrettyAnimatedTextPlugin&) = delete;
  PrettyAnimatedTextPlugin& operator=(const PrettyAnimatedTextPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace pretty_animated_text

#endif  // FLUTTER_PLUGIN_PRETTY_ANIMATED_TEXT_PLUGIN_H_
