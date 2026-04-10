import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'mozilla_geckoview.g.dart' as geckoview;
import 'platform_views_service_proxy.dart';

/// Object specifying creation parameters for creating a [GeckoWebViewController].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformWebViewControllerCreationParams] for
/// more information.
@immutable
class GeckoWebViewControllerCreationParams
    extends PlatformWebViewControllerCreationParams {
  /// Creates a new [GeckoWebViewControllerCreationParams] instance.
  const GeckoWebViewControllerCreationParams() : super();

  /// Creates a [GeckoWebViewControllerCreationParams] instance based on [PlatformWebViewControllerCreationParams].
  factory GeckoWebViewControllerCreationParams.fromPlatformWebViewControllerCreationParams(
    // Recommended placeholder to prevent being broken by platform interface.
    // ignore: avoid_unused_constructor_parameters
    PlatformWebViewControllerCreationParams params,
  ) {
    return GeckoWebViewControllerCreationParams();
  }
}

/// Implementation of the [PlatformWebViewController] with the Gecko WebView API.
class GeckoWebViewController extends PlatformWebViewController {
  final geckoview.GeckoRuntime _geckoRuntime;

  final geckoview.GeckoSession _geckoSession;

  /// The native [GeckoView] being controlled.
  final geckoview.GeckoView _geckoView;

  GeckoWebViewController(PlatformWebViewControllerCreationParams params)
    : _geckoRuntime = geckoview.GeckoRuntime.instance,
      _geckoSession = geckoview.GeckoSession(),
      _geckoView = geckoview.GeckoView(
        // onScrollChanged: withWeakReferenceTo(this, (
        //   WeakReference<AndroidWebViewController> weakReference,
        // ) {
        //   return (_, int left, int top, int oldLeft, int oldTop) async {
        //     final void Function(ScrollPositionChange)? callback =
        //         weakReference.target?._onScrollPositionChangedCallback;
        //     callback?.call(ScrollPositionChange(left.toDouble(), top.toDouble()));
        //   };
        // }),
      ),
      super.implementation(
        params is GeckoWebViewControllerCreationParams
            ? params
            : GeckoWebViewControllerCreationParams.fromPlatformWebViewControllerCreationParams(
                params,
              ),
      ) {
    // GeckoRuntime can only be initialized once per process
    // Workaround for Bug 1758212
    _geckoSession.setContentDelegate(geckoview.GeckoSessionContentDelegate());
    _geckoSession.open(_geckoRuntime);
    _geckoSession.settings.setAllowJavascript(true);
    _geckoView.setSession(_geckoSession);
  }

  @override
  Future<void> loadFile(String absoluteFilePath) {
    // TODO: implement loadFile
    return super.loadFile(absoluteFilePath);
  }

  @override
  Future<void> loadFileWithParams(LoadFileParams params) {
    // TODO: implement loadFileWithParams
    return super.loadFileWithParams(params);
  }

  @override
  Future<void> loadFlutterAsset(String key) {
    // TODO: implement loadFlutterAsset
    return super.loadFlutterAsset(key);
  }

  @override
  Future<void> loadHtmlString(String html, {String? baseUrl}) {
    // TODO: implement loadHtmlString
    return super.loadHtmlString(html, baseUrl: baseUrl);
  }

  @override
  Future<void> loadRequest(LoadRequestParams params) {
    if (!params.uri.hasScheme) {
      throw ArgumentError('WebViewRequest#uri is required to have a scheme.');
    }
    // TODO: implement loadRequest
    switch (params.method) {
      case LoadRequestMethod.get:
        // return _geckoView.loadUrl(params.uri.toString(), params.headers);
        return _geckoSession.loadUri(params.uri.toString());
      case LoadRequestMethod.post:
      // return _geckoView.postUrl(
      //   params.uri.toString(),
      //   params.body ?? Uint8List(0),
      // );
    }
    // The enum comes from a different package, which could get a new value at
    // any time, so a fallback case is necessary. Since there is no reasonable
    // default behavior, throw to alert the client that they need an updated
    // version. This is deliberately outside the switch rather than a `default`
    // so that the linter will flag the switch as needing an update.
    // ignore: dead_code
    throw UnimplementedError(
      'This version of `GeckoWebViewController` currently has no '
      'implementation for HTTP method ${params.method.serialize()} in '
      'loadRequest.',
    );
  }

