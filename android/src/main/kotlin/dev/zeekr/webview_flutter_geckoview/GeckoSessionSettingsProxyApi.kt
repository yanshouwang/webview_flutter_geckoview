package dev.zeekr.webview_flutter_geckoview

import org.mozilla.geckoview.GeckoSessionSettings

class GeckoSessionSettingsProxyApi(pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiGeckoSessionSettings(pigeonRegistrar) {
    override fun setAllowJavascript(pigeon_instance: GeckoSessionSettings, value: Boolean) {
        pigeon_instance.allowJavascript = value
    }
}