import 'dart:async';
import 'dart:convert';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'gecko.g.dart' as gecko;
import 'platform_views_service_proxy.dart';
import 'weak_reference_utils.dart';

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

/// Implementation of the [PlatformWebViewController] with the GeckoView API.
class GeckoWebViewController extends PlatformWebViewController {
  final gecko.GeckoRuntime _geckoRuntime;

  final gecko.GeckoSession _geckoSession;

  /// The native [GeckoView] being controlled.
  final gecko.GeckoView _geckoView;

  final _webExtensionPortCompleter = Completer<gecko.WebExtensionPort>();

  late final gecko.GeckoSessionContentDelegate _geckoContentDelegate =
      gecko.GeckoSessionContentDelegate();

  late final gecko.GeckoSessionNavigationDelegate _geckoNavigationDelegate =
      gecko.GeckoSessionNavigationDelegate(
        onCanGoBack: withWeakReferenceTo(
          this,
          (weakReference) => (_, session, canGoBack) {
            debugPrint('onCanGoBack: $canGoBack ');
            weakReference.target?._canGoBack = canGoBack;
          },
        ),
        onCanGoForward: withWeakReferenceTo(
          this,
          (weakReference) => (_, session, canGoForward) {
            debugPrint('onCanGoForward: $canGoForward ');
            weakReference.target?._canGoForward = canGoForward;
          },
        ),
      );

  late final gecko.WebExtensionMessageDelegate _geckoMessageDelegate =
      gecko.WebExtensionMessageDelegate(
        onConnect: withWeakReferenceTo(
          this,
          (weakReference) => (_, port) {
            weakReference.target?._webExtensionPortCompleter.complete(port);
            port.setDelegate(_geckoPortDelegate);
          },
        ),
      );

  late final gecko.WebExtensionPortDelegate
  _geckoPortDelegate = gecko.WebExtensionPortDelegate(
    onDisconnect: withWeakReferenceTo(this, (weakReference) => (_, port) {}),
    onPortMessage: withWeakReferenceTo(
      this,
      (weakReference) => (_, message, port) {
        final controller = weakReference.target;
        if (controller == null) return;
        final items = json.decode(message) as Map<String, dynamic>;
        final channelName = items['channelName'] as String?;
        if (channelName == null) return;
        final channelParams = controller._javaScriptChannelParams[channelName];
        if (channelParams == null) return;
        channelParams.onMessageReceived(
          JavaScriptMessage(message: items['message'] as String),
        );
      },
    ),
  );

  final _javaScriptChannelParams = <String, GeckoJavaScriptChannelParams>{};

  var _canGoBack = false;
  var _canGoForward = false;
  GeckoNavigationDelegate? _currentNavigationDelegate;

  GeckoWebViewController(PlatformWebViewControllerCreationParams params)
    : _geckoRuntime = gecko.GeckoRuntime.instance,
      _geckoSession = gecko.GeckoSession(),
      _geckoView = gecko.GeckoView(
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
    _geckoRuntime.settings.setConsoleOutputEnabled(true);
    _geckoRuntime.webExtensionController
        .ensureBuiltIn(
          'resource://android/assets/messaging/',
          'messaging@zeekr.dev',
        )
        .then((extension) {
          if (extension == null) {
            debugPrint('ensureBuiltIn failed: extension is null');
            return;
          }
          _geckoSession.webExtensionController.setMessageDelegate(
            extension,
            _geckoMessageDelegate,
            'webview_flutter',
          );
        }, onError: (error) => debugPrint('ensureBuiltIn failed: $error'));

    // Workaround for Bug 1758212
    _geckoSession.setContentDelegate(_geckoContentDelegate);
    _geckoSession.open(_geckoRuntime);
    _geckoSession.settings.setAllowJavascript(true);
    _geckoView.setSession(_geckoSession);

    _geckoSession.setNavigationDelegate(_geckoNavigationDelegate);
  }

