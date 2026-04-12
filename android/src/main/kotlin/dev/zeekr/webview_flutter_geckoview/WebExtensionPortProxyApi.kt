package dev.zeekr.webview_flutter_geckoview

import org.json.JSONObject
import org.mozilla.geckoview.WebExtension

class WebExtensionPortProxyApi(pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiWebExtensionPort(pigeonRegistrar) {
    override fun disconnect(pigeon_instance: WebExtension.Port) {
        pigeon_instance.disconnect()
    }

    override fun postMessage(pigeon_instance: WebExtension.Port, message: JSONObject) {
        pigeon_instance.postMessage(message)
    }

    override fun setDelegate(pigeon_instance: WebExtension.Port, delegate: WebExtension.PortDelegate) {
        pigeon_instance.setDelegate(delegate)
    }
}