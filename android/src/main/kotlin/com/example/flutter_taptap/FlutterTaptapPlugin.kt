package com.example.flutter_taptap

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import com.taptap.sdk.core.TapTapRegion
import com.taptap.sdk.core.TapTapSdk
import com.taptap.sdk.core.TapTapSdkOptions

class FlutterTaptapPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: android.content.Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_taptap")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
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
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}