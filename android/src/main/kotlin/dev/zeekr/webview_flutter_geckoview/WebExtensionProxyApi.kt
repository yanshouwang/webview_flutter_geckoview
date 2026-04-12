package dev.zeekr.webview_flutter_geckoview

import org.mozilla.geckoview.WebExtension

class WebExtensionProxyApi(pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiWebExtension(pigeonRegistrar) {
    override fun setMessageDelegate(pigeon_instance: WebExtension, delegate: WebExtension.MessageDelegate, nativeApp: String) {
        pigeon_instance.setMessageDelegate(delegate, nativeApp)
    }
}