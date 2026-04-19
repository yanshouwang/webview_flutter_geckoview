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
enum AllowOrDeny { allow, deny }

/// The over-scroll mode for a view.
///
/// See https://developer.android.com/reference/android/view/View#OVER_SCROLL_ALWAYS.
enum OverScrollMode {
  /// Always allow a user to over-scroll this view, provided it is a view that
  /// can scroll.
  always,

  /// Allow a user to over-scroll this view only if the content is large enough
  /// to meaningfully scroll, provided it is a view that can scroll.
  ifContentScrolls,

  /// Never allow a user to over-scroll this view.
  never,

  /// The type is not recognized by this wrapper.
  unknown,
}

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

  /// Get the storage controller for this runtime.
  @attached
  late StorageController storageController;

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
    fullClassName: 'org.mozilla.geckoview.GeckoSession',
  ),
)
abstract class GeckoSession {
  GeckoSession();

  /// This provides the native `GeckoSession()` constructor
  /// as an async method to ensure the class is added to the InstanceManager.
  /// See https://github.com/flutter/flutter/issues/162437.
  @static
  GeckoSession createAsync();

  /// Get the default user agent for this GeckoView build.
  @static
  String getDefaultUserAgent();

  /// Get the PanZoomController instance for this session.
  @attached
  late PanZoomController panZoomController;

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
  // SessionAccessibility? getAccessibility();

  ///
  // AutofillDelegate? getAutofillDelegate();

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
  GeckoSessionScrollDelegate? getScrollDelegate();

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
  // TranslationsControllerSessionTranslationDelegate?
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

  /// Handle back key pressed on Web content to dismiss some HTML elements such as &lt;dialog&gt;.
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
  // void setAutofillDelegate(AutofillDelegate? delegate);

  /// Set the compositor scroll callback handler.
  // void setCompositorScrollDelegate(
  //   GeckoSessionCompositorScrollDelegate? delegate,
  // );

  /// Set the content blocking callback handler.
  // void setContentBlockingDelegate(ContentBlockingDelegate? delegate);

  /// Set the content callback handler.
  void setContentDelegate(GeckoSessionContentDelegate? delegate);

  /// Sets the experiment delegate for this session.
  // void setExperimentDelegate(ExperimentDelegate? delegate);

  /// Move focus to this session or away from this session.
  void setFocused(bool focused);

  /// Set the history tracking delegate for this session, replacing the current delegate if one is set.
  // void setHistoryDelegate(GeckoSessionHistoryDelegate? delegate);

  /// Set the media callback handler.
  // void setMediaDelegate(GeckoSessionMediaDelegate? delegate);

  /// Set the media session delegate.
  // void setMediaSessionDelegate(MediaSessionDelegate? delegate);

  /// Set the navigation callback handler.
  void setNavigationDelegate(GeckoSessionNavigationDelegate? delegate);

  /// Set the current permission delegate for this GeckoSession.
  void setPermissionDelegate(GeckoSessionPermissionDelegate? delegate);

  /// Sets the print delegate for this session.
  // void setPrintDelegate(GeckoSessionPrintDelegate? delegate);

  /// Notify GeckoView of the priority for this GeckoSession.
  void setPriorityHint(int priorityHint);

  /// Set the progress callback handler.
  void setProgressDelegate(GeckoSessionProgressDelegate? delegate);

  /// Set the current prompt delegate for this GeckoSession.
  void setPromptDelegate(GeckoSessionPromptDelegate? delegate);

  /// Set the content scroll callback handler.
  void setScrollDelegate(GeckoSessionScrollDelegate? delegate);

  /// Set the current selection action delegate for this GeckoSession.
  // void setSelectionActionDelegate(GeckoSessionSelectionActionDelegate? delegate);

  /// Set the translation delegate, which receives translations events.
  // void setTranslationsSessionDelegate(
  //   TranslationsControllerSessionTranslationDelegate? delegate,
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
  GeckoSessionLoader dataBytes(Uint8List bytes, String? mimeType);

  /// Set the data URI of the resource to load.
  GeckoSessionLoader dataString(String data, String? mimeType);

  /// Set the load flags for this load.
  GeckoSessionLoader flags(int flags);

  /// Modify the header filter behavior.
  GeckoSessionLoader headerFilter(int filter);

  /// If this load originates from the address bar, sets the original user input before it got fixed up to a URI.
  GeckoSessionLoader originalInput(String? originalInput);

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

  /// A page has requested to close
  late void Function(GeckoSession session)? onCloseRequest;

  /// A user has initiated the context menu via long-press.
  // late void Function(
  //   GeckoSession session,
  //   int screenX,
  //   int screenY,
  //   GeckoSessionContentDelegateContextElement element,
  // )?
  // onContextMenu;

