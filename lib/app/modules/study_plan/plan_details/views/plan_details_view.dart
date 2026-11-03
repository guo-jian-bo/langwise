import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/enum/enum.dart';
import '../../../../../common/widgets/guide_engine/guide_engine.dart';
import '../../../../../common/widgets/widgets.dart';
import '../bindings/plan_details_binding.dart';
import '../controllers/plan_details_controller.dart';
import 'plan_details_course_widget.dart';
import 'plan_details_exercise_widget.dart';
import 'plan_details_lesson_widget.dart';
import 'plan_details_schedule_widget.dart';

class PlanDetailsView extends GetView<PlanDetailsController> {
  final String tagText;
  const PlanDetailsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      PlanDetailsView(tagText: tag),
      binding: PlanDetailsBinding(tagText: tag),
      routeName: Routes.PLAN_DETAILS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary.color,
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        alignment: Alignment.topCenter,
        padding: EdgeInsets.only(
          bottom: 10.wMin + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          children: [
            BreadcrumbWidget(),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 90.wMin),
                child: Row(
                  spacing: 16.wMin,
                  children: controller.specialty == SpecialtyEnum.EN_PHONICS ? [
                    PlanDetailsCourseWidget(controller: controller),
                    PlanDetailsScheduleWidget(controller: controller),
                  ] : [
                    PlanDetailsCourseWidget(controller: controller),
                    PlanDetailsLessonWidget(controller: controller),
                    PlanDetailsExerciseWidget(controller: controller),
                    PlanDetailsScheduleWidget(controller: controller),
                  ],
                ),
              ),
            ), 
            SizedBox(height: 42.wMin),
            _buildButtonsWidget(context),
            SizedBox(height: 24.wMin),
          ],
        ),
      ),
    );
  }


  Widget _buildButtonsWidget(BuildContext context){
    SpecialtyColor courseColor = SpecialtyEnum.getCourseColor(controller.specialty??"");

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Visibility(
          visible: controller.pageType == 0,
          child: Container(
            margin: EdgeInsets.only(right: 18.wMin),
            child: ButtonWidget(
              text: "删除计划",
              width: 240.wMin,
              height: 60.wMin,
              borderRadius: 8.wMin,
              color: AppTheme.cSurfaceError.color.withValues(alpha: 0.2),
              fontColor: AppTheme.cSurfaceError.color,
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              sclae: 1.02,
              onTap: () {
                controller.deletePlan(context);
              },
            ),
          ),
        ),
        GuideStepWidget(
          id: GuideWidgetIds.planDetailsSavePlanButton,
          onTap: () async{
            controller.savePlan(context);
          },
          sclae: 1.01,
          child: ButtonWidget(
            text: "保存计划",
            width: 720.wMin,
            height: 60.wMin,
            borderRadius: 8.wMin,
            color: courseColor.color1,
            fontSize: 24.wMin,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }



}
