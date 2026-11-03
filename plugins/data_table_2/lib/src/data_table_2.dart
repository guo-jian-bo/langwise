// 版权所有 2014 Flutter 开发者。保留所有权利。
// 使用此源代码受 BSD 风格许可的约束，该许可可在 LICENSE 文件中找到。

// 版权所有 2021 Maxim Saplin - 对 Flutter 原生 DataTable 实现的更改和修改

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// 是否显示 DataTable 的日志
bool dataTableShowLogs = true;

/// 列的相对大小决定了分配给每个单独列的表格总宽度的份额。
/// 在确定列宽时，S、M 和 L 列之间的比例会保持不变（即大列的宽度设置为中列的 1.2 倍）
/// - 请参阅 [DataTable2.smRatio]、[DataTable2.lmRatio] 以及 [PaginatedDataTable2] 上的相同属性。
/// 默认 S/M 比例为 0.67，L/M 比例为 1.2
enum ColumnSize { S, M, L }

/// 继承自原生 [DataColumn]，通过 [size] 属性增加了设置相对列大小的功能
@immutable
class DataColumn2 extends DataColumn {
  /// 创建 [DataTable2] 列的配置。
  /// [label] 参数不能为空。
  const DataColumn2(
      {required super.label,
      super.tooltip,
      super.numeric = false,
      super.onSort,
      super.headingRowAlignment,
      // 列的相对大小，默认为 M
      this.size = ColumnSize.M,
      // 列的固定宽度（以像素为单位）
      this.fixedWidth});

  /// 列的大小根据可用宽度分配给各个列，同时考虑它们的相对大小（请参阅 [ColumnSize]）
  final ColumnSize size;

  /// 定义列的绝对宽度（以像素为单位），与默认使用的相对大小相反。
  /// 警告：如果宽度大于可用总宽度，其他列可能会被裁剪
  final double? fixedWidth;
}

/// 继承自标准 [DataRow]，增加了行级点击事件。
/// 此外，还有 onSecondaryTap 和 onSecondaryTapDown，这些在 DataCells 中不可用，
/// 在桌面环境中，当需要对右键点击做出反应时可能会很有用。
@immutable
class DataRow2 extends DataRow {
  //DataRow2.fromDataRow(DataRow row) : this.cells = row.cells;

  /// 创建 [DataTable2] 行的配置。
  /// [cells] 参数不能为空。
  const DataRow2(
      {super.key,
      super.selected = false,
      super.onSelectChanged,
      super.color,
      // 应用于给定行的装饰
      this.decoration,
      required super.cells,
      // 特定行的高度
      this.specificRowHeight,
      // 行点击事件处理函数
      this.onTap,
      // 行双击事件处理函数
      this.onDoubleTap,
      super.onLongPress,
      // 行右键点击事件处理函数
      this.onSecondaryTap,
      // 行右键按下事件处理函数
      this.onSecondaryTapDown});

  DataRow2.byIndex(
      {super.index,
      super.selected = false,
      super.onSelectChanged,
      super.color,
      this.decoration,
      required super.cells,
      this.specificRowHeight,
      this.onTap,
      this.onDoubleTap,
      super.onLongPress,
      this.onSecondaryTap,
      this.onSecondaryTapDown})
      : super.byIndex();

  /// 克隆行，如果提供了非空值，则覆盖相应的字段
  DataRow2 clone({
    LocalKey? key,
    bool? selected,
    ValueChanged<bool?>? onSelectChanged,
    WidgetStateProperty<Color?>? color,
    Decoration? decoration,
    List<DataCell>? cells,
    double? specificRowHeight,
    GestureTapCallback? onTap,
    GestureTapCallback? onDoubleTap,
    GestureLongPressCallback? onLongPress,
    GestureTapCallback? onSecondaryTap,
    GestureTapDownCallback? onSecondaryTapDown,
  }) {
    return DataRow2(
      key: key ?? this.key,
      selected: selected ?? this.selected,
      onSelectChanged: onSelectChanged ?? this.onSelectChanged,
      color: color ?? this.color,
      decoration: decoration ?? this.decoration,
      cells: cells ?? this.cells,
      specificRowHeight: specificRowHeight ?? this.specificRowHeight,
      onTap: onTap ?? this.onTap,
      onDoubleTap: onDoubleTap ?? this.onDoubleTap,
      onLongPress: onLongPress ?? this.onLongPress,
      onSecondaryTap: onSecondaryTap ?? this.onSecondaryTap,
      onSecondaryTapDown: onSecondaryTapDown ?? this.onSecondaryTapDown,
    );
  }

  /// 应用于给定行的装饰。当应用此装饰时，[DataTable2.dividerThickness] 将不起作用
  final Decoration? decoration;

  /// 特定行的高度，仅在提供时使用。
  /// 如果未提供，则应用 dataRowHeight。
  final double? specificRowHeight;

  /// 行点击事件处理函数，如果点击的单元格有任何点击事件处理函数，则不会调用此函数
  final GestureTapCallback? onTap;

  /// 行右键点击事件处理函数，如果点击的单元格有任何点击事件处理函数，则不会调用此函数
  final GestureTapCallback? onSecondaryTap;

  /// 行右键按下事件处理函数，如果点击的单元格有任何点击事件处理函数，则不会调用此函数
  final GestureTapDownCallback? onSecondaryTapDown;

  /// 行双击事件处理函数，如果点击的单元格有任何点击事件处理函数，则不会调用此函数
  final GestureTapCallback? onDoubleTap;

// /// 行长按事件处理函数，如果点击的单元格有任何点击事件处理函数，则不会调用此函数
// final GestureLongPressCallback? onLongPress;
}

/// 替代标准 [DataTable] 小部件，模仿其 API。
/// 表头行始终固定，表格的核心（包含数据行）可滚动，并可拉伸以适应其容器的最大宽度/高度。
/// 通过使用 [DataColumn2] 而不是 [DataColumn]，可以控制相对列大小（将其设置为 S、M 和 L）。
/// [DataRow2] 提供行级点击事件处理函数。
class DataTable2 extends DataTable {
  DataTable2({
    super.key,
    required super.columns,
    super.sortColumnIndex,
    super.sortAscending = true,
    super.onSelectAll,
    super.decoration,
    super.dataRowColor,
    // 每一行（不包括包含列标题的行）的高度。
    this.dataRowHeight,
    super.dataTextStyle,
    super.headingRowColor,
    // 固定列的背景颜色
    this.fixedColumnsColor,
    // 左上角固定角的背景颜色
    this.fixedCornerColor,
    super.headingRowHeight,
    super.headingTextStyle,
    // 表头复选框的主题
    this.headingCheckboxTheme,
    // 数据行复选框的主题
    this.datarowCheckboxTheme,
    super.horizontalMargin,
    super.checkboxHorizontalMargin,
    // 复选框的对齐方式
    this.checkboxAlignment = Alignment.center,
    // 表格底部的边距
    this.bottomMargin,
    super.columnSpacing,
    // 是否显示表头复选框
    this.showHeadingCheckBox = true,
    // 新增控制表头复选框可点击的参数
    this.headerCheckboxEnabled = true,
    this.isHeaderCheckbox = true,
    super.showCheckboxColumn = true,
    super.showBottomBorder = false,
    super.dividerThickness,
    super.clipBehavior,
    // 表格的最小宽度
    this.minWidth,
    // 垂直滚动控制器
    this.scrollController,
    // 水平滚动控制器
    this.horizontalScrollController,
    // 是否显示垂直滚动条
    this.isVerticalScrollBarVisible,
    // 是否显示水平滚动条
    this.isHorizontalScrollBarVisible,
    // 数据行为空时显示的占位符小部件
    this.empty,
    // 表格的边框
    this.border,
    // 小列与中列的宽度比例
    this.smRatio = 0.67,
    // 固定在表格顶部的行数
    this.fixedTopRows = 1,
    // 固定在表格左侧的列数
    this.fixedLeftColumns = 0,
    // 大列与中列的宽度比例
    this.lmRatio = 1.2,
    // 排序箭头动画的持续时间
    this.sortArrowAnimationDuration = const Duration(milliseconds: 150),
    // 排序时显示的箭头图标
    this.sortArrowIcon = Icons.arrow_upward,
    // 排序箭头小部件的构建器
    this.sortArrowBuilder,
    // 表头行的装饰
    this.headingRowDecoration,
    required super.rows,
  })  : assert(fixedLeftColumns >= 0),
        assert(fixedTopRows >= 0);

