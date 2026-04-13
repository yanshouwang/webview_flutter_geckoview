import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    // copyrightHeader: 'pigeons/copyright.txt',
    dartOut: 'lib/src/gecko.g.dart',
    kotlinOut:
        'android/src/main/kotlin/dev/zeekr/webview_flutter_geckoview/GeckoLibrary.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'dev.zeekr.webview_flutter_geckoview',
      errorClassName: 'GeckoError',
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

  /// Get the runtime settings.
  @attached
  late GeckoRuntimeSettings settings;

  /// Returns a WebExtensionController for this GeckoRuntime.
  @attached
  late WebExtensionController webExtensionController;
}

@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'org.mozilla.geckoview.GeckoRuntimeSettings',
  ),
)
abstract class GeckoRuntimeSettings {
  /// Get whether or not web console messages are sent to logcat.
  bool getConsoleOutputEnabled();

  /// Set whether or not web console messages should go to logcat.
  GeckoRuntimeSettings setConsoleOutputEnabled(bool value);
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
    fullClassName: 'org.mozilla.geckoview.WebExtension.SessionController',
  ),
)
abstract class WebExtensionSessionController {
  /// Get the Action delegate for this session.
  // WebExtensionActionDelegate getActionDelegate(WebExtension extension);

  /// Get the message delegate for nativeApp.
  WebExtensionMessageDelegate? getMessageDelegate(
    WebExtension extension,
    String nativeApp,
  );

  /// Get the TabDelegate for the given extension.
  // WebExtensionSessionTabDelegate getTabDelegate(WebExtension extension);

  /// Set the Action delegate for this session.
  // void setActionDelegate(
  //   WebExtension extension,
  //   WebExtensionActionDelegate delegate,
  // );

  /// Defines a message delegate for a Native App.
  void setMessageDelegate(
    WebExtension extension,
    WebExtensionMessageDelegate delegate,
    String nativeApp,
  );

  /// Set the TabDelegate for this session.
  // void setTabDelegate(
  //   WebExtension extension,
  //   WebExtensionSessionTabDelegate delegate,
  // );
}

@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'org.mozilla.geckoview.GeckoSession',
  ),
)
abstract class GeckoSession {
  GeckoSession();

  /// Get the default user agent for this GeckoView build.
  @static
  String getDefaultUserAgent();

  /// Returns the settings used by this GeckoSession.
  @attached
  late GeckoSessionSettings settings;

  /// Returns a WebExtensionController for this GeckoSession.
  @attached
  late WebExtensionSessionController webExtensionController;

  /// Acquire the GeckoDisplay instance for providing the session with a drawing Surface.
  // GeckoDispaly acquireDisplay();
  void close();

  /// Get whether this GeckoSession has form data.
  @async
  bool? containsFormData();

  /// Prints the currently displayed page and provides dialog finished status or if an exception occurred.
  @async
  bool? didPrintPageContent();

  /// Exits fullscreen mode
  void exitFullScreen();

  /// Flushes the current GeckoSession state.
  void flushSessionState();

  /// Get the SessionAccessibility instance for this session.
  // SessionAccessibility getAccessibility();

  ///
  // AutofillDelegate getAutofillDelegate();

  /// Provides an autofill structure similar to
  /// View.onProvideAutofillVirtualStructure(ViewStructure, int) , but does not
  /// rely on ViewStructure to build the tree.
  // AutofillSession getAutofillSession();'

  /// Get the bounds of the client area in client coordinates.
  // void getClientBounds(RectF rect);

  /// Get a matrix for transforming from client coordinates to screen coordinates.
  // void getClientToScreenMatrix(Matrix matrix);

  /// Get a matrix for transforming from client coordinates to surface coordinates.
  // void getClientToSurfaceMatrix(Matrix matrix);

  /// Get the CompositorController instance for this session.
  // CompositorController getCompositorController();

  /// Get the current compositor scroll callback handler.
  // GeckoSessionCompositorScrollDelegate? getCompositorScrollDelegate();

  /// Get the content blocking callback handler.
  // ContentBlockingDelegate? getContentBlockingDelegate();

  /// Get the content callback handler.
  GeckoSessionContentDelegate? getContentDelegate();

  /// Gets the experiment delegate for this session.
  // ExperimentDelegate? getExperimentDelegate();

  /// Get the SessionFinder instance for this session, to perform find-in-page operations.
  // SessionFinder getFinder();

  ///
  // GeckoSessionHistoryDelegate? getHistoryDelegate();

  /// Get the Media callback handler.
  // GeckoSessionMediaDelegate? getMediaDelegate();

  /// Get the media session delegate.
  // MediaSessionDelegate? getMediaSessionDelegate();

  /// Get the navigation callback handler.
  GeckoSessionNavigationDelegate? getNavigationDelegate();

