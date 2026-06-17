import Flutter
import UIKit
import TapTapCoreSDK
import TapTapLoginSDK
import TapTapLeaderboardSDK
import TapTapComplianceSDK

public class FlutterTaptapPlugin: NSObject, FlutterPlugin {
  private var channel: FlutterMethodChannel?
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_taptap", binaryMessenger: registrar.messenger())
    let instance = FlutterTaptapPlugin()
    instance.channel = channel
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "init":
      guard let args = call.arguments as? [String: Any] else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
        return
      }
      
      let clientId = args["clientId"] as? String ?? ""
      let clientToken = args["clientToken"] as? String ?? ""
      let regionStr = args["region"] as? String ?? "CN"
      let screenOrientation = args["screenOrientation"] as? Int ?? 1
      let enableLog = args["enableLog"] as? Bool ?? false
      
      let region: TapRegion = regionStr == "GLOBAL" ? .global : .CN
      
      let options = TapTapSdkOptions()
      options.clientId = clientId
      options.clientToken = clientToken
      options.region = region
      options.screenOrientation = screenOrientation
      options.enableLog = enableLog
      
      TapTapSdk.initSDK(with: options)
      result(nil)
    case "login":
      guard let args = call.arguments as? [String: Any] else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
        return
      }
      
      let scopes = args["scopes"] as? [String] ?? ["public_profile"]
      let tapScopes = scopes.map { scope -> TapTapScope in
        switch scope {
        case "public_profile":
          return .publicProfile
        default:
          return .publicProfile
        }
      }
      
      guard let viewController = UIApplication.shared.keyWindow?.rootViewController else {
        result(FlutterError(code: "VIEW_CONTROLLER_NOT_AVAILABLE", message: "View controller is not available", details: nil))
        return
      }
      
      TapTapLogin.login(with: viewController, permissions: tapScopes) { account, error in
        if let error = error {
          let errorCode = (error as NSError).code
          result(FlutterError(code: "LOGIN_FAILED", message: error.localizedDescription, details: errorCode))
          return
        }
        
        if let account = account {
          let accountInfo: [String: Any] = [
            "openId": account.userId ?? "",
            "unionId": account.unionId ?? "",
            "name": account.name ?? "",
            "avatar": account.avatarUrl ?? "",
            "accessToken": account.accessToken ?? ""
          ]
          result(accountInfo)
        } else {
          result(nil)
        }
      }
    case "getCurrentUser":
      if let account = TapTapLogin.currentTapAccount() {
        let accountInfo: [String: Any] = [
          "openId": account.userId ?? "",
          "unionId": account.unionId ?? "",
          "name": account.name ?? "",
          "avatar": account.avatarUrl ?? "",
          "accessToken": account.accessToken ?? ""
        ]
        result(accountInfo)
      } else {
        result(nil)
      }
    case "logout":
      TapTapLogin.logout()
      result(nil)
    case "openLeaderboard":
      guard let args = call.arguments as? [String: Any] else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
        return
      }
      
      let leaderboardId = args["leaderboardId"] as? String ?? ""
      let type = args["type"] as? String ?? "public"
      
      guard let viewController = UIApplication.shared.keyWindow?.rootViewController else {
        result(FlutterError(code: "VIEW_CONTROLLER_NOT_AVAILABLE", message: "View controller is not available", details: nil))
        return
      }
      
      TapTapLeaderboard.openLeaderboard(with: viewController, leaderboardId: leaderboardId, type: type)
      result(nil)
    case "registerLeaderboardCallback":
      let callbackHandler = LeaderboardCallbackHandler(channel: self.channel)
      TapTapLeaderboard.registerLeaderboardCallback(callback: callbackHandler)
      result(nil)
    case "setLeaderboardShareCallback":
      let shareHandler = ShareCallbackHandler(channel: self.channel)
      TapTapLeaderboard.setShareCallback(callback: shareHandler)
      result(nil)
    case "submitScores":
      guard let args = call.arguments as? [String: Any], let scoresData = args["scores"] as? [[String: Any]] else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
        return
      }
      
      if scoresData.isEmpty {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Scores list is empty", details: nil))
        return
      }
      
      var scoreItems: [ScoreItem] = []
      for item in scoresData {
        if let leaderboardId = item["leaderboardId"] as? String, let score = item["score"] as? Int {
          scoreItems.append(ScoreItem(leaderboardId: leaderboardId, score: score))
        }
      }
      
      if scoreItems.isEmpty {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "No valid score items", details: nil))
        return
      }
      
      TapTapLeaderboard.submitScores(scores: scoreItems) { response, error in
        if let error = error {
          let nsError = error as NSError
          result(FlutterError(code: "SUBMIT_FAILED", message: nsError.localizedDescription, details: nsError.code))
          return
        }
        result(["success": true])
      }
    case "registerComplianceCallback":
      let handler = ComplianceCallbackHandler(channel: channel)
      TapTapCompliance.registerComplianceCallback(handler)
      result(nil)
    case "unregisterComplianceCallback":
      TapTapCompliance.unregisterComplianceCallback()
      result(nil)
    case "startCompliance":
      guard let args = call.arguments as? [String: Any], let userId = args["userId"] as? String else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "userId is required", details: nil))
        return
      }
      TapTapCompliance.startup(userId: userId)
      result(nil)
    case "getRemainingTime":
      let remainingTime = TapTapCompliance.getRemainingTime()
      result(remainingTime)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

class LeaderboardCallbackHandler: NSObject, TapTapLeaderboardCallback {
  private weak var channel: FlutterMethodChannel?
  
  init(channel: FlutterMethodChannel?) {
    self.channel = channel
    super.init()
  }
  
  func onLeaderboardResult(code: Int, message: String) {
    channel?.invokeMethod("onLeaderboardResult", arguments: ["code": code, "message": message])
  }
}

class ShareCallbackHandler: NSObject, TapTapLeaderboardShareCallback {
  private weak var channel: FlutterMethodChannel?
  
  init(channel: FlutterMethodChannel?) {
    self.channel = channel
    super.init()
  }
  
  func onShareSuccess(localPath: String) {
    channel?.invokeMethod("onLeaderboardShareSuccess", arguments: ["localPath": localPath])
  }
  
  func onShareFailed(error: Error) {
    channel?.invokeMethod("onLeaderboardShareFailed", arguments: ["message": error.localizedDescription])
  }
}

class ComplianceCallbackHandler: NSObject, TapTapComplianceCallback {
  private weak var channel: FlutterMethodChannel?
  
  init(channel: FlutterMethodChannel?) {
    self.channel = channel
    super.init()
  }
  
  func onComplianceResult(code: Int, extra: [String : Any]?) {
    channel?.invokeMethod("onComplianceResult", arguments: ["code": code, "extra": extra ?? [:]])
  }
}