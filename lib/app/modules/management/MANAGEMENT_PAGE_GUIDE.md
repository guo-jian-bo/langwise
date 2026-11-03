# 管理端页面开发规范

## 一、为什么使用 tag 跳转页面

### 问题背景

使用 GetX 命名路由时，同一页面多次 push 会**共享控制器实例**。这导致：
- 从 A 页面跳转到 B 页面，再从 B 页面跳转到另一个 B 页面时，两个 B 页面共用同一个控制器
- 任意一个 B 页面销毁时，会导致所有 B 页面的控制器被销毁
- 面包屑导航无法正确区分同一页面的不同实例

### 解决方案

使用 `Get.to()` + `tag` 参数实现控制器多实例独立管理：
- 每个页面实例拥有**唯一 tag**（格式：`${Routes.XXX}_${timestamp}`）
- tag 同时作为面包屑 ID，确保每个页面实例可独立识别
- 页面销毁时只销毁对应 tag 的控制器，不影响其他实例

### tag 控制器的使用方法

```dart
// 1. 在 View 中通过 tag 获取控制器（GetView 自动处理）
class ManageXxxView extends GetView<ManageXxxController> {
  final String tagText;
  const ManageXxxView({super.key, required this.tagText});

  @override
  String? get tag => tagText;  // 重写 tag getter

  @override
  Widget build(BuildContext context) {
    // controller 会自动根据 tag 获取对应实例
    return Text(controller.someValue);
  }
}

// 2. 在其他地方通过 tag 获取控制器
final controller = Get.find<ManageXxxController>(tag: 'your_tag');

// 3. 检查控制器是否存在
if (Get.isRegistered<ManageXxxController>(tag: 'your_tag')) {
  // 控制器存在
}
```

---

## 二、创建新页面

### 1. 使用脚本创建页面

```bash
# 基本用法
./generate_manage_page.sh <page_name> -t '面包屑标题'

# 带父级目录
./generate_manage_page.sh <page_name> -p <parent_dir> -t '面包屑标题'
```

**示例：**
```bash
# 在 management/ 根目录下创建
./generate_manage_page.sh manage_topic -t '话题管理'

# 在 management/manage_content/ 下创建
./generate_manage_page.sh manage_topic -p manage_content -t '话题管理'

# 在 management/manage_study/ 下创建
./generate_manage_page.sh manage_topic -p manage_study -t '话题管理'
```

### 2. 脚本自动完成的工作

脚本会自动创建以下文件并配置：

| 文件 | 说明 |
|-----|------|
| `controllers/<name>_controller.dart` | 控制器，包含 tag 参数和 ManageBreadcrumbMixin |
| `bindings/<name>_binding.dart` | 绑定，使用 Get.lazyPut + tag + fenix: true |
| `views/<name>_view.dart` | 视图，包含 tagText 参数和静态 to 方法 |
| `app_routes.dart` | 自动添加 Routes 常量和 _Paths 常量 |
| `manage_page_registry.dart` | 自动注册页面跳转方法 |

---

## 三、页面结构模板

### 1. Controller 模板

```dart
import 'package:get/get.dart';

import '../../../../routes/routes.dart';
import '../../utils/manage_breadcrumb_utils.dart';

class ManageXxxController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageXxxController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_XXX;

  @override
  String get breadcrumbTitle => '页面标题';

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    // TODO: 初始化逻辑
  }

  @override
  void onClose() {
    // TODO: 清理逻辑
    super.onClose();
  }
}
```

### 2. Binding 模板

```dart
import 'package:get/get.dart';

import '../controllers/manage_xxx_controller.dart';

class ManageXxxBinding extends Bindings {
  final String tag;
  ManageXxxBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageXxxController>(
      () => ManageXxxController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
```

### 3. View 模板

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/routes.dart';
import '../../common/manage_scaffold.dart';
import '../bindings/manage_xxx_binding.dart';
import '../controllers/manage_xxx_controller.dart';

