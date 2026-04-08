import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'webview_flutter_geckoview_platform_interface.dart';

/// An implementation of [WebviewFlutterGeckoviewPlatform] that uses method channels.
class MethodChannelWebviewFlutterGeckoview extends WebviewFlutterGeckoviewPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('webview_flutter_geckoview');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
