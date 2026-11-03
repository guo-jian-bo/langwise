# 05 · langwise 接入建议（基于当前仓库现状）

本文基于 2026-09-23 对 `/Users/alexyou/Code/langwise` 的只读核对结果整理。**本轮没有修改 langwise 源码，也没有在 langwise 执行 `pub get`、`analyze`、测试或构建。**

通用接入规则见 [04](04-integration.md)，fieldlens 当前已交付边界见 [06](06-fieldlens-side-changes.md)。

## 本次核对到的宿主现状

以下结论都来自当前 `langwise` 仓库真实代码，而不是旧假设：

- SDK 约束为 `>=3.2.5 <4.0.0`，README 记录的实际基线是 Flutter 3.41.9 / Dart 3.11.5，和 fieldlens 当前验证基线一致。
- `lib/main.dart` 已直接依赖 `window_manager`，桌面主窗口初始化在 `initDesktop()` 中完成。
- `langwise` 的主应用壳是 `ScreenUtilInit -> Themed -> GetMaterialApp`，并在 `builder` 中叠加了 `BotToast`。
- `MyAppBuildWidget` 内部又额外包了一层 `Material + Overlay + Stack`，其中放了 `ManageSandboxFloatWidget` 和 `MvPlayerGlobalFloatWidget` 两个全局浮层。
- 网络层不是直接暴露裸 `Dio`，而是通过 `WiseHttp` 和 `DioInterceptorUtils.addInterceptor(...)` 统一注册拦截器。
- macOS / Windows Runner 目前都只有主窗口插件注册，没有为 `desktop_multi_window` 创建出来的副窗口补注册插件。

这几个点决定了：**langwise 可以接入当前 fieldlens，但宿主需要改入口、网络注册和桌面 Runner；fieldlens 本身目前不需要为了 langwise 再新增 Dart API。**

## 结论先说

### langwise 需要做的改动

1. `pubspec.yaml` 增加 `fieldlens` 与 `fieldlens_dio` 依赖。
2. `lib/main.dart` 的移动端入口把 `MyApp` 包在 `FieldLens` 外层。
3. `lib/main.dart` 的桌面端入口改用 `FieldLensDesktopBootstrap.run(...)` 启动。
4. `lib/main.dart` 的 `initHttp()` 里给 `WiseHttp` 挂上 `FieldLensDioInterceptor`。
5. 需要排期为少量关键页面补 `FieldTag` 与 `NonFieldTag`：接口数据标蓝、非接口本地数据标红，否则只能看 JSON，页面来源关系不完整。
6. macOS / Windows Runner 需要补 `desktop_multi_window` 的副窗口插件注册回调，否则桌面 JSON 独立窗口会像我们示例里最初那样因为 `window_manager MissingPluginException` 拉起失败。

### fieldlens 目前是否需要改动

当前判断：**fieldlens 不需要为了接入 langwise 再改代码。**

原因：

- langwise 当前 Flutter/Dart 基线与 fieldlens 验证基线一致。
- `langwise` 的移动端路径只需要普通 `FieldLens(child: MyApp())`，不依赖额外 API。
- `langwise` 的桌面端路径本来就不会走友盟 APM 的 `runApp` 分支，因此可以直接切到 `FieldLensDesktopBootstrap.run(...)`。
- 网络层虽然经过 `WiseHttp` 包装，但拦截器模型仍然是 Dio 风格，`FieldLensDioInterceptor` 可以按现有方式接入。

只有一种情况才需要再评估 fieldlens 侧增强：**如果后续希望宿主完全不改 macOS / Windows Runner 原生代码**。当前 Flutter 插件体系下，桌面多窗口的副窗口插件注册仍然需要宿主 Runner 补回调，这不是 langwise 专属问题。

## langwise 需要改哪些文件

## 1. `pubspec.yaml`

当前 `langwise/pubspec.yaml` 已经包含 `window_manager`、`get`、`bot_toast`、`wise_http` 等宿主依赖，说明它的应用壳与 fieldlens 没有方向性冲突。

