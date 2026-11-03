import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:langwise/common/widgets/guide_engine/guide_anchor.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:markdown_widget/config/configs.dart';
import 'package:markdown_widget/widget/blocks/all.dart';
import 'package:markdown_widget/widget/inlines/code.dart';
import 'package:markdown_widget/widget/markdown.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:get/get.dart';
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
      UserEvaluationLevelView(tagText: tag),
      binding: UserEvaluationLevelBinding(tagText: tag),
      routeName: Routes.USER_EVALUATION_LEVEL,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    child: Column(
                      children: [
                        RepaintBoundary(
                          key: controller.sharePageKey,
                          child: Column(
                            children: [
                              UserEvaluationLevelCefrWidget(tagText: tagText),
                              SizedBox(height: 40.wMin),
                              Obx(() {
                                return (controller.aiResultDetail.value?.isZeroBased ?? false) ? const SizedBox.shrink() : UserEvaluationLevelLatitudeWidget(tagText: tagText);
                              }),
                              SizedBox(height: 40.wMin),
                              _aiReport(),
                              SizedBox(height: 40.wMin),
                              Obx(() {
                                final sec = controller.reportDurationSec.value;
                                if (sec > 0) {
                                  return Padding(
                                    padding: EdgeInsets.only(top: 40.wMin),
                                    child: _buildGeneratingPlanWidget(sec),
                                  );
                                }
                                final pages = controller.learningPlanPages;
                                if (pages.isEmpty) return const SizedBox.shrink();
                                return Padding(
                                    padding: EdgeInsets.only(top: 40.wMin),
                                    child: Container(
                                      height: 1100.wMin,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(40.wMin),
                                        color: AppTheme.cSurfacePrimary.color,
                                      ),
                                      padding: EdgeInsets.only(top: 24.wMin, bottom: 64.wMin),
                                      child: GuideAnchor(
                                        id: 'look_plan',
                                        route: Routes.USER_EVALUATION_LEVEL,
                                        child: PersonalizedLearningPlanWidget(
                                            title: '个性化学习规划',
                                            showTitle: true,
                                            isNoticeDialog: controller.aiResultDetail.value?.validAssessmentPlan??false,
                                            hideClearButton: true,
                                            titleGradient: [
                                              const Color(0xFFFFFFFF).withValues(alpha: 0.5),
                                              const Color(0xFFFFFFFF),
                                            ],
                                            description: 'AI为你定制的学习计划，点击卡片查看详情',
                                            pages: pages,
                                            controller: controller.learningPlanController),
                                      ),
                                    ));
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
    );
  }

  Widget _buildGeneratingPlanWidget(int sec) {
    final double progress = (1 - (sec / 600)).clamp(0.0, 1.0);
    return GuideAnchor(
      id: 'look_plan',
      route: Routes.USER_EVALUATION_LEVEL,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40.wMin),
          color: AppTheme.cSurfacePrimary.color,
        ),
        padding: EdgeInsets.symmetric(horizontal: 40.wMin, vertical: 32.wMin),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  spacing: 10.wMin,
                  children: [
                    _buildTitleLineWidget(),
                    _buildTitleLineWidget(),
                  ],
                ),
                SizedBox(width: 12.wMin),
                Text(
                  'AI 正在为你定制学习方案',
                  style: TextStyle(
                    fontSize: 34.wMin,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.cTextPrimary.color,
                  ),
                ),
                SizedBox(width: 12.wMin),
                Column(
                  spacing: 10.wMin,
                  children: [
                    _buildTitleLineWidget(false),
                    _buildTitleLineWidget(false),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10.wMin),
            Text(
              '智能分析评测数据，规划三大课程多阶段学习路径',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextSecondary.color,
              ),
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
                  title: '官方主课程',
                  subTitle: '智能匹配阶梯难度',
                  bgColor: const Color(0x0D22C55E),
                  colors: const [Color(0xFF00D0A0), Color(0xFF00B980)],
                  progress: progress,
                ),
                SizedBox(width: 16.wMin),
                _buildGeneratingProgressCard(
                  title: '教材拓展课',
                  subTitle: '选择最佳起始教材',
                  bgColor: const Color(0x0D06B6D4),
                  colors: const [Color(0xFF3B82F6), Color(0xFF2563EB)],
                  progress: progress,
                ),
                SizedBox(width: 16.wMin),
                _buildGeneratingProgressCard(
                  title: '自然拼读课',
                  subTitle: '巩固发音基础',
                  bgColor: const Color(0x0DA855F7),
                  colors: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
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
    );
  }

  Widget _buildTitleLineWidget([bool isLeft = true]) {
    return Container(
      height: 2.wMin,
      width: 56.wMin,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: isLeft ? Alignment.centerRight : Alignment.centerLeft,
          end: isLeft ? Alignment.centerLeft : Alignment.centerRight,
          colors: [
            AppTheme.cTextPrimary.color.withValues(alpha: 0.8),
            AppTheme.cBgBrand.color.withValues(alpha: 0),
          ],
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
    return Container(
      padding: EdgeInsets.all(22.wMin),
      width: 412.wMin,
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
              backgroundColor: AppTheme.cWhiteAlpha10.color,
              valueColor: AlwaysStoppedAnimation(colors.first),
            ),
          ),
        ],
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40.wMin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + 24.wMin),
              const BackWidget(title: "英语评测结果"),
              Container(
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
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 110.wMin - 40.wMin),
            child: TapScaleWidget(
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
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, spacing: 40.wMin, children: [
      Expanded(
          child: Container(
        padding: EdgeInsets.all(32.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32.wMin),
          color: AppTheme.cSurfacePrimary.color,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('历史评测',
                        style: TextStyle(
                          fontSize: 32.wMin,
                          color: AppTheme.cTextPrimary.color,
                          fontWeight: FontWeight.w600,
                        )),
                    SizedBox(height: 8.wMin),
                    Text('查看成长轨迹',
                        style: TextStyle(
                          fontSize: 22.wMin,
                          color: AppTheme.cTextTertiary.color,
                          fontWeight: FontWeight.w400,
                        )),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    TagRoutes.toNamed(Routes.ASSESSMENT_HISTORY_TIME_MACHINE);
                  },
                  child: Container(
                      height: 56.wMin,
                      width: 56.wMin,
                      alignment: Alignment.center,
                      child: SvgPicture.asset("assets/svg/manage/icon_chevron_right.svg", width: 32.wMin, height: 32.wMin)),
                ),
              ],
            ),
            SizedBox(height: 24.wMin),
            SizedBox(
              height: (88 * 3 + 24 * 2).wMin,
              child: Obx(() {
                final historyList = controller.assessmentHistory.value;
                if (historyList.isEmpty) return const SizedBox.shrink();
                List<Color> colors = [AppTheme.cTextBrand.color, const Color(0xFF00D492), const Color(0xFFC084FC), const Color(0xFFFB923C)];
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
                            child: Text(DateFormatUtil.formatStr(item.assessmentDate ?? DateTime.now()),
                                style: TextStyle(
                                  fontSize: 24.wMin,
                                  color: AppTheme.cTextPrimary.color,
                                  fontWeight: FontWeight.w400,
                                )),
                          ),
                          Expanded(
                              flex: 139,
                              child: Row(children: [
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 2.wMin, horizontal: 12.wMin),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(color: StatusUtils.getDifficultyBackgroundColor(1).color1, borderRadius: BorderRadius.circular(8.wMin)),
                                  child: Text('${item.cefr}',
                                      style: TextStyle(
                                        fontSize: 24.wMin,
                                        color: AppTheme.cTextPrimary.color,
                                        fontWeight: FontWeight.w400,
                                      )),
                                ),
                                Spacer()
                              ])),
                          Expanded(
                            flex: 432,
                            child: Row(
                                children: List.generate(item.tierSkills!.length, (index) {
                              var tSkill = item.tierSkills?[index];

                              return Expanded(
                                child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                  Text((tSkill!.title?.where((e) => e?.lang == 'zh').first?.text ?? ''),
                                      style: TextStyle(color: colors[index], fontWeight: FontWeight.w600, fontSize: 22.wMin)),
                                  SizedBox(width: 4.wMin),
                                  Text('${tSkill.score}',
                                      style: TextStyle(
                                        fontSize: 24.wMin,
                                        color: AppTheme.cTextPrimary.color,
                                        fontWeight: FontWeight.w600,
                                      )),
                                ]),
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
      )),
      Expanded(
          child: Container(
        padding: EdgeInsets.all(32.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32.wMin),
          color: AppTheme.cSurfacePrimary.color,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(children: [
              Text('重新评测',
                  style: TextStyle(
                    fontSize: 32.wMin,
                    color: AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w600,
                  )),
              SizedBox(height: 8.wMin),
              Text('检验学习成果',
                  style: TextStyle(
                    fontSize: 22.wMin,
                    color: AppTheme.cTextTertiary.color,
                    fontWeight: FontWeight.w400,
                  )),
            ]),
            SizedBox(height: 24.wMin),
            Obx(() {
              var lastAssessment = controller.aiResultDetail.value?.lastAssessment??'';
              if(lastAssessment.isEmpty)return const SizedBox.shrink();
              int lessDays = DateTime.now().difference(DateFormatUtil.tryParseDate(lastAssessment)!).inDays;
              return Container(
                  padding: EdgeInsets.all(24.wMin),
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(16.wMin), color: AppTheme.cSurfaceSecondary.color, border: Border.all(color: AppTheme.cBorderPrimary.color)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '上次评测时间:${DateFormatUtil.formatStrtoStr(lastAssessment,newPattern: 'yyyy年MM月dd日')}',
                        style: TextStyle(fontSize: 24.wMin, color: AppTheme.cTextPrimary.color, fontWeight: FontWeight.w600),
                      ),
                      RichText(text:TextSpan(text: '距离现在$lessDays天,',style: TextStyle(fontSize: 24.wMin, color: AppTheme.cTextPrimary.color, fontWeight: FontWeight.w400),children: [
                        lessDays>=90?const TextSpan(
                          text: '可评测',style: TextStyle(color: AppTheme.cFeedbackSuccessText)
                        ):TextSpan(
                          text: '建议${controller.currentMemberInfo.value?.nextRecommendDay??0}天后评测',style: const TextStyle(color: AppTheme.cFeedbackErrorText)
                        )
                      ])),
                      SizedBox(height: 8.wMin),
                      Text(
                        '语言学习需要时间沉淀。研究表明，系统学习3个月后才能产生可测量的进步。 频繁测试反而会打击学习信心，影响学习节奏。',
                        style: TextStyle(fontSize: 24.wMin, color: AppTheme.cTextSecondary.color, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ));
            }),
            SizedBox(height: 32.wMin),
            Obx(() {
              var days = controller.currentMemberInfo.value?.assessmentFreeDay ?? 0;
              var freeCnt = controller.currentMemberInfo.value?.freeAssessmentCount ?? 0;
              if (days <= 0 || freeCnt > 0) {
                return GestureDetector(
                  onTap: () {
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
                      )),
                );
              }
              return Column(children: [
                Text(
                  '${controller.currentMemberInfo.value?.assessmentFreeDay} 天后解锁免费评测',
                  style: TextStyle(fontSize: 24.wMin, color: AppTheme.cFeedbackSuccessText.color, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 16.wMin),
                GestureDetector(
                  onTap: () {
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
                      )),
                ),
                SizedBox(height: 16.wMin),
                Text(
                  '适合急需了解当前水平的情况',
                  style: TextStyle(fontSize: 22.wMin, color: AppTheme.cTextTertiary.color, fontWeight: FontWeight.w400),
                )
              ]);
            }),
          ],
        ),
      ))
    ]);
  }

  Widget _aiReport() {
    return Obx(() {
      if (controller.reportDurationSec.value > 0 || controller.aiResultDetail.value?.report == null) {
        return Container();
      }
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40.wMin),
          color: AppTheme.cSurfacePrimary.color,
        ),
        child: Column(
          children: [
            SizedBox(height: 32.wMin),
            Row(
              spacing: 12.wMin,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  spacing: 12.wMin,
                  children: [
                    _buildTitleLineWidget(),
                    _buildTitleLineWidget(),
                  ],
                ),
                ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFFFFFFF).withValues(alpha: 0.5),
                        const Color(0xFFFFFFFF),
                      ],
                    ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
                  },
                  child: Text(
                    '个性化学习方案',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 56.wMin,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.cTextPrimary,
                    ),
                  ),
                ),
                Column(
                  spacing: 12.wMin,
                  children: [
                    _buildTitleLineWidget(false),
                    _buildTitleLineWidget(false),
                  ],
                ),
              ],
            ),
            SizedBox(height: 32.wMin),
            Obx(
              () {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 120.wMin),
                  padding: EdgeInsets.all(24.wMin),
                  child: MarkdownWidget(
                    data: controller.aiResultDetail.value?.report ?? "",
                    config: MarkdownConfig(
                      configs: [
                        PConfig(
                          textStyle: TextStyle(
                            fontSize: 28.wMin,
                            height: 1.6,
                            letterSpacing: 0.2,
                            color: AppTheme.cTextSecondary.color,
                          ),
                        ),
                        H1Config(
                          style: TextStyle(
                            fontSize: 56.wMin,
                            height: 1.2,
                            color: AppTheme.cTextSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        H2Config(
                          style: TextStyle(
                            fontSize: 48.wMin,
                            height: 1.25,
                            color: AppTheme.cTextPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        H3Config(
                          style: TextStyle(
                            fontSize: 30.wMin,
                            height: 1.3,
                            color: const Color(0xFFBFE6FF),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        H4Config(
                          style: TextStyle(
                            fontSize: 28.wMin,
                            height: 1.35,
                            color: const Color(0xFFD7C7FF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        H5Config(
                          style: TextStyle(
                            fontSize: 27.wMin,
                            height: 1.35,
                            color: const Color(0xFFFFE2B8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        H6Config(
                          style: TextStyle(
                            fontSize: 26.wMin,
                            height: 1.35,
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        LinkConfig(
                          style: TextStyle(
                            fontSize: 28.wMin,
                            height: 1.6,
                            color: AppTheme.cTextBrand.color,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        HrConfig(
                          height: 1,
                          color: AppTheme.cBorderPrimary.color.withValues(alpha: 0.6),
                        ),
                        TableConfig(
                          border: TableBorder.all(
                            color: AppTheme.cBorderSecondary,
                          ),
                          defaultColumnWidth: const FlexColumnWidth(),
                          bodyStyle: TextStyle(fontSize: 28.wMin,fontWeight: FontWeight.w400,height: 1.25),
                          headerStyle: TextStyle(fontSize: 28.wMin,fontWeight: FontWeight.w500,height: 1.25),
                        ),
                        BlockquoteConfig(
                          sideColor: AppTheme.cTextBrand.color.withValues(alpha: 0.85),
                          textColor: AppTheme.cTextSecondary.color,
                          sideWith: 4.wMin,
                          padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 12.wMin),
                          margin: EdgeInsets.symmetric(vertical: 12.wMin),
                        ),
                        CodeConfig(
                          style: TextStyle(
                            fontSize: 26.wMin,
                            height: 1.5,
                            color: Colors.white,
                            fontFamily: 'monospace',
                            backgroundColor: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        PreConfig(
                          padding: EdgeInsets.all(16.wMin),
                          margin: EdgeInsets.symmetric(vertical: 12.wMin),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(12.wMin),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.10),
                              width: 1,
                            ),
                          ),
                          textStyle: TextStyle(
                            fontSize: 26.wMin,
                            height: 1.5,
                            color: Colors.white.withValues(alpha: 0.9),
                            fontFamily: 'monospace',
                          ),
                          styleNotMatched: TextStyle(
                            fontSize: 16.wMin,
                            height: 1.5,
                            color: Colors.white.withValues(alpha: 0.9),
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                    shrinkWrap: true, // 使 Widget 高度随内容自适应
                    physics: const NeverScrollableScrollPhysics(), // 禁止内部滚动
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