  @override
  Future<String?> currentUrl() {
    // TODO: implement currentUrl
    return super.currentUrl();
  }

  @override
  Future<bool> canGoBack() {
    // TODO: implement canGoBack
    return super.canGoBack();
  }

  @override
  Future<bool> canGoForward() {
    // TODO: implement canGoForward
    return super.canGoForward();
  }

  @override
  Future<void> goBack() => _geckoSession.goBack();

  @override
  Future<void> goForward() => _geckoSession.goForward();

  @override
  Future<void> reload() => _geckoSession.reload();

  @override
  Future<void> clearCache() {
    // TODO: implement clearCache
    return super.clearCache();
  }

  @override
  Future<void> clearLocalStorage() {
    // TODO: implement clearLocalStorage
    return super.clearLocalStorage();
  }

  @override
  Future<void> setPlatformNavigationDelegate(
    covariant GeckoNavigationDelegate handler,
  ) async {
    await Future.wait([
      _geckoSession.setProgressDelegate(handler.geckoProgressDelegate),
    ]);
  }

  @override
  Future<void> runJavaScript(String javaScript) {
    // TODO: implement runJavaScript
    return super.runJavaScript(javaScript);
  }

  @override
  Future<Object> runJavaScriptReturningResult(String javaScript) {
    // TODO: implement runJavaScriptReturningResult
    return super.runJavaScriptReturningResult(javaScript);
  }

  @override
  Future<void> addJavaScriptChannel(
    JavaScriptChannelParams javaScriptChannelParams,
  ) {
    // TODO: implement addJavaScriptChannel
    return super.addJavaScriptChannel(javaScriptChannelParams);
  }

  @override
  Future<void> removeJavaScriptChannel(String javaScriptChannelName) {
    // TODO: implement removeJavaScriptChannel
    return super.removeJavaScriptChannel(javaScriptChannelName);
  }

  @override
  Future<String?> getTitle() {
    // TODO: implement getTitle
    return super.getTitle();
  }

  @override
  Future<void> scrollTo(int x, int y) {
    // TODO: implement scrollTo
    return super.scrollTo(x, y);
  }

  @override
  Future<void> scrollBy(int x, int y) {
    // TODO: implement scrollBy
    return super.scrollBy(x, y);
  }

  @override
  Future<Offset> getScrollPosition() {
    // TODO: implement getScrollPosition
    return super.getScrollPosition();
  }

  @override
  Future<void> enableZoom(bool enabled) {
    // TODO: implement enableZoom
    return super.enableZoom(enabled);
  }