  /// Get the OverscrollEdgeEffect instance for this session.
  // OverscrollEdgeEffect getOverscrollEdgeEffect();

  /// Get a matrix for transforming from page coordinates to screen coordinates.
  // void getPageToScreenMatrix(Matrix matrix);

  /// Get a matrix for transforming from page coordinates to surface coordinates.
  // void getPageToSurfaceMatrix(Matrix matrix);

  /// Get the PanZoomController instance for this session.
  // PanZoomController getPanZoomController();

  /// Get the SessionPdfFileSaver instance for this session, to save a pdf document.
  // SessionPdfFileSaver getPdfFileSaver();

  /// Get the current permission delegate for this GeckoSession.
  GeckoSessionPermissionDelegate? getPermissionDelegate();

  /// Gets the print delegate for this session.
  // GeckoSessionPrintDelegate? getPrintDelegate();

  /// Get the progress callback handler.
  GeckoSessionProgressDelegate? getProgressDelegate();

  /// Get the current prompt delegate for this GeckoSession.
  GeckoSessionPromptDelegate? getPromptDelegate();

  /// Get the current scroll callback handler.
  // GeckoSessionScrollDelegate? getScrollDelegate();

  /// Get the current selection action delegate for this GeckoSession.
  // GeckoSessionSelectionActionDelegate? getSelectionActionDelegate();

  /// Get the page extractor for this GeckoSession.
  // PageExtractionControllerSessionPageExtractor getSessionPageExtractor();

  /// The session translation object coordinates receiving and sending session messages with the translations toolkit.
  // TranslationsControllerSessionTranslation getSessionTranslation();

  /// Get the bounds of the client area in surface coordinates.
  // void getSurfaceBounds(Rect rect);

  /// Get the SessionTextInput instance for this session.
  // SessionTextInput getTextInput();

  /// Get the translations delegate.
  // TranslationsControllerSessionTranslationDelegate
  // getTranslationsSessionDelegate();

  /// Get the current user agent string for this GeckoSession.
  @async
  String? getUserAgent();

  /// Get the web compatibility info when a site is reported as broken.
  @async
  String? getWebCompatInfo();

  /// Go back in history and assumes the call was based on a user interaction.
  void goBack();

  /// Go back in history.
  // void goBack(bool userInteraction);

  /// Go forward in history and assumes the call was based on a user interaction.
  void goForward();

  /// Go forward in history.
  // void goForward(bool userInteraction);

  /// Navigate to an index in browser history; the index of the currently viewed page can be retrieved from an up-to-date HistoryList by calling GeckoSession.HistoryDelegate.HistoryList.getCurrentIndex().
  void gotoHistoryIndex(int index);

  /// Checks whether we have a rule for this session.
  @async
  bool? hasCookieBannerRuleForBrowsingContextTree();

  /// Return whether this session is open.
  bool isOpen();

  /// Check if the document being viewed is a pdf.
  @async
  bool? isPdfJs();

  /// Load page using the GeckoSession.Loader specified.
  void load(GeckoSessionLoader request);

  /// Load the given URI.
  void loadUri(String uri);

  /// Opens the session.
  void open(GeckoRuntime runtime);

  /// Prints the currently displayed page.
  void printPageContent();

  /// Handle back key pressed on Web content to dismiss some HTML elements such as <dialog>.
  // @async
  // bool? processBackPressed();

  /// Purge history for the session.
  void purgeHistory();

  /// Determine if the current page uses a qualified website authentication certificate (QWAC).
  // @async
  // X509Certificate qwacStatus();

  /// Release an acquired GeckoDisplay instance.
  // void releaseDisplay(GeckoDisplay display);

  /// Reload the current URI.
  void reload();

  /// Reload the current URI.
  // void reload(int flags);

  /// Restore a saved state to this GeckoSession; only data that is saved (history, scroll position, zoom, and form data) will be restored.
  // void restoreState(GeckoSessionSessionState state);

  /// Saves a PDF of the currently displayed page.
  // @async
  // InputStream saveAsPdf();

  /// Send more web compatibility info when a site is reported as broken.
  @async
  void sendMoreWebCompatInfo(String info);

  /// Set this GeckoSession as active or inactive, which represents if the session is currently visible or not.
  void setActive(bool active);

  /// Sets the autofill delegate for this session.
  // void setAutofillDelegate(AutofillDelegate delegate);

  /// Set the compositor scroll callback handler.
  // void setCompositorScrollDelegate(
  //   GeckoSessionCompositorScrollDelegate delegate,
  // );

  /// Set the content blocking callback handler.
  // void setContentBlockingDelegate(ContentBlockingDelegate delegate);

  /// Set the content callback handler.
  void setContentDelegate(GeckoSessionContentDelegate delegate);

