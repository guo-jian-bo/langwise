import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/values/values.dart';
import '../../../../../utils/utils.dart';
import '../../../management/common/commons.dart';
import '../bindings/course_unit_grammar_details_binding.dart';
import '../controllers/course_unit_grammar_details_controller.dart';

class CourseUnitGrammarDetailsView extends GetView<CourseUnitGrammarDetailsController> {
  final String tagText;
  const CourseUnitGrammarDetailsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      CourseUnitGrammarDetailsView(tagText: tag),
      binding: CourseUnitGrammarDetailsBinding(tagText: tag),
      routeName: Routes.COURSE_UNIT_GRAMMAR_DETAILS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      onRefresh: () {
        controller.refreshList();
      },
      body: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            BreadcrumbWidget(isCompatibleManage: controller.isManagement),
            SizedBox(height: 10.wMin),
            _buildTitleWidget(),
            SizedBox(height: 10.wMin),
            Expanded(child: _buildListWidget()),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleWidget(){
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 90.wMin),
      child: Obx((){
        final data = controller.targetDetail.value;
        final title = LearningLangUtils.getLocalLang(data.title);
        final description = LearningLangUtils.getLocalLang(data.description);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title?.text??'',
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cZhenxieFontPrimary.color,
                fontFamily: AppFontValue.sourceHanSerifCN,
              ),
            ),
            SizedBox(height: 8.wMin),
            Text(
              description?.text??'',
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cZhenxieFontSecondary.color,
                fontFamily: AppFontValue.sourceHanSerifCN,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildListWidget() {
    return Obx(() {
      if (controller.dataList.isEmpty && !controller.isLoading.value) {
        return NotDataWidget(message: "这个语法点还没有签发组。");
      }

      return SentenceGrammarGroupListWidget(
        isManagement: controller.isManagement,
        // isToDetail: false,
        isToDetailBindRealizationSetId: true,
        unitId: controller.unitId,
        list: controller.dataList,
      );
    });
  }


}
