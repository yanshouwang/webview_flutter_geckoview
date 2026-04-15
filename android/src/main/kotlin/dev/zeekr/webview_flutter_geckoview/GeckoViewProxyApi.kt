package dev.zeekr.webview_flutter_geckoview

import android.view.View
import io.flutter.plugin.platform.PlatformView
import org.mozilla.geckoview.GeckoSession
import org.mozilla.geckoview.GeckoView

class GeckoViewProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiGeckoView(pigeonRegistrar) {
    override fun pigeon_defaultConstructor(): GeckoView {
        return object : GeckoView(pigeonRegistrar.context), PlatformView {
            init {
                val runtime = pigeonRegistrar.geckoRuntime
                val session = GeckoSession().apply {
                    this.open(runtime)
                    this.setActive(true)
                    this.setFocused(true)
                }
                runtime.webExtensionController.setTabActive(session, true)
                this.setSession(session)
            }

            override fun getView(): View = this

            override fun dispose() {
                val session = this.releaseSession()
                session?.close()
            }
        }
    }

    override fun session(pigeon_instance: GeckoView): GeckoSession {
        return pigeon_instance.session ?: throw NullPointerException("session is null")
    }
}