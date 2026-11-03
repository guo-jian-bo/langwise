import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';

import 'builder/reorderable_animated_list_base.dart';
import 'builder/reorderable_animated_list_impl.dart';
import 'model/cross_container_data.dart';

/// @docImport 'animated_reorderable_listview';

/// A GridView that enables users to interactively reorder items through dragging, with animated insertion and removal of items.
/// 一个支持用户通过拖拽交互式重新排序项目的GridView，具有动画插入和移除项目的功能。
///  ```dart
///  enterTransition: [FadeIn(), ScaleIn()],
///  ```
///
/// Effects are always run in parallel (ie. the fade and scale effects in the
/// example above would be run simultaneously), but you can apply delays to
/// offset them or run them in sequence.
/// 效果始终并行运行（例如，上面示例中的淡入和缩放效果将同时运行），
/// 但您可以应用延迟来偏移它们或按顺序运行它们。
///
/// The [onReorder] parameter is required and will be called when a child
/// widget is dragged to a new position.
/// [onReorder]参数是必需的，当子部件被拖动到新位置时将调用它。
///
/// All list items must have a key.
/// 所有列表项必须有一个键(key)。
///
/// While a drag is underway, the widget returned by the [AnimatedReorderableListView.proxyDecorator]
/// callback serves as a "proxy" (a substitute) for the item in the list. The proxy is
/// created with the original list item as its child.
/// 当拖动正在进行时，由[AnimatedReorderableListView.proxyDecorator]回调返回的部件
/// 作为列表中项目的"代理"（替代品）。代理是使用原始列表项作为其子项创建的。
///
class AnimatedReorderableGridView<E extends Object> extends StatefulWidget {
  /// The current list of items that this[AnimatedReorderableGridView] should represent.
  /// 当前[AnimatedReorderableGridView]应该表示的项目列表。
  final List<E> items;

  /// Called, as needed, to build list item widgets.
  /// 根据需要调用，用于构建列表项部件。
  ///
  /// List items are only built when they're scrolled into view.
  /// 列表项仅在滚动到视图中时才构建。
  ///
  /// The [ItemBuilder] index parameter indicates the item's
  /// position in the list. The value of the index parameter will be between
  /// zero and one less than [items]. All items in the list must have a
  /// unique [Key].
  /// [ItemBuilder]索引参数表示项目在列表中的位置。索引参数的值将在
  /// 零和比[items]少一之间。列表中的所有项目必须有一个唯一的[Key]。
  final ItemBuilder<Widget, E> itemBuilder;

  /// Controls the layout of tiles in a grid.
  /// 控制网格中瓷砖的布局。
  /// Given the current constraints on the grid,
  /// a SliverGridDelegate computes the layout for the tiles in the grid.
  /// 给定网格上的当前约束，SliverGridDelegate为网格中的瓷砖计算布局。
  /// The tiles can be placed arbitrarily,
  /// but it is more efficient to place tiles in roughly in order by scroll offset because grids reify a contiguous sequence of children.
  /// 瓷砖可以任意放置，但按滚动偏移量大致排序放置瓷砖更有效，因为网格会实例化一个连续的子序列。
  final SliverGridDelegate sliverGridDelegate;

  /// A list of [AnimationEffect](s) used for the appearing animation when an item is added to the list.
  /// 当项目添加到列表时用于出现动画的[AnimationEffect]列表。
  ///
  /// This property controls how newly added items animate into view. The animations in this list
  /// will run sequentially, meaning each effect will be applied one after another in the order
  /// specified. By default, this property uses a single [FadeIn()] effect.
  /// 此属性控制新添加的项目如何动画进入视图。此列表中的动画将按顺序运行，
  /// 这意味着每个效果将按照指定的顺序依次应用。默认情况下，此属性使用单个[FadeIn()]效果。
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
  final List<AnimationEffect>? enterTransition;

