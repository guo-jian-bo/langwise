# 04 · 最小侵入接入 Flutter App

## 接入范围

FieldLens 是可插拔的 Flutter 组件与可选网络适配包。核心包本轮新增了桌面窗口管理依赖，但接入方式仍然保持在 Flutter 层，不要求宿主自行实现多窗口路由；网络与剪贴板继续使用宿主及 Flutter 既有能力。

本轮新增桌面多窗口能力，但接入目标不变：**仍然以最外层插件包装 + 最小入口改动接入宿主 App**。

接入收敛为：添加依赖、最外层包装、网络初始化处安装适配器、为需要精准溯源的控件保留 `FieldTag`。不要求业务创建/传递调试控制器，不在页面捕获 JSON，不改 App 的路由或状态管理。

## 依赖与已验证边界

假设宿主与 fieldlens 仓库是同级目录：

```yaml
dependencies:
  fieldlens:
    path: ../fieldlens/packages/fieldlens
  # 按实际客户端选择，可同时使用。
  fieldlens_dio:
    path: ../fieldlens/packages/fieldlens_dio
  fieldlens_http:
    path: ../fieldlens/packages/fieldlens_http
  fieldlens_mqtt:
    path: ../fieldlens/packages/fieldlens_mqtt
```

- 核心 Dart SDK 约束 `^3.11.5`，验证基线 Flutter 3.41.9 / Dart 3.11.5。
- 适配包分别依赖 Dio `^5.9.0`、http `^1.2.0`、mqtt5_client `^4.11.0`。使用客户端的宿主代码应直接声明对应客户端依赖。
- 仓库保留 pub workspace；`validation/external_host` 不属于 workspace、没有 `resolution: workspace`，用于独立 path 依赖解析与编译验证。
- 旧文档「workspace 成员必定不能被外部依赖」不成立。本期提供 checkout/path 接入，没有发布 pub 包、创建 tag 或验证 Git 分发。
- 未验证低版本 Flutter、其他平台或真实宿主的全部依赖组合；不能以旧 pubspec 的 Flutter `>=1.17.0` 声明作为兼容保证。

## 最外层包装

```dart
import 'package:fieldlens/fieldlens.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  await FieldLensDesktopBootstrap.run(
    mainApp: const FieldLens(child: MyApp()),
  );
}
```

`MyApp` 内部继续使用原来的 `MaterialApp`、`GetMaterialApp` 或 `MaterialApp.router`，无需改 `builder`。默认面板关闭，右上角提供「字段名」「非接口」「JSON 面板」三个独立开关。

- macOS / Windows：JSON 面板为独立桌面窗口，业务主窗口尺寸不变；桌面窗口可拖动到主窗口外并吸附在四边。
- Android / iOS：JSON 面板继续为窗口内覆盖层，新增透明度滑轨，默认 `100%`，范围 `0% ~ 100%`。
- 业务子树保留原 Navigator、主题、MediaQuery。只有调试区域补充独立 Material、Directionality、Localizations、MediaQuery、Navigator/Overlay。
- 调试区域外不参与点击拦截；JSON 更新、面板开关和宽度调整不重建业务根节点。
- 字段标签仍使用业务路由最近的 Overlay；自建无 Overlay 的裸控件树需要宿主提供 Overlay。
- 最外层调试区或桌面副窗口会盖住重叠的业务内容；与宿主已有浮窗的遮挡关系仍需实际检查。

如果宿主当前没有桌面需求，也可以继续直接：

```dart
runApp(const FieldLens(child: MyApp()));
```

但后续一旦要启用桌面独立窗口，推荐统一切到 `FieldLensDesktopBootstrap.run(...)`。

## 网络初始化

### Dio

```dart
import 'package:dio/dio.dart';
import 'package:fieldlens_dio/fieldlens_dio.dart';

final dio = Dio();
dio.interceptors.add(FieldLensDioInterceptor());
```

拦截器在 `onRequest`、`onResponse` 和带响应的 `onError` 中旁路登记/捕获，每次调用一次 `handler.next`，不修改请求、响应、错误、重试策略或下游拦截链。

**请求发起即显示**：`onRequest` 阶段即把请求登记进面板（含请求参数快照），请求列表立即可见并可查看「请求参数」；响应未返回前「响应参数」页显示等待提示，响应到达后同一条记录原地补全为完整响应（历史不重复追加）。面板未选中任何请求时自动选中该请求；正在查看其他请求则只新增列表条目、不打断。请求参数快照已按 `truncateToBytes` 限额，主线程开销可接受；`filter` 返回 false 或 stream/bytes 请求与响应采集同规则跳过。

