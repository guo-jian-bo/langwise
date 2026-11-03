import 'package:flutter/cupertino.dart';

/// 本文件实现了可重排序动画列表和网格视图的基础抽象类
/// 它作为AnimatedReorderableListView和AnimatedReorderableGridView的共同父类
/// 提供了统一的属性和方法，减少代码重复，提高维护性
///
/// 主要功能：
/// 1. 提供统一的项目拖拽重排序功能
/// 2. 支持项目添加和移除的动画效果
/// 3. 允许通过nonDraggableItems和lockedItems限制特定项目的拖拽
/// 4. 支持水平和垂直滚动方向
/// 5. 提供自定义动画构建器

import 'package:flutter/foundation.dart';
import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:flutter/material.dart';

import '../model/cross_container_data.dart';

/// 项目构建器类型定义
/// 用于构建列表或网格中的每个项目
///
/// [context] - 构建上下文
/// [index] - 项目在列表中的索引
typedef ItemBuilder<W extends Widget, E> = Widget Function(BuildContext context, int index);

/// 数据获取器类型定义
/// 用于获取指定索引的实际数据模型，而不是 UI 组件
///
/// [index] - 项目在列表中的索引
/// 返回值 - 指定索引处的数据模型
typedef ItemDataGetter<T> = T Function(int index);

/// 动画部件构建器类型定义
/// 用于自定义项目添加或移除时的动画效果
///
/// [child] - 要应用动画的子部件
/// [animation] - 控制动画进度的动画对象
typedef AnimatedWidgetBuilder<W extends Widget, E> = Widget Function(Widget child, Animation<double> animation);

/// 相等性检查器类型定义
/// 用于比较两个项目是否相同
///
/// 返回true表示两个项目相同，false表示不同
typedef EqualityChecker<E> = bool Function(E, E);

/// 默认动画持续时间：300毫秒
const Duration kAnimationDuration = Duration(milliseconds: 300);

/// 默认拖拽开始延迟时间：500毫秒
const Duration kDefaultDragStartDelay = Duration(milliseconds: 500);

/// 可重排序动画列表基类
/// 这是一个抽象基类，为可重排序的动画列表和网格视图提供统一的基础结构
///
/// 泛型参数：
/// [W] - 列表项目的部件类型
/// [E] - 列表数据项的类型
abstract class ReorderableAnimatedListBase<W extends Widget, E extends Object> extends StatefulWidget {
  /// 项目构建器函数
  /// 用于构建列表中的每个项目
  final ItemBuilder<W, E>? itemBuilder;

  /// 当前列表中的项目数据
  /// 这些项目将在列表或网格中显示
  final List<E> items;

  /// 重新排序回调函数
  /// 当用户完成项目拖拽重排序时调用
  /// 参数为项目的旧索引和新索引
  final ReorderCallback? onReorder;

  /// 开始重排序回调函数
  /// 当用户开始拖拽项目时调用
  /// 参数为被拖拽项目的索引
  final void Function(int)? onReorderStart;

  /// 结束重排序回调函数
  /// 当用户放下拖拽的项目时调用
  /// 参数为项目放下位置的索引
  /// 与onReorder不同，即使项目放在原位置也会调用此函数
  final void Function(int)? onReorderEnd;

  /// 拖拽项目装饰器
  /// 允许应用程序在项目被拖拽时添加动画装饰
  /// 例如可以添加阴影、边框等效果
  final ReorderItemProxyDecorator? proxyDecorator;

  /// 进入过渡动画效果列表
  /// 当项目添加到列表时使用的动画效果
  /// 列表中的动画将按顺序运行
  /// 如果为null，则使用默认的淡入效果
  final List<AnimationEffect>? enterTransition;

  /// 退出过渡动画效果列表
  /// 当项目从列表中移除时使用的动画效果
  /// 列表中的动画将按顺序运行
  /// 如果为null，则使用默认的淡出效果
  final List<AnimationEffect>? exitTransition;

  /// 插入动画持续时间
  /// 控制项目添加到列表时动画的持续时间
  /// 如果设置，将覆盖enterTransition中各动画效果的持续时间
  final Duration? insertDuration;

  /// 移除动画持续时间
  /// 控制项目从列表中移除时动画的持续时间
  /// 如果设置，将覆盖exitTransition中各动画效果的持续时间
  final Duration? removeDuration;