class ManageXxxView extends GetView<ManageXxxController> {
  final String tagText;
  const ManageXxxView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_XXX}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageXxxView(tagText: tag),
      binding: ManageXxxBinding(tag: tag),
      routeName: Routes.MANAGE_XXX,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      body: Center(
        child: Text('页面标题'),
      ),
    );
  }
}
```

---

## 四、权限控制

管理端页面中的按钮和事件需要进行权限控制，有两种方式：

### 1. 隐藏按钮 - 使用 ManageAuthBoxWidget

当用户没有权限时，按钮完全不显示。

```dart
import '../../../utils/utils.dart';  // 包含 ManageAuthUtils 和 ManageAuthCode
import '../../../common/commons.dart';  // 包含 ManageAuthBoxWidget

// 单个权限
ManageAuthBoxWidget(
  authCodes: const [ManageAuthCode.enContentKnowledgeList],
  child: ButtonWidget(
    text: "按钮文字",
    onTap: () {
      // 按钮点击事件
    },
  ),
),

// 多个权限（需要全部满足）
ManageAuthBoxWidget(
  authCodes: const [
    ManageAuthCode.enContentSemanticList, 
    ManageAuthCode.exerciseTypeList,
    ManageAuthCode.exercisePage,
  ],
  child: ButtonWidget(
    text: "题目",
    onTap: () {
      onSemanticExercises?.call(semantic!);
    },
  ),
),

// 多个权限（任意一个满足即可）
ManageAuthBoxWidget(
  authCodes: const [ManageAuthCode.enWordEdit, ManageAuthCode.enPhraseEdit],
  isAny: true,  // 设置为 true 表示任意权限满足即可
  child: ButtonWidget(
    text: "编辑",
    onTap: () {
      // 编辑操作
    },
  ),
),

// 带边距的权限控制
ManageAuthBoxWidget(
  authCodes: const [ManageAuthCode.enPhraseDelete],
  margin: EdgeInsets.only(left: 8.wMin),
  child: TapScaleWidget(
    onTap: () {
      onDeleteKnowledge?.call();
    },
    child: Container(
      // 按钮内容
    ),
  ),
),
```

### 2. 禁用事件 - 使用 ManageAuthUtils.isAuth

当用户没有权限时，按钮可见但点击无效。适用于需要在 Controller 中控制的场景。

```dart
import '../../../utils/utils.dart';  // 包含 ManageAuthUtils 和 ManageAuthCode

// 在方法开头检查权限，无权限直接返回
Future<void> jumpToAudioManage(EnKnowledgeEntity entity, EnKnowledgeEntityAudioExpressionList data) async {
  // 权限检查：无权限直接返回，不执行后续逻辑
  if (!ManageAuthUtils.isAuth(ManageAuthCode.audioExpressQuery)) return;

  // 有权限才执行后续逻辑
  await ManagePageRegistry.jumpTo(
    Routes.MANAGE_AUDIO_SUBTITLE_EDITOR,
    arguments: {
      "audioList": audios,
      "currentAudioIndex": index,
      "type": entity.contentType,
    },
  );
}

// 检查多个权限（全部满足）
void someAction() {
  if (!ManageAuthUtils.isAuths([
    ManageAuthCode.enWordEdit,
    ManageAuthCode.enWordSemanticEdit,
  ])) return;
  
  // 执行操作
}

// 检查多个权限（任意一个满足）
void anotherAction() {
  if (!ManageAuthUtils.isAnyAuth([
    ManageAuthCode.enWordEdit,
    ManageAuthCode.enPhraseEdit,
  ])) return;
  
  // 执行操作
}
```

### 3. 在 View 中根据权限控制 UI 逻辑

```dart
// 根据权限决定回调是否为 null
ManageCrossFadeWidget(
  title: "包含语义 (${entity.data.semantics?.length ?? 0})",
  firstChild: _buildSemanticListWidget(context),
  buttonText: "添加语义",
  // 无权限时 onButton 为 null，按钮不可点击或不显示
  onButton: !ManageAuthUtils.isAuth(ManageAuthCode.enWordEdit) 
      ? null 
      : () {
          onAddSemantic?.call();
        },
),
```

---

## 五、权限码定义

权限码定义在 `ManageAuthCode` 类中，位于 `lib/app/modules/management/utils/manage_auth_utils.dart`。

**常用权限码示例：**

```dart
// 单词相关
ManageAuthCode.enWordPages          // 单词列表
ManageAuthCode.enWordEdit           // 编辑单词
ManageAuthCode.enWordDelete         // 删除单词
ManageAuthCode.enWordSemanticEdit   // 编辑单词语义
ManageAuthCode.enWordSemanticDelete // 删除单词语义
ManageAuthCode.enWordEditSemanticAdd // 单词关联语义

