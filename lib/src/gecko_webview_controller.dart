import 'dart:async';
import 'dart:convert';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'gecko.g.dart' as gecko;
import 'platform_views_service_proxy.dart';
import 'weak_reference_utils.dart';

var _id = 0;
final _completers = <int, Completer>{};

/// Object specifying parameters for loading a local file in a
/// [GeckoWebViewController].
@immutable
base class GeckoLoadFileParams extends LoadFileParams {
  /// Constructs a [GeckoLoadFileParams], the subclass of a [LoadFileParams].
  GeckoLoadFileParams({
    required String absoluteFilePath,
    this.headers = const <String, String>{},
  }) : super(
         absoluteFilePath: absoluteFilePath.startsWith('file://')
             ? absoluteFilePath
             : Uri.file(absoluteFilePath).toString(),
       );

  /// Constructs a [GeckoLoadFileParams] using a [LoadFileParams].
  factory GeckoLoadFileParams.fromLoadFileParams(
    LoadFileParams params, {
    Map<String, String> headers = const <String, String>{},
  }) {
    return GeckoLoadFileParams(
      absoluteFilePath: params.absoluteFilePath,
      headers: headers,
    );
  }

  /// Additional HTTP headers to be included when loading the local file.
  ///
  /// If not provided at initialization time, doesn't add any additional headers.
  ///
  /// On Gecko, WebView supports adding headers when loading local or remote
  /// content. This can be useful for scenarios like authentication,
  /// content-type overrides, or custom request context.
  final Map<String, String> headers;
}

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
  final Completer<gecko.WebExtensionPort> _webExtensionPort;
  final gecko.FlutterAssetManager _flutterAssetManager;
  final gecko.GeckoView _geckoView;

  final _javaScriptChannelParams = <String, GeckoJavaScriptChannelParams>{};

  late final _geckoSessionNavigationDelegate =
      gecko.GeckoSessionNavigationDelegate(
        onCanGoBack: withWeakReferenceTo(
          this,
          (weakThis) => (_, session, canGoBack) {
            weakThis.target?._canGoBack = canGoBack;
          },
        ),
        onCanGoForward: withWeakReferenceTo(
          this,
          (weakThis) => (_, session, canGoForward) {
            weakThis.target?._canGoForward = canGoForward;
          },
        ),
      );

  late final _geckoSessionProgressDelegate = gecko.GeckoSessionProgressDelegate(
    onPageStart: withWeakReferenceTo(
      this,
      (weakThis) => (_, session, url) {
        _currentUrl = url;
        weakThis.target?._currentNavigationDelegate?._onPageStarted?.call(url);
      },
    ),
    onPageStop: withWeakReferenceTo(
      this,
      (weakThis) => (_, session, success) {
        weakThis.target?._currentNavigationDelegate?._onPageFinished?.call(
          _currentUrl ?? '',
        );
      },
    ),
    onProgressChange: withWeakReferenceTo(
      this,
      (weakThis) => (_, session, progress) {
        weakThis.target?._currentNavigationDelegate?._onProgress?.call(
          progress,
        );
      },
    ),
  );

  late final _webExtensioinPortDelegate = gecko.WebExtensionPortDelegate(
    onDisconnect: withWeakReferenceTo(
      this,
      (weakThis) => (_, webExtensionPort) {
        debugPrint('webExtensionPort disconnected');
      },
    ),
    onPortMessage: withWeakReferenceTo(
      this,
      (weakThis) => (_, message, webExtensionPort) {
        debugPrint('webExtensionPort received: $message');
        final target = weakThis.target;
        if (target == null) return;
        final object = json.decode(message) as Map<String, dynamic>;
        final type = object['type'] as int?;
        if (type == null) return;
        switch (type) {
          case 0: // addJavaScriptChannel reply
          case 1: // removeJavaScriptChannel reply
          case 2: // runJavaScript reply
            final id = object['id'] as int?;
            if (id == null) return;
            final completer = _completers.remove(id);
            if (completer == null) return;
            final error = object['error'];
            if (error == null) {
              final result = object['result'];
              completer.complete(result);
            } else {
              completer.completeError(error);
            }
            break;
          case 3: // javaScriptChannel event
            final javaScriptChannelName = object['name'] as String?;
            if (javaScriptChannelName == null) return;
            final javaScriptChannelMessage = object['message'] as String?;
            if (javaScriptChannelMessage == null) return;
            final javaScriptChannelParams =
                target._javaScriptChannelParams[javaScriptChannelName];
            if (javaScriptChannelParams == null) return;
            javaScriptChannelParams.onMessageReceived(
              JavaScriptMessage(message: javaScriptChannelMessage),
            );
            break;
          default:
            throw ArgumentError.value(type, 'type');
        }
      },
    ),
  );

  var _canGoBack = false;
  var _canGoForward = false;

  String? _currentUrl;
  GeckoNavigationDelegate? _currentNavigationDelegate;

  GeckoWebViewController(PlatformWebViewControllerCreationParams params)
    : _webExtensionPort = Completer(),
      _flutterAssetManager = gecko.FlutterAssetManager.instance,
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
    gecko.WebExtensionPort.getAsync()
        .then((e) => ArgumentError.checkNotNull(e))
        .then(
          withWeakReferenceTo(
            this,
            (weakThis) => (webExtensionPort) {
              final target = weakThis.target;
              if (target == null) return;
              webExtensionPort.setDelegate(target._webExtensioinPortDelegate);
              target._webExtensionPort.complete(webExtensionPort);
            },
          ),
          onError: withWeakReferenceTo(
            this,
            (weakThis) => (error) {
              weakThis.target?._webExtensionPort.completeError(error);
            },
          ),
        );

    _geckoSession.setNavigationDelegate(_geckoSessionNavigationDelegate);
    _geckoSession.setProgressDelegate(_geckoSessionProgressDelegate);
    _geckoSession.settings.setAllowJavascript(true);
  }

  gecko.GeckoSession get _geckoSession => _geckoView.session;

  @override
  Future<void> loadFile(String absoluteFilePath) {
    return loadFileWithParams(
      GeckoLoadFileParams(absoluteFilePath: absoluteFilePath),
    );
  }

  @override
  Future<void> loadFileWithParams(LoadFileParams params) async {
    switch (params) {
      case final GeckoLoadFileParams params:
        final request = gecko.GeckoSessionLoader()
          ..uri(params.absoluteFilePath)
          ..additionalHeaders(params.headers);
        await _geckoSession.load(request);
        break;
      default:
        await loadFileWithParams(
          GeckoLoadFileParams.fromLoadFileParams(params),
        );
    }
  }

  @override
  Future<void> loadFlutterAsset(String key) async {
    final assetFilePath = await _flutterAssetManager.getAssetFilePathByName(
      key,
    );
    final pathElements = assetFilePath.split('/');
    final fileName = pathElements.removeLast();
    final paths = await _flutterAssetManager.list(pathElements.join('/'));

    if (!paths.contains(fileName)) {
      throw ArgumentError('Asset for key "$key" not found.', 'key');
    }

    return _geckoSession.loadUri('resource://android/assets/$assetFilePath');
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
        // TODO
        break;
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
  Future<String?> currentUrl() => Future.value(_currentUrl);

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
  }

  @override
  Future<void> addJavaScriptChannel(
    JavaScriptChannelParams javaScriptChannelParams,
  ) async {
    final geckoJavaScriptChannelParams =
        javaScriptChannelParams is GeckoJavaScriptChannelParams
        ? javaScriptChannelParams
        : GeckoJavaScriptChannelParams.fromJavaScriptChannelParams(
            javaScriptChannelParams,
          );
    final javaScriptChannelName = geckoJavaScriptChannelParams.name;
    if (_javaScriptChannelParams.containsKey(javaScriptChannelName)) {
      throw ArgumentError(
        'A JavaScriptChannel with name `$javaScriptChannelName` already exists.',
      );
    }
    _javaScriptChannelParams[javaScriptChannelName] =
        geckoJavaScriptChannelParams;
    final webExtensionPort = await _webExtensionPort.future;
    final int id = _id++;
    await webExtensionPort.postMessage(
      json.encode({'type': 0, 'id': id, 'name': javaScriptChannelName}),
    );
    final completer = Completer<void>();
    _completers[id] = completer;
    await completer.future;
  }

  @override
  Future<void> removeJavaScriptChannel(String javaScriptChannelName) async {
    assert(javaScriptChannelName.isNotEmpty);
    if (!_javaScriptChannelParams.containsKey(javaScriptChannelName)) {
      return;
    }
    final webExtensionPort = await _webExtensionPort.future;
    final int id = _id++;
    await webExtensionPort.postMessage(
      json.encode({'type': 1, 'id': id, 'name': javaScriptChannelName}),
    );
    final completer = Completer<void>();
    _completers[id] = completer;
    await completer.future;
    _javaScriptChannelParams.remove(javaScriptChannelName);
  }

  @override
  Future<void> runJavaScript(String javaScript) =>
      runJavaScriptReturningResult(javaScript);

  @override
  Future<Object> runJavaScriptReturningResult(String javaScript) async {
    final webExtensionPort = await _webExtensionPort.future;
    final int id = _id++;
    await webExtensionPort.postMessage(
      json.encode({'type': 2, 'id': id, 'javascript': javaScript}),
    );
    final completer = Completer<Object>();
    _completers[id] = completer;
    final result = await completer.future;
    return result;
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
      );

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