  /// This method is called when a cookie banner was detected.
  late void Function(GeckoSession session)? onCookieBannerDetected;

  /// This method is called when a cookie banner was handled.
  late void Function(GeckoSession session)? onCookieBannerHandled;

  /// The content process hosting this GeckoSession has crashed.
  late void Function(GeckoSession session)? onCrash;

  /// This is fired when there is a response that cannot be handled by Gecko (e.g., a download).
  // late void Function(GeckoSession session, WebResponse response)?
  // onExternalResponse;

  /// Notification that the first content composition has occurred.
  late void Function(GeckoSession session)? onFirstComposite;

  /// Notification that the first content paint has occurred.
  late void Function(GeckoSession session)? onFirstContentfulPaint;

  /// A page has requested focus.
  late void Function(GeckoSession session)? onFocusRequest;

  /// A page has entered or exited full screen mode.
  late void Function(GeckoSession session, bool fullScreen)? onFullScreen;

  /// The app should hide its dynamic toolbar.
  late void Function(GeckoSession geckoSession)? onHideDynamicToolbar;

  /// The content process hosting this GeckoSession has been killed.
  late void Function(GeckoSession session)? onKill;

  /// A viewport-fit was discovered in the content or updated after the content.
  late void Function(GeckoSession session, String viewportFit)?
  onMetaViewportFitChange;

  /// Notification that the paint status has been reset.
  late void Function(GeckoSession session)? onPaintStatusReset;

  /// A page has requested to change pointer icon.
  // late void Function(GeckoSession session, PointerIcon icon)?
  // onPointerIconChange;

  /// A preview image was discovered in the content after the content loaded.
  late void Function(GeckoSession session, String previewImageUrl)?
  onPreviewImage;

  /// The app should display its dynamic toolbar, fully expanded to the height that was previously specified via GeckoView.setDynamicToolbarMaxHeight(int).
  late void Function(GeckoSession geckoSession)? onShowDynamicToolbar;

  /// A script has exceeded its execution timeout value
  // late GeckoResult<SlowScriptResponse> Function(
  //   GeckoSession geckoSession,
  //   String scriptFileName,
  // )?
  // onSlowScript;

  /// A page title was discovered in the content or updated after the content loaded.
  late void Function(GeckoSession session, String? title)? onTitleChange;

  /// This is fired when the loaded document has a valid Web App Manifest present.
  late void Function(GeckoSession session, String manifest)? onWebAppManifest;
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
  late String? Function(GeckoSession session, String uri, WebRequestError error)
  onLoadError;

  /// A request to open an URI.
  @async
  late AllowOrDeny Function(
    GeckoSession session,
    GeckoSessionNavigationDelegateLoadRequest request,
  )
  onLoadRequest;

  /// A view has started loading content from the network.
  late void Function(
    GeckoSession session,
    String? url,
    List<GeckoSessionPermissionDelegateContentPermission> perms,
    bool hasUserGesture,
  )?
  onLocationChange;

  /// A request has been made to open a new session.
  // late GeckoSession Function(GeckoSession session, String uri) onNewSession;

  /// A request to load a URI in a non-top-level context.
  @async
  late AllowOrDeny Function(
    GeckoSession session,
    GeckoSessionNavigationDelegateLoadRequest request,
  )
  onSubframeLoadRequest;
}

@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName:
        'org.mozilla.geckoview.GeckoSession.NavigationDelegate.LoadRequest',
  ),
)
abstract class GeckoSessionNavigationDelegateLoadRequest {
  /// True if there was an active user gesture when the load was requested.
  late final bool hasUserGesture;

  /// This load request was initiated by a direct navigation from the application.
  late final bool isDirectNavigation;

  /// True if and only if the request was triggered by an HTTP redirect.
  late final bool isRedirect;

  /// The target where the window has requested to open.
  late final int target;

  /// The URI of the origin page that triggered the load request.
  late final String? triggerUri;

  /// The URI to be loaded.
  late final String uri;
}

@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'org.mozilla.geckoview.WebRequestError',
  ),
)
abstract class WebRequestError {
  /// The error category, e.g.
  late final int category;

  /// The server certificate used.
  late final X509Certificate? certificate;

  /// The error code, e.g.
  late final int code;
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
  // late int Function(
  //   GeckoSession session,
  //   GeckoSessionPermissionDelegateContentPermission perm,
  // )
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
    fullClassName:
        'org.mozilla.geckoview.GeckoSession.PermissionDelegate.ContentPermission',
  ),
)
abstract class GeckoSessionPermissionDelegateContentPermission {
  /// The context ID associated with the permission if any.
  late final String? contextId;

