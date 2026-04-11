package dev.zeekr.webview_flutter_geckoview

import org.mozilla.geckoview.GeckoSession

class GeckoSessionNavigationDelegateProxyApi(pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiGeckoSessionNavigationDelegate(pigeonRegistrar) {
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
        }
    }
}