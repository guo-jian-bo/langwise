import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/enum/enum.dart';
import '../../../../../common/entities/entities.dart';
import '../../../../../common/values/values.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../../../elements/utils/elements_page_utils.dart';
import '../controllers/zhenxie_task_details_correction_controller.dart';
import '../helper/zhenxie_task_correction_review_item_helper.dart';

/// 真写详情页右栏的批改区。
class ZhenxieTaskCorrectionWidget extends StatelessWidget {
  /// 批改区控制器，负责提供当前作答和批改结果。
  final ZhenxieTaskDetailsCorrectionController controller;

  const ZhenxieTaskCorrectionWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final details = controller.pageController().detailsData.value;
      final review = controller.currentReview();
      final isTextAnswerKind = controller.isTextAnswerKind();
      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 32.wMin),
        child: _buildBodyWidget(
          details: details,
          review: review,
          isTextAnswerKind: isTextAnswerKind,
        ),
      );
    });
  }

  /// 根据当前批改状态切换右栏内容。
  Widget _buildBodyWidget({
    required ZhenxieTaskDetailsEntity details,
    required ZhenxieTaskDetailsMemberWritingReview? review,
    required bool isTextAnswerKind,
  }) {
    return Obx((){
      if (controller.isReviewRunning() || review == null) {
        return _buildCorrectingWidget(review: review);
      }
      if (controller.isReviewFailed()) {
        return _buildFailedWidget(review: review);
      }
      if (!isTextAnswerKind) {
        return _buildMediaReviewWidget(details: details, review: review);
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ZhenxieTaskScoreWidget(controller: controller, review: review),
          ZhenxieTaskTotalEvaluationWidget(summary: review.summary),
          ZhenxieTaskQuestionKeyWidget(
            taskPoints: review.taskPoints?.whereType<ZhenxieTaskDetailsMemberWritingReviewTaskPoint>().toList() ?? [],
          ),
          ZhenxieTaskAnnotateItemWidget(controller: controller, review: review),
          ZhenxieTaskEachParagraphWidget(
            controller: controller,
            parts: review.parts?.whereType<ZhenxieTaskDetailsMemberWritingReviewPart>().toList() ?? [],
          ),
          ZhenxieTaskUseItWidget(controller: controller, review: review),
          ZhenxieTaskNextFirstWidget(priorities: review.priorities?.whereType<String>().toList() ?? []),
          ZhenxieTaskWarningsWidget(warnings: review.warnings?.whereType<String>().toList() ?? []),
        ],
      );
    });
  }

  /// 正在批改时显示统一 loading 卡。
  Widget _buildCorrectingWidget({ZhenxieTaskDetailsMemberWritingReview? review}) {
    final title = review?.statusTitle?.isNotEmpty == true ? review!.statusTitle! : "正在批改";
    final subtitle = review?.statusDescription ?? "";
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cZhenxieBackgroundPrimary.color,
        border: Border.all(
          color: AppTheme.cZhenxieBorderPrimary.color,
          width: 1.wMin,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SpinKitFadingCircle(
            color: AppTheme.cSurfaceBrand.color,
            size: 28.wMin,
          ),
          SizedBox(width: 12.wMin),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cZhenxieFontPrimary.color,
                  ),
                ),
                SizedBox(height: 6.wMin),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cZhenxieFontTertiary.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 批改失败时显示原因和重批按钮占位。
  Widget _buildFailedWidget({required ZhenxieTaskDetailsMemberWritingReview review}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceTranslucentBase.color,
        border: Border.all(
          color: const Color(0xffEF4444).withValues(alpha: 0.28),
          width: 1.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "这次批改没有完成",
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cSurfaceError.color,
            ),
          ),
          SizedBox(height: 12.wMin),
          Visibility(
            visible: review.error != null,
            child: Text(
              review.error??"",
              style: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cZhenxieFontPrimary.color,
              ),
            ),
          ),
          SizedBox(height: 16.wMin),
          ButtonWidget(
            text: "重新批改",
            height: 48.wMin,
            padding: EdgeInsets.symmetric(horizontal: 24.wMin),
            borderRadius: 99,
            color: AppTheme.cZhenxieFontPrimary.color,
            border: Border.all(color: AppTheme.cZhenxieBorderPrimary.color, width: 0.8.wMin),
            fontSize: 24.wMin,
            fontColor: AppTheme.cStaticDeprecatedBlack.color,
            fontWeight: FontWeight.w500,
            sclae: 1.01,
            onTap: () {
              controller.retryReview();
            },
          ),
        ],
      ),
    );
  }

  /// 非文字题只展示概览、老师评语、转写和提示。
  Widget _buildMediaReviewWidget({
    required ZhenxieTaskDetailsEntity details,
    required ZhenxieTaskDetailsMemberWritingReview review,
  }) {
    final answerKindLabel = details.stage?.answerKindEnum.label ?? "媒体";
    final mediaCount = details.memberWriting?.mediaKeys?.whereType<String>().length ?? 0;
    final levelText = review.levelLabel?.isNotEmpty == true ? review.levelLabel! : (review.level ?? "—");
    String overviewText = answerKindLabel;
    if (mediaCount > 0) {
      overviewText = details.memberWriting?.answerKind == 'image' ? "$answerKindLabel $mediaCount 张" : "$answerKindLabel $mediaCount 段";
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "按 $levelText 要求 · $overviewText",
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cZhenxieFontTertiary.color,
          ),
        ),
        SizedBox(height: 16.wMin),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.wMin),
            color: AppTheme.cSurfaceTranslucentBase.color,
            border: Border.all(
              color: AppTheme.cBorderTranslucentThin.color,
              width: 0.8.wMin,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "老师评语",
                style: TextStyle(
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cZhenxieFontTertiary.color,
                ),
              ),
              SizedBox(height: 12.wMin),
              Text(
                review.comment ?? "",
                style: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cZhenxieFontPrimary.color,
                  height: 1.6,
                ),
              ),
              
            ],
          ),
        ),
        ZhenxieTaskWarningsWidget(warnings: review.warnings?.whereType<String>().toList() ?? const []),
      ],
    );
  }
}

/// 批改页分数卡。
class ZhenxieTaskScoreWidget extends StatefulWidget {
  /// 批改区控制器，用于读取当前选中的历史摘要。
  final ZhenxieTaskDetailsCorrectionController controller;

  /// 当前批改详情。
  final ZhenxieTaskDetailsMemberWritingReview review;

  const ZhenxieTaskScoreWidget({
    super.key,
    required this.controller,
    required this.review,
  });

  @override
  State<ZhenxieTaskScoreWidget> createState() => _ZhenxieTaskScoreWidgetState();
}

class _ZhenxieTaskScoreWidgetState extends State<ZhenxieTaskScoreWidget> {
  /// 当前展开的评分维度。
  final Set<int> expandedIndex = <int>{};

