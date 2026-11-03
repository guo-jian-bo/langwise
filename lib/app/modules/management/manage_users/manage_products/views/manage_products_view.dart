import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../common/widgets/widgets.dart';
import '../../../../../routes/routes.dart';
import '../../../common/manage_scaffold.dart';
import '../bindings/manage_products_binding.dart';
import '../controllers/manage_products_controller.dart';
import 'manage_product_entity.dart';

class ManageProductsView extends GetView<ManageProductsController> {
  final String tagText;
  const ManageProductsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_PRODUCTS}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageProductsView(tagText: tag),
      binding: ManageProductsBinding(tag: tag),
      routeName: Routes.MANAGE_PRODUCTS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ManageProductsController>(
      tag: tagText,
      id: 'manage_products',
      builder: (_) {
        return ManageScaffold(
          onRefresh: controller.onRefresh,
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
                    child: AsyncDataTableWidget<ManageProductEntity>(
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
      },
    );
  }

  Widget _buildTitleWidget() {
    return Padding(
      padding: EdgeInsets.only(left: 24.wMin, right: 24.wMin, top: 20.wMin),
      child: Row(
        children: [
          Text(
            '商品列表',
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

  List<DataCell> _buildDataCells(BuildContext context, ManageProductEntity item, int startIndex) {
    return [
      DataCell(TableTextCell('${item.uid}')),
      DataCell(TableTextCell(item.category ?? '')),
      DataCell(TableTextCell(item.name ?? '')),
      DataCell(TableTextCell(item.describe ?? '')),
      DataCell(TableTextCell(item.payMethod ?? '')),
      DataCell(TableTextCell(item.priceStr)),
      DataCell(TableTextCell(item.productId ?? '')),
      DataCell(TableTextCell(item.newCreate)),
    ];
  }

  List<DataColumn> _buildColumns() {
    return [
      _buildColumn('uid', fixedWidth: 160.ww),
      _buildColumn('分类', fixedWidth: 200.ww),
      _buildColumn('名称', fixedWidth: 300.ww),
      _buildColumn('说明', fixedWidth: 300.ww),
      _buildColumn('支付方式', fixedWidth: 240.ww),
      _buildColumn('价格', fixedWidth: 200.ww),
      _buildColumn('产品ID', fixedWidth: 540.ww),
      _buildColumn('创建时间', fixedWidth: 200.ww),
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
          width: 180.ww,
          height: 42.wh,
          hintText: 'uid，支持逗号分隔',
          onChanged: (String value) {
            controller.onSetUid(value);
          },
          onSubmitted: (String value) {
            controller.onSetUid(value, isSubmit: true);
          },
        ),
        Gaps.getWidth(12.ww),
        SearchWidget(
          width: 200.ww,
          height: 42.wh,
          hintText: '名称',
          onChanged: (String value) {
            controller.onSetName(value);
          },
          onSubmitted: (String value) {
            controller.onSetName(value, isSubmit: true);
          },
        ),
        Gaps.getWidth(12.ww),
        SearchWidget(
          width: 220.ww,
          height: 42.wh,
          hintText: '描述',
          onChanged: (String value) {
            controller.onSetDescription(value);
          },
          onSubmitted: (String value) {
            controller.onSetDescription(value, isSubmit: true);
          },
        ),
      ],
    );
  }
}