  // 表头行的唯一键
  static final LocalKey _headingRowKey = UniqueKey();

  /// 处理全选操作
  void _handleSelectAll(bool? checked, bool someChecked) {
    // 如果某些复选框已选中，则所有复选框都被选中。否则，
    // 使用新的选中值，但如果为 null 则默认为 false。
    final bool effectiveChecked = someChecked || (checked ?? false);
    if (onSelectAll != null) {
      onSelectAll!(effectiveChecked);
    } else {
      for (final DataRow row in rows) {
        if (row.onSelectChanged != null && row.selected != effectiveChecked) {
          row.onSelectChanged!(effectiveChecked);
        }
      }
    }
  }

  /// 表头行的默认高度
  static const double _headingRowHeight = 56.0;

  /// 表格边缘与每行第一个和最后一个单元格内容之间的默认水平边距
  static const double _horizontalMargin = 24.0;

  /// 每个数据列内容之间的默认水平边距
  static const double _columnSpacing = 56.0;

  /// 表头内容与排序箭头之间的默认填充
  static const double _sortArrowPadding = 2.0;

  /// 默认分隔线厚度
  static const double _dividerThickness = 1.0;

  /// 更改排序方向时，表头中的箭头图标会顺时针旋转。
  /// 此值定义旋转动画的持续时间。
  /// 如果未设置，默认动画持续时间为 150 毫秒。
  final Duration sortArrowAnimationDuration;

  /// 应用排序时要显示的图标。
  /// 如果未设置，默认图标为 [Icons.arrow_upward]。
  /// 设置后，始终覆盖/优先于默认箭头图标。
  final IconData sortArrowIcon;

  /// 排序箭头小部件的构建器。可以与 [sortArrowAlwaysVisible] 结合使用，以实现自定义排序箭头行为。
  /// 如果使用此构建器，[sortArrowIcon] 和 [sortArrowAnimationDuration] 将被忽略。
  final Widget? Function(bool ascending, bool sorted)? sortArrowBuilder;

  /// 如果设置，表格将在达到阈值后停止缩小，并提供水平滚动。
  /// 对于窄屏幕（如竖屏手机方向）和大量列（在空间不足时会混乱）的情况很有用。
  final double? minWidth;

  /// 覆盖显示在表头左上角的复选框的主题（如果启用复选框）
  final CheckboxThemeData? headingCheckboxTheme;

  /// 复选框的对齐方式
  /// 默认值为 [Alignment.center]
  final Alignment checkboxAlignment;

  /// 如果存在复选框列，是否显示表头复选框。默认为 true。
  /// 另请参阅 [DataTable.showCheckboxColumn] 以了解如何控制复选框列的可见性
  final bool showHeadingCheckBox;

  // 新增控制表头复选框可点击的参数
  final bool headerCheckboxEnabled;

  final bool isHeaderCheckbox;

  /// 覆盖显示在每个数据行复选框列中的复选框的主题（如果启用复选框）
  final CheckboxThemeData? datarowCheckboxTheme;

  /// 如果设置，表格将在最后一行之后添加空白空间，并允许将表格的核心向上滚动
  /// （例如，如果您希望在底部有 iOS 导航 UI 重叠表格，并且能够稍微向上滚动底部行以避免遮挡）
  final double? bottomMargin;

  /// 覆盖应用于表头行的默认 [BoxDecoration]（底部边框）。
  /// 当同时提供 [headerRowColor] 和此属性时：
  /// - 如果固定行数为 0 或 1，则 [headingRowDecoration] 优先
  /// - [headerRowColor] 应用于从第二行开始的固定顶部行
  /// 当同时存在固定顶部行和固定左侧列且提供了 [fixedCornerColor] 时，
  /// 此装饰将覆盖左上角单元格的颜色。
  final BoxDecoration? headingRowDecoration;

  /// 每一行（不包括包含列标题的行）的高度。
  ///
  /// 如果为 null，则使用 [DataTableThemeData.dataRowMinHeight]。此值默认为 [kMinInteractiveDimension]，以符合 Material Design 规范。
  ///
  /// 请注意，与 SDK 中的原生 [DataTable] 不同，这里没有定义行的最小/最大高度的功能，相应的属性将被忽略。
  /// 这是为了实现高性能的粘性列而做出的实现权衡。
  @override
  final double? dataRowHeight;

  /// 暴露使数据行垂直滚动的 SingleChildScrollView 的滚动控制器
  final ScrollController? scrollController;

  /// 暴露使数据行水平滚动的 SingleChildScrollView 的滚动控制器
  final ScrollController? horizontalScrollController;

  /// 确定垂直滚动条是否可见，对于 iOS，当为 null 时从 scrollbarTheme 获取值
  final bool? isVerticalScrollBarVisible;

  /// 确定水平滚动条是否可见，对于 iOS，当为 null 时从 scrollbarTheme 获取值
  final bool? isHorizontalScrollBarVisible;

  /// 当数据行为空时显示的占位符小部件。
  /// 该小部件将显示在列下方。
  final Widget? empty;

  /// 设置单元格之间的垂直和水平边框，以及表格周围的外部边框。
  @override
  // 保留字段以保留文档
  // ignore: overridden_fields
  final TableBorder? border;

  /// 确定小列宽度与中列宽度的比例。
  /// 例如，0.5 表示小列的宽度是中列的一半。
  final double smRatio;

  /// 确定大列宽度与中列宽度的比例。
  /// 例如，2.0 表示大列的宽度是中列的两倍。
  final double lmRatio;

  /// 固定在表格顶部的粘性行数。
  /// 表头行被计算/包含在内。
  /// 默认值为 1，表示表头行固定。
  /// 设置为 0 以取消固定表头，
  /// 设置为 >1 以固定数据行
  /// （例如，要同时固定表头和第一行数据，请使用值 2）
  final int fixedTopRows;

  /// 固定在表格左侧的粘性列数。
  /// 复选框列（如果启用）也会被计算在内。
  final int fixedLeftColumns;

  /// 通过 [fixedLeftColumns] 固定的粘性列的背景颜色。
  /// 注意：与数据行不同，数据行的颜色可以根据材料状态（如选中、悬停）改变，
  /// 此颜色是静态的，不会响应状态变化
  /// 注意：要更改固定数据行的背景颜色，请使用 [DataTable2.headingRowColor]
  final Color? fixedColumnsColor;

  /// 当 [fixedTopRows] 和 [fixedLeftColumns] 都大于 0 时，固定的左上角的背景颜色
  /// 注意：与数据行不同，数据行的颜色可以根据材料状态（如选中、悬停）改变，
  /// 此颜色是静态的，不会响应状态变化
  /// 注意：要更改固定数据行的背景颜色，请使用 [DataTable2.headingRowColor]
  final Color? fixedCornerColor;

