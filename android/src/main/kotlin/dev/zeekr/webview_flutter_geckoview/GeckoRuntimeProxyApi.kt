package dev.zeekr.webview_flutter_geckoview

import org.mozilla.geckoview.GeckoRuntime

class GeckoRuntimeProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiGeckoRuntime(pigeonRegistrar) {
    companion object {
        var instance: GeckoRuntime? = null
    }

    override fun instance(): GeckoRuntime {
        return instance ?: GeckoRuntime.create(pigeonRegistrar.context).also { instance = it }
    }
}