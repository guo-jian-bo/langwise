import 'package:flutter/material.dart';

/// 点击高亮目标时的处理回调。
///
/// 该回调通常由 `GuideStepWidget` 传入，
/// 再由 `GuideTaskController` 在 `onClickTarget` 中统一调度执行。
typedef GuideTargetTapHandler = Future<void> Function();

/// 引导目标注册管理器
///
/// 这个类只负责一件事：维护引导目标的注册状态。
///
/// 具体来说，它会维护以下信息：
///
/// 1. 每个引导目标 `id` 对应的稳定 `GlobalKey`
/// 2. 当前目标是否已经注册
/// 3. 当前目标是否已经真实挂载到渲染树中
/// 4. 同一个 `id` 被重复注册时的引用计数
///
/// 这样设计的目的，是把“目标注册表”从“任务调度器”中拆出来：
///
/// - `GuideTaskController` 负责整个任务流和展示逻辑
/// - `GuideRegistryManage` 只负责 `id -> key` 和挂载状态管理
///
/// 该类不负责以下事情：
///
/// 1. 不负责拉取服务端步骤
/// 2. 不负责使用 `tutorial_coach_mark` 展示引导
/// 3. 不负责步骤完成上报
/// 4. 不负责步骤顺序推进
class GuideRegistryManage extends ChangeNotifier {
  /// 内部注册表。
  ///
  /// key 为业务侧定义的组件 id，
  /// value 为该目标对应的注册条目。
  final Map<String, _GuideRegistryEntry> _entries = <String, _GuideRegistryEntry>{};

  /// 当前所有已登记的引导目标 id 列表。
  ///
  /// 这里返回的是只读列表，避免外部直接修改内部状态。
  List<String> get registeredIds => List<String>.unmodifiable(_entries.keys);

  /// 判断某个引导目标是否已经注册。
  ///
  /// 注意：这里判断的是“是否登记过”，不代表该目标一定已经挂载到界面。
  bool contains(String id) {
    return _entries.containsKey(id);
  }

  /// 获取指定 id 对应的稳定 [GlobalKey]。
  ///
  /// 如果该 id 尚未创建过 key，则会自动创建一个新的稳定 key。
  /// 后续同一个 id 再次调用时，会始终拿到同一个 key。
  GlobalKey keyOf(String id) {
    return _entryOf(id).targetKey;
  }

  /// 注册引导组件。
  ///
  /// 这个方法通常会在 `GuidStepWidget.initState()` 中被调用。
  ///
  /// 注册行为包含两层含义：
  ///
  /// 1. 确保该 id 已经拥有一个稳定的 `GlobalKey`
  /// 2. 增加该 id 的引用计数
  ///
  /// 引用计数的意义在于兼容组件重建和重复挂载场景：
  ///
  /// - 同一目标在短时间内被重复创建时，不会错误删除 key
  /// - 多个相同 id 被错误接入时，也能在调试阶段发现
  ///
  /// 返回值为该目标对应的稳定 key，供外部直接绑定到目标组件上。
  GlobalKey register(
    String id, {
    GuideTargetTapHandler? onTargetTap,
    double? ensureVisibleAlignment,
  }) {
    final _GuideRegistryEntry entry = _entryOf(id);
    entry.onTargetTap = onTargetTap;
    entry.ensureVisibleAlignment = ensureVisibleAlignment;
    entry.registerCount += 1;

    if (entry.registerCount > 1) {
      _debugDuplicateId(id, entry.registerCount);
    }

    notifyListeners();
    return entry.targetKey;
  }

  /// 注销引导组件。
  ///
  /// 这个方法通常会在 `GuidStepWidget.dispose()` 中被调用。
  ///
  /// 为了兼容 widget 重建场景，这里采用引用计数策略：
  ///
  /// - 每次注册 `register()` 时计数 +1
  /// - 每次注销 `unregister()` 时计数 -1
  /// - 当计数归零后，才真正从注册表中移除
  ///
  /// 这样可以避免因为局部 rebuild 或短暂重建导致目标被过早移除。
  void unregister(String id) {
    final _GuideRegistryEntry? entry = _entries[id];
    if (entry == null) return;

    entry.registerCount -= 1;
    if (entry.registerCount <= 0) {
      _entries.remove(id);
    }

    notifyListeners();
  }

  /// 获取指定 id 对应的 key，但不会自动创建。
  ///
  /// 这个方法适合在“只想查询，不想创建”的场景中使用。
  GlobalKey? findKey(String id) {
    return _entries[id]?.targetKey;
  }

  /// 获取指定 id 对应的点击高亮目标回调。
  ///
  /// 当用户点击高亮区域时，控制器会优先调用该回调。
  GuideTargetTapHandler? findTargetTapHandler(String id) {
    return _entries[id]?.onTargetTap;
  }

