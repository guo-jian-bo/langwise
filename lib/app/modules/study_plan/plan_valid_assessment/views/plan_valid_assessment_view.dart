import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/widgets/guide_engine/guide_engine.dart';
import '../../../../../common/widgets/study_plan_widgets/study_plan_widget.dart';
import '../../../../../utils/utils.dart';
import '../bindings/plan_valid_assessment_binding.dart';
import '../controllers/plan_valid_assessment_controller.dart';

class PlanValidAssessmentView extends GetView<PlanValidAssessmentController> {
  final String tagText;
  const PlanValidAssessmentView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      PlanValidAssessmentView(tagText: tag),
      binding: PlanValidAssessmentBinding(tagText: tag),
      routeName: Routes.PLAN_VALID_ASSESSMENT,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary,
      body: Container(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 24.wMin),
            _buildTitleWidget(),
            SizedBox(height: 10.wMin),
            Expanded(
              child: Center(
                child: SizedBox(
                  height: 950.wMin,
                  child: Obx((){
                    if(controller.planList.isEmpty) {
                      return Container();
                    }
                    return StudyPlanCardWidget(
                      isShowCancelButton: true,
                      isReturnToParent: true,
                      isShowUnlockButton: false,
                      isShowCourseStatus: false,
                      initPlanIndex: controller.planIndex,
                      controller: controller.studyPlanCardController,
                      planList: controller.planList.toList(),
                      onRefresh: controller.getRecommendPlan,
                      onRefreshAndReturnNewPlanList: () async{
                        await controller.getRecommendPlan();
                        return controller.planList.toList();
                      },
                      widgetIds: StudyPlanCardWidgetIds(
                        pageCode: AppRoutesCode.planValidAssessment,
                        studyPlanStartPlanButton: GuideWidgetIds.studyPlanStartPlanButton,
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleWidget(){
    return Column(
      children: [
        Text(
          '你有新的规划还未执行',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32.wMin,
            fontWeight: FontWeight.w700,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
        SizedBox(height: 12.wMin),
        Obx((){
          final last = DateFormatUtil.formatStrtoStr(
            controller.detailData.value.lastAssessment?.trim(),
            newPattern: 'yyyy年MM月dd日',
          );
          if(last.isEmpty) return Container();
          return Text(
            '评测时间:$last',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextSecondary.color,
            ),
          );
        }),

      ],
    );
  }

}
