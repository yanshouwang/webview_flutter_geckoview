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
  void setAllowJavascript(bool value);
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
