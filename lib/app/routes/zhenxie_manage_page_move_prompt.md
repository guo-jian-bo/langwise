你是一个资深 Flutter(GetX) 工程师。请按照本文件要求，把一批原本位于管理端目录下的“真写句子相关页面”迁移到 `lib/app/modules/zhenxie` 下面，并改造成“用户端页面兼容管理端打开”的统一结构。

本次任务不是简单挪目录，而是一次完整迁移，必须同时完成：
- 目录迁移
- 迁移后的目录名前统一增加 `zhenxie_` 前缀
- 文件名去掉 `manage_` 前缀
- 迁移后的文件名前统一增加 `zhenxie_` 前缀
- 类名去掉 `Manage` 前缀
- 迁移后的类名前统一增加 `Zhenxie` 前缀
- 路由从 `Routes.MANAGE_*` 迁移到新的 `Routes.ZHENXIE_*`
- Controller 从 `ManageBreadcrumbMixin` 切到 `DualBreadcrumbMixin`
- 页面增加 `isManagement` 兼容参数
- 管理台入口统一改成传 `{"isManagement": true}`
- `ManagePageRegistry` 改成注册新的 zhenxie 页面 `toManage`
- 公共弹窗 `edit_name_desc_dialog.dart` 移到 `lib/common/widgets`
- 页面内部跳转统一改成 `TagRoutes.toNamed(...)`，不要继续沿用 `ManagePageRegistry.jumpTo(...)`

