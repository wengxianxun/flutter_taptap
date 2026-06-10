export 'flutter_taptap_platform_interface.dart' show TapTapRegion;

import 'flutter_taptap_platform_interface.dart';

class FlutterTaptap {

  // 单例实例
  static final FlutterTaptap _instance = FlutterTaptap._internal();
  
  // 工厂构造函数，返回单例实例
  factory FlutterTaptap() => _instance;
  
  // 私有构造函数
  FlutterTaptap._internal();

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

  Future<Map<String, dynamic>?> login({
    List<String> scopes = const ['public_profile'],
  }) {
    return FlutterTaptapPlatform.instance.login(scopes: scopes);
  }

  Future<Map<String, dynamic>?> getCurrentUser() {
    return FlutterTaptapPlatform.instance.getCurrentUser();
  }

  Future<void> openLeaderboard({
    required String leaderboardId,
    String type = 'public',
  }) {
    return FlutterTaptapPlatform.instance.openLeaderboard(
      leaderboardId: leaderboardId,
      type: type,
    );
  }

  Future<void> registerLeaderboardCallback({
    required Function(Map<String, dynamic>) onResult,
  }) {
    return FlutterTaptapPlatform.instance.registerLeaderboardCallback(
      onResult: onResult,
    );
  }

  Future<void> unregisterLeaderboardCallback() {
    return FlutterTaptapPlatform.instance.unregisterLeaderboardCallback();
  }

  Future<void> setLeaderboardShareCallback() {
    return FlutterTaptapPlatform.instance.setLeaderboardShareCallback();
  }

  Future<Map<String, dynamic>> submitScores(List<Map<String, dynamic>> scores) {
    return FlutterTaptapPlatform.instance.submitScores(scores);
  }
}