  @override
  Widget build(BuildContext context) {
    final review = widget.review;
    final dimensions = review.dimensions?.whereType<ZhenxieTaskDetailsMemberWritingReviewDimension>().toList() ?? const [];
    final weights = dimensions.where((item) => (item.weight ?? 0) > 0).map((item) => item.weight!).toList();
    final hasUnevenWeights = weights.isNotEmpty && weights.toSet().length > 1;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.wMin),
        color: AppTheme.cSurfaceTranslucentBase.color,
        border: Border.all(
          color: AppTheme.cBorderTranslucentThin.color,
          width: 0.8.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildScoreTitleWidget(),
          if (review.errorFree != null) ...[
            SizedBox(height: 16.wMin),
            Text(
              "无错句 ${review.errorFree?.clean ?? 0}/${review.errorFree?.total ?? 0}",
              style: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cZhenxieFontTertiary.color,
              ),
            ),
          ],
          if (dimensions.isNotEmpty) SizedBox(height: 16.wMin),
          Column(
            spacing: 24.wMin,
            children: List.generate(dimensions.length, (index) {
              return _buildScoreItemWidget(index: index, item: dimensions[index]);
            }),
          ),
          if (hasUnevenWeights) ...[
            SizedBox(height: 16.wMin),
            Text(
              "本题只写一句，连贯与衔接不评，其余三项按 ${weights.join(' / ')} 折算。",
              style: TextStyle(
                fontSize: 14.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cZhenxieFontTertiary.color,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 渲染分数标题区域。
  Widget _buildScoreTitleWidget() {
    final review = widget.review;
    final details = widget.controller.pageController().detailsData.value;
    final rubricName = LearningLangUtils.getLocalLang(details.stage?.compositionBlueprint?.name)?.text ?? "";
    final history = widget.controller.pageController().currentReviewHistory();
    final gradeEnum = ZhenxieReviewGradeEnum.fromValue(review.grade);
    final levelText = review.levelLabel?.isNotEmpty == true ? review.levelLabel! : (review.level ?? "—");
    final totalDenominator = review.totalDenominator ?? 100;
    final gradeText = history?.grade?.isNotEmpty == true ? history!.grade! : (review.gradeLabel ?? gradeEnum?.name ?? "");
    return Row(
      children: [
        Text(
          "${review.total ?? '—'}",
          style: TextStyle(
            fontSize: 40.wMin,
            fontWeight: FontWeight.w600,
            color: AppTheme.cZhenxieFontPrimary.color,
            fontFamily: AppFontValue.sourceHanSerifCN,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 4.wMin),
          child: Text(
            " / $totalDenominator",
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cZhenxieFontSecondary.color,
              fontFamily: AppFontValue.sourceHanSerifCN,
            ),
          ),
        ),
        SizedBox(width: 4.wMin),
        if (gradeText.isNotEmpty)
          Container(
            margin: EdgeInsets.only(bottom: 4.wMin),
            padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 4.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(99),
              color: gradeEnum?.background ?? AppTheme.cSurfaceLayerBase.color,
              border: Border.all(
                color: gradeEnum?.border ?? AppTheme.cBorderTranslucentThin.color,
                width: 0.8.wMin,
              ),
            ),
            child: Text(
              gradeText,
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w600,
                color: gradeEnum?.foreground ?? AppTheme.cZhenxieFontPrimary.color,
              ),
            ),
          ),
        const Spacer(),
        Padding(
          padding: EdgeInsets.only(bottom: 4.wMin),
          child: Text(
            "按 $levelText${rubricName.isNotEmpty ? ' · $rubricName' : ''}评",
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cZhenxieFontTertiary.color,
            ),
          ),
        ),
      ],
    );
  }

  /// 渲染单个评分维度。
  Widget _buildScoreItemWidget({
    required int index,
    required ZhenxieTaskDetailsMemberWritingReviewDimension item,
  }) {
    final score = item.score;
    final dimensionText = item.name?.isNotEmpty == true ? item.name! : (item.dimension ?? "dimension");
    final scoreDenominator = item.scoreDenominator ?? 10;
    final isExpanded = expandedIndex.contains(index);
    final detailRows = _buildScoreDetailRows(item);
    return Column(
      children: [
        TapScaleWidget(
          onTap: () {
            if (isExpanded) {
              expandedIndex.remove(index);
            } else {
              expandedIndex.add(index);
            }
            if (mounted) setState(() {});
          },
          sclae: 1,
          child: Container(
            color: Colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 250.wMin,
                      child: AutoSizeText(
                        dimensionText,
                        maxLines: 1,
                        minFontSize: 6,
                        style: TextStyle(
                          fontSize: 24.wMin,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.cZhenxieFontPrimary.color,
                        ),
                      ),
                    ),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: scoreDenominator <= 0 ? 0 : (score ?? 0) / scoreDenominator,
                        borderRadius: BorderRadius.circular(99),
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.cZhenxieFontTertiary.color),
                        backgroundColor: AppTheme.cZhenxieBackgroundPrimary.color,
                        minHeight: 8.wMin,
                      ),
                    ),
                    SizedBox(width: 4.wMin),
                    Text(
                      score == null ? "不评" : "$score/$scoreDenominator",
                      style: TextStyle(
                        fontSize: 20.wMin,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.cZhenxieFontPrimary.color,
                      ),
                    ),
                    SizedBox(width: 6.wMin),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: SvgPicture.asset(
                        "assets/svg/public/icon_arrow_down.svg",
                        width: 20.wMin,
                        colorFilter: ColorFilter.mode(AppTheme.cZhenxieFontTertiary.color, BlendMode.srcIn),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.wMin),
                Text(
                  item.comment ?? "",
                  style: TextStyle(
                    fontSize: 22.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cZhenxieFontTertiary.color,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
          crossFadeState: isExpanded && detailRows.isNotEmpty ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          secondChild: Container(),
          firstChild: Container(
            margin: EdgeInsets.only(top: 8.wMin),
            padding: EdgeInsets.all(12.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.wMin),
              color: AppTheme.cZhenxieBackgroundPrimary.color,
              border: Border.all(
                color: AppTheme.cZhenxieBorderPrimary.color,
                width: 1.wMin,
              ),
            ),
            child: Column(
              spacing: 12.wMin,
              children: detailRows.map((row) {
                return _buildScoreDetailRowWidget(
                  label: row.key,
                  value: row.value,
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  /// 渲染分数项展开后的明细行。
  Widget _buildScoreDetailRowWidget({
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130.wMin,
          child: AutoSizeText(
            label,
            maxLines: 2,
            minFontSize: 8,
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cZhenxieFontSecondary.color,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cZhenxieFontTertiary.color,
            ),
          ),
        ),
      ],
    );
  }

  /// 基于当前真实字段生成可展示的详情行。
  List<MapEntry<String, String>> _buildScoreDetailRows(ZhenxieTaskDetailsMemberWritingReviewDimension item) {
    final rows = item.detailItems?.whereType<ZhenxieTaskDetailsMemberWritingReviewDimensionDetailItem>().where((detail) {
          return (detail.label ?? "").isNotEmpty && (detail.content ?? "").isNotEmpty;
        }).map((detail) {
          return MapEntry(detail.label!, detail.content!);
        }).toList() ??
        const [];
    return rows;
  }
}

/// 总评区域。
class ZhenxieTaskTotalEvaluationWidget extends StatelessWidget {
  /// 当前总评文案。
  final String? summary;

  const ZhenxieTaskTotalEvaluationWidget({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    if ((summary ?? '').isEmpty) return const SizedBox.shrink();
    return _ReviewTextSection(title: "总评", content: summary);
  }
}

/// 题目要点区域。
class ZhenxieTaskQuestionKeyWidget extends StatelessWidget {
  /// 模型拆出来的题目要点。
  final List<ZhenxieTaskDetailsMemberWritingReviewTaskPoint> taskPoints;

  const ZhenxieTaskQuestionKeyWidget({super.key, required this.taskPoints});

  @override
  Widget build(BuildContext context) {
    if (taskPoints.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: EdgeInsets.only(top: 32.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "题目要点",
            style: TextStyle(
              fontSize: 28.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cZhenxieFontTertiary.color,
            ),
          ),
          SizedBox(height: 10.wMin),
          Column(
            spacing: 10.wMin,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(taskPoints.length, (index) {
              return _buildTaskPointItemWidget(taskPoints[index]);
            }),
          ),
        ],
      ),
    );
  }

  /// 渲染单个题目要点。
  Widget _buildTaskPointItemWidget(ZhenxieTaskDetailsMemberWritingReviewTaskPoint item) {
    final statusEnum = ZhenxieReviewTaskPointStatusEnum.fromValue(item.status);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 4.wMin),
          child: Text(
            statusEnum.symbol,
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w600,
              color: statusEnum.color,
            ),
          ),
        ),
        SizedBox(width: 8.wMin),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.point ?? "",
                style: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cZhenxieFontPrimary.color,
                ),
              ),
              if ((item.note ?? '').isNotEmpty) ...[
                SizedBox(height: 4.wMin),
                Text(
                  item.note!,
                  style: TextStyle(
                    fontSize: 22.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cZhenxieFontTertiary.color,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// 逐条批注区域。
class ZhenxieTaskAnnotateItemWidget extends StatefulWidget {
  /// 批改区控制器，用于读取拍位名称。
  final ZhenxieTaskDetailsCorrectionController controller;

  /// 当前批改详情。
  final ZhenxieTaskDetailsMemberWritingReview review;

  const ZhenxieTaskAnnotateItemWidget({
    super.key,
    required this.controller,
    required this.review,
  });

  @override
  State<ZhenxieTaskAnnotateItemWidget> createState() => _ZhenxieTaskAnnotateItemWidgetState();
}

class _ZhenxieTaskAnnotateItemWidgetState extends State<ZhenxieTaskAnnotateItemWidget> {
  /// 每张卡片的定位 key。
  final Map<String, GlobalKey> _itemKeys = <String, GlobalKey>{};

  /// marker id 到当前可见卡片 key 的映射。
  final Map<String, String> _markerVisibleItemKeys = <String, String>{};

  /// 当前正在闪动的卡片 id。
  String? _flashingItemId;

  /// 卡片闪动结束计时器。
  Timer? _flashTimer;

  /// 上一次处理过的选中 marker id。
  String? _lastSelectedMarkerId;

  /// 上一次处理过的 flash pulse tick。
  int? _lastFlashTick;

  @override
  void dispose() {
    _flashTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = widget.controller.reviewItems();
      if (items.isEmpty) return const SizedBox.shrink();
      final filteredItems = widget.controller.filteredReviewItems();
      final selectedItemId = widget.controller.selectedMarkerId.value;
      final selectedTab = widget.controller.selectedMarkerTab.value;
      final flashPulse = widget.controller.flashCardPulse.value;
      _syncVisibleItemKeys(filteredItems);
      _syncScrollEffects(
        selectedItemId: selectedItemId,
        flashPulse: flashPulse,
      );
      final tabs = ZhenxieReviewMarkerTabEnum.values.where((item) {
        return item == ZhenxieReviewMarkerTabEnum.all || widget.controller.markerTabCount(item) > 0;
      }).toList();
      return Container(
        margin: EdgeInsets.only(top: 32.wMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "逐条批注",
                  style: TextStyle(
                    fontSize: 28.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cZhenxieFontTertiary.color,
                  ),
                ),
                const Spacer(),
              ],
            ),
            SizedBox(height: 10.wMin),
            Container(
              padding: EdgeInsets.all(6.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                color: AppTheme.cSurfaceTranslucentBase.color,
                border: Border.all(
                  color: AppTheme.cBorderTranslucentThin.color,
                  width: 1.wMin,
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 8.wMin,
                  mainAxisSize: MainAxisSize.min,
                  children: tabs.map((tab) {
                    return _buildTabItemWidget(
                      tab: tab,
                      selected: selectedTab == tab,
                      count: widget.controller.markerTabCount(tab),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 12.wMin),
            if (filteredItems.isEmpty)
              Text(
                "这一类没有批注",
                style: TextStyle(
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cZhenxieFontSecondary.color,
                ),
              )
            else
              Column(
                spacing: 12.wMin,
                children: filteredItems.map((item) {
                  final itemKey = _itemRenderKey(item);
                  return _buildMarkerItemWidget(
                    item: item,
                    itemKey: itemKey,
                    isSelected: item.id == selectedItemId,
                    isFlashing: item.id == _flashingItemId,
                  );
                }).toList(),
              ),
          ],
        ),
      );
    });
  }

  /// 渲染单个筛选标签。
  Widget _buildTabItemWidget({
    required ZhenxieReviewMarkerTabEnum tab,
    required bool selected,
    required int count,
  }) {
    return TapScaleWidget(
      onTap: () {
        widget.controller.updateSelectedMarkerTab(tab);
      },
      sclae: 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 38.wMin,
        constraints: BoxConstraints(minWidth: 92.wMin),
        padding: EdgeInsets.symmetric(horizontal: 14.wMin),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99),
          color: selected ? AppTheme.cZhenxieFontPrimary.color : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${tab.name} $count",
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w500,
                color: selected ? AppTheme.cBgPrimary.color : AppTheme.cZhenxieFontSecondary.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 渲染单条批注或亮点卡片。
  Widget _buildMarkerItemWidget({
    required ZhenxieTaskCorrectionReviewItem item,
    required String itemKey,
    required bool isSelected,
    required bool isFlashing,
  }) {
    final severityEnum = item.isHighlight() ? ZhenxieReviewIssueSeverityEnum.highlight : ZhenxieReviewIssueSeverityEnum.fromValue(item.issue?.severity);
    final pillColor = severityEnum.color ?? AppTheme.cZhenxieFontPrimary.color;
    return TapScaleWidget(
      onTap: () {
        widget.controller.handleRailMarkerSelection(item.id);
      },
      sclae: 1,
      borderRadius: 16.wMin,
      backColor: isSelected || isFlashing ? AppTheme.cSurfaceLayerBase.color : AppTheme.cSurfaceTranslucentBase.color,
      child: Container(
        key: _itemKey(itemKey),
        width: double.infinity,
        padding: EdgeInsets.all(12.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: isSelected || isFlashing ? AppTheme.cSurfaceLayerBase.color : AppTheme.cSurfaceTranslucentBase.color,
          border: Border.all(
            color: isSelected || isFlashing ? AppTheme.cZhenxieColorPrimary.color : AppTheme.cBorderTranslucentThin.color,
            width: 1.wMin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  constraints: BoxConstraints(minHeight: 24.wMin, minWidth: 24.wMin),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: pillColor,
                  ),
                  child: Text(
                    "${item.number}",
                    style: TextStyle(
                      fontSize: 14.wMin,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.cTextInverse.color,
                    ),
                  ),
                ),
                SizedBox(width: 8.wMin),
                Expanded(
                  child: Text(
                    _markerTypeLabel(item),
                    style: TextStyle(
                      fontSize: 24.wMin,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.cZhenxieFontTertiary.color,
                    ),
                  ),
                ),
                Text(
                  _buildAnchorLocation(item.anchor),
                  style: TextStyle(
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cZhenxieFontSecondary.color,
                  ),
                ),
              ],
            ),
            if (_markerQuote(item).isNotEmpty) ...[
              SizedBox(height: 10.wMin),
              _buildMarkerQuoteWidget(item),
            ],
            if (_markerDescription(item).isNotEmpty) ...[
              SizedBox(height: 4.wMin),
              Text(
                _markerDescription(item),
                style: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cZhenxieFontSecondary.color,
                ),
              ),
            ],
            if (_grammarTitle(_markerGrammarTargetUid(item)).isNotEmpty || _knowledgeTitle(_markerKnowledge(item)).isNotEmpty) ...[
              SizedBox(height: 10.wMin),
              Wrap(
                spacing: 8.wMin,
                runSpacing: 8.wMin,
                children: [
                  if (_grammarTitle(_markerGrammarTargetUid(item)).isNotEmpty) ...[
                    _buildRelationChipWidget(
                      text: "语法点 · ${_grammarTitle(_markerGrammarTargetUid(item))}",
                      grammarTargetUid: _markerGrammarTargetUid(item),
                    ),
                  ],
                  if (_knowledgeTitle(_markerKnowledge(item)).isNotEmpty) ...[
                    _buildRelationChipWidget(
                      text: "核心词 · ${_knowledgeTitle(_markerKnowledge(item))}",
                      knowledge: _markerKnowledge(item),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 将 anchor 转为可读位置文案。
  String _buildAnchorLocation(ZhenxieTaskDetailsMemberWritingReviewAnchor? anchor) {
    if (anchor == null) return "";
    final beatLabel = _partKeyLabel(anchor.partKey);
    final sentenceIndex = _sentenceIndex(anchor.sentenceId);
    if (beatLabel.isEmpty && sentenceIndex == null) return "";
    if (sentenceIndex == null) return beatLabel;
    if (beatLabel.isEmpty) return "第 $sentenceIndex 句";
    return "$beatLabel · 第 $sentenceIndex 句";
  }

  /// 渲染批注卡片中的原文/改法。
  Widget _buildMarkerQuoteWidget(Object item) {
    final quote = _markerQuote(item);
    final correction = _markerCorrection(item);
    if (item is ZhenxieTaskCorrectionReviewItem && item.isHighlight()) {
      return Text(
        "“$quote”",
        style: TextStyle(
          fontSize: 28.wMin,
          fontWeight: FontWeight.w500,
          color: const Color(0xff86EFAC),
        ),
      );
    }
    if (correction.isEmpty) {
      return RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cZhenxieFontPrimary.color,
          ),
          children: [
            TextSpan(
              text: "删去 ",
              style: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cZhenxieFontSecondary.color,
              ),
            ),
            TextSpan(
              text: quote,
              style: const TextStyle(
                color: Color(0xffFCA5A5),
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ],
        ),
      );
    }
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 24.wMin,
          fontWeight: FontWeight.w500,
          color: AppTheme.cZhenxieFontPrimary.color,
        ),
        children: [
          TextSpan(
            text: quote,
            style: const TextStyle(
              color: Color(0xffFCA5A5),
              decoration: TextDecoration.lineThrough,
            ),
          ),
          TextSpan(
            text: "  →  ",
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cZhenxieFontSecondary.color,
            ),
          ),
          TextSpan(
            text: correction,
            style: const TextStyle(color: Color(0xff86EFAC)),
          ),
        ],
      ),
    );
  }

  /// 渲染语法点 / 核心词关联标签。
  Widget _buildRelationChipWidget({
    required String text,
    int? grammarTargetUid,
    ZhenxieTaskDetailsMemberWritingReviewKnowledge? knowledge,
  }) {
    return TapScaleWidget(
      onTap: () => widget.controller.handleRelationChipTap(
        knowledge: knowledge,
        grammarTargetUid: grammarTargetUid,
      ),
      sclae: 1,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 6.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99),
          color: AppTheme.cSurfaceLayerBase.color,
          border: Border.all(
            color: AppTheme.cBorderTranslucentThin.color,
            width: 0.8.wMin,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 20.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cZhenxieFontTertiary.color,
              ),
            ),
            SizedBox(width: 6.wMin),
            SvgPicture.asset(
              "assets/svg/public/icon_deeplink.svg",
              width: 16.wMin,
              colorFilter: ColorFilter.mode(AppTheme.cZhenxieFontTertiary.color, BlendMode.srcIn),
            ),
          ],
        ),
      ),
    );
  }

  /// 读取语法点标题，优先用当前 review 的命中数据。
  String _grammarTitle(int? uid) {
    if (uid == null) return "";
    final reviewRows = widget.review.grammarUses?.whereType<ZhenxieTaskDetailsMemberWritingReviewGrammarUse>().toList() ?? const [];
    for (final row in reviewRows) {
      if (row.uid == uid && (row.title ?? '').isNotEmpty) return row.title!;
    }
    final taskRows = widget.controller.pageController().taskController.taskGrammarTargetList;
    for (final row in taskRows) {
      if (row.uid == uid) return LearningLangUtils.getLocalLang(row.title)?.text ?? "";
    }
    return "";
  }

  /// 读取核心词标题，优先用当前 review 的命中数据。
  String _knowledgeTitle(ZhenxieTaskDetailsMemberWritingReviewKnowledge? knowledge) {
    if (knowledge == null) return "";
    final reviewRows = widget.review.knowledgeUses?.whereType<ZhenxieTaskDetailsMemberWritingReviewKnowledgeUse>().toList() ?? const [];
    for (final row in reviewRows) {
      final sameUid = row.uid == knowledge.uid;
      final sameType = (row.contentType ?? "") == (knowledge.contentType ?? "");
      final sameSemanticId = knowledge.semanticId == null || row.semanticId == knowledge.semanticId;
      if (sameUid && sameType && sameSemanticId && (row.content ?? '').isNotEmpty) return row.content!;
    }
    final taskRows = widget.controller.pageController().taskController.taskKnowledgePointsList;
    for (final row in taskRows) {
      final sameUid = knowledge.uid != null && (row.uid == knowledge.uid || row.contentId == knowledge.uid);
      final sameType = (row.contentType ?? "") == (knowledge.contentType ?? "");
      final sameSemanticId = knowledge.semanticId == null ||
          row.semanticId == knowledge.semanticId ||
          (row.semanticIds ?? const []).contains(knowledge.semanticId);
      if (sameUid && sameType && sameSemanticId) {
        final pos = row.posTitle ?? row.pos ?? "";
        if (pos.isEmpty) return row.content ?? "";
        return "${row.content ?? ''} $pos";
      }
    }
    return "";
  }

  /// 当前作答里的 part 顺序，用于统一批注编号。
  /// 统一读取 marker quote。
  String _markerQuote(Object item) {
    if (item is ZhenxieTaskCorrectionReviewItem) return item.anchor.quote ?? "";
    return "";
  }

  /// 统一读取 marker 改法。
  String _markerCorrection(Object item) {
    return item is ZhenxieTaskCorrectionReviewItem ? item.issue?.correction ?? "" : "";
  }

  /// 统一读取 marker 解释文案。
  String _markerDescription(Object item) {
    if (item is ZhenxieTaskCorrectionReviewItem) {
      if (item.isHighlight()) return item.highlight?.comment ?? "";
      return item.issue?.explanation ?? "";
    }
    return "";
  }

  /// 统一读取 marker 类型文案。
  String _markerTypeLabel(Object item) {
    if (item is ZhenxieTaskCorrectionReviewItem) {
      if (item.isHighlight()) return "亮点";
      final issue = item.issue;
      final labels = <String>[
        if ((issue?.categoryLabel ?? "").isNotEmpty) issue!.categoryLabel! else if ((issue?.category ?? "").isNotEmpty) issue!.category!,
        if ((issue?.dimensionShortName ?? "").isNotEmpty)
          issue!.dimensionShortName!
        else if ((issue?.dimensionName ?? "").isNotEmpty)
          issue!.dimensionName!
        else if ((issue?.dimension ?? "").isNotEmpty)
          issue!.dimension!,
      ];
      return labels.join(" · ");
    }
    return "";
  }

  /// 统一读取 marker 关联语法点 uid。
  int? _markerGrammarTargetUid(Object item) {
    return item is ZhenxieTaskCorrectionReviewItem ? item.issue?.grammarTargetUid : null;
  }

  /// 统一读取 marker 关联核心词。
  ZhenxieTaskDetailsMemberWritingReviewKnowledge? _markerKnowledge(Object item) {
    return item is ZhenxieTaskCorrectionReviewItem ? item.issue?.knowledge : null;
  }

  /// 根据 partKey 找到右栏展示拍位名。
  String _partKeyLabel(String? partKey) {
    if ((partKey ?? '').isEmpty) return "";
    final partKeyEnum = ZhenxieTaskPartKeyEnum.fromValue(partKey);
    if (partKeyEnum != null) return partKeyEnum.label;
    final list = widget.controller.pageController().paragraphRhetoricalList;
    for (final item in list) {
      if ((item.nid ?? '') == partKey) {
        final nameText = LearningLangUtils.getLocalLang(item.name)?.text ?? "";
        final glossText = LearningLangUtils.getLocalLang(item.gloss)?.text ?? "";
        if (nameText.isEmpty) return glossText;
        if (glossText.isEmpty) return nameText;
        return "$nameText·$glossText";
      }
    }
    return partKey ?? "";
  }

  /// 从 sentenceId 里提取句序。
  int? _sentenceIndex(String? sentenceId) {
    if ((sentenceId ?? '').isEmpty) return null;
    final match = RegExp(r'\.s(\d+)$').firstMatch(sentenceId!);
    if (match == null) return null;
    return int.tryParse(match.group(1) ?? "");
  }

  /// 同步右栏滚动和闪动态。
  void _syncScrollEffects({
    required String? selectedItemId,
    required ZhenxieTaskCorrectionPulse? flashPulse,
  }) {
    if (flashPulse != null && flashPulse.tick != _lastFlashTick) {
      _lastFlashTick = flashPulse.tick;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _startFlashCard(flashPulse.id);
        _ensureCardVisible(flashPulse.id, alignment: 0.5);
      });
    }
    if (selectedItemId != _lastSelectedMarkerId) {
      _lastSelectedMarkerId = selectedItemId;
    }
  }

  /// 启动一次右栏卡片闪动。
  void _startFlashCard(String markerId) {
    _flashTimer?.cancel();
    if (!mounted) return;
    setState(() {
      _flashingItemId = markerId;
    });
    _flashTimer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted || _flashingItemId != markerId) return;
      setState(() {
        _flashingItemId = null;
      });
    });
  }

  /// 滚动到指定卡片位置。
  Future<void> _ensureCardVisible(String markerId, {required double alignment}) async {
    final itemKey = _markerVisibleItemKeys[markerId];
    final cardContext = itemKey == null ? null : _itemKeys[itemKey]?.currentContext;
    if (cardContext == null || !mounted) return;
    await Scrollable.ensureVisible(
      cardContext,
      duration: const Duration(milliseconds: 200),
      alignment: alignment,
      curve: Curves.easeOut,
    );
  }

  /// 同步当前可见卡片 key，避免重复 markerId 复用同一个 GlobalKey。
  void _syncVisibleItemKeys(List<ZhenxieTaskCorrectionReviewItem> items) {
    final nextVisibleItemKeys = <String, String>{};
    final nextItemKeySet = <String>{};
    for (final item in items) {
      final itemKey = _itemRenderKey(item);
      nextItemKeySet.add(itemKey);
      nextVisibleItemKeys.putIfAbsent(item.id, () => itemKey);
      _itemKeys.putIfAbsent(itemKey, () => GlobalKey());
    }
    _markerVisibleItemKeys
      ..clear()
      ..addAll(nextVisibleItemKeys);
    _itemKeys.removeWhere((key, _) => !nextItemKeySet.contains(key));
  }

  /// 返回当前渲染行自己的稳定 key。
  String _itemRenderKey(ZhenxieTaskCorrectionReviewItem item) {
    return '${item.id}::${item.number}';
  }

  /// 返回当前卡片的稳定 key。
  GlobalKey _itemKey(String itemKey) {
    return _itemKeys.putIfAbsent(itemKey, () => GlobalKey());
  }
}

