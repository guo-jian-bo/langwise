

import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/widgets/guide_engine/guide_engine.dart';
import '../../../../../utils/utils.dart';
import '../controllers/plan_details_controller.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'plan_details_widgets.dart';

class PlanDetailsCourseWidget extends StatelessWidget {
  final PlanDetailsController controller;
  const PlanDetailsCourseWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return PlanDetailsBoxWidget(
      step: 1,
      title: "选择课程",
      controller: controller,
      child: Column(
        children: [
          SizedBox(height: 16.wMin),
          
          Expanded(
            child: Obx((){
              if(controller.planStartUnitInfo.value.unitId == null){
                return _buildNotCourseWidget();
              }
              return Column(
                children: [
                  _buildCourseWidget(),
                  SizedBox(height: 16.wMin),
                  Expanded(child: _buildContentWidget()),
                ],
              );
            }),
          ),

          SizedBox(height: 16.wMin),
          _buildButtonWidget(context),
        ],
      ),
    );
  }

  Widget _buildNotCourseWidget(){
    SpecialtyColor courseColor = SpecialtyEnum.getCourseColor(controller.specialty??"");
    return Column(
      children: [
        Container(
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
                    "请根据你的学习目标选择内容。你可以自由组合级别与主题，定制最适合你的学习计划。",
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
        ),
        SizedBox(height: 16.wMin),
        Expanded(
          child: Container(
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.wMin),
              border: Border.all(
                color: AppTheme.cBorderSubtle.color,
                width: 3.wMin,
              ),
            ),
            child: Text(
              "还没有选择课程内容\n点击下方按钮开始吧",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.cTextTertiary.color,
                fontSize: 20.wMin,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCourseWidget(){
    return Obx((){

      List<ThemeTextEntity?> tierMappings = controller.planStartUnitInfo.value.tierMappings??[];

      return Row(
        spacing: 6.wMin,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Container(
            width: 220.wMin,
            height: controller.specialty == SpecialtyEnum.EN_PHONICS ? 220.wMin : 296.wMin,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.wMin),
              border: Border.all(
                color: AppTheme.cSurfaceLayerElevated.color,
                width: 3.wMin,
              ),
            ),
            child: CachedImageWidget(
              controller.planStartUnitInfo.value.moduleCoverUrl??"",
              width: 220.wMin,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(6.wMin),
              placeholder: buildEmptyWidget(fit: BoxFit.cover),
              errorWidget: buildEmptyWidget(fit: BoxFit.cover),
            ),
          ),

          Expanded(
            child: SizedBox(
              height: controller.specialty == SpecialtyEnum.EN_PHONICS ? 220.wMin : 296.wMin,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(4.wMin),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.wMin),
                      color: AppTheme.cCardLevelColor1.color.withValues(alpha: 0.12),
                      border: Border.all(
                        color: AppTheme.cCardLevelColor1.color.withValues(alpha: 0.2),
                        width: 1.wMin,
                      ),
                    ),
                    child: Text(
                      controller.planStartUnitInfo.value.levelName??"",
                      style: TextStyle(
                        color: AppTheme.cCardLevelColor1.color,
                        fontSize: 14.wMin,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              
                  SizedBox(height: 4.wMin),
              
                  Text(
                    controller.planStartUnitInfo.value.moduleName??"",
                    style: TextStyle(
                      color: AppTheme.cTextPrimary.color,
                      fontSize: 28.wMin,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        controller.planStartUnitInfo.value.moduleDescription??"",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.cTextTertiary.color,
                          fontSize: 18.wMin,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 4.wMin),
              
                  Wrap(
                    spacing: 6.wMin,
                    runSpacing: 6.wMin,
                    children: List.generate(tierMappings.length, (index){
                      ThemeTextEntity? themeTextEntity = tierMappings[index];
                      ThemeTextStyleEntity? style = StyleUtils.getCurrentThemeText(themeTextEntity?.style);
                      Color? bgColor = ColorUtils.parseColor(style?.backgroundColor);
                      Color? borderColor = ColorUtils.parseColor(style?.borderColor);

                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 2.wMin),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(8.wMin),
                          border: Border.all(
                            color: borderColor ?? Colors.transparent,
                            width: 1.wMin,
                          ),
                        ),
                        child: StyleUtils.getText(themeTextEntity),
                      );

                    }),
                  ),
                ],
              ),
            ),
          ),

        ],
      );
    });
  }

  Widget _buildContentWidget(){
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          color: AppTheme.cBorderSubtle.color,
          width: 1.wMin,
        ),
      ),
      child: Obx((){
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "当前单元",
              style: TextStyle(
                color: AppTheme.cTextSecondary.color,
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 12.wMin),
            Text(
              controller.planStartUnitInfo.value.unitName??"",
              style: TextStyle(
                color: AppTheme.cTextPrimary.color,
                fontSize: 28.wMin,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 12.wMin),
            Text(
              controller.planStartUnitInfo.value.unitDescription??"",
              style: TextStyle(
                color: AppTheme.cTextSecondary.color,
                fontSize: 20.wMin,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildButtonWidget(BuildContext context){
    SpecialtyColor courseColor = SpecialtyEnum.getCourseColor(controller.specialty??"");
    return GuideStepWidget(
      id: GuideWidgetIds.planDetailsSwitchCourseButton,
      onTap: () async{
        await controller.switchCourse(context);
      },
      sclae: 1.01,
      child: ButtonWidget(
        text: controller.planStartUnitInfo.value.unitId == null ? "设置课程内容" : "切换课程内容",
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