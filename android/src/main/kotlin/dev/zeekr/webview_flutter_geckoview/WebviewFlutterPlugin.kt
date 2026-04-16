package dev.zeekr.webview_flutter_geckoview

import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import org.mozilla.geckoview.GeckoResult
import org.mozilla.geckoview.GeckoRuntime
import org.mozilla.geckoview.WebExtension

/**
 * Java platform implementation of the webview_flutter plugin.
 *
 * <p>Register this in an add to app scenario to gracefully handle activity and context changes.
 */
class WebviewFlutterPlugin : FlutterPlugin {
    companion object {
        var geckoRuntime: GeckoRuntime? = null
        val webExtensionPort by lazy { GeckoResult<WebExtension.Port>() }
    }

    lateinit var proxyApiRegistrar: ProxyApiRegistrar

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        proxyApiRegistrar = ProxyApiRegistrar(
            binding.binaryMessenger,
            binding.applicationContext,
            geckoRuntime ?: GeckoRuntime.create(binding.applicationContext).apply {
                this.settings.consoleOutputEnabled = true
                this.webExtensionController.ensureBuiltIn(
                    "resource://android/assets/messaging/", "messaging@zeekr.dev"
                ).accept({
                    if (it == null) {
                        webExtensionPort.complete(null)
                    } else {
                        Handler(Looper.getMainLooper()).post {
                            it.setMessageDelegate(object : WebExtension.MessageDelegate {
                                override fun onConnect(webExtensionPort: WebExtension.Port) {
                                    super.onConnect(webExtensionPort)
                                    WebviewFlutterPlugin.webExtensionPort.complete(
                                        webExtensionPort
                                    )
                                }
                            }, "webview_flutter")
                        }
                    }
                }, {
                    val error = it ?: NullPointerException("throwable is null")
                    webExtensionPort.completeExceptionally(error)
                })
            }.also { geckoRuntime = it },
            webExtensionPort,
            FlutterAssetManager.PluginBindingFlutterAssetManager(
                binding.applicationContext.assets, binding.flutterAssets
            )
        )
        binding.platformViewRegistry.registerViewFactory(
            "plugins.flutter.io/webview", FlutterViewFactory(proxyApiRegistrar.instanceManager)
        )
        proxyApiRegistrar.setUp()
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        proxyApiRegistrar.tearDown()
        proxyApiRegistrar.instanceManager.stopFinalizationListener()
    }
}
