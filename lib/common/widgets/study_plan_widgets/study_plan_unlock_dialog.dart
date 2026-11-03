
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/enum/enum.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../app/routes/routes.dart';
import '../../../app/routes/tag_routes.dart';
import '../../../utils/utils.dart';
import '../../entities/entities.dart';
import '../../https/https.dart';
import 'study_plan_widget.dart';
import '../widgets.dart';

class StudyPlanUnlockDialog{

  /// 显示解锁计划弹窗
  /// [step] 解锁的步骤
  /// [specialty] 课程类型
  static Future<bool> showUnlock({
    required BuildContext context,
    required StudyPlanCardStepModel step,
    required String specialty,
    required int stepCount,
    required int canShowIndex,
    required int? assessmentId,
  }) async{

    bool? result = await showCupertinoDialog<bool?>(
      context: context,
      builder: (context) {
        return StudyPlanUnlockDialogWidget(
          specialty: specialty,
          step: step,
          stepCount: stepCount,
          canShowIndex: canShowIndex,
          assessmentId: assessmentId,
        );
      },
    );
    return result??false;
  }

}

class StudyPlanUnlockDialogWidget extends StatefulWidget {
  final String specialty;
  final StudyPlanCardStepModel? step;
  final int stepCount;
  final int canShowIndex;
  final int? assessmentId;

  const StudyPlanUnlockDialogWidget({super.key, required this.specialty, this.step, required this.stepCount, required this.canShowIndex, this.assessmentId});

  @override
  State<StudyPlanUnlockDialogWidget> createState() => _StudyPlanUnlockDialogWidgetState();
}

class _StudyPlanUnlockDialogWidgetState extends State<StudyPlanUnlockDialogWidget> {

  @override
  void initState(){
    super.initState();
    tellServerShowed();
  }

  /// 告诉服务端已经弹出过啦
  Future<void> tellServerShowed() async{
    Map<String, dynamic> data = {
      "courseId": widget.step?.courseId,
      "canShowIndex": widget.canShowIndex,
    };
    await StudyPlanRequest.updateUnlockPlanShowStatus(data: data);
  }


  /// 开始学习计划
  Future<void> _startPlan() async{
    if(!HttpAuthUtils.instance.isAuth(HttpAuthCodes.memberCoursePlanPathInfo)) {
      ToastUtils.showToast(text: "无权限");
      return;
    }
    if(!HttpAuthUtils.instance.isAuth(HttpAuthCodes.manageCoursePlanCreateEdit)) {
      ToastUtils.showToast(text: "无权限");
      return;
    }
    if (widget.step?.courseId == null) return;

    bool isPwdRight = await ParentPasswordialog.show(context: context);
    if (!isPwdRight) return;

    if(widget.specialty == SpecialtyEnum.EN_TEXTBOOK){
      if((widget.step?.moduleId == null || widget.step?.moduleId == 0) && widget.step?.statusEnum != StudyPlanStatusEnum.RUNNING){
        if (!HttpAuthUtils.instance.isAuth(HttpAuthCodes.userCustomCreateCourseModule)) {
          ToastUtils.showToast(text: "无权限");
          return;
        }
        dynamic res = await TagRoutes.toNamed(
          Routes.CUSTOM_COURSE,
          arguments: {
            'courseId': widget.step?.courseId,
            'levelId': widget.step?.levelId,
            'cefr': widget.step?.name,
            'moduleId': widget.step?.moduleId,
            'fromType': 4,
            'gradeIndex': widget.step?.tierRange?.min,
            'levelName': widget.step?.levelName
          },
        );
        if(res == null) return;
      }
    }

    dynamic result = await TagRoutes.toNamed(
      Routes.PLAN_DETAILS, 
      arguments: {
        "courseId": widget.step?.courseId,
        "courseName": widget.step?.name,
        "tier": widget.step?.tierRange?.min,
        "semester": widget.step?.semester,
        "moduleId": widget.step?.moduleId,
        "specialty": widget.specialty,
        "phaseIndex": widget.canShowIndex - 1, 
        "assessmentId": widget.assessmentId,
        "pageType": 1,
      },
    );
    if(result != true) return;
    Get.back(result: true);
  }

  

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cOverlayBackground.color,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
        
            // StudyPlanCardWidget
            StudyPlanCardsTitleWidget(
              specialty: widget.specialty,
              isShowCourseStatus: false,
              stepsNotEmpty: true,
              titleBgColor2: AppTheme.cSurfacePrimary.color,
            ),
            SizedBox(height: 10.wMin),
        
            StudyPlanCardItemWidget(
              step: widget.step,
              stepCount: widget.stepCount,
              cardIndex: widget.canShowIndex - 1,
              specialty: widget.specialty,
            ),
        
            SizedBox(height: 28.wMin),
            _buildDescWidget(),
            SizedBox(height: 34.wMin),
            _buildButtonWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildDescWidget(){
    SpecialtyColor courseColor = SpecialtyEnum.getCourseColor(widget.specialty);
    
    return Column(
      spacing: 20.wMin,
      children: [
        Text(
          '已满足开启条件',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32.wMin,
            fontWeight: FontWeight.w600,
            color: courseColor.color1, // 课程颜色
          ),
        ),

        Text(
          '${SpecialtyEnum.getCourseName(widget.specialty)??""} 已达到对应阶段，这门课现在可以开始计划。',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextSecondary.color,
          ),
        ),

      ],
    );
  }

  Widget _buildButtonWidget(){
    SpecialtyColor courseColor = SpecialtyEnum.getCourseColor(widget.specialty);

    return Row(
      spacing: 12.wMin,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildButtonItemWidget(
          text: "稍后再说",
          fontColor: AppTheme.cTextTertiary.color,
          color: AppTheme.cSurfaceSecondary.color,
          borderColor: AppTheme.cBorderDefault.color,
          onTap: () async{
            Get.back();
          },
        ),
        _buildButtonItemWidget(
          text: "开始计划",
          fontColor: courseColor.color1,
          color: courseColor.color1.withValues(alpha: 0.12),
          borderColor: courseColor.color1.withValues(alpha: 0.2),
          onTap: () async{
            _startPlan();
          },
        ),
      ],
    );
  }

  Widget _buildButtonItemWidget({
    required String text,
    required Color color,
    required Color fontColor,
    required Color borderColor,
    Future<void> Function()? onTap,
  }){
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.02,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          color: AppTheme.cSurfacePrimary.color,
        ),
        child: Container(
          width: 314.wMin,
          height: 56.wMin,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.wMin),
            color: color,
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w600,
              color: fontColor,
            ),
          ),
        ),
      ),
    );
  }

}