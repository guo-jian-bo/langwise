package com.timelywise.langwise

import android.app.Application
import android.content.Context
import android.os.Bundle
import android.os.Process
import android.util.Log
import com.umeng.commonsdk.UMConfigure
import com.umeng.umcrash.UMCrash
import kotlin.system.exitProcess

class LangwiseApplication : Application() {
    private val logTag = "Langwise"
    private val logPrefix = "[LangwiseApplication.kt]"
    // 与 Flutter shared_preferences 保持同一份存储。
    private val flutterSharedPreferencesName = "FlutterSharedPreferences"
    private val privacyAgreeKey = "user_agree_privacy"

    override fun onCreate() {
        super.onCreate()
        initUmengCrashIfNeeded()
        registerUncaughtExceptionHandler()
    }

    private fun initUmengCrashIfNeeded() {
        try {
            val sharedPreferences = getSharedPreferences(flutterSharedPreferencesName, Context.MODE_PRIVATE)
            val agreePrivacy = sharedPreferences.getBoolean(privacyAgreeKey, false)
            Log.i(logTag, "$logPrefix 启动时检查隐私协议状态: $agreePrivacy")
            if (!agreePrivacy) {
                Log.i(logTag, "$logPrefix 用户未同意隐私协议，跳过友盟崩溃初始化")
                return
            }

            UMConfigure.setLogEnabled(true)
            val bundle = Bundle().apply {
                putBoolean(UMCrash.KEY_ENABLE_CRASH_JAVA, true)
                putBoolean(UMCrash.KEY_ENABLE_CRASH_NATIVE, true)
                putBoolean(UMCrash.KEY_ENABLE_ANR, true)
                putBoolean(UMCrash.KEY_ENABLE_PA, false)
                putBoolean(UMCrash.KEY_ENABLE_LAUNCH, false)
                putBoolean(UMCrash.KEY_ENABLE_MEM, false)
                putBoolean(UMCrash.KEY_ENABLE_H5PAGE, false)
                putBoolean(UMCrash.KEY_ENABLE_POWER, false)
            }
            UMCrash.initConfig(bundle)
            UMConfigure.preInit(this, "683a7430bc47b67d83784456", "android")
            UMConfigure.init(this, "683a7430bc47b67d83784456", "android", UMConfigure.DEVICE_TYPE_PHONE, "")
            Log.i(logTag, "$logPrefix 友盟崩溃初始化完成")
        } catch (t: Throwable) {
            Log.e(logTag, "$logPrefix 友盟崩溃初始化失败: ${t.message}", t)
        }
    }

    private fun registerUncaughtExceptionHandler() {
        val oldHandler = Thread.getDefaultUncaughtExceptionHandler()
        Thread.setDefaultUncaughtExceptionHandler { thread, throwable ->
            try {
                NativeErrorStore.writeUnhandledJavaCrash(this, thread.name, throwable)
                Log.e(logTag, "$logPrefix 捕获到未处理原生异常，线程: ${thread.name}", throwable)
            } catch (_: Throwable) {
            } finally {
                if (oldHandler != null) {
                    oldHandler.uncaughtException(thread, throwable)
                } else {
                    Process.killProcess(Process.myPid())
                    exitProcess(10)
                }
            }
        }
        Log.i(logTag, "$logPrefix 全局未捕获异常处理器注册完成")
    }
}
