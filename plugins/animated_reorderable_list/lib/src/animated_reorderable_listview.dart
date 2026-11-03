import 'package:flutter/gestures.dart';
import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:flutter/material.dart';
import 'builder/reorderable_animated_list_base.dart';
import 'builder/reorderable_animated_list_impl.dart';
import 'model/cross_container_data.dart';

///A [ListView] that enables users to interactively reorder items through dragging, with animated insertion and removal of items.
/// 一个[ListView]，允许用户通过拖动交互式地重新排序项目，并具有项目的动画插入和移除功能。
///
/// {@template animated_reorderable_list.AnimatedReorderableListView}
///  ```dart
///  enterTransition: [FadeIn(), ScaleIn()],
///  ```
///
/// Effects are always run in parallel (ie. the fade and scale effects in the
/// example above would be run simultaneously), but you can apply delays to
/// offset them or run them in sequence.
/// 效果总是并行运行（例如，上面示例中的淡入和缩放效果将同时运行），但您可以应用延迟来
/// 偏移它们或按顺序运行它们。
///
/// The [onReorder] parameter is required and will be called when a child
/// widget is dragged to a new position.
/// [onReorder]参数是必需的，当子部件被拖动到新位置时将调用它。
///
/// By default, on `TargetPlatformVariant.desktop` platforms each item will
/// have a drag handle added on top of it that will allow the user to grab it
/// to move the item. On `TargetPlatformVariant.mobile`, no drag handle will be
/// added, but when the user long presses anywhere on the item it will start
/// moving the item.
/// 默认情况下，在`TargetPlatformVariant.desktop`平台上，每个项目上方都会添加一个拖动手柄，
/// 允许用户抓取它来移动项目。在`TargetPlatformVariant.mobile`上，不会添加拖动手柄，
/// 但当用户在项目上任何位置长按时，它将开始移动项目。
///
/// All list items must have a key.
/// 所有列表项目必须有一个键。
///
/// While a drag is underway, the widget returned by the [AnimatedReorderableListView.proxyDecorator]
/// callback serves as a "proxy" (a substitute) for the item in the list. The proxy is
/// created with the original list item as its child.
/// 当拖动正在进行时，由[AnimatedReorderableListView.proxyDecorator]回调返回的部件
/// 作为列表中项目的"代理"（替代品）。代理是以原始列表项目作为其子项创建的。
/// {@endtemplate}
class AnimatedReorderableListView<E extends Object> extends StatefulWidget {
  /// The current list of items that this[AnimatedReorderableListView] should represent.
  /// 当前这个[AnimatedReorderableListView]应该表示的项目列表。
  final List<E> items;

  /// {@template animated_reorderable_list.itemBuilder}
  /// Called, as needed, to build list item widgets.
  /// 根据需要调用，用于构建列表项部件。
  ///
  /// List items are only built when they're scrolled into view.
  /// 列表项只有在滚动到视图中时才会被构建。
  ///
  /// The [ItemBuilder] index parameter indicates the item's
  /// position in the list. The value of the index parameter will be between
  /// zero and one less than [items]. All items in the list must have a
  /// unique [Key].
  /// [ItemBuilder]的index参数表示项目在列表中的位置。index参数的值将在
  /// 零和比[items]少一之间。列表中的所有项目必须有唯一的[Key]。
  /// {@endtemplate}
  final ItemBuilder<Widget, E> itemBuilder;