/// 每段点评区域。
class ZhenxieTaskEachParagraphWidget extends StatelessWidget {
  static const List<String> _bodyMarks = ['①', '②', '③', '④', '⑤'];

  /// 批改区控制器，用于拍位名称映射。
  final ZhenxieTaskDetailsCorrectionController controller;

  /// 当前作答分段点评。
  final List<ZhenxieTaskDetailsMemberWritingReviewPart> parts;

  const ZhenxieTaskEachParagraphWidget({
    super.key,
    required this.controller,
    required this.parts,
  });

  @override
  Widget build(BuildContext context) {
    if (parts.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: EdgeInsets.only(top: 32.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "每段点评",
            style: TextStyle(
              fontSize: 28.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cZhenxieFontTertiary.color,
            ),
          ),
          SizedBox(height: 10.wMin),
          Column(
            spacing: 12.wMin,
            children: List.generate(parts.length, (index) {
              return _buildEachParagraphItemWidget(parts[index]);
            }),
          ),
        ],
      ),
    );
  }

  /// 渲染单个分段点评。
  Widget _buildEachParagraphItemWidget(ZhenxieTaskDetailsMemberWritingReviewPart item) {
    final partLabel = _partShortLabel(item.key);
    final partThemeColor = _partThemeColorItem(item.key);
    return TapScaleWidget(
      onTap: () {
        controller.flashReviewPart(item.key ?? '');
      },
      sclae: 1,
      borderRadius: 12.wMin,
      backColor: AppTheme.cSurfaceLayerBase.color,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.wMin),
        child: Row(
          children: [
            Container(
              width: 40.wMin,
              height: 40.wMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: partThemeColor?.colorValue ?? AppTheme.cZhenxieBackgroundPrimary.color,
                border: Border.all(
                  color: partThemeColor?.colorValue ?? AppTheme.cZhenxieBorderPrimary.color,
                  width: 1.wMin,
                ),
              ),
              child: Text(
                partLabel,
                style: TextStyle(
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w600,
                  color: partThemeColor?.textColorValue ?? AppTheme.cZhenxieFontPrimary.color,
                ),
              ),
            ),
            SizedBox(width: 10.wMin),
            Expanded(
              child: Text(
                item.comment ?? "",
                style: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cZhenxieFontTertiary.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 根据 partKey 读取当前主题下的拍位颜色。
  ParagraphRhetoricalEntityColorItem? _partThemeColorItem(String? partKey) {
    if ((partKey ?? '').isEmpty) return null;
    final list = controller.pageController().paragraphRhetoricalList;
    for (final item in list) {
      if ((item.nid ?? '') == partKey) return item.currentThemeColor;
    }
    return null;
  }

  /// 根据 partKey 找到用于圆点标签的短名称。
  String _partShortLabel(String? partKey) {
    final bodyLabel = _bodyShortLabel(partKey);
    if (bodyLabel != null) return bodyLabel;
    final partKeyEnum = ZhenxieTaskPartKeyEnum.fromValue(partKey);
    if (partKeyEnum != null) return partKeyEnum.shortLabel;
    final text = _partKeyLabel(partKey);
    if (text.isEmpty) return "段";
    return text.characters.first;
  }

  /// 根据 partKey 找到右栏展示拍位名。
  String _partKeyLabel(String? partKey) {
    if ((partKey ?? '').isEmpty) return "";
    final bodyLabel = _bodyLabel(partKey);
    if (bodyLabel != null) return bodyLabel;
    final partKeyEnum = ZhenxieTaskPartKeyEnum.fromValue(partKey);
    if (partKeyEnum != null) return partKeyEnum.label;
    final list = controller.pageController().paragraphRhetoricalList;
    for (final item in list) {
      if ((item.nid ?? '') == partKey) {
        final nameText = LearningLangUtils.getLocalLang(item.name)?.text ?? "";
        final glossText = LearningLangUtils.getLocalLang(item.gloss)?.text ?? "";
        if (nameText.isEmpty) return glossText;
        if (glossText.isEmpty) return nameText;
        return "$nameText $glossText";
      }
    }
    return partKey ?? "";
  }

  /// 当前 key 是否属于纸上写正文块。
  bool _isBodyPartKey(String? partKey) {
    return RegExp(r'^body_\d+$').hasMatch(partKey ?? '');
  }

  /// 返回 body_n 在当前点评列表里的位置文案。
  String? _bodyLabel(String? partKey) {
    if (!_isBodyPartKey(partKey)) return null;
    final bodyKeys = parts.map((item) => item.key ?? '').where(_isBodyPartKey).toList();
    if (bodyKeys.length <= 1) return "正文";
    final index = bodyKeys.indexOf(partKey ?? '');
    if (index < 0) return "正文";
    return "第 ${index + 1} 处";
  }

  /// 返回 body_n 在当前点评列表里的短标签。
  String? _bodyShortLabel(String? partKey) {
    if (!_isBodyPartKey(partKey)) return null;
    final bodyKeys = parts.map((item) => item.key ?? '').where(_isBodyPartKey).toList();
    if (bodyKeys.length <= 1) return "文";
    final index = bodyKeys.indexOf(partKey ?? '');
    if (index < 0) return "文";
    return index < _bodyMarks.length ? _bodyMarks[index] : "${index + 1}";
  }
}

/// 要求用上了吗区域。
class ZhenxieTaskUseItWidget extends StatefulWidget {
  /// 批改区控制器，用于读取知识点和语法点静态数据。
  final ZhenxieTaskDetailsCorrectionController controller;

  /// 要求用上了吗区域。
  final ZhenxieTaskDetailsMemberWritingReview review;

  const ZhenxieTaskUseItWidget({
    super.key,
    required this.controller,
    required this.review,
  });

  @override
  State<ZhenxieTaskUseItWidget> createState() => _ZhenxieTaskUseItWidgetState();
}

class _ZhenxieTaskUseItWidgetState extends State<ZhenxieTaskUseItWidget> {
  /// 是否展开未用上的语法点列表。
  bool isExpandNotUse = false;

  @override
  Widget build(BuildContext context) {
    final knowledgeRows = widget.review.knowledgeUses?.whereType<ZhenxieTaskDetailsMemberWritingReviewKnowledgeUse>().toList() ?? const [];
    final grammarRows = widget.review.grammarUses?.whereType<ZhenxieTaskDetailsMemberWritingReviewGrammarUse>().toList() ?? const [];
    final usedKnowledge = knowledgeRows.where((item) => _hasAnchors(item.anchors)).toList();
    final unusedKnowledge = knowledgeRows.where((item) => !_hasAnchors(item.anchors)).toList();
    final usedGrammar = grammarRows.where((item) => _hasAnchors(item.anchors)).toList();
    final unusedGrammar = grammarRows.where((item) => !_hasAnchors(item.anchors)).toList();
    if (knowledgeRows.isEmpty && grammarRows.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: EdgeInsets.only(top: 32.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "要求用上了吗",
            style: TextStyle(
              fontSize: 28.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cZhenxieFontTertiary.color,
            ),
          ),
          SizedBox(height: 10.wMin),
          if (knowledgeRows.isNotEmpty) _buildKnowledgeWidget(usedKnowledge, unusedKnowledge),
          if (knowledgeRows.isNotEmpty && grammarRows.isNotEmpty) SizedBox(height: 16.wMin),
          if (grammarRows.isNotEmpty) _buildGrammarWidget(usedGrammar, unusedGrammar),
        ],
      ),
    );
  }

  /// 渲染核心词命中情况。
  Widget _buildKnowledgeWidget(
    List<ZhenxieTaskDetailsMemberWritingReviewKnowledgeUse> usedKnowledge,
    List<ZhenxieTaskDetailsMemberWritingReviewKnowledgeUse> unusedKnowledge,
  ) {
    final total = usedKnowledge.length + unusedKnowledge.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "核心词 用上${usedKnowledge.where((item) => (item.anchors ?? []).isNotEmpty).length}/$total",
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cZhenxieFontSecondary.color,
          ),
        ),
        SizedBox(height: 8.wMin),
        Wrap(
          spacing: 8.wMin,
          runSpacing: 8.wMin,
          children: [
            ...usedKnowledge.map(_buildUsedKnowledgeItemWidget),
            ...unusedKnowledge.map(_buildUnusedKnowledgeItemWidget),
          ],
        ),
      ],
    );
  }

  /// 渲染已命中的知识点芯片。
  Widget _buildUsedKnowledgeItemWidget(ZhenxieTaskDetailsMemberWritingReviewKnowledgeUse item) {
    
    final anchors = item.anchors?.whereType<ZhenxieTaskDetailsMemberWritingReviewAnchor>().toList() ?? const [];
    return Container(
      height: 40.wMin,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        color: AppTheme.cZhenxieBackgroundPrimary.color,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TapScaleWidget(
            onTap: () {
              widget.controller.toggleFocusAnchors(
                focusKey: _knowledgeFocusKey(item),
                anchors: anchors,
              );
            },
            sclae: 1,
            child: Obx((){
              final active = widget.controller.focusAnchorKey.value == _knowledgeFocusKey(item);
              return Container(
                height: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12.wMin),
                decoration: BoxDecoration(
                  color: active ? AppTheme.cZhenxieColorPrimary.color : AppTheme.cZhenxieFontPrimary.color,
                  borderRadius: BorderRadius.horizontal(left: Radius.circular(99)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      "assets/svg/public/icon_check_w.svg",
                      width: 18.wMin,
                      colorFilter: ColorFilter.mode(AppTheme.cStaticDeprecatedBlack.color, BlendMode.srcIn),
                    ),
                    SizedBox(width: 4.wMin),
                    Text(
                      item.content ?? "",
                      style: TextStyle(
                        fontSize: 24.wMin,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.cStaticDeprecatedBlack.color,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          SizedBox(width: 0.4.wMin),
          TapScaleWidget(
            onTap: () {
              ElementsPageUtils.jumpElementsPage(
                contentId: item.uid,
                contentType: item.contentType,
                semanticId: item.semanticId,
                styleId: null,
                dialect: null,
                isManagement: widget.controller.pageController().isManagement,
              );
            },
            sclae: 1,
            child: Container(
              height: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 10.wMin),
              decoration: BoxDecoration(
                color: AppTheme.cZhenxieFontPrimary.color,
                borderRadius: BorderRadius.horizontal(right: Radius.circular(99)),
              ),
              child: SvgPicture.asset(
                "assets/svg/public/icon_deeplink.svg",
                width: 20.wMin,
                colorFilter: ColorFilter.mode(AppTheme.cStaticDeprecatedBlack.color, BlendMode.srcIn),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 渲染未命中的知识点芯片。
  Widget _buildUnusedKnowledgeItemWidget(ZhenxieTaskDetailsMemberWritingReviewKnowledgeUse item) {
    final text = item.content ?? "";
    return TapScaleWidget(
      onTap: () {
        ElementsPageUtils.jumpElementsPage(
          contentId: item.uid,
          contentType: item.contentType,
          semanticId: item.semanticId,
          styleId: null,
          dialect: null,
          isManagement: widget.controller.pageController().isManagement,
        );
      },
      sclae: 1,
      child: DottedBorder(
        radius: Radius.circular(99),
        borderType: BorderType.RRect,
        padding: EdgeInsets.zero,
        color: AppTheme.cZhenxieBorderPrimary.color,
        dashPattern: [4.wMin, 4.wMin],
        strokeWidth: 0.8.wMin,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 6.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            color: AppTheme.cZhenxieBackgroundPrimary.color,
            border: Border.all(
              color: AppTheme.cZhenxieBorderPrimary.color,
              width: 0.8.wMin,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cZhenxieFontTertiary.color,
            ),
          ),
        ),
      ),
    );
  }

  /// 渲染语法点命中情况。
  Widget _buildGrammarWidget(
    List<ZhenxieTaskDetailsMemberWritingReviewGrammarUse> usedGrammar,
    List<ZhenxieTaskDetailsMemberWritingReviewGrammarUse> unusedGrammar,
  ) {
    final total = usedGrammar.length + unusedGrammar.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "本课语法点 用上${usedGrammar.where((item) => (item.anchors ?? []).isNotEmpty).length}/$total",
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cZhenxieFontSecondary.color,
          ),
        ),
        SizedBox(height: 8.wMin),
        Column(
          spacing: 8.wMin,
          children: usedGrammar.map(_buildUsedGrammarItemWidget).toList(),
        ),
        if (unusedGrammar.isNotEmpty) ...[
          SizedBox(height: 12.wMin),
          _buildUnusedToggleWidget(count: unusedGrammar.length),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 150),
            alignment: Alignment.topCenter,
            crossFadeState: isExpandNotUse ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: 12.wMin),
              child: Wrap(
                spacing: 8.wMin,
                runSpacing: 8.wMin,
                children: unusedGrammar.map(_buildUnusedGrammarItemWidget).toList(),
              ),
            ),
            secondChild: Container(),
          ),
        ],
      ],
    );
  }

  /// 渲染已命中的语法点卡片。
  Widget _buildUsedGrammarItemWidget(ZhenxieTaskDetailsMemberWritingReviewGrammarUse item) {
    final anchors = item.anchors?.whereType<ZhenxieTaskDetailsMemberWritingReviewAnchor>().toList() ?? const [];
    final quote = anchors.isNotEmpty ? anchors.first.quote ?? "" : "";
    final suffix = anchors.length > 1 ? " 等 ${anchors.length} 处" : "";
    return Obx((){
      final active = widget.controller.focusAnchorKey.value == _grammarFocusKey(item);
      return TapScaleWidget(
        onTap: () {
          widget.controller.toggleFocusAnchors(
            focusKey: _grammarFocusKey(item),
            anchors: anchors,
          );
        },
        sclae: 1,
        borderRadius: 16.wMin,
        backColor: AppTheme.cSurfaceLayerBase.color,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.wMin),
            color: Colors.transparent,
            border: Border.all(
              color: active ? AppTheme.cZhenxieColorPrimary.color : AppTheme.cZhenxieBorderPrimary.color,
              width: 0.8.wMin,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 6.wMin),
                    child: SvgPicture.asset(
                      "assets/svg/public/icon_check_w.svg",
                      width: 20.wMin,
                      colorFilter: ColorFilter.mode(AppTheme.cZhenxieFontPrimary.color, BlendMode.srcIn),
                    ),
                  ),
                  SizedBox(width: 4.wMin),
                  Expanded(
                    child: Text(
                      item.title ?? "",
                      style: TextStyle(
                        fontSize: 24.wMin,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.cZhenxieFontPrimary.color,
                      ),
                    ),
                  ),
                  TapScaleWidget(
                    onTap: () => widget.controller.pageController().jumpToGrammarDetail(item.uid),
                    sclae: 1.05,
                    child: Container(
                      color: Colors.transparent,
                      padding: EdgeInsets.symmetric(horizontal: 10.wMin),
                      child: SvgPicture.asset(
                        "assets/svg/public/icon_deeplink.svg",
                        width: 24.wMin,
                        colorFilter: ColorFilter.mode(AppTheme.cZhenxieFontTertiary.color, BlendMode.srcIn),
                      ),
                    ),
                  ),
                ],
              ),
              if (quote.isNotEmpty) ...[
                SizedBox(height: 6.wMin),
                Text(
                  "“$quote”$suffix",
                  style: TextStyle(
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cZhenxieFontTertiary.color,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  /// 渲染未命中的语法点芯片。
  Widget _buildUnusedGrammarItemWidget(ZhenxieTaskDetailsMemberWritingReviewGrammarUse item) {
    final text = item.title ?? "";
    return TapScaleWidget(
      onTap: () => widget.controller.pageController().jumpToGrammarDetail(item.uid),
      sclae: 1,
      child: DottedBorder(
        radius: Radius.circular(99),
        borderType: BorderType.RRect,
        padding: EdgeInsets.zero,
        color: AppTheme.cZhenxieBorderPrimary.color,
        dashPattern: [4.wMin, 4.wMin],
        strokeWidth: 0.8.wMin,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 6.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            color: AppTheme.cZhenxieBackgroundPrimary.color,
            border: Border.all(
              color: AppTheme.cZhenxieBorderPrimary.color,
              width: 0.8.wMin,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cZhenxieFontTertiary.color,
            ),
          ),
        ),
      ),
    );
  }

  /// 渲染“还有 N 个这次没用上”的开关。
  Widget _buildUnusedToggleWidget({required int count}) {
    return TapScaleWidget(
      onTap: () {
        isExpandNotUse = !isExpandNotUse;
        if (mounted) setState(() {});
      },
      sclae: 1,
      child: Container(
        color: Colors.transparent,
        child: Text(
          "还有 $count 个这次没用上 · ${isExpandNotUse ? "收起" : "展开"}",
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cZhenxieFontSecondary.color,
          ),
        ),
      ),
    );
  }

  /// anchor 非空表示这项确实命中了正文。
  bool _hasAnchors(List<ZhenxieTaskDetailsMemberWritingReviewAnchor?>? anchors) {
    return anchors?.whereType<ZhenxieTaskDetailsMemberWritingReviewAnchor>().isNotEmpty == true;
  }

  /// 构造知识点命中的稳定 focus key。
  String _knowledgeFocusKey(ZhenxieTaskDetailsMemberWritingReviewKnowledgeUse item) {
    return 'knowledge-${item.contentType ?? ''}-${item.uid ?? 0}-${item.semanticId ?? 0}';
  }

  /// 构造语法点命中的稳定 focus key。
  String _grammarFocusKey(ZhenxieTaskDetailsMemberWritingReviewGrammarUse item) {
    return 'grammar-${item.uid ?? 0}';
  }
}

