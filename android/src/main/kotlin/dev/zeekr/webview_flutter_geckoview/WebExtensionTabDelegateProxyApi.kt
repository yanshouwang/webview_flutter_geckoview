package dev.zeekr.webview_flutter_geckoview

import org.mozilla.geckoview.GeckoResult
import org.mozilla.geckoview.GeckoSession
import org.mozilla.geckoview.WebExtension

val sessions = mutableListOf<GeckoSession>()

class WebExtensionTabDelegateProxyApi(pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiWebExtensionTabDelegate(pigeonRegistrar) {
    override fun pigeon_defaultConstructor(): WebExtension.TabDelegate {
        return object : WebExtension.TabDelegate {
            override fun onNewTab(
                source: WebExtension, createDetails: WebExtension.CreateTabDetails
            ): GeckoResult<GeckoSession> {
                val result = GeckoResult<GeckoSession>()
                this@WebExtensionTabDelegateProxyApi.onNewTab(this, source, createDetails) {
                    it.onSuccess { session -> result.complete(session) }
                        .onFailure { throwable -> result.completeExceptionally(throwable) }
                }
                return result
            }

            override fun onOpenOptionsPage(source: WebExtension) {
                super.onOpenOptionsPage(source)
                this@WebExtensionTabDelegateProxyApi.onOpenOptionsPage(this, source) {}
            }
        }
    }
}