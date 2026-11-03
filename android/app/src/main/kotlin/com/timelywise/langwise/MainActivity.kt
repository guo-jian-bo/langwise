package com.timelywise.langwise

import android.util.Log
import com.meituan.android.walle.WalleChannelReader
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : AudioServiceActivity() {
    private val appChannelChannelName = "com.timelywise.langwise/android_app_channel_code"
    private val nativeErrorBridgeChannelName = "native_error_bridge"
    private val logTag = "Langwise"
    private val logPrefix = "[LangwiseApplication.kt]"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, appChannelChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getChannel" -> {
                        try {
                            val channel = WalleChannelReader.getChannel(applicationContext)
                            result.success(channel)
                        } catch (t: Throwable) {
                            NativeErrorStore.writeHandledError(this, "get_channel", t)
                            Log.e(logTag, "$logPrefix 读取渠道号失败: ${t.message}", t)
                            result.success(null)
                        }
                    }

                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, nativeErrorBridgeChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "consumePendingNativeErrors" -> {
                        try {
                            result.success(NativeErrorStore.consumePendingErrors(this))
                        } catch (t: Throwable) {
                            NativeErrorStore.writeHandledError(this, "method_channel", t)
                            Log.e(logTag, "$logPrefix MethodChannel 读取待消费日志失败: ${t.message}", t)
                            result.error("native_error", t.message, null)
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }
}
