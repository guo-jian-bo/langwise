// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/zhenxie/zhenxie_sentence_pair_details/views/zhenxie_sentence_pair_details_table_widget.dart';
import 'package:langwise/common/enum/enum.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/values/app_font_value.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/common/widgets/zhenxie_widgets/set_expansion_buttons_widget.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../routes/routes.dart';
import '../../../common/commons.dart';
import '../../../enums/enums.dart';
import '../bindings/manage_unit_grammar_target_details_binding.dart';
import '../controllers/manage_unit_grammar_target_details_controller.dart';

class ManageUnitGrammarTargetDetailsView extends GetView<ManageUnitGrammarTargetDetailsController> {
  final String tagText;
  const ManageUnitGrammarTargetDetailsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_UNIT_GRAMMAR_TARGET_DETAILS}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageUnitGrammarTargetDetailsView(tagText: tag),
      binding: ManageUnitGrammarTargetDetailsBinding(tag: tag),
      routeName: Routes.MANAGE_UNIT_GRAMMAR_TARGET_DETAILS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  Color get _textPrimary => AppTheme.cTextPrimary.color;
  Color get _textSecondary => AppTheme.cTextSecondary.color;
  Color get _textTertiary => AppTheme.cTextTertiary.color;

  static const Map<String, Color> _statusColorMap = {
    'candidate': Color(0xffF59E0B),
    'approved': Color(0xff34D399),
    'disabled': Color(0xff94A3B8),
  };

  static const Map<String, String> _statusLabelMap = {
    'candidate': '备选',
    'approved': '通过',
    'disabled': '未通过',
  };

  static const Map<String, Color> _typeColorMap = {
    'EN_SENTENCE_PATTERN': Color(0xff8B5CF6),
    'EN_SENTENCE_PATTERN_PAIR': Color(0xffFB7185),
    'EN_SENTENCE_PATTERN_PAIR_FORK': Color(0xffF97316),
    'EN_SENTENCE_PARADIGM': Color(0xffD946EF),
    'EN_SENTENCE_PYRAMID': Color(0xffA855F7),
    'EN_SENTENCE_GRAMMAR_GRID': Color(0xffEC4899),
  };

  static const Map<String, String> _typeLabelMap = {
    'EN_SENTENCE_PATTERN': '句型蓝图',
    'EN_SENTENCE_PATTERN_PAIR': '句间配链',
    'EN_SENTENCE_PATTERN_PAIR_FORK': '配句分叉',
    'EN_SENTENCE_PARADIGM': '句型对照',
    'EN_SENTENCE_PYRAMID': '句型金字塔',
    'EN_SENTENCE_GRAMMAR_GRID': '语法全景宫格',
  };

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      onRefresh: () => controller.fetchData(showLoading: true),
      body: Column(
        children: [
          Visibility(
            visible: !controller.isManagement,
            child: BreadcrumbWidget(
               isCompatibleManage: true,
              actionWidget: GeneralSettingButtonWidget(
                isManagement: controller.isManagement,
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.detailData.value == null) {
                return const SizedBox.shrink();
              }

              if (controller.detailData.value == null) {
                return Center(
                  child: Text(
                    '暂无 Target 详情数据',
                    style: TextStyle(
                      color: _textSecondary,
                      fontSize: 16.wMin,
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                controller: controller.scrollController,
                padding: EdgeInsets.symmetric(horizontal: 90.wMin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 32.wMin),
                    _buildTopWidget(),
                    _buildAssetWidget(),
                    _buildBottomWidget(),
                    SizedBox(height: 120.wMin),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// 头部信息区，承接标题、标签和说明。
  Widget _buildTopWidget() {
    return _buildInfoWidget();
  }

  /// 资产主区域：当前先对 pattern 做完整渲染，其余资产先占位。
  Widget _buildAssetWidget() {
    final String? type = controller.detailData.value?.grammarUnifiedInfo?.type;
    if (type == ZhenxieEnSentenceType.EN_SENTENCE_PATTERN_PAIR_FORK.rawValue ||
        type == ZhenxieEnSentenceType.EN_SENTENCE_PATTERN_PAIR.rawValue) {
      return const SizedBox.shrink();
    }

    if (type == ZhenxieEnSentenceType.EN_SENTENCE_GRAMMAR_GRID.rawValue && controller.grammarPanoramaData.value != null) {
      return _buildGrammarPanoramaAssetWidget();
    }

    if (type == ZhenxieEnSentenceType.EN_SENTENCE_PARADIGM.rawValue) {
      return const SizedBox.shrink();
    }

    if (type == ZhenxieEnSentenceType.EN_SENTENCE_PATTERN.rawValue || type == ZhenxieEnSentenceType.EN_SENTENCE_PYRAMID.rawValue) {
      return _buildPatternSlotMapWidget();
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 24.wMin),
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          width: 1.wMin,
          color: AppTheme.cBorderThin.color,
        ),
      ),
      child: Text(
        "当前先完成句型蓝图、句子类型对照和句型对照详情渲染，${_typeLabelMap[type] ?? type ?? '该类型'} 详情后续再补。",
        style: TextStyle(
          fontSize: 18.wMin,
          fontWeight: FontWeight.w400,
          color: _textTertiary,
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 24.wMin),
      padding: padding ?? EdgeInsets.all(15.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          width: 1.wMin,
          color: AppTheme.cBorderThin.color,
        ),
      ),
      child: child,
    );
  }

  Widget _buildBottomWidget() {
    if (controller.isApprovedTarget()) {
      return _buildWorkbenchWidget();
    }
    return _buildReviewWidget();
  }

  Widget _buildWorkbenchWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUngroupedSentencesWidget(),
        _buildGroupedSentenceSetsWidget(),
      ],
    );
  }

  /// 已通过态的未归组句区域。
  Widget _buildUngroupedSentencesWidget() {
    return Obx(() {
      final List<Widget> actionWidgets = _buildWorkbenchActionWidgets();
      final List<Widget> ungroupedCards = _buildUngroupedSetCards();
      final String? type = controller.detailData.value?.grammarUnifiedInfo?.type;
      final String ungroupedTitle = type == ZhenxieEnSentenceType.EN_SENTENCE_PATTERN_PAIR_FORK.rawValue ||
              type == ZhenxieEnSentenceType.EN_SENTENCE_PATTERN_PAIR.rawValue
          ? '未归组•上一句'
          : '未归组句';
      return _buildSectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                              ungroupedTitle,
                            style: TextStyle(
                              fontSize: 20.wMin,
                              fontWeight: FontWeight.w700,
                              color: _textPrimary,
                              fontFamily: AppFontValue.sourceHanSerifCN,
                            ),
                          ),
                        ],
                      ),
                      if (ungroupedCards.isEmpty) ...[
                        SizedBox(height: 16.wMin),
                        Text(
                          _buildUngroupedEmptyHint(),
                          style: TextStyle(
                            fontSize: 16.wMin,
                            fontWeight: FontWeight.w700,
                            color: _textTertiary,
                            fontFamily: AppFontValue.sourceHanSerifCN,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (actionWidgets.isNotEmpty)
                  SizedBox(
                    width: 520.wMin,
                    child: Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 4.wMin,
                      runSpacing: 4.wMin,
                      children: actionWidgets,
                    ),
                  ),
              ],
            ),
            if (ungroupedCards.isNotEmpty) ...[
              SizedBox(height: 16.wMin),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(ungroupedCards.length, (index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: index == ungroupedCards.length - 1 ? 0 : 12.wMin),
                    child: ungroupedCards[index],
                  );
                }),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildPatternSlotMapWidget() {
    final Map<String, dynamic> payload = controller.grammarStructPayload;
    if (payload.isEmpty) {
      return const SizedBox.shrink();
    }
    final PatternBlueprintEntity data = PatternBlueprintEntity.fromJson(payload);
    return _buildSectionCard(
      child: SentenceSlotMapWidget(
        data: SentenceSlotMapUtils.buildFromPatternBlueprint(data),
        showDepend: true,
      ),
      padding: EdgeInsets.all(8.wMin),
    );
  }

  /// 已通过态的已归组区域。
  Widget _buildGroupedSentenceSetsWidget() {
    final List<Widget> groupedCards = _buildGroupedSetCards();
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '已归组',
                      style: TextStyle(
                        fontSize: 20.wMin,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                        fontFamily: AppFontValue.sourceHanSerifCN,
                      ),
                    ),
                    SizedBox(height: 12.wMin),
                    Text(
                      groupedCards.isEmpty ? '还没有签发组。点「添加一组」把未归组句收进来。' : '已签发 ${groupedCards.length} 组。',
                      style: TextStyle(
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w500,
                        color: _textSecondary,
                        fontFamily: AppFontValue.sourceHanSerifCN,
                        height: 1.33,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (groupedCards.isNotEmpty) ...[
            SizedBox(height: 16.wMin),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(groupedCards.length, (index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: index == groupedCards.length - 1 ? 0 : 12.wMin),
                  child: groupedCards[index],
                );
              }),
            ),
          ],
          if (controller.canLoadMoreSentenceSetPages() || controller.isSentenceSetLoadingMore.value) ...[
            SizedBox(height: 16.wMin),
            Align(
              alignment: Alignment.centerRight,
              child: _buildWorkbenchActionButton(
                text: controller.isSentenceSetLoadingMore.value ? '加载中...' : '加载更多已归组',
                isPrimary: false,
                onTap: () {
                  if (controller.isSentenceSetLoadingMore.value) return;
                  controller.loadMoreSentenceSetPages();
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 待审核区域：展示教材支持点、LLM 自评和审核动作。
  Widget _buildReviewWidget() {
    final List<_ManageUnitGrammarReviewActionItem> actionItems = _buildReviewActionItems(controller.detailData.value?.status);
    final bool hasReviewQueue = controller.hasReviewQueue();
    final int? previousTargetUid = hasReviewQueue ? controller.getPreviousReviewTargetUid() : null;
    final int? nextTargetUid = hasReviewQueue ? controller.getNextReviewTargetUid() : null;

    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  '审核区域',
                  style: TextStyle(
                    fontSize: 20.wMin,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                    fontFamily: AppFontValue.sourceHanSerifCN,
                  ),
                ),
              ),
              SizedBox(width: 16.wMin),
              if (actionItems.isNotEmpty)
                SizedBox(
                  width: 260.wMin,
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 4.wMin,
                    runSpacing: 4.wMin,
                    children: actionItems.map((item) {
                      return _buildReviewDecisionButton(
                        text: item.text,
                        isPrimary: item.status == 'approved',
                        onTap: () {
                          controller.onReviewStatus(item.status);
                        },
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
          if (hasReviewQueue) ...[
            SizedBox(height: 16.wMin),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildNavigatorButton(
                  icon: Icons.chevron_left_rounded,
                  enabled: previousTargetUid != null,
                  onTap: () {
                    controller.onOpenReviewQueueTarget(previousTargetUid);
                  },
                ),
                SizedBox(width: 8.wMin),
                Column(
                  children: [
                    Text(
                      '第 ${controller.currentReviewQueueOrder()} / ${controller.reviewQueueTotalCount()} 条',
                      style: TextStyle(
                        fontSize: 14.wMin,
                        fontWeight: FontWeight.w500,
                        color: _textPrimary,
                        fontFamily: AppFontValue.langWiseFont,
                      ),
                    ),
                    Text(
                      '还剩 ${controller.remainingReviewQueueCandidateCount()} 条待审',
                      style: TextStyle(
                        fontSize: 12.wMin,
                        fontWeight: FontWeight.w400,
                        color: _textTertiary,
                        fontFamily: AppFontValue.langWiseFont,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 8.wMin),
                _buildNavigatorButton(
                  icon: Icons.chevron_right_rounded,
                  enabled: nextTargetUid != null,
                  onTap: () {
                    controller.onOpenReviewQueueTarget(nextTargetUid);
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _buildUngroupedEmptyHint() {
    if (controller.canOperatePatternActions()) {
      return '还没有未归组句。用搜索或生成补进这个池。';
    }
    return '还没有未归组句。';
  }

  List<Widget> _buildWorkbenchActionWidgets() {
    final List<Widget> widgets = [];
    if (controller.canOperatePatternActions()) {
      widgets.add(
        _buildWorkbenchActionButton(
          text: '搜索库里已有句子',
          onTap: controller.onTapSearchLibrary,
        ),
      );
      widgets.add(
        _buildWorkbenchActionButton(
          text: '生成句子',
          isPrimary: false,
          onTap: controller.onTapGenerateSentence,
        ),
      );
    }
    if (controller.canAddRealizationSet()) {
      widgets.add(
        _buildWorkbenchActionButton(
          text: '添加一组',
          enabled: !controller.shouldDisableAddGroupButton(),
          onTap: controller.onTapAddGroup,
        ),
      );
    }
    return widgets;
  }

  Widget _buildWorkbenchActionButton({
    required String text,
    required VoidCallback onTap,
    bool isPrimary = true,
    bool enabled = true,
  }) {
    final Color borderColor = !enabled
        ? AppTheme.cBorderThin.color
        : isPrimary
            ? Colors.transparent
            : AppTheme.cDifficultyBackgroundColor22.color.withValues(alpha: 0.2);
    final Color backgroundColor = !enabled
        ? AppTheme.cSurfaceLayerBase.color
        : isPrimary
            ? AppTheme.cTextPrimary.color
            : AppTheme.cDifficultyBackgroundColor22.color.withValues(alpha: 0.12);
    final Color textColor = !enabled
        ? _textTertiary
        : isPrimary
            ? AppTheme.cBgPrimary
            : AppTheme.cTextPrimary.color;
    return TapScaleWidget(
      sclae: 1.02,
      onTap: enabled ? onTap : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 8.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9999),
          color: backgroundColor,
          border: Border.all(
            color: borderColor,
            width: 1.wMin,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w500,
            color: textColor,
            fontFamily: AppFontValue.langWiseFont,
          ),
        ),
      ),
    );
  }

  Widget _buildReviewDecisionButton({
    required String text,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return TapScaleWidget(
      sclae: 1.02,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 8.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9999),
          color: isPrimary ? AppTheme.cTextPrimary.color : AppTheme.cSurfaceLayerBase.color,
          border: Border.all(
            color: isPrimary ? Colors.transparent : AppTheme.cBorderDefault.color,
            width: 1.wMin,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w500,
            color: isPrimary ? AppTheme.cBgPrimary : _textSecondary,
            fontFamily: AppFontValue.langWiseFont,
          ),
        ),
      ),
    );
  }

  Widget _buildSentenceDeleteButton({
    required VoidCallback onTap,
  }) {
    return ButtonWidget(
      text: '删除',
      sclae: 1.03,
      onTap: onTap,
      padding: EdgeInsets.only(left: 8.wMin),
      height: 38.wMin,
      width: 82.wMin,
      borderRadius: 99,
      color: AppTheme.cSurfaceError.color.withValues(alpha: 0.12),
      border: Border.all(
        color: AppTheme.cSurfaceError.color.withValues(alpha: 0.24),
        width: 1.wMin,
      ),
      fontSize: 16.wMin,
      fontColor: AppTheme.cSurfaceError.color,
      fontWeight: FontWeight.w500,
    );
  }

  List<Widget> _buildGroupedSetCards() {
    final List<ManageUnitGrammarTargetSentenceSetPageEntity> groups = controller.groupedSentenceSetPages;
    return List.generate(groups.length, (index) {
      final item = groups[index];
      return _buildSentenceSetCard(
        item,
        index: index,
        isUngroupedGroup: false,
        bindRealizationSetId: true,
      );
    });
  }

  List<Widget> _buildUngroupedSetCards() {
    if (controller.isPatternTarget()) {
      final List<_PatternUngroupedStructureGroup> groups = _buildPatternUngroupedStructureGroups();
      return List.generate(groups.length, (index) {
        return _buildPatternUngroupedStructureGroupCard(
          groups[index],
          index: index,
        );
      });
    }
    final List<ManageUnitGrammarTargetSentenceSetPageEntity> groups = controller.ungroupedSentenceSetPages;
    return List.generate(groups.length, (index) {
      final item = groups[index];
      return _buildSentenceSetCard(
        item,
        index: index,
        isUngroupedGroup: true,
        bindRealizationSetId: false,
      );
    });
  }

  Widget _buildSentenceSetCard(ManageUnitGrammarTargetSentenceSetPageEntity item,
      {required int index, required bool bindRealizationSetId, required bool isUngroupedGroup}) {
    if (item.assetType == 'pattern' || item.assetType == 'pyramid') {
      return _buildPatternSentenceSetGroupCard(
        item,
        context: Get.context!,
        index: index,
        bindRealizationSetId: bindRealizationSetId,
        isUngroupedGroup: isUngroupedGroup,
        showShell: !isUngroupedGroup,
      );
    }
    if (item.assetType == 'paradigm') {
      return _buildParadigmSentenceSetGroupCard(
        item,
        index: index,
        isUngroupedGroup: isUngroupedGroup,
        showShell: !isUngroupedGroup,
      );
    }
    if (item.assetType == 'pair_fork' || item.assetType == 'pair') {
      return _buildPairForkSentenceSetGroupCard(
        item,
        index: index,
        isUngroupedGroup: isUngroupedGroup,
        isPairAsset: item.assetType == 'pair',
      );
    }
    final String title = _buildSentenceSetTitle(item, index);
    final String subtitle = _buildSentenceSetSubtitle(item);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          width: 1.wMin,
          color: AppTheme.cBorderThin.color,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
              fontFamily: AppFontValue.sourceHanSerifCN,
            ),
          ),
          SizedBox(height: 8.wMin),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w500,
              color: _textSecondary,
              fontFamily: AppFontValue.sourceHanSerifCN,
              height: 1.33,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternSentenceSetGroupCard(
    ManageUnitGrammarTargetSentenceSetPageEntity item, {
    required BuildContext context,
    required int index,
    required bool bindRealizationSetId,
    required bool isUngroupedGroup,
    bool showShell = true,
    String? patternGroupKey,
  }) {
    final List<PatternBlueprintSentenceBriefEntity?> memberList =
        List<PatternBlueprintSentenceBriefEntity?>.from(item.contents ?? const []);
    final bool isPyramid = controller.detailData.value?.grammarUnifiedInfo?.type == ZhenxieEnSentenceType.EN_SENTENCE_PYRAMID.rawValue;
    final String title = '${isPyramid ? '金字塔' : '蓝图'} ${index + 1}';
    final bool isNormal = item.access == 'NORMAL';
    final Widget body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: memberList.isEmpty,
          child: Text(
            '暂无例句',
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
        ),
        ListView.separated(
          itemCount: memberList.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) => SizedBox(height: 24.wMin),
          itemBuilder: (context, memberIndex) {
            return _buildPatternSentenceSetSentenceItem(
              context: context,
              group: item,
              sentence: memberList[memberIndex],
              isNormal: isNormal,
              isUngroupedGroup: isUngroupedGroup,
              patternGroupKey: patternGroupKey,
            );
          },
        ),
      ],
    );
    if (!showShell) {
      return body;
    }
    return Container(
      padding: EdgeInsets.all(24.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cZhenxieBackgroundPrimary.color,
        border: Border.all(
          color: AppTheme.cZhenxieBorderPrimary.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextPrimary.color,
                  fontFamily: AppFontValue.sourceHanSerifCN,
                ),
              ),
              SizedBox(width: 12.wMin),
              CopyTagWidget(
                name: 'uid',
                value: item.uid?.toString() ?? '',
                isShow: controller.isManagement && item.uid != null,
              ),
              SizedBox(width: 12.wMin),
              if (controller.isManagement)
                _buildTagWidget(
                  tagText: isNormal ? '已上架' : '未上架',
                  textColor: isNormal ? AppTheme.cSurfaceSuccess.color : AppTheme.cSurfaceWarning.color,
                  bgColor: isNormal
                      ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.12)
                      : AppTheme.cSurfaceWarning.color.withValues(alpha: 0.12),
                  borderColor: isNormal
                      ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.2)
                      : AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2),
                ),
              const Spacer(),
              if (controller.isManagement && bindRealizationSetId)
                ManageIpDownEditDelWidget(
                  isNormal: isNormal,
                  onShelf: () {
                    controller.onShelfPatternSentenceSet(item);
                  },
                  onDelete: () {
                    controller.onDeletePatternSentenceSet(Get.context!, index, item);
                  },
                ),
            ],
          ),
          Container(
            height: 1.wMin,
            color: AppTheme.cZhenxieBorderPrimary.color,
            margin: EdgeInsets.symmetric(vertical: 16.wMin),
          ),
          body,
        ],
      ),
    );
  }

  Widget _buildPatternUngroupedStructureGroupCard(
    _PatternUngroupedStructureGroup group, {
    required int index,
  }) {
    final ManageUnitGrammarTargetSentenceSetPageEntity sourcePage = group.sourcePage;
    final List<int> sentenceIds = group.sentences
        .map((item) => item.actualSentenceId)
        .whereType<int>()
        .where((item) => item > 0)
        .toList();
    final bool isSelectedGroup = controller.selectedUngroupedPatternGroupKey.value == group.groupKey &&
        controller.selectedUngroupedSentenceIds.isNotEmpty;
    return Container(
      padding: EdgeInsets.all(24.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cZhenxieBackgroundPrimary.color,
        border: Border.all(
          color: isSelectedGroup ? AppTheme.cBgBrand.color : AppTheme.cZhenxieBorderPrimary.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '结构 ${index + 1}',
                style: TextStyle(
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextPrimary.color,
                  fontFamily: AppFontValue.sourceHanSerifCN,
                ),
              ),
              SizedBox(width: 12.wMin),
              _buildTagWidget(
                tagText: '${group.slotKeys.length} 槽位',
                textColor: AppTheme.cTextSecondary.color,
                bgColor: AppTheme.cSurfaceLayerBase.color,
                borderColor: AppTheme.cBorderThin.color,
              ),
              SizedBox(width: 8.wMin),
              _buildTagWidget(
                tagText: '${group.sentences.length} 句',
                textColor: AppTheme.cTextSecondary.color,
                bgColor: AppTheme.cSurfaceLayerBase.color,
                borderColor: AppTheme.cBorderThin.color,
              ),
              SizedBox(width: 12.wMin),
              TapScaleWidget(
                sclae: 1.02,
                onTap: () {
                  controller.toggleUngroupedPatternGroupSelection(
                    sentenceIds,
                    groupKey: group.groupKey,
                  );
                },
                child: Text(
                  controller.isUngroupedPatternGroupAllSelected(
                    sentenceIds,
                    groupKey: group.groupKey,
                  )
                      ? '全不选'
                      : '全选',
                  style: TextStyle(
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cTextLink.color,
                    fontFamily: AppFontValue.langWiseFont,
                  ),
                ),
              ),
              const Spacer(),
              if (isSelectedGroup)
                _buildTagWidget(
                  tagText: '当前选择组',
                  textColor: AppTheme.cBgBrand.color,
                  bgColor: AppTheme.cBgBrand.color.withValues(alpha: 0.12),
                  borderColor: AppTheme.cBgBrand.color.withValues(alpha: 0.2),
                ),
            ],
          ),
          Container(
            height: 1.wMin,
            color: AppTheme.cZhenxieBorderPrimary.color,
            margin: EdgeInsets.symmetric(vertical: 16.wMin),
          ),
          ListView.separated(
            itemCount: group.sentences.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) => SizedBox(height: 24.wMin),
            itemBuilder: (context, memberIndex) {
              return _buildPatternSentenceSetSentenceItem(
                context: Get.context!,
                group: sourcePage,
                sentence: group.sentences[memberIndex],
                isNormal: sourcePage.access == 'NORMAL',
                isUngroupedGroup: true,
                patternGroupKey: group.groupKey,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPairForkSentenceSetGroupCard(
    ManageUnitGrammarTargetSentenceSetPageEntity item, {
    required int index,
    required bool isUngroupedGroup,
    bool isPairAsset = false,
  }) {
    final List<PatternBlueprintSentenceBriefEntity?> memberList =
        List<PatternBlueprintSentenceBriefEntity?>.from(item.contents ?? const []);
    final bool isNormal = item.access == 'NORMAL';
    final bool hideShellDecoration = isPairAsset && isUngroupedGroup;
    return Container(
      padding: hideShellDecoration ? EdgeInsets.zero : EdgeInsets.all(24.wMin),
      decoration: hideShellDecoration
          ? null
          : BoxDecoration(
              borderRadius: BorderRadius.circular(16.wMin),
              color: AppTheme.cZhenxieBackgroundPrimary.color,
              border: Border.all(
                color: AppTheme.cZhenxieBorderPrimary.color,
                width: 1.wMin,
              ),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUngroupedGroup) ...[
            Row(
              children: [
                Text(
                  '${isPairAsset ? '配对' : '分叉'} ${index + 1}',
                  style: TextStyle(
                    fontSize: 20.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cTextPrimary.color,
                    fontFamily: AppFontValue.sourceHanSerifCN,
                  ),
                ),
                SizedBox(width: 12.wMin),
                CopyTagWidget(
                  name: 'uid',
                  value: item.uid?.toString() ?? '',
                  isShow: controller.isManagement && item.uid != null,
                ),
                SizedBox(width: 12.wMin),
                if (controller.isManagement)
                  _buildTagWidget(
                    tagText: isNormal ? '已上架' : '未上架',
                    textColor: isNormal ? AppTheme.cSurfaceSuccess.color : AppTheme.cSurfaceWarning.color,
                    bgColor: isNormal
                        ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.12)
                        : AppTheme.cSurfaceWarning.color.withValues(alpha: 0.12),
                    borderColor: isNormal
                        ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.2)
                        : AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2),
                  ),
                const Spacer(),
                if (controller.isManagement && item.isSet == true)
                  ManageIpDownEditDelWidget(
                    isNormal: isNormal,
                    onShelf: () {
                      controller.onShelfPatternSentenceSet(item);
                    },
                    onDelete: () {
                      controller.onDeletePatternSentenceSet(Get.context!, index, item);
                    },
                  ),
              ],
            ),
            Container(
              height: 1.wMin,
              color: AppTheme.cZhenxieBorderPrimary.color,
              margin: EdgeInsets.symmetric(vertical: 16.wMin),
            ),
          ],
          Visibility(
            visible: memberList.isEmpty,
            child: Text(
              '暂无例句',
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextTertiary.color,
              ),
            ),
          ),
          ListView.separated(
            itemCount: memberList.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) => SizedBox(height: 16.wMin),
            itemBuilder: (context, memberIndex) {
              if (!isUngroupedGroup) {
                if (isPairAsset) {
                  return _buildPairGroupedSentenceSetItem(memberList[memberIndex]);
                }
                return _buildPairForkGroupedSentenceSetItem(memberList[memberIndex]);
              }
              if (isPairAsset) {
                return _buildPairSentenceSetSentenceItem(
                  sentence: memberList[memberIndex],
                  isUngroupedGroup: isUngroupedGroup,
                );
              }
              return _buildPairForkSentenceSetSentenceItem(
                sentence: memberList[memberIndex],
                isUngroupedGroup: isUngroupedGroup,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPairGroupedSentenceSetItem(PatternBlueprintSentenceBriefEntity? sentence) {
    final SentencePairSentenceBriefEntity? fromSentence = sentence?.fromSentenceStruct;
    final SentencePairSentenceBriefEntity? toSentence = sentence?.toSentenceStruct;
    final String fromContent = fromSentence?.content?.trim() ?? '';
    final String toContent = toSentence?.content?.trim() ?? '';
    if (fromContent.isEmpty && toContent.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (fromContent.isNotEmpty)
          _buildPairGroupedLegRow(
            isQuestion: true,
            patternName: _readZhLanguageText(fromSentence?.patternName),
            content: fromContent,
            definition: fromSentence?.definition?.trim() ?? '',
            sentenceId: fromSentence?.sentenceId ?? sentence?.fromSentenceId,
            isNormal: fromSentence?.isNormal ?? false,
            onShelf: fromSentence == null
                ? null
                : () {
                    controller.onShelfPairSentence(fromSentence);
                  },
          ),
        if (fromContent.isNotEmpty && toContent.isNotEmpty) SizedBox(height: 18.wMin),
        if (toContent.isNotEmpty)
          _buildPairGroupedLegRow(
            isQuestion: false,
            patternName: '',
            content: toContent,
            definition: toSentence?.definition?.trim() ?? '',
            sentenceId: toSentence?.sentenceId ?? sentence?.toSentenceId,
            isNormal: toSentence?.isNormal ?? false,
            onShelf: toSentence == null
                ? null
                : () {
                    controller.onShelfPairSentence(toSentence);
                  },
          ),
      ],
    );
  }

  Widget _buildPairGroupedLegRow({
    required bool isQuestion,
    required String patternName,
    required String content,
    required String definition,
    required int? sentenceId,
    required bool isNormal,
    void Function()? onShelf,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 8.wMin, right: 10.wMin),
          child: Container(
            width: 10.wMin,
            height: 10.wMin,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isQuestion ? Colors.transparent : const Color(0xFFE6DCC8),
              border: Border.all(
                color: const Color(0xFFE6DCC8),
                width: isQuestion ? 1.5.wMin : 1.wMin,
              ),
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (patternName.isNotEmpty)
                Text(
                  patternName,
                  style: TextStyle(
                    fontSize: 15.wMin,
                    fontWeight: FontWeight.w500,
                    color: const Color(0x73E6DCC8),
                    height: 1.3,
                    fontFamily: AppFontValue.sourceHanSerifCN,
                  ),
                ),
              if (patternName.isNotEmpty) SizedBox(height: 4.wMin),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      content,
                      style: TextStyle(
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFF4EFE6),
                        height: 1.35,
                        fontFamily: AppFontValue.langWiseFont,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.wMin),
                  SetExpansionButtonsWidget(
                    isManagement: controller.isManagement,
                    sentenceId: sentenceId,
                    content: content,
                    isNormal: isNormal,
                    onShelf: onShelf,
                    onRefresh: () {
                      controller.fetchSentenceSetPages(reset: true);
                    },
                  ),
                ],
              ),
              if (definition.isNotEmpty) ...[
                SizedBox(height: 4.wMin),
                Text(
                  definition,
                  style: TextStyle(
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w400,
                    color: const Color(0x73E6DCC8),
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPairSentenceSetSentenceItem({
    required PatternBlueprintSentenceBriefEntity? sentence,
    required bool isUngroupedGroup,
  }) {
    final String content = sentence?.fromSentenceStruct?.content?.trim() ?? '';
    if (content.isEmpty) return const SizedBox.shrink();
    final int? sentenceId = sentence?.fromSentenceStruct?.sentenceId ?? sentence?.fromSentenceId;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isUngroupedGroup) ...[
          Padding(
            padding: EdgeInsets.only(top: 2.wMin, right: 10.wMin),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: sentenceId == null
                  ? null
                  : () {
                      controller.toggleUngroupedSentence(sentenceId);
                    },
              child: CardSelectDotWidget(
                isSelected: controller.isUngroupedSentenceSelected(sentenceId),
              ),
            ),
          ),
        ],
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 2.wMin),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextPrimary.color,
                height: 1.3,
              ),
            ),
          ),
        ),
        SizedBox(width: 12.wMin),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SetExpansionButtonsWidget(
              isManagement: controller.isManagement,
              sentenceId: sentenceId,
              content: content,
              isNormal: sentence?.fromSentenceStruct?.isNormal ?? false,
              onShelf: sentence == null
                  ? null
                  : () {
                      controller.onShelfPatternSentence(sentence);
                    },
              onRefresh: () {
                controller.fetchSentenceSetPages(reset: true);
              },
            ),
            if (controller.isManagement && isUngroupedGroup) ...[
              SizedBox(width: 10.wMin),
              _buildSentenceDeleteButton(
                onTap: () {
                  controller.onTapSentenceDelete(sentenceId);
                },
              ),
            ],
          ],
        ),
      ],
    );
  }

    Widget _buildPairForkGroupedSentenceSetItem(PatternBlueprintSentenceBriefEntity? sentence) {
      final SentenceForkRealizationBranchEntity? forkFrom = sentence?.forkFrom;
      final List<SentenceForkRealizationBranchEntity?> forkToList =
          List<SentenceForkRealizationBranchEntity?>.from(sentence?.forkToList ?? const []);
      final String leftContent = forkFrom?.sentenceStruct?.content?.trim() ?? '';
      if (leftContent.isEmpty && forkToList.isEmpty) return const SizedBox.shrink();
      return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: _buildPairForkBranchPanel(
                content: leftContent,
                definition: forkFrom?.sentenceStruct?.definition?.trim() ?? '',
                sentenceId: forkFrom?.sentenceStruct?.sentenceId ?? forkFrom?.sentenceId,
                isNormal: forkFrom?.sentenceStruct?.isNormal ?? false,
                onShelf: forkFrom?.sentenceStruct == null
                    ? null
                    : () {
                        controller.onShelfPairForkSentence(forkFrom?.sentenceStruct);
                      },
                showDivider: true,
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.only(left: 16.wMin),
                decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 1.wMin)),
                ),
                child: Column(
                  children: List.generate(forkToList.length, (index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: index == forkToList.length - 1 ? 0 : 20.wMin),
                      child: _buildPairForkBranchPanel(
                        content: forkToList[index]?.sentenceStruct?.content?.trim() ?? '',
                        definition: forkToList[index]?.sentenceStruct?.definition?.trim() ?? '',
                        sentenceId: forkToList[index]?.sentenceStruct?.sentenceId ?? forkToList[index]?.sentenceId,
                        isNormal: forkToList[index]?.sentenceStruct?.isNormal ?? false,
                        onShelf: forkToList[index]?.sentenceStruct == null
                            ? null
                            : () {
                                controller.onShelfPairForkSentence(forkToList[index]?.sentenceStruct);
                              },
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        )
    ;
    }

    Widget _buildPairForkBranchPanel({
      required String content,
      required String definition,
      required int? sentenceId,
      required bool isNormal,
      void Function()? onShelf,
      bool showDivider = false,
    }) {
      if (content.isEmpty) return const SizedBox.shrink();
      return Container(
        padding: EdgeInsets.only(right: showDivider ? 16.wMin : 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    content,
                    style: TextStyle(
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFF4EFE6),
                      height: 1.35,
                      fontFamily: AppFontValue.langWiseFont,
                    ),
                  ),
                ),
                SizedBox(width: 12.wMin),
                SetExpansionButtonsWidget(
                  isManagement: controller.isManagement,
                  sentenceId: sentenceId,
                  content: content,
                  isNormal: isNormal,
                  onShelf: onShelf,
                  onRefresh: () {
                    controller.fetchSentenceSetPages(reset: true);
                  },
                ),
              ],
            ),
            if (definition.isNotEmpty) ...[
              SizedBox(height: 6.wMin),
              Text(
                definition,
                style: TextStyle(
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w400,
                  color: const Color(0x73E6DCC8),
                  height: 1.35,
                ),
              ),
            ],
          ],
        ),
      );
    }

  Widget _buildPairForkSentenceSetSentenceItem({
    required PatternBlueprintSentenceBriefEntity? sentence,
    required bool isUngroupedGroup,
  }) {
    final String content = sentence?.forkFrom?.sentenceStruct?.content?.trim() ?? '';
    if (content.isEmpty) return const SizedBox.shrink();
    final int? sentenceId = sentence?.actualSentenceId;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isUngroupedGroup) ...[
          Padding(
            padding: EdgeInsets.only(top: 2.wMin, right: 10.wMin),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: sentenceId == null
                  ? null
                  : () {
                      controller.toggleUngroupedSentence(sentenceId);
                    },
              child: CardSelectDotWidget(
                isSelected: controller.isUngroupedSentenceSelected(sentenceId),
              ),
            ),
          ),
        ],
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 2.wMin),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextPrimary.color,
                height: 1.3,
              ),
            ),
          ),
        ),
        SizedBox(width: 12.wMin),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SetExpansionButtonsWidget(
              isManagement: controller.isManagement,
              sentenceId: sentenceId,
              content: content,
              isNormal: sentence?.isNormal ?? false,
              onShelf: sentence == null
                  ? null
                  : () {
                      controller.onShelfPatternSentence(sentence);
                    },
              onRefresh: () {
                controller.fetchSentenceSetPages(reset: true);
              },
            ),
            if (controller.isManagement && isUngroupedGroup) ...[
              SizedBox(width: 10.wMin),
              _buildSentenceDeleteButton(
                onTap: () {
                  controller.onTapSentenceDelete(sentenceId);
                },
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildParadigmSentenceSetGroupCard(
    ManageUnitGrammarTargetSentenceSetPageEntity item, {
    required int index,
    required bool isUngroupedGroup,
    bool showShell = true,
  }) {
    final List<_ParadigmSentenceGroup> sentenceGroups = _buildParadigmSentenceGroups(
      item.contents,
      isUngroupedGroup: isUngroupedGroup,
    );
    final Widget body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sentenceGroups.isEmpty)
          Text(
            '暂无例句',
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
        if (sentenceGroups.isNotEmpty)
          ListView.separated(
            itemCount: sentenceGroups.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) => SizedBox(height: 20.wMin),
            itemBuilder: (context, groupIndex) {
              return _buildParadigmSentenceGroupSection(
                sentenceGroups[groupIndex],
                isUngroupedGroup: isUngroupedGroup,
              );
            },
          ),
      ],
    );
    if (!showShell) {
      return body;
    }
    return Container(
      padding: EdgeInsets.all(24.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cZhenxieBackgroundPrimary.color,
        border: Border.all(
          color: AppTheme.cZhenxieBorderPrimary.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '对照 ${index + 1}',
                style: TextStyle(
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextPrimary.color,
                  fontFamily: AppFontValue.sourceHanSerifCN,
                ),
              ),
              SizedBox(width: 12.wMin),
              CopyTagWidget(
                name: 'uid',
                value: item.uid?.toString() ?? '',
                isShow: controller.isManagement && item.uid != null,
              ),
              SizedBox(width: 12.wMin),
              if (controller.isManagement)
                _buildTagWidget(
                  tagText: item.access == 'NORMAL' ? '已上架' : '未上架',
                  textColor: item.access == 'NORMAL' ? AppTheme.cSurfaceSuccess.color : AppTheme.cSurfaceWarning.color,
                  bgColor: item.access == 'NORMAL'
                      ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.12)
                      : AppTheme.cSurfaceWarning.color.withValues(alpha: 0.12),
                  borderColor: item.access == 'NORMAL'
                      ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.2)
                      : AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2),
                ),
              const Spacer(),
              if (controller.isManagement && item.isSet == true)
                ManageIpDownEditDelWidget(
                  isNormal: item.access == 'NORMAL',
                  onShelf: () {
                    controller.onShelfPatternSentenceSet(item);
                  },
                  onDelete: () {
                    controller.onDeletePatternSentenceSet(Get.context!, index, item);
                  },
                ),
            ],
          ),
          Container(
            height: 1.wMin,
            color: AppTheme.cZhenxieBorderPrimary.color,
            margin: EdgeInsets.symmetric(vertical: 16.wMin),
          ),
          body,
        ],
      ),
    );
  }

  Widget _buildParadigmSentenceGroupSection(
    _ParadigmSentenceGroup group, {
    required bool isUngroupedGroup,
  }) {
    return Container(
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          width: 1.wMin,
          color: AppTheme.cBorderThin.color,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (group.showTitle) ...[
            Text(
              group.title,
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w700,
                color: group.isWarningTitle ? AppTheme.cSurfaceWarning.color : _textPrimary,
                fontFamily: AppFontValue.sourceHanSerifCN,
              ),
            ),
            SizedBox(height: 12.wMin),
          ],
          ListView.separated(
            itemCount: group.sentences.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) => SizedBox(height: 16.wMin),
            itemBuilder: (context, index) {
              return _buildParadigmSentenceItem(
                sentence: group.sentences[index],
                groupKey: group.groupKey,
                isUngroupedGroup: isUngroupedGroup,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildParadigmSentenceItem({
    required PatternBlueprintSentenceBriefEntity sentence,
    required String groupKey,
    required bool isUngroupedGroup,
  }) {
    final String content = sentence.actualContent?.trim() ?? '';
    if (content.isEmpty) return const SizedBox.shrink();
    final int? sentenceId = sentence.actualSentenceId;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isUngroupedGroup)
              Padding(
                padding: EdgeInsets.only(top: 2.wMin, right: 10.wMin),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: sentenceId == null
                      ? null
                      : () {
                          controller.toggleUngroupedParadigmSentence(
                            groupKey: groupKey,
                            sentenceId: sentenceId,
                          );
                        },
                  child: CardSelectDotWidget(
                    isSelected: controller.isUngroupedParadigmSentenceSelected(
                      groupKey: groupKey,
                      sentenceId: sentenceId,
                    ),
                  ),
                ),
              ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 2.wMin),
                child: Text(
                  content,
                  style: TextStyle(
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextPrimary.color,
                    height: 1.3,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.wMin),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SetExpansionButtonsWidget(
                  isManagement: controller.isManagement,
                  sentenceId: sentenceId,
                  content: content,
                  isNormal: sentence.isNormal,
                  onShelf: () {
                    controller.onShelfPatternSentence(sentence);
                  },
                  onRefresh: () {
                    controller.fetchSentenceSetPages(reset: true);
                  },
                ),
                if (controller.isManagement && isUngroupedGroup) ...[
                  SizedBox(width: 10.wMin),
                  _buildSentenceDeleteButton(
                    onTap: () {
                      controller.onTapSentenceDelete(sentenceId);
                    },
                  ),
                ],
              ],
            ),
          ],
        ),
        if (sentence.actualDefinition?.isNotEmpty == true) ...[
          SizedBox(height: 6.wMin),
          Text.rich(
            TextSpan(
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cZhenxieFontSecondary.color,
                fontFamily: AppFontValue.sourceHanSerifCN,
              ),
              children: [
                TextSpan(text: sentence.actualDefinition ?? ''),
                if (controller.isManagement)
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Container(
                      margin: EdgeInsets.only(left: 4.wMin),
                      child: CopyTagWidget(
                        name: '句子',
                        value: sentenceId?.toString() ?? '',
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  List<_ParadigmSentenceGroup> _buildParadigmSentenceGroups(
    List<PatternBlueprintSentenceBriefEntity?>? contents, {
    required bool isUngroupedGroup,
  }) {
    final List<_ParadigmSentenceGroup> groups = <_ParadigmSentenceGroup>[];
    final Map<String, int> groupIndexMap = <String, int>{};
    final List<PatternBlueprintSentenceBriefEntity?> sentenceList = contents ?? const <PatternBlueprintSentenceBriefEntity?>[];
    for (int index = 0; index < sentenceList.length; index++) {
      final PatternBlueprintSentenceBriefEntity? sentence = sentenceList[index];
      final int? sentenceId = sentence?.actualSentenceId;
      if (sentence == null || sentenceId == null || sentenceId <= 0) continue;
      final String patternNid = sentence.actualPatternNid?.trim() ?? '';
      final String patternName = _readZhLanguageText(sentence.actualPatternName);
      final bool isUngroupedStructure = patternNid.isEmpty;
      final bool showTitle = isUngroupedGroup ? (isUngroupedStructure || patternName.isNotEmpty) : patternName.isNotEmpty;
      final String groupKey = isUngroupedStructure
          ? (isUngroupedGroup ? 'unanalysed_structure' : 'sentence:$sentenceId')
          : 'pattern:$patternNid';
      final int? targetIndex = groupIndexMap[groupKey];
      if (targetIndex == null) {
        groupIndexMap[groupKey] = groups.length;
        groups.add(
          _ParadigmSentenceGroup(
            groupKey: groupKey,
            title: isUngroupedStructure && isUngroupedGroup ? '未分析结构' : patternName,
            showTitle: showTitle,
            isWarningTitle: isUngroupedStructure && isUngroupedGroup,
            sentences: <PatternBlueprintSentenceBriefEntity>[sentence],
          ),
        );
        continue;
      }
      groups[targetIndex].sentences.add(sentence);
    }
    return groups;
  }

  List<_PatternUngroupedStructureGroup> _buildPatternUngroupedStructureGroups() {
    final Map<String, _PatternUngroupedStructureGroup> groupMap = <String, _PatternUngroupedStructureGroup>{};
    for (final ManageUnitGrammarTargetSentenceSetPageEntity page in controller.ungroupedSentenceSetPages) {
      for (final PatternBlueprintSentenceBriefEntity? sentence in page.contents ?? const <PatternBlueprintSentenceBriefEntity?>[]) {
        final int? sentenceId = sentence?.actualSentenceId;
        if (sentence == null || sentenceId == null || sentenceId <= 0) continue;
        final List<String> slotKeys = _buildPatternStructureSlotKeys(sentence.segmentList);
        final String groupKey = slotKeys.join('|');
        final _PatternUngroupedStructureGroup? existingGroup = groupMap[groupKey];
        if (existingGroup != null) {
          existingGroup.sentences.add(sentence);
          continue;
        }
        groupMap[groupKey] = _PatternUngroupedStructureGroup(
          groupKey: groupKey,
          slotKeys: slotKeys,
          sourcePage: page,
          sentences: <PatternBlueprintSentenceBriefEntity>[sentence],
        );
      }
    }
    final List<_PatternUngroupedStructureGroup> groups = groupMap.values.toList();
    for (final _PatternUngroupedStructureGroup group in groups) {
      group.sentences.sort((a, b) {
        final String contentA = (a.actualContent ?? '').trim().toLowerCase();
        final String contentB = (b.actualContent ?? '').trim().toLowerCase();
        return contentA.compareTo(contentB);
      });
    }
    groups.sort((a, b) {
      final int lengthCompare = a.slotKeys.length.compareTo(b.slotKeys.length);
      if (lengthCompare != 0) return lengthCompare;
      return a.groupKey.compareTo(b.groupKey);
    });
    return groups;
  }

  List<String> _buildPatternStructureSlotKeys(
    List<PatternBlueprintSentenceBriefSegmentEntity?>? segmentList,
  ) {
    final List<String> resp = <String>[];
    for (final PatternBlueprintSentenceBriefSegmentEntity? segment
        in segmentList ?? const <PatternBlueprintSentenceBriefSegmentEntity?>[]) {
      if (segment == null) continue;
      final String slotKey = segment.slotKey?.trim() ?? '';
      if (slotKey.isNotEmpty) {
        resp.add(slotKey);
      }
    }
    return resp;
  }

  String _readZhLanguageText(List<LanguageText?>? values) {
    for (final LanguageText? item in values ?? const <LanguageText?>[]) {
      final String lang = item?.lang?.trim() ?? '';
      final String text = item?.text?.trim() ?? '';
      if (lang == 'zh' && text.isNotEmpty) {
        return text;
      }
    }
    for (final LanguageText? item in values ?? const <LanguageText?>[]) {
      final String text = item?.text?.trim() ?? '';
      if (text.isNotEmpty) {
        return text;
      }
    }
    return '';
  }

  Widget _buildPatternSentenceSetSentenceItem({
    required BuildContext context,
    required ManageUnitGrammarTargetSentenceSetPageEntity group,
    required PatternBlueprintSentenceBriefEntity? sentence,
    required bool isNormal,
    required bool isUngroupedGroup,
    String? patternGroupKey,
  }) {
    if (sentence == null) return const SizedBox.shrink();
    final bool isPyramidDisabled = isUngroupedGroup && controller.isUngroupedPyramidSentenceDisabled(group, sentence);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12.wMin),
        Row(
          children: [
            if (isUngroupedGroup)
              Padding(
                padding: EdgeInsets.only(right: 8.wMin),
                child: controller.isPyramidTarget()
                    ? TapScaleWidget(
                        sclae: 1.02,
                        onTap: sentence.sentenceId == null || isPyramidDisabled
                            ? null
                            : () {
                                controller.toggleUngroupedSentence(
                                  sentence.sentenceId,
                                  groupKey: patternGroupKey,
                                );
                              },
                        child: Opacity(
                          opacity: isPyramidDisabled ? 0.35 : 1,
                          child: CardSelectDotWidget(
                            isSelected: controller.isUngroupedSentenceSelected(sentence.sentenceId),
                          ),
                        ),
                      )
                    : Checkbox(
                        value: controller.isUngroupedSentenceSelected(sentence.sentenceId),
                        side: BorderSide(
                          color: AppTheme.cBorderTranslucentSubtle.color,
                          width: 1.5.wMin,
                        ),
                        activeColor: AppTheme.cBgBrand.color,
                        checkColor: Colors.white,
                        overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
                        onChanged: (_) {
                          controller.toggleUngroupedSentence(
                            sentence.sentenceId,
                            groupKey: patternGroupKey,
                          );
                        },
                      ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SentenceSlotExampleWidget(
                    isManagement: controller.isManagement,
                    content: sentence.content,
                    segmentList: sentence.segmentList,
                    lableFontSzie: 14.wMin,
                    valueFontSize: 20.wMin,
                    padding: EdgeInsets.symmetric(horizontal: 2.wMin, vertical: 2.wMin),
                    onSlotTap: (segment) {
                      controller.onTapPatternSentenceExample(
                        context,
                        segment,
                        sentence,
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.wMin),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SetExpansionButtonsWidget(
                  isManagement: controller.isManagement,
                  sentenceId: sentence.sentenceId,
                  content: sentence.content,
                  isNormal: sentence.isNormal,
                  onShelf: () {
                    controller.onShelfPatternSentence(sentence);
                  },
                  onRefresh: () {
                    controller.fetchSentenceSetPages(reset: true);
                  },
                ),
                if (controller.isManagement && isUngroupedGroup) ...[
                  SizedBox(width: 10.wMin),
                  _buildSentenceDeleteButton(
                    onTap: () {
                      controller.onTapSentenceDelete(sentence.sentenceId);
                    },
                  ),
                ],
              ],
            ),
          ],
        ),
        SizedBox(height: 6.wMin),
        Text.rich(
          TextSpan(
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cZhenxieFontSecondary.color,
              fontFamily: AppFontValue.sourceHanSerifCN,
            ),
            children: [
              TextSpan(text: sentence.definition ?? ''),
              if (controller.isManagement) ...[
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Container(
                    margin: EdgeInsets.only(left: 4.wMin),
                    child: CopyTagWidget(
                      name: '句子',
                      value: sentence.sentenceId?.toString() ?? '',
                    ),
                  ),
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Container(
                    margin: EdgeInsets.only(left: 4.wMin),
                    child: _buildTagWidget(
                      tagText: sentence.isNormal ? '已上架' : '未上架',
                      textColor: sentence.isNormal ? AppTheme.cSurfaceSuccess.color : AppTheme.cSurfaceWarning.color,
                      bgColor: sentence.isNormal
                          ? AppTheme.cSurfaceSuccess.withValues(alpha: 0.12)
                          : AppTheme.cSurfaceWarning.withValues(alpha: 0.12),
                      borderColor: sentence.isNormal
                          ? AppTheme.cSurfaceSuccess.withValues(alpha: 0.2)
                          : AppTheme.cSurfaceWarning.withValues(alpha: 0.2),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  List<_ManageUnitGrammarReviewActionItem> _buildReviewActionItems(
    String? currentStatus,
  ) {
    if (currentStatus == 'approved') {
      return const [
        _ManageUnitGrammarReviewActionItem(text: '未通过', status: 'disabled'),
        _ManageUnitGrammarReviewActionItem(text: '改回备选', status: 'candidate'),
      ];
    }
    if (currentStatus == 'disabled') {
      return const [
        _ManageUnitGrammarReviewActionItem(text: '通过', status: 'approved'),
        _ManageUnitGrammarReviewActionItem(text: '改回备选', status: 'candidate'),
      ];
    }
    return const [
      _ManageUnitGrammarReviewActionItem(text: '通过', status: 'approved'),
      _ManageUnitGrammarReviewActionItem(text: '未通过', status: 'disabled'),
    ];
  }

  Widget _buildUngroupedSentenceCard({
    required ManageUnitGrammarTargetSentenceSetPageEntity page,
    required PatternBlueprintSentenceBriefEntity sentence,
    required int index,
  }) {
    if (page.assetType == 'pattern') {
      return _buildPatternUngroupedSentenceCard(
        page: page,
        sentence: sentence,
        index: index,
      );
    }
    return _buildPatternUngroupedSentenceCard(
      page: page,
      sentence: sentence,
      index: index,
    );
  }

  Widget _buildPatternUngroupedSentenceCard({
    required ManageUnitGrammarTargetSentenceSetPageEntity page,
    required PatternBlueprintSentenceBriefEntity sentence,
    required int index,
  }) {
    final bool hasSegments = sentence.segmentList?.isNotEmpty == true;
    final bool hasDefinition = sentence.definition?.isNotEmpty == true;
    final bool isInternal = page.access == 'INTERNAL';
    return Container(
      padding: EdgeInsets.all(8.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          width: 0.8.wMin,
          color: AppTheme.cBorderThin.color,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildTagWidget(tagText: '未归组句 ${index + 1}'),
              if (isInternal) ...[
                SizedBox(width: 4.wMin),
                _buildTagWidget(
                  tagText: '新创建',
                  textColor: const Color(0xffF59E0B),
                  bgColor: const Color(0xffF59E0B).withValues(alpha: 0.12),
                  borderColor: const Color(0xffF59E0B).withValues(alpha: 0.2),
                ),
              ],
              SizedBox(width: 4.wMin),
              CopyTagWidget(
                name: '句子',
                value: '${sentence.sentenceId ?? ''}',
                isShow: controller.isManagement,
              ),
            ],
          ),
          if (hasSegments || sentence.content?.isNotEmpty == true) ...[
            SizedBox(height: 12.wMin),
            if (hasSegments)
              SentenceSlotExampleWidget(
                isManagement: controller.isManagement,
                content: sentence.content,
                segmentList: sentence.segmentList,
              )
            else
              Text(
                sentence.content ?? '',
                style: TextStyle(
                  fontSize: 26.wMin,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
          ],
          if (hasDefinition) ...[
            SizedBox(height: 12.wMin),
            Text(
              sentence.definition ?? '',
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: _textSecondary,
                fontFamily: AppFontValue.sourceHanSerifCN,
              ),
            ),
          ],
          SizedBox(height: 12.wMin),
          Align(
            alignment: Alignment.centerRight,
            child: _buildWorkbenchActionButton(
              text: '拓展学习',
              onTap: () {
                controller.onTapExpandStudy(sentence);
              },
            ),
          ),
        ],
      ),
    );
  }

  String _buildSentenceSetTitle(
    ManageUnitGrammarTargetSentenceSetPageEntity item,
    int index,
  ) {
    final String? assetName = LearningLangUtils.getLocalLang(item.asset?.name)?.text;
    if (assetName?.isNotEmpty ?? false) return assetName!;
    return '第 ${(item.order ?? index) + 1} 组';
  }

  String _buildSentenceSetSubtitle(
    ManageUnitGrammarTargetSentenceSetPageEntity item,
  ) {
    final String? description = LearningLangUtils.getLocalLang(item.asset?.description)?.text;
    if (description?.isNotEmpty ?? false) return description!;
    final List<String> contents =
        (item.contents ?? const []).map((e) => e?.actualContent ?? '').where((e) => e.trim().isNotEmpty).take(2).toList();
    if (contents.isNotEmpty) return contents.join(' / ');
    final int count = item.members?.length ?? item.contents?.length ?? 0;
    if (count > 0) return '共 $count 句';
    return '';
  }

  /// 头部信息区统一入口，内部按资产类型复用对应的信息表达。
  Widget _buildInfoWidget() {
    final String? type = controller.detailData.value?.grammarUnifiedInfo?.type;
    if (type == ZhenxieEnSentenceType.EN_SENTENCE_PARADIGM.rawValue && controller.paradigmCompareData.value != null) {
      return _buildParadigmInfoWidget();
    }
    if (type == ZhenxieEnSentenceType.EN_SENTENCE_GRAMMAR_GRID.rawValue && controller.grammarPanoramaData.value != null) {
      return _buildGrammarPanoramaInfoWidget();
    }
    if (type == ZhenxieEnSentenceType.EN_SENTENCE_PATTERN_PAIR_FORK.rawValue && controller.pairForkData.value != null) {
      return _buildPairForkInfoWidget();
    }
    if (type == ZhenxieEnSentenceType.EN_SENTENCE_PATTERN_PAIR.rawValue && controller.grammarStructPayload.isNotEmpty) {
      return _buildPairInfoWidget();
    }

    final detail = controller.detailData.value;
    final data = controller.patternBlueprint.value;
    final localName = LearningLangUtils.getLocalLang(data?.name);
    final localDescription = LearningLangUtils.getLocalLang(data?.description);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontSize: 32.wMin,
                    fontWeight: FontWeight.w500,
                    color: _textPrimary,
                  ),
                  children: [
                    TextSpan(
                      text: localName?.text ?? _readDetailTitle(detail),
                    ),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Container(
                        margin: EdgeInsets.only(left: 4.wMin),
                        child: CopyTagWidget(
                          name: '句型',
                          value: data?.nid ?? detail?.grammarUnifiedInfo?.nid ?? '',
                          isShow: controller.isManagement,
                        ),
                      ),
                    ),
                    if (detail?.uid != null)
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Container(
                          margin: EdgeInsets.only(left: 4.wMin),
                          child: CopyTagWidget(
                            name: 'targetUid',
                            value: '${detail?.uid}',
                            isShow: controller.isManagement,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            _buildPatternInfoRightTagsWidget(),
          ],
        ),
        if (localDescription?.text?.isNotEmpty ?? false) ...[
          SizedBox(height: 10.wMin),
          Text(
            localDescription?.text ?? '',
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: _textTertiary,
            ),
          ),
        ],
        SizedBox(height: 10.wMin),
        _buildPatternInfoBottomTagsWidget(),
      ],
    );
  }

  Widget _buildPatternInfoRightTagsWidget() {
    final detail = controller.detailData.value;
    final data = controller.patternBlueprint.value;
    final statusColor = _statusColorMap[detail?.status] ?? AppTheme.cTextSecondary.color;
    final List<Widget> tags = [];
    final String? type = detail?.grammarUnifiedInfo?.type;

    tags.add(
      _buildTagWidget(
        tagText: type == ZhenxieEnSentenceType.EN_SENTENCE_PYRAMID.rawValue ? '句型金字塔' : '句型蓝图',
        textColor: (_typeColorMap[type] ?? AppTheme.cDifficultyBackgroundColor22.color),
        bgColor: (_typeColorMap[type] ?? AppTheme.cDifficultyBackgroundColor22.color).withValues(alpha: 0.12),
        borderColor: (_typeColorMap[type] ?? AppTheme.cDifficultyBackgroundColor22.color).withValues(alpha: 0.2),
      ),
    );

    if (data?.supportsPyramid == true) {
      tags.add(
        _buildTagWidget(
          tagText: '可生长',
          textColor: const Color(0xff22C55E),
          bgColor: const Color(0xff22C55E).withValues(alpha: 0.12),
          borderColor: const Color(0xff22C55E).withValues(alpha: 0.2),
        ),
      );
    }
    if (data?.patternTier?.isNotEmpty ?? false) {
      tags.add(_buildTagWidget(tagText: data?.patternTier ?? ''));
    }
    if (data?.difficulty?.min != null && data?.difficulty?.max != null) {
      tags.add(
        _buildTagWidget(
          tagText: 'L${data?.difficulty?.min}-L${data?.difficulty?.max}',
        ),
      );
    }
    tags.add(
      _buildTagWidget(
        tagText: _statusLabelMap[detail?.status] ?? detail?.status ?? '-',
        textColor: statusColor,
        bgColor: statusColor.withValues(alpha: 0.12),
        borderColor: statusColor.withValues(alpha: 0.2),
      ),
    );

    return Row(spacing: 6.wMin, children: tags);
  }

  Widget _buildPatternInfoBottomTagsWidget() {
    final detail = controller.detailData.value;
    final data = controller.patternBlueprint.value;
    final familyName = LearningLangUtils.getLocalLang(data?.family?.name);
    final functionalTypeName = LearningLangUtils.getLocalLang(data?.functionalType?.name);
    final basicTypeName = LearningLangUtils.getLocalLang(data?.basicType?.name);
    final svocaTypeName = LearningLangUtils.getLocalLang(data?.primarySvoca?.name);

    final List<Widget> tags = [];
    if (familyName?.text?.isNotEmpty ?? false) {
      tags.add(_buildTagWidget(tagText: familyName?.text ?? ''));
    }
    if (functionalTypeName?.text?.isNotEmpty ?? false) {
      tags.add(_buildTagWidget(tagText: functionalTypeName?.text ?? ''));
    }
    if (basicTypeName?.text?.isNotEmpty ?? false) {
      tags.add(_buildTagWidget(tagText: basicTypeName?.text ?? ''));
    }
    if (svocaTypeName?.text?.isNotEmpty ?? false) {
      tags.add(_buildTagWidget(tagText: svocaTypeName?.text ?? ''));
    }
    if (data?.blueprintScope?.isNotEmpty ?? false) {
      tags.add(
        _buildTagWidget(
          tagText: data?.blueprintScope == 'sentence' ? '跨子句组合' : '子句内装配',
        ),
      );
    }
    if (detail?.pointOrder != null) {
      tags.add(
        _buildTagWidget(
          tagText: '要点${detail?.pointOrder}',
        ),
      );
    }

    return Wrap(
      spacing: 6.wMin,
      runSpacing: 4.wMin,
      children: tags,
    );
  }

  Widget _buildParadigmInfoWidget() {
    final detail = controller.detailData.value;
    final data = controller.paradigmCompareData.value;
    final dimensionName = LearningLangUtils.getLocalLang(data?.dimension?.name);
    final name = LearningLangUtils.getLocalLang(data?.name);
    final description = LearningLangUtils.getLocalLang(data?.description);
    final transformationKindName = LearningLangUtils.getLocalLang(data?.transformationKind?.name);
    final int memberCount = data?.memberList?.length ?? 0;
    final int sentenceRealizationSetCount = data?.sentenceRealizationSetList?.length ?? 0;
    final Color statusColor = _statusColorMap[detail?.status] ?? AppTheme.cTextSecondary.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              dimensionName?.text ?? '',
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
                color: _textSecondary,
              ),
            ),
            SizedBox(width: 16.wMin),
            CopyTagWidget(
              name: '维度',
              value: data?.dimensionNid ?? '',
              isShow: controller.isManagement,
            ),
            const Spacer(),
            if (transformationKindName?.text?.isNotEmpty ?? false) ...[
              _buildTagWidget(tagText: transformationKindName?.text ?? ''),
              SizedBox(width: 6.wMin),
            ],
            _buildTagWidget(tagText: '$memberCount壳'),
            SizedBox(width: 6.wMin),
            _buildTagWidget(
              tagText: sentenceRealizationSetCount > 0 ? '$sentenceRealizationSetCount组对照' : '待挑句',
              textColor: sentenceRealizationSetCount > 0 ? const Color(0xff22C55E) : AppTheme.cTextQuaternary.color,
              bgColor: sentenceRealizationSetCount > 0 ? const Color(0xff22C55E).withValues(alpha: 0.12) : AppTheme.cSurfaceLayerBase.color,
              borderColor: sentenceRealizationSetCount > 0 ? const Color(0xff22C55E).withValues(alpha: 0.2) : AppTheme.cBorderThin.color,
            ),
            SizedBox(width: 6.wMin),
            _buildTagWidget(
              tagText: _statusLabelMap[detail?.status] ?? detail?.status ?? '-',
              textColor: statusColor,
              bgColor: statusColor.withValues(alpha: 0.12),
              borderColor: statusColor.withValues(alpha: 0.2),
            ),
            if (detail?.pointOrder != null) ...[
              SizedBox(width: 6.wMin),
              _buildTagWidget(tagText: '要点${detail?.pointOrder}'),
            ],
          ],
        ),
        SizedBox(height: 10.wMin),
        Row(
          spacing: 4.wMin,
          children: [
            Flexible(
              child: Text(
                name?.text ?? _readDetailTitle(detail),
                style: TextStyle(
                  fontSize: 28.wMin,
                  fontWeight: FontWeight.w500,
                  color: _textPrimary,
                ),
              ),
            ),
            CopyTagWidget(
              name: '对照',
              value: data?.nid ?? detail?.grammarUnifiedInfo?.nid ?? '',
              isShow: controller.isManagement,
            ),
            if (detail?.uid != null)
              CopyTagWidget(
                name: 'targetUid',
                value: '${detail?.uid}',
                isShow: controller.isManagement,
              ),
          ],
        ),
        if (description?.text?.isNotEmpty ?? false) ...[
          SizedBox(height: 10.wMin),
          Text(
            description?.text ?? '',
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: _textTertiary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildParadigmCompareWidget() {
    final data = controller.paradigmCompareData.value;
    final List<SentencePatternCompareParadigmSlotEntity?> paradigmSlots = data?.paradigmSlots ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: 24.wMin),
          padding: EdgeInsets.all(16.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.wMin),
            color: AppTheme.cSurfaceLayerBase.color,
            border: Border.all(
              color: AppTheme.cBorderThin.color,
              width: 0.8.wMin,
            ),
          ),
          child: SameGroupCompareSentenceTableWidget(
            memberList: data?.memberList,
            sentenceRealizationSetList: data?.sentenceRealizationSetList,
            isManagement: controller.isManagement,
          ),
        ),
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: 24.wMin),
          padding: EdgeInsets.all(16.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.wMin),
            color: AppTheme.cSurfaceLayerBase.color,
            border: Border.all(
              color: AppTheme.cBorderThin.color,
              width: 0.8.wMin,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '共享槽',
                style: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w500,
                  color: _textPrimary,
                ),
              ),
              SizedBox(height: 12.wMin),
              Text(
                '切换壳时应搬运的语义位',
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                  color: _textTertiary,
                ),
              ),
              if (paradigmSlots.isNotEmpty) ...[
                SizedBox(height: 12.wMin),
                Wrap(
                  spacing: 4.wMin,
                  runSpacing: 4.wMin,
                  children: paradigmSlots.map((slot) {
                    return _buildTagWidget(tagText: slot?.slotKey ?? '');
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGrammarPanoramaInfoWidget() {
    final detail = controller.detailData.value;
    final data = controller.grammarPanoramaData.value;
    final name = LearningLangUtils.getLocalLang(data?.name);
    final description = LearningLangUtils.getLocalLang(data?.description);
    final int subCount = data?.minimalSubGridCount ?? 0;
    final Color statusColor = _statusColorMap[detail?.status] ?? AppTheme.cTextSecondary.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              data?.gridKindEnum?.name ?? '语法全景',
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
                color: _textSecondary,
              ),
            ),
            SizedBox(width: 16.wMin),
            CopyTagWidget(
              name: '宫格',
              value: data?.nid ?? detail?.grammarUnifiedInfo?.nid ?? '',
              isShow: controller.isManagement,
            ),
            const Spacer(),
            _buildTagWidget(
              tagText: _statusLabelMap[detail?.status] ?? detail?.status ?? '-',
              textColor: statusColor,
              bgColor: statusColor.withValues(alpha: 0.12),
              borderColor: statusColor.withValues(alpha: 0.2),
            ),
            if (detail?.pointOrder != null) ...[
              SizedBox(width: 6.wMin),
              _buildTagWidget(tagText: '要点${detail?.pointOrder}'),
            ],
          ],
        ),
        SizedBox(height: 10.wMin),
        Wrap(
          spacing: 4.wMin,
          runSpacing: 4.wMin,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              name?.text ?? _readDetailTitle(detail),
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w500,
                color: _textPrimary,
              ),
            ),
            if (detail?.uid != null)
              CopyTagWidget(
                name: 'targetUid',
                value: '${detail?.uid}',
                isShow: controller.isManagement,
              ),
          ],
        ),
        if (description?.text?.isNotEmpty ?? false) ...[
          SizedBox(height: 10.wMin),
          Text(
            description?.text ?? '',
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: _textTertiary,
            ),
          ),
        ],
        SizedBox(height: 10.wMin),
        Wrap(
          spacing: 4.wMin,
          runSpacing: 4.wMin,
          children: [
            _buildTagWidget(tagText: '${data?.cellCount ?? 0}格'),
            _buildTagWidget(tagText: subCount > 0 ? '$subCount裁剪' : '无裁剪'),
            _buildTagWidget(
              tagText: 'CEFR ${data?.difficulty?.min ?? ''}-${data?.difficulty?.max ?? ''}',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGrammarPanoramaAssetWidget() {
    final data = controller.grammarPanoramaData.value;
    final bool canOpen = data?.nid?.isNotEmpty ?? false;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 24.wMin),
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          color: AppTheme.cBorderThin.color,
          width: 0.8.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '迷你宫格',
                  style: TextStyle(
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w500,
                    color: _textPrimary,
                  ),
                ),
              ),
              if (canOpen)
                ButtonWidget(
                  text: '打开详情',
                  height: 34.wMin,
                  padding: EdgeInsets.symmetric(horizontal: 12.wMin),
                  color: AppTheme.cSurfaceLayerElevated.color,
                  fontSize: 18.wMin,
                  fontColor: AppTheme.cTextSecondary.color,
                  fontWeight: FontWeight.w500,
                  sclae: 1.02,
                  onTap: () => controller.onOpenGrammarPanoramaDetails(data?.nid),
                ),
            ],
          ),
          SizedBox(height: 12.wMin),
          GrammarPanoramaMinTableWidget(
            axes: data?.axes,
            cells: data?.cells,
          ),
        ],
      ),
    );
  }

  Widget _buildQaPairInfoWidget() {
    final detail = controller.detailData.value;
    final pair = controller.pairData.value;
    final String pairTypeName = LearningLangUtils.getLocalLang(pair?.pairType?.name)?.text ?? '问答配对';
    final String pairName = LearningLangUtils.getLocalLang(pair?.name)?.text ?? _readDetailTitle(detail);
    final String pairDescription = LearningLangUtils.getLocalLang(pair?.description)?.text ?? _readDetailDescription(detail);
    final PracticeModeEnum? practiceModeEnum = PracticeModeEnum.fromValue(
      pair?.practiceMode,
    );
    final PairRacticeKindEnum? preferredPracticeEnum = PairRacticeKindEnum.fromValue(pair?.preferredPractice);
    final Color statusColor = _statusColorMap[detail?.status] ?? AppTheme.cTextSecondary.color;
    final int pairCount = pair?.realizationSetList?.length ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                pairTypeName,
                style: TextStyle(
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w400,
                  color: _textSecondary,
                ),
              ),
            ),
            Row(
              spacing: 6.wMin,
              children: [
                _buildTagWidget(
                  tagText: _statusLabelMap[detail?.status] ?? detail?.status ?? '-',
                  textColor: statusColor,
                  bgColor: statusColor.withValues(alpha: 0.12),
                  borderColor: statusColor.withValues(alpha: 0.2),
                ),
                if (detail?.pointOrder != null) _buildTagWidget(tagText: '要点${detail?.pointOrder}'),
              ],
            ),
          ],
        ),
        SizedBox(height: 10.wMin),
        Wrap(
          spacing: 4.wMin,
          runSpacing: 4.wMin,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              pairName,
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w500,
                color: _textPrimary,
              ),
            ),
            CopyTagWidget(
              name: '配对',
              value: pair?.nid ?? detail?.grammarUnifiedInfo?.nid ?? '',
              isShow: controller.isManagement,
            ),
            if (detail?.uid != null)
              CopyTagWidget(
                name: 'targetUid',
                value: '${detail?.uid}',
                isShow: controller.isManagement,
              ),
          ],
        ),
        if (pairDescription.isNotEmpty) ...[
          SizedBox(height: 10.wMin),
          Text(
            pairDescription,
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: _textTertiary,
            ),
          ),
        ],
        SizedBox(height: 10.wMin),
        Wrap(
          spacing: 4.wMin,
          runSpacing: 4.wMin,
          children: [
            if (practiceModeEnum != null)
              _buildTagWidget(
                tagText: practiceModeEnum.description,
                textColor: practiceModeEnum.color,
                bgColor: practiceModeEnum.color.withValues(alpha: 0.12),
                borderColor: practiceModeEnum.color.withValues(alpha: 0.2),
              ),
            if (preferredPracticeEnum != null)
              _buildTagWidget(
                tagText: preferredPracticeEnum.description,
                textColor: preferredPracticeEnum.color,
                bgColor: preferredPracticeEnum.color.withValues(alpha: 0.12),
                borderColor: preferredPracticeEnum.color.withValues(alpha: 0.2),
              ),
            if (pairCount > 0)
              _buildTagWidget(
                tagText: '$pairCount组句对',
                textColor: const Color(0xff22C55E),
                bgColor: const Color(0xff22C55E).withValues(alpha: 0.12),
                borderColor: const Color(0xff22C55E).withValues(alpha: 0.2),
              )
            else
              _buildTagWidget(tagText: '待挑句'),
          ],
        ),
      ],
    );
  }

  Widget _buildQaPairAssetWidget() {
    final pair = controller.pairData.value;
    if (pair == null) {
      return _buildPairCompareWidget();
    }

    final List<SentencePairForkEntity> pairForks = (pair.pairForks ?? const []).whereType<SentencePairForkEntity>().toList();
    final List<SentencePairSemanticAnchorMappingEntity> semanticAnchorMappings =
        (pair.semanticAnchorMappings ?? const []).whereType<SentencePairSemanticAnchorMappingEntity>().toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: 24.wMin),
          padding: EdgeInsets.all(16.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.wMin),
            color: AppTheme.cSurfaceLayerBase.color,
            border: Border.all(
              width: 1.wMin,
              color: AppTheme.cBorderThin.color,
            ),
          ),
          child: ZhenxieSentencePairDetailsTableWidget(
            realizationSetList: pair.realizationSetList,
            fromRealization: pair.fromRealization,
            toRealization: pair.toRealization,
            isManagement: controller.isManagement,
          ),
        ),
        if (pairForks.isNotEmpty) _buildQaPairForkChainWidget(pairForks),
        if (semanticAnchorMappings.isNotEmpty) _buildQaPairWhyMatchWidget(semanticAnchorMappings),
      ],
    );
  }

  Widget _buildQaPairForkChainWidget(List<SentencePairForkEntity> pairForks) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 24.wMin),
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          color: AppTheme.cBorderThin.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '出现在那些分叉链路',
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              color: _textPrimary,
            ),
          ),
          SizedBox(height: 10.wMin),
          Text(
            '同一条配对可以同时出现在肯否对照和换种答法里。点进去看怎么分叉。',
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: _textTertiary,
            ),
          ),
          SizedBox(height: 10.wMin),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: pairForks.map((fork) {
              return Padding(
                padding: EdgeInsets.only(bottom: 10.wMin),
                child: _buildQaPairForkItemWidget(fork),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQaPairForkItemWidget(SentencePairForkEntity fork) {
    final String forkName = LearningLangUtils.getLocalLang(fork.name)?.text ?? fork.nid ?? '';
    final String forkLabel = fork.soloPairPracticeLabel ?? '';
    final PairRacticeKindEnum? kindEnum = PairRacticeKindEnum.fromValue(fork.kind);
    final bool canOpen = fork.nid?.isNotEmpty == true;

    return TapScaleWidget(
      onTap: canOpen ? () => controller.onOpenPairForkDetails(fork.nid) : null,
      sclae: canOpen ? 1.01 : 1.0,
      borderRadius: 8.wMin,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(8.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          color: AppTheme.cSurfaceLayerBase.color,
          border: Border.all(
            color: AppTheme.cBorderThin.color,
            width: 0.8.wMin,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 4.wMin,
                    runSpacing: 4.wMin,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (kindEnum != null)
                        _buildTagWidget(
                          tagText: kindEnum.description,
                          textColor: kindEnum.color,
                          bgColor: kindEnum.color.withValues(alpha: 0.12),
                          borderColor: kindEnum.color.withValues(alpha: 0.2),
                        ),
                      Text(
                        forkName,
                        style: TextStyle(
                          fontSize: 28.wMin,
                          fontWeight: FontWeight.w500,
                          color: _textPrimary,
                        ),
                      ),
                    ],
                  ),
                  if (forkLabel.isNotEmpty) ...[
                    SizedBox(height: 6.wMin),
                    Text(
                      forkLabel,
                      style: TextStyle(
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w400,
                        color: _textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (canOpen) ...[
              SizedBox(width: 12.wMin),
              ButtonWidget(
                text: '打开棋盘',
                height: 34.wMin,
                padding: EdgeInsets.symmetric(horizontal: 12.wMin),
                color: AppTheme.cSurfaceLayerElevated.color,
                fontSize: 18.wMin,
                fontColor: AppTheme.cTextSecondary.color,
                fontWeight: FontWeight.w500,
                sclae: 1.02,
                onTap: () => controller.onOpenPairForkDetails(fork.nid),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQaPairWhyMatchWidget(
    List<SentencePairSemanticAnchorMappingEntity> semanticAnchorMappings,
  ) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 24.wMin),
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          color: AppTheme.cBorderThin.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '为何能配',
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              color: _textPrimary,
            ),
          ),
          SizedBox(height: 10.wMin),
          Wrap(
            spacing: 10.wMin,
            runSpacing: 6.wMin,
            children: semanticAnchorMappings.map((mapping) {
              final String fromSlotName =
                  LearningLangUtils.getLocalLang(mapping.fromPatternSlot?.name)?.text ?? mapping.fromPatternSlotKey ?? '';
              final String toSlotName = LearningLangUtils.getLocalLang(mapping.toPatternSlot?.name)?.text ?? mapping.toPatternSlotKey ?? '';
              return _buildTagWidget(tagText: '$fromSlotName → $toSlotName');
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPairForkInfoWidget() {
    final detail = controller.detailData.value;
    final fork = controller.pairForkData.value;
    final String pairTypeName = LearningLangUtils.getLocalLang(fork?.pairType?.name)?.text ?? '';
    final String contrastDimensionName = LearningLangUtils.getLocalLang(fork?.contrastDimension?.name)?.text ?? '';
    final String forkName = LearningLangUtils.getLocalLang(fork?.name)?.text ?? _readDetailTitle(detail);
    final String forkDescription = LearningLangUtils.getLocalLang(fork?.description)?.text ?? _readDetailDescription(detail);
    final PairRacticeKindEnum? kindEnum = PairRacticeKindEnum.fromValue(fork?.kind);
    final SoloPairPracticeEnum? soloPairPracticeEnum = SoloPairPracticeEnum.fromValue(fork?.soloPairPractice);
    final Color statusColor = _statusColorMap[detail?.status] ?? AppTheme.cTextSecondary.color;
    final int memberCount = fork?.members?.length ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Wrap(
                spacing: 4.wMin,
                runSpacing: 4.wMin,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    [pairTypeName, contrastDimensionName].where((item) => item.isNotEmpty).join(' · '),
                    style: TextStyle(
                      fontSize: 16.wMin,
                      fontWeight: FontWeight.w400,
                      color: _textSecondary,
                    ),
                  ),
                  if (fork?.contrastDimensionNid?.isNotEmpty ?? false)
                    CopyTagWidget(
                      name: '维度',
                      value: fork?.contrastDimensionNid ?? '',
                      isShow: controller.isManagement,
                    ),
                ],
              ),
            ),
            Row(
              spacing: 6.wMin,
              children: [
                _buildTagWidget(
                  tagText: _statusLabelMap[detail?.status] ?? detail?.status ?? '-',
                  textColor: statusColor,
                  bgColor: statusColor.withValues(alpha: 0.12),
                  borderColor: statusColor.withValues(alpha: 0.2),
                ),
                if (detail?.pointOrder != null) _buildTagWidget(tagText: '要点${detail?.pointOrder}'),
              ],
            ),
          ],
        ),
        SizedBox(height: 10.wMin),
        Wrap(
          spacing: 4.wMin,
          runSpacing: 4.wMin,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              forkName,
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w500,
                color: _textPrimary,
              ),
            ),
            if (fork?.nid?.isNotEmpty ?? false)
              CopyTagWidget(
                name: '分叉',
                value: fork?.nid ?? '',
                isShow: controller.isManagement,
              ),
            if (detail?.uid != null)
              CopyTagWidget(
                name: 'targetUid',
                value: '${detail?.uid}',
                isShow: controller.isManagement,
              ),
          ],
        ),
        if (forkDescription.isNotEmpty) ...[
          SizedBox(height: 10.wMin),
          Text(
            forkDescription,
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: _textTertiary,
            ),
          ),
        ],
        SizedBox(height: 10.wMin),
        Wrap(
          spacing: 4.wMin,
          runSpacing: 4.wMin,
          children: [
            if (kindEnum != null)
              _buildTagWidget(
                tagText: kindEnum.description,
                textColor: kindEnum.color,
                bgColor: kindEnum.color.withValues(alpha: 0.12),
                borderColor: kindEnum.color.withValues(alpha: 0.2),
              ),
            _buildTagWidget(tagText: '$memberCount种接法'),
            if (soloPairPracticeEnum != null)
              _buildTagWidget(
                tagText: soloPairPracticeEnum.description,
                textColor: soloPairPracticeEnum.color,
                bgColor: soloPairPracticeEnum.color.withValues(alpha: 0.12),
                borderColor: soloPairPracticeEnum.color.withValues(alpha: 0.2),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildPairForkAssetWidget() {
    final fork = controller.pairForkData.value;
    if (fork == null) {
      return const SizedBox.shrink();
    }
    final List<SentenceForkMemberEntity> members = (fork.members ?? const []).whereType<SentenceForkMemberEntity>().toList();
    final String sharedExample =
        members.map((item) => item.teachingExampleFrom ?? '').firstWhere((item) => item.isNotEmpty, orElse: () => '');
    final List<SentenceForkMemberEntity> answerMembers = members.where((item) => (item.teachingExampleTo ?? '').isNotEmpty).toList();

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 24.wMin),
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          color: AppTheme.cBorderThin.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '分叉棋盘',
                style: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w500,
                  color: _textPrimary,
                ),
              ),
              SizedBox(width: 10.wMin),
              Text(
                '同一问句，右边每路一个回答',
                style: TextStyle(
                  fontSize: 14.wMin,
                  fontWeight: FontWeight.w400,
                  color: _textTertiary.withValues(alpha: 0.72),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.wMin),
          if (sharedExample.isEmpty || answerMembers.isEmpty)
            Text(
              '当前分叉资产暂缺示例句数据',
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
                color: _textTertiary,
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 100,
                  child: Padding(
                    padding: EdgeInsets.only(right: 16.wMin),
                    child: Text(
                      sharedExample,
                      style: TextStyle(
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w500,
                        color: _textPrimary,
                        fontFamily: AppFontValue.robotoMono,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 115,
                  child: Container(
                    padding: EdgeInsets.only(left: 16.wMin),
                    decoration: BoxDecoration(
                      border: Border(
                          left: BorderSide(
                        color: AppTheme.cBorderDefault.color,
                        width: 1.wMin,
                      )),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 30.wMin,
                      children: List.generate(answerMembers.length, (index) {
                        final item = answerMembers[index];
                        final String answerText = item.teachingExampleTo ?? '';
                        return Padding(
                          padding: EdgeInsets.only(bottom: index == answerMembers.length - 1 ? 0 : 14.wMin),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                     
                              Text(
                                answerText,
                                style: TextStyle(
                                  fontSize: 18.wMin,
                                  fontWeight: FontWeight.w500,
                                  color: _textPrimary,
                                  fontFamily: AppFontValue.robotoMono,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPairInfoWidget() {
    final detail = controller.detailData.value;
    final payload = controller.grammarStructPayload;
    final String pairName = _findLocalText(payload['name']) ?? _readDetailTitle(detail);
    final String pairDescription = _findLocalText(payload['description']) ?? _readDetailDescription(detail);
    final String pairTypeName = _findLocalText(_readMap(payload['pairType'])?['name']) ?? '一组对照';
    final Color statusColor = _statusColorMap[detail?.status] ?? AppTheme.cTextSecondary.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '句子类型对照',
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
                color: _textSecondary,
              ),
            ),
            SizedBox(width: 16.wMin),
            CopyTagWidget(
              name: '对照',
              value: payload['nid']?.toString() ?? detail?.grammarUnifiedInfo?.nid ?? '',
              isShow: controller.isManagement,
            ),
            const Spacer(),
            _buildTagWidget(tagText: pairTypeName),
            SizedBox(width: 6.wMin),
            _buildTagWidget(
              tagText: _statusLabelMap[detail?.status] ?? detail?.status ?? '-',
              textColor: statusColor,
              bgColor: statusColor.withValues(alpha: 0.12),
              borderColor: statusColor.withValues(alpha: 0.2),
            ),
            if (detail?.pointOrder != null) ...[
              SizedBox(width: 6.wMin),
              _buildTagWidget(tagText: '要点${detail?.pointOrder}'),
            ],
          ],
        ),
        SizedBox(height: 10.wMin),
        Row(
          spacing: 4.wMin,
          children: [
            Flexible(
              child: Text(
                pairName,
                style: TextStyle(
                  fontSize: 28.wMin,
                  fontWeight: FontWeight.w500,
                  color: _textPrimary,
                ),
              ),
            ),
            CopyTagWidget(
              name: '资产',
              value: detail?.grammarUnifiedInfo?.nid ?? '',
              isShow: controller.isManagement,
            ),
            if (detail?.uid != null)
              CopyTagWidget(
                name: 'targetUid',
                value: '${detail?.uid}',
                isShow: controller.isManagement,
              ),
          ],
        ),
        if (pairDescription.isNotEmpty) ...[
          SizedBox(height: 10.wMin),
          Text(
            pairDescription,
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: _textTertiary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPairCompareWidget() {
    final payload = controller.grammarStructPayload;
    final String pairTypeDescription = _findLocalText(_readMap(payload['pairType'])?['description']) ?? '';
    final Map<String, dynamic>? fromRealization = _readMap(payload['fromRealization']);
    final Map<String, dynamic>? toRealization = _readMap(payload['toRealization']);
    final String fromTitle = _findLocalText(_readMap(fromRealization?['pattern'])?['name']) ?? '前句';
    final String toTitle = _findLocalText(_readMap(toRealization?['pattern'])?['name']) ?? '后句';
    final String fromTemplate = _readMap(fromRealization?['pattern'])?['template']?.toString() ?? '';
    final String toTemplate = _readMap(toRealization?['pattern'])?['template']?.toString() ?? '';
    final String fromExample = payload['teachingExampleFrom']?.toString() ?? '';
    final String toExample = payload['teachingExampleTo']?.toString() ?? '';
    final List<Map<String, dynamic>> semanticAnchorMappings = _readMapList(
      payload['semanticAnchorMappings'],
    );

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 24.wMin),
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          width: 1.wMin,
          color: AppTheme.cBorderThin.color,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '同组对照',
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              color: _textPrimary,
            ),
          ),
          if (pairTypeDescription.isNotEmpty) ...[
            SizedBox(height: 12.wMin),
            Text(
              pairTypeDescription,
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: _textTertiary,
              ),
            ),
          ],
          SizedBox(height: 16.wMin),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildPairCompareItemWidget(
                  label: 'From',
                  title: fromTitle,
                  template: fromTemplate,
                  example: fromExample,
                  primaryColor: const Color(0xff38BDF8),
                ),
              ),
              SizedBox(width: 12.wMin),
              Expanded(
                child: _buildPairCompareItemWidget(
                  label: 'To',
                  title: toTitle,
                  template: toTemplate,
                  example: toExample,
                  primaryColor: const Color(0xff22C55E),
                ),
              ),
            ],
          ),
          if (semanticAnchorMappings.isNotEmpty) ...[
            SizedBox(height: 16.wMin),
            Text(
              '共享槽',
              style: TextStyle(
                fontSize: 20.wMin,
                fontWeight: FontWeight.w500,
                color: _textPrimary,
              ),
            ),
            SizedBox(height: 12.wMin),
            Wrap(
              spacing: 6.wMin,
              runSpacing: 6.wMin,
              children: semanticAnchorMappings.map((item) {
                final String fromSlotName =
                    _findLocalText(_readMap(item['fromPatternSlot'])?['name']) ?? item['fromPatternSlotKey']?.toString() ?? '';
                final String toSlotName =
                    _findLocalText(_readMap(item['toPatternSlot'])?['name']) ?? item['toPatternSlotKey']?.toString() ?? '';
                return _buildTagWidget(tagText: '$fromSlotName -> $toSlotName');
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPairCompareItemWidget({
    required String label,
    required String title,
    required String template,
    required String example,
    required Color primaryColor,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          width: 0.8.wMin,
          color: AppTheme.cBorderThin.color,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTagWidget(
            tagText: label,
            textColor: primaryColor,
            bgColor: primaryColor.withValues(alpha: 0.12),
            borderColor: primaryColor.withValues(alpha: 0.2),
          ),
          SizedBox(height: 12.wMin),
          Text(
            title,
            style: TextStyle(
              fontSize: 22.wMin,
              fontWeight: FontWeight.w500,
              color: _textPrimary,
            ),
          ),
          if (template.isNotEmpty) ...[
            SizedBox(height: 12.wMin),
            Text(
              template,
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: _textSecondary,
              ),
            ),
          ],
          if (example.isNotEmpty) ...[
            SizedBox(height: 12.wMin),
            Text(
              example,
              style: TextStyle(
                fontSize: 20.wMin,
                fontWeight: FontWeight.w500,
                color: _textPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String? _findLocalText(dynamic value) {
    if (value is! List) return null;
    for (final item in value) {
      if (item is! Map) continue;
      if (item['lang'] == 'zh' && item['text'] != null) {
        return item['text'].toString();
      }
    }
    for (final item in value) {
      if (item is! Map) continue;
      if (item['text'] != null) {
        return item['text'].toString();
      }
    }
    return null;
  }

  Map<String, dynamic>? _readMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  List<Map<String, dynamic>> _readMapList(dynamic value) {
    if (value is! List) return const [];
    return value.whereType<Map>().map((item) {
      return Map<String, dynamic>.from(item);
    }).toList();
  }

  Color _getLexicalAnchorColor(String? bindingMode) {
    if (bindingMode == 'required_slot') {
      return const Color(0xff22C55E);
    }
    if (bindingMode == 'preferred_slot') {
      return const Color(0xffF59E0B);
    }
    if (bindingMode == 'context_only') {
      return const Color(0xff38BDF8);
    }
    return AppTheme.cTextSecondary.color;
  }

  Widget _buildNavigatorButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return TapScaleWidget(
      sclae: enabled ? 1.01 : 1,
      borderRadius: 999.wMin,
      onTap: enabled ? onTap : null,
      child: Container(
        width: 40.wMin,
        height: 40.wMin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999.wMin),
          color: AppTheme.cSurfaceLayerBase.color,
          border: Border.all(
            color: AppTheme.cBorderThin.color,
            width: 0.8.wMin,
          ),
        ),
        child: Icon(
          icon,
          size: 20.wMin,
          color: enabled ? _textPrimary : _textTertiary,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required Color textColor,
    required Color borderColor,
    required Color backgroundColor,
    VoidCallback? onTap,
  }) {
    final bool enabled = onTap != null;
    return TapScaleWidget(
      sclae: enabled ? 1.01 : 1,
      borderRadius: 999.wMin,
      onTap: onTap,
      child: Opacity(
        opacity: enabled ? 1 : 0.35,
        child: Container(
          height: 34.wMin,
          padding: EdgeInsets.symmetric(horizontal: 12.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999.wMin),
            color: backgroundColor,
            border: Border.all(
              color: borderColor,
              width: 0.8.wMin,
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewActionButton({
    required String text,
    required String status,
    required VoidCallback onTap,
  }) {
    final Color color = _statusColorMap[status] ?? AppTheme.cTextSecondary.color;
    return TapScaleWidget(
      sclae: 1.01,
      borderRadius: 999.wMin,
      onTap: onTap,
      child: Container(
        height: 34.wMin,
        // width: 100.wMin,
        padding: EdgeInsets.symmetric(horizontal: 12.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999.wMin),
          color: color.withValues(alpha: 0.14),
          border: Border.all(
            color: color.withValues(alpha: 0.35),
            width: 0.8.wMin,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTagWidget({
    required String tagText,
    Color textColor = AppTheme.cTextSecondary,
    Color bgColor = AppTheme.cSurfaceLayerBase,
    Color borderColor = AppTheme.cBorderThin,
  }) {
    return Container(
      height: 28.wMin,
      padding: EdgeInsets.symmetric(horizontal: 10.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        color: bgColor,
        border: Border.all(
          color: borderColor.withValues(alpha: 0.2),
          width: 0.5.wMin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tagText,
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: textColor,
              fontFamily: AppFontValue.langWiseFont,
            ),
          ),
        ],
      ),
    );
  }

  String _readDetailTitle(ManageUnitGrammarTargetDetailEntity? detail) {
    return LearningLangUtils.getLocalLang(detail?.title)?.text ?? detail?.grammarUnifiedInfo?.nid ?? 'Target详情';
  }

  String _readDetailDescription(ManageUnitGrammarTargetDetailEntity? detail) {
    return LearningLangUtils.getLocalLang(detail?.description)?.text ?? detail?.objective?.outcome ?? '';
  }
}

class _ManageUnitGrammarReviewActionItem {
  final String text;
  final String status;

  const _ManageUnitGrammarReviewActionItem({
    required this.text,
    required this.status,
  });
}

class _UngroupedSentenceItem {
  final ManageUnitGrammarTargetSentenceSetPageEntity page;
  final PatternBlueprintSentenceBriefEntity sentence;

  const _UngroupedSentenceItem({
    required this.page,
    required this.sentence,
  });
}

class _PatternUngroupedStructureGroup {
  final String groupKey;
  final List<String> slotKeys;
  final ManageUnitGrammarTargetSentenceSetPageEntity sourcePage;
  final List<PatternBlueprintSentenceBriefEntity> sentences;

  const _PatternUngroupedStructureGroup({
    required this.groupKey,
    required this.slotKeys,
    required this.sourcePage,
    required this.sentences,
  });
}

class _ParadigmSentenceGroup {
  final String groupKey;
  final String title;
  final bool showTitle;
  final bool isWarningTitle;
  final List<PatternBlueprintSentenceBriefEntity> sentences;

  const _ParadigmSentenceGroup({
    required this.groupKey,
    required this.title,
    required this.showTitle,
    required this.isWarningTitle,
    required this.sentences,
  });
}