  @override
  Future<void> setBackgroundColor(Color color) =>
      _geckoView.setBackgroundColor(color.toARGB32());

  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) => _geckoSession
      .settings
      .setAllowJavascript(javaScriptMode == .unrestricted);

  @override
  Future<String?> getUserAgent() => _geckoSession.getUserAgent();

  @override
  Future<void> setUserAgent(String? userAgent) {
    // TODO: implement setUserAgent
    return super.setUserAgent(userAgent);
  }

  @override
  Future<void> setOnScrollPositionChange(
    void Function(ScrollPositionChange scrollPositionChange)?
    onScrollPositionChange,
  ) {
    // TODO: implement setOnScrollPositionChange
    return super.setOnScrollPositionChange(onScrollPositionChange);
  }

  @override
  Future<void> setOnPlatformPermissionRequest(
    void Function(PlatformWebViewPermissionRequest request) onPermissionRequest,
  ) {
    // TODO: implement setOnPlatformPermissionRequest
    return super.setOnPlatformPermissionRequest(onPermissionRequest);
  }

  @override
  Future<void> setOnConsoleMessage(
    void Function(JavaScriptConsoleMessage consoleMessage) onConsoleMessage,
  ) {
    // TODO: implement setOnConsoleMessage
    return super.setOnConsoleMessage(onConsoleMessage);
  }

  @override
  Future<void> setOnJavaScriptAlertDialog(
    Future<void> Function(JavaScriptAlertDialogRequest request)
    onJavaScriptAlertDialog,
  ) {
    // TODO: implement setOnJavaScriptAlertDialog
    return super.setOnJavaScriptAlertDialog(onJavaScriptAlertDialog);
  }

  @override
  Future<void> setOnJavaScriptConfirmDialog(
    Future<bool> Function(JavaScriptConfirmDialogRequest request)
    onJavaScriptConfirmDialog,
  ) {
    // TODO: implement setOnJavaScriptConfirmDialog
    return super.setOnJavaScriptConfirmDialog(onJavaScriptConfirmDialog);
  }

  @override
  Future<void> setOnJavaScriptTextInputDialog(
    Future<String> Function(JavaScriptTextInputDialogRequest request)
    onJavaScriptTextInputDialog,
  ) {
    // TODO: implement setOnJavaScriptTextInputDialog
    return super.setOnJavaScriptTextInputDialog(onJavaScriptTextInputDialog);
  }

  @override
  Future<void> setVerticalScrollBarEnabled(bool enabled) {
    // TODO: implement setVerticalScrollBarEnabled
    return super.setVerticalScrollBarEnabled(enabled);
  }

  @override
  Future<void> setHorizontalScrollBarEnabled(bool enabled) {
    // TODO: implement setHorizontalScrollBarEnabled
    return super.setHorizontalScrollBarEnabled(enabled);
  }

  @override
  bool supportsSetScrollBarsEnabled() {
    // TODO: implement supportsSetScrollBarsEnabled
    return super.supportsSetScrollBarsEnabled();
  }

  @override
  Future<void> setOverScrollMode(WebViewOverScrollMode mode) {
    // TODO: implement setOverScrollMode
    return super.setOverScrollMode(mode);
  }
}

/// Object specifying creation parameters for creating a [GeckoWebViewWidget].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformWebViewWidgetCreationParams] for
/// more information.
@immutable
class GeckoWebViewWidgetCreationParams
    extends PlatformWebViewWidgetCreationParams {
  /// Creates [GeckoWebViewWidgetCreationParams].
  const GeckoWebViewWidgetCreationParams({
    super.key,
    required super.controller,
    super.layoutDirection,
    super.gestureRecognizers,
    this.displayWithHybridComposition = false,
    @visibleForTesting
    this.platformViewsServiceProxy = const PlatformViewsServiceProxy(),
  });

  /// Constructs a [GeckoWebViewWidgetCreationParams] using a
  /// [PlatformWebViewWidgetCreationParams].
  GeckoWebViewWidgetCreationParams.fromPlatformWebViewWidgetCreationParams(
    PlatformWebViewWidgetCreationParams params, {
    bool displayWithHybridComposition = false,
    @visibleForTesting
    PlatformViewsServiceProxy platformViewsServiceProxy =
        const PlatformViewsServiceProxy(),
  }) : this(
         key: params.key,
         controller: params.controller,
         layoutDirection: params.layoutDirection,
         gestureRecognizers: params.gestureRecognizers,
         displayWithHybridComposition: displayWithHybridComposition,
         platformViewsServiceProxy: platformViewsServiceProxy,
       );

  /// Proxy that provides access to the platform views service.
  ///
  /// This service allows creating and controlling platform-specific views.
  @visibleForTesting
  final PlatformViewsServiceProxy platformViewsServiceProxy;

  /// Whether the [WebView] will be displayed using the Hybrid Composition
  /// PlatformView implementation.
  ///
  /// For most use cases, this flag should be set to false. Hybrid Composition
  /// can have performance costs but doesn't have the limitation of rendering to
  /// an Android SurfaceTexture. See
  /// * https://docs.flutter.dev/platform-integration/android/platform-views#performance
  /// * https://github.com/flutter/flutter/issues/104889
  /// * https://github.com/flutter/flutter/issues/116954
  ///
  /// Defaults to false.
  final bool displayWithHybridComposition;

  @override
  int get hashCode => Object.hash(
    controller,
    layoutDirection,
    displayWithHybridComposition,
    platformViewsServiceProxy,
  );

  @override
  bool operator ==(Object other) {
    return other is GeckoWebViewWidgetCreationParams &&
        controller == other.controller &&
        layoutDirection == other.layoutDirection &&
        displayWithHybridComposition == other.displayWithHybridComposition &&
        platformViewsServiceProxy == other.platformViewsServiceProxy;
  }
}

