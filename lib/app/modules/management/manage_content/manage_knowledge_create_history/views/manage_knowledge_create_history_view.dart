import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:langwise/common/enum/elements_card_type.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../routes/routes.dart';
import '../../../common/commons.dart';
import '../bindings/manage_knowledge_create_history_binding.dart';
import '../controllers/manage_knowledge_create_history_controller.dart';

class ManageKnowledgeCreateHistoryView extends GetView<ManageKnowledgeCreateHistoryController> {
  final String tagText;
  const ManageKnowledgeCreateHistoryView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_KNOWLEDGE_CREATE_HISTORY}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageKnowledgeCreateHistoryView(tagText: tag),
      binding: ManageKnowledgeCreateHistoryBinding(tag: tag),
      routeName: Routes.MANAGE_KNOWLEDGE_CREATE_HISTORY,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      backgroundColor: const Color(0xff050916),
      body: _buildListWidget(),
    );
  }


  Widget _buildListWidget(){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.wMin),
      child: AsyncDataTableWidget<KnowledgeCreateHistoryEntity>(
        dataRowHeight: 100.wMin,
        minWidth: 3000.wMin,
        sourceCallback: (AsyncDataTableSource source) {
          controller.onSetDataSourceAsync(source);
        },
        fetchData: (int currentPage, int offset, int limit, String sortedBy, bool sortedAsc, bool noData) {
          return controller.getCreateHistory(offset, limit);
        },
        columns: _buildColumns(),
        dataCellBuilder: (dessert, int startIndex) {
          return _buildDataCells(dessert, startIndex);
        },
      ),
    );
  }

  List<DataColumn> _buildColumns() {
    return [
      _buildColumn('taskId', fixedWidth: 150.wMin),
      _buildColumn('内容', fixedWidth: 560.wMin),
      _buildColumn('词性', fixedWidth: 200.wMin),
      _buildColumn('状态', fixedWidth: 200.wMin),
      _buildColumn('状态信息', fixedWidth: 300.wMin),
      _buildColumn('uid', fixedWidth: 200.wMin),
      _buildColumn('类型', fixedWidth: 200.wMin),
      
    ];
  }

    /// 构建所有表格单元格
  List<DataCell> _buildDataCells(KnowledgeCreateHistoryEntity item, int startIndex) {
    
    Color statusColor = Colors.white;
    String statusStr = "";
    if(item.statusStart){
      statusColor = Colors.white;
      statusStr = "创建中";
    }else if(item.statusFinished){
      statusColor = Colors.green;
      statusStr = "创建完成";
    }else if(item.statusFailed){
      statusColor = Colors.red;
      statusStr = "创建失败";
    }

    /// 类型
    ElementsCardType? type;
    if(item.contentList?.isNotEmpty??false){
      type = ElementsCardType.fromRawValue(item.contentList?.first?.type??"");
    }

    return [
      _buildContentColumn(
        item.taskId?.toString()??"",
      ),
      _buildContentColumn(
        item.params?.content,
      ),
      _buildContentColumn(
        item.params?.pos,
      ),
      _buildContentColumn(
        statusStr,
        fnotColor: statusColor,
      ),
      _buildContentColumn(
        item.errMsg,
      ),
      _buildUidColumn(item),
      _buildContentColumn(
        type?.name??"",
      ),
    ];
  }

  /// uid
  DataCell _buildUidColumn(KnowledgeCreateHistoryEntity item) {

    int? uid = item.contentList?.isNotEmpty??false ? item.contentList?.first?.uid : null;

    return DataCell(DataGeneralColumnWidget(
      child: Center(
        child: TapScaleWidget(
          onTap: () {
            controller.onUidClick(uid);
          },
          sclae: 1,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SelectableText(
                uid?.toString()??"",
                style: TextStyle(fontSize: 18.wMin, color: Colors.white),
              ),
              Visibility(
                visible: uid != null,
                child: Container(
                  padding: EdgeInsets.all(5.wMin),
                  color: Colors.transparent,
                  child: SvgPicture.asset(
                    "assets/svg/public/icon_w_arrow_right.svg",
                    width: 24.wMin,
                    height: 24.wMin,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    ));
  }


  /// 创建列定义的辅助方法，统一列样式和结构
  DataColumn2 _buildColumn(String title, {double? fixedWidth, MainAxisAlignment alignment = MainAxisAlignment.start}) {
    return DataColumn2(
      label: DataGeneralColumnWidget(
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18.wMin,
              color: const Color(0xffACB4C0),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
      headingRowAlignment: alignment,
      fixedWidth: fixedWidth,
    );
  }

  /// 创建列定义的辅助方法，统一列样式和结构
  DataCell _buildContentColumn(String? title, {Color? fnotColor}) {
    return DataCell(DataGeneralColumnWidget(
      child: Center(
        child: SelectableText(
          title??"",
          style: TextStyle(fontSize: 18.wMin, color: fnotColor ?? Colors.white),
        ),
      ),
    ));
  }


}
