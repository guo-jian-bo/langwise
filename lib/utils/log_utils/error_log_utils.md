# Android 原生崩溃与原生错误落盘到 ErrorLogUtils 的最小实现提示词

请在当前 Flutter 项目中实现一套“最简单但可用”的 Android 原生异常采集方案，目标不是做完整监控平台，而是只解决下面这件事：

- 能捕获 Android 原生崩溃
- 能记录 Android 原生错误
- 能在下次启动 App 时由 Flutter 读取并写入 `ErrorLogUtils`

## 一、实现目标

请基于当前项目目录实现以下能力：

1. Android 原生崩溃继续使用友盟捕获
2. Android 原生“非致命错误 / handled error”由我们自己写入本地文件
3. Flutter 启动后主动读取 Android 侧待消费错误，并逐条写入 `lib/utils/log_utils/error_log_utils.dart`
4. 已消费的原生错误需要删除或清空，避免重复写入

## 二、必须遵守的实现约束

### 1. 这是最小实现，不要过度设计

只实现下面这些组件即可：

- `LangwiseApplication.kt`
- `NativeErrorStore.kt`
- `MainActivity.kt` 中的 Flutter / Android 通道桥接
- Flutter 侧一个读取原生待消费错误的方法

不要引入额外数据库，不要引入 Room，不要引入复杂线程池，不要引入新的第三方日志 SDK。

新增的 Flutter 文件统一放到：

- `/Users/langwise/Desktop/ns/project/langwise/lib/utils/log_utils`

### 2. 写本地文件必须考虑性能，不能导致 App 卡顿

这是硬要求。

原生错误落盘时，必须遵守下面规则：

- 不能在主线程上做文件 IO
- 不能每来一条错误就同步 `fsync` 或大块读写
- 不能在 UI 线程执行 JSON 序列化 + 文件写入
- 不能每次写入都先读取整个文件再追加
- 不能因为写日志导致页面卡顿、音频卡顿、播放器状态异常

推荐采用下面的最小性能方案：

- 使用单线程后台 `HandlerThread` 或单线程 `Executor`
- 使用 `jsonl` 追加写入，一行一条 JSON
- 每次只做轻量 append，不做全文件重写
- 写入目录使用应用私有目录，例如 `files/native_errors/`
- 文件名固定为 `pending.jsonl`
- 单条日志内容控制精简，避免超大字段
- 文件总大小需要做上限控制，例如 1MB 到 2MB；超过后可删除最旧内容、直接截断重建，或保留最近一部分

### 2.1 日志内容必须尽量轻

这是第二个硬要求。

原生日志不是为了完整替代 `logcat`，而是为了在下次启动时把“关键错误事实”转交给 `ErrorLogUtils`。因此每条日志必须尽量轻，禁止把大对象、大响应体、大配置、长列表直接写入文件。

必须遵守下面规则：

- 单条日志目标大小控制在 `1KB` 左右，最多不超过 `2KB`
- `tag` 最长不超过 `50` 个字符
- `message` 最长不超过 `300` 个字符
- `stack` 最长不超过 `1200` 个字符
- `extra` 默认不要写；确实需要时只能放少量字符串字段
- 禁止写入 request body、response body、整段 HTML、整段 JSON、完整播放器状态树、完整页面参数
- 禁止把 `Throwable` 的完整 `cause` 链全部展开为超长文本

推荐保留的最小字段只有：

- `type`
- `time`
- `tag`
- `message`
- `thread`
- `stack`（截断后）

推荐的轻量格式示例：

```json
{
  "type": "native_error",
  "time": "2026-07-31 12:00:00",
  "tag": "audio_prepare",
  "message": "IllegalStateException: prepare failed",
  "thread": "main",
  "stack": "java.lang.IllegalStateException at ..."
}
```

### 2.2 Android 原生日志输出规范

为了让 Flutter 侧能判断“本次是否真的调用到了 Android 原生读取逻辑”，请在 Android 原生端增加统一格式的调试日志输出。

必须遵守下面规则：

- Android 原生日志统一使用同一个前缀：`[LangwiseApplication.kt]`
- Android 原生日志文案尽量使用中文，便于直接排查
- 在调用 `consumePendingErrors(context)` 时，必须先打印“当前待消费日志条数”
- 即使当前没有任何待消费数据，也必须打印这条日志
- 读取成功后建议再打印一条“已返回多少条日志”
- 读取异常时也要打印一条失败日志

