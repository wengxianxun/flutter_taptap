import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_taptap_platform_interface.dart';
import 'model/flutter_taptap_leaderboard.dart';
import 'model/flutter_taptap_user.dart';

class MethodChannelFlutterTaptap extends FlutterTaptapPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_taptap');

  Function(Map<String, dynamic>)? _leaderboardCallback;
  Function(Map<String, dynamic>)? _complianceCallback;

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
      } else if (call.method == 'onComplianceResult') {
        final result = call.arguments as Map<Object?, Object?>;
        _complianceCallback?.call(result.cast<String, dynamic>());
      }
      return null;
    });
  }

  @override
  Future<TapTapUser?> login({
    List<String> scopes = const ['public_profile'],
  }) async {
    final result = await methodChannel.invokeMethod<Map<Object?, Object?>>(
      'login',
      {'scopes': scopes},
    );
    if (result == null) return null;
    return TapTapUser.fromMap(result.cast<String, dynamic>());
  }

  @override
  Future<TapTapUser?> getCurrentUser() async {
    final result = await methodChannel.invokeMethod<Map<Object?, Object?>>(
      'getCurrentUser',
    );
    if (result == null) return null;
    return TapTapUser.fromMap(result.cast<String, dynamic>());
  }

  @override
  Future<void> logout() async {
    await methodChannel.invokeMethod<void>('logout');
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

  @override
  Future<LeaderboardResponse> loadPlayerCenteredScores({
    required String leaderboardId,
    String leaderboardCollection = 'PUBLIC',
    String periodToken = '',
    int maxCount = 10,
  }) async {
    final result = await methodChannel
        .invokeMethod<Map<Object?, Object?>>('loadPlayerCenteredScores', {
          'leaderboardId': leaderboardId,
          'leaderboardCollection': leaderboardCollection,
          'periodToken': periodToken,
          'maxCount': maxCount,
        });
    final map = _castMap(result) ?? {};
    return LeaderboardResponse.fromMap(map);
  }

  Map<String, dynamic>? _castMap(Map<Object?, Object?>? map) {
    if (map == null) return null;
    final result = <String, dynamic>{};
    map.forEach((key, value) {
      final stringKey = key?.toString() ?? '';
      if (value is Map<Object?, Object?>) {
        result[stringKey] = _castMap(value);
      } else if (value is List<Object?>) {
        result[stringKey] = value.map((item) {
          if (item is Map<Object?, Object?>) {
            return _castMap(item);
          }
          return item;
        }).toList();
      } else {
        result[stringKey] = value;
      }
    });
    return result;
  }

  @override
  Future<void> registerComplianceCallback({
    required Function(Map<String, dynamic>) onResult,
  }) async {
    _complianceCallback = onResult;
    await methodChannel.invokeMethod<void>('registerComplianceCallback');
  }

  @override
  Future<void> unregisterComplianceCallback() async {
    _complianceCallback = null;
    await methodChannel.invokeMethod<void>('unregisterComplianceCallback');
  }

  @override
  Future<void> startCompliance({required String userId}) async {
    await methodChannel.invokeMethod<void>('startCompliance', {
      'userId': userId,
    });
  }

  @override
  Future<int> getRemainingTime() async {
    final result = await methodChannel.invokeMethod<int>('getRemainingTime');
    return result ?? -1;
  }
}
