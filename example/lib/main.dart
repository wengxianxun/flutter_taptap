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
      final result = await FlutterTaptap().login(
        scopes: ['public_profile'],
      );
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
        _userStatus = '已登录\n'
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
                ElevatedButton(
                  onPressed: _logout,
                  child: const Text('登出'),
                ),
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
                const SizedBox(height: 20),
                Text(_leaderboardStatus),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
