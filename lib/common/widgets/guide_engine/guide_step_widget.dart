import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/app_pages.dart';

import '../widgets.dart';
import 'guide_registry_manage.dart';
import 'guide_task_controller.dart';

/// 引导目标组件
///
/// 这个组件是新引导体系里的“目标声明层”。
///
/// 它只做三件事：
///
/// 1. 声明当前 `child` 对应哪个引导目标 `id`
/// 2. 在挂载时向全局 [GuideTaskController] 注册自己
/// 3. 在销毁时从全局 [GuideTaskController] 注销自己
///
/// 它不会做以下事情：
///
/// 1. 不负责拉取引导步骤
/// 2. 不负责决定当前展示哪个步骤
/// 3. 不负责步骤完成后的上报
/// 4. 不直接操作 `tutorial_coach_mark`
///
/// 换句话说，这个组件的职责非常单一：
/// 只负责把“当前这个 widget 可被引导”这件事声明出来。
class GuideStepWidget extends StatefulWidget {
  /// 当前目标组件的业务唯一 id。
  ///
  /// 这个值必须能与服务端返回的 `nodes.id` 对上，
  /// 也应该尽量使用 `GuideWidgetIds` 中定义的常量。
  final String id;

  /// 真实的业务组件。
  ///
  /// `GuideStepWidget` 本身不改变业务组件逻辑，
  /// 只是给它包上一层稳定的 `GlobalKey`。
  final Widget child;

  /// 点击“高亮目标区域”时的回调。
  ///
  /// 这个回调本身不会无条件执行，而是由当前步骤节点中的
  /// `targetTapAction` 决定是否触发。
  ///
  /// 使用场景：
  ///
  /// 1. 高亮目标被点击时，需要执行一段业务逻辑
  /// 2. 业务逻辑执行完成后，再决定是否推进下一步
  ///
  /// 常见写法是：
  ///
  /// ```dart
  /// onGuideTargetTap: () async {
  ///   await doSomething();
  ///   await GuideTaskController.to.completeGuide(pageCode, widgetId);
  /// }
  /// ```
  ///
  /// 推荐搭配：
  ///
  /// - 当节点配置 `targetTapAction = executeTargetLogic` 时，传入该回调
  /// - 当节点配置 `targetTapAction = nextStep` 时，可以不传
  final GuideTargetTapHandler? onTap;

  final double sclae;

  /// 是否禁用key
  final bool disableKey;

  /// 滚动对齐参数。
  final double? ensureVisibleAlignment;

  /// 创建一个引导目标组件。
  const GuideStepWidget({
    super.key,
    required this.id,
    required this.child,
    this.onTap,
    this.sclae = 1,
    this.disableKey = false,
    this.ensureVisibleAlignment,
  });

  @override
  State<GuideStepWidget> createState() => _GuideStepWidgetState();
}

class _GuideStepWidgetState extends State<GuideStepWidget> with RouteAware {
  /// 当前目标绑定的稳定 `GlobalKey`。
  ///
  /// 该 key 由全局 `GuideTaskController` 统一分配和管理。
  GlobalKey? _targetKey;

  /// 当前组件已连接到的全局引导控制器。
  ///
  /// 这里缓存一份引用，方便在 `dispose` 时反注册。
  GuideTaskController? _controller;

  /// 当前目标是否已经完成注册。
  ///
  /// 这个标记用于防止重复调用注册方法。
  bool _isRegistered = false;

  /// 当前组件所属的路由实例。
  ModalRoute<dynamic>? _route;

  /// 当前组件是否已订阅路由生命周期。
  bool _isRouteObserverSubscribed = false;