/// 下次先改区域。
class ZhenxieTaskNextFirstWidget extends StatelessWidget {
  /// 当前优先修改建议。
  final List<String> priorities;

  const ZhenxieTaskNextFirstWidget({super.key, required this.priorities});

  @override
  Widget build(BuildContext context) {
    if (priorities.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: EdgeInsets.only(top: 32.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "下次先改",
            style: TextStyle(
              fontSize: 28.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cZhenxieFontTertiary.color,
            ),
          ),
          SizedBox(height: 10.wMin),
          Column(
            spacing: 10.wMin,
            children: List.generate(priorities.length, (index) {
              return _buildItemWidget(index: index, content: priorities[index]);
            }),
          ),
        ],
      ),
    );
  }

  /// 渲染单条优先建议。
  Widget _buildItemWidget({
    required int index,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40.wMin,
          height: 40.wMin,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.cZhenxieBackgroundPrimary.color,
            border: Border.all(
              color: AppTheme.cZhenxieBorderPrimary.color,
              width: 0.8.wMin,
            ),
          ),
          child: Text(
            "${index + 1}",
            style: TextStyle(
              fontSize: 14.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cZhenxieFontPrimary.color,
            ),
          ),
        ),
        SizedBox(width: 10.wMin),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(top: 2.wMin),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cZhenxieFontTertiary.color,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 批改提示区域。
