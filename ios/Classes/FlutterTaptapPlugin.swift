import Flutter
import UIKit
import TapTapCoreSDK
import TapTapLoginSDK
import TapTapLeaderboardSDK
import TapTapComplianceSDK

public class FlutterTaptapPlugin: NSObject, FlutterPlugin {
  private var channel: FlutterMethodChannel?
  private var complianceHandler: ComplianceCallbackHandler?
  private var leaderboardCallbackHandler: LeaderboardCallbackHandler?
  private var shareCallbackHandler: ShareCallbackHandler?
  
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
      
      let region: TapTapRegionType = regionStr == "GLOBAL" ? .overseas : .CN
      let orientation: TapTapScreenOrientation = screenOrientation == 0 ? .portrait : .landscape
      
      let options = TapTapSdkOptions()
      options.clientId = clientId
      options.clientToken = clientToken
      options.region = region
      options.screenOrientation = orientation
      options.enableLog = enableLog
      
      TapTapSDK.initWith(options)
      
      complianceHandler = ComplianceCallbackHandler(channel: channel)
      TapComplianceService.`init`(complianceHandler!, gameIdentifier: clientId)
      result(nil)
    case "login":
      guard let args = call.arguments as? [String: Any] else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
        return
      }
      
      let scopes = args["scopes"] as? [String] ?? ["public_profile"]
      
      guard let viewController = UIApplication.shared.keyWindow?.rootViewController else {
        result(FlutterError(code: "VIEW_CONTROLLER_NOT_AVAILABLE", message: "View controller is not available", details: nil))
        return
      }
      
      TapTapLogin.Login(scopes: scopes, viewController: viewController) { success, error, account in
        if let error = error {
          let nsError = error as NSError
          result(FlutterError(code: "LOGIN_FAILED", message: nsError.localizedDescription, details: nsError.code))
          return
        }
        
        if let account = account {
          let userInfo = account.userInfo
          let accessToken = account.accessToken?.toJsonString() ?? ""
          let accountInfo: [String: Any] = [
            "openId": userInfo?.openId ?? "",
            "unionId": userInfo?.unionId ?? "",
            "name": userInfo?.name ?? "",
            "avatar": userInfo?.avatar ?? "",
            "accessToken": accessToken
          ]
          result(accountInfo)
        } else {
          result(nil)
        }
      }
    case "getCurrentUser":
      if let account = TapTapLogin.getCurrentTapAccount() {
        let userInfo = account.userInfo
        let accessToken = account.accessToken?.toJsonString() ?? ""
        let accountInfo: [String: Any] = [
          "openId": userInfo?.openId ?? "",
          "unionId": userInfo?.unionId ?? "",
          "name": userInfo?.name ?? "",
          "avatar": userInfo?.avatar ?? "",
          "accessToken": accessToken
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
      
      let collection: TapTapLeaderboardCollection = type == "friends" ? .friends : .public
      
      TapTapLeaderboard.openLeaderboard(leaderboardId: leaderboardId, collection: collection)
      result(nil)
    case "registerLeaderboardCallback":
      leaderboardCallbackHandler = LeaderboardCallbackHandler(channel: self.channel)
      TapTapLeaderboard.registerLeaderboardCallback(callback: leaderboardCallbackHandler!)
      result(nil)
    case "unregisterLeaderboardCallback":
      if let handler = leaderboardCallbackHandler {
        TapTapLeaderboard.unregisterLeaderboardCallback(callback: handler)
        leaderboardCallbackHandler = nil
      }
      result(nil)
    case "setLeaderboardShareCallback":
      shareCallbackHandler = ShareCallbackHandler(channel: self.channel)
      TapTapLeaderboard.setShareCallback(callback: shareCallbackHandler!)
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
      
      var scoreItems: [TapTapLeaderboardScoreItem] = []
      for item in scoresData {
        if let leaderboardId = item["leaderboardId"] as? String, let score = item["score"] as? Int {
          scoreItems.append(TapTapLeaderboardScoreItem(leaderboardId: leaderboardId, score: Int64(score)))
        }
      }
      
      if scoreItems.isEmpty {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "No valid score items", details: nil))
        return
      }
      
      let submitCallback = SubmitScoreCallbackHandler(result: result)
      TapTapLeaderboard.submitScores(scores: scoreItems, callback: submitCallback)
    case "loadPlayerCenteredScores":
      guard let args = call.arguments as? [String: Any] else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
        return
      }
      
      let leaderboardId = args["leaderboardId"] as? String ?? ""
      let collectionStr = args["leaderboardCollection"] as? String ?? "PUBLIC"
      let periodToken = args["periodToken"] as? String ?? ""
      let maxCount = args["maxCount"] as? Int ?? 10
      
      let collection: TapTapLeaderboardCollection = collectionStr == "FRIENDS" ? .friends : .public
      
      let loadCallback = LoadScoresCallbackHandler(result: result)
      TapTapLeaderboard.loadPlayerCenteredScoresObjC(
        leaderboardId: leaderboardId,
        collection: collection,
        periodToken: periodToken,
        maxCount: NSNumber(value: maxCount),
        callback: loadCallback
      )
    case "loadLeaderboardScores":
      guard let args = call.arguments as? [String: Any] else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
        return
      }
      
      let leaderboardId = args["leaderboardId"] as? String ?? ""
      let collectionStr = args["leaderboardCollection"] as? String ?? "PUBLIC"
      let nextPage = args["nextPage"] as? String
      let periodToken = args["periodToken"] as? String ?? ""
      
      let collection: TapTapLeaderboardCollection = collectionStr == "FRIENDS" ? .friends : .public
      
      let loadCallback = LoadScoresCallbackHandler(result: result)
      TapTapLeaderboard.loadLeaderboardScores(
        leaderboardId: leaderboardId,
        collection: collection,
        nextPage: nextPage,
        periodToken: periodToken,
        callback: loadCallback
      )
    case "registerComplianceCallback":
      complianceHandler = ComplianceCallbackHandler(channel: channel)
      result(nil)
    case "unregisterComplianceCallback":
      complianceHandler = nil
      result(nil)
    case "startCompliance":
      guard let args = call.arguments as? [String: Any], let userId = args["userId"] as? String else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "userId is required", details: nil))
        return
      }
      let token = TapTapLogin.getCurrentTapAccount()?.accessToken?.toJsonString() ?? ""
      TapComplianceService.login(userId: userId, accessToken: token)
      TapComplianceService.enterGame()
      result(nil)
    case "getRemainingTime":
      let remainingTime = TapComplianceService.currentUserRemainingTime()
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
    channel?.invokeMethod("onLeaderboardShareFailed", arguments: ["message": (error as NSError).localizedDescription])
  }
}