  /// The type of this permission; one of PERMISSION_*.
  late final int permission;

  /// A boolean indicating whether this content permission is associated with private browsing.
  late final bool privateMode;

  /// The third party origin associated with the request; currently only used for storage access permission.
  late final String? thirdPartyOrigin;

  /// The URI associated with this content permission.
  late final String uri;

  /// The value of the permission; one of VALUE_.
  late final int value;
}

@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'org.mozilla.geckoview.GeckoSession.PromptDelegate',
  ),
)
abstract class GeckoSessionPromptDelegate {
  GeckoSessionPromptDelegate();

  /// Handle a address save prompt request.
  // late GeckoSessionPromptDelegatePromptResponse Function(
  //   GeckoSession session,
  //   GeckoSessionPromptDelegateAutocompleteRequest<AutocompleteAddressSaveOption>
  //   request,
  // )
  // onAddressSave;

  /// Handle a address selection prompt request.
  // late GeckoSessionPromptDelegatePromptResponse Function(
  //   GeckoSession session,
  //   GeckoSessionPromptDelegateAutocompleteRequest<
  //     AutocompleteAddressSelectOption
  //   >
  //   request,
  // )
  // onAddressSelect;

  /// Display an alert prompt.
  @async
  late GeckoSessionPromptDelegatePromptResponse Function(
    GeckoSession session,
    GeckoSessionPromptDelegateAlertPrompt prompt,
  )
  onAlertPrompt;

  /// Display an authorization prompt.
  @async
  late GeckoSessionPromptDelegatePromptResponse Function(
    GeckoSession session,
    GeckoSessionPromptDelegateAuthPrompt prompt,
  )
  onAuthPrompt;

  /// Display a onbeforeunload prompt.
  // late GeckoSessionPromptDelegatePromptResponse Function(
  //   GeckoSession session,
  //   GeckoSessionPromptDelegateBeforeUnloadPrompt prompt,
  // )
  // onBeforeUnloadPrompt;

  /// Display a button prompt.
  @async
  late GeckoSessionPromptDelegatePromptResponse Function(
    GeckoSession session,
    GeckoSessionPromptDelegateButtonPrompt prompt,
  )
  onButtonPrompt;

  /// Display a list/menu prompt.
  // late GeckoSessionPromptDelegatePromptResponse Function(
  //   GeckoSession session,
  //   GeckoSessionPromptDelegateChoicePrompt prompt,
  // )
  // onChoicePrompt;

  /// Display a color prompt.
  // late GeckoSessionPromptDelegatePromptResponse Function(
  //   GeckoSession session,
  //   GeckoSessionPromptDelegateColorPrompt prompt,
  // )
  // onColorPrompt;

  /// Handle a credit card save prompt request.
  // late GeckoSessionPromptDelegatePromptResponse Function(
  //   GeckoSession session,
  //   GeckoSessionPromptDelegateAutocompleteRequest<
  //     AutocompleteCreditCardSaveOption
  //   >
  //   request,
  // )
  // onCreditCardSave;

  /// Handle a credit card selection prompt request.
  // late GeckoSessionPromptDelegatePromptResponse Function(
  //   GeckoSession session,
  //   GeckoSessionPromptDelegateAutocompleteRequest<
  //     AutocompleteCreditCardSelectOption
  //   >
  //   request,
  // )
  // onCreditCardSelect;

  /// Display a date/time prompt.
  // late GeckoSessionPromptDelegatePromptResponse Function(
  //   GeckoSession session,
  //   GeckoSessionPromptDelegateDateTimePrompt prompt,
  // )
  // onDateTimePrompt;

  /// Display a file prompt.
  // late GeckoSessionPromptDelegatePromptResponse Function(
  //   GeckoSession session,
  //   GeckoSessionPromptDelegateFilePrompt prompt,
  // )
  // onFilePrompt;

  /// Display a folder upload prompt.
  // late GeckoSessionPromptDelegatePromptResponse Function(
  //   GeckoSession session,
  //   GeckoSessionPromptDelegateFolderUploadPrompt prompt,
  // )
  // onFolderUploadPrompt;

  /// Handle a login save prompt request.
  // late GeckoSessionPromptDelegatePromptResponse Function(
  //   GeckoSession session,
  //   GeckoSessionPromptDelegateAutocompleteRequest<AutocompleteLoginSaveOption>
  //   request,
  // )
  // onLoginSave;

  /// Handle a login selection prompt request.
  // late GeckoSessionPromptDelegatePromptResponse Function(
  //   GeckoSession session,
  //   GeckoSessionPromptDelegateAutocompleteRequest<AutocompleteLoginSelectOption>
  //   request,
  // )
  // onLoginSelect;

