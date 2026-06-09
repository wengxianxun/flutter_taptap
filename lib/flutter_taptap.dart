export 'flutter_taptap_platform_interface.dart' show TapTapRegion;

import 'flutter_taptap_platform_interface.dart';

class FlutterTaptap {
  Future<String?> getPlatformVersion() {
    return FlutterTaptapPlatform.instance.getPlatformVersion();
  }

  Future<void> init({
    required String clientId,
    required String clientToken,
    TapTapRegion region = TapTapRegion.cn,
    int screenOrientation = 1,
    bool enableLog = false,
  }) {
    return FlutterTaptapPlatform.instance.init(
      clientId: clientId,
      clientToken: clientToken,
      region: region,
      screenOrientation: screenOrientation,
      enableLog: enableLog,
    );
  }
}