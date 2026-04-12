import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    // copyrightHeader: 'pigeons/copyright.txt',
    dartOut: 'lib/src/mozilla_geckoview.g.dart',
    kotlinOut:
        'android/src/main/kotlin/dev/zeekr/webview_flutter_geckoview/MozillaGeckoviewLibrary.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'dev.zeekr.webview_flutter_geckoview',
      errorClassName: 'MozillaGeckoviewError',
    ),
  ),
)
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'org.mozilla.geckoview.GeckoRuntime',
  ),
)
abstract class GeckoRuntime {
  @static
  late GeckoRuntime instance;

  /// Returns a WebExtensionController for this GeckoRuntime.
  @attached
  late WebExtensionController webExtensionController;
}

@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'org.mozilla.geckoview.WebExtensionController',
  ),
)
abstract class WebExtensionController {
  /// Ensure that a built-in extension is installed.
  @async
  WebExtension? ensureBuiltIn(String uri, String? id);

  /// List installed extensions for this GeckoRuntime.
  @async
  List<WebExtension>? list();
}

@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'org.mozilla.geckoview.WebExtension',
  ),
)
abstract class WebExtension {
  /// Defines the message delegate for a Native App.
  void setMessageDelegate(
    WebExtensionMessageDelegate delegate,
    String nativeApp,
  );
}

@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'org.mozilla.geckoview.WebExtension.MessageDelegate',
  ),
)
abstract class WebExtensionMessageDelegate {
  WebExtensionMessageDelegate();

  /// Called whenever the WebExtension connects to an app using runtime.connectNative.
  late void Function(WebExtensionPort port)? onConnect;

  /// Called whenever the WebExtension sends a message to an app using runtime.sendNativeMessage.
  // late GeckoResult<Object> Function(
  //   String nativeApp,
  //   Object message,
  //   WebExtensionMessageSender sender,
  // )?
  // onMessage;
}

@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'org.mozilla.geckoview.WebExtension.Port',
  ),
)
abstract class WebExtensionPort {
  /// Disconnects this port and notifies the other end.
  void disconnect();

  /// Post a message to the WebExtension connected to this WebExtension.Port instance.
  void postMessage(String message);

  /// Set a delegate for incoming messages through this WebExtension.Port.
  void setDelegate(WebExtensionPortDelegate delegate);
}

@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'org.mozilla.geckoview.WebExtension.PortDelegate',
  ),
)
abstract class WebExtensionPortDelegate {
  WebExtensionPortDelegate();

  late void Function(WebExtensionPort port)? onDisconnect;
  late void Function(String message, WebExtensionPort port)? onPortMessage;
}

@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'org.mozilla.geckoview.GeckoSession',
  ),
)
abstract class GeckoSession {
  GeckoSession();

  @attached
  late GeckoSessionSettings settings;

  void open(GeckoRuntime runtime);
  void setContentDelegate(GeckoSessionContentDelegate delegate);
  void setProgressDelegate(GeckoSessionProgressDelegate delegate);
  void setNavigationDelegate(GeckoSessionNavigationDelegate delegate);
  void loadUri(String uri);
  void goBack();
  void goForward();
  void reload();
  @async
  String? getUserAgent();
}

@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'org.mozilla.geckoview.GeckoSessionSettings',
  ),
)
abstract class GeckoSessionSettings {
  /// Whether javascript execution is allowed.
  bool getAllowJavascript();

  /// Set the chrome window URI.
  String? getChromeUri();

  /// The context ID for this session.
  String? getContextId();

  /// The current display mode.
  int getDisplayMode();

  /// Whether entire accessible tree is exposed with no caching.
  bool getFullAccessibilityTree();

  /// Set the window screen ID.
  int getScreenId();

  /// Whether media will be suspended when the session is inactice.
  bool getSuspendMediaWhenInactive();

  /// Whether private mode is enabled.
  bool getUsePrivateMode();

  /// The current user agent Mode
  int getUserAgentMode();

  /// The user agent override string.
  String? getUserAgentOverride();

  /// Whether tracking protection is enabled.
  bool getUserTrackingProtection();

  /// The current viewport Mode
  int getViewportMode();

  /// Set whether JavaScript support should be enabled.
  void setAllowJavascript(bool value);

  /// Set the display mode.
  void setDisplayMode(int value);

  /// Set whether the entire accessible tree should be exposed with no caching.
  void setFullAccessibilityTree(bool value);

  /// Set whether to suspend the playing of media when the session is inactive.
  void setSuspendMediaWhenInactive(bool value);

  /// Specify which user agent mode we should use
  void setUserAgentMode(int value);

  /// Specify the user agent override string.
  void setUserAgentOverride(String? value);

  /// Set whether tracking protection should be enabled.
  void setUseTrackingProtection(bool value);

  /// Specify which viewport mode we should use
  void setViewportMode(int value);
}

@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'org.mozilla.geckoview.GeckoSession.ContentDelegate',
  ),
)
abstract class GeckoSessionContentDelegate {
  GeckoSessionContentDelegate();
}

@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'org.mozilla.geckoview.GeckoSession.ProgressDelegate',
  ),
)
abstract class GeckoSessionProgressDelegate {
  GeckoSessionProgressDelegate();

  /// A View has started loading content from the network.
  late void Function(GeckoSession session, String url)? onPageStart;

  /// A View has finished loading content from the network.
  late void Function(GeckoSession session, bool success)? onPageStop;

  /// Page loading has progressed.
  late void Function(GeckoSession session, int progress)? onProgressChange;

