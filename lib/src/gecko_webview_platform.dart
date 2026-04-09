import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

/// Implementation of [WebViewPlatform] using the GeckoView API.
class GeckoWebViewPlatform extends WebViewPlatform {
  /// Registers this class as the default instance of [WebViewPlatform].
  static void registerWith() {
    WebViewPlatform.instance = GeckoWebViewPlatform();
  }
}
