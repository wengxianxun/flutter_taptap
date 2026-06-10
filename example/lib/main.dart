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
  final _flutterTaptapPlugin = FlutterTaptap();

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
      _flutterTaptapPlugin.init(
        clientId: "rzdzhht8quqietjakk",
        clientToken: "lHgdgRrR7AvirdOSQfSb1ddJ9HYwgt8qKSf9uWuo",
      );
      platformVersion =
          await _flutterTaptapPlugin.getPlatformVersion() ??
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
      final result = await _flutterTaptapPlugin.login(scopes: ['public_profile']);
      if (result != null) {
        setState(() {
          _loginResult = '登录成功!\nopenId: ${result['openId']}\nunionId: ${result['unionId']}';
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

  Future<void> _checkLoginStatus() async {
    final user = await _flutterTaptapPlugin.getCurrentUser();
    if (user != null) {
      setState(() {
        _userStatus = '已登录\nopenId: ${user['openId']}\nunionId: ${user['unionId']}';
      });
      print('已登录 - openId: ${user['openId']}, unionId: ${user['unionId']}');
    } else {
      setState(() {
        _userStatus = '未登录';
      });
      print('未登录');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('TapTap登录插件示例')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Running on: $_platformVersion\n'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: const Text('TapTap登录'),
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
            ],
          ),
        ),
      ),
    );
  }
}
