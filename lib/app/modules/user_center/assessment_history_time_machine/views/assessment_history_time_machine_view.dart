import 'dart:math';
import 'dart:ui';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_chart_plus/flutter_chart.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/user_center/assessment_history_time_machine/widgets/radar_widget.dart';
import 'package:langwise/common/enum/lsrw_enum.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/widgets/widgets.dart';
import '../../../../routes/routes.dart';
import '../bindings/assessment_history_time_machine_binding.dart';
import '../controllers/assessment_history_time_machine_controller.dart';
import '../../../../../common/entities/entities.dart';

class AssessmentHistoryTimeMachineView extends GetView<AssessmentHistoryTimeMachineController> {
  final String tagText;
  const AssessmentHistoryTimeMachineView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      AssessmentHistoryTimeMachineView(tagText: tag),
      binding: AssessmentHistoryTimeMachineBinding(tagText: tag),
      routeName: Routes.ASSESSMENT_HISTORY_TIME_MACHINE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(color: AppTheme.cBgTertiary),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.15),
                        Colors.black.withValues(alpha: 0.25),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _buildCenter(context),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 40.wMin),
                Padding(
                  padding: EdgeInsets.only(top: 40.wMin),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: SvgPicture.asset(
                          'assets/svg/public/icon_arrow_back.svg',
                          colorFilter: const ColorFilter.mode(AppTheme.cTextPrimary, BlendMode.srcIn),
                          width: 32.wMin,
                        ),
                      ),
                      SizedBox(width: 8.wMin),
                      Text('历史评测', style: TextStyle(color: AppTheme.cTextPrimary, fontSize: 32.wMin, fontWeight: FontWeight.w600))
                    ],
                  ),
                ),
                Spacer(),
                Align(alignment: Alignment.centerRight, child: _SidePagerButtons(controller: controller)),
                SizedBox(width: 260.wMin, child: _buildTimeline(context)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenter(BuildContext context) {
    return Obx(
      () {
        if (controller.isLoading.value && controller.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.items.isEmpty) {
          return Center(
            child: Text(
              '暂无历史评测',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 28.wMin),
            ),
          );
        }

        return SizedBox(
          width: 1280.wMin,
          height: 960.wMin,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: 0.01,
                child: PageView.builder(
                  controller: controller.pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: controller.items.length,
                  itemBuilder: (context, index) => const SizedBox.expand(),
                ),
              ),
              _TimeMachineCardStack(
                controller: controller,
                itemBuilder: (idx) => _buildPageCard(controller.items[idx], idx),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPageCard(AssessmentHistoryItemEntity item, int index) {
    return Container(
      width: 1280.wMin,
      height: 960.wMin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.wMin),
        color: AppTheme.cSurfacePrimary.color,
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      padding: EdgeInsets.all(24.wMin),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 64.wMin,
              child: Row(
                children: [
                  Text(
                    '评测结果  ${DateFormatUtil.formatStr(item.assessmentDate ?? DateTime.now(), locale: Get.locale)}',
                    style: TextStyle(color: AppTheme.cTextPrimary, fontSize: 24.wMin, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Obx(() {
                    final current = controller.page.round().clamp(0, controller.items.length - 1);
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 6.wMin),
                      decoration: BoxDecoration(
                        color: AppTheme.cSurfaceInfo.color.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                      ),
                      child: Text(
                        '${current + 1}/${controller.items.length}',
                        style: TextStyle(color: AppTheme.cTextPrimary, fontSize: 20.wMin),
                      ),
                    );
                  }),
                ],
              ),
            ),
            SizedBox(height: 12.wMin),
            Column(
              children: [
                Container(
                  padding: EdgeInsets.all(24.wMin),
                  decoration: BoxDecoration(
                    color: AppTheme.cBgSecondary.color.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(40.wMin),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        children: [
                          Row(
                            spacing: 12.wMin,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                spacing: 3.wMin,
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
                                      AppTheme.cTextPrimary.color,
                                      AppTheme.cTextPrimary.color.withValues(alpha: 0.5),
                                    ],
                                    stops: const [0.18, 0.84],
                                  ).createShader(bounds);
                                },
                                child: Text(
                                  'CEFR等级认证',
                                  style: TextStyle(
                                    fontSize: 56.wMin,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.cTextPrimary.color,
                                  ),
                                ),
                              ),
                              Column(
                                spacing: 3.wMin,
                                children: [
                                  _buildTitleLineWidget(false),
                                  _buildTitleLineWidget(false),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 4.wMin),
                            child: Text(
                              "你的英语水平评估结果",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 32.wMin,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.cTextSecondary.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      _buildLevelWidget(item),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 32.wMin),
            _buildCefrBarChartWidget(item),
            SizedBox(height: 32.wMin),
            _radar(item),
            SizedBox(height: 32.wMin),
            _aiReport()
          ],
        ),
      ),
    );
  }

  Widget _radar(AssessmentHistoryItemEntity item) {
    return Obx(() {
      if (controller.cards.value?.isZeroBased ?? false) {
        return const SizedBox.shrink();
      }
      return Container(
        padding: EdgeInsets.all(24.wMin),
        decoration: BoxDecoration(
          color: AppTheme.cBgSecondary.color.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(40.wMin),
        ),
        child: Column(
          children: [
            Column(
              children: [
                Row(
                  spacing: 12.wMin,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      spacing: 3.wMin,
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
                            AppTheme.cTextPrimary.color,
                            AppTheme.cTextPrimary.color.withValues(alpha: 0.5),
                          ],
                          stops: const [0.18, 0.84],
                        ).createShader(bounds);
                      },
                      child: Text(
                        '技能维度分析',
                        style: TextStyle(
                          fontSize: 56.wMin,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.cTextPrimary.color,
                        ),
                      ),
                    ),
                    Column(
                      spacing: 3.wMin,
                      children: [
                        _buildTitleLineWidget(false),
                        _buildTitleLineWidget(false),
                      ],
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 4.wMin),
                  child: Text(
                    "四大英语核心技能评估",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 48.wMin,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.cTextSecondary.color,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Column(
                  spacing: 120.wMin,
                  children: [
                    RadarWidget(lsrwType: LSRWEnum.listening, item: item),
                    RadarWidget(lsrwType: LSRWEnum.speaking, item: item),
                  ],
                ),
                Expanded(
                  child: _buildRadarWidget(item),
                ),
                Column(
                  spacing: 120.wMin,
                  children: [
                    RadarWidget(lsrwType: LSRWEnum.reading, item: item),
                    RadarWidget(lsrwType: LSRWEnum.writing, item: item),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildRadarWidget(AssessmentHistoryItemEntity item) {
    List<AssessmentResultDetailEntityTierSkills?> tierSkills = item.tierSkills ?? [];

    AssessmentResultDetailEntityTierSkills? listeningSkillData = tierSkills.firstWhereOrNull((element) => element?.skill == LSRWEnum.listening);
    AssessmentResultDetailEntityTierSkills? speakingSkillData = tierSkills.firstWhereOrNull((element) => element?.skill == LSRWEnum.speaking);
    AssessmentResultDetailEntityTierSkills? readingSkillData = tierSkills.firstWhereOrNull((element) => element?.skill == LSRWEnum.reading);
    AssessmentResultDetailEntityTierSkills? writingSkillData = tierSkills.firstWhereOrNull((element) => element?.skill == LSRWEnum.writing);

    return Container(
      height: 447.wMin,
      alignment: Alignment.center,
      child: GestureDetector(
        onTapUp: (details) {
          print(details.localPosition);
        },
        child: Container(
          color: Colors.transparent,
          child: IgnorePointer(
            ignoring: true,
            child: ChartWidget(
              coordinateRender: ChartCircularCoordinateRender(
                borderColor: Colors.transparent,
                animationDuration: const Duration(milliseconds: 500),
                strokeCap: StrokeCap.round,
                charts: [
                  CustomizeRadar<int>(
                    startAngle: pi / 0.8,
                    lineWidth: 1.wMin,
                    dataLineWidth: 3.wMin,
                    showPoints: true,
                    pointRadius: 8.wMin,
                    pointBorderWidth: 4.wMin,
                    pointBorderColor: AppTheme.cStaticWhite.color,
                    count: 5,
                    lineTextStyle: TextStyle(
                      fontSize: 12.wMin,
                      color: AppTheme.cTextTertiary.color,
                      fontWeight: FontWeight.w400,
                    ),
                    onPointData: (_pointHitAreas) {
                      if (_pointHitAreas.isNotEmpty) {
                        print(_pointHitAreas.first.first.center);
                      }
                    },
                    max: listeningSkillData?.maxScore ?? 100,
                    data: [
                      listeningSkillData?.score ?? 0,
                      readingSkillData?.score ?? 0,
                      writingSkillData?.score ?? 0,
                      speakingSkillData?.score ?? 0,
                    ], // 听读说写
                    valueFormatter: (item) => [
                      item.toString(),
                    ],
                    values: (item) => [item],
                    lineColor: AppTheme.cBorderSecondary.color,
                    fillColors: [AppTheme.cSurfaceBrand.color.withValues(alpha: 0.3)],
                    legendTextStyle: TextStyle(
                      fontSize: 12.wMin,
                      color: AppTheme.cTextPrimary.color,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeline(BuildContext context) {
    return Obx(() {
      final list = controller.items;
      final current = controller.page.round().clamp(0, list.isEmpty ? 0 : list.length - 1);

      return Padding(
        padding: EdgeInsets.only(top: 32.wMin, right: 24.wMin, bottom: 24.wMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('时间轴', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 22.wMin)),
            SizedBox(height: 16.wMin),
            Expanded(
              child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (ctx, idx) {
                  final isActive = idx == current;
                  final date = DateFormatUtil.formatStr(list[idx].assessmentDate ?? DateTime.now(), newPattern: 'M月d日', locale: Get.locale);

                  return InkWell(
                    onTap: () => controller.jumpToIndex(idx),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.wMin),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            date,
                            style: TextStyle(
                              color: AppTheme.cTextPrimary.withValues(alpha: isActive ? 1.0 : 0.55),
                              fontSize: isActive ? 24.wMin : 22.wMin,
                              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                            ),
                          ),
                          SizedBox(width: 12.wMin),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: isActive ? 56.wMin : 36.wMin,
                            height: 2.wMin,
                            decoration: BoxDecoration(
                              color: AppTheme.cTextPrimary.withValues(alpha: isActive ? 1.0 : 0.55),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLevelWidget(AssessmentHistoryItemEntity entity) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 30.wMin,
      children: [
        SvgPicture.asset(
          "assets/svg/public/icon_union_left.svg",
          height: 240.wMin,
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
          child: Container(
              child: Column(
            children: [
              Text(
                "Level ${entity.tier ?? 0}",
                style: TextStyle(
                  fontSize: 120.wMin,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.cTextPrimary.color,
                  height: 1.15,
                ),
              ),
              Text(
                "CEFR ${entity.cefr ?? ""}",
                style: TextStyle(
                  fontSize: 40.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
            ],
          )),
        ),
        SvgPicture.asset(
          "assets/svg/public/icon_union_right.svg",
          height: 240.wMin,
        ),
      ],
    );
  }

  Widget _buildCefrBarChartWidget(AssessmentHistoryItemEntity entity) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        List<AssessmentResultDetailEntityTierInfos?> tierInfos = entity.tierInfos ?? [];

        List<AssessmentResultDetailEntityTierInfos?> tierInfosList = tierInfos.where((element) => element?.disable == false).toList();
        List<AssessmentResultDetailEntityTierInfos?> tierInfosDisableList = tierInfos.where((element) => element?.disable == true).toList();

        double itemWidth = (width - (tierInfos.length - 1) * 6.wMin) / tierInfos.length;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          spacing: 6.wMin,
          children: [
            Row(
              spacing: 6.wMin,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(tierInfosList.length, (index) {
                AssessmentResultDetailEntityTierInfosScoreRange? scoreRange = tierInfosList[index]?.scoreRange;
                return CefrBarChartWidget(
                  height: 260.wMin + index * 50.wMin,
                  width: itemWidth,
                  fontSize1: 24.wMin,
                  fontSize2: 20.wMin,
                  fontSize3: 20.wMin,
                  selected: false,
                  cefr: tierInfosList[index]?.cefr,
                  subTitle: "L${tierInfosList[index]?.tier?.min ?? 0}-L${tierInfosList[index]?.tier?.max ?? 0}",
                  scoreRange: "${scoreRange?.min ?? 0}-${scoreRange?.max ?? 0}",
                  child: _buildCefrBarChartItemWidget(tierInfosList[index]),
                );
              }),
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  spacing: 6.wMin,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(tierInfosDisableList.length, (index) {
                    AssessmentResultDetailEntityTierInfosScoreRange? scoreRange = tierInfosDisableList[index]?.scoreRange;
                    return CefrBarChartWidget(
                      height: 260.wMin + (index + tierInfosList.length) * 50.wMin,
                      width: itemWidth,
                      fontSize1: 24.wMin,
                      fontSize2: 20.wMin,
                      fontSize3: 20.wMin,
                      selected: false,
                      cefr: tierInfosDisableList[index]?.cefr,
                      subTitle: "L${tierInfosDisableList[index]?.tier?.min ?? 0}-L${tierInfosDisableList[index]?.tier?.max ?? 0}",
                      scoreRange: "${scoreRange?.min ?? 0}-${scoreRange?.max ?? 0}",
                      isDisable: true,
                      child: _buildCefrBarChartItemWidget(tierInfosDisableList[index]),
                    );
                  }),
                ),
                Container(
                  width: 45.wMin,
                  height: 45.wMin,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.cBlackAlpha50.color,
                  ),
                  child: SvgPicture.asset(
                    "assets/svg/public/icon_lock_blank.svg",
                    height: 24.wMin,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildCefrBarChartItemWidget(AssessmentResultDetailEntityTierInfos? data) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCefrBarChartTextItemWidget(data?.cambridgeList),
        _buildCefrBarChartTextItemWidget([data?.ielts]),
        _buildCefrBarChartTextItemWidget([data?.vocabulary]),
      ],
    );
  }

  Widget _buildCefrBarChartTextItemWidget(List<AssessmentResultDetailEntityTierInfosTitleDesc?>? list) {
    if (list == null) return Container();
    if (list.isEmpty) return Container();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(list.length, (index) {
        return Column(
          children: [
            Visibility(
              visible: list[index]?.title != null,
              child: Text(
                list[index]?.title ?? "",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.cStaticWhite.color,
                ),
              ),
            ),
            Visibility(
              visible: list[index]?.describe != null,
              child: Text(
                list[index]?.describe ?? "",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.cStaticWhite.color.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        );
      }),
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

  Widget _aiReport() {
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
                child: AppMarkdownWidget(
                  data: controller.cards.value?.report ?? "",
                ),
              );
            },
          ),
          SizedBox(height: 32.wMin)
        ],
      ),
    );
  }
}

class _TimeMachineCardStack extends StatelessWidget {
  final AssessmentHistoryTimeMachineController controller;
  final Widget Function(int index) itemBuilder;

  const _TimeMachineCardStack({required this.controller, required this.itemBuilder});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller.pageController,
      builder: (context, _) {
        final len = controller.items.length;
        if (len == 0) return const SizedBox.shrink();

        final page = controller.page;
        final base = page.floor().clamp(0, len - 1);
        const stackDepth = 7;

        final children = <Widget>[];
        for (int i = stackDepth - 1; i >= 0; i--) {
          final idx = base + i;
          if (idx >= len) continue;

          final delta = idx - page;
          final depth = delta.clamp(-7.0, 7.0);
          final t = (1.0 - (depth.abs() / 8.0)).clamp(0.0, 1.0);

          final scale = lerpDouble(0.62, 1.0, t)!;
          final translateY = lerpDouble(160.wMin, 0.0, t)!;
          final rotateX = lerpDouble(0.78, 0.0, t)!;
          final opacity = lerpDouble(0.08, 1.0, t)!;
          final blurSigma = lerpDouble(1.0, 0.0, t)!;

          children.add(
            Positioned.fill(
              child: Center(
                child: IgnorePointer(
                  ignoring: idx != page.round().clamp(0, len - 1),
                  child: Opacity(
                    opacity: opacity,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..translate(0.0, translateY * (delta.isNegative ? -1 : 1), 0)
                        ..rotateX(rotateX * (delta.isNegative ? 1 : -1))
                        ..scale(scale),
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                        child: itemBuilder(idx),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return Stack(clipBehavior: Clip.none, children: children);
      },
    );
  }
}

class _SidePagerButtons extends StatefulWidget {
  final AssessmentHistoryTimeMachineController controller;

  const _SidePagerButtons({required this.controller});

  @override
  State<_SidePagerButtons> createState() => _SidePagerButtonsState();
}

class _SidePagerButtonsState extends State<_SidePagerButtons> {
  Timer? _repeatTimer;

  @override
  void dispose() {
    _repeatTimer?.cancel();
    super.dispose();
  }

  void _stopRepeat() {
    _repeatTimer?.cancel();
    _repeatTimer = null;
  }

  void _startRepeat(int direction) {
    _stopRepeat();
    _repeatTimer = Timer.periodic(const Duration(milliseconds: 120), (_) {
      _flip(direction, duration: const Duration(milliseconds: 160));
    });
  }

  void _flip(int direction, {Duration duration = const Duration(milliseconds: 320)}) {
    final len = widget.controller.items.length;
    if (len == 0) return;
    final current = widget.controller.page.round().clamp(0, len - 1);
    final target = (current + direction).clamp(0, len - 1);
    if (target == current) return;

    widget.controller.pageController.animateToPage(
      target,
      duration: duration,
      curve: Curves.easeOutCubic,
    );
    widget.controller.getCurrent(widget.controller.items[target].assessmentId ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PagerButton(
          icon: Icons.keyboard_arrow_up_rounded,
          onTap: () => _flip(-1),
          onLongPressStart: () => _startRepeat(-1),
          onLongPressEnd: _stopRepeat,
        ),
        SizedBox(height: 12.wMin),
        _PagerButton(
          icon: Icons.keyboard_arrow_down_rounded,
          onTap: () => _flip(1),
          onLongPressStart: () => _startRepeat(1),
          onLongPressEnd: _stopRepeat,
        ),
      ],
    );
  }
}

class _PagerButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback onLongPressStart;
  final VoidCallback onLongPressEnd;

  const _PagerButton({
    required this.icon,
    required this.onTap,
    required this.onLongPressStart,
    required this.onLongPressEnd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPressStart: (_) => onLongPressStart(),
      onLongPressEnd: (_) => onLongPressEnd(),
      onLongPressCancel: onLongPressEnd,
      child: Container(
        width: 48.wMin,
        height: 48.wMin,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(16.wMin),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: Colors.white.withValues(alpha: 0.85), size: 30.wMin),
      ),
    );
  }
}