  /// Display a popup request prompt; this occurs when content attempts to open a new window in a way that doesn't appear to be the result of user input.
  // late GeckoSessionPromptDelegatePromptResponse Function(
  //   GeckoSession session,
  //   GeckoSessionPromptDelegatePopupPrompt prompt,
  // )
  // onPopupPrompt;

  /// Display a redirect request prompt; this occurs when a third-party frame attempts to redirect the top-level window in a way that doesn't appear to be the result of user input.
  // late GeckoSessionPromptDelegatePromptResponse Function(
  //   GeckoSession session,
  //   GeckoSessionPromptDelegateRedirectPrompt prompt,
  // )
  // onRedirectPrompt;

  /// Display a POST resubmission confirmation prompt.
  // late GeckoSessionPromptDelegatePromptResponse Function(
  //   GeckoSession session,
  //   GeckoSessionPromptDelegateRepostConfirmPrompt prompt,
  // )
  // onRepostConfirmPrompt;

  /// Handle a request for a client authentication certificate.
  // late GeckoSessionPromptDelegatePromptResponse Function(
  //   GeckoSession session,
  //   GeckoSessionPromptDelegateCertificateRequest request,
  // )
  // onRequestCertificate;

  /// Handle an Identity Credential Account selection prompt request.
  // late GeckoSessionPromptDelegatePromptResponse Function(
  //   GeckoSession session,
  //   GeckoSessionPromptDelegateIdentityCredentialAccountSelectorPrompt prompt,
  // )
  // onSelectIdentityCredentialAccount;

  /// Handle an Identity Credential Provider selection prompt request.
  // late GeckoSessionPromptDelegatePromptResponse Function(
  //   GeckoSession session,
  //   GeckoSessionPromptDelegateIdentityCredentialProviderSelectorPrompt prompt,
  // )
  // onSelectIdentityCredentialProvider;

  /// Display a share request prompt; this occurs when content attempts to use the WebShare API.
  // late GeckoSessionPromptDelegatePromptResponse Function(
  //   GeckoSession session,
  //   GeckoSessionPromptDelegate.SharePrompt prompt,
  // )
  // onSharePrompt;

  /// Handle an Identity Credential privacy policy prompt request.
  // late GeckoSessionPromptDelegatePromptResponse Function(
  //   GeckoSession session,
  //   GeckoSessionPromptDelegateIdentityCredentialPrivacyPolicyPrompt prompt,
  // )
  // onShowPrivacyPolicyIdentityCredential;

  /// Display a text prompt.
  @async
  late GeckoSessionPromptDelegatePromptResponse Function(
    GeckoSession session,
    GeckoSessionPromptDelegateTextPrompt prompt,
  )
  onTextPrompt;
}

@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName:
        'org.mozilla.geckoview.GeckoSession.PromptDelegate.BasePrompt',
  ),
)
abstract class GeckoSessionPromptDelegateBasePrompt {
  /// This dismisses the prompt without sending any meaningful information back to content.
  GeckoSessionPromptDelegatePromptResponse dismiss();

  /// Get the delegate for this prompt.
  // GeckoSessionPromptDelegatePromptInstanceDelegate getDelegate();

  /// This returns true if the prompt has already been confirmed or dismissed.
  bool isComplete();

  /// Set the delegate for this prompt.
  // void setDelegate(GeckoSessionPromptDelegatePromptInstanceDelegate delegate);
}

@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName:
        'org.mozilla.geckoview.GeckoSession.PromptDelegate.AlertPrompt',
  ),
)
abstract class GeckoSessionPromptDelegateAlertPrompt
    extends GeckoSessionPromptDelegateBasePrompt {
  /// The title of this prompt; may be null.
  late final String? title;

  /// The message to be displayed with this alert; may be null.
  late final String? message;
}

@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName:
        'org.mozilla.geckoview.GeckoSession.PromptDelegate.AuthPrompt',
  ),
)
abstract class GeckoSessionPromptDelegateAuthPrompt
    extends GeckoSessionPromptDelegateBasePrompt {
  /// The title of this prompt; may be null.
  late final String? title;

  /// The GeckoSession.PromptDelegate.AuthPrompt.AuthOptions that describe the type of authorization prompt.
  late final GeckoSessionPromptDelegateAuthPromptAuthOptions authOptions;

  /// The message to be displayed with this prompt; may be null.
  late final String? message;

  /// Confirms this prompt with just a password, returning the password to content.
  GeckoSessionPromptDelegatePromptResponse confirmWithPassword(String password);

  /// Confirms this prompt with a username and password, returning both to content.
  GeckoSessionPromptDelegatePromptResponse confirmWithUsernameAndPassword(
    String username,
    String password,
  );
}