  /// A list of [AnimationEffect](s) used for the disappearing animation when an item was removed from the list.
  /// 当项目从列表中移除时用于消失动画的[AnimationEffect]列表。
  ///
  /// This property controls how item will be removed from the view. The animations in this list
  /// will run sequentially, meaning each effect will be applied one after another in the order
  /// specified. By default, this property uses a single [FadeIn()] effect.
  /// 此属性控制项目将如何从视图中移除。此列表中的动画将按顺序运行，
  /// 这意味着每个效果将按照指定的顺序依次应用。默认情况下，此属性使用单个[FadeIn()]效果。
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
  final List<AnimationEffect>? exitTransition;

  /// The duration of the animation when an item is inserted into the list.
  /// 当项目插入到列表中时的动画持续时间。
  ///
  /// This property defines the default duration for all animations applied to items
  /// when they are added to the list. If you provide a specific duration for each
  /// [AnimationEffect] in the `enterTransition` list, the [insertDuration]
  /// override the durations of all animations in the [enterTransition].
  /// 此属性定义了应用于项目添加到列表时的所有动画的默认持续时间。
  /// 如果您为`enterTransition`列表中的每个[AnimationEffect]提供特定持续时间，
  /// [insertDuration]将覆盖[enterTransition]中所有动画的持续时间。
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
  /// AnimatedReorderableGridView(
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
  /// 当项目从列表中移除时的动画持续时间。
  ///
  /// This property defines the default duration for all animations applied to items
  /// when they are removed from the list. If you provide a specific duration for each
  /// [AnimationEffect] in the `exitTransition` list, the [removeDuration]
  /// override the durations of all animations in the [exitTransition].
  /// 此属性定义了应用于项目从列表中移除时的所有动画的默认持续时间。
  /// 如果您为`exitTransition`列表中的每个[AnimationEffect]提供特定持续时间，
  /// [removeDuration]将覆盖[exitTransition]中所有动画的持续时间。
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
  /// AnimatedReorderableGridView(
  ///   removeDuration: Duration(milliseconds: 400), // Default duration for item removals.
  ///   exitTransition: [
  ///     FadeOut(duration: Duration(milliseconds: 200)), // Overrides the default for this effect.
  ///     SlideOutRight(), // Will use the default duration from `removeDuration`.
  ///   ],
  /// );
  /// ```
  /// `removeDuration` is overridden by the duration specified in the `exitTransition`.
  final Duration? removeDuration;

  /// A callback used by [AnimatedReorderableGridView] to report that a list item has moved
  /// to a new position in the list.
  /// [AnimatedReorderableGridView]用于报告列表项已移动到列表中新位置的回调。
  ///
  /// Implementations should remove the corresponding list item at `oldIndex`
  /// and reinsert it at `newIndex`.
  /// 实现应该删除`oldIndex`处的相应列表项，并在`newIndex`处重新插入。
  final ReorderCallback onReorder;

  /// A callback that is called when an item drag has started.
  /// 当项目拖动开始时调用的回调。
  ///
  /// The index parameter of the callback is the index of the selected item.
  /// 回调的索引参数是所选项目的索引。
  final void Function(int)? onReorderStart;

  /// A callback that is called when the dragged item is dropped.
  /// 当拖动的项目被放下时调用的回调。
  ///
  /// The index parameter of the callback is the index where the item is
  /// dropped. Unlike [onReorder], this is called even when the list item is
  /// dropped in the same location.
  final void Function(int)? onReorderEnd;

  /// {@template flutter.widgets.reorderable_list.proxyDecorator}
  /// A callback that allows the app to add an animated decoration around
  /// an item when it is being dragged.
  /// 允许应用程序在项目被拖动时在其周围添加动画装饰的回调。
  /// {@endtemplate}
  final ReorderItemProxyDecorator? proxyDecorator;

