package dev.zeekr.webview_flutter_geckoview

import android.view.View
import io.flutter.plugin.platform.PlatformView
import org.mozilla.geckoview.GeckoSession
import org.mozilla.geckoview.GeckoView

class GeckoViewProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) : PigeonApiGeckoView(pigeonRegistrar) {
    override fun pigeon_defaultConstructor(): GeckoView {
        return object : GeckoView(pigeonRegistrar.context), PlatformView {
            override fun getView(): View = this
            override fun dispose() {}
        }
    }

    override fun setSession(pigeon_instance: GeckoView, session: GeckoSession) {
        pigeon_instance.setSession(session)
    }
}