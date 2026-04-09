import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

class GeckoWebViewControllerCreationParams
    extends PlatformWebViewControllerCreationParams {
  const GeckoWebViewControllerCreationParams();

  /// Constructs a [GeckoWebViewControllerCreationParams] using a
  /// [PlatformWebViewControllerCreationParams].
  const GeckoWebViewControllerCreationParams.fromPlatformWebViewControllerCreationParams(
    // Recommended placeholder to prevent being broken by platform interface.
    // ignore: avoid_unused_constructor_parameters
    PlatformWebViewControllerCreationParams params,
  ) : this();
}

class GeckoWebviewController extends PlatformWebViewController {
  GeckoWebviewController(PlatformWebViewControllerCreationParams params)
    : super.implementation(
        params is GeckoWebViewControllerCreationParams
            ? params
            : GeckoWebViewControllerCreationParams.fromPlatformWebViewControllerCreationParams(
                params,
              ),
      );
}
