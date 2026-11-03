
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/widgets/guide_engine/guide_engine.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../controllers/plan_details_controller.dart';
import 'plan_details_widgets.dart';

class PlanDetailsScheduleWidget extends StatelessWidget {
  final PlanDetailsController controller;
  const PlanDetailsScheduleWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return PlanDetailsBoxWidget(
      key: controller.timeSettingDialogKey,
      step: controller.specialty == SpecialtyEnum.EN_PHONICS ? 2 : 4,
      title: "时间安排",
      controller: controller,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 16.wMin),
                  _buildTimeSettingWidget(context),
                  _buildHolidayWidget(),
                  SizedBox(height: 16.wMin),
                  _buildEstimatedTimeWidget(),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.wMin),
          _buildButtonWidget(context),
        ],
      ),
    );
  }

  Widget _buildTimeSettingWidget(BuildContext context){
    return Obx((){
      return Column(
        children: [
          TapScaleWidget(
            onTap: () => controller.showTimeSettingDialog(context),
            sclae: 1,
            child: _buildTimeSettingItemWidget(
              title: "工作日",
              weeks: controller.timeSettingData.value.workWeekList??[],
              duration: controller.timeSettingData.value.workDuration??0,
              times: controller.timeSettingData.value.workReminderTimeList ?? [],
            ),
          ),
          SizedBox(height: 16.wMin),
          TapScaleWidget(
            onTap: () => controller.showTimeSettingDialog(context),
            sclae: 1,
            child: _buildTimeSettingItemWidget(
              title: "休息日",
              weeks: controller.timeSettingData.value.restWeekList??[],
              duration: controller.timeSettingData.value.restDuration??0,
              times: controller.timeSettingData.value.restReminderTimeList ?? [],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildTimeSettingItemWidget({
    required String title,
    required List<int> weeks,
    required int duration,
    required List<DateTime> times,
  }){
    String weekStr = weeks.map((e) => DateFormatUtil.getWeekList()[e - 1]).join("、");
    SpecialtyColor courseColor = SpecialtyEnum.getCourseColor(controller.specialty??"");
    return Container(
      padding: EdgeInsets.all(12.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppTheme.cTextPrimary.color,
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                weekStr,
                style: TextStyle(
                  color: courseColor.color1,
                  fontSize: 14.wMin,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.wMin),
          Row(
            children: [
              Text(
                duration.toString(),
                style: TextStyle(
                  color: AppTheme.cTextPrimary.color,
                  fontSize: 40.wMin,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 4.wMin),
              Text(
                "分钟 / 天",
                style: TextStyle(
                  color: AppTheme.cTextSecondary.color,
                  fontSize: 14.wMin,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(width: 10.wMin),
              Container(
                width: 1.wMin,
                height: 24.wMin,
                color: AppTheme.cBorderSecondary.color,
              ),
              SizedBox(width: 10.wMin),
              Expanded(
                child: Wrap(
                  spacing: 10.wMin,
                  runSpacing: 10.wMin,
                  children: List.generate(times.length, (index){
                    return _buildTimeSettingItemTimeWidget(times[index]);
                  }),
                ),
              ),

            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSettingItemTimeWidget(DateTime time){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 4.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            "assets/svg/public/icon_duration1.svg",
            width: 16.wMin,
            colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
          ),
          SizedBox(width: 6.wMin),
          Text(
            DateFormatUtil.formatStr(time, newPattern: "HH:mm"),
            style: TextStyle(
              color: AppTheme.cTextPrimary.color,
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }


  /// 只能节假日
  Widget _buildHolidayWidget(){
    return Obx((){
      if(!controller.timeSettingData.value.isHolidaySwitch) return Container();
      return Container(
        margin: EdgeInsets.only(top: 16.wMin),
        padding: EdgeInsets.all(12.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.wMin),
          color: AppTheme.cSurfaceLayerBase.color,
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              "assets/svg/public/icon_calendar.svg",
              width: 24.wMin,
              colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
            ),
            SizedBox(width: 8.wMin),
            Text(
              "已开启智能节假日：节假日当休息日，调休当工作日",
              style: TextStyle(
                color: AppTheme.cTextSecondary.color,
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      );
    });
  }

  /// 预计时间
  Widget _buildEstimatedTimeWidget(){
    return Container(
      padding: EdgeInsets.all(12.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        border: Border.all(
          color: AppTheme.cBorderSubtle.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "预计完成",
                style: TextStyle(
                  color: AppTheme.cTextTertiary.color,
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              Text(
                "按当前时间安排估算",
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
            PlanEntityPlanPathCoursesStudyPlanStartUnitInfo startUnitInfo = controller.planStartUnitInfo.value;
            return Row(
              spacing: 8.wMin,
              children: [
                _buildEstimatedTimeItemWidget(
                  title: "模块",
                  value: startUnitInfo.moduleDay??0,
                  subtitle: "${startUnitInfo.unitTotal??0} 个单元",
                ),
                _buildEstimatedTimeItemWidget(
                  title: "单元",
                  value: startUnitInfo.unitDay??0,
                  subtitle: "${startUnitInfo.lessonCount??0} 课时",
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEstimatedTimeItemWidget({
    required String title,
    required int value,
    required String subtitle,
  }){
    SpecialtyColor courseColor = SpecialtyEnum.getCourseColor(controller.specialty??"");
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.wMin),
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceLayerBase.color,
          borderRadius: BorderRadius.circular(8.wMin),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: AppTheme.cTextTertiary.color,
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 8.wMin),
            Row(
              children: [
                Text(
                  "预计 ",
                  style: TextStyle(
                    color: AppTheme.cTextTertiary.color,
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  value.toString(),
                  style: TextStyle(
                    color: courseColor.color1,
                    fontSize: 28.wMin,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4.wMin),
                Text(
                  " 天",
                  style: TextStyle(
                    color: AppTheme.cTextTertiary.color,
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.wMin),
            Text(
              subtitle,
              style: TextStyle(
                color: AppTheme.cTextTertiary.color,
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
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
      id: GuideWidgetIds.planDetailsAdjustTimeButton,
      onTap: () async{
        await controller.showTimeSettingDialog(context);
      },
      sclae: 1.01,
      child: ButtonWidget(
        text: "调整时间安排",
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