推荐日志格式：

```text
[LangwiseApplication.kt] 开始读取待消费日志，当前条数: 0
[LangwiseApplication.kt] 读取待消费日志成功，返回条数: 0
[LangwiseApplication.kt] 读取待消费日志失败: xxx
```

这里的日志不是为了替代落盘错误日志，而是为了确认 Android 原生读取链路是否真的执行成功。

### 3. 崩溃写入也要轻量

Java 未捕获崩溃若做兜底落盘：

- 只允许写非常小的一条记录
- 先快速写入，再交给旧的 `UncaughtExceptionHandler`
- 不要在崩溃回调里做复杂对象序列化
- 不要在崩溃回调里做网络请求
- 不要阻塞太久，避免影响系统崩溃流程

## 三、推荐实现结构

### 1. Android Application

新增：

- `android/app/src/main/kotlin/com/timelywise/langwise/LangwiseApplication.kt`

职责：

- 在 `onCreate()` 中尽早初始化友盟崩溃采集
- 注册 Java 层全局未捕获异常处理器
- 未捕获异常发生时，调用 `NativeErrorStore.writeUnhandledJavaCrash(...)`
- 写完后继续调用系统原有的 `UncaughtExceptionHandler`

注意：

- 友盟初始化从 `MainActivity` 挪到 `Application`
- 如果项目已有隐私协议开关，则继续遵守现有隐私逻辑
- 若用户未同意隐私协议，可只保留本地落盘，不做友盟上报

### 2. NativeErrorStore

新增：

- `android/app/src/main/kotlin/com/timelywise/langwise/NativeErrorStore.kt`

至少提供下面几个方法：

- `writeHandledError(context, tag, throwable, extra)`
- `writeUnhandledJavaCrash(context, threadName, throwable)`
- `consumePendingErrors(context): String`

其中：

- `writeHandledError`：记录原生 try/catch 中主动捕获的异常
- `writeUnhandledJavaCrash`：记录 Java 未捕获崩溃
- `consumePendingErrors`：读取 `pending.jsonl` 内容，转成 JSON 数组字符串后返回，并清空或删除原文件

额外补充两个私有辅助方法，保证实现足够简单：

- `buildLightJson(...)`
- `trimToMaxLength(...)`

### 3. 数据格式

每条记录尽量统一，但字段要轻，推荐字段如下：

```json
{
  "type": "native_error",
  "time": "2026-07-31 12:00:00",
  "tag": "audio_prepare",
  "message": "MediaPlayer prepare failed",
  "thread": "main",
  "stack": "java.lang...."
}
```

说明：

- `type` 建议区分 `native_error`、`java_crash`
- `time` 使用本地时间字符串即可
- `tag` 用于区分模块，比如 `audio`、`camera`、`webview`、`channel`
- `message` 保留错误摘要
- `stack` 可为空，但必须截断
- `extra` 默认不建议保留，除非确实需要极少量上下文

## 四、具体实现要求

下面不是泛泛建议，而是请尽量直接按这个结构实现。

### 1. `LangwiseApplication.kt` 具体实现

文件：

- `android/app/src/main/kotlin/com/timelywise/langwise/LangwiseApplication.kt`

要求：

- 继承 `FlutterApplication`
- 在 `onCreate()` 中：
  1. 读取隐私协议状态
  2. 若已同意隐私协议，初始化友盟崩溃采集
  3. 注册 `Thread.setDefaultUncaughtExceptionHandler`
- `UncaughtExceptionHandler` 中：
  1. 调用 `NativeErrorStore.writeUnhandledJavaCrash(...)`
  2. 再调用旧的 handler
- 所有 Android 原生日志输出统一使用前缀：`[LangwiseApplication.kt]`
- 所有 Android 原生日志文案尽量使用中文

实现骨架：

```kotlin
class LangwiseApplication : FlutterApplication() {
    override fun onCreate() {
        super.onCreate()

        val sp = getSharedPreferences("app_prefs", Context.MODE_PRIVATE)
        val agreePrivacy = sp.getBoolean("user_agree_privacy", false)

        if (agreePrivacy) {
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
            UMConfigure.preInit(this, "你的appKey", "android")
            UMConfigure.init(this, "你的appKey", "android", UMConfigure.DEVICE_TYPE_PHONE, "")
        }

        val oldHandler = Thread.getDefaultUncaughtExceptionHandler()
        Thread.setDefaultUncaughtExceptionHandler { thread, throwable ->
            NativeErrorStore.writeUnhandledJavaCrash(this, thread.name, throwable)
            oldHandler?.uncaughtException(thread, throwable)
        }
    }
}
```

