# flutter_taptap

TapTap SDK Flutter 插件，提供登录、排行榜等功能。

## 功能特性

- ✅ TapTap 登录
- ✅ 获取当前用户信息
- ✅ 登出功能
- ✅ 排行榜功能
  - 打开排行榜页面（总榜/好友榜）
  - 提交分数
  - 排行榜事件回调
  - 分享回调

## 安装

在 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  flutter_taptap: ^0.0.1
```

## 使用方法

### 1. 初始化 SDK

```dart
import 'package:flutter_taptap/flutter_taptap.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await FlutterTaptap().init(
    clientId: "your_client_id",
    clientToken: "your_client_token",
    region: TapTapRegion.cn, // 或 TapTapRegion.global
    screenOrientation: 1, // 0-自动，1-竖屏，2-横屏
    enableLog: false, // 是否开启日志
  );
  
  runApp(MyApp());
}
```

### 2. 登录

```dart
try {
  final result = await FlutterTaptap().login(
    scopes: ['public_profile'],
  );
  if (result != null) {
    print('登录成功: ${result['openId']}');
  } else {
    print('用户取消登录');
  }
} on PlatformException catch (e) {
  print('登录失败: ${e.message}');
}
```

### 3. 获取当前用户

```dart
final user = await FlutterTaptap().getCurrentUser();
if (user != null) {
  print('已登录: ${user['openId']}');
} else {
  print('未登录');
}
```

### 4. 登出

```dart
await FlutterTaptap().logout();
```

### 5. 排行榜功能

#### 打开排行榜

```dart
// 打开总榜
await FlutterTaptap().openLeaderboard(
  leaderboardId: 'your_leaderboard_id',
  type: 'public',
);

// 打开好友榜
await FlutterTaptap().openLeaderboard(
  leaderboardId: 'your_leaderboard_id',
  type: 'friend',
);
```

#### 提交分数

```dart
final scores = [
  {'leaderboardId': 'leaderboard_1', 'score': 1000},
  {'leaderboardId': 'leaderboard_2', 'score': 2000},
];

final result = await FlutterTaptap().submitScores(scores);
if (result['success'] == true) {
  print('分数提交成功');
}
```

#### 注册排行榜回调

```dart
await FlutterTaptap().registerLeaderboardCallback(
  onResult: (event) {
    final code = event['code'] as int;
    final message = event['message'] as String;
    
    if (code == 500102) {
      print('用户未登录');
    } else {
      print('事件: code=$code, message=$message');
    }
  },
);
```

#### 设置分享回调

```dart
await FlutterTaptap().setLeaderboardShareCallback();
```

## 平台配置

### Android

在 `android/app/build.gradle` 中添加：

```gradle
android {
    defaultConfig {
        manifestPlaceholders += [
            'taptapClientId': 'your_client_id'
        ]
    }
}
```

### iOS

在 `ios/Runner/Info.plist` 中添加：

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>taptap</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>tt{your_client_id}</string>
        </array>
    </dict>
</array>
```

## 注意事项

1. 使用前需要在 [TapTap 开发者中心](https://developer.taptap.cn/) 创建应用并获取 `clientId` 和 `clientToken`
2. 排行榜功能需要用户已登录
3. 请确保在 AndroidManifest.xml 和 Info.plist 中正确配置应用信息

## 许可证

MIT License

## 问题反馈

如有问题，请在 [GitHub Issues](https://github.com/yourusername/flutter_taptap/issues) 中提交。

