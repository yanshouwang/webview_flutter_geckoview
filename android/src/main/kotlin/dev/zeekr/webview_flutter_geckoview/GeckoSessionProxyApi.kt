package dev.zeekr.webview_flutter_geckoview

import org.mozilla.geckoview.GeckoRuntime
import org.mozilla.geckoview.GeckoSession
import org.mozilla.geckoview.GeckoSessionSettings

class GeckoSessionProxyApi(pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiGeckoSession(pigeonRegistrar) {
    override fun pigeon_defaultConstructor(): GeckoSession {
        return GeckoSession()
    }

    override fun settings(pigeon_instance: GeckoSession): GeckoSessionSettings {
        return pigeon_instance.settings
    }

    override fun open(pigeon_instance: GeckoSession, runtime: GeckoRuntime) {
        pigeon_instance.open(runtime)
    }

    override fun setContentDelegate(pigeon_instance: GeckoSession, delegate: GeckoSession.ContentDelegate) {
        pigeon_instance.contentDelegate = delegate
    }

    override fun setProgressDelegate(pigeon_instance: GeckoSession, delegate: GeckoSession.ProgressDelegate) {
        pigeon_instance.progressDelegate = delegate
    }

    override fun setNavigationDelegate(pigeon_instance: GeckoSession, delegate: GeckoSession.NavigationDelegate) {
        pigeon_instance.navigationDelegate = delegate
    }

    override fun loadUri(pigeon_instance: GeckoSession, uri: String) {
        pigeon_instance.loadUri(uri)
    }

    override fun goBack(pigeon_instance: GeckoSession) {
        pigeon_instance.goBack()
    }

    override fun goForward(pigeon_instance: GeckoSession) {
        pigeon_instance.goForward()
    }

    override fun reload(pigeon_instance: GeckoSession) {
        pigeon_instance.reload()
    }

    override fun getUserAgent(pigeon_instance: GeckoSession, callback: (Result<String?>) -> Unit) {
        pigeon_instance.userAgent.accept({
            ResultCompat.success(it, callback)
        }, {
            val exception = it ?: return@accept
            ResultCompat.failure(exception, callback)
        })
    }
}