  /// 获取行的最小和最大高度
  (double, double) getMinMaxRowHeight(DataTableThemeData dataTableTheme) {
    final double effectiveDataRowMinHeight =
        dataRowHeight ?? dataTableTheme.dataRowMinHeight ?? kMinInteractiveDimension;
    // 为了避免粘性列单元格出现问题，将最小/最大高度支持恢复为单行高度值
    // https://github.com/maxim-saplin/data_table_2/issues/191
    // final double effectiveDataRowMaxHeight = dataRowMaxHeight ??
    //     dataTableTheme.dataRowMaxHeight ??
    //     dataTableTheme.dataRowMaxHeight ??
    //     kMinInteractiveDimension;

    return (effectiveDataRowMinHeight, effectiveDataRowMinHeight);
  }

  /// 构建复选框
  Widget _buildCheckbox(
      {required BuildContext context,
      required bool? checked,
      required bool newHeaderCheckboxEnabled,
      required VoidCallback? onRowTap,
      required ValueChanged<bool?>? onCheckboxChanged,
      required WidgetStateProperty<Color?>? overlayColor,
      required CheckboxThemeData? checkboxTheme,
      required bool tristate,
      required double? rowHeight}) {
    final DataTableThemeData dataTableTheme = DataTableTheme.of(context);

    final double effectiveHorizontalMargin =
        horizontalMargin ?? dataTableTheme.horizontalMargin ?? _horizontalMargin;

    final (effectiveDataRowMinHeight, effectiveDataRowMaxHeight) = getMinMaxRowHeight(dataTableTheme);

    /// 将小部件包装在容器中
    Widget wrapInContainer(Widget child) => Container(
        alignment: checkboxAlignment,
        constraints: BoxConstraints(
            minHeight: rowHeight ?? effectiveDataRowMinHeight, maxHeight: rowHeight ?? effectiveDataRowMaxHeight),
        padding: EdgeInsetsDirectional.only(
          start: checkboxHorizontalMargin ?? effectiveHorizontalMargin,
          end: (checkboxHorizontalMargin ?? effectiveHorizontalMargin) / 2.0,
        ),
        child: child);

    Widget contents = Semantics(
      container: true,
      child: wrapInContainer(
        Theme(
            data: ThemeData(checkboxTheme: checkboxTheme),
            child: Checkbox(
              value: checked,
              // 如果表头复选框允许点击, 就执行回调
              // 通过设置value为null,或者不提供onChanged回调, 可以使Checkbox处于禁用状态
              onChanged: newHeaderCheckboxEnabled ? onCheckboxChanged : null,
              tristate: tristate,
            )),
      ),
    );
    if (onRowTap != null) {
      contents = TableRowInkWell(
        onTap: onRowTap,
        overlayColor: overlayColor,
        child: contents,
      );
    }

    return contents;
  }

  /// 构建表头单元格
  Widget _buildHeadingCell(
      {required BuildContext context,
      required EdgeInsetsGeometry padding,
      required Widget label,
      required String? tooltip,
      required bool numeric,
      required VoidCallback? onSort,
      required bool sorted,
      required bool ascending,
      required double effectiveHeadingRowHeight,
      required WidgetStateProperty<Color?>? overlayColor,
      required MainAxisAlignment headingRowAlignment}) {
    final ThemeData themeData = Theme.of(context);

    var customArrows = sortArrowBuilder != null ? sortArrowBuilder!(ascending, sorted) : null;
    label = Row(
      textDirection: numeric ? TextDirection.rtl : null,
      mainAxisAlignment: headingRowAlignment,
      children: <Widget>[
        Flexible(child: label),
        if (onSort != null) ...<Widget>[
          customArrows ??
              _SortArrow(
                visible: sorted,
                up: sorted ? ascending : null,
                duration: sortArrowAnimationDuration,
                sortArrowIcon: sortArrowIcon,
              ),
          const SizedBox(width: _sortArrowPadding),
        ],
      ],
    );

    final TextStyle effectiveHeadingTextStyle =
        headingTextStyle ?? themeData.dataTableTheme.headingTextStyle ?? themeData.textTheme.titleSmall!;

    label = Container(
      padding: padding,
      height: effectiveHeadingRowHeight,
      alignment: numeric ? Alignment.centerRight : AlignmentDirectional.centerStart,
      child: AnimatedDefaultTextStyle(
        style: effectiveHeadingTextStyle,
        softWrap: false,
        duration: sortArrowAnimationDuration,
        child: label,
      ),
    );
    if (tooltip != null) {
      label = Tooltip(
        message: tooltip,
        child: label,
      );
    }

    label = InkWell(
      onTap: onSort,
      overlayColor: overlayColor,
      child: label,
    );
    return label;
  }

  /// 构建数据单元格
  Widget _buildDataCell(
      {required BuildContext context,
      required EdgeInsetsGeometry padding,
      required double? specificRowHeight,
      required Widget label,
      required bool numeric,
      required bool placeholder,
      required bool showEditIcon,
      required GestureTapCallback? onTap,
      required GestureTapCallback? onDoubleTap,
      required GestureLongPressCallback? onLongPress,
      required GestureTapDownCallback? onTapDown,
      required GestureTapCancelCallback? onTapCancel,
      required GestureTapCallback? onRowTap,
      required GestureTapCallback? onRowDoubleTap,
      required GestureLongPressCallback? onRowLongPress,
      required GestureTapCallback? onRowSecondaryTap,
      required GestureTapDownCallback? onRowSecondaryTapDown,
      required VoidCallback? onSelectChanged,
      required WidgetStateProperty<Color?>? overlayColor}) {
    final ThemeData themeData = Theme.of(context);
    final DataTableThemeData dataTableTheme = DataTableTheme.of(context);

    if (showEditIcon) {
      const Widget icon = Icon(Icons.edit, size: 18.0);
      label = Expanded(child: label);
      label = Row(
        textDirection: numeric ? TextDirection.rtl : null,
        children: <Widget>[label, icon],
      );
    }

    final TextStyle effectiveDataTextStyle = dataTextStyle ??
        dataTableTheme.dataTextStyle ??
        themeData.dataTableTheme.dataTextStyle ??
        themeData.textTheme.bodyMedium!;

    final (effectiveDataRowMinHeight, effectiveDataRowMaxHeight) = getMinMaxRowHeight(dataTableTheme);

    label = Container(
      padding: padding,
      constraints: BoxConstraints(
          minHeight: specificRowHeight ?? effectiveDataRowMinHeight,
          maxHeight: specificRowHeight ?? effectiveDataRowMaxHeight),
      alignment: numeric ? Alignment.centerRight : AlignmentDirectional.centerStart,
      child: DefaultTextStyle(
        style: effectiveDataTextStyle.copyWith(
          color: placeholder ? effectiveDataTextStyle.color!.withValues(alpha: 0.6) : null,
        ),
        child: DropdownButtonHideUnderline(child: label),
      ),
    );

    // 如果存在单元格或行级点击事件，则将标签包装在 InkResponse 中
    if (onTap != null || onDoubleTap != null || onLongPress != null || onTapDown != null || onTapCancel != null) {
      // 单元格级
      label = InkWell(
        onTap: () {
          onTap?.call();
          onRowTap?.call();
        },
        onDoubleTap: () {
          onDoubleTap?.call();
          onRowDoubleTap?.call();
        },
        onLongPress: () {
          onLongPress?.call();
          onRowLongPress?.call();
        },
        onTapDown: onTapDown,
        onTapCancel: onTapCancel,
        // 也将行级事件添加到单元格
        onSecondaryTap: onRowSecondaryTap,
        onSecondaryTapDown: onRowSecondaryTapDown,
        overlayColor: overlayColor,
        child: label,
      );
    } else if (onSelectChanged != null ||
        onRowTap != null ||
        onRowDoubleTap != null ||
        onRowLongPress != null ||
        onRowSecondaryTap != null ||
        onRowSecondaryTapDown != null) {
      // 行级
      label = TableRowInkWell(
        onTap: onRowTap ?? onSelectChanged,
        onDoubleTap: onRowDoubleTap,
        onLongPress: onRowLongPress,
        onSecondaryTap: onRowSecondaryTap,
        onSecondaryTapDown: onRowSecondaryTapDown,
        overlayColor: overlayColor,
        child: label,
      );
    }
    return label;
  }

