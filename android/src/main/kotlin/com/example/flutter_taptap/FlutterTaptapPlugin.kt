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
import android.app.Activity
import androidx.annotation.NonNull

class FlutterTaptapPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var context: android.content.Context
    private var activity: Activity? = null

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
                            val accountMap = mapOf(
                                "openId" to account.openId,
                                "unionId" to account.unionId
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
                    val accountMap = mapOf(
                        "openId" to account.openId,
                        "unionId" to account.unionId
                    )
                    result.success(accountMap)
                } else {
                    result.success(null)
                }
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