import Flutter
import UIKit
import TapTapCoreSDK
import TapTapLoginSDK

public class FlutterTaptapPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_taptap", binaryMessenger: registrar.messenger())
    let instance = FlutterTaptapPlugin()
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
            "unionId": account.unionId ?? ""
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
          "unionId": account.unionId ?? ""
        ]
        result(accountInfo)
      } else {
        result(nil)
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}