import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_taptap_platform_interface.dart';

class MethodChannelFlutterTaptap extends FlutterTaptapPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_taptap');

  Function(Map<String, dynamic>)? _leaderboardCallback;

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
    await methodChannel.invokeMethod<void>('init', {
      'clientId': clientId,
      'clientToken': clientToken,
      'region': region == TapTapRegion.cn ? 'CN' : 'GLOBAL',
      'screenOrientation': screenOrientation, //1横屏： 0竖屏
      'enableLog': enableLog,
    });
    // 设置方法调用处理器以接收回调
    methodChannel.setMethodCallHandler((call) async {
      if (call.method == 'onLeaderboardResult') {
        final result = call.arguments as Map<Object?, Object?>;
        _leaderboardCallback?.call(result.cast<String, dynamic>());
      }
      return null;
    });
  }

  @override
  Future<Map<String, dynamic>?> login({
    List<String> scopes = const ['public_profile'],
  }) async {
    final result = await methodChannel.invokeMethod<Map<Object?, Object?>>(
      'login',
      {'scopes': scopes},
    );
    return result?.cast<String, dynamic>();
  }

  @override
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final result = await methodChannel.invokeMethod<Map<Object?, Object?>>(
      'getCurrentUser',
    );
    return result?.cast<String, dynamic>();
  }

  @override
  Future<void> openLeaderboard({
    required String leaderboardId,
    String type = 'public',
  }) async {
    await methodChannel.invokeMethod<void>('openLeaderboard', {
      'leaderboardId': leaderboardId,
      'type': type,
    });
  }

  @override
  Future<void> registerLeaderboardCallback({
    required Function(Map<String, dynamic>) onResult,
  }) async {
    _leaderboardCallback = onResult;
    await methodChannel.invokeMethod<void>('registerLeaderboardCallback');
  }

  @override
  Future<void> unregisterLeaderboardCallback() async {
    _leaderboardCallback = null;
    await methodChannel.invokeMethod<void>('unregisterLeaderboardCallback');
  }

  @override
  Future<void> setLeaderboardShareCallback() async {
    await methodChannel.invokeMethod<void>('setLeaderboardShareCallback');
  }

  @override
  Future<Map<String, dynamic>> submitScores(
    List<Map<String, dynamic>> scores,
  ) async {
    final result = await methodChannel.invokeMethod<Map<Object?, Object?>>(
      'submitScores',
      {'scores': scores},
    );
    return result?.cast<String, dynamic>() ?? {};
  }
}