class ZhenxieTaskWarningsWidget extends StatelessWidget {
  /// 当前 warning 文案列表。
  final List<String> warnings;

  const ZhenxieTaskWarningsWidget({super.key, required this.warnings});

  @override
  Widget build(BuildContext context) {
    if (warnings.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: EdgeInsets.only(top: 32.wMin),
      padding: EdgeInsets.all(12.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          color: AppTheme.cBorderTranslucentThin.color,
          width: 0.8.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "批改提示",
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cZhenxieFontSecondary.color,
            ),
          ),
          SizedBox(height: 8.wMin),
          Column(
            spacing: 6.wMin,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: warnings.map((item) {
              return Text(
                "· $item",
                style: TextStyle(
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cZhenxieFontTertiary.color,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// 通用的单段文字区域。
class _ReviewTextSection extends StatelessWidget {
  /// 区块标题。
  final String title;

  /// 区块正文。
  final String? content;

  const _ReviewTextSection({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    if ((content ?? '').isEmpty) return const SizedBox.shrink();
    return Container(
      margin: EdgeInsets.only(top: 32.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 28.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cZhenxieFontTertiary.color,
            ),
          ),
          SizedBox(height: 10.wMin),
          Text(
            content!,
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cZhenxieFontTertiary.color,
            ),
          ),
        ],
      ),
    );
  }
}
