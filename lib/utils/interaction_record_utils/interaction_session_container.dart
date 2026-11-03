import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../app/routes/app_pages.dart';
import 'interaction_record_constants.dart';
import 'interaction_session_manager.dart';

/// 页面根部交互监听容器
class InteractionSessionContainer extends StatefulWidget {
  /// 子组件
  final Widget child;

  /// 来源标识
  final String source;

  /// 是否启用监听
  final bool enabled;

  /// 创建页面根部交互监听容器
  const InteractionSessionContainer({
    super.key,
    required this.child,
    required this.source,
    this.enabled = true,
  });

  @override
  State<InteractionSessionContainer> createState() {
    return _InteractionSessionContainerState();
  }
}

/// 页面根部交互监听容器状态
class _InteractionSessionContainerState extends State<InteractionSessionContainer>
    with WidgetsBindingObserver, RouteAware {
  /// 当前页面路由实例
  ModalRoute<dynamic>? _route;

  /// 当前是否为桌面端平台
  bool get _isDesktopPlatform {
    return !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final ModalRoute<dynamic>? route = ModalRoute.of(context);
    if (_route == route) return;

    if (_route is PageRoute<dynamic>) {
      AppPages.observer.unsubscribe(this);
    }

    _route = route;
    if (route is PageRoute<dynamic>) {
      AppPages.observer.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_route is PageRoute<dynamic>) {
      AppPages.observer.unsubscribe(this);
    }
    super.dispose();
  }

  @override
  void didPushNext() {
    if (!widget.enabled) return;
    InteractionSessionManager.instance.notifyRouteCovered();
  }

  @override
  void didPopNext() {
    if (!widget.enabled) return;
    InteractionSessionManager.instance.notifyAppForeground();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.enabled) return;

    if (state == AppLifecycleState.resumed) {
      InteractionSessionManager.instance.notifyAppForeground();
      return;
    }

    if (_isDesktopPlatform &&
        (state == AppLifecycleState.inactive ||
            state == AppLifecycleState.hidden)) {
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      InteractionSessionManager.instance.notifyAppBackground();
    }
  }

  /// 处理指针按下
  void _handlePointerDown(PointerDownEvent event) {
    if (!widget.enabled) return;
    InteractionSessionManager.instance.notifyUserInteraction(
      InteractionSignal.touch,
    );
  }

  /// 处理滚轮等指针信号
  void _handlePointerSignal(PointerSignalEvent event) {
    if (!widget.enabled) return;
    if (event is! PointerScrollEvent) return;
    InteractionSessionManager.instance.notifyUserInteraction(
      InteractionSignal.scroll,
    );
  }

  /// 处理点击
  void _handleTap() {
    if (!widget.enabled) return;
    InteractionSessionManager.instance.notifyUserInteraction(
      InteractionSignal.tap,
    );
  }

  /// 处理双击
  void _handleDoubleTap() {
    if (!widget.enabled) return;
    InteractionSessionManager.instance.notifyUserInteraction(
      InteractionSignal.doubleTap,
    );
  }

  /// 处理长按
  void _handleLongPress() {
    if (!widget.enabled) return;
    InteractionSessionManager.instance.notifyUserInteraction(
      InteractionSignal.longPress,
    );
  }

  /// 处理拖动
  void _handlePanUpdate(DragUpdateDetails details) {
    if (!widget.enabled) return;
    InteractionSessionManager.instance.notifyUserInteraction(
      InteractionSignal.drag,
    );
  }

  /// 处理滚动通知
  bool _handleScrollNotification(ScrollNotification notification) {
    if (!widget.enabled) return false;
    InteractionSessionManager.instance.notifyUserInteraction(
      InteractionSignal.scroll,
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: _handlePointerDown,
        onPointerSignal: _handlePointerSignal,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _handleTap,
          onDoubleTap: _handleDoubleTap,
          onLongPress: _handleLongPress,
          onPanUpdate: _handlePanUpdate,
          child: widget.child,
        ),
      ),
    );
  }
}