  /// {@template flutter.widgets.AnimatedReorderable.enterTransition}
  /// A list of [AnimationEffect](s) used for the appearing animation when an item is added to the list.
  ///
  /// This property controls how newly added items animate into view. The animations in this list
  /// will run sequentially, meaning each effect will be applied one after another in the order
  /// specified. By default, this property uses a single [FadeIn()] effect.
  ///
  /// ### Default Value
  /// If not explicitly provided, the default animation applied is:
  /// ```dart
  /// [FadeIn()]
  /// ```
  ///
  /// ### Supported Animations
  /// The following animation effects are supported by the library and can be combined as desired:
  /// - `FadeIn()`: A smooth fade-in animation.
  /// - `FlipInY()`: An animation that flips the item along the Y-axis.
  /// - `FlipInX()`: An animation that flips the item along the X-axis.
  /// - `Landing()`: An animation that mimics a landing effect.
  /// - `SizeAnimation()`: Gradually animates the size of the item.
  /// - `ScaleIn()`: A scaling animation where the item grows into view.
  /// - `ScaleInTop()`: A scaling effect originating from the top.
  /// - `ScaleInBottom()`: A scaling effect originating from the bottom.
  /// - `ScaleInLeft()`: A scaling effect originating from the left.
  /// - `ScaleInRight()`: A scaling effect originating from the right.
  /// - `SlideInLeft()`: A sliding animation from the left.
  /// - `SlideInRight()`: A sliding animation from the right.
  /// - `SlideInUp()`: A sliding animation from the bottom to the top.
  /// - `SlideInDown()`: A sliding animation from the top to the bottom.
  ///
  /// ### Custom Animations
  /// In addition to the predefined animations listed above, you can create custom configurations
  /// for each animation to suit your specific needs. For example, you can adjust the duration,
  /// curve, or other parameters for finer control:
  /// ```dart
  /// enterTransition: [
  ///   FadeIn(duration: Duration(milliseconds: 500), curve: Curves.easeIn),
  ///   SlideInLeft(delay: Duration(milliseconds: 200)),
  /// ],
  /// ```
  ///
  /// {@endtemplate}
  final List<AnimationEffect>? enterTransition;

  /// {@template flutter.widgets.AnimatedReorderable.exitTransition}
  /// A list of [AnimationEffect](s) used for the disappearing animation when an item was removed from the list.
  ///
  /// This property controls how item will be removed from the view. The animations in this list
  /// will run sequentially, meaning each effect will be applied one after another in the order
  /// specified. By default, this property uses a single [FadeIn()] effect.
  ///
  /// ### Default Value
  /// If not explicitly provided, the default animation applied is:
  /// ```dart
  /// [FadeIn()]
  /// ```
  ///
  /// ### Supported Animations
  /// The following animation effects are supported by the library and can be combined as desired:
  /// - `FadeIn()`: A smooth fade-in animation.
  /// - `FlipInY()`: An animation that flips the item along the Y-axis.
  /// - `FlipInX()`: An animation that flips the item along the X-axis.
  /// - `Landing()`: An animation that mimics a landing effect.
  /// - `SizeAnimation()`: Gradually animates the size of the item.
  /// - `ScaleIn()`: A scaling animation where the item grows into view.
  /// - `ScaleInTop()`: A scaling effect originating from the top.
  /// - `ScaleInBottom()`: A scaling effect originating from the bottom.
  /// - `ScaleInLeft()`: A scaling effect originating from the left.
  /// - `ScaleInRight()`: A scaling effect originating from the right.
  /// - `SlideInLeft()`: A sliding animation from the left.
  /// - `SlideInRight()`: A sliding animation from the right.
  /// - `SlideInUp()`: A sliding animation from the bottom to the top.
  /// - `SlideInDown()`: A sliding animation from the top to the bottom.
  ///
  /// ### Custom Animations
  /// In addition to the predefined animations listed above, you can create custom configurations
  /// for each animation to suit your specific needs. For example, you can adjust the duration,
  /// curve, or other parameters for finer control:
  /// ```dart
  /// exitTransition: [
  ///   FadeIn(duration: Duration(milliseconds: 500), curve: Curves.easeIn),
  ///   SlideInLeft(delay: Duration(milliseconds: 200)),
  /// ],
  /// ```
  ///
  /// {@endtemplate}
  final List<AnimationEffect>? exitTransition;