必须同时参考：
- [manage_compatible_page_prompt.md](file:///Users/langwise/Desktop/ns/project/langwise/lib/app/routes/manage_compatible_page_prompt.md)
- [tag_routes_migration_prompt.md](file:///Users/langwise/Desktop/ns/project/langwise/lib/app/routes/tag_routes_migration_prompt.md)

目标：
- 这些页面在物理目录上属于 `zhenxie` 模块，不再继续放在 `management/manage_content/manage_zhenxie_console` 下
- 页面本质上变成“用户端页面”，但仍然能从管理端打开
- 用户端和管理端共用同一套页面代码，只通过 `isManagement` 区分兼容行为
- 迁移后路由、面包屑、跳转链路、弹窗引用、管理台入口都保持可用

硬性约束：
- 只做本次迁移需要的改动，不做无关重构
- 不改视觉样式，除非兼容管理端必须补上 `BreadcrumbWidget`
- 不引入新依赖
- 新增字段、方法、关键分支必须补简短注释
- 保持当前文件已有排版习惯，能单行看清就不要强行折行
- 禁止嵌套三元表达式
- 不要误改 `ManageScaffold`、`ManagePageRegistry`、`ManageBreadcrumbController` 这类现有公共管理能力的命名，它们不是本次“去 manage 前缀”的目标

一、迁移目录映射
把以下目录整体迁移到 `lib/app/modules/zhenxie/` 下，并去掉目录名前的 `manage_`，同时统一补上 `zhenxie_` 前缀，命名风格参考：
- `lib/app/modules/zhenxie/zhenxie_enter_sentence`
- `zhenxie_enter_sentence_view.dart`
- `ZhenxieEnterSentenceView`

1. `manage_grammar_panorama`
   -> `lib/app/modules/zhenxie/zhenxie_grammar_panorama`
2. `manage_grammar_panorama_details`
   -> `lib/app/modules/zhenxie/zhenxie_grammar_panorama_details`
3. `manage_pattern_blueprint`
   -> `lib/app/modules/zhenxie/zhenxie_pattern_blueprint`
4. `manage_pattern_blueprint_details`
   -> `lib/app/modules/zhenxie/zhenxie_pattern_blueprint_details`
5. `manage_sentence_pair`
   -> `lib/app/modules/zhenxie/zhenxie_sentence_pair`
6. `manage_sentence_pair_details`
   -> `lib/app/modules/zhenxie/zhenxie_sentence_pair_details`
7. `manage_sentence_pair_fork_details`
   -> `lib/app/modules/zhenxie/zhenxie_sentence_pair_fork_details`
8. `manage_sentence_pattern_compare`
   -> `lib/app/modules/zhenxie/zhenxie_sentence_pattern_compare`
9. `manage_sentence_pattern_compare_details`
   -> `lib/app/modules/zhenxie/zhenxie_sentence_pattern_compare_details`

二、文件名与类名重命名规则
迁移范围内的“页面自身文件”都要去掉 `manage_` / `Manage` 前缀，并统一补上 `zhenxie_` / `Zhenxie` 前缀。

规则：
- 文件名：`manage_xxx.dart` -> `zhenxie_xxx.dart`
- 类名：`ManageXxx` -> `ZhenxieXxx`

示例：
- `manage_grammar_panorama_view.dart` -> `zhenxie_grammar_panorama_view.dart`
- `ManageGrammarPanoramaView` -> `ZhenxieGrammarPanoramaView`
- `manage_grammar_panorama_controller.dart` -> `zhenxie_grammar_panorama_controller.dart`
- `ManageGrammarPanoramaController` -> `ZhenxieGrammarPanoramaController`
- `manage_grammar_panorama_binding.dart` -> `zhenxie_grammar_panorama_binding.dart`
- `ManageGrammarPanoramaBinding` -> `ZhenxieGrammarPanoramaBinding`

这个规则不仅适用于 View / Controller / Binding，也适用于迁移目录内的局部 Widget / Dialog 文件，例如：
- `manage_pattern_edit_represent_dialog.dart` -> `zhenxie_pattern_edit_represent_dialog.dart`
- `ManagePatternEditRepresentDialog` -> `ZhenxiePatternEditRepresentDialog`
- `manage_sentence_pair_item_widget.dart` -> `zhenxie_sentence_pair_item_widget.dart`
- `ManageSentencePairItemWidget` -> `ZhenxieSentencePairItemWidget`
- `manage_sentence_fork_item_widget.dart` -> `zhenxie_sentence_fork_item_widget.dart`
- `ManageSentenceForkItemWidget` -> `ZhenxieSentenceForkItemWidget`
- `manage_edit_pair_sentence_dialog.dart` -> `zhenxie_edit_pair_sentence_dialog.dart`
- `ManageEditPairSentenceDialog` -> `ZhenxieEditPairSentenceDialog`
- `manage_edit_compare_group_dialog.dart` -> `zhenxie_edit_compare_group_dialog.dart`
- `ManageEditCompareGroupDialog` -> `ZhenxieEditCompareGroupDialog`

注意：
- 只重命名迁移模块自身的页面类、局部组件类、局部弹窗类
- 不要重命名实体类、HTTP 请求类、管理公共基建类，除非本次迁移明确要求
- 命名风格必须与现有 `zhenxie_enter_sentence` 对齐，不能出现一部分是 `zhenxie_xxx`、另一部分仍是裸 `xxx`

三、公共弹窗迁移要求
把：
- `lib/app/modules/management/dialog/edit_name_desc_dialog.dart`

迁移到：
- `lib/common/widgets/edit_name_desc_dialog.dart`

并同步去掉类名前缀：
- `EditNameDescDialogResult` -> `EditNameDescDialogResult`
- `EditNameDescDialog` -> `EditNameDescDialog`
- `EditNameDescDialogWidget` -> `EditNameDescDialogWidget`

同时必须完成：
1. 更新所有引用它的文件 import
2. 更新所有调用类名
3. 在 `lib/common/widgets/widgets.dart` 里新增导出：
   `export 'edit_name_desc_dialog.dart';`
4. 全局搜索旧类名和旧文件路径，确保没有残留引用
5. 如果 `lib/app/modules/management/dialog/dialogs.dart` 仍被其他地方依赖，需要一并更新其导出，或在确认无引用后清理旧导出

当前已知直接引用点包括：
- `manage_pattern_blueprint_details_controller.dart`
- `manage_grammar_panorama_details_controller.dart`
- `manage_sentence_pair_details_controller.dart`
- `manage_sentence_pattern_compare_details_controller.dart`

四、路由迁移规则
这些页面迁移到 `zhenxie` 后，不再继续使用 `Routes.MANAGE_*` 作为业务主路由，改为新增 `Routes.ZHENXIE_*`。

新增路由建议命名如下：
- `Routes.ZHENXIE_GRAMMAR_PANORAMA`
- `Routes.ZHENXIE_GRAMMAR_PANORAMA_DETAILS`
- `Routes.ZHENXIE_PATTERN_BLUEPRINT`
- `Routes.ZHENXIE_PATTERN_BLUEPRINT_DETAILS`
- `Routes.ZHENXIE_SENTENCE_PAIR`
- `Routes.ZHENXIE_SENTENCE_PAIR_DETAILS`
- `Routes.ZHENXIE_SENTENCE_PAIR_FORK_DETAILS`
- `Routes.ZHENXIE_SENTENCE_PATTERN_COMPARE`
- `Routes.ZHENXIE_SENTENCE_PATTERN_COMPARE_DETAILS`

对应 `_Paths` 建议：
- `/zhenxie-grammar-panorama`
- `/zhenxie-grammar-panorama-details`
- `/zhenxie-pattern-blueprint`
- `/zhenxie-pattern-blueprint-details`
- `/zhenxie-sentence-pair`
- `/zhenxie-sentence-pair-details`
- `/zhenxie-sentence-pair-fork-details`
- `/zhenxie-sentence-pattern-compare`
- `/zhenxie-sentence-pattern-compare-details`

需要修改的位置：
1. `lib/app/routes/app_routes.dart`
2. `lib/app/routes/app_pages.dart`
3. `lib/app/routes/tag_routes.dart`
4. `lib/app/modules/management/utils/manage_page_registry.dart`

要求：
1. `app_pages.dart` 为新 zhenxie 页面补齐 `GetPage`
2. `tag_routes.dart` 为新 zhenxie 页面补齐 `Routes.ZHENXIE_*: XxxView.to`
3. `manage_page_registry.dart` 只注册“管理台首页会直接进入的列表页/入口页”，并改为注册新 zhenxie 页面：

   ```dart
   Routes.ZHENXIE_XXX: XxxView.toManage,
   ```

4. 详情页默认不需要补 `toManage`，也默认不需要注册到 `ManagePageRegistry`
5. 迁移范围内的页面内部跳转，全部改成使用新的 `Routes.ZHENXIE_*`
6. 全局搜索旧的 `Routes.MANAGE_*` 引用；对于本次迁移涉及的这 9 组页面，业务代码里应尽量替换为新的 `Routes.ZHENXIE_*`
7. 只有在确认迁移范围外仍有引用时，才临时保留旧 `MANAGE_*` 常量；否则可以清理

当前已知需要同步替换的地方包括：
- `manage_zhenxie_console_controller.dart`
- `manage_unit_grammar_target_details_controller.dart`
- 各个列表页跳详情
- 各个详情页跳下一级详情
- `ManagePageRegistry` 注册表

这里要特别注意两条：
- 像 `manage_grammar_panorama_controller.dart` 里当前这种 `await ManagePageRegistry.jumpTo(...)`，迁移后要统一改成 `TagRoutes.toNamed(...)`，写法对齐 `zhenxie_enter_sentence_controller.dart`
- 像 `zhenxie_enter_sentence_details_view.dart` 这种详情页，不要机械补 `toManage`，除非它确实需要被管理台首页或其他管理公共入口直接打开

五、页面结构改造要求
迁移后的页面必须遵循 `zhenxie` 模块现有结构，参考：
- `zhenxie_enter_sentence`
- `zhenxie_enter_sentence_details`

每个页面都要改成“tag 多实例 + 兼容管理端”的标准结构。

1. View 要求
- 保留 `GetView<Controller>`
- 使用 `final String tagText;`
- `const XxxView({super.key, required this.tagText});`
- `@override String? get tag => tagText;`
- 列表页/入口页提供两个静态跳转方法：

```dart
static Future<T?> toManage<T>({dynamic arguments}) async
static Future<T?> to<T>({dynamic arguments, required String tag}) async
```

- `toManage` 自己生成唯一 tag
- `to` 直接使用传入 tag
- `routeName` 必须使用新的 `Routes.ZHENXIE_*`
- `binding` 必须传同一个 `tagText`
- 详情页默认只保留标准 `to<T>({dynamic arguments, required String tag})`
- 只有当“详情页本身需要被管理台首页或公共管理入口直接打开”时，才额外补 `toManage`

2. 根布局要求
- 页面根节点保持 `ManageScaffold`
- 页面顶部补：
  `BreadcrumbWidget(isCompatibleManage: controller.isManagement)`
- 用户端打开时显示普通面包屑
- 管理端打开时自动隐藏用户端面包屑，避免重复

3. Controller 要求
- `class XxxController extends GetxController with DualBreadcrumbMixin`
- 不再使用 `ManageBreadcrumbMixin`
- 字段统一改成：

```dart
final String tagText;
bool isManagement = false;
```

- 构造方法：

```dart
XxxController({required this.tagText});
```

- `onInit` 统一先：

```dart
super.onInit();
initBreadcrumb(tagText);
if (Get.arguments != null) {
  isManagement = Get.arguments['isManagement'] ?? false;
}
```

- 然后再继续读取本页面自己的业务参数，例如 `nid`、`supportsPyramid`

4. Binding 要求
- `final String tagText;`
- `XxxBinding({required this.tagText});`
- `Get.lazyPut(() => XxxController(tagText: tagText), tag: tagText);`

六、参数透传要求
迁移后的页面既能从用户端打开，也能从管理端打开，所以所有内部跳转必须继续透传 `isManagement`。

示例：

```dart
TagRoutes.toNamed(
  Routes.ZHENXIE_XXX_DETAILS,
  arguments: {
    "nid": data.nid,
    "isManagement": isManagement,
  },
);
```

必须逐项检查：
1. 列表 -> 详情
2. 详情 -> 下一级详情
3. 详情内联卡片 -> 关联页面
4. 管理台入口 -> 列表页

不要只改第一跳；第二跳、第三跳同样要透传。

七、管理台入口改造要求
管理台入口仍然保留在：
- `lib/app/modules/management/manage_content/manage_zhenxie_console/controllers/manage_zhenxie_console_controller.dart`

但入口目标要改成新的 zhenxie 路由，并补管理端参数：

示例目标：
- `Routes.ZHENXIE_PATTERN_BLUEPRINT`
- `Routes.ZHENXIE_SENTENCE_PATTERN_COMPARE`
- `Routes.ZHENXIE_SENTENCE_PAIR`
- `Routes.ZHENXIE_GRAMMAR_PANORAMA`

同时这些入口都要补：

```dart
params: {"isManagement": true}
```

其中像“生长金字塔”这种已有业务参数的入口，改成：

```dart
params: {
  "supportsPyramid": true,
  "isManagement": true,
}
```

八、页面内跳转方式要求
迁移后的 zhenxie 页面统一遵循：

1. 用户端页面内部优先使用 `TagRoutes.toNamed(...)`
2. 管理端外部入口仍通过 `ManagePageRegistry.jumpTo(...)`
3. 管理端外部入口如果进入的是列表页/入口页，则 `ManagePageRegistry` 注册的是 `XxxView.toManage`
4. 详情页默认不注册 `ManagePageRegistry`
5. 页面内部不要继续直接写旧的 `ManagePageRegistry.jumpTo(Routes.MANAGE_...)`
6. 页面内部跳转都应切到新的 `Routes.ZHENXIE_*`

这里的执行标准必须和下面这两个参考点对齐：
- 反例：`manage_grammar_panorama_controller.dart` 中 `await ManagePageRegistry.jumpTo(...)`
- 正例：`zhenxie_enter_sentence_controller.dart` 中 `TagRoutes.toNamed(...)`

也就是说：
- 页面内部从列表跳详情、详情跳详情、详情跳关联页，都统一使用 `TagRoutes.toNamed(...)`
- `ManagePageRegistry.jumpTo(...)` 只用于管理台外部入口首次进入页面，不用于页面内部二跳、三跳

九、导入路径与 Barrel 文件要求
目录迁移和文件重命名后，必须同步处理：

1. 所有相对 import 路径
2. `app_pages.dart` 顶部 import
3. `tag_routes.dart` 顶部 import
4. `manage_page_registry.dart` 顶部 import
5. 如有模块内 `views/` 引用局部 widget 文件，也要改成新文件名
6. `lib/common/widgets/widgets.dart` 的 export

十、推荐迁移顺序
建议严格按下面顺序做，避免大面积报错时难以定位：

1. 先迁移公共弹窗 `edit_name_desc_dialog.dart`
2. 再迁移一组最小页面链路做模板：
   - `manage_grammar_panorama`
   - `manage_grammar_panorama_details`
3. 跑静态检查，确认迁移模式成立
4. 再迁移：
   - `manage_pattern_blueprint`
   - `manage_pattern_blueprint_details`
5. 再迁移：
   - `manage_sentence_pair`
   - `manage_sentence_pair_details`
   - `manage_sentence_pair_fork_details`
6. 最后迁移：
   - `manage_sentence_pattern_compare`
   - `manage_sentence_pattern_compare_details`
7. 统一补齐路由、注册表、入口和引用清理

十一、输出要求
你需要直接改代码，不要只给方案。完成后必须交付：

1. 改动文件清单
2. 新旧目录映射清单
3. 新旧路由映射清单
4. 已补齐 `isManagement` 的入口和透传点清单
5. 已迁移到 `common/widgets` 的公共弹窗说明
6. 静态校验结果

十二、自检清单
改完后逐项确认：

- [ ] 9 组页面目录都已迁移到 `lib/app/modules/zhenxie/zhenxie_*`
- [ ] 迁移范围内文件名已改成 `zhenxie_*.dart`
- [ ] 迁移范围内类名已改成 `Zhenxie*`
- [ ] Controller 已从 `ManageBreadcrumbMixin` 改为 `DualBreadcrumbMixin`
- [ ] Controller 已补 `tagText` 和 `isManagement`
- [ ] View 已补 `toManage` 与标准 `to`
- [ ] 页面顶部已补 `BreadcrumbWidget(isCompatibleManage: controller.isManagement)`
- [ ] 页面内部跳转都改成新 `Routes.ZHENXIE_*`
- [ ] 管理台入口都已补 `{"isManagement": true}`
- [ ] 列表页/入口页已按需注册 `ManagePageRegistry -> XxxView.toManage`
- [ ] 详情页未机械补 `toManage` 和 `ManagePageRegistry` 注册
- [ ] `edit_name_desc_dialog.dart` 已迁到 `common/widgets`
- [ ] `common/widgets/widgets.dart` 已补 export
- [ ] 全局已无旧文件名、旧类名残留引用
- [ ] 编译和静态分析通过

十三、额外提醒
1. 迁移过程中，如果某些旧 `Routes.MANAGE_*` 仍被非本次范围代码引用，不要直接粗暴删除；先完成新路由切换，再基于全局搜索决定是否清理
2. 详情页里如果调用了局部编辑弹窗，优先只做“同目录迁移 + 去 manage 前缀”，不要顺手改业务逻辑
3. 现有 Entity 类型名例如 `ManageGrammarPanoramaEntity` 是否要去掉 `Manage` 前缀，不属于本次默认任务；除非编译或语义要求，否则不要扩大改动面
4. 本次迁移命名必须强制对齐 `zhenxie_enter_sentence`：目录名、文件名、类名都要体现 `zhenxie` 前缀，不接受裸模块名
