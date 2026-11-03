你是一个资深 Flutter(GetX) 工程师。请把“用户端页面”改造成“同时兼容管理端打开”的形式，严格参考下面这套现有实现，不要自行发明另一套接入方式：

- [zhenxie_enter_sentence_details_controller.dart:L9](file:///Users/langwise/Desktop/ns/project/langwise/lib/app/modules/zhenxie/zhenxie_enter_sentence_details/controllers/zhenxie_enter_sentence_details_controller.dart#L9)
- [zhenxie_enter_sentence_details_controller.dart:L23](file:///Users/langwise/Desktop/ns/project/langwise/lib/app/modules/zhenxie/zhenxie_enter_sentence_details/controllers/zhenxie_enter_sentence_details_controller.dart#L23)
- [zhenxie_enter_sentence_details_controller.dart:L42](file:///Users/langwise/Desktop/ns/project/langwise/lib/app/modules/zhenxie/zhenxie_enter_sentence_details/controllers/zhenxie_enter_sentence_details_controller.dart#L42)
- [zhenxie_enter_sentence_view.dart:L44](file:///Users/langwise/Desktop/ns/project/langwise/lib/app/modules/zhenxie/zhenxie_enter_sentence/views/zhenxie_enter_sentence_view.dart#L44)
- [zhenxie_enter_sentence_view.dart:L51](file:///Users/langwise/Desktop/ns/project/langwise/lib/app/modules/zhenxie/zhenxie_enter_sentence/views/zhenxie_enter_sentence_view.dart#L51)
- [zhenxie_enter_sentence_view.dart:L20-L30](file:///Users/langwise/Desktop/ns/project/langwise/lib/app/modules/zhenxie/zhenxie_enter_sentence/views/zhenxie_enter_sentence_view.dart#L20-L30)
- [manage_page_registry.dart:L346](file:///Users/langwise/Desktop/ns/project/langwise/lib/app/modules/management/utils/manage_page_registry.dart#L346)

目标：
- 保留用户端原有打开方式
- 额外支持管理端通过 `ManagePageRegistry` 打开
- 页面在管理端打开时，UI 容器、面包屑、子页面跳转链路都要兼容
- 改动保持外科手术式，只改当前需求需要的内容

硬性约束：
- 不要改页面原有业务逻辑和视觉样式，除非兼容管理端必须调整
- 不要删除现有用户端跳转能力
- 不要引入新依赖
- 所有新增字段、方法、关键分支都要补简短注释，注释说明“它为什么存在”
- 保持项目现有排版风格；能单行看清的代码不要强行折行；禁止嵌套三元表达式

一、Controller 改造要求
页面 Controller 必须沿用当前项目的“双端面包屑”模式，不要改成别的 mixin 方案：

1. Controller 继承形式保持为：
   `class XxxController extends GetxController with DualBreadcrumbMixin`

2. 必须具备以下字段：
   - `final String tagText;`
   - `bool isManagement = false;`

3. 构造方法必须接收 `tagText`：
   `XxxController({required this.tagText});`

4. `onInit` 内的初始化顺序参考现有实现：
   - 先 `super.onInit();`
   - 再 `initBreadcrumb(tagText);`
   - 再从 `Get.arguments` 读取管理端标记：
     `isManagement = Get.arguments['isManagement'] ?? false;`
   - 最后再执行页面自己的初始化逻辑

5. 页面如果已经有详情跳转、子页面跳转、弹窗跳转，凡是需要继续进入“兼容管理端页面”的地方，都必须把：
   `isManagement: controller.isManagement`
   原样继续往下透传，避免只在第一页兼容、后续链路丢失管理端状态

二、View 改造要求
View 必须兼容“用户端单独打开”和“管理端容器内打开”两种场景：

1. 页面根节点优先使用 `ManageScaffold`
   参考：
   [zhenxie_enter_sentence_view.dart:L44](file:///Users/langwise/Desktop/ns/project/langwise/lib/app/modules/zhenxie/zhenxie_enter_sentence/views/zhenxie_enter_sentence_view.dart#L44)

2. 顶部面包屑必须使用：
   `BreadcrumbWidget(isCompatibleManage: controller.isManagement)`
   参考：
   [zhenxie_enter_sentence_view.dart:L51](file:///Users/langwise/Desktop/ns/project/langwise/lib/app/modules/zhenxie/zhenxie_enter_sentence/views/zhenxie_enter_sentence_view.dart#L51)

3. 这样做的原因是：
   - 用户端打开时，显示原有用户端面包屑
   - 管理端打开时，`BreadcrumbWidget` 会根据 `isCompatibleManage` 自动隐藏用户端面包屑，避免和管理端面包屑重复显示

4. 如果页面已经是 `GetView<Controller>` + `tagText` 多实例结构：
   - 保留现有 `to<T>({dynamic arguments, required String tag})`
   - 只额外补一个管理端入口 `toManage<T>({dynamic arguments})`

5. `toManage` 的实现方式必须参考现有页面：
   - 自己生成唯一 tag
   - `Get.to(...)`
   - `binding` 使用同一个 tagText
   - `routeName` 必须传对应的 `Routes.XXX`
   - `preventDuplicates: false`

   示例形式：

   ```dart
   static Future<T?> toManage<T>({dynamic arguments}) async {
     final tag = '${Routes.XXX}_${DateTime.now().millisecondsSinceEpoch}';
     return await Get.to<T>(
       XxxView(tagText: tag),
       binding: XxxBinding(tagText: tag),
       routeName: Routes.XXX,
       arguments: arguments,
       preventDuplicates: false,
     );
   }
   ```

6. 如果页面内部还有点击进入详情页的逻辑，除了业务参数外，必须补传：

   ```dart
   {
     ...原有参数,
     'isManagement': controller.isManagement,
   }
   ```

三、Binding 改造要求
Binding 负责保证多实例和管理端打开时的实例隔离：

1. 保持 `tagText` 构造参数
2. `Get.lazyPut` 时继续使用 `tag: tagText`
3. Controller 构造参数传同一个 `tagText`
4. 不要把管理端逻辑写进 Binding，Binding 只负责实例注入

四、ManagePageRegistry 接入要求
如果一个用户端页面需要被管理端打开，必须在：
[manage_page_registry.dart](file:///Users/langwise/Desktop/ns/project/langwise/lib/app/modules/management/utils/manage_page_registry.dart)
里注册：

```dart
Routes.XXX: XxxView.toManage,
```

要求：
- 注册的是 `toManage`，不是普通 `to`
- `route key` 必须是页面自己的 `Routes.XXX`
- 一个兼容管理端的页面，如果有列表页和详情页，通常两者都要分别注册

五、必须关注的透传点
这类页面兼容管理端时，最容易漏的是“第二跳以后丢失管理端状态”。因此必须逐项检查：

1. 列表页打开详情页时，是否透传 `isManagement`
2. 详情页再打开其他关联页时，是否继续透传 `isManagement`
3. 页面刷新、回退、面包屑更新时，是否仍然使用当前实例自己的 `tagText`
4. 页面在用户端打开时，`isManagement` 默认必须仍为 `false`
5. 页面在管理端打开时，是否真正走了 `ManagePageRegistry -> XxxView.toManage` 这条链路

六、建议执行顺序
1. 先给 View 补 `toManage`
2. 再确认 Controller 有 `isManagement` 并从 `Get.arguments` 读取
3. 再把根容器改为或确认已是 `ManageScaffold`
4. 再把面包屑改为 `BreadcrumbWidget(isCompatibleManage: controller.isManagement)`
5. 再补齐页面内部跳转参数透传
6. 最后在 `ManagePageRegistry` 注册 `Routes.XXX: XxxView.toManage`

七、自检清单
改完后请逐项确认：

- [ ] 用户端原入口还能正常打开页面
- [ ] 管理端入口能通过 `ManagePageRegistry` 正常打开页面
- [ ] 管理端打开时没有重复显示用户端面包屑
- [ ] 页面内部继续跳转到下一级时，管理端兼容状态没有丢失
- [ ] 多实例页面没有串 Controller
- [ ] `routeName`、`binding(tagText)`、`GetView.tag` 三者保持一致
- [ ] 没有引入无关重构、无关格式化、无关注释清理

八、输出要求
- 直接修改目标页面相关文件
- 不输出泛泛分析，直接给出实际代码改动
- 最终列出改动文件清单
- 说明管理端入口注册点和 `isManagement` 透传点分别改在了哪里
