package com.example.flutter_taptap

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import com.taptap.sdk.core.TapTapRegion
import com.taptap.sdk.core.TapTapSdk
import com.taptap.sdk.core.TapTapSdkOptions
import com.taptap.sdk.login.TapTapLogin
import com.taptap.sdk.login.TapTapAccount
import com.taptap.sdk.kit.internal.callback.TapTapCallback
import com.taptap.sdk.kit.internal.exception.TapTapException
import com.taptap.sdk.leaderboard.androidx.TapTapLeaderboard
import com.taptap.sdk.leaderboard.callback.TapTapLeaderboardCallback
import com.taptap.sdk.leaderboard.callback.TapTapLeaderboardShareCallback
import com.taptap.sdk.leaderboard.callback.TapTapLeaderboardResponseCallback
import com.taptap.sdk.leaderboard.data.request.LeaderboardCollection
import com.taptap.sdk.leaderboard.data.request.SubmitScoresRequest
import com.taptap.sdk.leaderboard.data.response.LeaderboardScoresResponse
import com.taptap.sdk.leaderboard.data.response.SubmitScoresResponse
import com.taptap.sdk.compliance.TapTapCompliance
import com.taptap.sdk.compliance.TapTapComplianceCallback
import com.taptap.sdk.compliance.constants.ComplianceMessage
import android.app.Activity
import androidx.annotation.NonNull
import android.util.Log

class FlutterTaptapPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var context: android.content.Context
    private var activity: Activity? = null
    private var leaderboardCallback: TapTapLeaderboardCallback? = null
    private var complianceCallback: TapTapComplianceCallback? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_taptap")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
