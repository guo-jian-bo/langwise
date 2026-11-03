你是一个资深 Flutter(GetX) 工程师。请把指定页面改造成「可多实例 / 基于 tag 的路由跳转」形式，参考 ElementsWordDetilsView 的实现。目标：同一个路由可以同时打开多次，每个实例都有独立的 Controller/Binding，并能正确记录面包屑。

约束：
- 只做必要改动，保持现有代码风格、命名、导入顺序、格式化风格
- 不引入新依赖
- View / Binding / Controller 三件套必须通过同一个 tagText 绑定在一起
- TagRoutes 注册表里的 to 方法签名必须一致：Future<T?> to<T>({dynamic arguments, required String tag})

一、需要改造的文件清单（按优先级）
1) View：lib/app/modules/<module>/<page>/views/<page>_view.dart
2) Controller：lib/app/modules/<module>/<page>/controllers/<page>_controller.dart
3) Binding：lib/app/modules/<module>/<page>/bindings/<page>_binding.dart
4) 路由常量：lib/app/routes/app_routes.dart（必要时还要补 _Paths）
5) 页面注册：lib/app/routes/tag_routes.dart
6) 跳转调用方：把 Get.to / Get.toNamed 改为 TagRoutes.toNamed

二、View 改造（必须）
把 View 改成带 tagText 的多实例形式：
1) 添加字段与构造参数：
   - final String tagText;
   - const XxxView({super.key, required this.tagText});
2) 如果 View 是 GetView<Controller>，必须覆写 tag：
   - @override
     String? get tag => tagText;
3) 在 View 内新增静态跳转方法（给 TagRoutes 注册用）：

   static Future<T?> to<T>({dynamic arguments, required String tag}) async {
     return await Get.to<T>(
       XxxView(tagText: tag),
       binding: XxxBinding(tagText: tag),
       routeName: Routes.XXX, // 确保是该页面对应的 Routes 常量
       arguments: arguments,
       preventDuplicates: false,
     );
   }

注意点：
- routeName 必须设置为 Routes.XXX（便于路由观察、面包屑、统计）
- tag 参数直接透传给 tagText；不要自己再生成 tag（TagRoutes 会生成）
- 如果页面不是 GetView，而是用 GetBuilder/GetX/Obx 包裹 Controller：任何 Get.find/GetBuilder 都必须带 tag: tagText（或统一改成 GetView + tag getter）

三、Controller 改造（必须）
Controller 增加 tagText 并初始化面包屑（参考 ElementsWordDetilsController）：
1) Controller 声明增加 mixin：
   class XxxController extends GetxController with RoutesBreadcrumbMixin
2) 添加 tagText 字段与构造方法参数：
   final String tagText;
   XxxController({required this.tagText});
3) 实现面包屑字段（按页面实际文案修改）：
   @override
   String get breadcrumbRoute => Routes.XXX;

   @override
   String get breadcrumbTitle => "页面标题";
4) onInit 内调用 initBreadcrumb(tagText)（尽量在 super.onInit() 后立即调用）：
   @override
   void onInit() {
     super.onInit();
     initBreadcrumb(tagText);
     ...
   }

注意点：
- 如果 Controller 里注册过 worker（ever/interval/debounce 等），确保 onClose 里 dispose（项目规范要求）
- 从 Get.arguments 取参保持不变即可；本改造只影响“实例隔离”

四、Binding 改造（必须）
Binding 负责把“同一个 tagText”注入给 Controller，并用 tag 隔离实例：
1) 增加字段与构造参数：
   final String tagText;
   XxxBinding({required this.tagText});
2) dependencies 里按 tag 注入：

   @override
   void dependencies() {
     Get.lazyPut<XxxController>(
       () => XxxController(tagText: tagText),
       tag: tagText,
     );
   }

注意点：
- tag 必须与 View.tagText 完全一致
- fenix 是否保留按项目现状（示例里为 true）