  /// Sets the experiment delegate for this session.
  // void setExperimentDelegate(ExperimentDelegate delegate);

  /// Move focus to this session or away from this session.
  void setFocused(bool focused);

  /// Set the history tracking delegate for this session, replacing the current delegate if one is set.
  // void setHistoryDelegate(GeckoSessionHistoryDelegate delegate);

  /// Set the media callback handler.
  // void setMediaDelegate(GeckoSessionMediaDelegate delegate);

  /// Set the media session delegate.
  // void setMediaSessionDelegate(MediaSessionDelegate delegate);

  /// Set the navigation callback handler.
  void setNavigationDelegate(GeckoSessionNavigationDelegate delegate);

  /// Set the current permission delegate for this GeckoSession.
  void setPermissionDelegate(GeckoSessionPermissionDelegate delegate);

  /// Sets the print delegate for this session.
  // void setPrintDelegate(GeckoSessionPrintDelegate delegate);

  /// Notify GeckoView of the priority for this GeckoSession.
  void setPriorityHint(int priorityHint);

  /// Set the progress callback handler.
  void setProgressDelegate(GeckoSessionProgressDelegate delegate);

  /// Set the content scroll callback handler.
  // void setScrollDelegate(GeckoSessionScrollDelegate delegate);

  /// Set the current selection action delegate for this GeckoSession.
  // void setSelectionActionDelegate(GeckoSessionSelectionActionDelegate delegate);

  /// Set the translation delegate, which receives translations events.
  // void setTranslationsSessionDelegate(
  //   TranslationsControllerSessionTranslationDelegate delegate,
  // );

  /// Stop loading.
  void stop();
}

@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'org.mozilla.geckoview.GeckoSession.Loader',
  ),
)
abstract class GeckoSessionLoader {
  GeckoSessionLoader();

  /// Add headers for this load.
  GeckoSessionLoader additionalHeaders(Map<String, String> headers);

  /// Set the app link intent launch type for this load.
  // GeckoSessionLoader appLinkLaunchType(int appLinkLaunchType);

  /// Set the data URI of the resource to load.
  GeckoSessionLoader bytes(Uint8List bytes, String mimeType);

  /// Set the data URI of the resource to load.
  GeckoSessionLoader string(String data, String mimeType);

  /// Set the load flags for this load.
  GeckoSessionLoader flags(int flags);

  /// Modify the header filter behavior.
  GeckoSessionLoader headerFilter(int filter);

  /// If this load originates from the address bar, sets the original user input before it got fixed up to a URI.
  GeckoSessionLoader originalInput(String originalInput);

  /// Set the referrer for this load.
  // GeckoSessionLoader referrerUri(Uri referrerUri);

  /// Set the referrer for this load.
  GeckoSessionLoader referrerUri(String referrerUri);

  /// Set the referrer for this load.
  GeckoSessionLoader referrer(GeckoSession referrer);

  /// Set the text directive user activation for the document opened in the window.
  GeckoSessionLoader textDirectiveUserActivation(
    bool textDirectiveUserActivation,
  );

  /// Set the URI of the resource to load.
  // GeckoSessionLoader uri(Uri uri);

  /// Set the URI of the resource to load.
  GeckoSessionLoader uri(String uri);
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

@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'org.mozilla.geckoview.GeckoSession.PermissionDelegate',
  ),
)
abstract class GeckoSessionPermissionDelegate {
  GeckoSessionPermissionDelegate();

  /// Request Android app permissions.
  late void Function(
    GeckoSession session,
    List<String> permissions,
    GeckoSessionPermissionDelegateCallback callback,
  )?
  onAndroidPermissionsRequest;

  /// Request content permission.
  // late GeckoResult<int> Function(
  //   GeckoSession session,
  //   GeckoSessionPermissionDelegateContentPermission perm,
  // )?
  // onContentPermissionRequest;

  /// Request content media permissions, including request for which video and/or audio source to use.
  // late void Function(
  //   GeckoSession session,
  //   List<GeckoSessionPermissionDelegateMediaSource> video,
  //   List<GeckoSessionPermissionDelegateMediaSource> audio,
  //   GeckoSessionPermissionDelegateMediaCallback callback,
  // )?
  // onMediaPermissionRequest;
}

@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName:
        'org.mozilla.geckoview.GeckoSession.PermissionDelegate.Callback',
  ),
)
abstract class GeckoSessionPermissionDelegateCallback {
  /// Called by the implementation after permissions are granted; the implementation must call either grant() or reject() for every request.
  void grant();

  /// Called by the implementation when permissions are not granted; the implementation must call either grant() or reject() for every request.
  void reject();
}

@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'org.mozilla.geckoview.GeckoSession.PromptDelegate',
  ),
)
abstract class GeckoSessionPromptDelegate {
  GeckoSessionPromptDelegate();
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
