package dev.zeekr.webview_flutter_geckoview

import org.mozilla.geckoview.GeckoRuntime
import org.mozilla.geckoview.GeckoSession
import org.mozilla.geckoview.GeckoSessionSettings

class GeckoSessionProxyApi(pigeonRegistrar: ProxyApiRegistrar) : PigeonApiGeckoSession(pigeonRegistrar) {
    override fun pigeon_defaultConstructor(): GeckoSession {
        return GeckoSession()
    }

    override fun getSettings(pigeon_instance: GeckoSession): GeckoSessionSettings {
        return pigeon_instance.settings
    }

    override fun open(pigeon_instance: GeckoSession, runtime: GeckoRuntime) {
        pigeon_instance.open(runtime)
    }

    override fun setContentDelegate(pigeon_instance: GeckoSession, delegate: GeckoSession.ContentDelegate) {
        pigeon_instance.contentDelegate = delegate
    }

    override fun loadUri(pigeon_instance: GeckoSession, uri: String) {
        pigeon_instance.loadUri(uri)
    }
}