五、Routes 常量（必须）
在 lib/app/routes/app_routes.dart 确保存在路由常量：
   static const XXX = _Paths.XXX;

如果 _Paths 里没有对应 path，需要同步补齐（通常在 app_routes_code.dart 里定义，按项目现状为准）。

六、TagRoutes 注册（必须）
在 lib/app/routes/tag_routes.dart 做两件事：
1) import 新页面的 View：
   import '../modules/.../views/xxx_view.dart';
2) 注册到 _pages：
   static final Map<String, Future<dynamic> Function({dynamic arguments, required String tag})> _pages = {
     ...
     Routes.XXX: XxxView.to,
   };

注意点：
- 注册的 value 必须是 View.to（签名必须匹配）
- 不要把 binding/controller 注册逻辑写进 TagRoutes，保持“页面自包含”

七、跳转方式（必须）
把调用方从 Get.to(...) / Get.toNamed(...) 改为：

await TagRoutes.toNamed(
  Routes.XXX,
  arguments: {
    ...
  },
);

说明：
- TagRoutes 会自动生成唯一 tag（route + 时间戳），支持同一路由多开
- arguments 原样透传到 Get.arguments

补充约束（必须遵守）：
- 页面跳转必须优先使用 TagRoutes 类中提供的方法（例如 toNamed / offAndToNamed / offNamedUntil / offAllNamed）
- 如果业务代码里需要某种跳转语义，但 TagRoutes 里没有对应方法：先在 tag_routes.dart 里补齐该跳转方法，再在调用方统一使用（不要在业务代码里直接调用 Get.to/Get.off/Get.offAll 等）
- 如果在“页面外部/弹窗”等场景需要获取 Controller：
  - 提交行为（如 submit/create/update/delete）：只使用 TagRoutes.findLast<Controller>(Routes.XXX) 获取堆栈中最新实例并执行
  - 在本页面外部 刷新/广播行为（如重新拉取数据、批量更新 UI）：使用 TagRoutes.findLast<Controller>(Routes.XXX) 遍历当前堆栈中的所有实例并执行

八、额外补充（推荐检查项）
1) 页面内找 Controller 的方式要统一：
   - 推荐：View extends GetView<XxxController> + override tag => tagText
   - 不推荐：无 tag 的 Get.find / GetBuilder（会串实例）
2) 如果页面里有子组件需要 Controller：
   - 直接从父组件传 controller
   - 或者在子组件里 Get.find<XxxController>(tag: tagText)
3) 如果页面希望“打开同一个业务对象时复用已打开页面”：
   - 当前 TagRoutes.toNamed 总是生成新 tag（永远新实例）
   - 需要复用时，改造调用方：自定义 tag（例如 '${Routes.XXX}_$id'）并直接调用 XxxView.to(arguments: ..., tag: 自定义tag)
4) 确保 routeName 与 Routes 常量一致（便于 RouteObserver/埋点/面包屑）
5) 如果外部需要 find 控制器：不要直接 Get.find（页面堆栈可能存在多个实例）
   - 用 TagRoutes.finds<YourController>(Routes.XXX) 获取当前堆栈中该 route 的所有实例（返回 List）
   - 需要“当前路由实例”时：优先用 TagRoutes.getCurrentRoute() 拿到当前 tag，再 Get.find(tag: tag)
6) 如果改造后 app_pages.dart（GetPage 注册处）因为 View/Binding 构造新增 required tagText 而报错：
   - 这里是“静态路由表”占位用，tagText 直接传空字符串即可：tagText: ''
   - Binding 同理：XxxBinding(tagText: '')

九、输出要求（你需要交付的结果）
- 直接修改上述文件，保证编译通过
- 不要引入新文件（除非该页面缺少 Binding/Controller/Routes 常量必须补齐）
- 修改完成后，给出你改动过的文件列表
- 修改完成后，在 lib/app/routes/tag_routes_migration_checklist.md 把对应 Routes.XXX 行改为 - [x] Routes.XXX