同时修改：

- `android/app/src/main/AndroidManifest.xml`

把 `application` 的 `android:name` 改成：

```xml
android:name=".LangwiseApplication"
```

并将原来 `MainActivity.kt` 里的友盟初始化代码删除，避免重复初始化。

### 2. `NativeErrorStore.kt` 具体实现

文件：

- `android/app/src/main/kotlin/com/timelywise/langwise/NativeErrorStore.kt`

要求：

- 使用单线程后台 `Executor`
- 使用 `files/native_errors/pending.jsonl`
- 采用追加写入
- 采用轻量 JSON
- 增加最大文件大小控制
- 读取待消费日志时必须先打印待消费条数日志，即使条数为 `0` 也要打印
- 所有 Android 原生日志统一以 `[LangwiseApplication.kt]` 开头

建议直接按下面结构实现：

```kotlin
object NativeErrorStore {
    private const val LOG_PREFIX = "[LangwiseApplication.kt]"
    private const val DIR_NAME = "native_errors"
    private const val FILE_NAME = "pending.jsonl"
    private const val MAX_FILE_BYTES = 1024 * 1024L
    private const val MAX_TAG_LENGTH = 50
    private const val MAX_MESSAGE_LENGTH = 300
    private const val MAX_STACK_LENGTH = 1200

    private val executor = Executors.newSingleThreadExecutor()

    fun writeHandledError(context: Context, tag: String, throwable: Throwable, extra: String? = null) {
        val appContext = context.applicationContext
        executor.execute {
            appendLine(
                appContext = appContext,
                jsonLine = buildLightJson(
                    type = "native_error",
                    tag = tag,
                    message = throwable.message ?: throwable.javaClass.simpleName,
                    thread = Thread.currentThread().name,
                    stack = Log.getStackTraceString(throwable),
                    extra = extra,
                )
            )
        }
    }

    fun writeUnhandledJavaCrash(context: Context, threadName: String, throwable: Throwable) {
        try {
            appendLine(
                appContext = context.applicationContext,
                jsonLine = buildLightJson(
                    type = "java_crash",
                    tag = "uncaught",
                    message = throwable.message ?: throwable.javaClass.simpleName,
                    thread = threadName,
                    stack = Log.getStackTraceString(throwable),
                    extra = null,
                )
            )
        } catch (_: Throwable) {
        }
    }

    fun consumePendingErrors(context: Context): String {
        val file = getFile(context.applicationContext)
        if (!file.exists()) {
            Log.i("Langwise", "$LOG_PREFIX 开始读取待消费日志，当前条数: 0")
            Log.i("Langwise", "$LOG_PREFIX 读取待消费日志成功，返回条数: 0")
            return "[]"
        }
        return try {
            val lines = file.readLines().filter { it.isNotBlank() }
            Log.i("Langwise", "$LOG_PREFIX 开始读取待消费日志，当前条数: ${lines.size}")
            file.delete()
            Log.i("Langwise", "$LOG_PREFIX 读取待消费日志成功，返回条数: ${lines.size}")
            "[${lines.joinToString(",")}]"
        } catch (t: Throwable) {
            Log.e("Langwise", "$LOG_PREFIX 读取待消费日志失败: ${t.message}", t)
            "[]"
        }
    }
}
```

必须补齐以下私有方法：

- `getDir(context)`
- `getFile(context)`
- `appendLine(appContext, jsonLine)`
- `buildLightJson(...)`
- `trimToMaxLength(text, maxLength)`
- `maybeRotate(file)`

### 3. `buildLightJson(...)` 的具体要求

请不要直接把完整异常对象塞进 JSON。

请按下面规则实现：

- `message` 优先使用 `Throwable.message`
- 如果为空，则使用异常类名
- `stack` 使用 `Log.getStackTraceString(throwable)` 后再截断
- `extra` 只允许是单个短字符串，最长 `200` 字符
- 所有字段都要调用 `trimToMaxLength`

建议骨架：

