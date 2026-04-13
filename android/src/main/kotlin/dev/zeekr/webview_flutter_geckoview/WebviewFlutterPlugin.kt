package dev.zeekr.webview_flutter_geckoview

import io.flutter.embedding.engine.plugins.FlutterPlugin

/**
 * Java platform implementation of the webview_flutter plugin.
 *
 * <p>Register this in an add to app scenario to gracefully handle activity and context changes.
 */
class WebviewFlutterPlugin : FlutterPlugin {
    lateinit var proxyApiRegistrar: ProxyApiRegistrar

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        proxyApiRegistrar = ProxyApiRegistrar(
            binding.binaryMessenger,
            binding.applicationContext,
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