  @override
  Widget build(BuildContext context) {
    var sw = Stopwatch();
    sw.start();
    // assert(!_debugInteractive || debugCheckHasMaterial(context));
    assert(debugCheckHasMaterial(context));

    final theme = Theme.of(context);
    final DataTableThemeData dataTableTheme = DataTableTheme.of(context);
    final effectiveHeadingRowColor = headingRowColor ?? theme.dataTableTheme.headingRowColor;
    final effectiveDataRowColor = dataRowColor ?? theme.dataTableTheme.dataRowColor;
    final defaultRowColor = WidgetStateProperty.resolveWith(
      (Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return theme.colorScheme.primary.withValues(alpha: 0.08);
        }
        return null;
      },
    );
    final anyRowSelectable = rows.any((DataRow row) => row.onSelectChanged != null);
    final displayCheckboxColumn = showCheckboxColumn && anyRowSelectable;
    // 新增控制表头复选框可点击的参数
    final newHeaderCheckboxEnabled = headerCheckboxEnabled;
    // final newIsHeaderCheckbox = isHeaderCheckbox;
    final rowsWithCheckbox =
        displayCheckboxColumn ? rows.where((DataRow row) => row.onSelectChanged != null) : <DataRow2>[];
    final rowsChecked = rowsWithCheckbox.where((DataRow row) => row.selected);
    final allChecked = displayCheckboxColumn && rowsChecked.length == rowsWithCheckbox.length;
    final anyChecked = displayCheckboxColumn && rowsChecked.isNotEmpty;
    final someChecked = anyChecked && !allChecked;
    final effectiveHorizontalMargin =
        horizontalMargin ?? theme.dataTableTheme.horizontalMargin ?? _horizontalMargin;
    final effectiveColumnSpacing = columnSpacing ?? theme.dataTableTheme.columnSpacing ?? _columnSpacing;

    final double effectiveHeadingRowHeight =
        headingRowHeight ?? theme.dataTableTheme.headingRowHeight ?? _headingRowHeight;

    final tableColumnWidths = List<TableColumnWidth>.filled(
        columns.length + (displayCheckboxColumn ? 1 : 0), const _NullTableColumnWidth());

    final headingRow = _buildHeadingRow(context, theme, effectiveHeadingRowColor, tableColumnWidths.length);

    final actualFixedRows = math.max(0, rows.isEmpty ? 0 : math.min(fixedTopRows, rows.length + 1));
    final actualFixedColumns =
        math.max(0, rows.isEmpty ? 0 : math.min(fixedLeftColumns, columns.length + (showCheckboxColumn ? 1 : 0)));

    List<TableRow>? coreRows = rows.isEmpty || actualFixedColumns >= columns.length + (showCheckboxColumn ? 1 : 0)
        ? null
        : _buildTableRows(
            anyRowSelectable,
            effectiveDataRowColor,
            context,
            theme,
            tableColumnWidths.length - actualFixedColumns,
            defaultRowColor,
            actualFixedRows == 0
                ? _buildHeadingRow(
                    context, theme, effectiveHeadingRowColor, tableColumnWidths.length - actualFixedColumns)
                : null,
            actualFixedRows > 0 ? actualFixedRows - 1 : 0);

    List<TableRow>? fixedColumnsRows = rows.isEmpty
        ? null
        : actualFixedColumns > 0
            ? (actualFixedRows < 1
                ? [
                    _buildHeadingRow(
                        context,
                        theme,
                        fixedColumnsColor != null
                            ? WidgetStatePropertyAll(fixedColumnsColor)
                            : effectiveHeadingRowColor,
                        actualFixedColumns),
                    ..._buildTableRows(
                        anyRowSelectable,
                        fixedColumnsColor != null
                            ? WidgetStatePropertyAll(fixedColumnsColor)
                            : effectiveDataRowColor,
                        context,
                        theme,
                        actualFixedColumns,
                        defaultRowColor,
                        null,
                        0,
                        0,
                        true)
                  ]
                : _buildTableRows(
                    anyRowSelectable,
                    fixedColumnsColor != null ? WidgetStatePropertyAll(fixedColumnsColor) : effectiveDataRowColor,
                    context,
                    theme,
                    actualFixedColumns,
                    defaultRowColor,
                    null,
                    actualFixedRows - 1,
                    0,
                    true))
            : null;

    List<TableRow>? fixedRows = actualFixedRows > 0
        ? (actualFixedRows == 1
            ? [
                _buildHeadingRow(context, theme, headingRowColor ?? effectiveHeadingRowColor,
                    tableColumnWidths.length - actualFixedColumns)
              ]
            : [
                _buildHeadingRow(context, theme, headingRowColor ?? effectiveHeadingRowColor,
                    tableColumnWidths.length - actualFixedColumns),
                ..._buildTableRows(
                    anyRowSelectable,
                    headingRowColor ?? effectiveDataRowColor,
                    context,
                    theme,
                    tableColumnWidths.length - actualFixedColumns,
                    defaultRowColor,
                    null,
                    0,
                    actualFixedRows - 1,
                    true)
              ])
        : null;

    List<TableRow>? fixedCornerRows = actualFixedColumns > 0 && actualFixedRows > 0
        ? (actualFixedRows == 1
            ? [
                _buildHeadingRow(
                    context,
                    theme,
                    fixedCornerColor != null ? WidgetStatePropertyAll(fixedCornerColor) : effectiveHeadingRowColor,
                    actualFixedColumns)
              ]
            : [
                _buildHeadingRow(
                    context,
                    theme,
                    fixedCornerColor != null ? WidgetStatePropertyAll(fixedCornerColor) : effectiveHeadingRowColor,
                    actualFixedColumns),
                ..._buildTableRows(
                    anyRowSelectable,
                    fixedCornerColor != null ? WidgetStatePropertyAll(fixedCornerColor) : effectiveDataRowColor,
                    context,
                    theme,
                    actualFixedColumns,
                    defaultRowColor,
                    null,
                    0,
                    actualFixedRows - 1,
                    true)
              ])
        : null;

    double checkBoxWidth = _addCheckBoxes(
        displayCheckboxColumn,
        newHeaderCheckboxEnabled,
        effectiveHorizontalMargin,
        tableColumnWidths,
        headingRow,
        effectiveHeadingRowHeight,
        context,
        someChecked,
        allChecked,
        coreRows,
        fixedRows,
        fixedCornerRows,
        fixedColumnsRows,
        rows,
        actualFixedRows,
        effectiveDataRowColor);