@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName:
        'org.mozilla.geckoview.GeckoSession.PromptDelegate.AuthPrompt.AuthOptions',
  ),
)
abstract class GeckoSessionPromptDelegateAuthPromptAuthOptions {
  /// An int bit-field of GeckoSession.PromptDelegate.AuthPrompt.AuthOptions.Flags.
  late final int flags;

  /// An int, one of GeckoSession.PromptDelegate.AuthPrompt.AuthOptions.Level, indicating level of encryption.
  late final int level;

  /// A string containing the initial password.
  late final String? password;

  /// A string containing the URI for the auth request or null if unknown.
  late final String? uri;

  /// A string containing the initial username or null if password-only.
  late final String? username;
}

@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName:
        'org.mozilla.geckoview.GeckoSession.PromptDelegate.ButtonPrompt',
  ),
)
abstract class GeckoSessionPromptDelegateButtonPrompt
    extends GeckoSessionPromptDelegateBasePrompt {
  /// The title of this prompt; may be null.
  late final String? title;

  /// The message to be displayed with this prompt; may be null.
  late final String? message;

  /// Confirms this prompt, returning the selected button to content.
  GeckoSessionPromptDelegatePromptResponse confirm(int selection);
}

@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName:
        'org.mozilla.geckoview.GeckoSession.PromptDelegate.TextPrompt',
  ),
)
abstract class GeckoSessionPromptDelegateTextPrompt
    extends GeckoSessionPromptDelegateBasePrompt {
  /// The title of this prompt; may be null.
  late final String? title;

  /// The default value for the text field; may be null.
  late final String? defaultValue;

  /// The message to be displayed with this prompt; may be null.
  late final String? message;

  /// Confirms this prompt, returning the input text to content.
  GeckoSessionPromptDelegatePromptResponse confirm(String text);
}

@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName:
        'org.mozilla.geckoview.GeckoSession.PromptDelegate.PromptResponse',
  ),
)
abstract class GeckoSessionPromptDelegatePromptResponse {}

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
    fullClassName: 'org.mozilla.geckoview.GeckoSession.ScrollDelegate',
  ),
)
abstract class GeckoSessionScrollDelegate {
  GeckoSessionScrollDelegate();

  late void Function(GeckoSession session, int scrollX, int scrollY)?
  onScrollChanged;
}

@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'org.mozilla.geckoview.GeckoWebExecutor',
  ),
)
abstract class GeckoWebExecutor {
  GeckoWebExecutor(GeckoRuntime runtime);

  /// Send the given WebRequest.
  @async
  WebResponse? fetch(WebRequest request, int? flags);

  /// Resolves the specified host name.
  // @async
  // List<InetAddress> resolve(String host);

  ///This causes a speculative connection to be made to the host in the specified URI.
  void speculativeConnect(String uri);
}

@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'org.mozilla.geckoview.WebRequest',
  ),
)
abstract class WebRequest extends WebMessage {
  /// An unmodifiable Map of headers.
  late final Map<String, String> headers;

  /// The URI for the request or response.
  late final String uri;

  /// If true, do not use newer protocol features that might have interop problems on the Internet.
  late final bool beConservative;

  /// The body of the request.
  late final Uint8List? body;

  /// The cache mode for the request.
  late final int cacheMode;

  /// The HTTP method for the request.
  late final String method;

  /// The value of the Referer header for this request.
  late final String? referrer;
}

@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'org.mozilla.geckoview.WebRequest.Builder',
  ),
)
abstract class WebRequestBuilder {
  /// Construct a Builder instance with the specified URI.
  WebRequestBuilder(String uri);

  /// Add a HTTP header.
  WebRequestBuilder addHeader(String key, String value);

  /// Set the beConservative property.
  WebRequestBuilder beConservative(bool beConservative);

  /// Set the body.
  WebRequestBuilder bodyString(String? bodyString);

  /// Set the body.
  WebRequestBuilder bodyBytes(Uint8List? bytes);

  ///
  WebRequest build();

  /// Set the cache mode.
  WebRequestBuilder cacheMode(int mode);

  /// Set a HTTP header.
  WebRequestBuilder header(String key, String value);

  /// Set the HTTP method.
  WebRequestBuilder method(String method);

  /// Set the HTTP Referer header.
  WebRequestBuilder referrer(String referrer);

  /// Set the URI
  WebRequestBuilder uri(String uri);
}

@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'org.mozilla.geckoview.WebResponse',
  ),
)
abstract class WebResponse extends WebMessage {
  /// An unmodifiable Map of headers.
  late final Map<String, String> headers;

  /// The URI for the request or response.
  late final String uri;

  /// An InputStream containing the response body, if available.
  late final Uint8List? body;