- Map/List 的有界副本在 isolate 编码为 JSON 文本，请求元数据标注「已解码对象编码」，不能当作线上原始字节；面板「重编码」按钮可在查看时重新序列化（默认不重编码）。
- String 需 JSON Content-Type（`application/json` 或 `+json`）。Map/List 无 Content-Type 时也可捕获；显式非 JSON 类型跳过。
- `ResponseType.stream`、`ResponseType.bytes` 跳过；文件、multipart、流式请求正文不提前读取。
- 安装在你希望观察的数据转换之前。上游拦截器若直接 resolve 并跳过后续响应链，此适配器无法凭空观察该响应；缓存命中、重试和错误分支须在宿主确认。

### package:http

```dart
import 'package:http/http.dart' as http;
import 'package:fieldlens_http/fieldlens_http.dart';

final client = FieldLensHttpClient(http.Client());
final response = await client.get(uri);
// 正常业务解析，页面不调用 capture。
```

### MQTT（mqtt5_client）

```dart
import 'package:fieldlens_mqtt/fieldlens_mqtt.dart';

// 在 mqtt5_client 的 updates 监听回调里，把收到的消息旁路写进面板：
client.updates.listen((messages) {
  final publishMessage = messages.first.payload as MqttPublishMessage;
  final payload = MqttUtilities.bytesToStringAsString(publishMessage.payload.message!);
  final topic = publishMessage.variableHeader?.topicName;

  FieldLensMqtt.captureMessage(topic: topic ?? '', payload: payload);

  // 业务分发继续，不受影响。
});

// 发布的消息（如清除 retain、主动发布）也可捕获：
FieldLensMqtt.capturePublish(topic: topic, payload: payload);
```

- requestKey 格式为 `MQTT mqtt://<topic>`，面板解析为 method=`MQTT`、host=`mqtt://<host>`、path=`/<topic>`。
- 重复 topic 的各条消息按历史独立保留，可在左侧列表中分别选中查看。
- 仅旁路捕获，不修改 MQTT 消息流、订阅或业务分发链；捕获失败静默忽略。

包装你实际使用的 Client；仍调用静态 `http.get` 的请求不会经过它。

- `send` 不等待正文读完才交付响应。业务监听响应流时，按原顺序转发每个数据块、错误与结束事件，保留暂停、恢复、取消和响应元数据。
- 流结束前不提交完整缓存；取消或流错误放弃本次采集。业务不消费响应流时，也不会偷偷消费。
- `http.Request` 的已缓冲 JSON 正文可安全复制；`StreamedRequest`、multipart 和其他流式请求不提前消费。
- 只捕获 JSON Content-Type；非 JSON、二进制、SSE 原样旁路。无法仅凭头部判断伪装成 JSON 的无限流，请通过 `filter` 排除已知流式端点。
- `client.close()` 转发到被包装 Client；客户端生命周期仍由网络服务管理。

两种适配器都包含失败隔离：过滤、key、脱敏、编码、解析等调试错误不改变业务网络结果。不要重复给同一客户端安装多个采集适配器。

## 请求 key 与精准标签

```dart
final uri = Uri.parse('https://api.example.com/page?b=2&a=1&a=3');
final key = FieldLensRequestKey.fromUri('get', uri);
// GET https://api.example.com/page?a=1&a=3&b=2
FieldTag(requestKey: key, path: 'data.title', child: Text(title));
```

统一规则：方法大写，保留 URI 的 scheme/host/port/path，query 名称排序、同名值顺序不变，移除 fragment 和 URL userInfo。URI 自身会规范化标准端口等表示。两种适配器默认共用此工具。

自定义 key 由回调接收 `FieldLensNetworkRequest`（method、uri、headers、有限 body 副本），例如复用业务常量：

```dart
const pageKey = 'page-config';
final interceptor = FieldLensDioInterceptor(
  requestKeyBuilder: (request) => request.uri.path == '/page'
      ? pageKey
      : FieldLensRequestKey.fromUri(request.method, request.uri),
);
```

相同 key 仅保留最新捕获，不是历史归档。并发请求按响应登记先后决定新旧，较慢的旧编码任务不能覆盖新结果。分页通常把页码纳入 key；同地址不同 body 默认会合并，必要时由业务选择区分维度，标签必须使用完全相同规则。敏感 query 不宜直接进入展示 key，`redact` 不会替你修改已经选择的 key。