  Future<gecko.WebExtensionPort> get _webExtensionPort =>
      _webExtensionPortCompleter.future;

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
    final request = gecko.GeckoSessionLoader()..string(html, 'text/html');
    if (baseUrl != null) {
      request.uri(baseUrl);
    }
    return _geckoSession.load(request);
  }

  @override
  Future<void> loadRequest(LoadRequestParams params) {
    if (!params.uri.hasScheme) {
      throw ArgumentError('WebViewRequest#uri is required to have a scheme.');
    }
    switch (params.method) {
      case LoadRequestMethod.get:
        final request = gecko.GeckoSessionLoader()
          ..uri(params.uri.toString())
          ..additionalHeaders(params.headers);
        return _geckoSession.load(request);
      case LoadRequestMethod.post:
        throw UnsupportedError(
          'GeckoView does not support POST method in loadRequest yet.',
        );
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
  Future<bool> canGoBack() => Future.value(_canGoBack);

  @override
  Future<bool> canGoForward() => Future.value(_canGoForward);

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
    _currentNavigationDelegate = handler;
    await Future.wait([
      _geckoSession.setProgressDelegate(handler.geckoProgressDelegate),
    ]);
  }

  @override
  Future<void> addJavaScriptChannel(
    JavaScriptChannelParams javaScriptChannelParams,
  ) async {
    final geckoParams = javaScriptChannelParams is GeckoJavaScriptChannelParams
        ? javaScriptChannelParams
        : GeckoJavaScriptChannelParams.fromJavaScriptChannelParams(
            javaScriptChannelParams,
          );
    final String channelName = geckoParams.name;
    if (_javaScriptChannelParams.containsKey(channelName)) {
      throw ArgumentError(
        'A JavaScriptChannel with name `$channelName` already exists.',
      );
    }
    _javaScriptChannelParams[channelName] = geckoParams;
    final webExtensionPort = await _webExtensionPort;
    await webExtensionPort.postMessage(
      json.encode({'action': 0, 'channelName': channelName}),
    );
  }

  @override
  Future<void> removeJavaScriptChannel(String javaScriptChannelName) async {
    assert(javaScriptChannelName.isNotEmpty);
    if (!_javaScriptChannelParams.containsKey(javaScriptChannelName)) {
      return;
    }
    final webExtensionPort = await _webExtensionPort;
    await webExtensionPort.postMessage(
      json.encode({'action': 1, 'channelName': javaScriptChannelName}),
    );
    _javaScriptChannelParams.remove(javaScriptChannelName);
  }

  @override
  Future<void> runJavaScript(String javaScript) async {
    final webExtensionPort = await _webExtensionPort;
    await webExtensionPort.postMessage(
      json.encode({'action': 2, 'javascript': javaScript}),
    );
  }

  @override
  Future<Object> runJavaScriptReturningResult(String javaScript) {
    // TODO: implement runJavaScriptReturningResult
    return super.runJavaScriptReturningResult(javaScript);
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
  Future<void> setUserAgent(String? userAgent) =>
      _geckoSession.settings.setUserAgentOverride(userAgent);

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

/// An implementation of [JavaScriptChannelParams] with the GeckoView API.
@immutable
class GeckoJavaScriptChannelParams extends JavaScriptChannelParams {
  /// Constructs a [GeckoJavaScriptChannelParams].
  GeckoJavaScriptChannelParams({
    required super.name,
    required super.onMessageReceived,
  }) : assert(name.isNotEmpty);

  /// Constructs a [GeckoJavaScriptChannelParams] using a
  /// [JavaScriptChannelParams].
  GeckoJavaScriptChannelParams.fromJavaScriptChannelParams(
    JavaScriptChannelParams params,
  ) : this(name: params.name, onMessageReceived: params.onMessageReceived);
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
/// triggered by the [gecko.GeckoView].
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
    _progressDelegate = gecko.GeckoSessionProgressDelegate(
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

  late final gecko.GeckoSessionProgressDelegate _progressDelegate;

  /// Gets the native [gecko.GeckoSessionProgressDelegate] that is bridged by this [GeckoNavigationDelegate].
  ///
  /// Used by the [GeckoWebViewController] to set the `geckoview.GeckoSession.setProgressDelegate`.
  gecko.GeckoSessionProgressDelegate get geckoProgressDelegate =>
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
  required gecko.View view,
  TextDirection layoutDirection = TextDirection.ltr,
}) {
  final int identifier = gecko.PigeonInstanceManager.instance.getIdentifier(
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
