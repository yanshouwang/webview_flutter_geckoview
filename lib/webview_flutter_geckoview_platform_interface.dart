import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'webview_flutter_geckoview_method_channel.dart';

abstract class WebviewFlutterGeckoviewPlatform extends PlatformInterface {
  /// Constructs a WebviewFlutterGeckoviewPlatform.
  WebviewFlutterGeckoviewPlatform() : super(token: _token);

  static final Object _token = Object();

  static WebviewFlutterGeckoviewPlatform _instance = MethodChannelWebviewFlutterGeckoview();

  /// The default instance of [WebviewFlutterGeckoviewPlatform] to use.
  ///
  /// Defaults to [MethodChannelWebviewFlutterGeckoview].
  static WebviewFlutterGeckoviewPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [WebviewFlutterGeckoviewPlatform] when
  /// they register themselves.
  static set instance(WebviewFlutterGeckoviewPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
