package dev.zeekr.webview_flutter_geckoview

import org.mozilla.geckoview.GeckoSession

class GeckoSessionContentDelegateProxyApi(pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiGeckoSessionContentDelegate(pigeonRegistrar) {
    override fun pigeon_defaultConstructor(): GeckoSession.ContentDelegate {
        return object : GeckoSession.ContentDelegate {}
    }
}