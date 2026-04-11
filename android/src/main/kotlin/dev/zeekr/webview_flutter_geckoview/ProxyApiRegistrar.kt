package dev.zeekr.webview_flutter_geckoview

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger

class ProxyApiRegistrar(binaryMessenger: BinaryMessenger, val context: Context) :
    MozillaGeckoviewLibraryPigeonProxyApiRegistrar(binaryMessenger) {
    override fun getPigeonApiGeckoRuntime(): PigeonApiGeckoRuntime {
        return GeckoRuntimeProxyApi(this)
    }

    override fun getPigeonApiGeckoSession(): PigeonApiGeckoSession {
        return GeckoSessionProxyApi(this)
    }

    override fun getPigeonApiGeckoSessionSettings(): PigeonApiGeckoSessionSettings {
        return GeckoSessionSettingsProxyApi(this)
    }

    override fun getPigeonApiGeckoSessionContentDelegate(): PigeonApiGeckoSessionContentDelegate {
        return GeckoSessionContentDelegateProxyApi(this)
    }

    override fun getPigeonApiGeckoSessionProgressDelegate(): PigeonApiGeckoSessionProgressDelegate {
        return GeckoSessionProgressDelegateProxyApi(this)
    }

    override fun getPigeonApiGeckoSessionNavigationDelegate(): PigeonApiGeckoSessionNavigationDelegate {
        return GeckoSessionNavigationDelegateProxyApi(this)
    }

    override fun getPigeonApiGeckoView(): PigeonApiGeckoView {
        return GeckoViewProxyApi(this)
    }

    override fun getPigeonApiView(): PigeonApiView {
        return ViewProxyApi(this)
    }
}