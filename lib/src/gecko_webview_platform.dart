import 'package:webview_flutter_geckoview/src/gecko_webview_controller.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

/// Implementation of [WebViewPlatform] using the GeckoView API.
class GeckoWebViewPlatform extends WebViewPlatform {
  /// Registers this class as the default instance of [WebViewPlatform].
  static void registerWith() {
    WebViewPlatform.instance = GeckoWebViewPlatform();
  }

  GeckoWebViewPlatform();

  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) {
    return GeckoWebViewController(params);
  }

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) {
    return GeckoNavigationDelegate(params);
  }

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) {
    return GeckoWebViewWidget(params);
  }

  @override
  PlatformWebViewCookieManager createPlatformCookieManager(
    PlatformWebViewCookieManagerCreationParams params,
  ) {
    // TODO: implement createPlatformCookieManager
    return super.createPlatformCookieManager(params);
  }
}