  /// 获取指定 id 对应的滚动对齐参数。
  ///
  /// 当控制器准备调用 `Scrollable.ensureVisible` 时，
  /// 会优先读取这里的配置；若未配置，则由上层使用默认值。
  double? findEnsureVisibleAlignment(String id) {
    return _entries[id]?.ensureVisibleAlignment;
  }

  /// 更新指定 id 的点击高亮目标回调。
  ///
  /// 这个方法主要用于兼容 widget 更新场景：
  /// 同一个目标 id 不变，但业务回调发生了变化。
  void updateTargetTapHandler(
    String id,
    GuideTargetTapHandler? onTargetTap,
    double? ensureVisibleAlignment,
  ) {
    final _GuideRegistryEntry? entry = _entries[id];
    if (entry == null) return;
    entry.onTargetTap = onTargetTap;
    entry.ensureVisibleAlignment = ensureVisibleAlignment;
  }

  /// 判断指定 id 的目标组件当前是否已经挂载到渲染树中。
  ///
  /// 判断方式很简单：
  ///
  /// - 若 `GlobalKey.currentContext != null`，则说明目标已经挂载
  /// - 若为 `null`，则说明目标还未出现，或已经被销毁
  bool isMounted(String id) {
    final GlobalKey? key = findKey(id);
    return key?.currentContext != null;
  }

  /// 判断当前是否至少存在一个已挂载的引导目标。
  ///
  /// 这个方法通常可用于调度器快速判断“当前是否存在任何可展示的目标”。
  bool get hasMountedTarget {
    for (final _GuideRegistryEntry entry in _entries.values) {
      if (entry.targetKey.currentContext != null) {
        return true;
      }
    }
    return false;
  }

  /// 获取当前已挂载的 id 列表。
  ///
  /// 这个列表对调度器很有用，可以用来分析当前哪些目标已经可见。
  List<String> get mountedIds {
    final List<String> ids = <String>[];
    for (final MapEntry<String, _GuideRegistryEntry> item in _entries.entries) {
      if (item.value.targetKey.currentContext != null) {
        ids.add(item.key);
      }
    }
    return ids;
  }

  /// 清空所有注册信息。
  ///
  /// 这个方法通常用于：
  ///
  /// 1. 整体重置引导系统
  /// 2. 用户退出登录
  /// 3. 调试态下手动清空注册表
  void clear() {
    if (_entries.isEmpty) return;
    _entries.clear();
    notifyListeners();
  }

  /// 获取或创建指定 id 对应的内部注册条目。
  ///
  /// 这里会保证：
  ///
  /// 1. id 不能为空
  /// 2. 相同 id 永远返回同一个注册条目
  _GuideRegistryEntry _entryOf(String id) {
    assert(id.trim().isNotEmpty, 'Guide widget id can not be empty.');
    return _entries.putIfAbsent(
      id,
      () => _GuideRegistryEntry(
        id: id,
        targetKey: GlobalKey(debugLabel: id),
      ),
    );
  }

  /// 在调试模式下输出重复 id 的提示信息。
  ///
  /// 重复 id 往往意味着：
  ///
  /// 1. 业务误把两个不同组件写成同一个引导 id
  /// 2. 某个引导组件被重复挂载
  /// 3. 页面中存在未预期的重复实例
  void _debugDuplicateId(String id, int count) {
    assert(() {
      debugPrint(
        '[GuideRegistryManage] duplicated guide id detected: '
        '$id, registerCount=$count',
      );
      return true;
    }());
  }
}

/// 单个引导目标在注册表中的内部结构。
///
/// 这个类不对外暴露，只作为注册表的内部数据承载对象。
class _GuideRegistryEntry {
  /// 业务定义的引导目标 id。
  final String id;

  /// 当前目标对应的稳定 `GlobalKey`。
  ///
  /// 该 key 会被绑定到真实组件上，用于后续定位和高亮。
  final GlobalKey targetKey;

  /// 当前目标对应的“点击高亮区域”回调。
  ///
  /// 当用户点击引导高亮区域时，控制器会优先执行该回调。
  GuideTargetTapHandler? onTargetTap;

  /// 当前目标滚动到可视区域时的对齐位置。
  ///
  /// 该值会透传给 `Scrollable.ensureVisible.alignment`。
  double? ensureVisibleAlignment;

  /// 当前目标的注册引用计数。
  ///
  /// 通过引用计数来判断某个目标是否应该真正从注册表中移除。
  int registerCount = 0;

  _GuideRegistryEntry({
    required this.id,
    required this.targetKey,
  });
}
