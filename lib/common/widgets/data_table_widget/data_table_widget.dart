import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'custom_pager.dart';
import 'data_sources.dart';
import 'loading_widget.dart';
import 'nav_helper.dart';

// 页码位置
enum PageNumPosition {
  top,
  bottom;
}

class AsyncDataTableWidget<T extends Dessert> extends StatefulWidget {
  // header
  final Widget? header;

  // 默认行背景颜色
  final Color? defaultRowBgColor;

  // 最小宽度/设置后table可滑动
  final double? minWidth;

  // 页码位置
  final PageNumPosition pageNumPosition;

  // 异步数据处理器
  final AsyncDataTableSourceCallback? sourceCallback;

  // 默认数据/回显选中/未选中状态
  final List<T>? defaultDessert;

  // 列
  final List<DataColumn> columns;

  // 垂直方向的表格边框样式
  final BorderSide? verticalInside;

  // 每页多少条数据
  final int rowsPerPage;

  // 是否显示表头的复选框
  final bool showHeadingCheckBox;

  // 表头复选框是否允许交互/默认可以
  final bool headerCheckboxEnabled;

  // 是否显示复选框
  final bool showCheckboxColumn;

  // 行高(默认48.wh)
  final double? dataRowHeight;

  // 头行高(默认56.wh)
  final double? headingRowHeight;

  // 行是否禁用
  final bool Function(T)? dataDisableCallback;

  // 点击单元格自动选中状态/外部可手动设置单元格选中状态
  final bool autoSelected;

  // cell回调
  final DataCellBuilder<T> dataCellBuilder;

  // 数据源
  final FetchDataBuilder<T> fetchData;

  // 选中/未选中回调
  final OnRowSelectChanged<T>? onRowSelectChanged;

  // 初始排序列索引
  final int? sortColumnIndex;

  // 是否升序排序
  final bool sortAscending;

  // 是否显示页码
  final bool showPages;

  /// 第一列的margin
  final double? horizontalMargin;

  const AsyncDataTableWidget({
    super.key,
    this.header,
    this.defaultRowBgColor,
    this.minWidth,
    this.pageNumPosition = PageNumPosition.top,
    this.sourceCallback,
    this.defaultDessert,
    required this.columns,
    this.rowsPerPage = defaultRawRowsPerPage,
    this.showHeadingCheckBox = false,
    this.headerCheckboxEnabled = false,
    this.showCheckboxColumn = false,
    this.verticalInside,
    this.dataRowHeight,
    this.headingRowHeight,
    this.dataDisableCallback,
    this.autoSelected = true,
    required this.dataCellBuilder,
    required this.fetchData,
    this.onRowSelectChanged,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.showPages = true,
    this.horizontalMargin,
    });

  @override
  _AsyncDataTableWidgetState<T> createState() => _AsyncDataTableWidgetState<T>();
}

// 关键点: AsyncDataTableWidget<T>必须带上泛型T
class _AsyncDataTableWidgetState<T extends Dessert> extends State<AsyncDataTableWidget<T>> {
  // todo 默认20条数据/重要,因为Row的key的唯一性跟这个有关
  int _rowsPerPage = defaultRawRowsPerPage;

  /// 排序方向
  /// - 'asc'（ascending）：升序排列，从小到大，例如 10, 50, 100
  /// - 'desc'（descending）：降序排列，从大到小，例如 100, 50, 10
  bool _sortAscending = true;

  // 排序索引
  int? _sortColumnIndex;

  bool _initialized = false;

  final PaginatorController _pageController = PaginatorController();

  late DessertDataSourceAsync _dessertDataSourceAsync;

  // 垂直滚动控制器
  final ScrollController _scrollController = ScrollController();

  // 横向滚动控制器
  final ScrollController _horizontalController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _rowsPerPage = widget.rowsPerPage;

      // 泛型带上
      _dessertDataSourceAsync = DessertDataSourceAsync<T>(
          defaultRowBgColor: widget.defaultRowBgColor,
          autoSelected: widget.autoSelected,
          fewerResultsAfterRefresh: true,
          noData: false,
          defaultDessert: widget.defaultDessert,
          fetchData: widget.fetchData,
          dataCellBuilder: widget.dataCellBuilder,
          dataDisableCallback: widget.dataDisableCallback,
          onRowSelectChanged: widget.onRowSelectChanged);

