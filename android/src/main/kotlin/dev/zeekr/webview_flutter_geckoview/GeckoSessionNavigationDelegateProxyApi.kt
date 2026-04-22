package dev.zeekr.webview_flutter_geckoview

import mozilla.components.browser.errorpages.ErrorPages
import mozilla.components.browser.errorpages.ErrorType
import org.mozilla.geckoview.AllowOrDeny
import org.mozilla.geckoview.GeckoResult
import org.mozilla.geckoview.GeckoSession
import org.mozilla.geckoview.WebRequestError

class GeckoSessionNavigationDelegateProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiGeckoSessionNavigationDelegate(pigeonRegistrar) {
    companion object {
        internal fun geckoErrorToErrorType(errorCode: Int) =
            when (errorCode) {
                WebRequestError.ERROR_UNKNOWN -> ErrorType.UNKNOWN
                WebRequestError.ERROR_SECURITY_SSL -> ErrorType.ERROR_SECURITY_SSL
                WebRequestError.ERROR_SECURITY_BAD_CERT -> ErrorType.ERROR_SECURITY_BAD_CERT
                WebRequestError.ERROR_NET_INTERRUPT -> ErrorType.ERROR_NET_INTERRUPT
                WebRequestError.ERROR_NET_TIMEOUT -> ErrorType.ERROR_NET_TIMEOUT
                WebRequestError.ERROR_CONNECTION_REFUSED -> ErrorType.ERROR_CONNECTION_REFUSED
                WebRequestError.ERROR_UNKNOWN_SOCKET_TYPE -> ErrorType.ERROR_UNKNOWN_SOCKET_TYPE
                WebRequestError.ERROR_REDIRECT_LOOP -> ErrorType.ERROR_REDIRECT_LOOP
                WebRequestError.ERROR_OFFLINE -> ErrorType.ERROR_OFFLINE
                WebRequestError.ERROR_PORT_BLOCKED -> ErrorType.ERROR_PORT_BLOCKED
                WebRequestError.ERROR_NET_RESET -> ErrorType.ERROR_NET_RESET
                WebRequestError.ERROR_UNSAFE_CONTENT_TYPE -> ErrorType.ERROR_UNSAFE_CONTENT_TYPE
                WebRequestError.ERROR_CORRUPTED_CONTENT -> ErrorType.ERROR_CORRUPTED_CONTENT
                WebRequestError.ERROR_CONTENT_CRASHED -> ErrorType.ERROR_CONTENT_CRASHED
                WebRequestError.ERROR_INVALID_CONTENT_ENCODING -> ErrorType.ERROR_INVALID_CONTENT_ENCODING
                WebRequestError.ERROR_UNKNOWN_HOST -> ErrorType.ERROR_UNKNOWN_HOST
                WebRequestError.ERROR_MALFORMED_URI -> ErrorType.ERROR_MALFORMED_URI
                WebRequestError.ERROR_UNKNOWN_PROTOCOL -> ErrorType.ERROR_UNKNOWN_PROTOCOL
                WebRequestError.ERROR_FILE_NOT_FOUND -> ErrorType.ERROR_FILE_NOT_FOUND
                WebRequestError.ERROR_FILE_ACCESS_DENIED -> ErrorType.ERROR_FILE_ACCESS_DENIED
                WebRequestError.ERROR_PROXY_CONNECTION_REFUSED -> ErrorType.ERROR_PROXY_CONNECTION_REFUSED
                WebRequestError.ERROR_UNKNOWN_PROXY_HOST -> ErrorType.ERROR_UNKNOWN_PROXY_HOST
                WebRequestError.ERROR_SAFEBROWSING_MALWARE_URI -> ErrorType.ERROR_SAFEBROWSING_MALWARE_URI
                WebRequestError.ERROR_SAFEBROWSING_UNWANTED_URI -> ErrorType.ERROR_SAFEBROWSING_UNWANTED_URI
                WebRequestError.ERROR_SAFEBROWSING_HARMFUL_URI -> ErrorType.ERROR_SAFEBROWSING_HARMFUL_URI
                WebRequestError.ERROR_SAFEBROWSING_PHISHING_URI -> ErrorType.ERROR_SAFEBROWSING_PHISHING_URI
                WebRequestError.ERROR_HTTPS_ONLY -> ErrorType.ERROR_HTTPS_ONLY
                WebRequestError.ERROR_BAD_HSTS_CERT -> ErrorType.ERROR_BAD_HSTS_CERT
                else -> ErrorType.UNKNOWN
            }
    }

    override fun pigeon_defaultConstructor(): GeckoSession.NavigationDelegate {
        return object : GeckoSession.NavigationDelegate {
            override fun onCanGoBack(session: GeckoSession, canGoBack: Boolean) {
                super.onCanGoBack(session, canGoBack)
                this@GeckoSessionNavigationDelegateProxyApi.onCanGoBack(this, session, canGoBack) {}
            }

            override fun onCanGoForward(session: GeckoSession, canGoForward: Boolean) {
                super.onCanGoForward(session, canGoForward)
                this@GeckoSessionNavigationDelegateProxyApi.onCanGoForward(this, session, canGoForward) {}
            }

            override fun onLoadError(
                session: GeckoSession,
                uri: String?,
                error: WebRequestError
            ): GeckoResult<String?> {
                val errorType = geckoErrorToErrorType(error.code)
                val errorUri = ErrorPages.createUrlEncodedErrorPage(pigeonRegistrar.context, errorType)
                return GeckoResult.fromValue(errorUri)
            }

            override fun onLoadRequest(
                session: GeckoSession,
                request: GeckoSession.NavigationDelegate.LoadRequest
            ): GeckoResult<AllowOrDeny> {
                val result = GeckoResult<AllowOrDeny>()
                this@GeckoSessionNavigationDelegateProxyApi.onLoadRequest(this, session, request) {
                    it.onSuccess { allowOrDeny ->
                        result.complete(
                            when (allowOrDeny) {
                                dev.zeekr.webview_flutter_geckoview.AllowOrDeny.ALLOW -> AllowOrDeny.ALLOW
                                dev.zeekr.webview_flutter_geckoview.AllowOrDeny.DENY -> AllowOrDeny.DENY
                            }
                        )
                    }
                        .onFailure { error -> result.completeExceptionally(error) }
                }
                return result
            }

            override fun onLocationChange(
                session: GeckoSession,
                url: String?,
                perms: List<GeckoSession.PermissionDelegate.ContentPermission>,
                hasUserGesture: Boolean
            ) {
                super.onLocationChange(session, url, perms, hasUserGesture)
                this@GeckoSessionNavigationDelegateProxyApi.onLocationChange(
                    this,
                    session,
                    url,
                    perms,
                    hasUserGesture
                ) {}
            }

            override fun onSubframeLoadRequest(
                session: GeckoSession,
                request: GeckoSession.NavigationDelegate.LoadRequest
            ): GeckoResult<AllowOrDeny> {
                val result = GeckoResult<AllowOrDeny>()
                this@GeckoSessionNavigationDelegateProxyApi.onLoadRequest(this, session, request) {
                    it.onSuccess { allowOrDeny ->
                        result.complete(
                            when (allowOrDeny) {
                                dev.zeekr.webview_flutter_geckoview.AllowOrDeny.ALLOW -> AllowOrDeny.ALLOW
                                dev.zeekr.webview_flutter_geckoview.AllowOrDeny.DENY -> AllowOrDeny.DENY
                            }
                        )
                    }
                        .onFailure { error -> result.completeExceptionally(error) }
                }
                return result
            }
        }
    }
}