    var builder = LayoutBuilder(builder: (context, constraints) {
      return SyncedScrollControllers(
          scrollController: scrollController,
          sc12toSc11Position: true,
          horizontalScrollController: horizontalScrollController,
          sc22toSc21Position: true,
          builder: (context, sc11, sc12, sc21, sc22) {
            var coreVerticalController = sc11;
            var leftColumnVerticalContoller = sc12;
            var coreHorizontalController = sc21;
            var fixedRowsHorizontalController = sc22;

            var displayColumnIndex = 0;

            // 调整表头和最左侧列中复选框的大小并构建
            // 从列可用的总宽度中减去该宽度

            if (checkBoxWidth > 0) displayColumnIndex += 1;

            // 调整数据列的大小
            // todo 计算总列宽.也就是表格的总宽度
            final widths = _calculateDataColumnSizes(constraints, checkBoxWidth, effectiveHorizontalMargin);

            // 用实际小部件填充创建的行中的空单元格
            for (int dataColumnIndex = 0; dataColumnIndex < columns.length; dataColumnIndex++) {
              final DataColumn column = columns[dataColumnIndex];

              final double paddingStart;
              if (dataColumnIndex == 0 && displayCheckboxColumn) {
                paddingStart = effectiveHorizontalMargin / 2.0;
              } else if (dataColumnIndex == 0 && !displayCheckboxColumn) {
                paddingStart = effectiveHorizontalMargin;
              } else {
                paddingStart = effectiveColumnSpacing / 2.0;
              }

              final double paddingEnd;
              if (dataColumnIndex == columns.length - 1) {
                paddingEnd = effectiveHorizontalMargin;
              } else {
                paddingEnd = effectiveColumnSpacing / 2.0;
              }

              final EdgeInsetsDirectional padding = EdgeInsetsDirectional.only(
                start: paddingStart,
                end: paddingEnd,
              );

              tableColumnWidths[displayColumnIndex] = FixedColumnWidth(widths[dataColumnIndex]);

              var h = _buildHeadingCell(
                context: context,
                padding: padding,
                effectiveHeadingRowHeight: effectiveHeadingRowHeight,
                label: column.label,
                tooltip: column.tooltip,
                numeric: column.numeric,
                onSort: column.onSort != null
                    ? () => column.onSort!(dataColumnIndex, sortColumnIndex != dataColumnIndex || !sortAscending)
                    : null,
                sorted: dataColumnIndex == sortColumnIndex,
                ascending: sortAscending,
                overlayColor: effectiveHeadingRowColor,
                headingRowAlignment:
                    column.headingRowAlignment ?? dataTableTheme.headingRowAlignment ?? MainAxisAlignment.start,
              );

              headingRow.children[displayColumnIndex] =
                  h; // 仅当没有数据行时，单独的表头行用于显示表格标题

              if (displayColumnIndex < actualFixedColumns) {
                if (actualFixedRows < 1) {
                  fixedColumnsRows![0].children[displayColumnIndex] = h;
                } else if (actualFixedRows > 0) {
                  fixedCornerRows![0].children[displayColumnIndex] = h;
                }
              } else {
                if (actualFixedRows < 1 && coreRows != null) {
                  coreRows[0].children[displayColumnIndex - actualFixedColumns] = h;
                } else if (actualFixedRows > 0) {
                  fixedRows![0].children[displayColumnIndex - actualFixedColumns] = h;
                }
              }

              var rowIndex = 0;
              var skipRows = actualFixedRows == 1
                  ? 0
                  : actualFixedRows > 1
                      ? actualFixedRows - 1
                      : -1;

              for (final DataRow row in rows) {
                final DataCell cell = row.cells[dataColumnIndex];

                var c = _buildDataCell(
                    context: context,
                    padding: padding,
                    specificRowHeight: row is DataRow2 ? row.specificRowHeight : null,
                    label: cell.child,
                    numeric: column.numeric,
                    placeholder: cell.placeholder,
                    showEditIcon: cell.showEditIcon,
                    onTap: cell.onTap,
                    onDoubleTap: cell.onDoubleTap,
                    onLongPress: cell.onLongPress,
                    onTapDown: cell.onTapDown,
                    onTapCancel: cell.onTapCancel,
                    onRowTap: row is DataRow2 ? row.onTap : null,
                    onRowDoubleTap: row is DataRow2 ? row.onDoubleTap : null,
                    onRowLongPress: row.onLongPress,
                    onRowSecondaryTap: row is DataRow2 ? row.onSecondaryTap : null,
                    onRowSecondaryTapDown: row is DataRow2 ? row.onSecondaryTapDown : null,
                    onSelectChanged: row.onSelectChanged != null ? () => row.onSelectChanged!(!row.selected) : null,
                    overlayColor: row.color ?? effectiveDataRowColor);

                if (displayColumnIndex < actualFixedColumns) {
                  if (rowIndex + 1 < actualFixedRows) {
                    fixedCornerRows![rowIndex + 1].children[displayColumnIndex] = c;
                  } else {
                    fixedColumnsRows![rowIndex - skipRows].children[displayColumnIndex] = c;
                  }
                } else {
                  if (rowIndex + 1 < actualFixedRows) {
                    fixedRows![rowIndex + 1].children[displayColumnIndex - actualFixedColumns] = c;
                  } else {
                    coreRows![rowIndex - skipRows].children[displayColumnIndex - actualFixedColumns] = c;
                  }
                }

                rowIndex += 1;
              }
              displayColumnIndex += 1;
            }

            var widthsAsMap = tableColumnWidths.asMap();
            Map<int, TableColumnWidth>? leftWidthsAsMap =
                actualFixedColumns > 0 ? tableColumnWidths.take(actualFixedColumns).toList().asMap() : null;
            Map<int, TableColumnWidth>? rightWidthsAsMap =
                actualFixedColumns > 0 ? tableColumnWidths.skip(actualFixedColumns).toList().asMap() : null;

            bool isRowsEmpty(List<TableRow>? rows) {
              return rows == null || rows.isEmpty || rows[0].children.isEmpty;
            }

            var coreTable = Table(
                columnWidths: actualFixedColumns > 0 ? rightWidthsAsMap : widthsAsMap,
                children: coreRows ?? [],
                border: border == null
                    ? null
                    : isRowsEmpty(fixedRows) && isRowsEmpty(fixedColumnsRows)
                        ? border
                        : !isRowsEmpty(fixedRows) && !isRowsEmpty(fixedColumnsRows)
                            ? TableBorder(
                                //top: border!.top,
                                //left: border!.left,
                                right: border!.right,
                                bottom: border!.bottom,
                                verticalInside: border!.verticalInside,
                                horizontalInside: border!.horizontalInside,
                                borderRadius: border!.borderRadius)
                            : isRowsEmpty(fixedRows)
                                ? TableBorder(
                                    top: border!.top,
                                    //left: border!.left,
                                    right: border!.right,
                                    bottom: border!.bottom,
                                    verticalInside: border!.verticalInside,
                                    horizontalInside: border!.horizontalInside,
                                    borderRadius: border!.borderRadius)
                                : TableBorder(
                                    //top: border!.top,
                                    left: border!.left,
                                    right: border!.right,
                                    bottom: border!.bottom,
                                    verticalInside: border!.verticalInside,
                                    horizontalInside: border!.horizontalInside,
                                    borderRadius: border!.borderRadius));

            Table? fixedRowsTabel;
            Table? fixedColumnsTable;
            Table? fixedTopLeftCornerTable;
            Widget? fixedColumnAndCornerCol;
            Widget? fixedRowsAndCoreCol;

            if (rows.isNotEmpty) {
              if (fixedRows != null &&
                  !isRowsEmpty(fixedRows) &&
                  actualFixedColumns < columns.length + (showCheckboxColumn ? 1 : 0)) {
                fixedRowsTabel = Table(
                    columnWidths: actualFixedColumns > 0 ? rightWidthsAsMap : widthsAsMap,
                    children: fixedRows,
                    border: border == null
                        ? null
                        : isRowsEmpty(fixedCornerRows)
                            ? border
                            : TableBorder(
                                top: border!.top,
                                //left: border!.left,
                                right: border!.right,
                                bottom: border!.bottom,
                                verticalInside: border!.verticalInside,
                                horizontalInside: border!.horizontalInside,
                                borderRadius: border!.borderRadius));
              }

              if (fixedColumnsRows != null && !isRowsEmpty(fixedColumnsRows)) {
                fixedColumnsTable = Table(
                    columnWidths: leftWidthsAsMap,
                    children: fixedColumnsRows,
                    border: border == null
                        ? null
                        : isRowsEmpty(fixedCornerRows)
                            ? border
                            : TableBorder(
                                //top: border!.top,
                                left: border!.left,
                                right: border!.right,
                                bottom: border!.bottom,
                                verticalInside: border!.verticalInside,
                                horizontalInside: border!.horizontalInside,
                                borderRadius: border!.borderRadius));
              }

              if (fixedCornerRows != null && !isRowsEmpty(fixedCornerRows)) {
                fixedTopLeftCornerTable =
                    Table(columnWidths: leftWidthsAsMap, children: fixedCornerRows, border: border);
              }

              Widget addBottomMargin(Table t) => bottomMargin != null && bottomMargin! > 0
                  ? Column(mainAxisSize: MainAxisSize.min, children: [t, SizedBox(height: bottomMargin!)])
                  : t;

              var scrollBarTheme = Theme.of(context).scrollbarTheme;
              // flutter/lib/src/material/scrollbar.dart, scrollbar决定whther to create  Cupertino or Material scrollbar, Cupertino ignores themes
              var isiOS = Theme.of(context).platform == TargetPlatform.iOS;

              // For iOS/Cupertino scrollbar
              fixedRowsAndCoreCol = Scrollbar(
                  thumbVisibility: isHorizontalScrollBarVisible ??
                      (isiOS ? scrollBarTheme.thumbVisibility?.resolve({WidgetState.hovered}) : null),
                  thickness: (isiOS ? scrollBarTheme.thickness?.resolve({WidgetState.hovered}) : null),
                  controller: coreHorizontalController,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                        child: SingleChildScrollView(
                            controller: fixedRowsHorizontalController,
                            scrollDirection: Axis.horizontal,
                            child: (fixedRowsTabel != null)
                                ? fixedRowsTabel
                                // WOrkaround for a bug when there's no horizontal scrollbar should there be no this SingleChildScrollView. I.e. originally this part was ommited and not scrollable was added to the column if not fixed top row was visible
                                : SizedBox(
                                    height: 0,
                                    width: widths.fold<double>(0, (previousValue, value) => previousValue + value),
                                  ))),
                    Flexible(
                        fit: FlexFit.tight,
                        child: Scrollbar(
                            thumbVisibility: isVerticalScrollBarVisible ??
                                (isiOS ? scrollBarTheme.thumbVisibility?.resolve({WidgetState.hovered}) : null),
                            thickness: (isiOS ? scrollBarTheme.thickness?.resolve({WidgetState.hovered}) : null),
                            controller: coreVerticalController,
                            child: SingleChildScrollView(
                                controller: coreVerticalController,
                                scrollDirection: Axis.vertical,
                                child: SingleChildScrollView(
                                    controller: coreHorizontalController,
                                    scrollDirection: Axis.horizontal,
                                    child: addBottomMargin(coreTable)))))
                  ]));

              fixedColumnAndCornerCol = fixedTopLeftCornerTable == null && fixedColumnsTable == null
                  ? null
                  : Column(mainAxisSize: MainAxisSize.min, children: [
                      if (fixedTopLeftCornerTable != null) fixedTopLeftCornerTable,
                      if (fixedColumnsTable != null)
                        Flexible(
                            fit: FlexFit.loose,
                            child: ScrollConfiguration(
                                behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                                child: SingleChildScrollView(
                                    controller: leftColumnVerticalContoller,
                                    scrollDirection: Axis.vertical,
                                    child: addBottomMargin(fixedColumnsTable))))
                    ]);
            }

            var completeWidget = Container(
                decoration: decoration ?? theme.dataTableTheme.decoration,
                child: Material(
                    type: MaterialType.transparency,
                    borderRadius: border?.borderRadius,
                    clipBehavior: clipBehavior,
                    child: rows.isEmpty
                        ? Column(children: [
                            SingleChildScrollView(
                                controller: coreHorizontalController,
                                scrollDirection: Axis.horizontal,
                                child: Table(columnWidths: widthsAsMap, border: border, children: [headingRow])),
                            Flexible(fit: FlexFit.tight, child: empty ?? const SizedBox())
                          ])
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (fixedColumnAndCornerCol != null) fixedColumnAndCornerCol,
                              if (fixedRowsAndCoreCol != null)
                                Flexible(fit: FlexFit.tight, child: fixedRowsAndCoreCol)
                            ],
                          )));

            return completeWidget;
          });
    });

    sw.stop();

    if (dataTableShowLogs && kDebugMode) {
      debugPrint('DataTable2 built: ${sw.elapsedMilliseconds}ms');
    }

    return builder;
  }

  /// 添加复选框
  double _addCheckBoxes(
      bool displayCheckboxColumn,
      bool newHeaderCheckboxEnabled,
      double effectiveHorizontalMargin,
      List<TableColumnWidth> tableColumns,
      TableRow headingRow,
      double headingHeight,
      BuildContext context,
      bool someChecked,
      bool allChecked,
      List<TableRow>? coreRows,
      List<TableRow>? fixedRows,
      List<TableRow>? fixedCornerRows,
      List<TableRow>? fixedColumnRows,
      List<DataRow> rows,
      int actualFixedRows,
      WidgetStateProperty<Color?>? effectiveDataRowColor) {
    double checkBoxWidth = 0;

    if (displayCheckboxColumn) {
      checkBoxWidth = effectiveHorizontalMargin + Checkbox.width + effectiveHorizontalMargin / 2.0;
      tableColumns[0] = FixedColumnWidth(checkBoxWidth);

      // 创建表头两次，一次用于没有数据的情况，另一次用于 xxx_rows 表

      // 显示表头复选框时, 添加一列
      headingRow.children[0] = showHeadingCheckBox
          ? _buildCheckbox(
              context: context,
              checked: someChecked ? null : allChecked,
              newHeaderCheckboxEnabled: newHeaderCheckboxEnabled,
              onRowTap: null,
              // 全选
              onCheckboxChanged: (bool? checked) => _handleSelectAll(checked, someChecked),
              overlayColor: null,
              checkboxTheme: headingCheckboxTheme,
              tristate: true,
              rowHeight: headingHeight)
          : SizedBox(
              height: headingHeight,
            );

      if (fixedCornerRows != null) {
        fixedCornerRows[0].children[0] = headingRow.children[0];
      } else if (fixedColumnRows != null) {
        fixedColumnRows[0].children[0] = headingRow.children[0];
      } else if (fixedRows != null) {
        fixedRows[0].children[0] = headingRow.children[0];
      } else {
        coreRows![0].children[0] = headingRow.children[0];
      }

      var skipRows = actualFixedRows == 1
          ? 0
          : actualFixedRows > 1
              ? actualFixedRows - 1
              : -1;

      var rowIndex = 0;
      // 设置每一行的复选框
      for (final DataRow row in rows) {
        var x = _buildCheckbox(
            context: context,
            checked: row.selected,
            newHeaderCheckboxEnabled: true,
            onRowTap: () {
              if (row is DataRow2 && row.onTap != null) {
                row.onTap?.call();
              } else {
                row.onSelectChanged?.call(!row.selected);
              }
            },
            onCheckboxChanged: row.onSelectChanged,
            overlayColor: row.color ?? effectiveDataRowColor,
            checkboxTheme: datarowCheckboxTheme,
            tristate: false,
            rowHeight: rows[rowIndex] is DataRow2 ? (rows[rowIndex] as DataRow2).specificRowHeight : null);

        if (fixedCornerRows != null && rowIndex < fixedCornerRows.length - 1) {
          fixedCornerRows[rowIndex + 1].children[0] = x;
        } else if (fixedColumnRows != null) {
          fixedColumnRows[rowIndex - skipRows].children[0] = x;
        } else if (fixedRows != null && rowIndex < fixedRows.length - 1) {
          fixedRows[rowIndex + 1].children[0] = x;
        } else {
          coreRows![rowIndex - skipRows].children[0] = x;
        }

        rowIndex += 1;
      }
    }
    return checkBoxWidth;
  }

  /// 计算数据列的大小
  List<double> _calculateDataColumnSizes(
      BoxConstraints constraints, double checkBoxWidth, double effectiveHorizontalMargin) {
    var totalColAvailableWidth = constraints.maxWidth;
    if (minWidth != null && totalColAvailableWidth < minWidth!) {
      totalColAvailableWidth = minWidth!;
    }

    // 当不存在复选框列时，全边距添加到侧边列宽度；
    // 当存在复选框列时，半边距添加到第一列数据列宽度，全边距添加到右侧

    totalColAvailableWidth = totalColAvailableWidth -
        checkBoxWidth -
        effectiveHorizontalMargin -
        (checkBoxWidth > 0 ? effectiveHorizontalMargin / 2 : effectiveHorizontalMargin);

    var columnWidth = totalColAvailableWidth / columns.length;
    var totalColCalculatedWidth = 0.0;
    var totalFixedWidth = columns.fold<double>(
        0.0,
        (previousValue, element) =>
            previousValue + (element is DataColumn2 && element.fixedWidth != null ? element.fixedWidth! : 0.0));

    assert(totalFixedWidth < totalColAvailableWidth,
        "DataTable2, combined width of columns of fixed width is greater than availble parent width. Table will be clipped");

    totalColAvailableWidth = math.max(0.0, totalColAvailableWidth - totalFixedWidth);

    // 根据 S、M、L 调整列大小
    final widths = List<double>.generate(columns.length, (i) {
      var w = columnWidth;
      var column = columns[i];
      if (column is DataColumn2) {
        if (column.fixedWidth != null) {
          w = column.fixedWidth!;
        } else if (column.size == ColumnSize.S) {
          w *= smRatio;
        } else if (column.size == ColumnSize.L) {
          w *= lmRatio;
        }
      }

      // 跳过固定宽度的列
      if (!(column is DataColumn2 && column.fixedWidth != null)) {
        totalColCalculatedWidth += w;
      }
      return w;
    });

    // 缩放列以适应可用宽度
    var ratio = totalColAvailableWidth / totalColCalculatedWidth;
    for (var i = 0; i < widths.length; i++) {
      // 跳过固定宽度的列
      if (!(columns[i] is DataColumn2 && (columns[i] as DataColumn2).fixedWidth != null)) {
        widths[i] *= ratio;
      }
    }

    // 向侧边列添加边距
    if (widths.length == 1) {
      widths[0] = math.max(
          0,
          widths[0] +
              effectiveHorizontalMargin +
              (checkBoxWidth > 0 ? effectiveHorizontalMargin / 2 : effectiveHorizontalMargin));
    } else if (widths.length > 1) {
      widths[0] =
          math.max(0, widths[0] + (checkBoxWidth > 0 ? effectiveHorizontalMargin / 2 : effectiveHorizontalMargin));
      widths[widths.length - 1] = math.max(0, widths[widths.length - 1] + effectiveHorizontalMargin);
    }
    return widths;
  }

  /// 构建表格行
  List<TableRow> _buildTableRows(
      bool anyRowSelectable,
      WidgetStateProperty<Color?>? effectiveDataRowColor,
      BuildContext context,
      ThemeData theme,
      int numberOfCols,
      WidgetStateProperty<Color?> defaultRowColor,
      TableRow? headingRow,
      [int skipRows = 0,
      int takeRows = 0,
      bool forceEffectiveDataRowColor = false]) {
    final rowStartIndex = skipRows;
    final List<TableRow> tableRows = List<TableRow>.generate(
      (takeRows <= 0 ? rows.length - skipRows : takeRows) + (headingRow == null ? 0 : 1),
      (int index) {
        var actualIndex = headingRow == null ? index : index - 1;
        if (headingRow != null && index == 0) {
          return headingRow;
        } else {
          final bool isSelected = rows[rowStartIndex + actualIndex].selected;
          final bool isDisabled = anyRowSelectable && rows[rowStartIndex + actualIndex].onSelectChanged == null;
          final Set<WidgetState> states = <WidgetState>{
            if (isSelected) WidgetState.selected,
            if (isDisabled) WidgetState.disabled,
          };
          final Color? resolvedDataRowColor = (forceEffectiveDataRowColor
                  ? effectiveDataRowColor
                  : (rows[rowStartIndex + actualIndex].color ?? effectiveDataRowColor))
              ?.resolve(states);
          final Color? rowColor = resolvedDataRowColor;

          final BorderSide borderSide = Divider.createBorderSide(
            context,
            width: dividerThickness ?? theme.dataTableTheme.dividerThickness ?? _dividerThickness,
          );
          final Border border = showBottomBorder ? Border(bottom: borderSide) : Border(top: borderSide);

          Decoration? rowDecoration = rows[rowStartIndex + actualIndex] is DataRow2
              ? (rows[rowStartIndex + actualIndex] as DataRow2).decoration
              : null;

          return TableRow(
            key: rows[rowStartIndex + actualIndex].key,
            decoration: rowDecoration ??
                BoxDecoration(
                  // Changed standard behaviour to never add border should the thickness be 0
                  border: dividerThickness == null || (dividerThickness != null && dividerThickness != 0.0)
                      ? border
                      : null,
                  color: rowColor ?? defaultRowColor.resolve(states),
                ),
            children: List<Widget>.filled(numberOfCols <= 0 ? numberOfCols : numberOfCols, const _NullWidget()),
          );
        }
      },
    );

    return tableRows;
  }

  /// 构建表头行
  TableRow _buildHeadingRow(BuildContext context, ThemeData theme,
      WidgetStateProperty<Color?>? effectiveHeadingRowColor, int numberOfCols) {
    var headingRow = TableRow(
      key: _headingRowKey,
      decoration: BoxDecoration(
        // Changed standard behaviour to never add border should the thickness be 0
        border: showBottomBorder &&
                border == null &&
                (dividerThickness == null || (dividerThickness != null && dividerThickness != 0.0))
            ? Border(
                bottom: Divider.createBorderSide(
                context,
                width: dividerThickness ?? theme.dataTableTheme.dividerThickness ?? _dividerThickness,
              ))
            : null,
        color: effectiveHeadingRowColor?.resolve(<WidgetState>{}),
      ).copyWith(
        color: headingRowDecoration?.color,
        image: headingRowDecoration?.image,
        border: headingRowDecoration?.border,
        borderRadius: headingRowDecoration?.borderRadius,
        boxShadow: headingRowDecoration?.boxShadow,
        gradient: headingRowDecoration?.gradient,
        backgroundBlendMode: headingRowDecoration?.backgroundBlendMode,
        shape: headingRowDecoration?.shape,
      ),
      children: List<Widget>.filled(numberOfCols, const _NullWidget()),
    );
    return headingRow;
  }
}