  /// The duration of the animation when an item is inserted into the list.
  ///
  /// This property defines the default duration for all animations applied to items
  /// when they are added to the list. If you provide a specific duration for each
  /// [AnimationEffect] in the `enterTransition` list, the [insertDuration]
  /// override the durations of all animations in the [enterTransition].
  ///
  /// **Usage:**
  /// - If `insertDuration` is provided, it will override all durations specified
  ///   in the [enterTransition] list.
  /// - If `insertDuration` is not provided, the individual durations defined
  ///   in [enterTransition] will be used instead.
  /// - If neither `insertDuration` nor individual durations are specified, a default
  ///   duration (e.g., `const Duration(milliseconds: 300)`) will be used.
  ///
  /// **Example:**
  /// ```dart
  /// AnimatedReorderableListView(
  ///   insertDuration: Duration(milliseconds: 500), // Default duration for item insertions.
  ///   enterTransition: [
  ///     FadeIn(duration: Duration(milliseconds: 300)), // Overrides the default for this effect.
  ///     SlideInLeft(), // Will use the default duration from `insertDuration`.
  ///   ],
  /// );
  /// ```
  /// insertDuration
  final Duration? insertDuration;

  /// The duration of the animation when an item is removed from the list.
  ///
  /// This property defines the default duration for all animations applied to items
  /// when they are removed from the list. If you provide a specific duration for each
  /// [AnimationEffect] in the `exitTransition` list, the [removeDuration]
  /// override the durations of all animations in the [exitTransition].
  ///
  /// **Usage:**
  /// - If `removeDuration` is specified, it will be applied as the default duration
  ///   for the removal animation of items.
  /// - If specific durations are provided for individual `AnimationEffect`s, they take precedence.
  /// - If neither `removeDuration` nor individual durations are specified, a default
  ///   duration (e.g., `const Duration(milliseconds: 300)`) may be used.
  ///
  /// **Example:**
  /// ```dart
  /// AnimatedReorderableListView(
  ///   removeDuration: Duration(milliseconds: 400), // Default duration for item removals.
  ///   exitTransition: [
  ///     FadeOut(duration: Duration(milliseconds: 200)), // Overrides the default for this effect.
  ///     SlideOutRight(), // Will use the default duration from `removeDuration`.
  ///   ],
  /// );
  /// ```
  /// `removeDuration` is overridden by the duration specified in the `exitTransition`.
  final Duration? removeDuration;

  /// A callback used by [AnimatedReorderableListView] to report that a list item has moved
  /// to a new position in the list.
  /// [AnimatedReorderableListView]用来报告列表项已移动到列表中新位置的回调。
  ///
  /// Implementations should remove the corresponding list item at `oldIndex`
  /// and reinsert it at `newIndex`.
  /// 实现应该删除`oldIndex`处的相应列表项，并在`newIndex`处重新插入。
  final ReorderCallback onReorder;

  /// A callback that is called when an item drag has started.
  /// 当项目拖动开始时调用的回调。
  ///
  /// The index parameter of the callback is the index of the selected item.
  /// 回调的index参数是所选项目的索引。
  final void Function(int)? onReorderStart;

  /// A callback that is called when the dragged item is dropped.
  /// 当拖动的项目被放下时调用的回调。
  ///
  /// The index parameter of the callback is the index where the item is
  /// dropped. Unlike [onReorder], this is called even when the list item is
  /// dropped in the same location.
  final void Function(int)? onReorderEnd;

  /// The axis along which the scroll view scrolls.
  /// 滚动视图滚动的轴向。
  ///
  /// Defaults to [Axis.vertical].
  /// 默认为[Axis.vertical]（垂直方向）。
  final Axis scrollDirection;

  /// {@template flutter.widgets.reorderable_list.proxyDecorator}
  /// A callback that allows the app to add an animated decoration around
  /// an item when it is being dragged.
  /// 允许应用程序在项目被拖动时在其周围添加动画装饰的回调。
  /// {@endtemplate}
  final ReorderItemProxyDecorator? proxyDecorator;

