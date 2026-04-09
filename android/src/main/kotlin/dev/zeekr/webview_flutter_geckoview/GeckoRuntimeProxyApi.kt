package dev.zeekr.webview_flutter_geckoview

import org.mozilla.geckoview.GeckoRuntime

class GeckoRuntimeProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) : PigeonApiGeckoRuntime(pigeonRegistrar) {
    override fun create(): GeckoRuntime {
        return GeckoRuntime.create(pigeonRegistrar.context)
    }
}