  /// The server certificate used with this response, if any.
  late final X509Certificate? certificate;

  /// Whether or not this response was delivered via a secure connection.
  late final bool isSecure;

  /// A boolean indicating whether or not this response is the result of a redirection.
  late final bool redirected;

  /// Specifies that the contents should request to be opened in another Android application.
  late final bool requestExternalApp;

  /// Specifies that the app may skip requesting the download in the UI.
  late final bool skipConfirmation;

  /// The HTTP status code for the response, e.g.
  late final int statusCode;
}

@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'org.mozilla.geckoview.WebMessage',
  ),
)
abstract class WebMessage {}

/// A View that displays web pages.
///
/// See https://developer.android.com/reference/android/webkit/WebView.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'org.mozilla.geckoview.GeckoView',
  ),
)
abstract class GeckoView extends View {
  /// Construct a new GeckoView instance.
  GeckoView();

  /// This is called in response to an internal scroll in this view (i.e., the
  /// view scrolled its own contents).
  late void Function(int left, int top, int oldLeft, int oldTop)?
  onScrollChanged;

  /// Returns the current GeckoSession attached to this view.
  @attached
  late GeckoSession session;

  /// Retrieves the controller responsible for panning and zooming gestures.
  @attached
  late PanZoomController panZoomController;

  /// Returns the current GeckoSession attached to this view.
  // GeckoSession? getSession();

  /// Unsets the current session from this instance and returns it, if any.
  // GeckoSession? releaseSession();

  /// Attach a session to this view.
  // void setSession(GeckoSession session);

  /// Set which view should be used by this GeckoView instance to display content.
  void setViewBackend(int backend);
}

@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'org.mozilla.geckoview.PanZoomController',
  ),
)
abstract class PanZoomController {
  /// Get the current scroll factor.
  double getScrollFactor();

  /// Process a drag event.
  // bool onDragEvent(DragEvent event);

  /// Process a non-touch motion event through the pan-zoom controller.
  // void onMotionEvent(MotionEvent event);

  /// Process a touch event through the pan-zoom controller.
  // void onMouseEvent(MotionEvent event);

  /// Process a touch event through the pan-zoom controller.
  // void onTouchEvent(MotionEvent event);

  /// Process a touch event through the pan-zoom controller.
  // @async
  // PanZoomControllerInputResultDetail? onTouchEventForDetailResult(
  //   MotionEvent event,
  // );

  /// Scroll the document body by an offset from the current scroll position.
  void scrollBy(ScreenLength width, ScreenLength height, int? behavior);

  /// Scroll the document body to an absolute position.
  void scrollTo(ScreenLength width, ScreenLength height, int? behavior);

  /// Scroll to the bottom left corner of the screen.
  void scrollToBottom();

  /// Scroll to the top left corner of the screen.
  void scrollToTop();

  /// Set whether Gecko should generate long-press events.
  void setIsLongpressEnabled(bool isLongpressEnabled);

  /// Set the current scroll factor.
  void setScrollFactor(double factor);
}

@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'org.mozilla.geckoview.ScreenLength',
  ),
)
abstract class ScreenLength {
  /// Create a ScreenLength of the documents height.
  ScreenLength.bottom();

  /// Create a ScreenLength of a specific length.
  ScreenLength.fromPixels(double value);

  /// Create a ScreenLength that uses the visual viewport width as units.
  ScreenLength.fromVisualViewportHeight(double value);

  /// Create a ScreenLength that uses the visual viewport width as units.
  ScreenLength.fromVisualViewportWidth(double value);

  /// Create a ScreenLength of zero pixels length.
  ScreenLength.top();

  /// Create a ScreenLength of zero pixels length.
  ScreenLength.zero();

  /// Returns the unit type of the length The length can be one of the following: PIXEL, VISUAL_VIEWPORT_WIDTH, VISUAL_VIEWPORT_HEIGHT, DOCUMENT_WIDTH, DOCUMENT_HEIGHT
  int getType();

  /// Returns the scalar value used to calculate length.
  double getValue();
}

@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'org.mozilla.geckoview.StorageController',
  ),
)
abstract class StorageController {
  /// Clear data for all hosts.
  @async
  void clearData(int flags);

  /// Clear data for the given context ID.
  void clearDataForSessionContext(String contextId);

  /// Clear data owned by the given base domain (eTLD+1).
  @async
  void clearDataFromBaseDomain(String baseDomain, int flags);

  /// Clear data owned by the given host.
  @async
  void clearDataFromHost(String host, int flags);

  /// Get all currently stored permissions.
  // @async
  // List<GeckoSessionPermissionDelegateContentPermission> getAllPermissions();

