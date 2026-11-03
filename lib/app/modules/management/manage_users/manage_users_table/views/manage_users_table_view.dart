import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../routes/routes.dart';
import '../../../common/manage_scaffold.dart';
import '../bindings/manage_users_table_binding.dart';
import '../controllers/manage_users_table_controller.dart';

class ManageUsersTableView extends GetView<ManageUsersTableController> {
  final String tagText;
  const ManageUsersTableView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_USERS_TABLE}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageUsersTableView(tagText: tag),
      binding: ManageUsersTableBinding(tag: tag),
      routeName: Routes.MANAGE_USERS_TABLE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Column(
          children: [
            _buildTitleWidget(),
            Gaps.getHeight(15.wh),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 24.wMin),
                child: AsyncDataTableWidget<ManageUserTableEntity>(
                  header: _buildHeader(),
                  dataRowHeight: 96.wh,
                  minWidth: 2210.ww,
                  sourceCallback: (AsyncDataTableSource source) {
                    controller.onSetDataSourceAsync(source);
                  },
                  fetchData: (
                    int currentPage,
                    int startingAt,
                    int count,
                    String sortedBy,
                    bool sortedAsc,
                    bool noData,
                  ) {
                    return controller.onFetchPages(
                      currentPage,
                      startingAt,
                      count,
                      sortedBy,
                      sortedAsc,
                      noData,
                    );
                  },
                  columns: _buildColumns(),
                  dataCellBuilder: (dessert, int startIndex) {
                    return _buildDataCells(context, dessert, startIndex);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleWidget() {
    return Padding(
      padding: EdgeInsets.only(left: 24.wMin, right: 24.wMin, top: 20.wMin),
      child: Row(
        children: [
          Text(
            '用户列表',
            style: TextStyle(
              fontSize: 28.wMin,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  List<DataCell> _buildDataCells(BuildContext context, ManageUserTableEntity item, int startIndex) {
    


    return [
      DataCell(TableTextCell('${item.userId}')),
      DataCell(TableTextCell(item.nickname ?? '')),
      DataCell(TableTextCell(item.phoneNumber ?? '')),
      DataCell(TableTextCell(item.teamId?.toString()??"")),
      DataCell(TableTextCell(item.vipDateStr)),
      DataCell(TableTextCell(item.newCreate)),
    ];
  }

  List<DataColumn> _buildColumns() {
    return [
      _buildColumn('用户ID', fixedWidth: 200.ww),
      _buildColumn('用户昵称', fixedWidth: 300.ww),
      _buildColumn('手机号', fixedWidth: 200.ww),
      _buildColumn('teamId', fixedWidth: 200.ww),
      _buildColumn('会员期限', fixedWidth: 500.ww),
      _buildColumn('创建时间', fixedWidth: 300.ww),
    ];
  }

  DataColumn2 _buildColumn(String title,
      {double? fixedWidth, MainAxisAlignment alignment = MainAxisAlignment.start}) {
    return DataColumn2(
      label: DataGeneralColumnWidget(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18.wMin,
            color: const Color(0xffACB4C0),
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      headingRowAlignment: alignment,
      fixedWidth: fixedWidth,
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        SearchWidget(
          width: 250.ww,
          height: 42.wh,
          hintText: 'userId，支持逗号分隔',
          onChanged: (String value) {
            controller.onSetUserId(value);
          },
          onSubmitted: (String value) {
            controller.onSetUserId(value, isSubmit: true);
          },
        ),
        Gaps.getWidth(12.ww),
        SearchWidget(
          width: 250.ww,
          height: 42.wh,
          hintText: '昵称',
          onChanged: (String value) {
            controller.onSetName(value);
          },
          onSubmitted: (String value) {
            controller.onSetName(value, isSubmit: true);
          },
        ),
      ],
    );
  }

  
}
