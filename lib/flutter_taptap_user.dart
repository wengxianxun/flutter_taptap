/// TapTap 用户信息模型
class TapTapUser {
  /// 用户在当前应用中的唯一标识
  /// 每个玩家在每个游戏中的 openId 都不一样
  final String openId;

  /// 用户在同一厂商所有应用中的唯一标识
  /// 一个玩家在同一个厂商的所有游戏中 unionId 是一样的
  final String unionId;

  /// 玩家在 TapTap 平台的昵称
  final String name;

  /// 玩家在 TapTap 平台的头像 url
  final String avatar;

  /// 玩家在 TapTap 平台的用户 token 信息
  final String accessToken;

  TapTapUser({
    required this.openId,
    required this.unionId,
    required this.name,
    required this.avatar,
    required this.accessToken,
  });

  /// 从 Map 创建 TapTapUser 实例
  factory TapTapUser.fromMap(Map<String, dynamic> map) {
    return TapTapUser(
      openId: map['openId'] as String? ?? '',
      unionId: map['unionId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      avatar: map['avatar'] as String? ?? '',
      accessToken: map['accessToken'] as String? ?? '',
    );
  }

  /// 转换为 Map
  Map<String, dynamic> toMap() {
    return {
      'openId': openId,
      'unionId': unionId,
      'name': name,
      'avatar': avatar,
      'accessToken': accessToken,
    };
  }

  @override
  String toString() {
    return 'TapTapUser(openId: $openId, unionId: $unionId, name: $name, avatar: $avatar, accessToken: $accessToken)';
  }
}