//        Log.e("Leaderboard", "原生call.........");
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "init" -> {
                val clientId = call.argument<String>("clientId") ?: ""
                val clientToken = call.argument<String>("clientToken") ?: ""
                val regionStr = call.argument<String>("region") ?: "CN"
                val screenOrientation = call.argument<Int>("screenOrientation") ?: 1
                val enableLog = call.argument<Boolean>("enableLog") ?: false

                val region = if (regionStr == "GLOBAL") TapTapRegion.GLOBAL else TapTapRegion.CN

                TapTapSdk.init(
                    context,
                    TapTapSdkOptions(
                        clientId = clientId,
                        clientToken = clientToken,
                        region = region,
                        screenOrientation = screenOrientation,
                        enableLog = enableLog,
                    )
                )
                result.success(null)
            }
            "login" -> {
                val scopesList = call.argument<List<String>>("scopes") ?: listOf("public_profile")
                val scopes = scopesList.toTypedArray()
                
                val currentActivity = activity
                if (currentActivity == null) {
                    result.error("ACTIVITY_NOT_AVAILABLE", "Activity is not available", null)
                    return
                }

                TapTapLogin.loginWithScopes(
                    currentActivity,
                    scopes,
                    object : TapTapCallback<TapTapAccount> {
                        override fun onSuccess(account: TapTapAccount) {
                            // AccessToken 是对象，需要转为字符串
                            val tokenStr = account.accessToken?.toString() ?: ""
                            val accountMap = mapOf(
                                "openId" to account.openId,
                                "unionId" to account.unionId,
                                "name" to (account.name ?: ""),
                                "avatar" to (account.avatar ?: ""),
                                "accessToken" to tokenStr
                            )
                            result.success(accountMap)
                        }

                        override fun onCancel() {
                            result.success(null)
                        }

                        override fun onFail(exception: TapTapException) {
                            result.error("LOGIN_FAILED", exception.message ?: "Login failed", null)
                        }
                    }
                )
            }
            "getCurrentUser" -> {
                val account = TapTapLogin.getCurrentTapAccount()
                if (account != null) {
                    // AccessToken 是对象，需要转为字符串
                    val tokenStr = account.accessToken?.toString() ?: ""
                    val accountMap = mapOf(
                        "openId" to account.openId,
                        "unionId" to account.unionId,
                        "name" to (account.name ?: ""),
                        "avatar" to (account.avatar ?: ""),
                        "accessToken" to tokenStr
                    )
                    result.success(accountMap)
                } else {
                    result.success(null)
                }
            }
            "logout" -> {
                TapTapLogin.logout()
                result.success(null)
            }
            "openLeaderboard" -> {
                val leaderboardId = call.argument<String>("leaderboardId") ?: ""
                val type = call.argument<String>("type") ?: "public"
                
                val currentActivity = activity
                if (currentActivity == null) {
                    result.error("ACTIVITY_NOT_AVAILABLE", "Activity is not available", null)
                    return
                }
                
                TapTapLeaderboard.openLeaderboard(currentActivity, leaderboardId, type)
                result.success(null)
            }
            "registerLeaderboardCallback" -> {
                leaderboardCallback = object : TapTapLeaderboardCallback {
                    override fun onLeaderboardResult(code: Int, message: String) {
                        // 处理排行榜事件
                        when (code) {
                            500102 -> {
                                // 用户未登录，需要引导用户登录
                                Log.d("Leaderboard", "用户未登录，需要引导用户登录")
                            }
                            else -> {
                                Log.d("Leaderboard", "code: $code, message: $message")
                            }
                        }
                        // 通过 MethodChannel 将回调信息发送给 Flutter 端
                        channel.invokeMethod("onLeaderboardResult", mapOf(
                            "code" to code,
                            "message" to message
                        ))
                    }
                }
                TapTapLeaderboard.registerLeaderboardCallback(leaderboardCallback!!)
                result.success(null)
            }
            "unregisterLeaderboardCallback" -> {
                if (leaderboardCallback != null) {
                    TapTapLeaderboard.unregisterLeaderboardCallback(leaderboardCallback!!)
                    leaderboardCallback = null
                }
                result.success(null)
            }
            "setLeaderboardShareCallback" -> {
                TapTapLeaderboard.setShareCallback(object : TapTapLeaderboardShareCallback() {
                    override fun onShareSuccess(localPath: String) {
                        channel.invokeMethod("onLeaderboardShareSuccess", mapOf(
                            "event" to "onShareSuccess",
                            "localPath" to localPath
                        ))
                    }
                    
                    override fun onShareFailed(error: Throwable) {
                        channel.invokeMethod("onLeaderboardShareFailed", mapOf(
                            "event" to "onShareFailed",
                            "message" to (error.message ?: "Share failed")
                        ))
                    }
                })
                result.success(null)
            }
            "submitScores" -> {
                val scoresData = call.argument<List<Map<String, Any>>>("scores")
                if (scoresData.isNullOrEmpty()) {
                    result.error("INVALID_ARGUMENTS", "Scores list is empty", null)
                    return
                }

                val scoreItems = scoresData.mapNotNull { item ->
                    val leaderboardId = item["leaderboardId"] as? String
                    val score = item["score"] as? Int
                    if (leaderboardId != null && score != null) {
                        SubmitScoresRequest.ScoreItem(leaderboardId, score.toLong())
                    } else {
                        null
                    }
                }
                
                if (scoreItems.isEmpty()) {
                    result.error("INVALID_ARGUMENTS", "No valid score items", null)
                    return
                }
                
                TapTapLeaderboard.submitScores(
                    scores = scoreItems,
                    callback = object : TapTapLeaderboardResponseCallback<SubmitScoresResponse>() {
                        override fun onSuccess(data: SubmitScoresResponse) {
                            Log.d("Leaderboard", "提交成功: $data")
                            result.success(mapOf("success" to true))
                        }

                        override fun onFailure(code: Int, message: String) {
                            Log.e("Leaderboard", "提交失败: code=$code, message=$message")
                            result.error("SUBMIT_FAILED", message, code)
                        }
                    }
                )
            }
            "loadPlayerCenteredScores" -> {
                Log.d("Leaderboard", "loadPlayerCenteredScores called")
                
                val leaderboardId = call.argument<String>("leaderboardId") ?: ""
                val collectionStr = call.argument<String>("leaderboardCollection") ?: "PUBLIC"
                val periodToken = call.argument<String>("periodToken") ?: ""
                val maxCount = call.argument<Int>("maxCount") ?: 10
                
                Log.d("Leaderboard", "Params: leaderboardId=$leaderboardId, collection=$collectionStr, periodToken=$periodToken, maxCount=$maxCount")

                val collection = if (collectionStr == "FRIENDS") {
                    LeaderboardCollection.FRIENDS
                } else {
                    LeaderboardCollection.PUBLIC
                }

                TapTapLeaderboard.loadPlayerCenteredScores(
                    leaderboardId = leaderboardId,
                    leaderboardCollection = collection,
                    periodToken = periodToken,
                    maxCount = maxCount,
                    callback = object : TapTapLeaderboardResponseCallback<LeaderboardScoresResponse>() {
                        override fun onSuccess(data: LeaderboardScoresResponse) {

//                            Log.i("Leaderboard", "相近分数数据: $data")
                            
                            val leaderboard = data.leaderboard
                            val leaderboardData = mapOf(
                                "id" to (leaderboard?.id ?: ""),
                                "name" to (leaderboard?.name ?: "")
                            )
                            
                            val scores = data.scores ?: emptyList()
                            val scoresList = scores.map { score ->
                                val user = score.user
                                val avatar = user?.avatar
                                mapOf(
                                    "rank" to score.rank,
                                    "rankDisplay" to (score.rankDisplay ?: ""),
                                    "score" to score.score,
                                    "scoreDisplay" to (score.scoreDisplay ?: ""),
                                    "playerId" to (user?.openid ?: ""),
                                    "playerName" to (user?.name ?: ""),
                                    "playerAvatar" to (avatar?.url ?: "")
                                )
                            }
                            result.success(mapOf(
                                "leaderboard" to leaderboardData,
                                "scores" to scoresList
                            ))
                        }

                        override fun onFailure(code: Int, message: String) {
                            Log.e("Leaderboard", "onFailure called - code=$code, message=$message")
                            result.error("LOAD_FAILED", message, code)
                        }
                    }
                )
                
                Log.d("Leaderboard", "loadPlayerCenteredScores method finished")
            }
            "registerComplianceCallback" -> {
                complianceCallback = object : TapTapComplianceCallback {
                    override fun onComplianceResult(code: Int, extra: Map<String, Any>?) {
                        when (code) {
                            ComplianceMessage.LOGIN_SUCCESS -> {
                                Log.d("Compliance", "登录成功")
                            }
                            ComplianceMessage.EXITED -> {
                                Log.d("Compliance", "退出登录")
                            }
                            ComplianceMessage.SWITCH_ACCOUNT -> {
                                Log.d("Compliance", "切换账号")
                            }
                        }
                        // 通过 MethodChannel 将回调信息发送给 Flutter 端
                        channel.invokeMethod("onComplianceResult", mapOf(
                            "code" to code,
                            "extra" to (extra ?: emptyMap<String, Any>())
                        ))
                    }
                }
                TapTapCompliance.registerComplianceCallback(complianceCallback!!)
                result.success(null)
            }
            "unregisterComplianceCallback" -> {
                if (complianceCallback != null) {
                    TapTapCompliance.unregisterComplianceCallback(complianceCallback!!)
                    complianceCallback = null
                }
                result.success(null)
            }
            "startCompliance" -> {
                val userId = call.argument<String>("userId")
                if (userId.isNullOrEmpty()) {
                    result.error("INVALID_ARGUMENTS", "userId is required", null)
                    return
                }
                val currentActivity = activity
                if (currentActivity == null) {
                    result.error("ACTIVITY_NOT_AVAILABLE", "Activity is not available", null)
                    return
                }
                TapTapCompliance.startup(currentActivity, userId)
                result.success(null)
            }
            "getRemainingTime" -> {
                val remainingTime = TapTapCompliance.getRemainingTime()
                result.success(remainingTime)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}