// 短语相关
ManageAuthCode.enPhrasePages        // 短语列表
ManageAuthCode.enPhraseEdit         // 编辑短语
ManageAuthCode.enPhraseDelete       // 删除短语
ManageAuthCode.enPhraseSemanticDelete // 删除短语语义

// 内容审核相关
ManageAuthCode.enContentSemanticList // 语义列表
ManageAuthCode.enContentKnowledgeList // 核心知识点
ManageAuthCode.contentReviewImageLock // 图片定稿
ManageAuthCode.contentReviewImageUnlock // 图片解锁定稿

// 题目相关
ManageAuthCode.exercisePage         // 题目列表
ManageAuthCode.exerciseTypeList     // 题目类型列表
ManageAuthCode.exerciseEdit         // 编辑题目
ManageAuthCode.exerciseDelete       // 删除题目

// 音频相关
ManageAuthCode.audioExpressQuery    // 音频查询
ManageAuthCode.audioGenerate        // 生成音频
ManageAuthCode.audioWordEdit        // 编辑单词发音
```

---

## 六、页面跳转

### 1. 推荐方式：ManagePageRegistry.jumpTo

```dart
// 简洁调用
await ManagePageRegistry.jumpTo(Routes.MANAGE_WORD);

// 带参数
await ManagePageRegistry.jumpTo(Routes.MANAGE_WORD_AUDIO, arguments: {"wordId": 123});

// 获取返回值
bool? result = await ManagePageRegistry.jumpTo<bool>(
  Routes.APPROVED_IMAGES_CONFIRM, 
  arguments: {...}
);
```

---

## 七、注意事项

1. **tag 命名规则**：
   - `ManagePageRegistry.jumpTo()` / `View.to()`：`${Routes.XXX}_${timestamp}` 动态生成
   - 命名路由：使用 `Routes.XXX` 作为固定 tag

2. **fenix: true**：确保控制器在页面返回后可重新创建

3. **preventDuplicates: false**：允许同一页面多次 push

4. **权限控制选择**：
   - 需要完全隐藏按钮 → 使用 `ManageAuthBoxWidget`
   - 需要在 Controller 中控制逻辑 → 使用 `ManageAuthUtils.isAuth()`
   - 需要根据权限决定回调是否为 null → 在 View 中使用 `ManageAuthUtils.isAuth()`

5. **导入路径**：
   - 权限工具：`import '../../../utils/utils.dart';`
   - 权限组件：`import '../../../common/commons.dart';`

---

## 八、代码警告处理规范

**重要：不允许有警告（文件/文件夹呈黄色）**

新创建的页面可能会有以下警告，需要在后期处理：

### 常见警告及处理方法

1. **未使用的导入**
   ```dart
   // 删除未使用的 import 语句
   // 或添加 ignore 注释（不推荐）
   // ignore: unused_import
   ```

2. **未使用的变量/参数**
   ```dart
   // 使用下划线前缀表示有意忽略
   void onTap(BuildContext _) { ... }
   
   // 或使用变量
   final _ = unusedValue;
   ```

3. **缺少 const 构造函数**
   ```dart
   // 在可以使用 const 的地方添加 const
   const ManageXxxView({super.key, required this.tagText});
   ```

4. **TODO 注释警告**
   ```dart
   // 完成 TODO 后删除注释，或替换为实际实现
   // TODO: 初始化逻辑  →  删除或实现
   ```

### 使用 AI 消除警告

可以使用以下提示词让 AI 帮助消除警告：

```
请帮我检查并修复以下文件中的所有警告：
[文件路径]

需要处理：
1. 未使用的导入
2. 未使用的变量
3. 缺少 const
4. TODO 注释
5. 其他 Dart 分析器警告
```