/// 排序箭头小部件
class _SortArrow extends StatefulWidget {
  const _SortArrow({
    required this.visible,
    required this.up,
    required this.duration,
    required this.sortArrowIcon,
  });

  // 箭头是否可见
  final bool visible;

  // 箭头是否向上
  final bool? up;

  // 动画持续时间
  final Duration duration;

  // 排序箭头图标
  final IconData sortArrowIcon;

  @override
  _SortArrowState createState() => _SortArrowState();
}

class _SortArrowState extends State<_SortArrow> with TickerProviderStateMixin {
  // 透明度动画控制器
  late AnimationController _opacityController;
  // 透明度动画
  late Animation<double> _opacityAnimation;

  // 方向动画控制器
  late AnimationController _orientationController;
  // 方向动画
  late Animation<double> _orientationAnimation;
  // 方向偏移量
  double _orientationOffset = 0.0;

  // 箭头是否向上
  bool? _up;

  // 旋转动画
  static final Animatable<double> _turnTween =
      Tween<double>(begin: 0.0, end: math.pi).chain(CurveTween(curve: Curves.easeIn));

  @override
  void initState() {
    super.initState();
    _up = widget.up;
    _opacityAnimation = CurvedAnimation(
      parent: _opacityController = AnimationController(
        duration: widget.duration,
        vsync: this,
      ),
      curve: Curves.fastOutSlowIn,
    )..addListener(_rebuild);
    _opacityController.value = widget.visible ? 1.0 : 0.0;
    _orientationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _orientationAnimation = _orientationController.drive(_turnTween)
      ..addListener(_rebuild)
      ..addStatusListener(_resetOrientationAnimation);
    if (widget.visible) _orientationOffset = widget.up! ? 0.0 : math.pi;
  }

