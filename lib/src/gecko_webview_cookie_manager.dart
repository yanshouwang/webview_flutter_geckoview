import 'package:meta/meta.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'mozilla_geckoview.g.dart';

/// Object specifying creation parameters for creating a [GeckoWebViewCookieManager].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformWebViewCookieManagerCreationParams] for
/// more information.
@immutable
class GeckoWebViewCookieManagerCreationParams
    extends PlatformWebViewCookieManagerCreationParams {
  /// Creates a new [GeckoWebViewCookieManagerCreationParams] instance.
  const GeckoWebViewCookieManagerCreationParams._(
    // This parameter prevents breaking changes later.
    // ignore: avoid_unused_constructor_parameters
    PlatformWebViewCookieManagerCreationParams params,
  ) : super();

  /// Creates a [GeckoWebViewCookieManagerCreationParams] instance based on [PlatformWebViewCookieManagerCreationParams].
  factory GeckoWebViewCookieManagerCreationParams.fromPlatformWebViewCookieManagerCreationParams(
    PlatformWebViewCookieManagerCreationParams params,
  ) {
    return GeckoWebViewCookieManagerCreationParams._(params);
  }
}

/// Handles all cookie operations for the GeckoView.
class GeckoWebViewCookieManager extends PlatformWebViewCookieManager {
  final GeckoRuntime _runtime;

  /// Creates a new [GeckoWebViewCookieManager].
  GeckoWebViewCookieManager(
    PlatformWebViewCookieManagerCreationParams params, {
    GeckoRuntime? runtime,
  }) : _runtime = runtime ?? GeckoRuntime.instance,
       super.implementation(
         params is GeckoWebViewCookieManagerCreationParams
             ? params
             : GeckoWebViewCookieManagerCreationParams.fromPlatformWebViewCookieManagerCreationParams(
                 params,
               ),
       );
}