```kotlin
private fun buildLightJson(
    type: String,
    tag: String,
    message: String,
    thread: String,
    stack: String?,
    extra: String?,
): String {
    val json = JSONObject()
    json.put("type", trimToMaxLength(type, 20))
    json.put("time", SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault()).format(Date()))
    json.put("tag", trimToMaxLength(tag, MAX_TAG_LENGTH))
    json.put("message", trimToMaxLength(message, MAX_MESSAGE_LENGTH))
    json.put("thread", trimToMaxLength(thread, 40))
    if (!stack.isNullOrBlank()) {
        json.put("stack", trimToMaxLength(stack.replace('\n', ' '), MAX_STACK_LENGTH))
    }
    if (!extra.isNullOrBlank()) {
        json.put("extra", trimToMaxLength(extra, 200))
    }
    return json.toString()
}
```

### 4. `appendLine(...)` 的具体要求

必须满足：

- 直接 append
- 不先读全文件
- 不在主线程执行
- 超过大小上限时执行最简单清理

建议骨架：

```kotlin
private fun appendLine(appContext: Context, jsonLine: String) {
    val file = getFile(appContext)
    file.parentFile?.mkdirs()
    maybeRotate(file)
    FileOutputStream(file, true).bufferedWriter(Charsets.UTF_8).use { writer ->
        writer.append(jsonLine)
        writer.append('\n')
    }
}
```

最简单的大小控制策略：

- 如果 `pending.jsonl` 大于 `1MB`
- 直接删除并重建

这里优先保证简单和不卡顿，不需要一开始就做复杂保留尾部逻辑。

### 4.1 `consumePendingErrors(...)` 的具体要求

这个方法除了返回待消费日志内容，还必须承担“给 Flutter 侧确认读取链路已执行”的职责。

必须满足：

- 一进入方法就要输出一条读取开始日志
- 这条日志里必须包含待消费条数
- 即使没有文件、没有数据、结果为空，也必须打印这条日志
- 成功返回前，再打印一条成功日志，带上实际返回条数
- 异常时打印失败日志

建议实现顺序：

1. 获取待消费文件
2. 计算当前待消费条数
3. 打印：
   - `[LangwiseApplication.kt] 开始读取待消费日志，当前条数: X`
4. 读取并拼接 JSON 数组
5. 删除文件
6. 打印：
   - `[LangwiseApplication.kt] 读取待消费日志成功，返回条数: X`
7. 返回结果

如果发生异常：

- 打印：
  - `[LangwiseApplication.kt] 读取待消费日志失败: xxx`
- 返回 `[]`

### 5. `MainActivity.kt` 具体实现

要求：

- 只保留 Flutter 通道桥接
- 删除友盟初始化逻辑
- 增加 `native_error_bridge`
- 原生读取通道调用成功与否，要能从 Android 日志中看出来

建议骨架：

```kotlin
class MainActivity : AudioServiceActivity() {
    private val channelName = "native_error_bridge"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "consumePendingNativeErrors" -> {
                        result.success(NativeErrorStore.consumePendingErrors(this))
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
```

如果通道处理里发生异常，也要轻量记录：

```kotlin
catch (t: Throwable) {
    NativeErrorStore.writeHandledError(this, "method_channel", t)
    Log.e("Langwise", "[LangwiseApplication.kt] MethodChannel 读取待消费日志失败: ${t.message}", t)
    result.error("native_error", t.message, null)
}
```

## 五、Flutter 侧接入要求

### 1. MethodChannel

在 Android 与 Flutter 之间增加一个简单通道，例如：

- channel name: `native_error_bridge`

提供一个方法，例如：

- `consumePendingNativeErrors`

返回值：

- JSON 数组字符串
- 或 `List<Map<String, dynamic>>`

优先选择实现简单、稳定的方式。

### 2. Flutter 启动时消费原生错误

请在 Flutter 启动链路中增加一次原生错误消费逻辑。

要求：

- App 启动后尽早执行，但不要早于基础初始化
- 拿到原生待消费错误后，逐条调用 `ErrorLogUtils.to.logError(...)`
- 写入时保留 `tag`、`message`、`type`、`thread`、`time` 等上下文
- 原生侧消费成功后，待消费文件必须清空或删除

建议写出的日志格式示例：

```text
[native][java_crash][audio_prepare] MediaPlayer prepare failed time:2026-07-31 12:00:00 thread:main
```