class ComplianceCallbackHandler: NSObject, TapComplianceServiceCallback {
  private weak var channel: FlutterMethodChannel?
  
  init(channel: FlutterMethodChannel?) {
    self.channel = channel
    super.init()
  }
  
  func onCallback(code: Int, extra: String?) {
    var extraDict: [String: Any] = [:]
    if let extraStr = extra, let data = extraStr.data(using: .utf8) {
      if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
        extraDict = json
      }
    }
    channel?.invokeMethod("onComplianceResult", arguments: ["code": code, "extra": extraDict])
  }
}

class SubmitScoreCallbackHandler: NSObject, TapTapLeaderboardResponseCallback {
  private var result: FlutterResult
  
  init(result: @escaping FlutterResult) {
    self.result = result
    super.init()
  }
  
  func onSuccess(data: Any) {
    result(["success": true])
  }
  
  func onFailure(code: Int, message: String) {
    result(FlutterError(code: "SUBMIT_FAILED", message: message, details: code))
  }
}

class LoadScoresCallbackHandler: NSObject, TapTapLeaderboardResponseCallback {
  private var result: FlutterResult
  
  init(result: @escaping FlutterResult) {
    self.result = result
    super.init()
  }
  
  func onSuccess(data: Any) {
    if let response = data as? TapTapLeaderboardDataResponse {
      let leaderboard = response.leaderboard
      let leaderboardData: [String: Any] = [
        "id": leaderboard?.id ?? "",
        "name": leaderboard?.name ?? ""
      ]
      
      let scoresList = response.scores?.map { score -> [String: Any] in
        let user = score.user
        let avatar = user?.avatar
        return [
          "rank": score.rank ?? 0,
          "rankDisplay": score.rankDisplay ?? "",
          "score": score.score ?? 0,
          "scoreDisplay": score.scoreDisplay ?? "",
          "playerId": user?.openId ?? "",
          "playerName": user?.name ?? "",
          "playerAvatar": avatar?.url ?? ""
        ]
      } ?? []
      
      result([
        "leaderboard": leaderboardData,
        "scores": scoresList,
        "nextPage": response.nextPage
      ])
    } else {
      result(["leaderboard": ["id": "", "name": ""], "scores": [], "nextPage": ""])
    }
  }
  
  func onFailure(code: Int, message: String) {
    result(FlutterError(code: "LOAD_FAILED", message: message, details: code))
  }
}