  /// The axis along which the scroll view scrolls.
  /// 滚动视图沿其滚动的轴。
  ///
  /// Determines whether the grid scrolls horizontally or vertically.
  /// 确定网格是水平滚动还是垂直滚动。
  ///
  /// Defaults to [Axis.vertical].
  /// 默认为[Axis.vertical]。
  final Axis scrollDirection;

  /// {@macro flutter.widgets.scroll_view.reverse}
  /// Whether the scroll view scrolls in the reading direction.
  /// 滚动视图是否按阅读方向滚动。
  ///
  /// For example, if the reading direction is left-to-right and
  /// [scrollDirection] is [Axis.horizontal], then the scroll view scrolls from
  /// left to right when [reverse] is false and from right to left when
  /// [reverse] is true.
  /// 例如，如果阅读方向是从左到右，且[scrollDirection]是[Axis.horizontal]，
  /// 那么当[reverse]为false时，滚动视图从左向右滚动；当[reverse]为true时，从右向左滚动。
  ///
  /// Similarly, if [scrollDirection] is [Axis.vertical], then the scroll view
  /// scrolls from top to bottom when [reverse] is false and from bottom to top
  /// when [reverse] is true.
  /// 类似地，如果[scrollDirection]是[Axis.vertical]，那么当[reverse]为false时，
  /// 滚动视图从上到下滚动；当[reverse]为true时，从下到上滚动。
  ///
  /// Defaults to false.
  /// 默认为false。
  final bool reverse;

  /// [ScrollController] to get the current scroll position.
  /// [ScrollController]用于获取当前滚动位置。
  ///
  /// Must be null if [primary] is true.
  /// 如果[primary]为true，则必须为null。
  ///
  /// It can be used to read the current scroll position (see [ScrollController.offset]),
  /// or change it (see [ScrollController.animateTo]).
  /// 它可用于读取当前滚动位置（参见[ScrollController.offset]），
  /// 或更改它（参见[ScrollController.animateTo]）。
  final ScrollController? controller;

  /// When this is true, the scroll view is scrollable even if it does not have
  /// sufficient content to actually scroll. Otherwise, by default the user can
  /// only scroll the view if it has sufficient content. See [physics].
  /// 当这个值为true时，即使滚动视图没有足够的内容来实际滚动，它也是可滚动的。
  /// 否则，默认情况下，用户只能在视图有足够内容时滚动它。请参见[physics]。
  ///
  /// Cannot be true while a [ScrollController] is provided to `controller`,
  /// only one ScrollController can be associated with a ScrollView.
  /// 当向`controller`提供[ScrollController]时，此值不能为true，
  /// 因为只能将一个ScrollController与一个ScrollView关联。
  ///
  /// Defaults to null.
  /// 默认为null。
  final bool? primary;

  /// {@template flutter.widgets.reorderable_list.padding}
  /// The amount of space by which to inset the list contents.
  ///
  /// It defaults to `EdgeInsets.all(0)`.
  /// {@endtemplate}
  final EdgeInsetsGeometry? padding;

  /// How the scroll view should respond to user input.
  /// 滚动视图应如何响应用户输入。
  ///
  /// For example, determines how the scroll view continues to animate after the
  /// user stops dragging the scroll view.
  /// 例如，决定用户停止拖动滚动视图后，滚动视图如何继续动画。
  ///
  /// Common physics types include:
  /// 常见的物理类型包括：
  /// - [ClampingScrollPhysics]: Prevents scrolling beyond the bounds (Android style)
  ///   阻止滚动超出边界（Android风格）
  /// - [BouncingScrollPhysics]: Allows scrolling beyond the bounds with a bounce effect (iOS style)
  ///   允许滚动超出边界并带有反弹效果（iOS风格）
  /// - [AlwaysScrollableScrollPhysics]: Makes the view always scrollable even with insufficient content
  ///   使视图始终可滚动，即使内容不足
  ///
  /// Defaults to matching platform conventions. Furthermore, if [primary] is
  /// false, then the user cannot scroll if there is insufficient content to
  /// scroll, while if [primary] is true, they can always attempt to scroll.
  /// 默认匹配平台约定。此外，如果[primary]为false，则在内容不足以滚动时用户无法滚动，
  /// 而如果[primary]为true，则他们始终可以尝试滚动。
  final ScrollPhysics? physics;