  /// 当前组件所在页面是否处于前台激活状态。
  bool _isRouteActive = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncRouteSubscription();
    _syncRouteActiveState();
  }

  @override
  void didUpdateWidget(covariant GuideStepWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.disableKey != widget.disableKey) {
      if (widget.disableKey) {
        _unregisterTarget(oldWidget.id);
      } else {
        _registerIfNeeded();
      }
    }

    if ((oldWidget.onTap != widget.onTap || oldWidget.ensureVisibleAlignment != widget.ensureVisibleAlignment) && _isRegistered) {
      _controller?.updateTargetTapHandler(
        widget.id,
        onTargetTap: widget.onTap,
        ensureVisibleAlignment: widget.ensureVisibleAlignment,
      );
    }

    // 如果业务侧把同一个组件实例的引导 id 改掉了，
    // 需要先注销旧 id，再重新按新 id 注册。
    if (oldWidget.id == widget.id) return;

    _unregisterTarget(oldWidget.id);
    _registerIfNeeded();
  }

  @override
  void dispose() {
    _unsubscribeRouteObserver();
    _unregisterTarget(widget.id);
    super.dispose();
  }

  /// 按需注册当前目标。
  ///
  /// 该方法会在以下场景中被调用：
  ///
  /// 1. `initState` 首次挂载时
  /// 2. `id` 发生变化时
  /// 3. 首次 build 时作为兜底检查
  ///
  /// 这样做的目的，是尽量保证：
  ///
  /// - 当全局控制器已就绪时，目标能自动注册
  /// - 当全局控制器暂未初始化时，组件也能安全降级显示
  void _registerIfNeeded() {
    if (widget.disableKey) return;
    if (!_isRouteActive) return;
    if (_isRegistered) return;

    final GuideTaskController? controller = _findController();
    if (controller == null) return;

    _controller = controller;
    _targetKey = controller.registerTarget(
      widget.id,
      onTargetTap: widget.onTap,
      ensureVisibleAlignment: widget.ensureVisibleAlignment,
    );
    _isRegistered = true;
  }

  /// 注销当前目标。
  ///
  /// 正常情况下会在 `dispose` 中调用；
  /// 如果 `id` 发生变化，也会先注销旧值。
  void _unregisterTarget(String id) {
    if (!_isRegistered) return;

    _controller?.unregisterTarget(id);
    _controller = null;
    _targetKey = null;
    _isRegistered = false;
  }

  /// 同步当前组件和所属路由的订阅关系。
  void _syncRouteSubscription() {
    final ModalRoute<dynamic>? route = ModalRoute.of(context);
    if (identical(_route, route)) return;

    _unsubscribeRouteObserver();
    _route = route;

    if (route == null) return;
    AppPages.observer.subscribe(this, route);
    _isRouteObserverSubscribed = true;
  }

  /// 依据当前路由是否为栈顶页面，决定目标是否持有引导 key。
  void _syncRouteActiveState() {
    final bool isCurrentRoute = _route?.isCurrent ?? false;
    if (isCurrentRoute) {
      _activateRoute();
      return;
    }
    _deactivateRoute();
  }

  /// 当前页面恢复到前台，重新持有引导 key。
  void _activateRoute() {
    final bool wasActive = _isRouteActive;
    _isRouteActive = true;
    _registerIfNeeded();
    if (!wasActive && mounted) {
      setState(() {});
    }
  }

  /// 当前页面失去前台焦点，立即释放引导 key。
  void _deactivateRoute() {
    final bool wasActive = _isRouteActive;
    _isRouteActive = false;
    _unregisterTarget(widget.id);
    if (wasActive && mounted) {
      setState(() {});
    }
  }

  /// 取消路由生命周期订阅。
  void _unsubscribeRouteObserver() {
    if (!_isRouteObserverSubscribed) return;
    AppPages.observer.unsubscribe(this);
    _isRouteObserverSubscribed = false;
  }

  /// 查找全局引导控制器。
  ///
  /// 如果当前应用尚未注册 `GuideTaskController`，
  /// 这里不会抛错，而是返回 `null` 并让组件安全降级。
  GuideTaskController? _findController() {
    if (!Get.isRegistered<GuideTaskController>()) {
      assert(() {
        debugPrint(
          '[GuideStepWidget] GuideTaskController has not been registered, '
          'guide target "${widget.id}" falls back to plain child widget.',
        );
        return true;
      }());
      return null;
    }

    return GuideTaskController.to;
  }

  @override
  void didPush() {
    _activateRoute();
  }

  @override
  void didPopNext() {
    _activateRoute();
  }

  @override
  void didPushNext() {
    _deactivateRoute();
  }

  @override
  void didPop() {
    _deactivateRoute();
  }

  @override
  Widget build(BuildContext context) {
    // 这里再做一次兜底注册，避免某些初始化顺序下首帧没有拿到控制器。
    _registerIfNeeded();

    final Widget content = Semantics(
      identifier: widget.id,
      child: TapScaleWidget(
        onTap: widget.onTap,
        sclae: widget.sclae,
        child: widget.child,
      ),
    );

    // 保持真实业务 child 的包裹结构稳定，只让引导锚点单独切换 key。
    // 这样在弹出 Dialog 等 route 切换场景下，不会因为 key 的增删导致 child 被重新挂载。
    return Theme(
      data: Theme.of(context).copyWith(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          content,
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: KeyedSubtree(
                key: _targetKey,
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
