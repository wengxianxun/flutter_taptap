export 'flutter_taptap_platform_interface.dart' show TapTapRegion;

import 'flutter_taptap_platform_interface.dart';

class FlutterTaptap {

  // 单例实例
  static final FlutterTaptap _instance = FlutterTaptap._internal();
  
  // 工厂构造函数，返回单例实例
  factory FlutterTaptap() => _instance;
  
  // 私有构造函数
  FlutterTaptap._internal();

  /// 获取平台版本信息
  Future<String?> getPlatformVersion() {
    return FlutterTaptapPlatform.instance.getPlatformVersion();
  }

  /// 初始化 TapTap SDK
  /// 
  /// [clientId] 应用客户端ID
  /// [clientToken] 应用客户端密钥
  /// [region] 服务器区域，默认为中国区
  /// [screenOrientation] 屏幕方向，0-自动，1-竖屏，2-横屏
  /// [enableLog] 是否开启日志，默认关闭
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

  /// TapTap 登录
  /// 
  /// [scopes] 权限作用域列表，默认为 ['public_profile']
  /// 返回用户信息 Map，包含 openId 和 unionId
  /// 用户取消登录返回 null
  Future<Map<String, dynamic>?> login({
    List<String> scopes = const ['public_profile'],
  }) {
    return FlutterTaptapPlatform.instance.login(scopes: scopes);
  }

  /// 获取当前登录用户信息
  /// 
  /// 返回用户信息 Map，包含 openId 和 unionId
  /// 未登录返回 null
  Future<Map<String, dynamic>?> getCurrentUser() {
    return FlutterTaptapPlatform.instance.getCurrentUser();
  }

  /// 登出当前用户
  Future<void> logout() {
    return FlutterTaptapPlatform.instance.logout();
  }

  /// 打开排行榜页面
  /// 
  /// [leaderboardId] 排行榜ID
  /// [type] 排行榜类型，'public' 为总榜，'friend' 为好友榜，默认为 'public'
  Future<void> openLeaderboard({
    required String leaderboardId,
    String type = 'public',
  }) {
    return FlutterTaptapPlatform.instance.openLeaderboard(
      leaderboardId: leaderboardId,
      type: type,
    );
  }

  /// 注册排行榜事件回调
  /// 
  /// [onResult] 回调函数，接收排行榜事件信息，包含 code 和 message
  Future<void> registerLeaderboardCallback({
    required Function(Map<String, dynamic>) onResult,
  }) {
    return FlutterTaptapPlatform.instance.registerLeaderboardCallback(
      onResult: onResult,
    );
  }

  /// 取消注册排行榜回调
  Future<void> unregisterLeaderboardCallback() {
    return FlutterTaptapPlatform.instance.unregisterLeaderboardCallback();
  }

  /// 设置排行榜分享回调
  Future<void> setLeaderboardShareCallback() {
    return FlutterTaptapPlatform.instance.setLeaderboardShareCallback();
  }

  /// 提交分数到排行榜
  /// 
  /// [scores] 分数列表，每个元素包含 leaderboardId 和 score
  /// 返回提交结果 Map，success 为 true 表示提交成功
  Future<Map<String, dynamic>> submitScores(List<Map<String, dynamic>> scores) {
    return FlutterTaptapPlatform.instance.submitScores(scores);
  }
}