/// An implementation of [PlatformWebViewWidget] with the Gecko WebView API.
class GeckoWebViewWidget extends PlatformWebViewWidget {
  /// Constructs a [GeckoWebViewWidget].
  GeckoWebViewWidget(PlatformWebViewWidgetCreationParams params)
    : super.implementation(
        params is GeckoWebViewWidgetCreationParams
            ? params
            : GeckoWebViewWidgetCreationParams.fromPlatformWebViewWidgetCreationParams(
                params,
              ),
      );

  GeckoWebViewWidgetCreationParams get _geckoParams =>
      params as GeckoWebViewWidgetCreationParams;

  @override
  Widget build(BuildContext context) {
    _trySetDefaultOnShowCustomWidgetCallbacks(context);
    return PlatformViewLink(
      // Setting a default key using `params` ensures the `PlatformViewLink`
      // recreates the PlatformView when changes are made.
      key:
          _geckoParams.key ??
          ValueKey<GeckoWebViewWidgetCreationParams>(
            params as GeckoWebViewWidgetCreationParams,
          ),
      viewType: 'plugins.flutter.io/webview',
      surfaceFactory:
          (BuildContext context, PlatformViewController controller) {
            return AndroidViewSurface(
              controller: controller as AndroidViewController,
              gestureRecognizers: _geckoParams.gestureRecognizers,
              hitTestBehavior: PlatformViewHitTestBehavior.opaque,
            );
          },
      onCreatePlatformView: (PlatformViewCreationParams params) {
        return _initAndroidView(
            params,
            displayWithHybridComposition:
                _geckoParams.displayWithHybridComposition,
            platformViewsServiceProxy: _geckoParams.platformViewsServiceProxy,
            view:
                (_geckoParams.controller as GeckoWebViewController)._geckoView,
            layoutDirection: _geckoParams.layoutDirection,
          )
          ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
          ..create();
      },
    );
  }

  // Attempt to handle custom views with a default implementation if it has not
  // been set.
  void _trySetDefaultOnShowCustomWidgetCallbacks(BuildContext context) {
    // TODO: Uncomment this.
    // final controller = _geckoParams.controller as GeckoWebViewController;

    // if (controller._onShowCustomWidgetCallback == null) {
    //   controller.setCustomWidgetCallbacks(
    //     onShowCustomWidget:
    //         (Widget widget, OnHideCustomWidgetCallback callback) {
    //           Navigator.of(context).push(
    //             MaterialPageRoute<void>(
    //               builder: (BuildContext context) => widget,
    //               fullscreenDialog: true,
    //             ),
    //           );
    //         },
    //     onHideCustomWidget: () {
    //       Navigator.of(context).pop();
    //     },
    //   );
    // }
  }
}