  /// Custom [ScrollBehavior] for this specific widget.
  /// 此特定小部件的自定义[ScrollBehavior]。
  ///
  /// [ScrollBehavior]s also provide [ScrollPhysics]. If an explicit
  /// [ScrollPhysics] is provided in [physics], it will take precedence,
  /// followed by [scrollBehavior], and then the inherited ancestor
  /// [ScrollBehavior].
  /// [ScrollBehavior]也提供[ScrollPhysics]。如果在[physics]中提供了显式的
  /// [ScrollPhysics]，它将优先使用，其次是[scrollBehavior]，然后是继承的祖先
  /// [ScrollBehavior]。
  ///
  /// This property can be particularly useful for customizing overscroll glow effects,
  /// drag behaviors, and scroll physics across platforms.
  /// 此属性对于自定义过度滚动发光效果、拖动行为和跨平台滚动物理特性特别有用。
  final ScrollBehavior? scrollBehavior;

  /// Restoration ID to save and restore the scroll offset of the scrollable.
  /// 用于保存和恢复可滚动内容滚动偏移量的恢复ID。
  ///
  /// If a restoration ID is provided, the scrollable will persist its current
  /// scroll offset and restore it during state restoration.
  /// 如果提供了恢复ID，可滚动内容将保持其当前滚动偏移量，并在状态恢复期间恢复它。
  ///
  /// The scroll offset is persisted in a [RestorationBucket] claimed from
  /// the surrounding [RestorationScope] using the provided restoration ID.
  /// 滚动偏移量使用提供的恢复ID从周围的[RestorationScope]中声明的[RestorationBucket]中持久化。
  ///
  /// See also:
  ///  * [RestorationManager], which explains how state restoration works in Flutter.
  final String? restorationId;

  /// Defines how this [ScrollView] will dismiss the keyboard automatically.
  /// 定义此[ScrollView]将如何自动关闭键盘。
  ///
  /// Options include:
  /// 选项包括：
  /// - [ScrollViewKeyboardDismissBehavior.manual]: The keyboard is not automatically dismissed.
  ///   键盘不会自动关闭。
  /// - [ScrollViewKeyboardDismissBehavior.onDrag]: The keyboard is dismissed when a drag begins.
  ///   当拖动开始时键盘关闭。
  ///
  /// Defaults to [ScrollViewKeyboardDismissBehavior.manual].
  /// 默认为[ScrollViewKeyboardDismissBehavior.manual]。
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// Determines how content that overflows the grid view should be clipped.
  /// 确定溢出网格视图的内容应如何裁剪。
  ///
  /// Possible values:
  /// 可能的值：
  /// - [Clip.none]: No clipping, content can overflow visibly.
  ///   无裁剪，内容可以可见地溢出。
  /// - [Clip.hardEdge]: Content is clipped with a sharp edge.
  ///   内容以锐利的边缘裁剪。
  /// - [Clip.antiAlias]: Content is clipped with anti-aliasing for smoother edges.
  ///   内容以抗锯齿方式裁剪，边缘更平滑。
  /// - [Clip.antiAliasWithSaveLayer]: Similar to antiAlias but with an intermediate
  ///   save layer, which can be expensive.
  ///   类似于antiAlias但带有中间保存层，这可能会很耗费资源。
  ///
  /// Defaults to [Clip.hardEdge].
  /// 默认为[Clip.hardEdge]。
  final Clip clipBehavior;