  /// 重建状态
  void _rebuild() {
    setState(() {
      // 动画改变，需要重建
    });
  }

  /// 重置方向动画
  void _resetOrientationAnimation(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      assert(_orientationAnimation.value == math.pi);
      _orientationOffset += math.pi;
      _orientationController.value = 0.0;
    }
  }

  @override
  void didUpdateWidget(_SortArrow oldWidget) {
    super.didUpdateWidget(oldWidget);
    bool skipArrow = false;
    final bool? newUp = widget.up ?? _up;
    if (oldWidget.visible != widget.visible) {
      if (widget.visible && (_opacityController.status == AnimationStatus.dismissed)) {
        _orientationController.stop();
        _orientationController.value = 0.0;
        _orientationOffset = newUp! ? 0.0 : math.pi;
        skipArrow = true;
      }
      if (widget.visible) {
        _opacityController.forward();
      } else {
        _opacityController.reverse();
      }
    }
    if ((_up != newUp) && !skipArrow) {
      if (_orientationController.status == AnimationStatus.dismissed) {
        _orientationController.forward();
      } else {
        _orientationController.reverse();
      }
    }
    _up = newUp;
  }

  @override
  void dispose() {
    _opacityController.dispose();
    _orientationController.dispose();
    super.dispose();
  }

  // 箭头图标基线偏移量
  static const double _arrowIconBaselineOffset = -1.5;
  // 箭头图标大小
  static const double _arrowIconSize = 16.0;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _opacityAnimation.value,
      child: Transform(
        transform: Matrix4.rotationZ(_orientationOffset + _orientationAnimation.value)
          ..setTranslationRaw(0.0, _arrowIconBaselineOffset, 0.0),
        alignment: Alignment.center,
        child: Icon(
          widget.sortArrowIcon,
          size: _arrowIconSize,
        ),
      ),
    );
  }
}

