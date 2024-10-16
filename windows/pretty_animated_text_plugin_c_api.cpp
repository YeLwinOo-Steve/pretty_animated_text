#include "include/pretty_animated_text/pretty_animated_text_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "pretty_animated_text_plugin.h"

void PrettyAnimatedTextPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  pretty_animated_text::PrettyAnimatedTextPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