      if (widget.sourceCallback != null) {
        widget.sourceCallback!.call(_dessertDataSourceAsync);
      }

      // 使用 widget 提供的排序参数初始化排序状态
      _sortColumnIndex = widget.sortColumnIndex;
      _sortAscending = widget.sortAscending;

      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildHeaderWidget(),
      Gaps.getHeight(7.wh),
      Expanded(
        child: AsyncPaginatedDataTable2(
          // 一直显示横向滚动条/false时,只有滑动才出现
          isHorizontalScrollBarVisible: false,
          // 一直显示垂直滚动条/false时,只有滑动才出现
          isVerticalScrollBarVisible: false,
          scrollController: _scrollController,
          horizontalScrollController: _horizontalController,
          // 100 Won't be shown since it is smaller than total records
          // 100将不会显示，因为它小于总记录
          availableRowsPerPage: availableRowsPerPage,
          // 是否显示表头的复选框
          showHeadingCheckBox: widget.showHeadingCheckBox,
          // 新增控制表头复选框可点击的参数
          headerCheckboxEnabled: widget.headerCheckboxEnabled,
          // todo 是否显示复选框
          showCheckboxColumn: widget.showCheckboxColumn,
          // 复选框横向距左间距
          checkboxHorizontalMargin: 0,
          /*
              todo   通过 headingCheckboxTheme 、 datarowCheckboxTheme 和 checkboxAlignment 自定义 DataTable2 中的复选框
                 */
          headingCheckboxTheme: CheckboxThemeData(
            fillColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.selected)) return Colors.blue;
              return Colors.transparent;
            }),
            checkColor: WidgetStateProperty.all(Colors.white),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            side: const BorderSide(
              color: Color(0xff616B85),
              width: 1,
            ),
          ),
          // 数据源的复选框样式
          datarowCheckboxTheme: CheckboxThemeData(
            fillColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.disabled)) return const Color(0xff4B5268);
              if (states.contains(WidgetState.selected)) return Colors.blue;
              return Colors.transparent;
            }),
            checkColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.disabled)) return const Color(0xff4B5268);
              return Colors.white;
            }),
            side: const BorderSide(
              color: Color(0xff616B85),
              width: 1,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          ),
          dividerThickness: 0,
          // 横向margin,影响第一列
          horizontalMargin: widget.horizontalMargin ?? 0,
          // 列之间的间距默认是56, 去掉
          columnSpacing: 0,
          wrapInCard: false,
          pageSyncApproach: PageSyncApproach.goToFirst,
          renderEmptyRowsInTheEnd: false,
          // header默认颜色: 透明
          headingRowColor: WidgetStateColor.resolveWith((states) => widget.defaultRowBgColor ?? Colors.transparent),
          // header不设置时, 隐藏
          // header: null,
          // header预留高度
          headingRowHeight: widget.headingRowHeight ?? 56.wh,
          // 显示在表格头部右侧的操作按钮，通常是 IconButton 或 TextButton
          actions: null,
          // 每页显示的行数
          rowsPerPage: _rowsPerPage,
          autoRowsToHeight: false,
          minWidth: widget.minWidth ?? 200,
          dataRowHeight: widget.dataRowHeight ?? 48.wh,
          fit: FlexFit.tight,
          border: TableBorder(
            bottom: BorderSide(color: const Color(0xff4B5268), width: 0.5.wMin),
            left: BorderSide(color: Colors.transparent, width: 0.5.wMin),
            right: BorderSide(color: const Color(0xff4B5268), width: 0.5.wMin),
            verticalInside: widget.verticalInside ?? BorderSide(color: const Color(0xff4B5268), width: 0.5.wMin),
            horizontalInside: BorderSide(color: const Color(0xff4B5268), width: 0.5.wMin),
          ),
          // 用户更改每页显示的行数时的回调
          onRowsPerPageChanged: (value) {
            _rowsPerPage = value!;
            print("---😆😆每页显示的行数变化,_rowsPerPage:${_rowsPerPage}");
          },
          initialFirstRowIndex: 0,
          onPageChanged: (rowIndex) {
            print('---页数变化: rowIndex: $rowIndex,_rowsPerPage:$_rowsPerPage, ${rowIndex / _rowsPerPage}');
          },
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          sortArrowIcon: Icons.keyboard_arrow_up,
          // custom arrow
          sortArrowAnimationDuration: const Duration(milliseconds: 0),
          loading: const LoadingWidget(),
          // custom animation duration
          // 选择了所有数据行的回调函数。
          onSelectAll: (val) {
            print('---😆😆选中所有,val:$val😆😆---');
            if (val ?? false) {
              _dessertDataSourceAsync.selectAllOnThePage();
            } else {
              _dessertDataSourceAsync.deselectAllOnThePage();
            }
            print('---😆😆选中所有,selectedRowCount:${_dessertDataSourceAsync.selectedRowCount}, selectionRowKeys:${_dessertDataSourceAsync.selectionRowKeys}😆😆---');
          },
          columns: widget.columns,
          empty: Center(child: Container(padding: const EdgeInsets.all(20), color: Colors.grey[200], child: const Text('No data'))),
          // 数据源
          source: _dessertDataSourceAsync,
          // 分页控制器
          controller: _pageController,
          // 移除自带的分页视图/使用自定义的分页视图
          hidePaginator: true,
        ),
      ),
      Gaps.getHeight(10.wh),
      if (widget.pageNumPosition == PageNumPosition.bottom) _buildBottomWidget(),
    ]);
  }

  Widget _buildHeaderWidget() {
    if (!widget.showPages) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        if (widget.header != null) widget.header!,
        const Spacer(),
        if (widget.pageNumPosition == PageNumPosition.top) CustomPager(_pageController),
      ],
    );
  }

  Widget _buildBottomWidget() {
    return Row(
      children: [
        const Spacer(),
        if (widget.pageNumPosition == PageNumPosition.bottom) CustomPager(_pageController),
      ],
    );
  }

  @override
  void dispose() {
    _dessertDataSourceAsync.dispose();
    _pageController.dispose();
    _scrollController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }
}