  /// If true, on desktop platforms, a drag handle is stacked over the center of each item's trailing edge;
  /// on mobile platforms, a long press anywhere on the item starts a drag.
  /// 如果为true，在桌面平台上，拖动手柄会叠加在每个项目尾部边缘的中心；
  /// 在移动平台上，在项目上任何位置长按都会开始拖动。
  ///
  /// The default desktop drag handle is just an [Icons.drag_handle] wrapped by [ReorderableDragStartListener].
  /// On mobile platforms, the entire item is wrapped with a [ReorderableDragStartListener].
  /// 默认的桌面拖动手柄只是由[ReorderableDragStartListener]包裹的[Icons.drag_handle]。
  /// 在移动平台上，整个项目都由[ReorderableDragStartListener]包裹。
  ///
  /// To change the appearance or the layout of the drag handles, make this parameter false
  /// and wrap each list item, or a widget within each list item, with [ReorderableDragStartListener]or
  /// a subclass of [ReorderableDragStartListener].
  /// 要更改拖动手柄的外观或布局，请将此参数设置为false，
  /// 并使用[ReorderableDragStartListener]或其子类包裹每个列表项或列表项内的小部件。
  ///
  /// To get the idea [Flutter Example](https://api.flutter.dev/flutter/material/ReorderableListView/buildDefaultDragHandles.html)
  /// 要获取更多信息，请参考[Flutter示例](https://api.flutter.dev/flutter/material/ReorderableListView/buildDefaultDragHandles.html)

  final bool buildDefaultDragHandles;

  /// {@macro flutter.widgets.scroll_view.reverse}
  /// 控制滚动视图的滚动方向是否与默认方向相反。
  ///
  /// 当设置为true时，滚动视图将从底部开始向上滚动（垂直方向）或从右到左滚动（水平方向）。
  final bool reverse;

  /// [ScrollController] to get the current scroll position.
  /// 用于获取当前滚动位置的[ScrollController]。
  ///
  ///  Must be null if [primary] is true.
  ///  如果[primary]为true，则必须为null。
  ///
  ///  It can be used to read the current
  //   scroll position (see [ScrollController.offset]), or change it (see
  //   [ScrollController.animateTo]).
  ///  它可用于读取当前滚动位置（参见[ScrollController.offset]），
  ///  或更改它（参见[ScrollController.animateTo]）。
  final ScrollController? controller;

  /// When this is true, the scroll view is scrollable even if it does not have
  /// sufficient content to actually scroll. Otherwise, by default the user can
  /// only scroll the view if it has sufficient content. See [physics].
  /// 当设置为true时，即使滚动视图没有足够的内容来实际滚动，也可以滚动。
  /// 否则，默认情况下用户只能在视图有足够内容时滚动。参见[physics]。
  ///
  /// Cannot be true while a [ScrollController] is provided to `controller`,
  /// only one ScrollController can be associated with a ScrollView.
  /// 当为`controller`提供[ScrollController]时，不能为true，
  /// 因为一个ScrollView只能关联一个ScrollController。
  ///
  /// Defaults to null.
  /// 默认为null。
  final bool? primary;

  /// {@template flutter.widgets.reorderable_list.padding}
  /// The amount of space by which to inset the list contents.
  /// 列表内容的内边距空间。
  ///
  /// It defaults to `EdgeInsets.all(0)`.
  /// 默认为`EdgeInsets.all(0)`。
  /// {@endtemplate}
  final EdgeInsetsGeometry? padding;

  /// How the scroll view should respond to user input.
  /// 滚动视图应如何响应用户输入。
  ///
  /// For example, determines how the scroll view continues to animate after the
  /// user stops dragging the scroll view.
  /// 例如，决定用户停止拖动滚动视图后，滚动视图如何继续动画。
  ///
  /// Defaults to matching platform conventions. Furthermore, if [primary] is
  /// false, then the user cannot scroll if there is insufficient content to
  /// scroll, while if [primary] is true, they can always attempt to scroll.
  /// 默认为匹配平台约定。此外，如果[primary]为false，则当没有足够的内容滚动时，
  /// 用户无法滚动；而如果[primary]为true，他们始终可以尝试滚动。
  final ScrollPhysics? physics;

