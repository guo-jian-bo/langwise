import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/specialty/model/speciaity_phonics_model.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/common/enum/specialty_enum.dart';
import 'package:langwise/common/values/language_service_code.dart';
import 'package:langwise/common/widgets/guide_engine/guide_anchor.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../../../../common/entities/entities.dart';
import '../../../../common/widgets/hero_widget.dart';
import '../../../../common/widgets/line_chart_widget.dart';
import '../../../../theme/theme.dart';
import '../controllers/today_plan_controller.dart';

class TodayPlanPage extends GetView<TodayPlanController> {
  final StudyPlanEntityPlanCourses data;
  final int index;
  final int courseId;
  final List<Color> colors;
  const TodayPlanPage({super.key, required this.data, required this.index, required this.courseId, required this.colors});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (data.courseId == null) {
        if (index == 0) {
          return _blankWidget();
        } else if (index == 1) {
          return _blankWidget();
        } else {
          return _blankWidget();
        }
      }
      return CardNeatBoxWidget(
        borderRadius: 16.wMin,
        height: 804.wMin,
        padding: EdgeInsets.all(24.wMin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.wMin),
                gradient: LinearGradient(colors: colors, begin: Alignment.topCenter, end: Alignment.bottomCenter),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTitleWidget(context),
                  Stack(
                    children: [
                      Column(children: [
                        SizedBox(
                          height: 392.wMin,
                          child: index == 2
                              ? _phonicsBody(data.moduleContentInfo)
                              : GridView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.all(18.wMin),
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: data.directionList?.length ?? 0,
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 16.wMin,
                                    crossAxisSpacing: 16.wMin,
                                    childAspectRatio: 228 / 74,
                                  ),
                                  itemBuilder: (context, index) {
                                    var item = data.directionList?[index];
                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16.wMin),
                                        color: const Color(0x26FFFFFF),
                                      ),
                                      padding: EdgeInsets.all(16.wMin),
                                      child: Row(
                                        children: [
                                          Text(LearningLangUtils.getLocalLang(item?.title)?.text ?? '',
                                              style: TextStyle(fontSize: 24.wMin, fontWeight: FontWeight.w600, color: AppTheme.cTextPrimary)),
                                          const Spacer(),
                                          if (!(item?.exclude ?? false))
                                            SvgPicture.asset(
                                              'assets/svg/public/icon_check_w.svg',
                                              width: 24.wMin,
                                              height: 24.wMin,
                                              colorFilter: const ColorFilter.mode(AppTheme.cTextPrimary, BlendMode.srcIn),
                                            )
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                        Container(
                          height: 144.wMin,
                          padding: EdgeInsets.all(24.wMin),
                          decoration: BoxDecoration(color: const Color(0x0DFFFFFF), borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.wMin))),
                          child: Row(mainAxisAlignment: index == 2 ? MainAxisAlignment.center : MainAxisAlignment.end, children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${((data.dailyStudyDuration ?? 0) ~/ 60).round()}',
                                  style: TextStyle(
                                    fontSize: 80.wMin,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    height: 1.0,
                                  ),
                                ),
                                SizedBox(width: 9.wMin),
                                Text(
                                  '分钟${index == 2 ? '' : '\n'}/今天',
                                  style: TextStyle(
                                    fontSize: 24.wMin,
                                    color: AppTheme.cTextPrimary.color,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ]),
                        )
                      ]),
                      if (data.pause ?? false) _buildPauseOverlayWidget(context)
                    ],
                  )
                ],
              ),
            ),
            SizedBox(height: 24.wMin),
            btn(context)
          ],
        ),
      );
    });
  }

  Widget _phonicsBody(SpeciaityPhonicsModelDataModuleContentInfo? model) {
    if (model == null) return SizedBox.shrink();
    List<PronunciationsEntity?> pronunciations = model.pronunciations ?? [];

    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 348.wMin,
            height: 348.wMin,
            color: Colors.transparent,
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.wMin),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    CachedImageWidget(
                      model.imageUrl ?? "",
                      placeholder: buildEmptyWidget(),
                      errorWidget: buildEmptyWidget(),
                    ),
                    Container(
                      width: double.infinity,
                      color: AppTheme.cBlackAlpha50.color,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          PronunciationsPlayIpaTextWidget(
                            ipa: data.startUnitInfo?.moduleTopic,
                            pronunciations: pronunciations,
                            national: LanguageServiceCode.US,
                            style: TextStyle(
                              fontSize: 110.wMin,
                              color: AppTheme.cInverseTextLight.color,
                              fontWeight: FontWeight.w700,
                              fontFamily: "AndikaRegular",
                            ),
                          ),
                          PronunciationsColorWidget(
                            content: model.content,
                            ipa: data.startUnitInfo?.moduleTopic,
                            pronunciations: pronunciations,
                            national: LanguageServiceCode.US,
                            style: TextStyle(
                              fontSize: 70.wMin,
                              color: AppTheme.cInverseTextLight.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 60.wMin),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(pronunciations.length, (index) {
                        return PlayLottieIconWidget(
                          size: 68.wMin,
                          audioUrl: pronunciations[index]?.audioUrl,
                          backgroundImageUrl: pronunciations[index]?.nationalIconUrl,
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _blankWidget() {
    return Container(
      width: 520.wMin,
      height: 626.wMin,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24.wMin), border: Border.all(color: AppTheme.cBorderSecondary), color: AppTheme.cSurfaceSecondary),
      child: Column(children: [
        Container(
            width: double.infinity,
            height: 84.wMin,
            alignment: Alignment.center,
            color: const Color(0x0DFFFFFF),
            child: Text(
                '添加${index == 0 ? '官方课程' : index == 1 ? '教材' : '发音课'}计划',
                style: TextStyle(color: AppTheme.cTextPrimary, fontSize: 32.wMin, fontWeight: FontWeight.w600))),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Get.toNamed(Routes.NEW_CREATE_STUDY_PLAN, arguments: {
                "titleName": index == 0
                    ? '官方课程'
                    : index == 1
                        ? '教材'
                        : '发音课',
                "courseId": courseId,
                "specialty": index == 0
                    ? SpecialtyEnum.EN_OFFICIAL
                    : index == 1
                        ? SpecialtyEnum.EN_TEXTBOOK
                        : SpecialtyEnum.EN_PHONICS
              });
            },
            child: Center(
                child: SvgPicture.asset('assets/svg/public/icon_add.svg',
                    colorFilter: const ColorFilter.mode(AppTheme.cBorderTertiary, BlendMode.srcIn), width: 120.wMin, height: 120.wMin)),
          ),
        )
      ]),
    );
  }

  /// 暂停蒙层
  Widget _buildPauseOverlayWidget(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 536.wMin,
      decoration: BoxDecoration(
        color: AppTheme.cBlackAlpha70.color.withValues(alpha: 0.8),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.wMin)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "该计划已暂停",
            style: TextStyle(
              fontSize: 32.wMin,
              fontWeight: FontWeight.w600,
              color: AppTheme.cFeedbackWarningText.color,
            ),
          ),
          SizedBox(height: 16.wMin),
          Visibility(
            visible: data.resumeDate != null,
            child: Text(
              "计划将于${data.resumeDate ?? ""}恢复",
              style: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextSecondary.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleWidget(BuildContext context) {
    String? planStartStr;
    if (data.currentUnitInfo?.levelName != null && data.currentUnitInfo?.moduleName != null && data.currentUnitInfo?.unitName != null) {
      planStartStr = "${data.currentUnitInfo?.levelName} / ${data.currentUnitInfo?.moduleName} / ${data.currentUnitInfo?.unitName}";
    }

    return Container(
        padding: EdgeInsets.symmetric(horizontal: 24.wMin),
        alignment: Alignment.centerLeft,
        height: 124.wMin,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.wMin)),
          color: const Color(0x33FFFFFF),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 8.wMin,
          children: [
            Text(
              data.courseName ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 32.wMin,
                color: AppTheme.cTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              planStartStr ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 24.wMin,
                color: AppTheme.cTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ));
  }

  Widget btn(BuildContext context) {
    return SizedBox(
      height: 72.wMin,
      child: Row(children: [
        Expanded(
          child: data.pause == true
              ? GuideAnchor(
                  id: 'resume_plan',
                  route: Routes.TODAY_PLAN,
                  child: ButtonWidget(
                    text: "立即恢复计划",
                    color: AppTheme.cFeedbackSuccessBackground.color,
                    borderRadius: 16.wMin,
                    height: 72.wMin,
                    padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 6.wMin),
                    fontColor: data.pause == true ? AppTheme.cFeedbackSuccessText.color : AppTheme.cFeedbackWarningText.color,
                    fontSize: 28.wMin,
                    fontWeight: FontWeight.w500,
                    sclae: 1.05,
                    onTap: () {
                      controller.pauseRecoverPlan(context, data);
                    },
                  ),
                )
              : GuideAnchor(
                  id: 'pause_plan',
                  route: Routes.TODAY_PLAN,
                  child: ButtonWidget(
                    text: "暂停新学",
                    color: AppTheme.cFeedbackWarningBackground.color,
                    borderRadius: 16.wMin,
                    height: 72.wMin,
                    padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 6.wMin),
                    fontColor: AppTheme.cFeedbackWarningText.color,
                    fontSize: 28.wMin,
                    fontWeight: FontWeight.w500,
                    sclae: 1.05,
                    onTap: () {
                      controller.pauseRecoverPlan(context, data);
                    },
                  ),
                ),
        ),
        SizedBox(width: 24.wMin),
        Expanded(
          child: GuideAnchor(
            id: 'edit_plan',
            route: Routes.TODAY_PLAN,
            child: ButtonWidget(
              text: "编辑计划",
              color: AppTheme.cFeedbackInfoBackground,
              borderRadius: 16.wMin,
              height: 72.wMin,
              padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 6.wMin),
              fontColor: AppTheme.cFeedbackInfoText,
              fontSize: 28.wMin,
              fontWeight: FontWeight.w500,
              sclae: 1.05,
              onTap: () {
                controller.toEditPlan(data, context, index);
              },
            ),
          ),
        ),
      ]),
    );
  }

  Size? _getTextSize(String? text) {
    if (text == null) return null;
    final TextStyle textStyle = TextStyle(
      fontSize: 18.wMin,
      fontWeight: FontWeight.w400,
      color: AppTheme.cStaticBlack,
    );

    // 获取文字的宽度
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    double width = textPainter.size.width + 10.wMin;
    if (width < 100.wMin) width = 100.wMin;
    if (width > 200.wMin) width = 200.wMin;
    return Size(width, 43.wMin);
  }

  Widget buildLineChart() {
    Size? size = _getTextSize(data.nextUnit);
    return HeroWidget(
      tag: "HomeStudyPlanChart$index",
      child: Container(
        width: 538.wMin,
        height: 330.wMin,
        padding: EdgeInsets.all(16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cBgTertiary,
        ),
        child: LineChartWidget(
          nextText: data.nextUnit,
          duration: Duration(milliseconds: controller.todayPlanPageIndex == index ? 500 : 0),
          delay: Duration(milliseconds: controller.todayPlanPageIndex == index ? 300 : 0),
          width: 538.wMin - 32.wMin,
          height: 330.wMin - 32.wMin,
          strokeWidth: 4.wMin,
          strokeColor: AppTheme.cTextPrimary.withValues(alpha: 0.2),
          padding: EdgeInsets.only(top: 90.wMin, left: 40.wMin, right: 42.wMin, bottom: 20.wMin),
          dotSize: 20.wMin,
          nowSize: Size(73.wMin, 43.wMin),
          nextSize: size ?? Size(93.wMin, 43.wMin),
          bubbleFontSize: 18.wMin,
          lineData: [],
        ),
      ),
    );
  }

  Widget buildSetUpTimes(String name, List<String> list) {
    return CardMinBox1Widget(
      padding: EdgeInsets.zero,
      child: Container(
        padding: EdgeInsets.all(10.wMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AutoSizeText(
              name,
              minFontSize: 4,
              maxLines: 1,
              style: TextStyle(
                fontSize: 20.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextPrimary,
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: list.length,
                padding: EdgeInsets.symmetric(vertical: 10.wMin),
                separatorBuilder: (context, index) => SizedBox(height: 7.68.wMin),
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.wMin),
                    width: double.infinity,
                    height: 40.wMin,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.wMin),
                      color: AppTheme.cBgQuaternary,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SvgPicture.asset("assets/svg/today_plan/icon_clock.svg", width: 18.wMin),
                        Text(
                          list[index],
                          style: TextStyle(
                            fontSize: 18.wMin,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.cTextPrimary,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSetUp() {
    List<StudyPlanEntityPlanCoursesPlans?> plans = data.plans ?? [];
    List<String> workList = [];
    List<String> restList = [];
    for (int i = 0; i < plans.length; i++) {
      if (plans[i] == null) continue;
      if (plans[i]!.type == null) continue;

      List<StudyPlanEntityPlanCoursesPlansTimes?> times = plans[i]!.times ?? [];
      for (int j = 0; j < times.length; j++) {
        if (times[j] == null) continue;
        int hour = times[j]!.hour ?? 0;
        int minute = times[j]!.minute ?? 0;
        String time = DateFormatUtil.hsToLocaleTime(hour, minute, locale: Get.locale);

        if (plans[i]!.type == "work") {
          workList.add(time);
        } else if (plans[i]!.type == "rest") {
          restList.add(time);
        }
      }
    }

    return Expanded(
      child: Row(
        spacing: (workList.isNotEmpty || restList.isNotEmpty) ? 16.wMin : 0,
        children: [
          Expanded(
            child: CardMinBox1Widget(
              padding: EdgeInsets.zero,
              child: SizedBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${(data.dailyStudyDuration ?? 0) ~/ 60}",
                      style: TextStyle(
                        fontSize: 64.wMin,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.cTextPrimary,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      "分钟",
                      style: TextStyle(
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cTextSecondary,
                      ),
                    ),
                    Text(
                      "每日计划时长",
                      style: TextStyle(
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Visibility(
            visible: workList.isNotEmpty,
            child: Expanded(
              child: buildSetUpTimes("工作日", workList),
            ),
          ),
          Visibility(
            visible: restList.isNotEmpty,
            child: Expanded(
              child: buildSetUpTimes("休息日", restList),
            ),
          ),
        ],
      ),
    );
  }
}