`path` 是原响应路径，支持 `data.items[3].title` 与 `data.items.3.title`。过滤、排序、合并分页后仍需保留每项的源请求 key 和源数组下标；业务 id 不能直接替代数组下标。

```dart
FieldTag(
  requestKey: key,
  path: 'data.form.account.placeholder',
  placement: FieldTagPlacement.insideEnd,
  child: TextField(decoration: InputDecoration(hintText: hint)),
);
NonFieldTag(reason: '本地固定文案', child: const Text('帮助'));
```

`placement` 还支持 `aboveStart`、`aboveEnd`、`insideStart`。`label` 只改标签文案，不改变路径。未加 `FieldTag` 的控件不会自动变红；缺失/空字段的业务展示策略未规定。

当前正式接入方式仍然是显式标注。如果宿主页面很多、人工补标签成本较高，可以参考 [09](09-semi-auto-tagging-plan.md) 的“自动补标签”方案：从 JSON 窗口顶栏按钮直接触发运行时自动落蓝/红标，用来快速验证页面来源。

## 过滤与脱敏

请求头、响应头现在默认按原始文本保存，不再内置 `Authorization`、`Cookie` 等字段的自动遮蔽。URL userInfo 仍不记录；query、body 中的业务敏感字段同样不会自动识别。

`filter` 与 `requestKeyBuilder` 在请求副本上执行；`redact` 在 isolate 中对 JSON 副本执行，section 为 `request` 或 `response`。推荐顶层/静态函数，不要捕获 UI、Client 或其他不可发送对象。

```dart
Object? redactBusiness(String section, Object? value) {
  if (value is! Map) return value;
  if (section == 'request') {
    final query = value['query'];
    if (query is Map) query.remove('token');
    // query 在 url 中也有一份，应同步处理。
    final url = value['url'];
    if (url is String) {
      final uri = Uri.parse(url);
      final params = Map<String, dynamic>.from(uri.queryParametersAll)..remove('token');
      value['url'] = uri.replace(queryParameters: params).toString();
    }
    final body = value['body'];
    if (body is Map && body.containsKey('password')) body['password'] = '[已遮蔽]';
  } else if (value.containsKey('accessToken')) {
    value['accessToken'] = '[已遮蔽]';
  }
  return value;
}

final interceptor = FieldLensDioInterceptor(
  filter: (request) => request.uri.host == 'api.example.com',
  requestKeyBuilder: (request) => '${request.method} ${request.uri.path}',
  redact: redactBusiness,
);
```

同样的参数可传给 `FieldLensHttpClient`。示例只是规则写法，不是通用业务脱敏策略；需按真实 JSON 层级完善。不要用包含密码的 body 或 query 直接拼 key。脱敏异常时丢弃整条采集；截断正文无法安全脱敏时只保存省略说明，不保存未脱敏前缀。若宿主明确要求“所有敏感数据都显示原文”，则不要传 `redact`，fieldlens 会直接保留原始文本。

## 共享会话、生命周期与预算

三个默认入口使用惰性 `FieldLensController.shared`，包装器卸载不销毁它，重新挂载后缓存仍在。也可以显式隔离：

```dart
final controller = FieldLensController(
  config: const FieldLensConfig(byteBudget: 20 * 1024 * 1024),
);
final interceptor = FieldLensDioInterceptor(controller: controller);
final client = FieldLensHttpClient(http.Client(), controller: controller);
final root = FieldLens(controller: controller, child: const MyApp());
// 显式实例由调用方在所有使用者退出后 controller.dispose()。
```

构建期通知会合并到帧末；销毁后的捕获忽略，异步任务检查生命周期和版本。适配器在响应到达时登记任务，立即点击标签会等待该 key 的捕获；JSON 解码、重编码与铺平在 isolate 中进行，业务响应不等待调试完成。

默认总缓存 20 MiB，响应阈值 8 MiB，超大响应最多保留 256 KiB 前缀；请求参数默认限 256 KiB，超限省略并注明。Dio 普通对象复制另有深度/复制预算，过大或非普通 JSON 对象会用说明替代，不调用业务 `toJson`。http 缓冲越限后缩到前缀上限，后续数据只转发。