  /// [ScrollBehavior]s also provide [ScrollPhysics]. If an explicit
  /// [ScrollPhysics] is provided in [physics], it will take precedence,
  /// followed by [scrollBehavior], and then the inherited ancestor
  /// [ScrollBehavior].
  /// [ScrollBehavior]也提供[ScrollPhysics]。如果在[physics]中提供了显式的
  /// [ScrollPhysics]，它将优先生效，其次是[scrollBehavior]，然后是继承的祖先
  /// [ScrollBehavior]。
  final ScrollBehavior? scrollBehavior;

  /// Creates a ScrollView that creates custom scroll effects using slivers.
  /// See the ScrollView constructor for more details on these arguments.
  /// 创建一个使用slivers创建自定义滚动效果的ScrollView。
  /// 有关这些参数的更多详细信息，请参见ScrollView构造函数。
  ///
  /// 用于在应用程序重启时恢复滚动位置的标识符。
  final String? restorationId;

  /// [ScrollViewKeyboardDismissBehavior] the defines how this [ScrollView] will
  /// dismiss the keyboard automatically.
  /// [ScrollViewKeyboardDismissBehavior]定义了这个[ScrollView]将如何
  /// 自动关闭键盘。
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// Defaults to [Clip.hardEdge].
  /// 默认为[Clip.hardEdge]。
  ///
  /// Creates a ScrollView that creates custom scroll effects using slivers.
  /// See the ScrollView constructor for more details on these arguments.
  /// 创建一个使用slivers创建自定义滚动效果的ScrollView。
  /// 有关这些参数的更多详细信息，请参见ScrollView构造函数。
  ///
  /// 控制如何裁剪滚动视图的内容。
  final Clip clipBehavior;

  /// Creates a ScrollView that creates custom scroll effects using slivers.
  /// See the ScrollView constructor for more details on these arguments.
  /// 创建一个使用slivers创建自定义滚动效果的ScrollView。
  /// 有关这些参数的更多详细信息，请参见ScrollView构造函数。
  ///
  /// 定义拖动手势开始的行为方式。
  final DragStartBehavior dragStartBehavior;

  /// A custom builder that is for adding items with animations.
  /// 用于添加带动画的项目的自定义构建器。
  ///
  /// The child argument is the widget that is returned by [itemBuilder],
  ///  and the `animation` is an [Animation] that should be used to animate an exit
  /// transition for the widget that is built.
  /// child参数是由[itemBuilder]返回的小部件，而`animation`是一个[Animation]，
  /// 应用于为构建的小部件添加进入过渡动画。
  ///
  /// If specified, the [enterTransition] will be ignored.
  /// 如果指定了此项，[enterTransition]将被忽略。
  final AnimatedWidgetBuilder? insertItemBuilder;

  /// A custom builder that is for removing items with animations.
  /// 用于移除带动画的项目的自定义构建器。
  ///
  /// The child argument is the widget that is returned by [itemBuilder],
  ///  and the `animation` is an [Animation] that should be used to animate an exit
  /// transition for the widget that is built.
  /// child参数是由[itemBuilder]返回的小部件，而`animation`是一个[Animation]，
  /// 应用于为构建的小部件添加退出过渡动画。
  ///
  /// If specified, the [exitTransition] will be ignored.
  /// 如果指定了此项，[exitTransition]将被忽略。
  final AnimatedWidgetBuilder? removeItemBuilder;

  /// Whether the extent of the scroll view in the scrollDirection should be determined by the contents being viewed.
  /// 在scrollDirection方向上的滚动视图范围是否应由正在查看的内容决定。
  ///
  /// 当设置为true时，滚动视图将根据其内容自动调整大小，而不是尽可能占用所有可用空间。
  final bool shrinkWrap;