  /// Gets the actual ContentBlocking.CBCookieBannerMode for the given uri and browsing mode.
  @async
  int? getCookieBannerModeForDomain(String uri, bool isPrivateBrowsing);

  /// Get all currently stored permissions for a given URI and default (unset) context ID, in normal mode This API will be deprecated in the future https://bugzilla.mozilla.org/show_bug.cgi?id=1797379
  // @async
  // List<GeckoSessionPermissionDelegateContentPermission> getPermissions(
  //   String uri,
  // );

  /// Get all currently stored permissions for a given URI and default (unset) context ID.
  // @async
  // List<GeckoSessionPermissionDelegateContentPermission> getPermissions(
  //   String uri,
  //   bool privateMode,
  // );

  /// Get all currently stored permissions for a given URI and context ID.
  // @async
  // List<GeckoSessionPermissionDelegateContentPermission> getPermissions(
  //   String uri,
  //   String contextId,
  //   bool privateMode,
  // );

  /// Removes a ContentBlocking.CBCookieBannerMode for the given uri and and browsing mode.
  @async
  void removeCookieBannerModeForDomain(String uri, bool isPrivateBrowsing);

  /// Set a permanent ContentBlocking.CBCookieBannerMode for the given uri in private mode.
  @async
  void setCookieBannerModeAndPersistInPrivateBrowsingForDomain(
    String uri,
    int mode,
  );

  /// Set a permanent ContentBlocking.CBCookieBannerMode for the given uri and browsing mode.
  @async
  void setCookieBannerModeForDomain(
    String uri,
    int mode,
    bool isPrivateBrowsing,
  );

  /// Set a new value for an existing permission.
  // void setPermission(
  //   GeckoSessionPermissionDelegateContentPermission perm,
  //   int value,
  // );

  /// Set a permanent value for a permission in a private browsing session.
  // void setPrivateBrowsingPermanentPermission(
  //   GeckoSessionPermissionDelegateContentPermission perm,
  //   int value,
  // );
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

  ///
  // WebExtensionControllerPromptDelegate? getPromptDelegate();

  /// List installed extensions for this GeckoRuntime.
  @async
  List<WebExtension>? list();

  /// Set the WebExtensionController.PromptDelegate for this instance.
  // void setPromptDelegate(WebExtensionControllerPromptDelegate? delegate);

  /// Notifies extensions about a active tab change over the `tabs.onActivated` event.
  void setTabActive(GeckoSession session, bool active);
}

@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'org.mozilla.geckoview.WebExtension',
  ),
)
abstract class WebExtension {
  /// Returns the delegate handling browsing-data operations for this extension.
  // WebExtensionBrowsingDataDelegate? getBrowsingDataDelegate();

  /// Get the download delegate for this extension.
  // WebExtensionDownloadDelegate? getDownloadDelegate();

  /// Get the tab delegate for this extension.
  WebExtensionTabDelegate? getTabDelegate();

  /// Set the Action delegate for this WebExtension.
  // void setActionDelegate(WebExtensionActionDelegate? delegate);

  /// Sets the delegate to handle browsing-data operations (clear, remove, get settings).
  // void setBrowsingDataDelegate(WebExtensionBrowsingDataDelegate? delegate);

  /// Set the download delegate for this extension.
  // void setDownloadDelegate(WebExtensionDownloadDelegate? delegate);

  /// Defines the message delegate for a Native App.
  void setMessageDelegate(
    WebExtensionMessageDelegate? delegate,
    String nativeApp,
  );

  /// Set the tab delegate for this extension.
  void setTabDelegate(WebExtensionTabDelegate? delegate);
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
    fullClassName: 'org.mozilla.geckoview.WebExtension.TabDelegate',
  ),
)
abstract class WebExtensionTabDelegate {
  WebExtensionTabDelegate();

  /// Called when tabs.create is invoked, this method returns a *newly-created* session that GeckoView will use to load the requested page on.
  @async
  late GeckoSession Function(
    WebExtension source,
    WebExtensionCreateTabDetails createDetails,
  )
  onNewTab;

  /// Called when runtime.openOptionsPage is invoked with options_ui.open_in_tab = false.
  late void Function(WebExtension source)? onOpenOptionsPage;
}

@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'org.mozilla.geckoview.WebExtension.CreateTabDetails',
  ),
)
abstract class WebExtensionCreateTabDetails {
  late final bool? active;
  late final String? cookieStoreId;
  late final bool? discarded;
  late final int? index;
  late final bool? openInReaderMode;
  late final bool? pinned;
  late final String? url;
}

@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'org.mozilla.geckoview.WebExtension.Port',
  ),
)
abstract class WebExtensionPort {
  @async
  @static
  WebExtensionPort? getAsync();