  /// Determines when a drag formally begins.
  /// 确定拖动何时正式开始。
  ///
  /// This affects the feedback provided to the user during drag operations.
  /// 这会影响在拖动操作期间向用户提供的反馈。
  ///
  /// Options include:
  /// 选项包括：
  /// - [DragStartBehavior.start]: The drag starts at the position where the pointer first
  ///   contacted the screen.
  ///   拖动从指针首次接触屏幕的位置开始。
  /// - [DragStartBehavior.down]: The drag starts at the position where the pointer was when
  ///   the drag formally began (typically after a certain threshold of movement).
  ///   拖动从拖动正式开始时指针所在的位置开始（通常在移动一定阈值后）。
  ///
  /// Defaults to [DragStartBehavior.start].
  /// 默认为[DragStartBehavior.start]。
  final DragStartBehavior dragStartBehavior;

  /// A custom builder that is for adding items with animations.
  ///
  /// The child argument is the widget that is returned by [itemBuilder],
  ///  and the `animation` is an [Animation] that should be used to animate an enter
  /// transition for the widget that is built.
  ///
  /// If specified, the [enterTransition] will be ignored.
  final AnimatedWidgetBuilder? insertItemBuilder;

  /// A custom builder that is for removing items with animations.
  ///
  /// The child argument is the widget that is returned by [itemBuilder],
  ///  and the `animation` is an [Animation] that should be used to animate an exit
  /// transition for the widget that is built.
  ///
  /// If specified, the [exitTransition] will be ignored.
  final AnimatedWidgetBuilder? removeItemBuilder;

  /// Whether the extent of the scroll view in the scrollDirection should be determined by the contents being viewed.
  /// 滚动视图在滚动方向上的范围是否应由正在查看的内容决定。
  ///
  /// When set to true, the grid view will size itself based on its children rather than
  /// expanding to fill the available space in the scroll direction.
  /// 当设置为true时，网格视图将根据其子项调整大小，而不是在滚动方向上扩展以填充可用空间。
  ///
  /// This can be useful when you have a small grid inside a larger scrollable area,
  /// but it comes with a performance cost as the grid must measure its children before layout.
  /// 当您在较大的可滚动区域内有一个小网格时，这很有用，但它带来了性能成本，因为网格必须在布局前测量其子项。
  ///
  /// Defaults to false.
  /// 默认为false。
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
  final bool Function(E a, E b) isSameItem;

  /// The amount of time to wait before starting the drag operation.
  /// 在开始拖动操作前等待的时间量。
  ///
  /// Set to [Duration.zero] to start the drag operation immediately.
  /// 设置为[Duration.zero]可立即开始拖动操作。
  final Duration dragStartDelay;

  /// A list of items that are not draggable.
  /// 不可拖动的项目列表。
  ///
  /// The item can't be draggable, but it can be reordered.
  /// 项目不能被拖动，但可以被重新排序。
  final List<E> nonDraggableItems;

  /// A list of items that are locked and can't be reordered.
  /// 被锁定且无法重新排序的项目列表。
  final List<E> lockedItems;

  /// Whether to enable swap animation when changing the order of the items.
  /// 更改项目顺序时是否启用交换动画。
  ///
  /// Defaults to true.
  /// 默认为true。
  final bool enableSwap;

  /// Unique identifier for this grid container.
  /// 这个网格容器的唯一标识符。
  /// 这对于跨容器拖放操作特别重要。
  /// 当一个项目从一个容器拖动到另一个容器时，该ID用于识别源容器和目标容器。
  final dynamic containerId;

  /// 是否允许跨容器拖拽和放置。
  ///
  /// 如果为 true，项目可以从该容器拖动到其他容器。
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

