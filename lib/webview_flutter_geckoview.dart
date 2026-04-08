
import 'webview_flutter_geckoview_platform_interface.dart';

class WebviewFlutterGeckoview {
  Future<String?> getPlatformVersion() {
    return WebviewFlutterGeckoviewPlatform.instance.getPlatformVersion();
  }
}