  /// A callback function to determine if two items in the list are considered the same.
  ///
  /// This function is important to prevent unnecessary animations when editing or updating items.
  /// For example, if your items have a unique `id`, you can use this function to compare them
  /// and return `true`, indicating they represent the same item.
  ///
  ///
  /// **Why is this important?**
  ///
  /// If `isSameItem` is not defined and you are working with immutable objects (e.g., creating new
  /// instances on every update), the library may interpret these as different items. This will
  /// trigger animations unnecessarily. Additionally, if you are generating `Key` values directly
  /// from these instances, it can result in the following exception:
  ///
  /// `Multiple widgets used the same GlobalKey.`
  ///
  /// To avoid this exception, you must implement the `isSameItem` callback to accurately compare
  /// the identity of the items in your list.
  ///
  /// Example:
  /// ```dart
  /// isSameItem: (a, b) => a.id == b.id,
  /// ```
  /// 用于判断两个项目是否相同的函数。在重新排序时用于识别项目。
  /// 例如，可以通过比较项目的ID来判断它们是否相同。
  final bool Function(E a, E b) isSameItem;

  /// The amount of time to wait before starting the drag operation.
  /// 在开始拖动操作前等待的时间量。
  ///
  /// Set to [Duration.zero] to start the drag operation immediately.
  /// 设置为[Duration.zero]可立即开始拖动操作。
  final Duration dragStartDelay;

  /// A list of item that are not draggable.
  /// 不可拖动的项目列表。
  ///
  /// The item can't be draggable, but it can be reordered.
  /// 项目不能被拖动，但可以被重新排序。
  final List<E> nonDraggableItems;

  /// A list of items that are locked and can't be reordered and dragged.
  /// 被锁定且无法重新排序和拖动的项目列表。
  ///
  /// Add elements in this list if all the elements in the list has same height. If the elements has different height, the reordered items will not be placed in the correct position.
  /// 如果列表中的所有元素高度相同，请将元素添加到此列表中。如果元素高度不同，重新排序的项目将无法放置在正确的位置。
  final List<E> lockedItems;

  /// Whether to enable swap animation when changing the order of the items.
  /// 更改项目顺序时是否启用交换动画。
  ///
  /// Defaults to true.
  /// 默认为true。
  final bool enableSwap;

  /// 这个容器是否可以接收从其他容器拖动的项目。
  /// 默认为false。
  final bool canReceiveItem;

  /// 是否允许项目拖出当前容器
  /// 如果为true，则项目可以被拖出到其他容器
  /// 如果为false，当拖拽结束时，项目会回到原来的位置
  final bool canDragOutItem;

  /// 滚动视图的缓存范围，单位为逻辑像素（非项目个数）
  /// 用于指定在可视区域外需要缓存的区域大小
  /// 设置较大的值（如1000）可以预加载更多项目，避免拖拽过程中组件重建
  /// 默认为null，使用Flutter的默认值
  final double? cacheExtent;

  /// 容器的唯一标识符
  /// 用于在跨容器拖拽时识别源容器和目标容器
  final dynamic containerId;

  /// 数据获取器回调
  /// 用于获取指定索引处的实际数据模型，而不是 UI 组件
  /// 在跨容器拖拽时用于传递实际数据
  final ItemDataGetter? itemDataGetter;

  /// 拖拽更新回调
  /// 当拖拽位置更新时触发，提供当前的拖拽信息
  /// 主要用于让外部组件根据拖拽位置进行额外操作，如水平滚动列表
  final void Function(CrossContainerData containerData)? onDragUpdate;

  /// 拖拽结束回调
  /// 当拖拽位置结束时触发，提供当前的拖拽信息
  /// 主要用于让外部组件根据拖拽位置进行额外操作
  final bool Function(CrossContainerData containerData)? onDragEnd;

  /// Creates a [AnimatedReorderableListView] that enables users to interactively reorder items through dragging,
  /// with animated insertion and removal of items.
  const AnimatedReorderableListView({
    Key? key,
    required this.items,
    required this.itemBuilder,
    required this.onReorder,
    this.enterTransition,
    this.exitTransition,
    this.insertDuration,
    this.removeDuration,
    this.onReorderStart,
    this.onReorderEnd,
    this.proxyDecorator,
    this.scrollDirection = Axis.vertical,
    this.padding,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.scrollBehavior,
    this.restorationId,
    this.buildDefaultDragHandles = true,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.dragStartBehavior = DragStartBehavior.start,
    this.clipBehavior = Clip.hardEdge,
    this.insertItemBuilder,
    this.removeItemBuilder,
    this.shrinkWrap = false,
    required this.isSameItem,
    this.dragStartDelay = const Duration(milliseconds: 500),
    this.nonDraggableItems = const [],
    this.lockedItems = const [],
    this.enableSwap = true,
    this.canReceiveItem = false,
    this.canDragOutItem = false,
    this.cacheExtent,
    this.containerId,
    this.itemDataGetter,
    this.onDragUpdate,
    this.onDragEnd,
  }) : super(key: key);

