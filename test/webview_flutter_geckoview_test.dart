import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter_geckoview/webview_flutter_geckoview.dart';
import 'package:webview_flutter_geckoview/webview_flutter_geckoview_platform_interface.dart';
import 'package:webview_flutter_geckoview/webview_flutter_geckoview_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockWebviewFlutterGeckoviewPlatform
    with MockPlatformInterfaceMixin
    implements WebviewFlutterGeckoviewPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final WebviewFlutterGeckoviewPlatform initialPlatform = WebviewFlutterGeckoviewPlatform.instance;

  test('$MethodChannelWebviewFlutterGeckoview is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelWebviewFlutterGeckoview>());
  });

  test('getPlatformVersion', () async {
    WebviewFlutterGeckoview webviewFlutterGeckoviewPlugin = WebviewFlutterGeckoview();
    MockWebviewFlutterGeckoviewPlatform fakePlatform = MockWebviewFlutterGeckoviewPlatform();
    WebviewFlutterGeckoviewPlatform.instance = fakePlatform;

    expect(await webviewFlutterGeckoviewPlugin.getPlatformVersion(), '42');
  });
}
