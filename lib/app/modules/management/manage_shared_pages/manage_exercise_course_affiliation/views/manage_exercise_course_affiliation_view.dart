import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/data_general_column_widget.dart';
import 'package:langwise/common/widgets/data_table_widget/data_table_widget.dart';
import 'package:langwise/generated/assets.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:popover/popover.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../routes/routes.dart';
import '../../../common/commons.dart';
import '../../../models/manage_exercise_course_affiliation_model.dart';
import '../../../utils/utils.dart';
import '../bindings/manage_exercise_course_affiliation_binding.dart';
import '../controllers/manage_exercise_course_affiliation_controller.dart';

class ManageExerciseCourseAffiliationView extends GetView<ManageExerciseCourseAffiliationController> {
  final String tagText;
  const ManageExerciseCourseAffiliationView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_EXERCISE_COURSE_AFFILIATION}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageExerciseCourseAffiliationView(tagText: tag),
      binding: ManageExerciseCourseAffiliationBinding(tag: tag),
      routeName: Routes.MANAGE_EXERCISE_COURSE_AFFILIATION,
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
          resizeToAvoidBottomInset: true,
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
                  child: AsyncDataTableWidget<ManageExerciseCourseAffiliationModel>(
                    dataRowHeight: 140.wh,
                    minWidth: 4200.ww,
                    sourceCallback: (AsyncDataTableSource source) {
                      controller.onSetDataSourceAsync(source);
                    },
                    fetchData: (int currentPage, int startingAt, int count, String sortedBy, bool sortedAsc,
                        bool noData) {
                      return controller.onFetchPages(currentPage, startingAt, count, sortedBy, sortedAsc, noData);
                    },
                    columns: _buildColumns(),
                    dataCellBuilder: (dessert, int startIndex) {
                      return _buildDataCells(context, dessert, startIndex);
                    },
                    rowsPerPage: 100,
                    showPages: false,
                  ),
                )),
              ],
            ),
          ),
        );
      },
    );
  }

  List<DataColumn> _buildColumns() {
    return [
      _buildColumn('序号', fixedWidth: 100.ww),
      _buildColumn('课程', fixedWidth: 200.ww),
      _buildColumn('等级', fixedWidth: 150.ww),
      _buildColumn('模块', fixedWidth: 300.ww),
      _buildColumn('单元', fixedWidth: 300.ww),
      _buildColumn('课时', fixedWidth: 300.ww),
      _buildColumn('状态', fixedWidth: 170.ww),
      _buildColumn('删除', fixedWidth: 100.ww),
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

  List<DataCell> _buildDataCells(BuildContext context, ManageExerciseCourseAffiliationModel item, int startIndex) {
    return [
      DataCell(_buildIndexCell(item)),
      DataCell(_buildCourseCell(item)),
      DataCell(_buildLevelCell(item)),
      DataCell(_buildModuleCell(item)),
      DataCell(_buildUnitCell(context, item)),
      DataCell(_buildLessonCell(context, item)),
      DataCell(_buildAccessStatusCell(context, item)),
      DataCell(_buildDeleteCell(context, item)),
    ];
  }

  Widget _buildIndexCell(ManageExerciseCourseAffiliationModel item) {
    return DataGeneralColumnWidget(
      child: Center(
        child: Text(
          item.uid.toString(),
          style: TextStyle(fontSize: 18.wMin, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildCourseCell(ManageExerciseCourseAffiliationModel item) {
    return DataGeneralColumnWidget(
      child: Center(
        child: SelectableText(
          item.courseName ?? '',
          style: TextStyle(fontSize: 18.wMin, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildLevelCell(ManageExerciseCourseAffiliationModel item) {
    return DataGeneralColumnWidget(
      child: Center(
        child: SelectableText(
          item.courseLevelName ?? '',
          style: TextStyle(fontSize: 18.wMin, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildModuleCell(ManageExerciseCourseAffiliationModel item) {
    return DataGeneralColumnWidget(
      child: Center(
        child: SelectableText(
          item.courseModuleName ?? '',
          style: TextStyle(fontSize: 18.wMin, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildUnitCell(BuildContext context, ManageExerciseCourseAffiliationModel item) {
    return DataGeneralColumnWidget(
      child: Center(
        child: Row(
          children: [
            Expanded(
              child: SelectableText(
                item.courseUnitName ?? '',
                style: TextStyle(fontSize: 18.wMin, color: Colors.white),
              ),
            ),
            SizedBox(width: 10.wMin),
            Visibility(
              visible: !controller.disabledButton,
              child: ManageAuthBoxWidget(
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
                    controller.viewUnit(context, item);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonCell(BuildContext context, ManageExerciseCourseAffiliationModel item) {
    return DataGeneralColumnWidget(
      child: Center(
        child: Row(
          children: [
            Expanded(
              child: SelectableText(
                item.courseLessonName ?? '',
                style: TextStyle(fontSize: 18.wMin, color: Colors.white),
              ),
            ),
            SizedBox(width: 10.wMin),
            Visibility(
              visible: !controller.disabledButton,
              child: ManageAuthBoxWidget(
                authCodes: const [ManageAuthCode.lessonExerciseList],
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
                    controller.viewLesson(context, item);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessStatusCell(BuildContext context, ManageExerciseCourseAffiliationModel item) {
    return DataGeneralColumnWidget(
      child: Builder(
        builder: (targetContext) {
          return GestureDetector(
            onTap: () {
              if(!ManageAuthUtils.isAuth(ManageAuthCode.exerciseOperationCode)) return;
              showPopover(
                context: targetContext,
                bodyBuilder: (context) => accessPopWidget(context, item),
                direction: PopoverDirection.bottom,
                width: 150.wMin,
                height: 110.wMin,
                arrowHeight: 10.wMin,
                arrowWidth: 20.wMin,
                barrierColor: Colors.transparent,
                backgroundColor: const Color(0xFF18191A),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ManageButton(
                  text: item.accessNormal ? '上架' : '下架',
                  width: 70,
                  height: 32.wMin,
                  color: item.accessNormal ? const Color(0xFF63DE77) : const Color(0xFFFF2D46),
                  borderColor: Colors.transparent,
                  style: TextStyle(
                    fontSize: 14.wMin,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(width: 15.wMin),
                ManageAuthBoxWidget(
                  authCodes: const [ManageAuthCode.exerciseOperationCode],
                  child: SvgPicture.asset(
                    Assets.manageIconArrowDown,
                    width: 20.ww,
                    height: 20.ww,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget accessPopWidget(BuildContext context, ManageExerciseCourseAffiliationModel item) {
    return Container(
      padding: EdgeInsets.all(15.wMin),
      decoration: BoxDecoration(
        color: const Color(0xF22B2F3C),
        borderRadius: BorderRadius.circular(12.wMin),
      ),
      child: Column(
        children: [
          ManageButton(
            text: '上架',
            width: 80,
            height: 32.wMin,
            color: const Color(0xFF63DE77),
            borderColor: Colors.transparent,
            style: TextStyle(
              fontSize: 14.wMin,
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
            onTap: () {
              Get.back();
              if (!item.accessNormal) {
                controller.accessQuiz(context, item);
              } else {
                ToastUtils.showManageToast(text: '题目已是上架状态');
              }
            },
          ),
          SizedBox(height: 15.wMin),
          ManageButton(
            text: '下架',
            width: 80,
            height: 32.wMin,
            color: const Color(0xFFFF2D46),
            borderColor: Colors.transparent,
            style: TextStyle(
              fontSize: 14.wMin,
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
            onTap: () {
              Get.back();
              if (item.accessNormal) {
                controller.accessQuiz(context, item);
              } else {
                ToastUtils.showManageToast(text: '题目已是下架状态');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteCell(BuildContext context, ManageExerciseCourseAffiliationModel item) {
    return DataGeneralColumnWidget(
      child: Center(
        child: ManageAuthBoxWidget(
          authCodes: const [ManageAuthCode.exerciseOperationCode],
          child: GestureDetector(
            onTap: () {
              controller.deleteQuiz(context, item);
            },
            child: Icon(
              Icons.delete,
              color: Colors.redAccent,
              size: 30.wMin,
            ),
          ),
        ),
      ),
    );
  }
}
