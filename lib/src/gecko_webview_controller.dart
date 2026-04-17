import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'gecko.g.dart' as gecko;
import 'gecko_constants.dart';
import 'gecko_web_extension.dart';
import 'platform_views_service_proxy.dart';
import 'weak_reference_utils.dart';

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
  final gecko.GeckoView _webView;
  final gecko.GeckoWebExecutor _webExecutor;
  final gecko.StorageController _storageController;
  final GeckoWebExtensionPort _webExtensionPort;
  final gecko.FlutterAssetManager _flutterAssetManager;
  final Map<String, GeckoJavaScriptChannelParams> _javaScriptChannelParams;

  late final _geckoSessionContentDelegate = gecko.GeckoSessionContentDelegate(
    onTitleChange: withWeakReferenceTo(
      this,
      (weakThis) => (_, session, title) {
        weakThis.target?._title = title;
      },
    ),
  );

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

  late final _geckoSessionPermissionDelegate =
      gecko.GeckoSessionPermissionDelegate(
        onAndroidPermissionsRequest: withWeakReferenceTo(
          this,
          (weakThis) => (_, session, permissioins, callback) async {
            debugPrint('onAndroidPermissionsRequest: $permissioins');
            final onPermissionRequestCallback =
                weakThis.target?._onPermissionRequestCallback;
            if (onPermissionRequestCallback == null) {
              return callback.reject();
            } else {
              final types = permissioins
                  .map<WebViewPermissionResourceType?>((String type) {
                    switch (type) {
                      case PermissionRequestConstants.camera:
                        return WebViewPermissionResourceType.camera;
                      case PermissionRequestConstants.recordAudio:
                        return WebViewPermissionResourceType.microphone;
                    }

                    // Type not supported.
                    return null;
                  })
                  .whereType<WebViewPermissionResourceType>()
                  .toSet();

              // If the request didn't contain any permissions recognized by the
              // implementation, deny by default.
              if (types.isEmpty) {
                return callback.reject();
              }

              onPermissionRequestCallback(
                GeckoWebViewPermissionRequest._(
                  types: types,
                  callback: callback,
                ),
              );
            }
          },
        ),
      );

  late final _geckoSessionProgressDelegate = gecko.GeckoSessionProgressDelegate(
    onPageStart: withWeakReferenceTo(
      this,
      (weakThis) => (_, session, url) {
        weakThis.target?._currentUrl = url;
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

  late final _geckoSessionScrollDelegate = gecko.GeckoSessionScrollDelegate(
    onScrollChanged: withWeakReferenceTo(
      this,
      (weakThis) => (_, session, scrollX, scrollY) {
        final target = weakThis.target;
        if (target == null) return;
        final scrollPosition = Offset(scrollX.toDouble(), scrollY.toDouble());
        target._scrollPosition = scrollPosition;
        target._onScrollPositionChangeCallback?.call(
          ScrollPositionChange(scrollPosition.dx, scrollPosition.dy),
        );
      },
    ),
  );

  var _canGoBack = false;
  var _canGoForward = false;

  String? _currentUrl;
  String? _title;
  Offset? _scrollPosition;
  GeckoNavigationDelegate? _currentNavigationDelegate;
  void Function(PlatformWebViewPermissionRequest)? _onPermissionRequestCallback;
  void Function(ScrollPositionChange)? _onScrollPositionChangeCallback;

  GeckoWebViewController(PlatformWebViewControllerCreationParams params)
    : _webView = gecko.GeckoView(),
      _webExecutor = gecko.GeckoWebExecutor(
        runtime: gecko.GeckoRuntime.instance,
      ),
      _storageController = gecko.GeckoRuntime.instance.storageController,
      _webExtensionPort = GeckoWebExtensionPort(),
      _flutterAssetManager = gecko.FlutterAssetManager.instance,
      _javaScriptChannelParams = {},
      super.implementation(
        params is GeckoWebViewControllerCreationParams
            ? params
            : GeckoWebViewControllerCreationParams.fromPlatformWebViewControllerCreationParams(
                params,
              ),
      ) {
    _webView.session.setContentDelegate(_geckoSessionContentDelegate);
    _webView.session.setNavigationDelegate(_geckoSessionNavigationDelegate);
    _webView.session.setPermissionDelegate(_geckoSessionPermissionDelegate);
    _webView.session.setProgressDelegate(_geckoSessionProgressDelegate);
    _webView.session.settings.setAllowJavascript(true);
  }

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
        await _webView.session.load(request);
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

    return _webView.session.loadUri('resource://android/assets/$assetFilePath');
  }

  @override
  Future<void> loadHtmlString(String html, {String? baseUrl}) {
    final request = gecko.GeckoSessionLoader()..dataString(html, 'text/html');
    if (baseUrl != null) {
      request.uri(baseUrl);
    }
    return _webView.session.load(request);
  }

  @override
  Future<void> loadRequest(LoadRequestParams params) async {
    if (!params.uri.hasScheme) {
      throw ArgumentError('WebViewRequest#uri is required to have a scheme.');
    }
    switch (params.method) {
      case LoadRequestMethod.get:
        final loader = gecko.GeckoSessionLoader()
          ..uri(params.uri.toString())
          ..additionalHeaders(params.headers);
        return _webView.session.load(loader);
      case LoadRequestMethod.post:
        final builder = gecko.WebRequestBuilder(uri: params.uri.toString())
          ..method(params.method.name.toUpperCase())
          ..bodyBytes(params.body);
        for (final header in params.headers.entries) {
          builder.header(header.key, header.value);
        }
        final request = await builder.build();
        final response = await _webExecutor
            .fetch(request, null)
            .then((e) => ArgumentError.checkNotNull(e));
        final loader = gecko.GeckoSessionLoader()..uri(response.uri);
        final bytes = response.body;
        final mimeType = response.headers['content-type'];
        if (bytes != null) {
          loader.dataBytes(bytes, mimeType);
        }
        return _webView.session.load(loader);
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
  Future<void> goBack() => _webView.session.goBack();

  @override
  Future<void> goForward() => _webView.session.goForward();

  @override
  Future<void> reload() => _webView.session.reload();

  @override
  Future<void> clearCache() =>
      _storageController.clearData(StorageControllerClearFlags.allCaches);

  @override
  Future<void> clearLocalStorage() =>
      _storageController.clearData(StorageControllerClearFlags.all);

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
    final javascriptChannel = GeckoJavascriptChannel(
      name: javaScriptChannelName,
      onMessageReceived: withWeakReferenceTo(
        this,
        (weakThis) => (message) {
          weakThis.target?._javaScriptChannelParams[javaScriptChannelName]
              ?.onMessageReceived(JavaScriptMessage(message: message));
        },
      ),
    );
    await _webExtensionPort.addJavascriptChannel(javascriptChannel);
  }

  @override
  Future<void> removeJavaScriptChannel(String javaScriptChannelName) async {
    assert(javaScriptChannelName.isNotEmpty);
    if (!_javaScriptChannelParams.containsKey(javaScriptChannelName)) {
      return;
    }
    await _webExtensionPort.removeJavascriptChannel(javaScriptChannelName);
    _javaScriptChannelParams.remove(javaScriptChannelName);
  }

  @override
  Future<void> runJavaScript(String javaScript) =>
      runJavaScriptReturningResult(javaScript);

  @override
  Future<Object> runJavaScriptReturningResult(String javaScript) async {
    final result = await _webExtensionPort.runJavascript(javaScript);
    return result ?? '';
  }

  @override
  Future<String?> getTitle() => Future.value(_title);

  @override
  Future<void> scrollTo(int x, int y) async {
    final width = gecko.ScreenLength.fromPixels(value: x.toDouble());
    final height = gecko.ScreenLength.fromPixels(value: y.toDouble());
    await _webView.panZoomController.scrollTo(width, height, null);
  }

  @override
  Future<void> scrollBy(int x, int y) async {
    final width = gecko.ScreenLength.fromPixels(value: x.toDouble());
    final height = gecko.ScreenLength.fromPixels(value: y.toDouble());
    await _webView.panZoomController.scrollBy(width, height, null);
  }

  @override
  Future<Offset> getScrollPosition() => Future.value(_scrollPosition);

  @override
  Future<void> enableZoom(bool enabled) {
    // TODO: implement enableZoom
    return super.enableZoom(enabled);
  }

  @override
  Future<void> setBackgroundColor(Color color) =>
      _webView.setBackgroundColor(color.toARGB32());

  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) => _webView
      .session
      .settings
      .setAllowJavascript(javaScriptMode == .unrestricted);

  @override
  Future<String?> getUserAgent() => _webView.session.getUserAgent();

  @override
  Future<void> setUserAgent(String? userAgent) =>
      _webView.session.settings.setUserAgentOverride(userAgent);

  @override
  Future<void> setOnPlatformPermissionRequest(
    void Function(PlatformWebViewPermissionRequest request) onPermissionRequest,
  ) async {
    _onPermissionRequestCallback = onPermissionRequest;
  }

  @override
  Future<void> setOnScrollPositionChange(
    void Function(ScrollPositionChange scrollPositionChange)?
    onScrollPositionChange,
  ) {
    _onScrollPositionChangeCallback = onScrollPositionChange;

    if (onScrollPositionChange != null) {
      return _webView.session.setScrollDelegate(_geckoSessionScrollDelegate);
    } else {
      return _webView.session.setScrollDelegate(null);
    }
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
    // Setting a default key using `params` ensures the `PlatformViewLink`
    // recreates the PlatformView when changes are made.
    final key =
        _geckoParams.key ??
        ValueKey<GeckoWebViewWidgetCreationParams>(
          params as GeckoWebViewWidgetCreationParams,
        );
    return PlatformViewLink(
      key: key,
      viewType: 'plugins.flutter.io/webview',
      surfaceFactory: (context, controller) {
        return AndroidViewSurface(
          controller: controller as AndroidViewController,
          gestureRecognizers: _geckoParams.gestureRecognizers,
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      },
      onCreatePlatformView: (params) {
        return _initAndroidView(
            params,
            displayWithHybridComposition:
                _geckoParams.displayWithHybridComposition,
            platformViewsServiceProxy: _geckoParams.platformViewsServiceProxy,
            view: (_geckoParams.controller as GeckoWebViewController)._webView,
            layoutDirection: _geckoParams.layoutDirection,
          )
          ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
          ..create();
      },
    );
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

  @override
  Future<void> setOnUrlChange(UrlChangeCallback onUrlChange) {
    // TODO: implement setOnUrlChange
    return super.setOnUrlChange(onUrlChange);
  }

  @override
  Future<void> setOnNavigationRequest(
    NavigationRequestCallback onNavigationRequest,
  ) {
    // TODO: implement setOnNavigationRequest
    return super.setOnNavigationRequest(onNavigationRequest);
  }

  @override
  Future<void> setOnHttpAuthRequest(HttpAuthRequestCallback onHttpAuthRequest) {
    // TODO: implement setOnHttpAuthRequest
    return super.setOnHttpAuthRequest(onHttpAuthRequest);
  }

  @override
  Future<void> setOnHttpError(HttpResponseErrorCallback onHttpError) {
    // TODO: implement setOnHttpError
    return super.setOnHttpError(onHttpError);
  }

  @override
  Future<void> setOnWebResourceError(
    WebResourceErrorCallback onWebResourceError,
  ) {
    // TODO: implement setOnWebResourceError
    return super.setOnWebResourceError(onWebResourceError);
  }

  @override
  Future<void> setOnSSlAuthError(SslAuthErrorCallback onSslAuthError) {
    // TODO: implement setOnSSlAuthError
    return super.setOnSSlAuthError(onSslAuthError);
  }
}

/// Gecko implementation of [PlatformWebViewPermissionRequest].
class GeckoWebViewPermissionRequest extends PlatformWebViewPermissionRequest {
  const GeckoWebViewPermissionRequest._({
    required super.types,
    required gecko.GeckoSessionPermissionDelegateCallback callback,
  }) : _callback = callback;

  final gecko.GeckoSessionPermissionDelegateCallback _callback;

  @override
  Future<void> grant() {
    return _callback.grant();
  }

  @override
  Future<void> deny() {
    return _callback.reject();
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