  /// 滚动方向
  /// 控制列表或网格的滚动方向（水平或垂直）
  final Axis scrollDirection;

  /// 网格布局代理
  /// 控制网格中瓷砖的布局
  /// 仅在网格视图中使用，列表视图中忽略此属性
  final SliverGridDelegate? sliverGridDelegate;

  /// 自定义插入项目动画构建器
  /// 用于自定义项目添加时的动画效果
  /// 如果指定，将忽略enterTransition属性
  final AnimatedWidgetBuilder? insertItemBuilder;

  /// 自定义移除项目动画构建器
  /// 用于自定义项目移除时的动画效果
  /// 如果指定，将忽略exitTransition属性
  final AnimatedWidgetBuilder? removeItemBuilder;

  /// 是否构建默认拖拽手柄
  /// 控制是否为项目添加默认的拖拽手柄
  final bool? buildDefaultDragHandles;

  /// 项目相等性比较函数
  /// 用于确定两个项目是否被视为相同
  /// 这对于防止不必要的动画和正确处理项目更新非常重要
  /// 如果未指定，将使用默认的==运算符比较
  final bool Function(E a, E b)? isSameItem;

  /// 拖拽开始延迟时间
  /// 控制在开始拖拽操作前等待的时间
  /// 设置为Duration.zero可立即开始拖拽操作
  /// 默认为500毫秒
  final Duration? dragStartDelay;

  /// 不可拖拽的项目列表
  /// 这些项目不能被用户拖拽，但可以被其他项目拖拽影响而重新排序
  final List<E> nonDraggableItems;

  /// 锁定的项目列表
  /// 这些项目完全锁定，既不能被拖拽，也不能被重新排序
  final List<E> lockedItems;

  /// 容器的唯一标识符
  final dynamic containerId;

  /// 是否能接收来自其他容器的项目
  final bool canReceiveItem;

  /// 是否允许项目拖出当前容器
  /// 如果为true，则项目可以被拖出到其他容器
  /// 如果为false，当拖拽结束时，项目会回到原来的位置
  final bool canDragOutItem;

  /// 数据获取器回调
  /// 用于获取指定索引处的实际数据模型，而不是 UI 组件
  /// 在跨容器拖拽时用于传递实际数据
  final ItemDataGetter? itemDataGetter;

  final void Function(CrossContainerData containerData)? onDragUpdate;

  /// 拖拽结束回调
  /// 当拖拽位置结束时触发，提供当前的拖拽信息
  /// 主要用于让外部组件根据拖拽位置进行额外操作
  final bool Function(CrossContainerData containerData)? onDragEnd;

  /// 是否启用交换动画
  /// 控制更改项目顺序时是否启用交换动画
  /// 默认为true
  final bool enableSwap;

  const ReorderableAnimatedListBase(
      {Key? key,
      required this.items,
      this.itemBuilder,
      this.onReorder,
      this.onReorderEnd,
      this.onReorderStart,
      this.proxyDecorator,
      this.enterTransition,
      this.exitTransition,
      this.insertDuration,
      this.removeDuration,
      required this.scrollDirection,
      this.insertItemBuilder,
      this.removeItemBuilder,
      this.buildDefaultDragHandles,
      this.isSameItem,
      this.itemDataGetter,
      this.dragStartDelay,
      this.nonDraggableItems = const [],
      this.lockedItems = const [],
      this.containerId,
      this.canReceiveItem = false,
      this.canDragOutItem = false,
      this.onDragUpdate,
      this.onDragEnd,
      this.enableSwap = true,
      this.sliverGridDelegate})
      : assert(itemBuilder != null),
        super(key: key);
}