### 3. Flutter 侧具体实现

请在 Flutter 侧增加一个简单工具类，例如：

- `lib/utils/log_utils/native_error_bridge.dart`

建议实现骨架：

```dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:langwise/utils/error_log_utils.dart';

class NativeErrorBridge {
  static const MethodChannel _channel = MethodChannel('native_error_bridge');

  static Future<void> consumePendingErrors() async {
    try {
      final String? raw = await _channel.invokeMethod<String>('consumePendingNativeErrors');
      if (raw == null || raw.isEmpty || raw == '[]') return;
      final List<dynamic> list = jsonDecode(raw);
      for (final item in list) {
        try {
          if (item is! Map) continue;
          final type = '${item['type'] ?? 'native_error'}';
          final tag = '${item['tag'] ?? 'unknown'}';
          final message = '${item['message'] ?? ''}';
          final time = '${item['time'] ?? ''}';
          final thread = '${item['thread'] ?? ''}';
          await ErrorLogUtils.to.logError(
            '[native][$type][$tag] $message time:$time thread:$thread',
            null,
          );
        } catch (_) {}
      }
    } catch (_) {}
  }
}
```

接入位置建议：

- 在 `lib/main.dart` 的 `initApp()` 完成基础初始化后调用
- 不要放在过早的位置
- 不要阻塞主启动流程

推荐调用位置：

```dart
await StorageUtil().init();
await initDesktop();
initError();
unawaited(NativeErrorBridge.consumePendingErrors());
```

这里使用异步非阻塞调用，避免影响启动首帧。

## 六、原生错误如何落点

这套方案不能自动抓住所有 Android 原生日志，因此要明确下面规则：

### 1. 自动覆盖范围

- 友盟：Java crash / native crash / 可选 ANR
- `UncaughtExceptionHandler`：Java 未捕获异常

### 2. 手动覆盖范围

下列场景请主动调用 `NativeErrorStore.writeHandledError(...)`：

- `MethodChannel` 原生实现中的 `catch`
- 音频播放器初始化失败
- WebView 原生错误回调
- 相机初始化失败
- 支付 SDK 原生异常
- 其他明确 catch 到的 Android 原生异常

### 3. 不要误解为“全局抓到所有错误”

请明确接受这个事实：

- 所有 `Log.e` 不能自动全局接管
- 系统底层日志很多只存在于 `logcat`
- 已被第三方 SDK 吞掉的错误，若没有暴露回调，也抓不到

## 七、性能与稳定性验收标准

实现完成后，必须满足下面要求：

1. 记录原生错误时，不能在主线程直接进行文件写入
2. 连续快速记录 50 到 100 条原生错误时，页面无明显卡顿
3. 单次写入是 append，不做全文件反复重写
4. 启动消费原生错误后，不会重复写入同一批日志
5. Java 未捕获崩溃发生后，下次启动 Flutter 能读到上一轮落盘的数据
6. 友盟崩溃初始化迁移到 `Application` 后，不能影响当前 App 启动流程
7. 代码结构保持简单清晰，避免过度抽象

## 八、实现建议

### 1. 文件写入建议

建议使用：

- `HandlerThread + Handler`
  或
- `Executors.newSingleThreadExecutor()`

写入策略建议：

- 收到错误后投递到后台串行队列
- 后台线程将 JSON 序列化为单行文本
- 使用 `FileOutputStream(file, true)` 或等价 append 方式写入
- 每条日志结尾追加换行符

### 2. 文件大小控制建议

建议：

- `pending.jsonl` 超过 1MB 或 2MB 时触发清理
- 最简单做法可以是直接删除并重建
- 如果要保留最近数据，也只保留尾部最近若干 KB

这里优先保证：

- 实现简单
- 不阻塞
- 不影响主流程

### 3. Flutter 消费建议

Flutter 侧解析原生数据时：

- 做好 `try/catch`
- 单条解析失败不要影响整批消费
- 即使某条数据格式异常，也尽量继续处理后续数据

## 九、最终交付结果

请直接产出可运行代码，而不是只写说明。

最终应至少包含：

- Android 自定义 `Application`
- Android 原生错误本地存储类
- Android / Flutter 通道桥接
- Flutter 启动时消费原生错误并写入 `ErrorLogUtils`
- 必要的简洁注释

实现时请优先保证“简单、稳定、低卡顿”，不要把方案做重。
