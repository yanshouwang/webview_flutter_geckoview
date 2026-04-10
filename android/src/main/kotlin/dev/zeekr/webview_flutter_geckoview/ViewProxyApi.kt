package dev.zeekr.webview_flutter_geckoview

import android.view.View

class ViewProxyApi(pigeonRegistrar: ProxyApiRegistrar) : PigeonApiView(pigeonRegistrar) {
    override fun setBackgroundColor(pigeon_instance: View, color: Long) {
        pigeon_instance.setBackgroundColor(color.toInt())
    }
}