后续建议新增：

```yaml
dependencies:
  fieldlens:
    path: ../fieldlens/packages/fieldlens
  fieldlens_dio:
    path: ../fieldlens/packages/fieldlens_dio
```

说明：

- 这次只看到 `wise_http` / Dio 体系，没有看到 `package:http` 作为统一客户端入口，所以当前无需接 `fieldlens_http`。
- `langwise` 自己的 SDK 下限写的是 `>=3.2.5`，但当前 README 标明开发基线是 Dart 3.11.5；只要实际构建环境继续使用 Dart 3.11.5，就不会和 fieldlens 的 `^3.11.5` 冲突。
- 如果 langwise 的某条 CI 还在用更低 Dart 版本，那不是 fieldlens 代码问题，而是宿主工具链需要先对齐。

## 2. `lib/main.dart`

### 现状

当前主入口有两条路径：

1. 移动端走 `UmengUtils.initApm(appRunner: ...)`
2. 桌面端因为 `UmengUtils.initApm()` 里直接对 macOS / Windows / Linux 返回 `false`，所以会走 fallback 分支，最终自己 `runApp(MyApp(...))`

这点很关键。因为它意味着：

- **移动端** 只要把返回的 `MyApp` 包进 `FieldLens`
- **桌面端** 可以直接把 fallback 分支替换成 `FieldLensDesktopBootstrap.run(...)`

不需要改 `UmengUtils` 本身，也不需要去改友盟 SDK。

### 建议改法

建议把 `MyApp(...)` 的构建收敛成一个公共方法，例如概念上统一为：

```dart
Widget buildRootApp({
  required String buildType,
  required LanguageTranslations languageTranslations,
  NavigatorObserver? navigatorObserver,
}) {
  return FieldLens(
    child: MyApp(
      isLogin: UserStore.to.isLogin,
      buildType: buildType,
      languageTranslations: languageTranslations,
      navigatorObserver: navigatorObserver,
    ),
  );
}
```

然后：

- `UmengUtils.initApm(appRunner: ...)` 返回 `buildRootApp(...)`
- 桌面 fallback 分支使用：

```dart
await FieldLensDesktopBootstrap.run(
  mainApp: buildRootApp(
    buildType: buildType,
    languageTranslations: languageTranslations,
  ),
);
```

### 为什么不用改 `MyAppBuildWidget`

当前 `MyAppBuildWidget` 已有自己的 `Overlay + Stack`，其中放了：

- `ManageSandboxFloatWidget`
- `MvPlayerGlobalFloatWidget`

fieldlens 是包在 `MyApp` 外层工作的，不要求宿主把 JSON 面板手动塞进这个 `Stack`。也就是说：

- 不需要往 `GetMaterialApp.builder` 里手写调试面板
- 不需要改 `MyAppBuildWidget` 的 `Overlay` 结构
- 不需要自己创建或传递 `FieldLensController`

但有一个必须保留的验证项：

- 非生产环境下，`ManageSandboxFloatWidget`、`MvPlayerGlobalFloatWidget` 与 fieldlens 顶部按钮区是否遮挡
- 移动端窗口内 JSON 面板打开后，是否会压住现有浮层交互
- 桌面端 JSON 独立窗口打开后，主窗口顶部按钮是否仍在预期位置

## 3. `lib/main.dart` 的 `initHttp()`

### 现状

当前 `initHttp()` 的链路已经很明确：

1. `DioInterceptorUtils.reset()`
2. `WiseHttp(baseUrl: httpEnv.host)`
3. 依次通过 `DioInterceptorUtils.addInterceptor(...)` 挂：
   - `RequestAuthInterceptor()`
   - `SystemMaintenanceInterceptor()`
   - `RequestsInterceptor()`
   - `RetryCurrentInterceptor()`
   - `CacheInterceptor()`
4. 最后挂 `LogInterceptor(...)`

