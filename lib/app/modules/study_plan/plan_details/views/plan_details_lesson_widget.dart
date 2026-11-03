

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';
import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/widgets/guide_engine/guide_engine.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../controllers/plan_details_controller.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'plan_details_widgets.dart';

class PlanDetailsLessonWidget extends StatelessWidget {
  final PlanDetailsController controller;
  const PlanDetailsLessonWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return PlanDetailsBoxWidget(
      step: 2,
      title: "选择课时",
      controller: controller,
      child: Column(
        children: [
          SizedBox(height: 16.wMin),
          _buildDescWidget(),
          SizedBox(height: 16.wMin),
          Expanded(child: _buildLessonListWidget()),
          SizedBox(height: 16.wMin),
          _buildButtonWidget(context),
        ],
      ),
    );
  }

  Widget _buildDescWidget(){
    SpecialtyColor courseColor = SpecialtyEnum.getCourseColor(controller.specialty??"");
    return Container(
      padding: EdgeInsets.all(8.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 2.wMin,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9),
                color: courseColor.color1,
              ),
            ),
            SizedBox(width: 6.wMin),
            Expanded(
              child: Text(
                "直接在下方切换要纳入计划的课时。选中的课时会参与学习安排，未选中的课时先不进入当前计划。",
                style: TextStyle(
                  color: AppTheme.cTextSecondary.color,
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonListWidget(){
    return Column(
      children: [
        Row(
          children: [
            Obx((){
              List<LessonTypeEntityList> directionList = controller.directionList.toList();
              int selectedCount = directionList.where((element) => element.exclude != true).length;
              return Text.rich(TextSpan(
                style: TextStyle(
                  color: AppTheme.cTextSecondary.color,
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  TextSpan(text: "已选用"),
                  TextSpan(
                    text: " $selectedCount",
                    style: TextStyle(
                      color: AppTheme.cTextPrimary.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(text: " / ${directionList.length} 个课时"),
                ],
              ));
            }),
            const Spacer(),
            Text(
              "直接点击方格开关",
              style: TextStyle(
                color: AppTheme.cTextTertiary.color,
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.wMin),
        Expanded(
          child: Obx((){
            return GridView.builder(
              itemCount: controller.directionList.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8.wMin,
                crossAxisSpacing: 8.wMin,
                mainAxisExtent: 130.wMin,
              ),
              itemBuilder: (context, index) {
                return _buildLessonListItemWidget(controller.directionList[index]);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildLessonListItemWidget(LessonTypeEntityList item){
    
    return TapScaleWidget(
      onTap: item.forceSelect ? null : () {
        controller.selectLesson(item);
      },
      sclae: 1,
      child: Container(
        padding: EdgeInsets.all(12.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.wMin),
          color: Colors.transparent,
          border: Border.all(
            color: AppTheme.cBorderSubtle.color,
            width: 1.wMin,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    LearningLangUtils.getLocalLang(item.title)?.text??"",
                    style: TextStyle(
                      color: AppTheme.cTextPrimary.color,
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: 8.wMin),
                Opacity(
                  opacity: item.forceSelect ? 0.7 : 1,
                  child: SvgPicture.asset(
                    item.exclude != true ? "assets/svg/public/icon_check_g.svg" : "assets/svg/public/icon_uncheck_box.svg",
                    width: 24.wMin,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.wMin),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  LearningLangUtils.getLocalLang(item.subtitle)?.text??"",
                  style: TextStyle(
                    color: AppTheme.cTextTertiary.color,
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonWidget(BuildContext context){
    SpecialtyColor courseColor = SpecialtyEnum.getCourseColor(controller.specialty??"");
    return GuideStepWidget(
      id: GuideWidgetIds.planDetailsRecommendSceneButton,
      onTap: () async{
        await controller.recommendScene(context);
      },
      sclae: 1.01,
      child: ButtonWidget(
        text: "推荐场景",
        width: double.infinity,
        height: 52.wMin,
        borderRadius: 8.wMin,
        color: courseColor.color1.withValues(alpha: 0.2),
        fontColor: courseColor.color1,
        fontSize: 20.wMin,
        fontWeight: FontWeight.w500,
      ),
    );
  }

}