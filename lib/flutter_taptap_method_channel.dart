import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_taptap_platform_interface.dart';

class MethodChannelFlutterTaptap extends FlutterTaptapPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_taptap');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<void> init({
    required String clientId,
    required String clientToken,
    TapTapRegion region = TapTapRegion.cn,
    int screenOrientation = 1,
    bool enableLog = false,
  }) async {
    await methodChannel.invokeMethod<void>(
      'init',
      {
        'clientId': clientId,
        'clientToken': clientToken,
        'region': region == TapTapRegion.cn ? 'CN' : 'GLOBAL',
        'screenOrientation': screenOrientation,
        'enableLog': enableLog,
      },
    );
  }
}