/// 可重排序动画列表基类状态
/// 负责管理可重排序动画列表的状态和行为
/// 实现了项目添加、移除和重排序的核心逻辑
///
/// 泛型参数：
/// [W] - 列表项目的部件类型
/// [B] - 具体的ReorderableAnimatedListBase子类类型
/// [E] - 列表数据项的类型
abstract class ReorderableAnimatedListBaseState<W extends Widget, B extends ReorderableAnimatedListBase<W, E>,
    E extends Object> extends State<B> with TickerProviderStateMixin {
  /// 旧的项目列表
  /// 用于跟踪列表变化，以便计算需要添加、移除或重排序的项目
  late List<E> oldList;

  /// 进入动画的持续时间，默认为300毫秒
  Duration _enterDuration = kAnimationDuration;

  /// 退出动画的持续时间，默认为300毫秒
  Duration _exitDuration = kAnimationDuration;

  /// 进入动画效果条目列表
  /// 存储所有应用于项目添加时的动画效果
  List<EffectEntry> _enterAnimations = [];

  /// 退出动画效果条目列表
  /// 存储所有应用于项目移除时的动画效果
  List<EffectEntry> _exitAnimations = [];

  /// 获取进入动画的持续时间
  Duration get enterDuration => _enterDuration;

  /// 获取退出动画的持续时间
  Duration get exitDuration => _exitDuration;

  /// 可重排序动画构建器的全局键
  /// 用于访问和控制内部的ReorderableAnimatedBuilder
  @protected
  GlobalKey<ReorderableAnimatedBuilderState> listKey = GlobalKey();

  /// 获取可重排序动画构建器的状态
  /// 提供对内部构建器的直接访问
  @nonVirtual
  @protected
  ReorderableAnimatedBuilderState get list => listKey.currentState!;

  /// 获取项目构建器函数
  /// 用于构建列表中的每个项目
  @nonVirtual
  @protected
  ItemBuilder<W, E> get itemBuilder {
    return widget.itemBuilder!;
  }

  /// 获取网格布局代理
  /// 控制网格中瓷砖的布局
  @nonVirtual
  @protected
  SliverGridDelegate? get sliverGridDelegate => widget.sliverGridDelegate;

  /// 获取重新排序回调函数
  /// 当用户完成项目拖拽重排序时调用
  @nonVirtual
  @protected
  ReorderCallback? get onReorder => widget.onReorder;

  /// 获取开始重排序回调函数
  /// 当用户开始拖拽项目时调用
  @nonVirtual
  @protected
  void Function(int)? get onReorderStart => widget.onReorderStart;

  /// 获取结束重排序回调函数
  /// 当用户放下拖拽的项目时调用
  @nonVirtual
  @protected
  void Function(int)? get onReorderEnd => widget.onReorderEnd;

  /// 获取拖拽项目装饰器
  /// 用于在项目被拖拽时添加动画装饰
  @nonVirtual
  @protected
  ReorderItemProxyDecorator? get proxyDecorator => widget.proxyDecorator;

  /// 获取插入动画持续时间
  /// 如果设置了widget.insertDuration，则使用该值，否则使用enterDuration
  @nonVirtual
  @protected
  Duration get insertDuration => widget.insertDuration ?? enterDuration;

  /// 获取移除动画持续时间
  /// 如果设置了widget.removeDuration，则使用该值，否则使用exitDuration
  @nonVirtual
  @protected
  Duration get removeDuration => widget.removeDuration ?? exitDuration;

  /// 获取滚动方向
  /// 控制列表或网格的滚动方向（水平或垂直）
  @protected
  @nonVirtual
  Axis get scrollDirection => widget.scrollDirection;

  /// 获取进入过渡动画效果列表
  /// 如果未设置，则返回空列表，后续会使用默认的淡入效果
  @nonVirtual
  @protected
  List<AnimationEffect> get enterTransition => widget.enterTransition ?? [];

  /// 获取退出过渡动画效果列表
  /// 如果未设置，则返回空列表，后续会使用默认的淡出效果
  @nonVirtual
  @protected
  List<AnimationEffect> get exitTransition => widget.exitTransition ?? [];

  /// 获取是否构建默认拖拽手柄
  /// 如果未设置，默认为false
  @nonVirtual
  @protected
  bool get buildDefaultDragHandles => widget.buildDefaultDragHandles ?? false;

  /// 获取项目相等性比较函数
  /// 用于确定两个项目是否被视为相同
  /// 如果未设置，则使用默认的==运算符比较
  @nonVirtual
  @protected
  bool Function(E a, E b) get isSameItem => widget.isSameItem ?? (a, b) => a == b;

  /// 获取拖拽开始延迟时间
  /// 控制在开始拖拽操作前等待的时间
  /// 如果未设置，默认为500毫秒
  @nonVirtual
  @protected
  Duration get dragStartDelay => widget.dragStartDelay ?? kDefaultDragStartDelay;

  /// 获取不可拖拽项目的索引列表
  /// 将nonDraggableItems中的项目转换为其在当前列表中的索引
  /// 使用isSameItem函数比较项目相等性
  @nonVirtual
  @protected
  List<int> get nonDraggableItems => widget.items
      .asMap()
      .entries
      .where((entry) {
        final found = widget.nonDraggableItems.where((e) => isSameItem(e, entry.value));
        return found.isNotEmpty;
      })
      .map((entry) => entry.key)
      .toList();

  /// 获取锁定项目的索引列表
  /// 将lockedItems中的项目转换为其在当前列表中的索引
  /// 使用isSameItem函数比较项目相等性
  @nonVirtual
  @protected
  List<int> get lockedIndices => widget.items
      .asMap()
      .entries
      .where((entry) {
        final items = widget.lockedItems.where((e) => isSameItem(e, entry.value));
        return items.isNotEmpty;
      })
      .map((entry) => entry.key)
      .toList();

  /// 初始化状态
  /// 在部件创建时调用，设置初始状态
  @override
  void initState() {
    super.initState();
    // 初始化旧列表，用于跟踪变化
    oldList = List.from(widget.items);

    // 添加进入和退出动画效果
    addEffects(enterTransition, _enterAnimations, enter: true);
    addEffects(exitTransition, _exitAnimations, enter: false);
  }

  /// 部件更新时调用
  /// 当部件的配置发生变化时调用，计算列表差异并应用动画
  @override
  void didUpdateWidget(covariant B oldWidget) {
    final newList = widget.items;
    // 检查进入动画效果是否变化
    if (!listEquals(oldWidget.enterTransition, enterTransition)) {
      _enterAnimations = [];
      addEffects(enterTransition, _enterAnimations, enter: true);
    }
    // 检查退出动画效果是否变化
    if (!listEquals(oldWidget.exitTransition, exitTransition)) {
      _exitAnimations = [];
      addEffects(exitTransition, _exitAnimations, enter: false);
    }
    // 计算列表差异并应用相应的动画
    calculateDiff(oldList, newList);
    // 更新旧列表为当前列表
    oldList = List.from(newList);
    super.didUpdateWidget(oldWidget);
  }

  /// 添加动画效果列表
  /// 将动画效果列表添加到指定的效果条目列表中
  ///
  /// [effects] - 要添加的动画效果列表
  /// [enteries] - 目标效果条目列表
  /// [enter] - 是否为进入动画，true表示进入动画，false表示退出动画
  void addEffects(List<AnimationEffect> effects, List<EffectEntry> enteries, {required bool enter}) {
    if (effects.isNotEmpty) {
      // 如果提供了效果列表，则添加每个效果
      for (AnimationEffect effect in effects) {
        addEffect(effect, enteries, enter: enter);
      }
    } else {
      // 如果没有提供效果，则使用默认的淡入效果
      addEffect(FadeIn(), enteries, enter: enter);
    }
  }

  /// 添加单个动画效果
  /// 将单个动画效果添加到指定的效果条目列表中，并计算总动画时间
  ///
  /// [effect] - 要添加的动画效果
  /// [enteries] - 目标效果条目列表
  /// [enter] - 是否为进入动画，true表示进入动画，false表示退出动画
  void addEffect(AnimationEffect effect, List<EffectEntry> enteries, {required bool enter}) {
    Duration zero = Duration.zero;
    // 计算动画效果的总时间（延迟 + 持续时间）
    final timeForAnimation = (effect.delay ?? zero) + (effect.duration ?? kAnimationDuration);
    if (enter) {
      // 如果是进入动画，更新进入动画的总时间（取最大值）
      _enterDuration = timeForAnimation > _enterDuration ? timeForAnimation : _enterDuration;
      assert(_enterDuration >= zero, "Duration can not be negative");
    } else {
      // 如果是退出动画，更新退出动画的总时间（取最大值）
      _exitDuration = timeForAnimation > _exitDuration ? timeForAnimation : _exitDuration;
      assert(_exitDuration >= zero, "Duration can not be negative");
    }

    // 创建效果条目，设置默认值
    EffectEntry entry = EffectEntry(
        animationEffect: effect,
        delay: effect.delay ?? zero,
        duration: effect.duration ?? kAnimationDuration,
        curve: effect.curve ?? Curves.linear);

    // 添加到效果条目列表
    enteries.add(entry);
  }

  /// 计算列表差异并应用相应的动画
  /// 比较旧列表和新列表，检测项目的交换、添加和移除
  ///
  /// [oldList] - 旧列表，上一次渲染的项目列表
  /// [newList] - 新列表，当前要渲染的项目列表
  ///
  /// 处理的情况包括：
  ///
  /// 1. 项目交换（元素位置互换）
  ///    例如：[A, B, C, D] -> [A, C, B, D]
  ///    处理流程：
  ///    - 检查列表长度相同且enableSwap为true
  ///    - 遇到索引1处的元素不同：B != C
  ///    - 在oldList中查找C的位置，找到索引2
  ///    - 检查newList[2] = B是否等于oldList[1] = B，确认是交换操作
  ///    - 将交换对[1, 2]添加到swappedPairs
  ///    - 调用moveItem(1, 2)应用移动动画
  ///    - 用户会看到B和C平滑地交换位置
  ///
  /// 2. 项目移除
  ///    例如：[A, B, C, D] -> [A, C, D]
  ///    处理流程：
  ///    - 列表长度不同，跳过交换检测
  ///    - 从后向前遍历oldList（从索引3到0）
  ///    - 对于oldList[3] = D，在newList中找到匹配项，继续
  ///    - 对于oldList[2] = C，在newList中找到匹配项，继续
  ///    - 对于oldList[1] = B，在newList中找不到匹配项
  ///    - 调用removeItem(1, removeItemDuration: removeDuration)应用移除动画
  ///    - 对于oldList[0] = A，在newList中找到匹配项，继续
  ///    - 用户会看到B以淡出或其他配置的退出动画效果消失
  ///
  /// 3. 项目添加
  ///    例如：[A, C, D] -> [A, B, C, D]
  ///    处理流程：
  ///    - 列表长度不同，跳过交换检测
  ///    - 完成移除检测（没有项目被移除）
  ///    - 遍历newList，对于每个元素检查它是否存在于oldList
  ///    - 对于newList[0] = A，在oldList中找到匹配项，继续
  ///    - 对于newList[1] = B，在oldList中找不到匹配项
  ///    - 调用insertItem(1, insertDuration: insertDuration)应用插入动画
  ///    - 对于剩余元素C和D，在oldList中找到匹配项，继续
  ///    - 用户会看到B以淡入或其他配置的进入动画效果出现
  ///
  /// 4. 多个项目同时添加和移除（列表长度相同）
  ///    例如：[A, B, C, D] -> [A, E, F, D]
  ///    处理流程：
  ///    - 列表长度相同（都是4）且enableSwap为true
  ///    - 遇到索引1处的元素不同：B != E
  ///    - 在oldList中查找E，找不到（返回-1）
  ///    - 由于oldIndex == -1，不会添加到swappedPairs
  ///    - 遇到索引2处的元素不同：C != F
  ///    - 在oldList中查找F，找不到（返回-1）
  ///    - 由于oldIndex == -1，不会添加到swappedPairs
  ///    - 检查swappedPairs.isEmpty：为true
  ///    - 执行return，提前返回，跳过后续的添加和移除检测
  ///    - 结果：用户界面不会显示任何动画效果，B和C会直接消失，E和F会直接出现
  ///    - 注意：这是当前实现的一个潜在问题，可能需要修改代码以正确处理这种情况
  ///
  /// 5. 多个项目同时添加和移除（列表长度不同）
  ///    例如：[A, B, C] -> [A, D, E, F]
  ///    处理流程：
  ///    - 列表长度不同（3 != 4），直接跳过交换检测逻辑块
  ///    - 执行移除检测：从后向前遍历oldList
  ///    - 对于C，在newList中找不到，应用移除动画
  ///    - 对于B，在newList中找不到，应用移除动画
  ///    - 对于A，在newList中找到，跳过
  ///    - 执行添加检测：遍历newList
  ///    - 对于A，在oldList中找到，跳过
  ///    - 对于D，在oldList中找不到，应用添加动画
  ///    - 对于E，在oldList中找不到，应用添加动画
  ///    - 对于F，在oldList中找不到，应用添加动画
  ///    - 结果：用户会看到B和C消失，D、E和F出现，所有变化都有平滑的动画效果
  ///
  /// 6. 复杂的重排序（多个交换）
  ///    例如：[A, B, C, D, E] -> [A, D, B, E, C]
  ///    处理流程：
  ///    - 列表长度相同（都是5）且enableSwap为true
  ///    - 遇到索引1处的元素不同：B != D
  ///    - 在oldList中查找D的位置，找到索引3
  ///    - 检查newList[3] = E是否等于oldList[1] = B，不等于，不是简单交换
  ///    - 遇到索引2处的元素不同：C != B
  ///    - 在oldList中查找B的位置，找到索引1
  ///    - 检查newList[1] = D是否等于oldList[2] = C，不等于，不是简单交换
  ///    - 类似地，识别出其他交换对
  ///    - 依次应用移动动画
  ///    - 结果：用户会看到元素平滑地移动到新位置
  void calculateDiff(List oldList, List newList) {
    final swappedPairs = [];

    // 检测项目交换（当列表长度相同且启用交换动画时）
    if (oldList.length == newList.length && widget.enableSwap) {
      for (int i = 0; i < newList.length; i++) {
        // 如果当前位置的项目不同
        if (!isSameItem(oldList[i], newList[i])) {
          // 在旧列表中查找新项目的位置
          final oldIndex = oldList.indexWhere((oldItem) => isSameItem(oldItem, newList[i]));

          if (oldIndex != -1) {
            // 检查是否是交换操作（A和B交换位置）
            if (isSameItem(newList[oldIndex], oldList[i])) {
              swappedPairs.add([i, oldIndex]);
            }
          }
        }
      }
      if (swappedPairs.isEmpty) {
        return;
      }
      // 处理交换的项目，应用移动动画
      for (List<int> pair in swappedPairs) {
        listKey.currentState!.moveItem(pair[0], pair[1]);
      }
      return;
    }

    // 检测移除的项目（从后向前遍历，避免索引变化影响）
    for (int i = oldList.length - 1; i >= 0; i--) {
      // 如果旧项目在新列表中不存在，则应用移除动画
      if (newList.indexWhere((element) => isSameItem(oldList[i], element)) == -1) {
        listKey.currentState!.removeItem(i, removeItemDuration: removeDuration);
      }
    }
    // 检测添加的项目
    for (int i = 0; i < newList.length; i++) {
      // 如果新项目在旧列表中不存在，则应用插入动画
      if (oldList.indexWhere((element) => isSameItem(newList[i], element)) == -1) {
        listKey.currentState!.insertItem(i, insertDuration: insertDuration);
      }
    }
  }

  /// 插入动画构建器
  /// 为新插入的项目构建动画效果
  ///
  /// [context] - 构建上下文
  /// [child] - 要应用动画的子部件
  /// [animation] - 控制动画进度的动画对象
  ///
  /// 返回应用了动画效果的部件
  @nonVirtual
  @protected
  Widget insertAnimationBuilder(BuildContext context, Widget child, Animation<double> animation) {
    if (widget.insertItemBuilder != null) {
      // 如果提供了自定义插入动画构建器，则使用它
      return widget.insertItemBuilder!(child, animation);
    } else {
      // 否则使用默认的动画效果列表
      Widget animatedChild = child;
      // 按顺序应用所有进入动画效果
      for (EffectEntry entry in _enterAnimations) {
        animatedChild = entry.animationEffect.build(context, animatedChild, animation, entry, insertDuration);
      }
      return animatedChild;
    }
  }

  /// 移除动画构建器
  /// 为要移除的项目构建动画效果
  ///
  /// [context] - 构建上下文
  /// [child] - 要应用动画的子部件
  /// [animation] - 控制动画进度的动画对象
  ///
  /// 返回应用了动画效果的部件
  @nonVirtual
  @protected
  Widget removeAnimationBuilder(BuildContext context, Widget child, Animation<double> animation) {
    if (widget.removeItemBuilder != null) {
      // 如果提供了自定义移除动画构建器，则使用它
      return widget.removeItemBuilder!(child, animation);
    } else {
      // 否则使用默认的动画效果列表
      Widget animatedChild = child;
      // 按顺序应用所有退出动画效果
      for (EffectEntry entry in _exitAnimations) {
        animatedChild = entry.animationEffect.build(context, animatedChild, animation, entry, removeDuration);
      }
      return animatedChild;
    }
  }
}
