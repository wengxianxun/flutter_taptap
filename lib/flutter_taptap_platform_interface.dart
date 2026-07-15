import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_taptap_method_channel.dart';
import 'model/flutter_taptap_user.dart';
import 'model/flutter_taptap_leaderboard.dart';

export 'model/flutter_taptap_user.dart';
export 'model/flutter_taptap_leaderboard.dart';

enum TapTapRegion { cn, global }

abstract class FlutterTaptapPlatform extends PlatformInterface {
  FlutterTaptapPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterTaptapPlatform _instance = MethodChannelFlutterTaptap();

  static FlutterTaptapPlatform get instance => _instance;

  static set instance(FlutterTaptapPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> init({
    required String clientId,
    required String clientToken,
    TapTapRegion region = TapTapRegion.cn,
    int screenOrientation = 1,
    bool enableLog = false,
  }) {
    throw UnimplementedError('init() has not been implemented.');
  }

  Future<TapTapUser?> login({List<String> scopes = const ['public_profile']}) {
    throw UnimplementedError('login() has not been implemented.');
  }

  Future<TapTapUser?> getCurrentUser() {
    throw UnimplementedError('getCurrentUser() has not been implemented.');
  }

  Future<void> logout() {
    throw UnimplementedError('logout() has not been implemented.');
  }

  Future<void> openLeaderboard({
    required String leaderboardId,
    String type = 'public',
  }) {
    throw UnimplementedError('openLeaderboard() has not been implemented.');
  }

  Future<void> registerLeaderboardCallback({
    required Function(Map<String, dynamic>) onResult,
  }) {
    throw UnimplementedError(
      'registerLeaderboardCallback() has not been implemented.',
    );
  }

  Future<void> unregisterLeaderboardCallback() {
    throw UnimplementedError(
      'unregisterLeaderboardCallback() has not been implemented.',
    );
  }

  Future<void> setLeaderboardShareCallback() {
    throw UnimplementedError(
      'setLeaderboardShareCallback() has not been implemented.',
    );
  }

  Future<Map<String, dynamic>> submitScores(List<Map<String, dynamic>> scores) {
    throw UnimplementedError('submitScores() has not been implemented.');
  }

  Future<LeaderboardResponse> loadPlayerCenteredScores({
    required String leaderboardId,
    String leaderboardCollection = 'PUBLIC',
    String periodToken = '',
    int maxCount = 10,
  }) {
    throw UnimplementedError(
      'loadPlayerCenteredScores() has not been implemented.',
    );
  }

  Future<LeaderboardResponse> loadLeaderboardScores({
    required String leaderboardId,
    String leaderboardCollection = 'PUBLIC',
    String? nextPage,
  }) {
    throw UnimplementedError(
      'loadLeaderboardScores() has not been implemented.',
    );
  }

  Future<void> registerComplianceCallback({
    required Function(Map<String, dynamic>) onResult,
  }) {
    throw UnimplementedError(
      'registerComplianceCallback() has not been implemented.',
    );
  }

  Future<void> unregisterComplianceCallback() {
    throw UnimplementedError(
      'unregisterComplianceCallback() has not been implemented.',
    );
  }

  Future<void> startCompliance({required String userId}) {
    throw UnimplementedError('startCompliance() has not been implemented.');
  }

  Future<int> getRemainingTime() {
    throw UnimplementedError('getRemainingTime() has not been implemented.');
  }
}
