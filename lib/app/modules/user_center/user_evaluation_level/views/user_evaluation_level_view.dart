import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:langwise/common/widgets/guide_engine/guide_engine.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:get/get.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/widgets/study_plan_widgets/study_plan_widget.dart';
import '../../../../routes/routes.dart';
import '../../../../routes/tag_routes.dart';
import '../bindings/user_evaluation_level_binding.dart';
import '../controllers/user_evaluation_level_controller.dart';
import 'user_evaluation_level_cefr_widget.dart';
import 'user_evaluation_level_latitude_widget.dart';

class UserEvaluationLevelView extends GetView<UserEvaluationLevelController> {
  final String tagText;
  const UserEvaluationLevelView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      () => UserEvaluationLevelView(tagText: tag),
      binding: UserEvaluationLevelBinding(tagText: tag),
      routeName: Routes.USER_EVALUATION_LEVEL,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GuidePageBoxWidget(
      pageCode: AppRoutesCode.userEvaluationLevelResult,
      child: Scaffold(
        backgroundColor: AppTheme.cBgPrimary.color,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.cBgBrand.color.withValues(alpha: 0.3),
                AppTheme.cBgBrand.color.withValues(alpha: 0),
              ],
            ),
          ),
          child: Column(
            children: [
              _buildTitleWidget(context),
              SizedBox(height: 10.wMin),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 110.wMin),
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(40.wMin)),
                    child: SingleChildScrollView(
                      controller: controller.scrollController,
                      child: Column(
                        children: [
                          RepaintBoundary(
                            key: controller.sharePageKey,
                            child: Column(
                              children: [
                                UserEvaluationLevelCefrWidget(tagText: tagText),
                                Obx(() {
                                  if (controller.aiResultDetail.value?.isZeroBased ?? false) {
                                    return const SizedBox.shrink();
                                  }
                                  return UserEvaluationLevelLatitudeWidget(tagText: tagText);
                                }),
                                _aiReport(),
                                Obx(() {
                                  final sec = controller.reportDurationSec.value;
                                  if (sec > 0) {
                                    return _buildGeneratingPlanWidget(sec);
                                  }
                                  return _buildPlanWidget();
                                }),
                                SizedBox(height: 40.wMin),
                                // const UserEvaluationLevelOverallWidget(),
                                // SizedBox(height: 40.wMin),
                              ],
                            ),
                          ),
                          _buildFooter(context),
                          SizedBox(height: 100.wMin + MediaQuery.of(context).padding.bottom),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanWidget() {
    if (controller.planList.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: EdgeInsets.only(top: 40.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40.wMin),
        color: AppTheme.cBgSecondary.color.withValues(alpha: 0.8),
      ),
      padding: EdgeInsets.only(top: 24.wMin, bottom: 24.wMin),
      child: Column(
        children: [
          EvaluationTitleWidget(
            title: "个性化学习规划",
            subTitle: "AI为你定制的学习计划",
          ),
          SizedBox(height: 20.wMin),
          GuideStepWidget(
            id: GuideWidgetIds.userEvaluationLevelResultLearningPlanModule,
            ensureVisibleAlignment: 1.5,
            child: SizedBox(
              height: 880.wMin,
              child: StudyPlanCardWidget(
                controller: controller.studyPlanCardController,
                isShowCustomPlanButton: true,
                planList: controller.planList.toList(),
                maskBgColor: AppTheme.cBgSecondary.color.withValues(alpha: 0.6),
                onRefresh: controller.getAssessmentResultDetail,
                onRefreshAndReturnNewPlanList: () async{
                  await controller.getAssessmentResultDetail();
                  return controller.planList.toList();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratingPlanWidget(int sec) {
    final double progress = (1 - (sec / 600)).clamp(0.0, 1.0);
    return Container(
      margin: EdgeInsets.only(top: 40.wMin),
      child: GuideStepWidget(
        id: GuideWidgetIds.userEvaluationLevelResultMakingPlanModule,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40.wMin),
            color: AppTheme.cBgSecondary.color.withValues(alpha: 0.8),
          ),
          padding: EdgeInsets.symmetric(horizontal: 40.wMin, vertical: 32.wMin),
          child: Column(
            children: [
              EvaluationTitleWidget(
                title: "AI 正在为你定制学习方案",
                subTitle: "智能分析评测数据，规划三大课程多阶段学习路径",
              ),
              SizedBox(height: 18.wMin),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.wMin, vertical: 10.wMin),
                decoration: BoxDecoration(
                  color: AppTheme.cBgBrand.color.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppTheme.cBgBrand.color.withValues(alpha: 0.3)),
                ),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '预计用时 ',
                        style: TextStyle(
                          fontSize: 22.wMin,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.cTextPrimary.color,
                        ),
                      ),
                      TextSpan(
                        text: _formatMMSS(sec),
                        style: TextStyle(
                          fontSize: 34.wMin,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.cBgBrand.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 40.wMin),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 24.wMin,
                children: [
                  _buildGeneratingProgressCard(
                    title: SpecialtyEnum.getCourseName(SpecialtyEnum.EN_OFFICIAL)??"",
                    subTitle: '智能匹配阶梯难度',
                    bgColor: const Color(0xff0EA5E9).withValues(alpha: 0.12),
                    colors: const [Color(0xFF0EA5E9), Color(0xFF0EA5E9)],
                    progress: progress,
                  ),
                  _buildGeneratingProgressCard(
                    title: SpecialtyEnum.getCourseName(SpecialtyEnum.EN_TEXTBOOK)??"",
                    subTitle: '选择最佳起始教材',
                    bgColor: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                    colors: const [Color(0xFFFBBF24), Color(0xFFFBBF24)],
                    progress: progress,
                  ),
                  _buildGeneratingProgressCard(
                    title: SpecialtyEnum.getCourseName(SpecialtyEnum.EN_PHONICS)??"",
                    subTitle: '巩固发音基础',
                    bgColor: const Color(0xFFA855F7).withValues(alpha: 0.12),
                    colors: const [Color(0xFFC084FC), Color(0xFFC084FC)],
                    progress: progress,
                  ),
                ],
              ),
              SizedBox(height: 24.wMin),
              Text(
                'AI正在分析你的听说读写四维数据，生成个性化学习报告',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextSecondary.color,
                ),
              ),
              SizedBox(height: 8.wMin),
              Text(
                '你可以先查看上方的评测分数，报告生成后将自动显示',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextTertiary.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeneratingProgressCard({
    required String title,
    required String subTitle,
    required Color bgColor,
    required List<Color> colors,
    required double progress,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(22.wMin),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.wMin), color: bgColor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 32.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
            SizedBox(height: 6.wMin),
            Text(
              subTitle,
              style: TextStyle(
                fontSize: 22.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextTertiary.color,
              ),
            ),
            SizedBox(height: 18.wMin),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 8.wMin,
                value: progress,
                backgroundColor: AppTheme.cWhiteAlpha20.color,
                valueColor: AlwaysStoppedAnimation(colors.first),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMMSS(int sec) {
    final s = sec < 0 ? 0 : sec;
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$m:$ss';
  }

  Widget _buildTitleWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BreadcrumbWidget(
          actionWidget: TapScaleWidget(
            onTap: () {
              controller.showShareDialog(context);
            },
            sclae: 1.02,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 32.wMin, vertical: 8.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: AppTheme.cBgBrand.color,
              ),
              child: Row(
                spacing: 8.wMin,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    "assets/svg/public/icon_share.svg",
                    width: 32.wMin,
                  ),
                  Text(
                    "分享",
                    style: TextStyle(
                      fontSize: 28.wMin,
                      color: AppTheme.cStaticWhite.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 72.wMin),
          child: Text(
            "你的英语水平评测已完成，以下是详细结果",
            style: TextStyle(
              fontSize: 24.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 40.wMin,
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(32.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32.wMin),
              color: AppTheme.cBgSecondary.color.withValues(alpha: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '历史评测',
                          style: TextStyle(
                            fontSize: 32.wMin,
                            color: AppTheme.cTextPrimary.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8.wMin),
                        Text(
                          '查看成长轨迹',
                          style: TextStyle(
                            fontSize: 22.wMin,
                            color: AppTheme.cTextTertiary.color,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    TapScaleWidget(
                      onTap: () {
                        if(!HttpAuthUtils.instance.isAuth(HttpAuthCodes.studyMemberCourseAssessmentHistoryPages)) {
                          ToastUtils.showToast(text: "无权限");
                          return;
                        }
                        TagRoutes.toNamed(Routes.ASSESSMENT_HISTORY_TIME_MACHINE);
                      },
                      child: Container(
                        height: 56.wMin,
                        width: 56.wMin,
                        alignment: Alignment.center,
                        color: Colors.transparent,
                        child: SvgPicture.asset(
                          "assets/svg/manage/icon_chevron_right.svg",
                          width: 32.wMin,
                          height: 32.wMin,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.wMin),
                SizedBox(
                  height: (88 * 3 + 24 * 2).wMin,
                  child: Obx(() {
                    final historyList = controller.assessmentHistory.value;
                    if (historyList.isEmpty) return const SizedBox.shrink();
                    List<Color> colors = [
                      AppTheme.cTextBrand.color,
                      const Color(0xFF00D492),
                      const Color(0xFFC084FC),
                      const Color(0xFFFB923C),
                    ];
                    return ListView.separated(
                      itemBuilder: (ctx, idx) {
                        var item = historyList[idx];
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.wMin),
                            color: AppTheme.cSurfaceSecondary.color,
                            border: Border.all(color: AppTheme.cBorderPrimary.color),
                          ),
                          padding: EdgeInsets.all(24.wMin),
                          height: 88.wMin,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 180,
                                child: Text(
                                  DateFormatUtil.formatStr(item.assessmentDate ?? DateTime.now()),
                                  style: TextStyle(
                                    fontSize: 24.wMin,
                                    color: AppTheme.cTextPrimary.color,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 139,
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(vertical: 2.wMin, horizontal: 12.wMin),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(color: StatusUtils.getDifficultyBackgroundColor(1).color1, borderRadius: BorderRadius.circular(8.wMin)),
                                      child: Text(
                                        '${item.cefr}',
                                        style: TextStyle(
                                          fontSize: 24.wMin,
                                          color: AppTheme.cTextPrimary.color,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    Spacer()
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 432,
                                child: Row(
                                    children: List.generate(item.tierSkills!.length, (index) {
                                  var tSkill = item.tierSkills?[index];

                                  return Expanded(
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text((tSkill!.title?.where((e) => e?.lang == 'zh').first?.text ?? ''),
                                            style: TextStyle(color: colors[index], fontWeight: FontWeight.w600, fontSize: 22.wMin)),
                                        SizedBox(width: 4.wMin),
                                        Text(
                                          '${tSkill.score}',
                                          style: TextStyle(
                                            fontSize: 24.wMin,
                                            color: AppTheme.cTextPrimary.color,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList()),
                              )
                            ],
                          ),
                        );
                      },
                      itemCount: historyList.length,
                      separatorBuilder: (BuildContext context, int index) {
                        return SizedBox(height: 24.wMin);
                      },
                    );
                  }),
                ),
                SizedBox(height: 48.wMin),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(32.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32.wMin),
              color: AppTheme.cBgSecondary.color.withValues(alpha: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Text(
                      '重新评测',
                      style: TextStyle(
                        fontSize: 32.wMin,
                        color: AppTheme.cTextPrimary.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.wMin),
                    Text(
                      '检验学习成果',
                      style: TextStyle(
                        fontSize: 22.wMin,
                        color: AppTheme.cTextTertiary.color,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.wMin),
                Obx(() {
                  var lastAssessment = controller.aiResultDetail.value?.lastAssessment ?? '';
                  if (lastAssessment.isEmpty) return const SizedBox.shrink();
                  int lessDays = DateTime.now().difference(DateFormatUtil.tryParseDate(lastAssessment)!).inDays;
                  return Container(
                    padding: EdgeInsets.all(24.wMin),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.wMin), color: AppTheme.cSurfaceSecondary.color, border: Border.all(color: AppTheme.cBorderPrimary.color)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '上次评测时间:${DateFormatUtil.formatStrtoStr(lastAssessment, newPattern: 'yyyy年MM月dd日')}',
                          style: TextStyle(fontSize: 24.wMin, color: AppTheme.cTextPrimary.color, fontWeight: FontWeight.w600),
                        ),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 24.wMin,
                              color: AppTheme.cTextPrimary.color,
                              fontWeight: FontWeight.w400,
                            ),
                            children: [
                              if (lessDays > 0)
                                TextSpan(
                                  text: '距离上次评测$lessDays天，',
                                  style: TextStyle(
                                    fontSize: 24.wMin,
                                    color: AppTheme.cTextPrimary.color,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              (controller.currentMemberInfo.value?.nextRecommendDay ?? 0) <= 0
                                  ? const TextSpan(text: '可评测', style: TextStyle(color: AppTheme.cFeedbackSuccessText))
                                  : TextSpan(
                                      text: '建议${controller.currentMemberInfo.value?.nextRecommendDay ?? 0}天后评测',
                                      style: const TextStyle(
                                        color: AppTheme.cFeedbackErrorText,
                                      ),
                                    )
                            ],
                          ),
                        ),
                        SizedBox(height: 8.wMin),
                        Text(
                          '语言学习需要时间沉淀。研究表明，系统学习3个月后才能产生可测量的进步。 频繁测试反而会打击学习信心，影响学习节奏。',
                          style: TextStyle(fontSize: 24.wMin, color: AppTheme.cTextSecondary.color, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  );
                }),
                SizedBox(height: 32.wMin),
                Obx(() {
                  var days = controller.currentMemberInfo.value?.assessmentFreeDay ?? 0;
                  var freeCnt = controller.currentMemberInfo.value?.freeAssessmentCount ?? 0;
                  if (days <= 0 || freeCnt > 0) {
                    return GuideStepWidget(
                      id: GuideWidgetIds.userEvaluationLevelResultTestButton,
                      onTap: () async {
                        controller.reEvaluation(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.wMin),
                          color: AppTheme.cSurfaceInfo.color,
                          border: Border.all(color: AppTheme.cSurfaceInfo.color),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 15.wMin),
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '开始免费评测',
                              style: TextStyle(fontSize: 28.wMin, color: AppTheme.cTextPrimary.color, fontWeight: FontWeight.w400),
                            ),
                            if (freeCnt > 0)
                              Text(
                                '(剩余$freeCnt次)',
                                style: TextStyle(fontSize: 24.wMin, color: AppTheme.cTextPrimary.color, fontWeight: FontWeight.w400),
                              ),
                          ],
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      Text(
                        '${controller.currentMemberInfo.value?.assessmentFreeDay} 天后解锁免费评测',
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: AppTheme.cFeedbackSuccessText.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 16.wMin),
                      GuideStepWidget(
                        id: GuideWidgetIds.userEvaluationLevelResultTestButton,
                        onTap: () async {
                          //todo:学点评测
                          controller.assessmentPay(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.wMin),
                            color: AppTheme.cFeedbackWarningBackground.color,
                            border: Border.all(color: AppTheme.cFeedbackWarningBorder.color),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 15.wMin),
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: Text(
                            '使用 ${controller.currentMemberInfo.value?.assessmentPrice}学点提前评测',
                            style: TextStyle(fontSize: 28.wMin, color: AppTheme.cFeedbackWarningText.color, fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.wMin),
                      Text(
                        '适合急需了解当前水平的情况',
                        style: TextStyle(fontSize: 22.wMin, color: AppTheme.cTextTertiary.color, fontWeight: FontWeight.w400),
                      )
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _aiReport() {
    return Obx(() {
      if (controller.reportDurationSec.value > 0 || controller.aiResultDetail.value?.report == null) {
        return Container();
      }
      return Container(
        margin: EdgeInsets.only(top: 40.wMin),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40.wMin),
          color: AppTheme.cBgSecondary.color.withValues(alpha: 0.8),
        ),
        child: Column(
          children: [
            SizedBox(height: 32.wMin),
            EvaluationTitleWidget(
              title: "个性化学习方案",
            ),
            SizedBox(height: 24.wMin),
            Obx(
              () {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 120.wMin),
                  padding: EdgeInsets.all(24.wMin),
                  child: AppMarkdownWidget(
                    data: controller.aiResultDetail.value?.report ?? "",
                  ),
                );
              },
            ),
            SizedBox(height: 32.wMin)
          ],
        ),
      );
    });
  }
}
