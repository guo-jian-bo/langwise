package com.timelywise.langwise
import com.umeng.umcrash.UMCrash
import com.umeng.commonsdk.UMConfigure
import com.ryanheise.audioservice.AudioServiceActivity
import android.os.Bundle
import android.content.Context
import android.content.SharedPreferences

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: AudioServiceActivity() {
    private lateinit var sharedPreferencesHelper: SharedPreferences
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // 初始化SharedPreferences
        sharedPreferencesHelper = getSharedPreferences("app_prefs", Context.MODE_PRIVATE)

        UMConfigure.setLogEnabled(true)

        // 检查用户是否同意隐私协议，使用与Flutter一致的键名
        if (sharedPreferencesHelper.getBoolean("user_agree_privacy", false)) {
            // 在application.onCreate内配置各模块开关并预初始化SDK 配置崩溃日志收集也放到隐私协议同意后：
            val bundle = Bundle()
            bundle.putBoolean(UMCrash.KEY_ENABLE_CRASH_JAVA, true)
            bundle.putBoolean(UMCrash.KEY_ENABLE_CRASH_NATIVE, true)
            bundle.putBoolean(UMCrash.KEY_ENABLE_ANR, false)
            bundle.putBoolean(UMCrash.KEY_ENABLE_PA, false)
            bundle.putBoolean(UMCrash.KEY_ENABLE_LAUNCH, false)
            bundle.putBoolean(UMCrash.KEY_ENABLE_MEM, false)
            bundle.putBoolean(UMCrash.KEY_ENABLE_H5PAGE, false)
            bundle.putBoolean(UMCrash.KEY_ENABLE_POWER, false)
            UMCrash.initConfig(bundle)
            
            UMConfigure.preInit(this, "66f6c4a5c1b2b2b2b2b2b2b2", "android")
            initUmeng()
        }
    }
    
    private fun initUmeng() {
        // 友盟正式初始化
        UMConfigure.init(this, "683a7430bc47b67d83784456", "android", UMConfigure.DEVICE_TYPE_PHONE, "")
    }
}
