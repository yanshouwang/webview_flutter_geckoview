package dev.zeekr.webview_flutter_geckoview

import org.mozilla.geckoview.WebExtension

class WebExtensionSessionControllerProxyApi(pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiWebExtensionSessionController(pigeonRegistrar) {
    override fun getMessageDelegate(
        pigeon_instance: WebExtension.SessionController, extension: WebExtension, nativeApp: String
    ): WebExtension.MessageDelegate? {
        return pigeon_instance.getMessageDelegate(extension, nativeApp)
    }

    override fun setMessageDelegate(
        pigeon_instance: WebExtension.SessionController,
        extension: WebExtension,
        delegate: WebExtension.MessageDelegate,
        nativeApp: String
    ) {
        pigeon_instance.setMessageDelegate(extension, delegate, nativeApp)
    }
}