这说明 fieldlens 最合适的接入点就是这里，不需要新建第二套网络采集层。

### 建议改法

建议把 `FieldLensDioInterceptor` 挂在 `CacheInterceptor()` 之后、`LogInterceptor(...)` 之前：

```dart
DioInterceptorUtils.addInterceptor(CacheInterceptor());
DioInterceptorUtils.addInterceptor(FieldLensDioInterceptor());
```

这样做的原因：

- 认证、重试、系统维护、缓存这些宿主逻辑先完成
- fieldlens 观察尽量接近“最终交付给业务层”的响应
- 日志拦截器仍然保留在后面，宿主现有日志行为不需要因为 fieldlens 调整

### 这里要注意的边界

- 如果 `CacheInterceptor` 在某些命中场景里直接短路且不继续后续链路，fieldlens 也无法凭空观察到这部分响应，这属于宿主缓存实现边界，不是 fieldlens 自己能单边修掉的。
- `RequestAuthInterceptor` 会在请求头里加 `Authorization`，fieldlens 现在默认直接保留请求头/响应头原始文本；如果 langwise 仍希望隐藏 query/body/headers 中的业务敏感字段，需要宿主显式配置 `redact`。

## 4. 业务页面标签

接入 fieldlens 后，即使一个 `FieldTag` 都不加，也能先看到请求/响应 JSON。

但如果想把页面里的可见数据来源区分完整，langwise 最终需要同时接两类标签：

- `FieldTag`：接口返回的数据，显示蓝色标签，可正反向定位 JSON。
- `NonFieldTag`：不是接口返回的数据，显示红色标签，只负责说明“这是本地数据 / 本地文案 / 本地默认值”，不会跳 JSON。

也就是说，fieldlens 在宿主里的目标不只是“能看到 JSON”，而是进一步做到：

1. 接口数据一眼看出来自哪个字段
2. 非接口数据一眼看出它不是接口下发，避免误判

如果想实现“点页面控件，反查 JSON 字段”或者“点 JSON 节点，反查页面控件”，langwise 仍然要在关键页面补少量标签，例如：

```dart
final key = FieldLensRequestKey.fromUri('GET', actualUri);

FieldTag(
  requestKey: key,
  path: 'data.items[3].title',
  child: Text(title),
);
```

对于不是接口返回、但用户在页面上实际能看到的内容，也建议同步补红标，例如：

```dart
NonFieldTag(
  reason: '按钮文案为本地固定文案',
  child: const Text('立即重试'),
);
```

适合优先补 `NonFieldTag` 的内容包括：

- 页面标题
- 本地按钮文案
- 空态提示
- 本地兜底图片 / 占位图
- 本地默认输入框文本
- 本地筛选项、Tab、导航文案

这里最容易踩偏的是两件事：

1. `requestKey` 必须和网络拦截器侧的规则一致
2. `path` 要写源 JSON 的真实数组下标，而不是当前列表经过筛选、排序后的 UI 下标

所以 langwise 的接入顺序建议是：

1. 先接根包装和网络拦截器，确保能看 JSON
2. 再挑 1 到 2 个来源明确的页面补 `FieldTag`
3. 同时把这些页面里明显不是接口下发的本地内容补 `NonFieldTag`
4. 最后再决定是否扩大蓝标 / 红标覆盖面

这里的边界需要明确：

- `FieldTag` 解决的是“接口字段 -> 控件”的追踪
- `NonFieldTag` 解决的是“这不是接口字段”的来源澄清
- 两者都属于 fieldlens 的公开能力，不是示例 APP 私有能力

## 5. macOS / Windows Runner

这是 langwise 接桌面独立 JSON 窗口时**必须改**的地方。

### 当前现状

目前 `langwise` Runner 只有主窗口插件注册：

- `macos/Runner/MainFlutterWindow.swift` 只做了 `RegisterGeneratedPlugins(registry: flutterViewController)`
- `windows/runner/flutter_window.cpp` 只做了 `RegisterPlugins(flutter_controller_->engine())`

