import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_taptap/flutter_taptap.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String _loginResult = '';
  String _userStatus = '';
  String _leaderboardStatus = '';
  String _complianceStatus = '';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      FlutterTaptap().init(
        clientId: "rzdzhht8quqietjakk",
        clientToken: "lHgdgRrR7AvirdOSQfSb1ddJ9HYwgt8qKSf9uWuo",
        screenOrientation: 0,
      );
      platformVersion =
          await FlutterTaptap().getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> _login() async {
    try {
      final result = await FlutterTaptap().login(scopes: ['public_profile']);
      if (result != null) {
        setState(() {
          _loginResult =
              '登录成功!\nopenId: ${result.openId}\nunionId: ${result.unionId}';
        });
      } else {
        setState(() {
          _loginResult = '用户取消登录';
        });
      }
    } on PlatformException catch (e) {
      setState(() {
        _loginResult = '登录失败: ${e.message}';
      });
    }
  }

  Future<void> _logout() async {
    try {
      await FlutterTaptap().logout();
      setState(() {
        _loginResult = '已登出';
        _userStatus = '';
      });
      print('登出成功');
    } on PlatformException catch (e) {
      setState(() {
        _loginResult = '登出失败: ${e.message}';
      });
    }
  }

  Future<void> _checkLoginStatus() async {
    final user = await FlutterTaptap().getCurrentUser();
    if (user != null) {
      setState(() {
        _userStatus =
            '已登录\n'
            'openId: ${user.openId}\n'
            'unionId: ${user.unionId}\n'
            'name: ${user.name}\n'
            'avatar: ${user.avatar}\n'
            'accessToken: ${user.accessToken}';
      });
      print('已登录 - openId: ${user.openId}, unionId: ${user.unionId}');
    } else {
      setState(() {
        _userStatus = '未登录';
      });
      print('未登录');
    }
  }

  Future<void> _registerLeaderboardCallback() async {
    try {
      await FlutterTaptap().registerLeaderboardCallback(
        onResult: (event) {
          final code = event['code'] as int;
          final message = event['message'] as String;

          setState(() {
            switch (code) {
              case 500102:
                _leaderboardStatus = '用户未登录，请先登录';
                break;
              default:
                _leaderboardStatus = '排行榜事件: code=$code, message=$message';
                break;
            }
          });
          print('排行榜事件: code=$code, message=$message');
        },
      );
      setState(() {
        _leaderboardStatus = '排行榜回调已注册';
      });
    } on PlatformException catch (e) {
      setState(() {
        _leaderboardStatus = '注册回调失败: ${e.message}';
      });
    }
  }

  Future<void> _unregisterLeaderboardCallback() async {
    try {
      await FlutterTaptap().unregisterLeaderboardCallback();
      setState(() {
        _leaderboardStatus = '排行榜回调已取消注册';
      });
    } on PlatformException catch (e) {
      setState(() {
        _leaderboardStatus = '取消注册回调失败: ${e.message}';
      });
    }
  }

  Future<void> _setLeaderboardShareCallback() async {
    try {
      await FlutterTaptap().setLeaderboardShareCallback();
      setState(() {
        _leaderboardStatus = '分享回调已设置';
      });
    } on PlatformException catch (e) {
      setState(() {
        _leaderboardStatus = '设置分享回调失败: ${e.message}';
      });
    }
  }

  Future<void> _openLeaderboard(String type) async {
    try {
      await FlutterTaptap().openLeaderboard(
        leaderboardId: 'xab1tc1s7am9vp9wxb',
        type: type,
      );
      setState(() {
        _leaderboardStatus = '正在打开${type == 'public' ? '总榜' : '好友榜'}...';
      });
    } on PlatformException catch (e) {
      setState(() {
        _leaderboardStatus = '打开排行榜失败: ${e.message}';
      });
    }
  }

  Future<void> _submitScores() async {
    try {
      // 先获取当前登录用户信息
      final user = await FlutterTaptap().getCurrentUser();
      if (user == null) {
        setState(() {
          _leaderboardStatus = '请先登录';
        });
        return;
      }

      // 使用当前用户ID提交分数
      final scores = [
        {'leaderboardId': 'xab1tc1s7am9vp9wxb', 'score': 7000},
      ];

      final result = await FlutterTaptap().submitScores(scores);
      if (result['success'] == true) {
        setState(() {
          _leaderboardStatus = '分数提交成功!';
        });
        print('分数提交成功');
      }
    } on PlatformException catch (e) {
      setState(() {
        _leaderboardStatus = '提交失败: ${e.message}';
      });
      print('提交失败: ${e.message}');
    }
  }

  Future<void> _loadPlayerCenteredScores() async {
    try {
      final result = await FlutterTaptap().loadPlayerCenteredScores(
        leaderboardId: 'xab1tc1s7am9vp9wxb',
        leaderboardCollection: 'PUBLIC',
        periodToken: 'weekly',
        maxCount: 10,
      );

      setState(() {
        _leaderboardStatus = '排行榜: ${result.leaderboard.name} (${result.scores.length}人)';
      });

      for (var score in result.scores) {
        print('排名: ${score.rank}, 分数: ${score.scoreDisplay}, 玩家: ${score.playerName} 头像: ${score.playerAvatar}');
      }
    } on PlatformException catch (e) {
      setState(() {
        _leaderboardStatus = '获取相近分数失败: ${e.message}';
      });
      print('获取相近分数失败: ${e.message}');
    }
  }

  Future<void> _registerComplianceCallback() async {
    try {
      await FlutterTaptap().registerComplianceCallback(
        onResult: (event) {
          final code = event['code'] as int;
          final extra = event['extra'] as Map<String, dynamic>?;

          setState(() {
            switch (code) {
              case 500: // LOGIN_SUCCESS
                _complianceStatus = '实名回调: 玩家未受到限制，正常进入游戏';
                break;
              case 1000: // EXITED
                _complianceStatus = '实名回调: 退出防沉迷认证，游戏应返回登录页';
                break;
              case 1001: // SWITCH_ACCOUNT
                _complianceStatus = '实名回调: 用户点击切换账号，游戏应返回登录页';
                break;
              case 1030: // PERIOD_RESTRICT
                _complianceStatus = '实名回调: 用户当前时间无法进行游戏';
                break;
              case 1050: // DURATION_LIMIT
                _complianceStatus = '实名回调: 用户无可玩时长';
                break;
              case 1100: // AGE_LIMIT
                _complianceStatus = '实名回调: 当前用户因年龄限制无法进入游戏';
                break;
              case 1200: // INVALID_CLIENT_OR_NETWORK_ERROR
                _complianceStatus = '实名回调: 数据请求失败，请检查应用信息和网络';
                break;
              case 9002: // REAL_NAME_STOP
                _complianceStatus = '实名回调: 用户关闭了实名窗，可重新开始认证';
                break;
              default:
                _complianceStatus = '实名回调: code=$code';
                break;
            }
          });

          print('实名回调 - code: $code, extra: $extra');
        },
      );
      setState(() {
        _complianceStatus = '实名回调已注册';
      });
    } on PlatformException catch (e) {
      setState(() {
        _complianceStatus = '注册实名回调失败: ${e.message}';
      });
    }
  }

  Future<void> _unregisterComplianceCallback() async {
    try {
      await FlutterTaptap().unregisterComplianceCallback();
      setState(() {
        _complianceStatus = '实名回调已取消注册';
      });
    } on PlatformException catch (e) {
      setState(() {
        _complianceStatus = '取消注册实名回调失败: ${e.message}';
      });
    }
  }

  Future<void> _startCompliance() async {
    try {
      // 获取当前用户的 openId 作为 userIdentifier
      final user = await FlutterTaptap().getCurrentUser();
      if (user == null) {
        setState(() {
          _complianceStatus = '请先登录';
        });
        return;
      }

      // 开始防沉迷认证
      await FlutterTaptap().startCompliance(userId: user.openId); //
      setState(() {
        _complianceStatus = '防沉迷认证已启动';
      });
    } on PlatformException catch (e) {
      setState(() {
        _complianceStatus = '启动防沉迷认证失败: ${e.message}';
      });
    }
  }

  Future<void> _getRemainingTime() async {
    try {
      final remainingTime = await FlutterTaptap().getRemainingTime();
      setState(() {
        if (remainingTime >= 0) {
          _complianceStatus = '剩余时长: ${remainingTime}秒';
        } else if (remainingTime == -1) {
          _complianceStatus = '剩余时长: 用户未登录或数据未初始化';
        } else if (remainingTime == -2) {
          _complianceStatus = '剩余时长: 用户不受时长限制';
        } else {
          _complianceStatus = '剩余时长获取失败';
        }
      });
    } on PlatformException catch (e) {
      setState(() {
        _complianceStatus = '获取剩余时长失败: ${e.message}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('TapTap插件示例')),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text('Running on: $_platformVersion\n'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _login,
                  child: const Text('TapTap登录'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(onPressed: _logout, child: const Text('登出')),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _checkLoginStatus,
                  child: const Text('检查登录状态'),
                ),
                const SizedBox(height: 20),
                Text(_loginResult),
                const SizedBox(height: 20),
                Text(_userStatus),
                const SizedBox(height: 40),
                const Divider(),
                const SizedBox(height: 20),
                const Text(
                  '排行榜功能',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _registerLeaderboardCallback,
                  child: const Text('注册排行榜回调'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _setLeaderboardShareCallback,
                  child: const Text('设置分享回调'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _openLeaderboard('public'),
                  child: const Text('打开总榜'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _openLeaderboard('friend'),
                  child: const Text('打开好友榜'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _submitScores,
                  child: const Text('提交分数'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _loadPlayerCenteredScores,
                  child: const Text('获取相近分数'),
                ),
                const SizedBox(height: 20),
                Text(_leaderboardStatus),
                const SizedBox(height: 40),
                const Divider(),
                const SizedBox(height: 20),
                const Text(
                  '实名回调功能',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _registerComplianceCallback,
                  child: const Text('注册实名回调'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _unregisterComplianceCallback,
                  child: const Text('取消注册实名回调'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _startCompliance,
                  child: const Text('开始防沉迷认证'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _getRemainingTime,
                  child: const Text('获取剩余时长'),
                ),
                const SizedBox(height: 20),
                Text(_complianceStatus),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