  /// The security status has been updated.
  // late void Function(
  //   GeckoSession session,
  //   GeckoSessionProgressDelegateSecurityInformation securityInfo,
  // )?
  // onSecurityChange;

  /// The browser session state has changed.
  // late void Function(
  //   GeckoSession session,
  //   GeckoSessionSessionState sessionState,
  // )?
  // onSessionStateChange;
}

@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'org.mozilla.geckoview.GeckoSession.NavigationDelegate',
  ),
)
abstract class GeckoSessionNavigationDelegate {
  GeckoSessionNavigationDelegate();

  /// The view's ability to go back has changed.
  late void Function(GeckoSession session, bool canGoBack)? onCanGoBack;

  /// The view's ability to go forward has changed.
  late void Function(GeckoSession session, bool canGoForward)? onCanGoForward;

  ///
  // late GeckoResult<String> Function(
  //   GeckoSession session,
  //   String uri,
  //   WebRequestError error,
  // )?
  // onLoadError;

  /// A request to open an URI.
  // late GeckoResult<AllowOrDeny> Function(
  //   GeckoSession session,
  //   GeckoSessionNavigationDelegateLoadRequest request,
  // )?
  // onLoadRequest;

  /// A view has started loading content from the network.
  // late void Function(
  //   GeckoSession session,
  //   String url,
  //   List<GeckoSessionPermissionDelegateContentPermission> perms,
  //   bool hasUserGesture,
  // )?
  // onLocationChange;

  /// A request has been made to open a new session.
  // late GeckoResult<GeckoSession> Function(GeckoSession session, String uri)?
  // onNewSession;

  /// A request to load a URI in a non-top-level context.
  // late GeckoResult<AllowOrDeny> Function(
  //   GeckoSession session,
  //   GeckoSessionNavigationDelegateLoadRequest request,
  // )?
  // onSubframeLoadRequest;
}

/// A View that displays web pages.
///
/// See https://developer.android.com/reference/android/webkit/WebView.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'org.mozilla.geckoview.GeckoView',
  ),
)
abstract class GeckoView extends View {
  GeckoView();

  void setSession(GeckoSession session);

  /// This is called in response to an internal scroll in this view (i.e., the
  /// view scrolled its own contents).
  // late void Function(int left, int top, int oldLeft, int oldTop)?
  // onScrollChanged;

  /// The WebSettings object used to control the settings for this WebView.
  // @attached
  // late WebSettings settings;

  /// Loads the given data into this WebView using a 'data' scheme URL.
  // void loadData(String data, String? mimeType, String? encoding);

  /// Loads the given data into this WebView, using baseUrl as the base URL for
  /// the content.
  // void loadDataWithBaseUrl(
  //   String? baseUrl,
  //   String data,
  //   String? mimeType,
  //   String? encoding,
  //   String? historyUrl,
  // );

  /// Loads the given URL.
  // void loadUrl(String url, Map<String, String> headers);

  /// Loads the URL with postData using "POST" method into this WebView.
  // void postUrl(String url, Uint8List data);

  /// Gets the URL for the current page.
  // String? getUrl();

  /// Gets whether this WebView has a back history item.
  // bool canGoBack();

  /// Gets whether this WebView has a forward history item.
  // bool canGoForward();

  /// Goes back in the history of this WebView.
  // void goBack();

  /// Goes forward in the history of this WebView.
  // void goForward();

  /// Reloads the current URL.
  // void reload();

  /// Clears the resource cache.
  // void clearCache(bool includeDiskFiles);

  /// Asynchronously evaluates JavaScript in the context of the currently
  /// displayed page.
  // @async
  // String? evaluateJavascript(String javascriptString);

  /// Gets the title for the current page.
  // String? getTitle();

  /// Enables debugging of web contents (HTML / CSS / JavaScript) loaded into
  /// any WebViews of this application.
  // @static
  // void setWebContentsDebuggingEnabled(bool enabled);

  /// Sets the WebViewClient that will receive various notifications and
  /// requests.
  // void setWebViewClient(WebViewClient? client);

  /// Injects the supplied Java object into this WebView.
  // void addJavaScriptChannel(JavaScriptChannel channel);

  /// Removes a previously injected Java object from this WebView.
  // void removeJavaScriptChannel(String name);

  /// Registers the interface to be used when content can not be handled by the
  /// rendering engine, and should be downloaded instead.
  // void setDownloadListener(DownloadListener? listener);

  /// Sets the chrome handler.
  // void setWebChromeClient(WebChromeClient? client);

  /// Destroys the internal state of this WebView.
  // void destroy();
}

/// This class represents the basic building block for user interface
/// components.
///
/// See https://developer.android.com/reference/android/view/View.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(fullClassName: 'android.view.View'),
)
abstract class View {
  /// Sets the background color for this view.
  void setBackgroundColor(int color);

  /// Set the scrolled position of your view.
  // void scrollTo(int x, int y);

  /// Move the scrolled position of your view.
  // void scrollBy(int x, int y);

  /// Return the scrolled position of this view.
  // WebViewPoint getScrollPosition();

  /// Define whether the vertical scrollbar should be drawn or not.
  ///
  /// The scrollbar is not drawn by default.
  // void setVerticalScrollBarEnabled(bool enabled);

  /// Define whether the horizontal scrollbar should be drawn or not.
  ///
  /// The scrollbar is not drawn by default.
  // void setHorizontalScrollBarEnabled(bool enabled);

  /// Set the over-scroll mode for this view.
  // void setOverScrollMode(OverScrollMode mode);
}
