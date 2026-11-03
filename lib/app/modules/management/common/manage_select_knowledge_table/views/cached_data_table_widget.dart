import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:langwise/common/widgets/data_table_widget/data_table.dart';
import 'package:ui_essentials/ui_essentials.dart';

class CachedDataTable<T extends Dessert> extends StatefulWidget {
  final List<DataColumn> columns;
  final List<T>? defaultDessert;
  final bool autoSelected;
  final Function(AsyncDataTableSource)? sourceCallback;
  final Future<DesertsFakeWebServiceResponse<T>> Function(int, int, int, String, bool, bool) fetchData;
  final Function(bool, int, T) onRowSelectChanged;
  final List<DataCell> Function(T, int) dataCellBuilder;
  final bool Function(T)? dataDisableCallback;

  const CachedDataTable({
    Key? key,
    required this.columns,
    required this.fetchData,
    required this.onRowSelectChanged,
    required this.dataCellBuilder,
    this.defaultDessert,
    this.autoSelected = false,
    this.sourceCallback,
    this.dataDisableCallback,
  }) : super(key: key);

  @override
  _CachedDataTableState<T> createState() => _CachedDataTableState<T>();
}

class _CachedDataTableState<T extends Dessert> extends State<CachedDataTable<T>>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AsyncDataTableWidget<T>(
      columns: widget.columns,
      pageNumPosition: PageNumPosition.bottom,
      dataRowHeight: 116.wh,
      verticalInside: BorderSide.none,
      showHeadingCheckBox: true,
      showCheckboxColumn: true,
      defaultDessert: widget.defaultDessert,
      dataDisableCallback: widget.dataDisableCallback,
      sourceCallback: widget.sourceCallback,
      fetchData: widget.fetchData,
      onRowSelectChanged: widget.onRowSelectChanged,
      dataCellBuilder: widget.dataCellBuilder,
      // 外部手动更新单元格选中状态
      autoSelected: widget.autoSelected,
    );
  }
}