// coverage:ignore-start
class _NullTableColumnWidth extends TableColumnWidth {
  const _NullTableColumnWidth();

  @override
  double maxIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) => throw UnimplementedError();

  @override
  double minIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) => throw UnimplementedError();
}

class _NullWidget extends Widget {
  const _NullWidget();

  @override
  Element createElement() => throw UnimplementedError();
}
// coverage:ignore-end

/// 创建成对的滚动控制器，可提供给可滚动组件，确保一个可滚动组件的偏移量变化会同步到另一个可滚动组件（反之亦然）
/// iOS 上存在一个关于弹性滚动的 bug（或特性），当可滚动组件处于弹性滚动位置时，可滚动组件会失去同步
class SyncedScrollControllers extends StatefulWidget {
  const SyncedScrollControllers(
      {super.key,
      required this.builder,
      // 垂直滚动控制器
      this.scrollController,
      // 是否将 sc12 的初始偏移量设置为 sc11 的值
      this.sc12toSc11Position = false,
      // 水平滚动控制器
      this.horizontalScrollController,
      // 是否将 sc22 的初始偏移量设置为 sc21 的值
      this.sc22toSc21Position = false});

  /// 其中一个控制器（sc11）不会由这个小部件创建
  /// 而是使用外部提供的控制器
  final ScrollController? scrollController;

  /// 其中一个控制器（sc21）不会由这个小部件创建
  /// 而是使用外部提供的控制器
  final ScrollController? horizontalScrollController;

  /// 是否将 sc12 的初始偏移量设置为 sc11 的值
  final bool sc12toSc11Position;

  /// 是否将 sc22 的初始偏移量设置为 sc21 的值
  final bool sc22toSc21Position;

  /// 两对滚动控制器（sc11|sc12 和 sc21|sc22）的位置将同步，
  /// 附加的可滚动组件将复制位置
  final Widget Function(BuildContext context, ScrollController sc11, ScrollController sc12, ScrollController sc21,
      ScrollController sc22) builder;

  @override
  SyncedScrollControllersState createState() => SyncedScrollControllersState();
}

class SyncedScrollControllersState extends State<SyncedScrollControllers> {
  // 垂直滚动控制器 1
  ScrollController? _sc11;
  // 垂直滚动控制器 2
  late ScrollController _sc12;
  // 水平滚动控制器 1
  ScrollController? _sc21;
  // 水平滚动控制器 2
  late ScrollController _sc22;

  // 监听器列表
  final List<void Function()> _listeners = [];

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void didUpdateWidget(SyncedScrollControllers oldWidget) {
    super.didUpdateWidget(oldWidget);
    _disposeOrUnsubscribe();
    _initControllers();
  }

  @override
  void dispose() {
    _disposeOrUnsubscribe();
    super.dispose();
  }

  /// 初始化控制器
  void _initControllers() {
    _doNotReissueJump.clear();
    var offset = _sc11 == null || _sc11!.positions.isEmpty ? 0.0 : _sc11!.offset;
    if (widget.scrollController != null) {
      _sc11 = widget.scrollController!;
      if (_sc11!.positions.isNotEmpty) {
        offset = _sc11!.offset;
      }
    } else {
      _sc11 = ScrollController();
    }

    var horizontalOffset = _sc21 == null || _sc21!.positions.isEmpty ? 0.0 : _sc21!.offset;
    if (widget.horizontalScrollController != null) {
      _sc21 = widget.horizontalScrollController!;
      if (_sc21!.positions.isNotEmpty) {
        offset = _sc21!.offset;
      }
    } else {
      _sc21 = ScrollController();
    }

    _sc12 = ScrollController(initialScrollOffset: widget.sc12toSc11Position ? offset : 0.0);
    _sc22 = ScrollController(initialScrollOffset: widget.sc22toSc21Position ? horizontalOffset : 0.0);

    _syncScrollControllers(_sc11!, _sc12);
    _syncScrollControllers(_sc21!, _sc22);
  }

  /// 释放或取消订阅控制器
  void _disposeOrUnsubscribe() {
    if (widget.scrollController == _sc11) {
      _sc11?.removeListener(_listeners[0]);
    } else {
      _sc11?.dispose();
    }
    _sc12.dispose();

    if (widget.horizontalScrollController == _sc21) {
      _sc21?.removeListener(_listeners[0]);
    } else {
      _sc21?.dispose();
    }
    _sc22.dispose();

    _listeners.clear();
  }

  // 避免重复跳转的映射
  final Map<ScrollController, bool> _doNotReissueJump = {};

  /// 同步滚动控制器
  void _syncScrollControllers(ScrollController sc1, ScrollController sc2) {
    var l = () => _jumpToNoCascade(sc1, sc2);
    sc1.addListener(l);
    _listeners.add(l);
    l = () => _jumpToNoCascade(sc2, sc1);
    sc2.addListener(l);
  }

  /// 无级联跳转
  void _jumpToNoCascade(ScrollController master, ScrollController slave) {
    //print('$master $slave');
    if (!slave.hasClients || slave.position.outOfRange) {
      return; // 处理弹性滚动的情况，bug #113
    }
    if (_doNotReissueJump[master] == null || _doNotReissueJump[master]! == false) {
      _doNotReissueJump[slave] = true;
      slave.jumpTo(master.offset);
    } else {
      _doNotReissueJump[master] = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _sc11!, _sc12, _sc21!, _sc22);
}