package dev.zeekr.webview_flutter_geckoview

import org.json.JSONObject

class JSONObjectProxyApi(pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiJSONObject(pigeonRegistrar) {
    override fun pigeon_defaultConstructor(): JSONObject {
        return JSONObject()
    }

    override fun fromJSONString(json: String): JSONObject {
        return JSONObject(json)
    }

    override fun toJSONString(pigeon_instance: JSONObject): String {
        return pigeon_instance.toString()
    }
}