  /// WebExtension.MessageSender corresponding to this port.
  // @attached
  // late WebExtensionMessageSender sender;

  /// The application identifier of the MessageDelegate that opened this port.
  late final String name;

  /// Disconnects this port and notifies the other end.
  void disconnect();

  /// Post a message to the WebExtension connected to this WebExtension.Port instance.
  void postMessage(String message);

  /// Set a delegate for incoming messages through this WebExtension.Port.
  void setDelegate(WebExtensionPortDelegate? delegate);
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
  // WebExtensionActionDelegate? getActionDelegate(WebExtension extension);

  /// Get the message delegate for nativeApp.
  WebExtensionMessageDelegate? getMessageDelegate(
    WebExtension extension,
    String nativeApp,
  );

  /// Get the TabDelegate for the given extension.
  WebExtensionSessionTabDelegate? getTabDelegate(WebExtension extension);

  /// Set the Action delegate for this session.
  // void setActionDelegate(
  //   WebExtension extension,
  //   WebExtensionActionDelegate? delegate,
  // );

  /// Defines a message delegate for a Native App.
  void setMessageDelegate(
    WebExtension extension,
    WebExtensionMessageDelegate? delegate,
    String nativeApp,
  );

  /// Set the TabDelegate for this session.
  void setTabDelegate(
    WebExtension extension,
    WebExtensionSessionTabDelegate? delegate,
  );
}

@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'org.mozilla.geckoview.WebExtension.SessionTabDelegate',
  ),
)
abstract class WebExtensionSessionTabDelegate {
  WebExtensionSessionTabDelegate();

  late AllowOrDeny Function(WebExtension? source, GeckoSession session)
  onCloseTab;
  late AllowOrDeny Function(
    WebExtension extension,
    GeckoSession session,
    WebExtensionUpdateTabDetails details,
  )
  onUpdateTab;
}

@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'org.mozilla.geckoview.WebExtension.UpdateTabDetails',
  ),
)
abstract class WebExtensionUpdateTabDetails {
  /// Whether the tab should become active.
  late final bool? active;

  /// Whether the tab should be discarded automatically by the app when resources are low.
  late final bool? autoDiscardable;

  /// If true and the tab is not highlighted, it should become active by default.
  late final bool? highlighted;

  /// Whether the tab should be muted.
  late final bool? muted;

  /// Whether the tab should be pinned.
  late final bool? pinned;

  /// The url that the tab will be navigated to.
  late final String? url;
}

/// Represents a position on a web page.
///
/// This is a custom class created for convenience of the wrapper.
@ProxyApi()
abstract class GeckoViewPoint {
  late int x;
  late int y;
}

/// Provides access to the assets registered as part of the App bundle.
///
/// Convenience class for accessing Flutter asset resources.
@ProxyApi()
abstract class FlutterAssetManager {
  /// The global instance of the `FlutterAssetManager`.
  @static
  late FlutterAssetManager instance;

  /// Returns a String array of all the assets at the given path.
  ///
  /// Throws an IOException in case I/O operations were interrupted.
  List<String> list(String path);

  /// Gets the relative file path to the Flutter asset with the given name, including the file's
  /// extension, e.g., "myImage.jpg".
  ///
  /// The returned file path is relative to the Android app's standard asset's
  /// directory. Therefore, the returned path is appropriate to pass to
  /// Android's AssetManager, but the path is not appropriate to load as an
  /// absolute path.
  String getAssetFilePathByName(String name);
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
  void scrollTo(int x, int y);

  /// Move the scrolled position of your view.
  void scrollBy(int x, int y);

  /// Return the scrolled position of this view.
  GeckoViewPoint getScrollPosition();

  /// Define whether the vertical scrollbar should be drawn or not.
  ///
  /// The scrollbar is not drawn by default.
  void setVerticalScrollBarEnabled(bool enabled);

  /// Define whether the horizontal scrollbar should be drawn or not.
  ///
  /// The scrollbar is not drawn by default.
  void setHorizontalScrollBarEnabled(bool enabled);

  /// Set the over-scroll mode for this view.
  void setOverScrollMode(OverScrollMode mode);
}

/// Abstract class for managing a variety of identity certificates.
///
/// See https://developer.android.com/reference/java/security/cert/Certificate.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'java.security.cert.Certificate',
  ),
)
abstract class Certificate {
  /// The encoded form of this certificate.
  Uint8List getEncoded();
}

/// Abstract class for X.509 certificates.
///
/// This provides a standard way to access all the attributes of an X.509
/// certificate.
///
/// See https://developer.android.com/reference/java/security/cert/X509Certificate.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'java.security.cert.X509Certificate',
  ),
)
abstract class X509Certificate extends Certificate {}