class SyncDataTableWidget<T extends Dessert> extends StatefulWidget {
  final Widget? header;
  final double? minWidth;
  final SyncDataTableSourceCallback? sourceCallback;
  final List<DataColumn> columns;
  final List<T>? desserts;

  // 是否显示表头的复选框
  final bool showHeadingCheckBox;

  // 是否显示复选框
  final bool showCheckboxColumn;

  // 行高(默认48.wh)
  final double? dataRowHeight;
  final DataSourceBuilder<T> dataCellBuilder;

  // 行是否禁用
  final bool Function(T)? dataDisableCallback;

  // 鼠标右击
  final Function(int index, T)? onSecondaryTap;

  // 选中/未选中回调
  final OnRowSelectChanged<T>? onRowSelectChanged;

  const SyncDataTableWidget(
      {super.key,
      this.header,
      this.minWidth,
      this.sourceCallback,
      required this.columns,
      this.desserts,
      this.showHeadingCheckBox = true,
      this.showCheckboxColumn = false,
      this.dataRowHeight,
      required this.dataCellBuilder,
      this.dataDisableCallback,
      this.onSecondaryTap,
      this.onRowSelectChanged});

  @override
  _SyncDataTableWidgetState<T> createState() => _SyncDataTableWidgetState<T>();
}

// 关键点: DataTableWidget<T>必须带上泛型T
class _SyncDataTableWidgetState<T extends Dessert> extends State<SyncDataTableWidget<T>> {
  bool _sortAscending = true;
  int? _sortColumnIndex;
  late DessertDataSource _dessertsDataSource;
  bool _initialized = false;

  // 泛型带上
  DataSourceBuilder<T>? _builder;

  // 垂直滚动控制器
  final ScrollController _scrollController = ScrollController();

  // 横向滚动控制器
  final ScrollController _horizontalController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _builder = widget.dataCellBuilder;

      if (_builder != null) {
        // 泛型带上
        _dessertsDataSource = DessertDataSource<T>(context,
            desserts: widget.desserts ?? [],
            builder: _builder,
            hasRowTaps: false,
            dataDisableCallback: widget.dataDisableCallback,
            onSecondaryTap: widget.onSecondaryTap,
            onRowSelectChanged: widget.onRowSelectChanged);
        _dessertsDataSource.addListener(() {
          setState(() {});
        });
      }

