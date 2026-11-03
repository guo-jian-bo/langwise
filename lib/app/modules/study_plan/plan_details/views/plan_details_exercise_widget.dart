
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/widgets/guide_engine/guide_engine.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../controllers/plan_details_controller.dart';
import 'plan_details_widgets.dart';

class PlanDetailsExerciseWidget extends StatelessWidget {
  final PlanDetailsController controller;
  const PlanDetailsExerciseWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return PlanDetailsBoxWidget(
      step: 3,
      title: "题型禁用",
      controller: controller,
      child: Column(
        children: [
          SizedBox(height: 16.wMin),
          _buildDescWidget(),
          SizedBox(height: 16.wMin),
          Expanded(child: _buildExerciseListWidget()),
          SizedBox(height: 16.wMin),
          _buildButtonWidget(),
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
                "勾选课时后进入题型禁用页，按全局选择不需要的题型。确认返回后，这里展示被禁用题型的分类与名称。",
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


  Widget _buildExerciseListWidget(){
    return Column(
      children: [
        Row(
          children: [
            Obx((){
              return Text.rich(TextSpan(
                style: TextStyle(
                  color: AppTheme.cTextSecondary.color,
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  TextSpan(text: "已禁用"),
                  TextSpan(
                    text: " ${controller.disableExerciseTypeInfos.length} ",
                    style: TextStyle(
                      color: AppTheme.cTextPrimary.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(text: "个题型"),
                ],
              ));
            }),
            const Spacer(),
            Text(
              "全局设置",
              style: TextStyle(
                color: AppTheme.cTextTertiary.color,
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.wMin),
        Obx((){
          if(controller.disableExerciseTypeInfos.isEmpty){
            return _buildNotWidget();
          }
          return GridView.builder(
            itemCount: controller.disableExerciseTypeInfos.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8.wMin,
              crossAxisSpacing: 8.wMin,
              mainAxisExtent: 120.wMin,
            ),
            itemBuilder: (context, index) {
              return _buildExerciseListItemWidget(controller.disableExerciseTypeInfos[index]);
            },
          );
        }),
        
      ],
    );
  }

  Widget _buildNotWidget(){
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.wMin),
          border: Border.all(
            color: AppTheme.cBorderSubtle.color,
            width: 1.wMin,
          ),
        ),
        child: Text(
          "无禁用题型",
          style: TextStyle(
            color: AppTheme.cTextTertiary.color,
            fontSize: 28.wMin,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseListItemWidget(PlanEntityDisableExerciseTypeInfos item){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        border: Border.all(
          color: AppTheme.cBorderSubtle.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.wMin),
              color: AppTheme.cSurfaceTertiary.color,
              border: Border.all(
                color: AppTheme.cBorderSecondary.color,
                width: 0.8.wMin,
              ),
            ),
            child: Text(
              item.categoryName??"",
              style: TextStyle(
                color: AppTheme.cTextSecondary.color,
                fontSize: 18.wMin,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 16.wMin),
          Text(
            item.exerciseTypeName??"",
            style: TextStyle(
              color: AppTheme.cTextPrimary.color,
              fontSize: 24.wMin,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildButtonWidget(){
    SpecialtyColor courseColor = SpecialtyEnum.getCourseColor(controller.specialty??"");
    return GuideStepWidget(
      id: GuideWidgetIds.planDetailsDisableExerciseButton,
      onTap: () async{
        await controller.goSelectExerciseType();
      },
      sclae: 1.01,
      child: ButtonWidget(
        text: "禁用题型",
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