/// Object specifying creation parameters for creating a [AndroidNavigationDelegate].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformNavigationDelegateCreationParams] for
/// more information.
@immutable
class GeckoNavigationDelegateCreationParams
    extends PlatformNavigationDelegateCreationParams {
  /// Creates a new [GeckoNavigationDelegateCreationParams] instance.
  const GeckoNavigationDelegateCreationParams._() : super();

  /// Creates a [GeckoNavigationDelegateCreationParams] instance based on [PlatformNavigationDelegateCreationParams].
  factory GeckoNavigationDelegateCreationParams.fromPlatformNavigationDelegateCreationParams(
    // Recommended placeholder to prevent being broken by platform interface.
    // ignore: avoid_unused_constructor_parameters
    PlatformNavigationDelegateCreationParams params,
  ) {
    return const GeckoNavigationDelegateCreationParams._();
  }
}

/// A place to register callback methods responsible to handle navigation events
/// triggered by the [geckoview.GeckoView].
class GeckoNavigationDelegate extends PlatformNavigationDelegate {
  /// Creates a new [GeckoNavigationDelegate].
  GeckoNavigationDelegate(PlatformNavigationDelegateCreationParams params)
    : super.implementation(
        params is GeckoNavigationDelegateCreationParams
            ? params
            : GeckoNavigationDelegateCreationParams.fromPlatformNavigationDelegateCreationParams(
                params,
              ),
      ) {
    final weakThis = WeakReference<GeckoNavigationDelegate>(this);
    _progressDelegate = geckoview.GeckoSessionProgressDelegate(
      onPageStart: (_, session, url) {
        final callback = weakThis.target?._onPageStarted;
        if (callback != null) callback(url);
      },
      onPageStop: (_, session, success) {
        final callback = weakThis.target?._onPageFinished;
        // TODO: Pass the actual URL instead of an empty string when the callback is triggered.
        if (callback != null) callback('');
      },
      onProgressChange: (_, session, progress) {
        final callback = weakThis.target?._onProgress;
        if (callback != null) callback(progress);
      },
    );
  }

  late final geckoview.GeckoSessionProgressDelegate _progressDelegate;

  /// Gets the native [geckoview.GeckoSessionProgressDelegate] that is bridged by this [GeckoNavigationDelegate].
  ///
  /// Used by the [GeckoWebViewController] to set the `geckoview.GeckoSession.setProgressDelegate`.
  geckoview.GeckoSessionProgressDelegate get geckoProgressDelegate =>
      _progressDelegate;

  PageEventCallback? _onPageStarted;
  PageEventCallback? _onPageFinished;
  ProgressCallback? _onProgress;

  @override
  Future<void> setOnPageStarted(PageEventCallback onPageStarted) async {
    _onPageStarted = onPageStarted;
  }

  @override
  Future<void> setOnPageFinished(PageEventCallback onPageFinished) async {
    _onPageFinished = onPageFinished;
  }

  @override
  Future<void> setOnProgress(ProgressCallback onProgress) async {
    _onProgress = onProgress;
  }
}

AndroidViewController _initAndroidView(
  PlatformViewCreationParams params, {
  required bool displayWithHybridComposition,
  required PlatformViewsServiceProxy platformViewsServiceProxy,
  required geckoview.View view,
  TextDirection layoutDirection = TextDirection.ltr,
}) {
  final int identifier = geckoview.PigeonInstanceManager.instance.getIdentifier(
    view,
  )!;

  if (displayWithHybridComposition) {
    return platformViewsServiceProxy.initExpensiveAndroidView(
      id: params.id,
      viewType: 'plugins.flutter.io/webview',
      layoutDirection: layoutDirection,
      creationParams: identifier,
      creationParamsCodec: const StandardMessageCodec(),
    );
  } else {
    return platformViewsServiceProxy.initSurfaceAndroidView(
      id: params.id,
      viewType: 'plugins.flutter.io/webview',
      layoutDirection: layoutDirection,
      creationParams: identifier,
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}
