import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/widgets/guide_engine/guide_engine.dart';
import '../../../../common/widgets/study_plan_widgets/study_plan_card_widget.dart';
import '../../../../utils/utils.dart';
import '../bindings/study_plan_binding.dart';
import '../controllers/study_plan_controller.dart';

class StudyPlanView extends GetView<StudyPlanController> {
  final String tagText;
  const StudyPlanView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      StudyPlanView(tagText: tag),
      binding: StudyPlanBinding(tagText: tag),
      routeName: Routes.STUDY_PLAN,
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
        child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BreadcrumbWidget(),
                  _buildStatisticsWidget(),
                  SizedBox(height: 10.wMin),
                  Expanded(
                    child: _buildPlanWidget(),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 56.wMin,
              bottom: 50.wMin,
              child: CustomerServiceButtonWidget(widgetId: GuideWidgetIds.studyPlanCustomerServiceButton, pageCode: AppRoutesCode.studyPlan),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsWidget(){
    return Container(
      height: 90.wMin,
      margin: EdgeInsets.symmetric(horizontal: 90.wMin),
      child: Row(
        children: [
          _buildStatisticsCefrWidget(),
          SizedBox(width: 10.wMin),
          _buildStatisticsPlanWidget(),
          SizedBox(width: 10.wMin),
          _buildStudyStatisticsWidget(),
        ],
      ),
    );
  }

  /// 当前等级
  Widget _buildStatisticsCefrWidget(){
    return GuideStepWidget(
      id: GuideWidgetIds.studyPlanAssessmentLevelButton,
      onTap: () async {
        await controller.goAssessmentResultPage();
      },
      sclae: 1,
      child: Obx((){

        int? assessmentTier = controller.currentMemberInfo.value.assessmentTier;
        int nextRecommendDay = (controller.currentMemberInfo.value.nextRecommendDay ?? 0);
        Color shimmerColor = Colors.transparent;
        if(assessmentTier == null){
          shimmerColor = AppTheme.cSurfaceError.color;
        }else if(nextRecommendDay <= 0){
          shimmerColor = AppTheme.cSurfaceWarning.color;
        }

        return Container(
          height: double.infinity,
          width: 290.wMin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.wMin),
            color: AppTheme.cSurfaceLayerBase2.color,
            border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
          ),
          child: Visibility(
            visible: controller.currentMemberInfo.value.memberId != null,
            child: ShimmerWidget(
              color: shimmerColor,
              enabled: assessmentTier == null || nextRecommendDay <= 0,
              colorOpacity: 0.2,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.wMin),
                child: Row(
                  spacing: 16.wMin,
                  children: [
                    _buildStatisticsCefrBoxWidget(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStatisticsCefrLevelTextWidget(),
                        _buildStatisticsCefrDayWidget(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStatisticsCefrBoxWidget(){
    return Obx((){
      int? assessmentTier = controller.currentMemberInfo.value.assessmentTier;
      String? cefr = controller.currentMemberInfo.value.cefr;
      DifficultyColor difficultyColor = StatusUtils.getCefrBackgroundColor(cefr);
      Color crfrColor = difficultyColor.color1;
      String cefrText = cefr??"";
      if(assessmentTier == null){
        crfrColor = AppTheme.cSurfaceError.color;
        cefrText = "暂无\n等级";
      }

      return Container(
        height: 64.wMin,
        width: 64.wMin,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 4.wMin),
        decoration: BoxDecoration(
          color: crfrColor.withValues(alpha: 0.2),
          border: Border.all(width: 1.wMin, color: crfrColor.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(12.wMin),
        ),
        child: AutoSizeText(
          cefrText,
          maxLines: assessmentTier == null ? 2 : 1,
          minFontSize: 6,
          style: TextStyle(
            fontSize: 24.wMin,
            color: crfrColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

    });
  }

  Widget _buildStatisticsCefrLevelTextWidget(){
    return Obx((){
      int? assessmentTier = controller.currentMemberInfo.value.assessmentTier;
      if(assessmentTier != null){
        return Row(
          spacing: 2.wMin,
          children: [
            Text(
              "Level $assessmentTier",
              style: TextStyle(
                fontSize: 32.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w600,
              ),
            ),
            SvgPicture.asset(
              "assets/svg/public/icon_w_arrow_right.svg",
              width: 28.wMin,
              colorFilter: ColorFilter.mode(AppTheme.cTextTertiary.color, BlendMode.srcIn),
            ),
          ],
        );
      }
      return Row(
        spacing: 2.wMin,
        children: [
          Text(
            "去评测",
            style: TextStyle(
              fontSize: 28.wMin,
              color: AppTheme.cSurfaceError.color,
              fontWeight: FontWeight.w600,
            ),
          ),
          SvgPicture.asset(
            "assets/svg/public/icon_w_arrow_right.svg",
            width: 28.wMin,
            colorFilter: ColorFilter.mode(AppTheme.cSurfaceError.color, BlendMode.srcIn),
          ),
        ],
      );
    });
  }

  Widget _buildStatisticsCefrDayWidget(){
    return Obx((){
      int? assessmentTier = controller.currentMemberInfo.value.assessmentTier;
      if(assessmentTier == null){
        return Text(
          "开始听说读写能力评估",
          style: TextStyle(
            fontSize: 16.wMin,
            color: AppTheme.cTextTertiary.color,
            fontWeight: FontWeight.w400,
          ),
        );
      }

      int nextRecommendDay = (controller.currentMemberInfo.value.nextRecommendDay ?? 0);
      if(nextRecommendDay <= 0){
        return Text(
          "建议重新评测",
          style: TextStyle(
            fontSize: 16.wMin,
            color: AppTheme.cSurfaceWarning.color,
            fontWeight: FontWeight.w600,
          ),
        );
      }

      String? lastAssessment = controller.currentMemberInfo.value.lastAssessment;
      DateTime? lastAssessmentDate = DateFormatUtil.tryParseDate(lastAssessment);
      // 最近评测时间 n 天前
      String timeAgoText = DateFormatUtil.getTimeAgoText(lastAssessmentDate??DateTime.now());

      return Text(
        "最近评测 · $timeAgoText",
        style: TextStyle(
          fontSize: 16.wMin,
          color: AppTheme.cTextTertiary.color,
          fontWeight: FontWeight.w400,
        ),
      );
    });
  }


  /// 计划设置
  Widget _buildStatisticsPlanWidget(){
    return GuideStepWidget(
      id: GuideWidgetIds.studyPlanTodayTaskButton,
      onTap: () async {
        await controller.goTodayTaskPage();
      },
      sclae: 1,
      child: Container(
        height: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cSurfaceLayerBase2.color,
          border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
        ),
        child: Obx((){
          int workDuration = controller.getPlanTotalDuration(false);
          int restDuration = controller.getPlanTotalDuration(true);
    
          String? lastStudied = controller.currentMemberInfo.value.lastStudied;
          DateTime? lastStudiedDate = DateFormatUtil.tryParseDate(lastStudied);
          // 最近学习时间 n 天前
          String timeAgoText = DateFormatUtil.getTimeAgoText(lastStudiedDate);
    
          return Row(
            children: [
              _buildStatisticsPlanItemWidget(
                value: "$workDuration",
                title: "分钟 / 天",
                subtitle: "工作日",
                valueColor: const Color(0xff3B82F6),
              ),
              _buildDividerWidget(),
              _buildStatisticsPlanItemWidget(
                value: "$restDuration",
                title: "分钟 / 天",
                subtitle: "休息日",
                valueColor: const Color(0xffF59E0B),
              ),
              _buildDividerWidget(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        "今日任务",
                        style: TextStyle(
                          fontSize: 20.wMin,
                          color: AppTheme.cTextPrimary.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SvgPicture.asset(
                        "assets/svg/public/icon_w_arrow_right.svg",
                        width: 28.wMin,
                        colorFilter: ColorFilter.mode(AppTheme.cTextTertiary.color, BlendMode.srcIn),
                      ),
                    ],
                  ),
                  Text(
                    "最近学习 · $timeAgoText",
                    style: TextStyle(
                      fontSize: 16.wMin,
                      color: AppTheme.cTextTertiary.color,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStatisticsPlanItemWidget({
    required String value,
    required String title,
    required String subtitle,
    required Color valueColor,
  }){
    return Row(
      spacing: 4.wMin,
      children: [
        Container(
          alignment: Alignment.centerRight,
          constraints: BoxConstraints(
            minWidth: 75.wMin,
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 52.wMin,
              color: valueColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18.wMin,
                color: AppTheme.cTextSecondary.color,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16.wMin,
                color: AppTheme.cTextTertiary.color,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 学习统计
  Widget _buildStudyStatisticsWidget(){
    return Expanded(
      child: Container(
        height: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cSurfaceLayerBase2.color,
          border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
        ),
        child: Obx((){
          MemberStatisticsEntity memberStatistics = controller.memberStatistics.value;
          int totalDuration = ((memberStatistics.totalDuration??0) / 60).round();

          return Row(
            children: [
              _buildStudyStatisticsItemWidget(
                svg: "assets/svg/today_plan/icon_knowledge.svg",
                title: "总知识",
                value: NumberUtils.formatNumberWithCommas(memberStatistics.totalMemoryContentCount?.toDouble()??0),
                suffix: "个",
                valueColor: const Color(0xff38BDF8),
              ),
              _buildDividerWidget(),
              _buildStudyStatisticsItemWidget(
                svg: "assets/svg/today_plan/icon_duration.svg",
                title: "总时长",
                value: NumberUtils.formatNumberWithCommas(totalDuration.toDouble()),
                suffix: "分钟",
                valueColor: const Color(0xff60A5FA),
              ),
              _buildDividerWidget(),
              _buildStudyStatisticsItemWidget(
                svg: "assets/svg/today_plan/icon_star.svg",
                title: "总星星",
                value: NumberUtils.formatNumberWithCommas(memberStatistics.totalStars?.toDouble()??0),
                suffix: "个",
                valueColor: const Color(0xffFBBF24),
              ),
              _buildDividerWidget(),
              _buildStudyStatisticsItemWidget(
                svg: "assets/svg/today_plan/icon_diamond.svg",
                title: "总钻石",
                value: NumberUtils.formatNumberWithCommas(memberStatistics.totalDiamond?.toDouble()??0),
                suffix: "个",
                valueColor: const Color(0xffC084FC),
              ),
              _buildDividerWidget(),
              _buildStudyStatisticsItemWidget(
                svg: "assets/svg/today_plan/icon_memory.svg",
                title: "总记忆",
                value: NumberUtils.formatNumberWithCommas(memberStatistics.totalMemoryDay?.toDouble()??0),
                suffix: "天",
                valueColor: const Color(0xff00D492),
              ),
              _buildDividerWidget(),
              _buildStudyStatisticsItemWidget(
                svg: "assets/svg/today_plan/icon_continuous_fire.svg",
                title: "连续记忆",
                value: NumberUtils.formatNumberWithCommas(memberStatistics.continueMemoryDay?.toDouble()??0),
                suffix: "天",
                valueColor: const Color(0xffFB7185),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStudyStatisticsItemWidget({
    required String svg,
    required String title,
    required String value,
    required String suffix,
    required Color valueColor,
  }){
    return Expanded(
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 4.wMin,
          children: [
            Row(
              spacing: 4.wMin,
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  svg,
                  width: 16.wMin,
                  colorFilter: ColorFilter.mode(valueColor, BlendMode.srcIn),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.wMin,
                    color: AppTheme.cTextSecondary.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            Row(
              spacing: 4.wMin,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28.wMin,
                    color: valueColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  suffix,
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color: AppTheme.cTextTertiary.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildDividerWidget(){
    return Container(
      width: 1.wMin,
      height: 64.wMin,
      margin: EdgeInsets.symmetric(horizontal: 12.wMin),
      color: AppTheme.cBorderPrimary.color,
    );
  }


  /// 计划卡片模块
  Widget _buildPlanWidget(){
    return Obx((){
      if(controller.planList.isEmpty) return Container();
      return StudyPlanCardWidget(
        initPlanIndex: controller.planIndex,
        planList: controller.planList.toList(),
        onRefresh: controller.initData,
        isShowFirstRunningCard: true,
        maskBgColor: AppTheme.cSurfacePrimary.color.withValues(alpha: 0.6),
        widgetIds: StudyPlanCardWidgetIds(
          pageCode: AppRoutesCode.studyPlan,
          studyPlanAddCourseButton: GuideWidgetIds.studyPlanAddCourseButton,
          studyPlanStartPlanButton: GuideWidgetIds.studyPlanStartPlanButton,
          studyPlanPausePlanButton: GuideWidgetIds.studyPlanPausePlanButton,
          studyPlanResumePlanButton: GuideWidgetIds.studyPlanResumePlanButton,
          studyPlanEditPlanButton: GuideWidgetIds.studyPlanEditPlanButton,
          studyPlanAdvanceStudyButton: GuideWidgetIds.studyPlanAdvanceStudyButton,
          studyPlanAddTextbookButton: GuideWidgetIds.studyPlanAddTextbookButton,
        ),
      );
    });
  }


}