这对于单窗口应用没有问题，但对 `desktop_multi_window` 不够。因为 JSON 面板在 macOS / Windows 上是单独创建的新 Flutter engine，如果不在“新窗口创建时”再补一次插件注册，副窗口里的：

- `window_manager`
- `desktop_multi_window`
- 以及其他方法通道插件

都有机会缺失。

### 需要补的宿主改动

#### macOS

需要在 `macos/Runner/MainFlutterWindow.swift`：

- 引入 `desktop_multi_window`
- 在主窗口注册插件后，增加 `FlutterMultiWindowPlugin.setOnWindowCreatedCallback`
- 在回调里对新建窗口的 controller 再执行一次 `RegisterGeneratedPlugins`

#### Windows

需要在 `windows/runner/flutter_window.cpp`：

- 引入 `desktop_multi_window` 对应头文件
- 在主窗口 `RegisterPlugins(...)` 之后，设置 `DesktopMultiWindowSetWindowCreatedCallback(...)`
- 在回调里对新窗口 engine 再调用一次 `RegisterPlugins(...)`

### 为什么这一步不能省

这是我们在 fieldlens 示例里已经实打实踩过的坑：  
主窗口能启动，不代表副窗口有完整插件注册。缺少这一步时，典型现象就是点击“JSON 面板”后没有窗口，日志里出现 `MissingPluginException`，最常见的是 `window_manager.ensureInitialized` 调用失败。

因此，**langwise 若要启用桌面独立 JSON 窗口，这一步不是优化项，而是必选项。**

## fieldlens 这边是否还要改

当前结论仍然是：**不用。**

已经满足 langwise 接入的能力包括：

- 最外层根包装 `FieldLens`
- 桌面端主窗口 / 副窗口分流 `FieldLensDesktopBootstrap.run(...)`
- Dio 采集适配 `FieldLensDioInterceptor`
- 桌面副窗口吸附与主窗口联动
- Android / iOS 维持窗口内 JSON 面板

这次核对后，没有发现 langwise 当前结构要求 fieldlens 再新增：

- GetX 专用适配
- WiseHttp 专用适配层
- BotToast 专用桥接
- 友盟 APM 专用入口 API

唯一要额外强调的是：fieldlens 目前仍然假设桌面多窗口的 Runner 由宿主补注册回调。如果未来产品目标变成“宿主零原生改动接入桌面副窗口”，那将是新的能力扩展，不属于这次 langwise 接入前置条件。

## 建议执行顺序

后续真正实施时，建议按下面顺序做，便于快速定位问题：

1. `langwise/pubspec.yaml` 增加 `fieldlens`、`fieldlens_dio`
2. 移动端先把 `MyApp` 包进 `FieldLens`
3. 桌面 fallback 切到 `FieldLensDesktopBootstrap.run(...)`
4. `initHttp()` 挂上 `FieldLensDioInterceptor`
5. 先不加 `FieldTag`，确认 JSON 面板能看到请求
6. 补 macOS / Windows Runner 多窗口插件注册
7. 最后在 1 到 2 个页面补 `FieldTag`

这样分阶段推进时，问题会更容易定位：

- 看不到面板，先查入口和桌面 Runner
- 看得到面板但没数据，先查网络拦截器
- 看得到数据但不能定位控件，再查 `FieldTag`
- 页面里一部分内容明明不是接口返回，却看不出来源，再补 `NonFieldTag`

## 本轮未执行事项

本轮仍然没有做这些事情：

- 没有修改 `langwise` 任何源码
- 没有对 `langwise` 跑 `flutter pub get`
- 没有对 `langwise` 跑 `flutter analyze`、测试或构建
- 没有验证 `wise_http` 的缓存命中、重试链是否会短路后续拦截器
- 没有验证 `langwise` 真实页面上的浮层遮挡和标签命中

所以本文是**基于当前仓库结构的接入设计说明**，不是“langwise 已完成接入”的完成报告。