  /// Creates a [AnimatedReorderableGridView] that enables users to interactively reorder items through dragging,
  /// with animated insertion and removal of items.
  const AnimatedReorderableGridView(
      {Key? key,
      required this.items,
      required this.itemBuilder,
      required this.sliverGridDelegate,
      required this.onReorder,
      this.enterTransition,
      this.exitTransition,
      this.insertDuration,
      this.removeDuration,
      this.onReorderStart,
      this.onReorderEnd,
      this.proxyDecorator,
      this.padding,
      this.scrollDirection = Axis.vertical,
      this.reverse = false,
      this.controller,
      this.primary,
      this.physics,
      this.scrollBehavior,
      this.restorationId,
      this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
      this.dragStartBehavior = DragStartBehavior.start,
      this.clipBehavior = Clip.hardEdge,
      this.shrinkWrap = false,
      this.insertItemBuilder,
      this.removeItemBuilder,
      required this.isSameItem,
      this.dragStartDelay = const Duration(milliseconds: 500),
      this.nonDraggableItems = const [],
      this.lockedItems = const [],
      this.containerId,
      this.canReceiveItem = false,
      this.canDragOutItem = false,
      this.cacheExtent,
      this.itemDataGetter,
      this.onDragUpdate,
      this.onDragEnd,
      this.enableSwap = true})
      : super(key: key);

  /// The state from the closest instance of this class that encloses the given
  /// context.
  ///
  /// If no [AnimatedReorderableGridViewState] surrounds the given context, then this function
  /// will assert in debug mode and throw an exception in release mode.
  ///
  /// This method can be expensive (it walks the element tree).
  static AnimatedReorderableGridViewState of(BuildContext context) {
    final AnimatedReorderableGridViewState? result =
        context.findAncestorStateOfType<AnimatedReorderableGridViewState>();
    assert(() {
      if (result == null) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
              'AnimatedReorderableGridViewState.of() called with a context that does not contain a AnimatedReorderableGridViewState.'),
          ErrorDescription(
            'No AnimatedReorderableGridViewState ancestor could be found starting from the context that was passed to AnimatedReorderableGridViewState.of().',
          ),
          ErrorHint('This can happen when the context provided is from the same StatefulWidget that '
              'built the AnimatedReorderableGridViewState. '),
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
  /// This method is typically used by [AnimatedReorderableGridViewState] item widgets that insert
  /// or remove items in response to user input.
  ///
  /// If no [AnimatedReorderableGridViewState] surrounds the context given, then this function will
  /// return null.
  ///
  /// This method can be expensive (it walks the element tree).
  static AnimatedReorderableGridViewState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<AnimatedReorderableGridViewState>();
  }

  @override
  State<AnimatedReorderableGridView<E>> createState() => AnimatedReorderableGridViewState();
}

class AnimatedReorderableGridViewState<E extends Object> extends State<AnimatedReorderableGridView<E>> {
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
            sliver: ReorderableAnimatedListImpl.grid(
              items: widget.items,
              itemBuilder: widget.itemBuilder,
              sliverGridDelegate: widget.sliverGridDelegate,
              insertDuration: widget.insertDuration,
              removeDuration: widget.removeDuration,
              enterTransition: widget.enterTransition,
              exitTransition: widget.exitTransition,
              onReorder: widget.onReorder,
              onReorderStart: widget.onReorderStart,
              onReorderEnd: widget.onReorderEnd,
              proxyDecorator: widget.proxyDecorator,
              scrollDirection: widget.scrollDirection,
              insertItemBuilder: widget.insertItemBuilder,
              removeItemBuilder: widget.removeItemBuilder,
              isSameItem: widget.isSameItem,
              dragStartDelay: widget.dragStartDelay,
              nonDraggableItems: widget.nonDraggableItems,
              lockedItems: widget.lockedItems,
              // 添加跨容器拖拽相关属性
              containerId: widget.containerId,
              canReceiveItem: widget.canReceiveItem,
              canDragOutItem: widget.canDragOutItem,
              itemDataGetter: widget.itemDataGetter,
              onDragUpdate: widget.onDragUpdate,
              onDragEnd: widget.onDragEnd,
              enableSwap: widget.enableSwap,
            ),
          ),
        ]);
  }
}
