package dev.zeekr.webview_flutter_geckoview

import org.mozilla.geckoview.GeckoSession

class GeckoSessionPromptDelegateProxyApi(pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiGeckoSessionPromptDelegate(pigeonRegistrar) {
    override fun pigeon_defaultConstructor(): GeckoSession.PromptDelegate {
        return object : GeckoSession.PromptDelegate {}
    }
}