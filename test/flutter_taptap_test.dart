import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_taptap/flutter_taptap.dart';
import 'package:flutter_taptap/flutter_taptap_platform_interface.dart';
import 'package:flutter_taptap/flutter_taptap_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterTaptapPlatform
    with MockPlatformInterfaceMixin
    implements FlutterTaptapPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterTaptapPlatform initialPlatform = FlutterTaptapPlatform.instance;

  test('$MethodChannelFlutterTaptap is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterTaptap>());
  });

  test('getPlatformVersion', () async {
    FlutterTaptap flutterTaptapPlugin = FlutterTaptap();
    MockFlutterTaptapPlatform fakePlatform = MockFlutterTaptapPlatform();
    FlutterTaptapPlatform.instance = fakePlatform;

    expect(await flutterTaptapPlugin.getPlatformVersion(), '42');
  });
}