  /// The state from the closest instance of this class that encloses the given
  /// context.
  ///
  /// If no [AnimatedReorderableListView] surrounds the given context, then this function
  /// will assert in debug mode and throw an exception in release mode.
  ///
  /// This method can be expensive (it walks the element tree).
  static AnimatedReorderableListViewState of(BuildContext context) {
    final AnimatedReorderableListViewState? result =
        context.findAncestorStateOfType<AnimatedReorderableListViewState>();
    assert(() {
      if (result == null) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
              'AnimatedReorderableListViewState.of() called with a context that does not contain a AnimatedReorderableListViewState.'),
          ErrorDescription(
            'No AnimatedReorderableListViewState ancestor could be found starting from the context that was passed to AnimatedReorderableListViewState.of().',
          ),
          ErrorHint('This can happen when the context provided is from the same StatefulWidget that '
              'built the AnimatedReorderableListViewState. '),
          context.describeElement('The context used was'),
        ]);
      }
      return true;
    }());
    return result!;
  }

  /// The state from the closest instance of this class that encloses the given
  /// context.
  ///
  /// This method is typically used by [AnimatedReorderableListViewState] item widgets that insert
  /// or remove items in response to user input.
  ///
  /// If no [AnimatedReorderableListViewState] surrounds the context given, then this function will
  /// return null.
  ///
  /// This method can be expensive (it walks the element tree).
  static AnimatedReorderableListViewState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<AnimatedReorderableListViewState>();
  }

  @override
  State<AnimatedReorderableListView<E>> createState() => AnimatedReorderableListViewState();
}

class AnimatedReorderableListViewState<E extends Object> extends State<AnimatedReorderableListView<E>> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
        scrollDirection: widget.scrollDirection,
        reverse: widget.reverse,
        controller: widget.controller,
        primary: widget.primary,
        physics: widget.physics,
        scrollBehavior: widget.scrollBehavior,
        restorationId: widget.restorationId,
        keyboardDismissBehavior: widget.keyboardDismissBehavior,
        dragStartBehavior: widget.dragStartBehavior,
        clipBehavior: widget.clipBehavior,
        shrinkWrap: widget.shrinkWrap,
        cacheExtent: widget.cacheExtent,
        slivers: [
          SliverPadding(
            padding: widget.padding ?? EdgeInsets.zero,
            sliver: ReorderableAnimatedListImpl(
              items: widget.items,
              itemBuilder: widget.itemBuilder,
              enterTransition: widget.enterTransition,
              exitTransition: widget.exitTransition,
              insertDuration: widget.insertDuration,
              removeDuration: widget.removeDuration,
              onReorder: widget.onReorder,
              onReorderStart: widget.onReorderStart,
              onReorderEnd: widget.onReorderEnd,
              proxyDecorator: widget.proxyDecorator,
              buildDefaultDragHandles: widget.buildDefaultDragHandles,
              scrollDirection: widget.scrollDirection,
              insertItemBuilder: widget.insertItemBuilder,
              removeItemBuilder: widget.removeItemBuilder,
              isSameItem: widget.isSameItem,
              dragStartDelay: widget.dragStartDelay,
              nonDraggableItems: widget.nonDraggableItems,
              lockedItems: widget.lockedItems,
              containerId: widget.containerId,
              canReceiveItem: widget.canReceiveItem,
              canDragOutItem: widget.canDragOutItem,
              onDragUpdate: widget.onDragUpdate,
              onDragEnd: widget.onDragEnd,
              itemDataGetter: widget.itemDataGetter,
              enableSwap: widget.enableSwap,
            ),
          ),
        ]);
  }
}
