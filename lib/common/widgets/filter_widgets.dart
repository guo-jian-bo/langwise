import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../theme/theme.dart';
import '../entities/entities.dart';
import 'widgets.dart';

enum FilterSortDirection {
  up,
  down,
}

/// 筛选排序
class FilterSortsData {
  String title;
  List<FilterSortsItem> sorts;

  FilterSortsData({
    required this.title,
    required this.sorts,
  });
}

class FilterSortsItem {
  String name;
  bool selected;
  bool isDefault;
  FilterSortDirection direction;

  FilterSortsItem({
    required this.name,
    this.selected = false,
    this.isDefault = false,
    this.direction = FilterSortDirection.up,
  });
}

/// 筛选条件
class FilterConditionsData {
  String title;
  List<FilterConditionsItem> conditions;

  /// 是否是单选，默认是单选
  bool isSingle;
  String? component;
  String? filterGroup;
  bool radioGroup;
  Color? color;
  bool Function(Map<String, FilterConditionsData> conditions)? visibleWhen;

  FilterConditionsData({
    required this.title,
    required this.conditions,
    this.isSingle = true,
    this.component,
    this.filterGroup,
    this.radioGroup = false,
    this.color,
    this.visibleWhen,
  });
}

class FilterConditionsItem {
  String name;
  dynamic value;
  bool selected;

  FilterConditionsItem({
    required this.name,
    required this.value,
    this.selected = false,
  });
}

/// 搜索 搜索
class FilterSearchsData {
  TextEditingController controller;
  String title;
  String? hintText;

  /// 是否以逗号分隔
  bool isCommaSeparated;

  FilterSearchsData({
    required this.controller,
    required this.title,
    this.hintText,
    this.isCommaSeparated = false,
  });
}

/// 定位数据
class FilterLocateData{
  String name;
  GlobalKey key;
  dynamic value;

  FilterLocateData({
    required this.name,
    required this.key,
    this.value,
  });
}


class FilterStripWidget extends StatefulWidget {
  /// 筛选排序
  final Map<String, FilterSortsData>? sorts;

  /// 筛选条件
  final Map<String, FilterConditionsData>? conditions;

  /// 搜索
  final Map<String, FilterSearchsData>? searchs;

  /// 定位数据
  final List<FilterLocateData>? locates;

  /// 定位索引
  final int locateIndex;

  /// 定位组件的基础保留宽度，默认500.wMin。
  ///
  /// 当筛选组件内容较少且剩余空间充足时，定位组件实际宽度可以超过该值；
  /// 当筛选组件内容较多时，定位组件会优先保留该宽度。
  final double? locateMinWidth;

  /// 宽度
  final double? width;

  /// 筛选排序回调
  final void Function(Map<String, FilterSortsData> sorts)? onSorts;

  /// 筛选条件回调
  final void Function(Map<String, FilterConditionsData> conditions)? onConditions;

  /// 搜索提交回调
  final void Function()? onSearch;

  /// 清空单个搜索的搜索框回调
  final void Function()? onSingleClearSearch;

  /// 单个搜索框的宽度
  final double? searchSingleWidth;

  /// 结尾的文字，在搜索框之前。（可以展示提示/数量等）
  final String? endText;

  /// 开头的文字，在排序按钮之前。（可以展示提示/数量等）
  final String? startText;

  /// 重置所有排序和筛选条件回调
  final void Function(Map<String, FilterSortsData> sorts, Map<String, FilterConditionsData> conditions)? onReset;

  /// 定位回调
  final void Function(FilterLocateData locate, int index)? onLocate;

  /// * 筛选浮动条
  /// * 筛选排序回调
  /// * 筛选条件回调
  /// * 搜索提交回调
  /// * 重置所有排序和筛选条件回调
  /// * 定位切换回调
  ///
  /// ```
  /// //使用方法：
  ///
  /// 1: 定义筛选排序、筛选条件、搜索条件、定位条件
  ///  // 排序条件
  ///  Map<String, FilterSortsData> filterSorts = {
  ///   "uid": FilterSortsData( // 使用要查询的参数名作为key
  ///     title: "uid", // 标题
  ///     sorts: [ // 排序列表
  ///       FilterSortsItem(name: "uid从小到大", direction: FilterSortDirection.up, selected: true, isDefault: true), // selected=默认选中；isDefault=默认排序，重置会把排序重置到此项
  ///       FilterSortsItem(name: "uid从大到小", direction: FilterSortDirection.down),
  ///     ],
  ///   ),
  ///  };
  ///
  /// // 筛选条件
  ///  Map<String, FilterConditionsData> filterConditions = {
  ///   "checked": FilterConditionsData( // 使用要查询的参数名作为key
  ///     title: "审核状态", // 标题
  ///     conditions: [ // 筛选条件列表
  ///       FilterConditionsItem(name: "已审核", value: true), // name=显示的名称，value=实际参数
  ///       FilterConditionsItem(name: "未审核", value: false),
  ///     ],
  ///   ),
  /// };
  ///  // 搜索条件
  ///  Map<String, FilterSearchsData> filterSearchs = {
  ///   "uid": FilterSearchsData( // 使用要查询的参数名作为key
  ///     title: "uid", // 标题
  ///     hintText: "uid", // 提示文字
  ///     controller: TextEditingController(), // 搜索框控制器
  ///     isCommaSeparated: true, // 是否以逗号分隔 获取参数的时候会根据中英文逗号分隔为数组
  ///   ),
  /// };
  ///
  /// // 定位组件
  /// final List<FilterLocateData> filterLocates = [
  ///   FilterLocateData(
  ///     name: "一年级",
  ///     key: GlobalKey(),
  ///   ),
  ///   FilterLocateData(
  ///     name: "二年级",
  ///     key: GlobalKey(),
  ///   ),
  ///   FilterLocateData(
  ///     name: "三年级",
  ///     key: GlobalKey(),
  ///   ),
  /// ];
  ///
  /// 2：在view中使用FilterStripWidget
  /// FilterStripWidget(
  ///   sorts: {...controller.filterSorts}, // 排序条件 不传则不现实对应widget
  ///   conditions: {...controller.filterConditions}, // 筛选条件 不传则不现实对应widget
  ///   searchs: controller.filterSearchs, // 搜索条件 不传则不现实对应widget
  ///   locates: controller.filterLocates, // 定位条件 不传则不显示对应widget
  ///   locateIndex: controller.locateIndex.value, // 当前定位选中索引
  ///   locateMinWidth: 500.wMin, // 定位组件基础保留宽度，空间充足时可继续变宽
  ///   onSorts: (sorts) { // 排序条件回调
  ///     controller.filterSorts.value = sorts;
  ///     // 随后刷新数据
  ///   },
  ///   onConditions: (conditions) { // 筛选条件回调
  ///     controller.filterConditions.value = conditions;
  ///     // 随后刷新数据
  ///   },
  ///   onReset: (sorts, conditions) { // 重置所有排序和筛选条件回调
  ///     controller.filterSorts.value = sorts;
  ///     controller.filterConditions.value = conditions;
  ///     // 随后刷新数据
  ///   },
  ///   onSearch: () { // 搜索提交回调
  ///     // 随后刷新数据
  ///   },
  ///   onLocate: (locate, index) { // 定位切换回调
  ///     controller.locateIndex.value = index;
  ///     // 也可以用 locate.value 作为接口参数
  ///     // 随后刷新数据
  ///   },
  /// );
  ///
  /// 3: 获取参数 请求数据
  /// Map<String, dynamic> sortOrder = FilterStripUtils.getSortOrderParameter(sorts: filterSorts);
  /// Map<String, dynamic> conditions = FilterStripUtils.getConditionsParameter(conditions: filterConditions);
  /// Map<String, dynamic> searchs = FilterStripUtils.getSearchsParameter(searchs: filterSearchs);
  /// final dynamic locateValue = filterLocates[controller.locateIndex.value].value;
  ///
  /// ```
  const FilterStripWidget({
    super.key,
    this.sorts,
    this.conditions,
    this.searchs,
    this.locates,
    this.locateIndex = 0,
    this.locateMinWidth,
    this.width,
    this.onSorts,
    this.onConditions,
    this.onSearch,
    this.onSingleClearSearch,
    this.searchSingleWidth,
    this.onReset,
    this.onLocate,
    this.endText,
    this.startText,
  });

