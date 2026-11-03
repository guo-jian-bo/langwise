import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/data_general_column_widget.dart';
import 'package:langwise/common/widgets/data_table_widget/data_table_widget.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../routes/routes.dart';
import '../../../common/commons.dart';
import '../../../models/manage_english_word_course_usage_model.dart';
import '../../../utils/utils.dart';
import '../bindings/manage_english_course_usage_binding.dart';
import '../controllers/manage_english_course_usage_controller.dart';

class ManageEnglishCourseUsageView extends GetView<ManageEnglishCourseUsageController> {
  final String tagText;
  const ManageEnglishCourseUsageView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_ENGLISH_COURSE_USAGE}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageEnglishCourseUsageView(tagText: tag),
      binding: ManageEnglishCourseUsageBinding(tag: tag),
      routeName: Routes.MANAGE_ENGLISH_COURSE_USAGE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      tag: tagText,
      builder: (_) {
        return ManageScaffold(
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Column(
              children: [
                Gaps.getHeight(15.wh),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: 24.ww, right: 24.ww),
                    child: AsyncDataTableWidget<ManageEnglishWordCourseUsageModel>(
                      dataRowHeight: 140.wh,
                      minWidth: 1400.ww,
                      sourceCallback: (AsyncDataTableSource source) {
                        // controller.onSetDataSourceAsync(source);
                      },
                      fetchData: (int currentPage, int startingAt, int count, String sortedBy, bool sortedAsc, bool noData) {
                        return controller.onFetchPages(currentPage, startingAt, count, sortedBy, sortedAsc, noData);
                      },
                      columns: _buildColumns(),
                      dataCellBuilder: (dessert, int startIndex) {
                        return _buildDataCells(dessert);
                      },
                      rowsPerPage: 100,
                      showPages: false,
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

  List<DataColumn> _buildColumns() {
    return [
      _buildColumn('序号', fixedWidth: 120.ww),
      _buildColumn('课程', fixedWidth: 220.ww),
      _buildColumn('等级', fixedWidth: 200.ww),
      _buildColumn('模块', fixedWidth: 620.ww),
      _buildColumn('单元', fixedWidth: 320.ww),
    ];
  }

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

  List<DataCell> _buildDataCells(ManageEnglishWordCourseUsageModel item) {
    return [
      DataCell(_buildTextCell(item.uid.toString())),
      DataCell(_buildTextCell(item.courseName ?? '')),
      DataCell(_buildTextCell(item.courseLevelName ?? '')),
      DataCell(_buildTextCell(item.courseModuleName ?? '')),
      DataCell(_buildUnitCell(item)),
    ];
  }

  Widget _buildTextCell(String text) {
    return DataGeneralColumnWidget(
      child: Center(
        child: Text(
          text,
          style: TextStyle(fontSize: 18.wMin, color: Colors.white),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildUnitCell(ManageEnglishWordCourseUsageModel item) {
    return DataGeneralColumnWidget(
      child: Center(
        child: Row(
          children: [
            Expanded(
              child: Text(
                item.courseUnitName ?? '',
                style: TextStyle(fontSize: 18.wMin, color: Colors.white),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ManageAuthBoxWidget(
              authCodes: const [ManageAuthCode.courseModuleUnitLessonList],
              child: ManageButton(
                text: "查看",
                width: 55.wMin,
                height: 32.wMin,
                color: const Color(0xFF353E5C),
                borderColor: Colors.transparent,
                style: TextStyle(
                  fontSize: 14.wMin,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
                onTap: () {
                  controller.viewUnit(Get.context!, item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
