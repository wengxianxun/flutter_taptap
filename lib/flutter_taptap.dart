import 'flutter_taptap_platform_interface.dart';
import 'model/flutter_taptap_user.dart';

export 'flutter_taptap_platform_interface.dart'
    show TapTapRegion, TapTapUser, LeaderboardResponse, Leaderboard, Score;

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
  /// 返回 [TapTapUser] 用户信息，包含以下字段：
  /// - openId: 用户在当前应用中的唯一标识，每个玩家在每个游戏中的 openId 都不一样
  /// - unionId: 用户在同一厂商所有应用中的唯一标识，一个玩家在同一个厂商的所有游戏中 unionId 是一样的
  /// - name: 玩家在 TapTap 平台的昵称
  /// - avatar: 玩家在 TapTap 平台的头像 url
  /// - accessToken: 玩家在 TapTap 平台的用户 token 信息
  ///
  /// 用户取消登录返回 null
  Future<TapTapUser?> login({List<String> scopes = const ['public_profile']}) {
    return FlutterTaptapPlatform.instance.login(scopes: scopes);
  }

  /// 获取当前登录用户信息
  ///
  /// 返回 [TapTapUser] 用户信息，包含以下字段：
  /// - openId: 用户在当前应用中的唯一标识，每个玩家在每个游戏中的 openId 都不一样
  /// - unionId: 用户在同一厂商所有应用中的唯一标识，一个玩家在同一个厂商的所有游戏中 unionId 是一样的
  /// - name: 玩家在 TapTap 平台的昵称
  /// - avatar: 玩家在 TapTap 平台的头像 url
  /// - accessToken: 玩家在 TapTap 平台的用户 token 信息
  ///
  /// 未登录返回 null
  Future<TapTapUser?> getCurrentUser() {
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

  /// 获取用户相近分数
  ///
  /// 查询当前用户相近的其他用户成绩（上下X位）
  ///
  /// [leaderboardId] 排行榜ID
  /// [leaderboardCollection] 排行榜类型，'PUBLIC' 为总榜，'FRIENDS' 为好友榜，默认为 'PUBLIC'
  /// [periodToken] 时间周期标识，如 'weekly'、'monthly'、'yearly'，默认为空
  /// [maxCount] 最大返回数量，默认为 10
  ///
  /// 返回 LeaderboardResponse 对象，包含：
  /// - leaderboard: 排行榜信息（id、name）
  /// - scores: 分数列表，每个元素为 Score 对象
  Future<LeaderboardResponse> loadPlayerCenteredScores({
    required String leaderboardId,
    String leaderboardCollection = 'PUBLIC',
    String periodToken = '',
    int maxCount = 10,
  }) {
    return FlutterTaptapPlatform.instance.loadPlayerCenteredScores(
      leaderboardId: leaderboardId,
      leaderboardCollection: leaderboardCollection,
      periodToken: periodToken,
      maxCount: maxCount,
    );
  }

  /// 注册实名回调
  ///
  /// [onResult] 回调函数，接收实名事件信息，包含 code 和 extra
  ///
  /// code 说明：
  /// - 500: LOGIN_SUCCESS - 玩家未受到限制，正常进入游戏
  /// - 1000: EXITED - 退出防沉迷认证及检查，游戏应返回登录页
  /// - 1001: SWITCH_ACCOUNT - 用户点击切换账号，游戏应返回登录页
  /// - 1030: PERIOD_RESTRICT - 用户当前时间无法进行游戏
  /// - 1050: DURATION_LIMIT - 用户无可玩时长
  /// - 1100: AGE_LIMIT - 当前用户因年龄限制无法进入游戏
  /// - 1200: INVALID_CLIENT_OR_NETWORK_ERROR - 数据请求失败
  /// - 9002: REAL_NAME_STOP - 用户关闭了实名窗，可重新开始认证
  Future<void> registerComplianceCallback({
    required Function(Map<String, dynamic>) onResult,
  }) {
    return FlutterTaptapPlatform.instance.registerComplianceCallback(
      onResult: onResult,
    );
  }

  /// 取消注册实名回调
  Future<void> unregisterComplianceCallback() {
    return FlutterTaptapPlatform.instance.unregisterComplianceCallback();
  }

  /// 开始防沉迷认证
  ///
  /// [userId] 玩家唯一标识，建议使用 TapTap 用户的 openId
  ///
  /// userId 格式要求：
  /// - 长度不大于 160
  /// - 只能包含：数字、大小写字母、下划线（_）、短横（-）、加号（+）、正斜线（/）、等号（=）、英文句号（.）、英文逗号（,）、英文冒号（:）
  Future<void> startCompliance({required String userId}) {
    return FlutterTaptapPlatform.instance.startCompliance(userId: userId);
  }

  /// 获取玩家当前剩余可玩时长
  ///
  /// 返回值说明：
  /// - >= 0: 剩余可玩时长（秒）
  /// - -1: 用户未登录或数据未初始化
  /// - -2: 用户不受时长限制（如成年人）
  Future<int> getRemainingTime() {
    return FlutterTaptapPlatform.instance.getRemainingTime();
  }
}