      if (widget.sourceCallback != null) {
        widget.sourceCallback!.call(_dessertsDataSource);
      }

      // 默认排序
      _sortColumnIndex = 1;

      _initialized = true;
    }
  }

  void sort<T>(
    Comparable<T> Function(Dessert d) getField,
    int columnIndex,
    bool ascending,
  ) {
    _dessertsDataSource.sort<T>(getField, ascending);
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildHeaderWidget(),
      Gaps.getHeight(7.wh),
      Expanded(
          child: DataTable2(
        // 一直显示横向滚动条/false时,只有滑动才出现
        isHorizontalScrollBarVisible: false,
        // 一直显示垂直滚动条/false时,只有滑动才出现
        isVerticalScrollBarVisible: false,
        scrollController: _scrollController,
        horizontalScrollController: _horizontalController,
        // 是否显示表头上的复选框
        showHeadingCheckBox: widget.showHeadingCheckBox,
        // todo 是否显示复选框
        showCheckboxColumn: widget.showCheckboxColumn,
        // 复选框横向距左间距
        checkboxHorizontalMargin: 0,
        /*
              todo   通过 headingCheckboxTheme 、 datarowCheckboxTheme 和 checkboxAlignment 自定义 DataTable2 中的复选框
                 */
        headingCheckboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) return Colors.blue;
            return Colors.transparent;
          }),
          checkColor: WidgetStateProperty.all(Colors.white),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          side: const BorderSide(
            color: Color(0xff616B85),
            width: 1,
          ),
        ),
        // 数据源的复选框样式
        datarowCheckboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) return const Color(0xff4B5268);
            if (states.contains(WidgetState.selected)) return Colors.blue;
            return Colors.transparent;
          }),
          checkColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) return const Color(0xff4B5268);
            return Colors.white;
          }),
          side: const BorderSide(
            color: Color(0xff616B85),
            width: 1,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),

        dividerThickness: 0,
        horizontalMargin: 20,
        // 列之间的间距默认是56, 去掉
        columnSpacing: 0,
        // header默认颜色: 透明
        headingRowColor: WidgetStateColor.resolveWith((states) => Colors.transparent),
        // header不设置时, 隐藏
        // header: null,
        // header预留高度
        headingRowHeight: 56.wh,
        minWidth: widget.minWidth ?? 800,
        dataRowHeight: widget.dataRowHeight ?? 48.wh,
        border: TableBorder(
          // top: BorderSide(color: Colors.transparent, width: 0.5.wMin),
          bottom: BorderSide(color: const Color(0xff4B5268), width: 0.5.wMin),
          left: BorderSide(color: Colors.transparent, width: 0.5.wMin),
          right: BorderSide(color: const Color(0xff4B5268), width: 0.5.wMin),
          verticalInside: BorderSide(color: const Color(0xff4B5268), width: 0.5.wMin),
          horizontalInside: BorderSide(color: const Color(0xff4B5268), width: 0.5.wMin),
        ),
        sortColumnIndex: _sortColumnIndex,
        sortAscending: _sortAscending,
        sortArrowIcon: Icons.keyboard_arrow_up,
        // custom arrow
        sortArrowAnimationDuration: const Duration(milliseconds: 0),
        // 选择了所有数据行的回调函数。
        onSelectAll: null,

        // onSelectAll: (val) => setState(() => _dessertsDataSource.selectAll(val)),
        columns: widget.columns,
        empty: Center(child: Container(padding: const EdgeInsets.all(20), color: Colors.grey[200], child: const Text('No data'))),
        rows: buildDataRow,
      )),
    ]);
  }

  List<DataRow> get buildDataRow {
    return List<DataRow>.generate(_dessertsDataSource.rowCount, (index) => _dessertsDataSource.getRow(index));
  }

  Widget _buildHeaderWidget() {
    if (widget.header != null) return widget.header!;
    return const SizedBox();
  }

  @override
  void dispose() {
    _dessertsDataSource.dispose();
    _scrollController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }
}