  @override
  State<FilterStripWidget> createState() => _FilterStripWidgetState();
}

class _FilterStripWidgetState extends State<FilterStripWidget> {
  int _locateIndex = 0;

  /// 定位组件实际内容宽度（包含外层 margin），用于中间区域宽度分配。
  double _locateListWidth = 0;

  /// 筛选组件实际内容宽度（包含重置按钮和外层 margin），用于中间区域宽度分配。
  double _conditionListWidth = 0;

  /// 仅用于获取筛选条件 items 区域的真实渲染宽度。
  final GlobalKey _conditionItemsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    initLocateIndex();
    _scheduleMeasureMiddleSectionWidth();
  }

  @override
  void didUpdateWidget(FilterStripWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.locateIndex != oldWidget.locateIndex) {
      scrollToLocateIndex();
    }
    _scheduleMeasureMiddleSectionWidth();
  }

  /// 初始化定位索引
  void initLocateIndex() {
    if (widget.locates == null) return;
    if (widget.locates!.length <= widget.locateIndex) return;
    _locateIndex = widget.locateIndex;
    if (mounted) setState(() {});
  }

  /// 滚动到定位索引
  void scrollToLocateIndex() {
    if (widget.locates == null) return;
    if (widget.locates!.length <= _locateIndex) return;
    _locateIndex = widget.locateIndex;
    if (mounted) setState(() {});

    final context = widget.locates![_locateIndex].key.currentContext;
    if (context == null) return;

    Scrollable.ensureVisible(
      context,
      duration: Duration(milliseconds: 200),
      alignment: 0.5,
    );
  }

  /// 在当前帧布局完成后，重新测量筛选区和定位区的真实宽度。
  void _scheduleMeasureMiddleSectionWidth() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final double locateWidth = _getLocateActualWidth();
      final double conditionWidth = _getConditionActualWidth();
      if ((locateWidth - _locateListWidth).abs() < 0.5 && (conditionWidth - _conditionListWidth).abs() < 0.5) return;
      setState(() {
        _locateListWidth = locateWidth;
        _conditionListWidth = conditionWidth;
      });
    });
  }

  /// 获取定位组件真实内容宽度。
  ///
  /// 这里会累加每个定位 item 的实际宽度，再补上 spacing、scrollView 的左右 padding
  /// 和外层容器的左侧 margin。首次还未完成布局时，回退到 `locateMinWidth`。
  double _getLocateActualWidth() {
    if (widget.locates == null || widget.locates!.isEmpty) return 0;
    final double locateMinWidth = widget.locateMinWidth ?? 500.wMin;
    double itemWidth = 0;
    for (final locate in widget.locates!) {
      final BuildContext? itemContext = locate.key.currentContext;
      final RenderObject? renderObject = itemContext?.findRenderObject();
      if (renderObject is! RenderBox || !renderObject.hasSize) return locateMinWidth + 8.wMin;
      itemWidth += renderObject.size.width;
    }
    final double spacingWidth = math.max(0, widget.locates!.length - 1) * 8.wMin;
    final double horizontalPaddingWidth = 8.wMin;
    final double marginWidth = 8.wMin;
    final double actualWidth = itemWidth + spacingWidth + horizontalPaddingWidth + 1.6.wMin;
    return actualWidth + marginWidth;
  }

  /// 获取定位组件在空间紧张时允许保留的基础宽度。
  ///
  /// 这里仍然会把外层左侧 margin 一起算进去，便于和中间区域总宽度直接比较。
  double _getLocateLimitWidth() {
    if (widget.locates == null || widget.locates!.isEmpty) return 0;
    final double locateMinWidth = widget.locateMinWidth ?? 500.wMin;
    final double marginWidth = 8.wMin;
    return locateMinWidth + marginWidth;
  }

  /// 获取筛选组件真实内容宽度。
  ///
  /// 宽度由三部分组成：筛选 item 区域、筛选项与重置按钮间距、重置按钮宽度，
  /// 同时补上外层左侧 margin。
  double _getConditionActualWidth() {
    if (widget.conditions == null || widget.conditions!.isEmpty) return 0;
    final double itemsWidth = _getRenderBoxWidth(_conditionItemsKey);
    final bool hasSelectedConditions = _hasSelectedConditions();
    final double marginWidth = 8.wMin;
    final double spacingWidth = hasSelectedConditions ? 8.wMin : 0;
    final double resetWidth = 110.wMin;
    return marginWidth + itemsWidth + spacingWidth + resetWidth;
  }

  /// 通过 key 读取组件当前的实际渲染宽度。
  double _getRenderBoxWidth(GlobalKey key) {
    final BuildContext? currentContext = key.currentContext;
    final RenderObject? renderObject = currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return 0;
    return renderObject.size.width;
  }

  /// 当前是否存在已选中的筛选条件。
  bool _hasSelectedConditions() {
    if (widget.conditions == null || widget.conditions!.isEmpty) return false;
    for (final value in widget.conditions!.values) {
      if (value.conditions.where((e) => e.selected).isNotEmpty) return true;
    }
    return false;
  }

  /// 显示排序弹窗
  Future<void> showSortPopup() async {
    Map<String, FilterSortsData>? res = await FilterStripUtils.showSort(
      context: context,
      sortsData: widget.sorts ?? {},
    );
    if (res == null) return;

    widget.onSorts?.call(res);
  }

  /// 显示筛选弹窗
  Future<void> showConditionsPopup({String? scrollConditionKey}) async {
    Map<String, FilterConditionsData>? res = await FilterStripUtils.showCondition(
      context: context,
      conditionsData: widget.conditions ?? {},
      scrollConditionKey: scrollConditionKey,
    );
    if (res == null) return;
    widget.onConditions?.call(res);
  }

  /// 显示搜索弹窗
  Future<void> showSearchPopup() async {
    Map<String, FilterSearchsData>? res = await FilterStripUtils.showSearch(
      context: context,
      searchsData: widget.searchs ?? {},
    );
    if (res == null) return;
    widget.searchs?.forEach((key, value) {
      value.controller.text = res[key]?.controller.text ?? "";
    });
    if (mounted) setState(() {});

    widget.onSearch?.call();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: PlatformBackdropFilterWidget(
        sigmaX: 4.wMin,
        sigmaY: 4.wMin,
        child: Container(
          height: 80.wMin,
          width: widget.width ?? (1800.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: AppTheme.cSurfaceSearchBackground.color,
            border: Border.all(
              color: AppTheme.cBorderDark.color,
              width: 1.wMin,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStartTextWidget(context),
              _buildSortButtonWidget(context),
              _buildConditionsButtonWidget(context),
              _buildConditionAndLocateWidget(context),
              _buildEndTextWidget(context),
              _buildSearchWidget(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartTextWidget(BuildContext context) {
    if (widget.startText == null) return Container();
    return Container(
      margin: EdgeInsets.only(left: 12.wMin),
      child: Text(
        widget.startText ?? "",
        style: TextStyle(
          color: AppTheme.cTextPrimary.color,
          fontSize: 24.wMin,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEndTextWidget(BuildContext context) {
    if (widget.endText == null) return Container();
    return Container(
      margin: EdgeInsets.only(left: 12.wMin),
      child: Text(
        widget.endText ?? "",
        style: TextStyle(
          color: AppTheme.cTextPrimary.color,
          fontSize: 24.wMin,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 排序按钮
  Widget _buildSortButtonWidget(BuildContext context) {
    if (widget.sorts == null) return Container();
    if (widget.sorts!.isEmpty) return Container();

    FilterSortsData? selectSort;
    FilterSortsItem? selectSortItem;

    for (var element in widget.sorts!.entries) {
      selectSortItem = element.value.sorts.firstWhereOrNull((e) => e.selected);
      if (selectSortItem != null) {
        selectSort = element.value;
        break;
      }
    }
    // if(selectSort == null && selectSortItem == null) return Container();

    return Container(
      margin: EdgeInsets.only(left: 12.wMin),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 100),
        alignment: Alignment.centerLeft,
        child: TapScaleWidget(
          onTap: () {
            showSortPopup();
          },
          sclae: 1,
          child: Container(
            height: 56.wMin,
            padding: EdgeInsets.only(left: 16.wMin, right: 24.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: AppTheme.cSurfaceGhostBgStrong.color,
              border: Border.all(
                color: AppTheme.cBorderTertiary.color,
                width: 0.8.wMin,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/svg/public/icon_sort.svg',
                  width: 28.wMin,
                  colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                ),
                SizedBox(width: 4.wMin),
                Text(
                  selectSort == null || selectSortItem == null ? '排序' : '${selectSort.title}·${selectSortItem.name}', // 排序的title·排序条件
                  style: TextStyle(
                    color: AppTheme.cTextPrimary.color,
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 条件按钮
  Widget _buildConditionsButtonWidget(BuildContext context) {
    if (widget.conditions == null) return Container();
    if (widget.conditions!.isEmpty) return Container();

    int conditionCount = 0;
    for (var element in widget.conditions!.values) {
      conditionCount += element.conditions.where((e) => e.selected).length;
    }

    return AnimatedSize(
      alignment: Alignment.centerLeft,
      duration: const Duration(milliseconds: 100),
      child: Container(
        margin: EdgeInsets.only(left: 8.wMin),
        padding: EdgeInsets.symmetric(vertical: 12.wMin),
        child: TapScaleWidget(
          onTap: () {
            showConditionsPopup();
          },
          sclae: 1,
          child: Container(
            height: 56.wMin,
            padding: EdgeInsets.only(left: 16.wMin, right: 16.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: AppTheme.cSurfaceGhostBgStrong.color,
              border: Border.all(
                color: AppTheme.cBorderTertiary.color,
                width: 0.8.wMin,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/svg/public/icon_filter.svg',
                  width: 28.wMin,
                  colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                ),
                SizedBox(width: 4.wMin),
                Text(
                  '筛选',
                  style: TextStyle(
                    color: AppTheme.cTextPrimary.color,
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 4.wMin),
                Visibility(
                  visible: conditionCount > 0,
                  child: Container(
                    padding: EdgeInsets.all(10.wMin),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.cSurfaceSearchBackground.color,
                    ),
                    child: Text(
                      "$conditionCount", // 选中的条件数量
                      style: TextStyle(
                        color: AppTheme.cTextPrimary.color,
                        fontSize: 16.wMin,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConditionAndLocateWidget(BuildContext context) {
    final bool hasConditions = widget.conditions != null && widget.conditions!.isNotEmpty;
    final bool hasLocates = widget.locates != null && widget.locates!.isNotEmpty;

    if (!hasConditions && !hasLocates) return Container();
    if (!hasLocates) return Expanded(child: _buildConditionListWidget(context));
    if (!hasConditions) return Expanded(child: _buildLocateLisWidget(context));
    
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double actualLocateWidth = _locateListWidth > 0 ? _locateListWidth : _getLocateActualWidth();
          final double limitLocateWidth = _getLocateLimitWidth();
          final double actualConditionWidth = _conditionListWidth > 0 ? _conditionListWidth : _getConditionActualWidth();
          final double locateWidth = math.min(
            actualLocateWidth,
            math.max(limitLocateWidth, constraints.maxWidth - actualConditionWidth),
          );
          final double conditionWidth = math.max(0, constraints.maxWidth - locateWidth);

          return Row(
            children: [
              SizedBox(width: conditionWidth, child: _buildConditionListWidget(context)),
              SizedBox(width: locateWidth, child: _buildLocateLisWidget(context)),
            ],
          );
        },
      ),
    );
  }

  /// 筛选条件列表
  Widget _buildConditionListWidget(BuildContext context) {
    if (widget.conditions == null) return Container();
    if (widget.conditions!.isEmpty) return Container();

    Map<String, FilterConditionsData> conditions = {};

    // 已经选择的
    widget.conditions?.forEach((key, value) {
      if (value.conditions.where((e) => e.selected).isNotEmpty) {
        conditions[key] = value;
      }
    });

    return Container(
      margin: EdgeInsets.only(left: 8.wMin),
      alignment: Alignment.centerLeft,
      child: SizedBox(
        height: 56.wMin,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  scrollbars: false, // 隐藏滚动条
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    key: _conditionItemsKey,
                    spacing: 8.wMin,
                    mainAxisSize: MainAxisSize.min,
                    children: conditions.entries.map((entry) {
                      String key = entry.key;
                      FilterConditionsData conditionsData = entry.value;
                      List<FilterConditionsItem> itemList = entry
                          .value.conditions
                          .where((e) => e.selected)
                          .toList();

                      return Row(
                        spacing: 6.wMin,
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(itemList.length, (itemIndex) {
                          return _buildConditionListItemWidget(conditionsData, itemList[itemIndex], key);
                        }),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            SizedBox(width: conditions.isEmpty ? 0 : 8.wMin),
            _buildResetButtonWidget(context),
          ],
        ),
      ),
    );
  }

  /// 筛选条件列表item
  Widget _buildConditionListItemWidget(FilterConditionsData conditionsData, FilterConditionsItem item, String conditionKey) {
    Color color = conditionsData.color ?? AppTheme.cSurfaceBrand.color;
    return TapScaleWidget(
      onTap: () {
        showConditionsPopup(scrollConditionKey: conditionKey);
      },
      sclae: 1,
      child: Container(
        height: 56.wMin,
        padding: EdgeInsets.only(left: 12.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: color.withValues(alpha: 0.12), // 后面改为动态=条件item的颜色 透明度0.12
          border: Border.all(
            color: color.withValues(alpha: 0.2), // 后面改为动态=条件item的颜色 透明度0.2
            width: 0.8.wMin,
          ),
        ),
        child: Row(
          children: [
            Text(
              '${conditionsData.title}·${item.name}', // 筛选条件item的title·筛选item选中的name
              style: TextStyle(
                color: color, // 后面改为动态=条件item的颜色
                fontSize: 22.wMin,
                fontWeight: FontWeight.w500,
              ),
            ),
            TapScaleWidget(
              sclae: 1.1,
              onTap: () {
                if (widget.conditions == null) return;
                item.selected = false;
                widget.onConditions?.call(widget.conditions ?? {});
              },
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(left: 4.wMin, right: 8.wMin),
                child: SvgPicture.asset(
                  "assets/svg/public/x.svg",
                  width: 20.wMin,
                  height: 24.wMin,
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn), // 后面改为动态=条件item的颜色
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 重置按钮
  Widget _buildResetButtonWidget(BuildContext context) {
    return TapScaleWidget(
      onTap: () {
        if (widget.sorts != null) {
          // 重置所有排序
          widget.sorts?.forEach((key, value) {
            for (var item in value.sorts) {
              item.selected = item.isDefault; // 恢复到默认
            }
          });
        }

        if (widget.conditions != null) {
          // 重置所有筛选条件
          widget.conditions?.forEach((key, value) {
            for (var item in value.conditions) {
              item.selected = false;
            }
          });
        }

        widget.onReset?.call(widget.sorts ?? {}, widget.conditions ?? {});
      },
      sclae: 1,
      child: Container(
        height: 56.wMin,
        width: 110.wMin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: AppTheme.cSurfaceGhostBgStrong.color,
          border: Border.all(
            color: AppTheme.cBorderTertiary.color,
            width: 0.8.wMin,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/svg/public/icon_reset.svg',
              width: 28.wMin,
              colorFilter: ColorFilter.mode(
                AppTheme.cTextPrimary.color.withValues(alpha: 0.6),
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: 4.wMin),
            Text(
              '重置',
              style: TextStyle(
                color: AppTheme.cTextPrimary.color.withValues(alpha: 0.6),
                fontSize: 24.wMin,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildLocateLisWidget(BuildContext context){
    if(widget.locates == null) return Container();
    return Container(
      margin: EdgeInsets.only(left: 8.wMin),
      height: 56.wMin,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: AppTheme.cSurfaceSearchBackground.color,
        border: Border.all(
          color: AppTheme.cBorderDark.color,
          width: 0.8.wMin,
        ),
      ),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          scrollbars: false, // 隐藏滚动条
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 4.wMin, vertical: 4.wMin),
          child: Row(
            spacing: 8.wMin,
            children: List.generate(widget.locates!.length, (index){
              bool isSelected = widget.locateIndex == index;
              return TapScaleWidget(
                onTap: () {
                  widget.onLocate?.call(widget.locates![index], index);
                },
                sclae: 1,
                key: widget.locates![index].key,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 100),
                  padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 8.wMin),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    color: isSelected ? AppTheme.cSurfaceBrand.withValues(alpha: 0.12) : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppTheme.cSurfaceBrand.color.withValues(alpha: 0.6) : Colors.transparent,
                      width: 0.8.wMin,
                    ),
                  ),
                  child: Text(
                    widget.locates![index].name,
                    style: TextStyle(
                      color: isSelected ? AppTheme.cSurfaceBrand.color : AppTheme.cTextSecondary.color,
                      fontSize: 20.wMin,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchWidget(BuildContext context) {
    if (widget.searchs == null) return Container();
    if (widget.searchs?.length == 1) {
      return _buildSingleSearchWidget();
    }
    return Row(
      children: [
        _buildSearchReslutButtonWidget(context),
        _buildSearchButtonWidget(context),
      ],
    );
  }

  /// 搜索结果按钮
  Widget _buildSearchReslutButtonWidget(BuildContext context) {
    if (widget.searchs == null) return Container();

    List<FilterSearchsData> searchList = [];
    widget.searchs?.forEach((key, value) {
      if (value.controller.text.isNotEmpty) {
        searchList.add(value);
      }
    });

    if (searchList.isEmpty) return Container();

    String searchText = searchList.map((e) => "${e.title}: ${e.controller.text}").join(" · ");

    return Container(
      margin: EdgeInsets.only(left: 8.wMin),
      child: TapScaleWidget(
        onTap: () {
          showSearchPopup();
        },
        sclae: 1,
        child: Container(
          height: 56.wMin,
          padding: EdgeInsets.only(left: 8.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: AppTheme.cSurfaceSearchBackground.color,
            border: Border.all(
              color: AppTheme.cBorderTertiary.color,
              width: 0.8.wMin,
            ),
          ),
          child: Row(
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: 400.wMin,
                ),
                child: Text(
                  searchText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.cTextPrimary.color,
                    fontSize: 20.wMin,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TapScaleWidget(
                sclae: 1.1,
                onTap: () {
                  widget.searchs?.forEach((key, value) {
                    value.controller.clear();
                  });
                  if (mounted) setState(() {});
                  widget.onSearch?.call();
                },
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      "assets/svg/public/x.svg",
                      width: 24.wMin,
                      height: 24.wMin,
                      colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn), // 后面改为动态=条件item的颜色
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 搜索按钮
  Widget _buildSearchButtonWidget(BuildContext context) {
    if (widget.searchs == null) return Container();

    int count = 0;
    widget.searchs?.forEach((key, value) {
      if (value.controller.text.isNotEmpty) {
        count++;
      }
    });

    return AnimatedSize(
      duration: const Duration(milliseconds: 100),
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(left: 8.wMin, right: 8.wMin),
        child: TapScaleWidget(
          onTap: () {
            showSearchPopup();
          },
          sclae: 1,
          child: Container(
            height: 56.wMin,
            padding: EdgeInsets.only(left: 16.wMin, right: 16.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: AppTheme.cSurfaceSearchBackground.color,
              border: Border.all(
                color: AppTheme.cBorderTertiary.color,
                width: 0.8.wMin,
              ),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/svg/public/icon_search.svg',
                  width: 28.wMin,
                  colorFilter: ColorFilter.mode(
                    AppTheme.cTextPrimary.color,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 10.wMin),
                Container(
                  width: 1.wMin,
                  height: double.infinity,
                  color: AppTheme.cBorderDark.color,
                  margin: EdgeInsets.symmetric(vertical: 12.wMin),
                ),
                SizedBox(width: 10.wMin),
                Text(
                  "多条件搜索",
                  style: TextStyle(
                    color: AppTheme.cTextSecondary.color,
                    fontSize: 20.wMin,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 6.wMin),
                Visibility(
                  visible: count > 0,
                  child: Container(
                    padding: EdgeInsets.all(10.wMin),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.cSurfaceLayerBase.color,
                    ),
                    child: Text(
                      "$count", // 搜索框有值数量
                      style: TextStyle(
                        color: AppTheme.cTextPrimary.color,
                        fontSize: 16.wMin,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 单独搜索的输入框
  Widget _buildSingleSearchWidget() {
    if (widget.searchs == null) return Container();
    FilterSearchsData? value = widget.searchs?.values.first;

    OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(999),
      borderSide: BorderSide(width: 1.wMin, color: AppTheme.cBorderTertiary.color),
    );

    return Container(
      width: widget.searchSingleWidth ?? 450.wMin,
      height: double.infinity,
      margin: EdgeInsets.only(right: 12.wMin, left: 8.wMin),
      alignment: Alignment.center,
      child: SizedBox(
        height: 56.wMin,
        child: TextField(
          controller: value?.controller,
          maxLines: 1,
          textAlignVertical: TextAlignVertical.center,
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextPrimary.color,
          ),
          decoration: InputDecoration(
            counterText: "",
            filled: true,
            fillColor: AppTheme.cSurfaceSearchBackground.color,
            contentPadding: EdgeInsets.symmetric(horizontal: 20.wMin),
            hintText: value?.hintText,
            hintStyle: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextPrimary.color.withValues(alpha: 0.45),
            ),
            border: border,
            focusedBorder: border,
            disabledBorder: border,
            enabledBorder: border,
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Visibility(
                  visible: (value?.controller.text.isNotEmpty ?? true) && widget.onSingleClearSearch != null,
                  child: TapScaleWidget(
                    onTap: () {
                      value?.controller.clear();
                      widget.onSingleClearSearch?.call();
                    },
                    sclae: 1.01,
                    child: Container(
                      width: 38.wMin,
                      height: 38.wMin,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.cSurfaceLayerElevated2.color,
                      ),
                      child: SvgPicture.asset(
                        'assets/svg/public/x.svg',
                        width: 24.wMin,
                        colorFilter: ColorFilter.mode(
                          AppTheme.cTextSecondary.color,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.wMin),
                Container(
                  width: 1.wMin,
                  height: 28.wMin,
                  color: AppTheme.cBorderDark.color,
                ),
                TapScaleWidget(
                  onTap: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    widget.onSearch?.call();
                  },
                  sclae: 1.03,
                  child: Container(
                    height: 56.wMin,
                    width: 56.wMin - 1.wMin,
                    alignment: Alignment.center,
                    color: Colors.transparent,
                    child: SvgPicture.asset(
                      'assets/svg/public/icon_search.svg',
                      width: 28.wMin,
                      colorFilter: ColorFilter.mode(
                        AppTheme.cTextPrimary.color,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          onChanged: (value) {
            if (mounted) setState(() {});
          },
          onSubmitted: (value) {
            widget.onSearch?.call();
          },
        ),
      ),
    );
  }
}

/// 筛选弹窗
class FilterStripUtils {
  /// 显示排序弹窗
  static Future<Map<String, FilterSortsData>?> showSort({
    required BuildContext context,
    required Map<String, FilterSortsData> sortsData,
  }) async {
    return await showCupertinoDialog<Map<String, FilterSortsData>?>(
      context: context,
      builder: (context) {
        return FilterStripDialogSortWidget(
          sortsData: sortsData,
        );
      },
    );
  }

  /// 显示筛选弹窗
  static Future<Map<String, FilterConditionsData>?> showCondition({
    required BuildContext context,
    required Map<String, FilterConditionsData> conditionsData,
    String? scrollConditionKey,
  }) async {
    return await showCupertinoDialog<Map<String, FilterConditionsData>?>(
      context: context,
      builder: (context) {
        return FilterStripDialogConditionWidget(
          conditionsData: conditionsData,
          scrollConditionKey: scrollConditionKey,
        );
      },
    );
  }

  /// 显示搜索弹窗
  static Future<Map<String, FilterSearchsData>?> showSearch({
    required BuildContext context,
    required Map<String, FilterSearchsData> searchsData,
  }) async {
    return await showCupertinoDialog<Map<String, FilterSearchsData>?>(
      context: context,
      builder: (context) {
        return FilterStripDialogSearchWidget(
          searchsData: searchsData,
        );
      },
    );
  }

  /// 获取排序参数
  static Map<String, dynamic> getSortOrderParameter({required Map<String, FilterSortsData> sorts, String orderKey = "order"}) {
    Map<String, dynamic> orderParameter = {};
    sorts.forEach((key, value) {
      FilterSortDirection? direction = value.sorts.firstWhereOrNull((element) => element.selected)?.direction;
      if (direction != null) {
        orderParameter[orderKey] = direction == FilterSortDirection.up ? key : "-$key";
      }
    });
    return orderParameter;
  }

  /// 获取筛选参数
  /// [singleToList] 单选的返回值是否也是数组
  static Map<String, dynamic> getConditionParameter({
    required Map<String, FilterConditionsData> conditions,
    bool singleToList = false,
  }) {
    Map<String, dynamic> parameter = {};
    conditions.forEach((key, value) {
      if (value.isSingle) {
        dynamic item = value.conditions.firstWhereOrNull((element) => element.selected)?.value;
        if (item != null) {
          if(singleToList){
            parameter[key] = [item];
          }else{
            parameter[key] = item;
          }
        }
      } else {
        List list = [];
        for (var e in value.conditions) {
          if (e.selected) {
            list.add(e.value);
          }
        }
        if (list.isNotEmpty) {
          parameter[key] = list;
        }
      }
    });
    return parameter;
  }

  /// 获取搜索参数
  static Map<String, dynamic> getSearchParameter({required Map<String, FilterSearchsData> searchs}) {
    Map<String, dynamic> parameter = {};

    for (var element in searchs.entries) {
      if (element.value.controller.text.isEmpty) continue;
      if (element.value.isCommaSeparated) {
        List? values = stringToList(element.value.controller.text);
        parameter[element.key] = values;
      } else {
        parameter[element.key] = element.value.controller.text;
      }
    }

    return parameter;
  }

  /// 字符串转数组
  static List? stringToList(String? input) {
    // 1. 如果输入为空，直接返回空列表
    if (input == null) return null;
    if (input.isEmpty) return null;

    List result = [];

    // 2. 使用正则表达式按照 中文逗号(，) 或 英文逗号(,) 分割字符串
    List<String> rawList = input.split(RegExp(r'[,，]'));

    for (String item in rawList) {
      // 3. 去除每个元素前后的空格（防止 " 12 " 这种情况）
      String cleanItem = item.trim();

      // 4. 只有在字符串不为空时才处理（防止 "1,,2" 产生空元素）
      if (cleanItem.isNotEmpty) {
        // 5. 核心：使用 int.tryParse
        // 如果是数字，返回整数；如果不是数字（如 "abc"），返回 null
        int? parsedNumber = int.tryParse(cleanItem);

        if (parsedNumber != null) {
          // 只有成功转换才加入结果集
          result.add(parsedNumber);
        } else {
          result.add(cleanItem);
        }
      }
    }

    if (result.isEmpty) return null;

    return result;
  }

  /// 根据接口数据转换排序数据
  static Map<String, FilterSortsData> getSortDataFrom(FiltersGroupEntity? filtersGroup) {
    if(filtersGroup == null) return {};

    Map<String, FilterSortsData> filterSorts = <String, FilterSortsData>{};

    List<FiltersGroupEntityFilters?> orders = filtersGroup.orders ?? [];

    for (var element in orders) {
      String? groupName = element?.name;
      String? groupCode = element?.code;
      if(groupName == null || groupCode == null) continue;
      List<FiltersGroupEntityValues?> items = element?.values ?? [];
      List<FilterSortsItem> sorts = [];
      for(int i = 0; i < items.length; i++){
        if(items[i]?.value == null || items[i]?.name == null) continue;
        sorts.add(FilterSortsItem( 
          name: items[i]?.name ?? "",
          selected: items[i]?.defaultValue ?? false,
          direction: (items[i]?.value ?? '').startsWith('-')? FilterSortDirection.down : FilterSortDirection.up
        ));
      }

      filterSorts[groupCode] = FilterSortsData(
        title: groupName,
        sorts: sorts,
      );
    }
    
    return filterSorts;
  }

  /// 根据接口数据转换筛选数据
  static Map<String, FilterConditionsData> getConditionDataFrom(FiltersGroupEntity? filtersGroup) {
    if(filtersGroup == null) return {};
    Map<String, FilterConditionsData> filterConditions = <String, FilterConditionsData>{};
    List<FiltersGroupEntityFilters?> filters = filtersGroup.filters ?? [];

    for (var element in filters) {
      String? groupName = element?.name;
      String? groupCode = element?.code;
      if(groupName == null || groupCode == null) continue;
      bool isRadioGroup = element?.radioGroup ?? false;
      List<FiltersGroupEntityValues?> items = element?.values ?? [];
      List<FilterConditionsItem> conditions = [];
      for(int i = 0; i < items.length; i++){
        if(items[i]?.value == null || items[i]?.name == null) continue;
        bool selected = (items[i]?.defaultValue ?? false);
        conditions.add(FilterConditionsItem( 
          name: items[i]?.name ?? "",
          value: items[i]?.value ?? "",
          selected: selected,
        ));
      }
      filterConditions[groupCode] = FilterConditionsData(
        title: groupName,
        isSingle: isRadioGroup,
        conditions: conditions,
      );
    }
    return filterConditions;
  }

}

class FilterStripDialogSortWidget extends StatefulWidget {
  final Map<String, FilterSortsData> sortsData;
  const FilterStripDialogSortWidget({super.key, required this.sortsData});

  @override
  State<FilterStripDialogSortWidget> createState() => _FilterStripDialogSortWidgetState();
}

class _FilterStripDialogSortWidgetState extends State<FilterStripDialogSortWidget> {
  Map<String, FilterSortsData> filterSoryDatas = {};

  Map<String, GlobalKey> filterKeyMap = {};

  @override
  void initState() {
    super.initState();

    /// 深拷贝
    widget.sortsData.forEach((key, value) {
      filterSoryDatas[key] = FilterSortsData(
        title: value.title,
        sorts: value.sorts.map((e) {
          return FilterSortsItem(
            name: e.name,
            selected: e.selected,
            isDefault: e.isDefault,
            direction: e.direction,
          );
        }).toList(),
      );
      filterKeyMap[key] = GlobalKey();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToTarget();
    });
  }

  void _scrollToTarget() {
    String? key;

    for (var element in filterSoryDatas.entries) {
      FilterSortsItem? selectSortItem = element.value.sorts.firstWhereOrNull((e) => e.selected);
      if (selectSortItem != null) {
        key = element.key;
        break;
      }
    }
    if (key == null) return;

    final targetKey = filterKeyMap[key];
    if (targetKey?.currentContext == null) return;

    // 使用 Scrollable.ensureVisible 滚动到目标 widget
    Scrollable.ensureVisible(
      targetKey!.currentContext!,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      alignment: 0.5, // 0.0 顶部对齐，0.5 居中对齐，1.0 底部对齐
    );
  }

  @override
  Widget build(BuildContext context) {
    return DialogUserWidget(
      title: "排序方式",
      width: 960.wMin,
      child: Column(
        children: [
          _buildSelectWidget(),
          SizedBox(height: 16.wMin),
          Container(
            constraints: BoxConstraints(
              maxHeight: 750.wMin,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 32.wMin,
                right: 32.wMin,
                bottom: 24.wMin,
              ),
              child: Column(
                spacing: 16.wMin,
                children: List.generate(filterSoryDatas.length, (index) {
                  return _buildSortItemWidget(filterSoryDatas.keys.elementAt(index), filterSoryDatas.values.elementAt(index), index);
                }),
              ),
            ),
          ),
          Container(height: 1.wMin, color: AppTheme.cBorderPrimary.color),
          SizedBox(height: 32.wMin),
          _buildButtonsWidget(),
          SizedBox(height: 32.wMin),
        ],
      ),
    );
  }

  Widget _buildButtonsWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.wMin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ButtonWidget(
            text: "确定",
            height: 56.wMin,
            borderRadius: 8.wMin,
            padding: EdgeInsets.symmetric(horizontal: 32.wMin),
            color: AppTheme.cSurfaceBrand.color,
            fontSize: 20.wMin,
            fontWeight: FontWeight.w600,
            sclae: 1.03,
            onTap: () {
              Get.back(result: filterSoryDatas);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSelectWidget() {
    FilterSortsData? selectSort;
    FilterSortsItem? selectSortItem;

    for (var element in filterSoryDatas.entries) {
      selectSortItem = element.value.sorts.firstWhereOrNull((e) => e.selected);
      if (selectSortItem != null) {
        selectSort = element.value;
        break;
      }
    }
    if (selectSort == null && selectSortItem == null) return Container();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 32.wMin),
      width: double.infinity,
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cFeedbackInfoBackground.color,
        border: Border.all(width: 0.8.wMin, color: AppTheme.cBgQuaternary.color),
      ),
      child: Text(
        "当前排序：${selectSort?.title}·${selectSortItem?.name}",
        style: TextStyle(
          fontSize: 18.wMin,
          color: AppTheme.cTextBrand.color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSortItemWidget(String key, FilterSortsData data, int index) {
    List<FilterSortsItem> selectedItems = data.sorts.where((e) => e.selected).toList();
    return Container(
      key: filterKeyMap[key],
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: index == filterSoryDatas.length - 1 ? null : Border(
          bottom: BorderSide(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
        ),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.title,
                style: TextStyle(
                  color: AppTheme.cTextPrimary.color,
                  fontWeight: FontWeight.w600,
                  fontSize: 18.wMin,
                ),
              ),
              SizedBox(height: 4.wMin),
              Text(
                selectedItems.isEmpty ? "选择正序或倒序" : "当前：${selectedItems.first.name}",
                style: TextStyle(
                  color: AppTheme.cTextTertiary.color,
                  fontWeight: FontWeight.w400,
                  fontSize: 16.wMin,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            height: 48.wMin,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
              color: AppTheme.cSurfaceSecondary.color,
            ),
            child: Row(
              children: List.generate(data.sorts.length, (index) {
                return _buildSortItemSelectItemWidget(data.sorts[index]);
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortItemSelectItemWidget(FilterSortsItem item) {
    return TapScaleWidget(
      onTap: () {
        filterSoryDatas.forEach((k, v) {
          for (var e in v.sorts) {
            e.selected = false;
          }
        });

        item.selected = !item.selected;
        if (mounted) setState(() {});
      },
      sclae: 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: double.infinity,
        padding: EdgeInsets.only(left: 16.wMin, right: 12.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: item.selected ? AppTheme.cFeedbackInfoBackground.color : Colors.transparent,
          border: Border.all(
            width: 1.wMin,
            color: AppTheme.cBorderBrand.color.withValues(alpha: item.selected ? 1 : 0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              item.direction == FilterSortDirection.up ? "assets/svg/public/icon_up.svg" : "assets/svg/public/icon_down.svg",
              width: 20.wMin,
              colorFilter: ColorFilter.mode(
                item.selected ? AppTheme.cTextBrand.color : AppTheme.cTextTertiary.color,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: 4.wMin),
            Text(
              item.name,
              style: TextStyle(
                fontSize: 16.wMin,
                color: item.selected ? AppTheme.cTextBrand.color : AppTheme.cTextTertiary.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterStripDialogConditionWidget extends StatefulWidget {
  final Map<String, FilterConditionsData> conditionsData;
  final String? scrollConditionKey;
  const FilterStripDialogConditionWidget({super.key, required this.conditionsData, this.scrollConditionKey});

  @override
  State<FilterStripDialogConditionWidget> createState() => _FilterStripDialogConditionWidgetState();
}

class _FilterStripDialogConditionWidgetState extends State<FilterStripDialogConditionWidget> {
  Map<String, FilterConditionsData> filterConditionsDatas = {};

  Map<String, GlobalKey> filterKeyMap = {};

  @override
  void initState() {
    super.initState();

    /// 深拷贝
    widget.conditionsData.forEach((key, value) {
      filterConditionsDatas[key] = FilterConditionsData(
        title: value.title,
        isSingle: value.isSingle,
        component: value.component,
        filterGroup: value.filterGroup,
        radioGroup: value.radioGroup,
        color: value.color,
        visibleWhen: value.visibleWhen,
        conditions: value.conditions.map((e) {
          return FilterConditionsItem(
            name: e.name,
            selected: e.selected,
            value: e.value,
          );
        }).toList(),
      );
      filterKeyMap[key] = GlobalKey();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToTarget();
    });
  }

  void _scrollToTarget() {
    if (widget.scrollConditionKey == null) return;
    final targetKey = filterKeyMap[widget.scrollConditionKey];
    if (targetKey?.currentContext == null) return;

    // 使用 Scrollable.ensureVisible 滚动到目标 widget
    Scrollable.ensureVisible(
      targetKey!.currentContext!,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      alignment: 0.5, // 0.0 顶部对齐，0.5 居中对齐，1.0 底部对齐
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<MapEntry<String, FilterConditionsData>> visibleConditions = _visibleConditions;
    return DialogUserWidget(
      title: "筛选",
      width: 1200.wMin,
      child: Column(
        children: [
          Container(
            constraints: BoxConstraints(
              maxHeight: 750.wMin,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 32.wMin,
                right: 32.wMin,
                bottom: 24.wMin,
              ),
              child: Column(
                spacing: 16.wMin,
                children: List.generate(visibleConditions.length, (index) {
                  final MapEntry<String, FilterConditionsData> entry = visibleConditions[index];
                  return _buildConditionItemWidget(
                    entry.key,
                    entry.value,
                    index,
                    visibleConditions.length,
                  );
                }),
              ),
            ),
          ),
          Container(height: 1.wMin, color: AppTheme.cBorderPrimary.color),
          SizedBox(height: 32.wMin),
          _buildButtonsWidget(),
          SizedBox(height: 32.wMin),
        ],
      ),
    );
  }

  Widget _buildConditionItemWidget(
    String key,
    FilterConditionsData data,
    int index,
    int visibleCount,
  ) {
    return Container(
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: Colors.transparent,
        border: index == visibleCount - 1 ? null : Border(
          bottom: BorderSide(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
        ),
      ),
      child: Row(
        key: filterKeyMap[key],
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 180.wMin,
            padding: EdgeInsets.only(top: 6.wMin),
            child: Text(
              data.title,
              style: TextStyle(
                fontSize: 20.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 12.wMin,
                runSpacing: 12.wMin,
                children: List.generate(data.conditions.length, (index) {
                  return _buildConditionItemSelectItemWidget(key, data, data.conditions[index]);
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionItemSelectItemWidget(String key, FilterConditionsData data, FilterConditionsItem item) {
    Color color = data.color ?? AppTheme.cSurfaceBrand.color;
    return TapScaleWidget(
      onTap: () {
        if (!item.selected) {
          if (data.isSingle) {
            for (var element in data.conditions) {
              element.selected = false;
            }
          }
          _clearLinkedGroupSelections(currentKey: key, currentData: data);
          item.selected = true;
        } else {
          item.selected = false;
        }
        _clearInvisibleSelections();

        if (mounted) setState(() {});
      },
      sclae: 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: EdgeInsets.symmetric(horizontal: 20.wMin, vertical: 8.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: item.selected ? color.withValues(alpha: 0.2) : AppTheme.cSurfaceGhostBgSubtle.color.withValues(alpha: 0.1),
          border: Border.all(
            width: 1.wMin,
            color: item.selected ? color : AppTheme.cBorderDefault.color,
          ),
        ),
        child: Text(
          item.name,
          style: TextStyle(
            fontSize: 20.wMin,
            color: item.selected ? color : AppTheme.cTextSecondary.color,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  void _clearLinkedGroupSelections({
    required String currentKey,
    required FilterConditionsData currentData,
  }) {
    final String filterGroup = (currentData.filterGroup ?? '').trim();
    if (filterGroup.isEmpty || !currentData.radioGroup) return;
    filterConditionsDatas.forEach((key, value) {
      if (key == currentKey) return;
      if ((value.filterGroup ?? '').trim() != filterGroup) return;
      for (final FilterConditionsItem element in value.conditions) {
        element.selected = false;
      }
    });
  }

  List<MapEntry<String, FilterConditionsData>> get _visibleConditions {
    return filterConditionsDatas.entries.where((entry) => _isConditionVisible(entry.value)).toList();
  }

  bool _isConditionVisible(FilterConditionsData data) {
    final visibleWhen = data.visibleWhen;
    if (visibleWhen == null) return true;
    return visibleWhen(filterConditionsDatas);
  }

  void _clearInvisibleSelections() {
    filterConditionsDatas.forEach((key, value) {
      if (_isConditionVisible(value)) return;
      for (final FilterConditionsItem element in value.conditions) {
        element.selected = false;
      }
    });
  }

  Widget _buildButtonsWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.wMin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ButtonWidget(
            text: "重置",
            height: 56.wMin,
            borderRadius: 8.wMin,
            padding: EdgeInsets.symmetric(horizontal: 32.wMin),
            color: AppTheme.cSurfaceTertiary.color,
            border: Border.all(width: 0.8.wMin, color: AppTheme.cBorderDefault.color),
            fontSize: 20.wMin,
            fontWeight: FontWeight.w600,
            fontColor: AppTheme.cTextPrimary.color,
            sclae: 1.03,
            leftIcon: Container(
              margin: EdgeInsets.only(left: 4.wMin),
              child: SvgPicture.asset(
                "assets/svg/public/icon_reset.svg",
                width: 20.wMin,
                colorFilter: ColorFilter.mode(
                  AppTheme.cTextPrimary.color,
                  BlendMode.srcIn,
                ),
              ),
            ),
            onTap: () {
              filterConditionsDatas.forEach((key, value) {
                for (var element in value.conditions) {
                  element.selected = false;
                }
              });
              if (mounted) setState(() {});
            },
          ),
          ButtonWidget(
            text: "确定",
            height: 56.wMin,
            borderRadius: 8.wMin,
            padding: EdgeInsets.symmetric(horizontal: 32.wMin),
            color: AppTheme.cSurfaceBrand.color,
            fontSize: 20.wMin,
            fontWeight: FontWeight.w600,
            sclae: 1.03,
            onTap: () {
              Get.back(result: filterConditionsDatas);
            },
          ),
        ],
      ),
    );
  }
}

class FilterStripDialogSearchWidget extends StatefulWidget {
  final Map<String, FilterSearchsData> searchsData;
  const FilterStripDialogSearchWidget({super.key, required this.searchsData});

  @override
  State<FilterStripDialogSearchWidget> createState() => _FilterStripDialogSearchWidgetState();
}

class _FilterStripDialogSearchWidgetState extends State<FilterStripDialogSearchWidget> {
  Map<String, FilterSearchsData> searchsData = {};
  late final bool Function(KeyEvent event) _keyboardHandler;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    /// 深拷贝
    widget.searchsData.forEach((key, value) {
      searchsData[key] = FilterSearchsData(
        hintText: value.hintText,
        controller: value.controller,
        title: value.title,
      );
    });

    _keyboardHandler = (event) {
      if (event is! KeyDownEvent) return false;
      if (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.numpadEnter) {
        if (_hasFocusedTextInput()) return false;
        _submitSearch();
        return true;
      }
      return false;
    };
    HardwareKeyboard.instance.addHandler(_keyboardHandler);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_keyboardHandler);
    super.dispose();
  }

  void _submitSearch() {
    if (!mounted || _isSubmitting) return;
    _isSubmitting = true;
    FocusManager.instance.primaryFocus?.unfocus();
    Get.back(result: searchsData);
  }

  bool _hasFocusedTextInput() {
    final focusedContext = FocusManager.instance.primaryFocus?.context;
    if (focusedContext == null) return false;
    if (focusedContext.widget is EditableText) return true;
    return focusedContext.findAncestorWidgetOfExactType<EditableText>() != null;
  }

  @override
  Widget build(BuildContext context) {
    return DialogUserWidget(
      title: "多条件搜索",
      width: 1200.wMin,
      child: Column(
        children: [
          Container(
            constraints: BoxConstraints(
              maxHeight: 750.wMin,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 32.wMin,
                right: 32.wMin,
                bottom: 24.wMin,
              ),
              child: Column(
                spacing: 16.wMin,
                children: List.generate(searchsData.length, (index) {
                  return _buildSearchItemWidget(searchsData.keys.elementAt(index), searchsData.values.elementAt(index));
                }),
              ),
            ),
          ),
          Container(height: 1.wMin, color: AppTheme.cBorderPrimary.color),
          SizedBox(height: 32.wMin),
          _buildButtonsWidget(),
          SizedBox(height: 32.wMin),
        ],
      ),
    );
  }

  Widget _buildSearchItemWidget(String key, FilterSearchsData value) {
    return Container(
      padding: EdgeInsets.all(20.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceLayerElevated.color,
        borderRadius: BorderRadius.circular(20.wMin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                "assets/svg/public/icon_search.svg",
                width: 20.wMin,
                colorFilter: ColorFilter.mode(
                  AppTheme.cTextPrimary.color,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 6.wMin),
              Text(
                value.title,
                style: TextStyle(
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextSecondary.color,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.wMin),
          CardInputWidget(
            borderRadius: BorderRadius.circular(999),
            hintText: value.hintText,
            height: 56.wMin,
            controller: value.controller,
            fillColor: AppTheme.cSurfaceSearchBackground.color,
            borderColor: AppTheme.cBorderSubtle.color,
            hintStyle: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
            valueStyle: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonsWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.wMin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ButtonWidget(
            text: "清空条件",
            height: 56.wMin,
            borderRadius: 8.wMin,
            padding: EdgeInsets.symmetric(horizontal: 16.wMin),
            color: AppTheme.cSurfaceTertiary.color,
            border: Border.all(width: 0.8.wMin, color: AppTheme.cBorderDefault.color),
            fontSize: 20.wMin,
            fontWeight: FontWeight.w600,
            fontColor: AppTheme.cTextPrimary.color,
            sclae: 1.03,
            leftIcon: Container(
              margin: EdgeInsets.only(left: 4.wMin),
              child: SvgPicture.asset(
                "assets/svg/public/icon_reset.svg",
                width: 20.wMin,
                colorFilter: ColorFilter.mode(
                  AppTheme.cTextPrimary.color,
                  BlendMode.srcIn,
                ),
              ),
            ),
            onTap: () {
              searchsData.forEach((key, value) {
                value.controller.clear();
              });
              if (mounted) setState(() {});
            },
          ),
          ButtonWidget(
            text: "搜索",
            height: 56.wMin,
            borderRadius: 8.wMin,
            padding: EdgeInsets.symmetric(horizontal: 32.wMin),
            color: AppTheme.cSurfaceBrand.color,
            fontSize: 20.wMin,
            fontWeight: FontWeight.w600,
            sclae: 1.03,
            onTap: () {
              _submitSearch();
            },
          ),
        ],
      ),
    );
  }
}
