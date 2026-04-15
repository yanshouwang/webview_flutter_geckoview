package dev.zeekr.webview_flutter_geckoview

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import org.mozilla.geckoview.GeckoRuntime

class ProxyApiRegistrar(
    binaryMessenger: BinaryMessenger,
    val context: Context,
    val geckoRuntime: GeckoRuntime,
    val flutterAssetManager: FlutterAssetManager
) : GeckoLibraryPigeonProxyApiRegistrar(binaryMessenger) {
    override fun getPigeonApiGeckoRuntime(): PigeonApiGeckoRuntime {
        return GeckoRuntimeProxyApi(this)
    }

    override fun getPigeonApiGeckoRuntimeSettings(): PigeonApiGeckoRuntimeSettings {
        return GeckoRuntimeSettingsProxyApi(this)
    }

    override fun getPigeonApiWebExtensionController(): PigeonApiWebExtensionController {
        return WebExtensionControllerProxyApi(this)
    }

    override fun getPigeonApiWebExtension(): PigeonApiWebExtension {
        return WebExtensionProxyApi(this)
    }

    override fun getPigeonApiWebExtensionMessageDelegate(): PigeonApiWebExtensionMessageDelegate {
        return WebExtensionMessageDelegateProxyApi(this)
    }

    override fun getPigeonApiWebExtensionTabDelegate(): PigeonApiWebExtensionTabDelegate {
        return WebExtensionTabDelegateProxyApi(this)
    }

    override fun getPigeonApiWebExtensionCreateTabDetails(): PigeonApiWebExtensionCreateTabDetails {
        return WebExtensionCreateTabDetailsProxyApi(this)
    }

    override fun getPigeonApiWebExtensionPort(): PigeonApiWebExtensionPort {
        return WebExtensionPortProxyApi(this)
    }

    override fun getPigeonApiWebExtensionPortDelegate(): PigeonApiWebExtensionPortDelegate {
        return WebExtensionPortDelegateProxyApi(this)
    }

    override fun getPigeonApiWebExtensionSessionController(): PigeonApiWebExtensionSessionController {
        return WebExtensionSessionControllerProxyApi(this)
    }

    override fun getPigeonApiGeckoSession(): PigeonApiGeckoSession {
        return GeckoSessionProxyApi(this)
    }

    override fun getPigeonApiGeckoSessionLoader(): PigeonApiGeckoSessionLoader {
        return GeckoSessionLoaderProxyApi(this)
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

    override fun getPigeonApiGeckoSessionPermissionDelegate(): PigeonApiGeckoSessionPermissionDelegate {
        return GeckoSessionPermissionDelegateProxyApi(this)
    }

    override fun getPigeonApiGeckoSessionPermissionDelegateCallback(): PigeonApiGeckoSessionPermissionDelegateCallback {
        return GeckoSessionPermissionDelegateCallbackProxyApi(this)
    }

    override fun getPigeonApiGeckoSessionPromptDelegate(): PigeonApiGeckoSessionPromptDelegate {
        return GeckoSessionPromptDelegateProxyApi(this)
    }

    override fun getPigeonApiGeckoView(): PigeonApiGeckoView {
        return GeckoViewProxyApi(this)
    }

    override fun getPigeonApiView(): PigeonApiView {
        return ViewProxyApi(this)
    }

    override fun getPigeonApiFlutterAssetManager(): PigeonApiFlutterAssetManager {
        return FlutterAssetManagerProxyApi(this)
    }
}