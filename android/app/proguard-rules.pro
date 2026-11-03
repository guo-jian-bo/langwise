# 保留友盟所有类和方法
-keep class com.umeng.** { *; }

-keep class com.uc.** { *; }

-keep class com.efs.** { *; }

# 小米
-dontwarn com.xiaomi.push.**
-keep class com.xiaomi.push.** { *; }

# 魅族
-dontwarn com.meizu.cloud.**
-keep class com.meizu.cloud.** { *; }

# VIVO
-dontwarn com.vivo.push.**
-keep class com.vivo.push.**{*; }
-keep class com.vivo.vms.**{*; }

# OPPO
-dontwarn com.coloros.mcsdk.**
-keep class com.coloros.mcsdk.** { *; }

-dontwarn com.heytap.**
-keep class com.heytap.** { *; }

-dontwarn com.mcs.**
-keep class com.mcs.** { *; }

# Honor
-ignorewarnings
-keepattributes *Annotation*
-keepattributes Exceptions
-keepattributes InnerClasses
-keepattributes Signature
-keepattributes SourceFile,LineNumberTable
-keep class com.hihonor.push.**{*;}

# 华为
-ignorewarnings
-keepattributes *Annotation* 
-keepattributes Exceptions 
-keepattributes InnerClasses 
-keepattributes Signature 
-keepattributes SourceFile,LineNumberTable 
-keep class com.hianalytics.android.**{*;} 
-keep class com.huawei.updatesdk.**{*;} 
-keep class com.huawei.hms.**{*;}



# 忽略缺失的 OkHttp3 类
-dontwarn okhttp3.**
-dontwarn com.efs.sdk.net.**

# 保留 EFS SDK 相关类
-keep class com.efs.sdk.** { *; }

# 保留JSON构造方法
-keepclassmembers class * {
    public <init> (org.json.JSONObject);
}
# 保留枚举方法
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

-keep public class com.timelywise.langwise.R$* {
    public static final int *;
}