缓存只保留文本，不为每个请求保存解析树；同一控制器仅保留当前解析行表。LRU 预算按请求与响应 UTF-8 字节总量计算，不是进程 RSS 硬上限。并发任务、对象快照、isolate 临时内存和业务客户端缓冲额外占用内存。高频/大载荷端点应先过滤。`cache.pin/unpin` 是可选手动保护，标签使用登记不会自动 pin；全部 pin 时预算可能超限。

## 面板与旧 API 迁移

请求/响应视图共用搜索、展开、折行、字号和右键复制。点字段标签会自动打开面板并切回响应。反向 ● 仅针对当前活动请求的响应，活动请求由最近登记/点击的标签决定，不是最近网络响应；只追踪已挂载控件，不扫描未构建列表项。

移动端新增透明度滑轨，仅改变 JSON 面板的可视透明度，不支持点击穿透到底层页面。

面板获得焦点后：`⌘F` 搜索，`⌘=` / `⌘-` 调字号，搜索框 `Enter` 跳下一个命中，`Esc` 先清空搜索再关闭面板。右键可复制字段名、标量值、字段和值或路径，不复制整棵容器子树。

已有集成不强制迁移：

- `FieldLensWorkspace(controller:, child:)` 保留原分栏，放在已有 Material/Overlay 环境内。默认构造的旧控制器仍从面板打开状态开始。
- `FieldLensScope`、`FieldLensPanel` 可继续组合自定义宿主；不要同时挂两套面板。
- `controller.capture(key, rawText, request: requestJson, label: label)` 仍可用。手动 API 不自动脱敏，调用方若需要隐藏敏感数据必须自己先处理；捕获字节计量在调用线程，建议大对象改走网络适配管线。
- 迁移时先替换手写拦截器，再移除页面 capture 与调试控制器传递；有定制 key 时务必先配置 `requestKeyBuilder`。

## 编译期开关与入口显示

`FIELDLENS_ENABLED` 是编译期总开关，默认 `true`（debug / profile / release 全模式生效）：

```bash
# 显式关闭（tree-shaking，不采集任何调试数据）
flutter build macos --release --dart-define=FIELDLENS_ENABLED=false
```

关闭路径覆盖 `FieldLens`、`FieldLensWorkspace`、标签登记/监听、控制器捕获/解析与两个网络适配器；业务 child 和网络结果原样继续，不采集、编码或解析调试数据。底层 `FieldLensScope`/`FieldLensPanel` 若被宿主手动直接构建，宿主仍需控制挂载；业务自己计算的 `jsonEncode` 不会被库替你消除。常量分支支持 tree-shaking，不保证整个库的所有符号必然从产物消失。

### 宿主按构建模式控制入口显示

`FieldLens` 提供 `showEntry` 参数（默认 `true`，全模式显示）：传 `false` 时完全旁路调试 UI——只渲染业务 child，不创建入口工具条与内嵌面板，也不挂桌面副窗口。宿主可传任意构建模式判断：

```dart
// 仅 release/profile 显示，debug 日常开发不打扰。
FieldLens(child: app, showEntry: !kDebugMode);

// 仅 debug 显示。
FieldLens(child: app, showEntry: kDebugMode);

// 任意业务条件（如内部构建标识）均可。
FieldLens(child: app, showEntry: isInternalBuild);
```

- 网络适配器侧的捕获不受此参数影响：隐藏期间数据照常采集，改回 `true` 时历史仍在。
- 与 `FIELDLENS_ENABLED=false` 的区别：后者编译期关闭所有采集；前者仅隐藏入口 UI。
- 运行时切换该参数（热重载/`didUpdateWidget`）即时生效，控制器与缓存不销毁。

## 验证清单

仓库内运行：

```bash
flutter pub get
flutter analyze --no-pub
flutter test --no-pub packages/fieldlens/test packages/fieldlens_dio/test packages/fieldlens_http/test packages/fieldlens/example/test
dart run tool/verify_plugin.dart
```

最后一个命令执行非 workspace 宿主依赖解析、`FIELDLENS_ENABLED=false` 独立测试、bundle 编译与 macOS 示例 debug 构建；非 macOS 环境可加 `--skip-macos`。

真实宿主仍需确认：SDK 与客户端版本、路由/全局 Overlay、输入焦点、缓存命中拦截链、准确的 key/源下标、敏感字段脱敏、实际平台构建。langwise 的特定步骤见 [05](05-integration-langwise.md)，本轮没有修改其源码。

桌面独立窗口的吸附、联动和 Windows 当前验证口径见 [07](07-desktop-detached-window.md)。
