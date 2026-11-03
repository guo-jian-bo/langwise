import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../routes/routes.dart';
import '../../../common/commons.dart';
import '../../../enums/enums.dart';
import '../bindings/manage_unit_grammar_target_details_binding.dart';
import '../controllers/manage_unit_grammar_target_details_controller.dart';
import 'manage_unit_grammar_target_detail_widgets.dart';

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

  static final Color _textPrimary = AppTheme.cTextPrimary.color;
  static final Color _textSecondary = AppTheme.cTextSecondary.color;
  static final Color _textTertiary = AppTheme.cTextTertiary.color;

  static const Map<String, Color> _statusColorMap = {
    'candidate': Color(0xffF59E0B),
    'approved': Color(0xff34D399),
    'disabled': Color(0xff94A3B8),
  };

  static const Map<String, Color> _kindColorMap = {
    'pattern': Color(0xff8B5CF6),
    'pair': Color(0xffFB7185),
    'pair_fork': Color(0xffF97316),
    'paradigm': Color(0xffD946EF),
    'pyramid': Color(0xffA855F7),
    'grid': Color(0xffEC4899),
  };

  static const Map<String, String> _kindLabelMap = {
    'pattern': '句型蓝图',
    'pair': '句型对照',
    'pair_fork': '分叉对照',
    'paradigm': '范式对照',
    'pyramid': '生长金字塔',
    'grid': '语法全景',
  };

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      onRefresh: () => controller.fetchData(showLoading: true),
      body: Obx(() {
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

        return Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 90.wMin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 32.wMin),
                    _buildInfoWidget(),
                    _buildAssetWidget(),
                    _buildRepresentWidget(),
                    SizedBox(height: 360.wMin),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildReviewWidget(),
            ),
          ],
        );
      }),
    );
  }

  /// 头部信息区，承接标题、标签和说明。
  Widget _buildInfoWidget() {
    if (controller.isPairForkTarget() && controller.pairForkData.value != null) {
      return _buildPairForkInfoWidget();
    }

    if (controller.isGridTarget() && controller.grammarPanoramaData.value != null) {
      return _buildGrammarPanoramaInfoWidget();
    }

    if (controller.isQaPairTarget() && controller.pairData.value != null) {
      return _buildQaPairInfoWidget();
    }

    if (controller.isParadigmTarget() && controller.paradigmCompareData.value != null) {
      return _buildParadigmInfoWidget();
    }

    if (controller.isPairTarget() && controller.grammarStructPayload.isNotEmpty) {
      return _buildPairInfoWidget();
    }

    if (controller.isPatternOrPyramidTarget() && controller.patternBlueprint.value != null) {
      return _buildPatternInfoWidget();
    }

    final target = controller.target.value;
    final String? assetKind = target?.assetKind;
    final Color kindColor = _kindColorMap[assetKind] ?? AppTheme.cDifficultyBackgroundColor22.color;
    final Color statusColor = _statusColorMap[target?.status] ?? AppTheme.cTextSecondary.color;

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
                    target?.title ?? target?.assetNid ?? 'Target详情',
                    style: TextStyle(
                      fontSize: 32.wMin,
                      fontWeight: FontWeight.w500,
                      color: _textPrimary,
                    ),
                  ),
                  if ((target?.assetNid?.isNotEmpty ?? false))
                    CopyTagWidget(
                      name: '资产',
                      value: target?.assetNid ?? '',
                    ),
                  if (target?.uid != null)
                    CopyTagWidget(
                      name: 'targetUid',
                      value: '${target?.uid}',
                    ),
                ],
              ),
            ),
            Row(
              spacing: 6.wMin,
              children: [
                _buildTagWidget(
                  tagText: _kindLabelMap[assetKind] ?? target?.assetKind ?? 'Target',
                  textColor: kindColor,
                  bgColor: kindColor.withValues(alpha: 0.12),
                  borderColor: kindColor.withValues(alpha: 0.2),
                ),
                _buildTagWidget(
                  tagText: target?.statusLabel ?? target?.status ?? '-',
                  textColor: statusColor,
                  bgColor: statusColor.withValues(alpha: 0.12),
                  borderColor: statusColor.withValues(alpha: 0.2),
                ),
                if (target?.pointOrder != null)
                  _buildTagWidget(
                    tagText: '要点${target?.pointOrder}',
                  ),
              ],
            ),
          ],
        ),
        if (target?.description?.isNotEmpty ?? false) ...[
          SizedBox(height: 10.wMin),
          Text(
            target?.description ?? '',
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: _textTertiary,
            ),
          ),
        ],
        if (target?.objective?.isNotEmpty ?? false) ...[
          SizedBox(height: 10.wMin),
          Text(
            target?.objective ?? '',
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: _textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  /// 资产主区域：当前先对 pattern 做完整渲染，其余资产先占位。
  Widget _buildAssetWidget() {
    if (controller.isPairForkTarget() && controller.pairForkData.value != null) {
      return _buildPairForkAssetWidget();
    }

    if (controller.isGridTarget() && controller.grammarPanoramaData.value != null) {
      return _buildGrammarPanoramaAssetWidget();
    }

    if (controller.isQaPairTarget() && controller.pairData.value != null) {
      return _buildQaPairAssetWidget();
    }

    if (controller.isParadigmTarget() && controller.paradigmCompareData.value != null) {
      return _buildParadigmCompareWidget();
    }

    if (controller.isPatternOrPyramidTarget()) {
      return ManageUnitGrammarPatternSkeletonWidget(
        data: controller.patternBlueprint.value,
        skeletonChips: const [],
      );
    }

    if (controller.isPairTarget() && controller.grammarStructPayload.isNotEmpty) {
      return _buildPairCompareWidget();
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
        '当前先完成句型蓝图、句子类型对照和句型对照详情渲染，${controller.target.value?.assetKind ?? '该类型'} 详情后续再补。',
        style: TextStyle(
          fontSize: 18.wMin,
          fontWeight: FontWeight.w400,
          color: _textTertiary,
        ),
      ),
    );
  }

  /// 代表句区域：展示配额、动作按钮和已绑句列表。
  Widget _buildRepresentWidget() {
    final quota = controller.quota.value;
    final bool isPatternTarget = controller.isPatternTarget();
    final bool isAdvancedPracticeTarget = controller.isAdvancedPracticeTarget();
    final bool canOperatePatternActions = controller.canOperatePatternActions();
    final bool canOperateAdvancedPractice = controller.canOperateAdvancedPractice();
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '代表句',
                  style: TextStyle(
                    fontSize: 28.wMin,
                    fontWeight: FontWeight.w500,
                    color: _textPrimary,
                  ),
                ),
              ),
              if (quota?.showQuota == true)
                Padding(
                  padding: EdgeInsets.only(top: 2.wMin, right: 20.wMin),
                  child: Text(
                    '${quota?.boundCount ?? 0}/${quota?.needCount ?? 0}',
                    style: TextStyle(
                      fontSize: 28.wMin,
                      fontWeight: FontWeight.w700,
                      color: quota?.isEnough == true ? const Color(0xff34D399) : const Color(0xffF87171),
                    ),
                  ),
                ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 8.wMin,
                  children: [
                    if (isPatternTarget) ...[
                      _buildActionButton(
                        text: '搜索库里已有句子',
                        textColor: const Color(0xff22D3EE),
                        borderColor: const Color(0xff22D3EE).withValues(alpha: 0.35),
                        backgroundColor: const Color(0xff22D3EE).withValues(alpha: 0.15),
                        onTap: canOperatePatternActions ? controller.onTapSearchLibrary : null,
                      ),
                      _buildActionButton(
                        text: '生成句子',
                        textColor: const Color(0xffF59E0B),
                        borderColor: const Color(0xffF59E0B).withValues(alpha: 0.35),
                        backgroundColor: const Color(0xffF59E0B).withValues(alpha: 0.15),
                        onTap: canOperatePatternActions ? controller.onTapGenerateSentence : null,
                      ),
                    ],
                    if (isAdvancedPracticeTarget)
                      _buildActionButton(
                        text: '高阶加练',
                        textColor: const Color(0xffF59E0B),
                        borderColor: const Color(0xffF59E0B).withValues(alpha: 0.35),
                        backgroundColor: const Color(0xffF59E0B).withValues(alpha: 0.15),
                        onTap: canOperateAdvancedPractice ? controller.onTapAdvancedPractice : null,
                      ),
                  ],
                ),
              )
            ],
          ),
          if (controller.lexicalAnchors.isNotEmpty) ...[
            SizedBox(height: 10.wMin),
            SizedBox(
              width: double.infinity,
              child: _buildLexicalAnchorsWidget(),
            )
          ],
          SizedBox(height: 16.wMin),
          if (controller.sentences.isEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.wMin, vertical: 16.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.wMin),
                color: AppTheme.cSurfaceLayerBase.color,
                border: Border.all(
                  width: 0.8.wMin,
                  color: AppTheme.cBorderThin.color,
                ),
              ),
              child: Text(
                '本单元还没有句子归到这条 Target。用右上角搜索库句或生成句子。',
                style: TextStyle(
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w400,
                  color: _textTertiary,
                ),
              ),
            )
          else
            Column(
              spacing: 16.wMin,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(controller.sentences.length, (index) {
                final sentence = controller.sentences[index];
                final analyzedSentence = controller.findSentenceRealizationByContentId(sentence.contentId);
                return ManageUnitGrammarRepresentSentenceWidget(
                  isManagement: true,
                  sentence: sentence,
                  analyzedSentence: analyzedSentence,
                  index: index,
                  isSentenceAnalyseRunning: controller.isSentenceAnalyseRunning.value,
                  onTapExpandStudy: () {
                    controller.onTapExpandStudy(sentence);
                  },
                  onTapAnalyseGrammar: sentence.hasStructure == true ? null : controller.onAnalyseSentence,
                  onTapRemoveFromGrammar: () {
                    controller.onRemoveFromGrammar(sentence.uid);
                  },
                  onTapRemoveFromUnit: () {
                    controller.onRemoveFromUnit(sentence.uid);
                  },
                );
              }),
            ),
        ],
      ),
    );
  }

  /// 评审信息区：展示证据句、LLM 自评和审核操作。
  Widget _buildReviewWidget() {
    final review = controller.review.value;
    final target = controller.target.value;
    final List<String> evidences = review?.evidences ?? const [];
    final String notes = _buildReviewNotesText(
      notes: review?.reviewNotes,
      score: review?.reviewScore,
    );
    final Color statusColor = _statusColorMap[target?.status] ?? AppTheme.cTextSecondary.color;
    final List<_ManageUnitGrammarReviewActionItem> actionItems = _buildReviewActionItems(target?.status);
    final bool hasReviewQueue = controller.hasReviewQueue();
    final int? previousTargetUid = hasReviewQueue ? controller.getPreviousReviewTargetUid() : null;
    final int? nextTargetUid = hasReviewQueue ? controller.getNextReviewTargetUid() : null;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(90.wMin, 0.wMin, 90.wMin, 0.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cBgPrimary.color.withValues(alpha: 0.96),
        border: Border(
          top: BorderSide(
            width: 1.wMin,
            color: AppTheme.cBorderDefault.color,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.wMin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '教材支持点',
                          style: TextStyle(
                            fontSize: 16.wMin,
                            fontWeight: FontWeight.w500,
                            color: _textSecondary,
                          ),
                        ),
                        SizedBox(height: 8.wMin),
                        if (evidences.isNotEmpty)
                          Column(
                            spacing: 8.wMin,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: evidences.map((evidence) {
                              return Text(
                                evidence,
                                style: TextStyle(
                                  fontSize: 16.wMin,
                                  fontWeight: FontWeight.w400,
                                  color: _textPrimary,
                                ),
                              );
                            }).toList(),
                          )
                        else
                          Text(
                            '教材里还没有挂上支持句。',
                            style: TextStyle(
                              fontSize: 16.wMin,
                              fontWeight: FontWeight.w400,
                              color: _textTertiary,
                            ),
                          ),
                        SizedBox(height: 8.wMin),
                        Row(
                          spacing: 8.wMin,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'LLM 自评',
                              style: TextStyle(
                                fontSize: 16.wMin,
                                fontWeight: FontWeight.w500,
                                color: _textSecondary,
                              ),
                            ),
                            if (review?.reviewScore != null) _buildScoreTag(review?.reviewScore),
                            if (review?.evidenceFit?.isNotEmpty ?? false)
                              Text(
                                review?.evidenceFit ?? '',
                                style: TextStyle(
                                  fontSize: 16.wMin,
                                  fontWeight: FontWeight.w500,
                                  color: _textPrimary,
                                ),
                              ),
                            Text(
                              notes.trim().isNotEmpty ? notes : '这条还没有补充审核说明。',
                              style: TextStyle(
                                fontSize: 16.wMin,
                                fontWeight: FontWeight.w400,
                                color: notes.trim().isNotEmpty ? _textSecondary : _textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 24.wMin),
                  SizedBox(
                    width: 300.wMin,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '状态',
                              style: TextStyle(
                                fontSize: 18.wMin,
                                fontWeight: FontWeight.w500,
                                color: _textSecondary,
                              ),
                            ),
                            SizedBox(width: 8.wMin),
                            _buildTagWidget(
                              tagText: target?.statusLabel ?? target?.status ?? '-',
                              textColor: statusColor,
                              bgColor: statusColor.withValues(alpha: 0.12),
                              borderColor: statusColor.withValues(alpha: 0.2),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.wMin),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          spacing: 8.wMin,
                          children: actionItems.map((item) {
                            return _buildReviewActionButton(
                              text: item.text,
                              status: item.status,
                              onTap: () {
                                controller.onReviewStatus(item.status);
                              },
                            );
                          }).toList(),
                        ),
                        if (hasReviewQueue) ...[
                          SizedBox(height: 12.wMin),
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
                                ),

                              ),
                              Text(
                              '还剩 ${controller.remainingReviewQueueCandidateCount()} 条待审',
                              style: TextStyle(
                                fontSize: 12.wMin,
                                fontWeight: FontWeight.w400,
                                color: _textTertiary,
                              ),
                            )
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
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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

  String _buildReviewNotesText({
    required String? notes,
    required num? score,
  }) {
    final String rawNotes = notes ?? '';
    if (rawNotes.isEmpty || score == null) return rawNotes;
    final String scoreText = score % 1 == 0 ? score.toInt().toString() : '$score';
    final List<String> prefixes = [
      '$scoreText:',
      '$scoreText：',
      '$scoreText :',
      '$scoreText ：',
    ];
    for (final prefix in prefixes) {
      if (rawNotes.startsWith(prefix)) {
        return rawNotes.substring(prefix.length).trimLeft();
      }
    }
    return rawNotes;
  }

  Widget _buildScoreTag(num? score) {
    if (score == null) return const SizedBox.shrink();
    final String scoreText = score % 1 == 0 ? score.toInt().toString() : '$score';
    return Container(
      height: 24.wMin,
      padding: EdgeInsets.symmetric(horizontal: 8.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        color: const Color(0xff22D3EE).withValues(alpha: 0.12),
        border: Border.all(
          color: const Color(0xff22D3EE).withValues(alpha: 0.2),
          width: 0.5.wMin,
        ),
      ),
      child: Text(
        '$scoreText分',
        style: TextStyle(
          fontSize: 16.wMin,
          fontWeight: FontWeight.w500,
          color: const Color(0xff22D3EE),
        ),
      ),
    );
  }

  Widget _buildLexicalAnchorsWidget() {
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 4.wMin,
      runSpacing: 4.wMin,
      children: controller.lexicalAnchors.map((anchor) {
        final Color anchorColor = _getLexicalAnchorColor(anchor.bindingMode);
        return _buildTagWidget(
          tagText: '${anchor.content ?? ''}${anchor.bindingModeLabel?.isNotEmpty == true ? ' · ${anchor.bindingModeLabel}' : ''}',
          textColor: anchorColor,
          bgColor: anchorColor.withValues(alpha: 0.12),
          borderColor: anchorColor.withValues(alpha: 0.2),
        );
      }).toList(),
    );
  }

  /// pattern / pyramid 头部信息区，复用句型蓝图详情的信息表达。
  Widget _buildPatternInfoWidget() {
    final target = controller.target.value;
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
                      text: localName?.text ?? target?.title ?? target?.assetNid ?? 'Target详情',
                    ),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Container(
                        margin: EdgeInsets.only(left: 4.wMin),
                        child: CopyTagWidget(
                          name: '句型',
                          value: data?.nid ?? target?.assetNid ?? '',
                        ),
                      ),
                    ),
                    if (target?.uid != null)
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Container(
                          margin: EdgeInsets.only(left: 4.wMin),
                          child: CopyTagWidget(
                            name: 'targetUid',
                            value: '${target?.uid}',
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
    final target = controller.target.value;
    final data = controller.patternBlueprint.value;
    final statusColor = _statusColorMap[target?.status] ?? AppTheme.cTextSecondary.color;
    final List<Widget> tags = [];

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
        tagText: target?.statusLabel ?? target?.status ?? '-',
        textColor: statusColor,
        bgColor: statusColor.withValues(alpha: 0.12),
        borderColor: statusColor.withValues(alpha: 0.2),
      ),
    );

    return Row(spacing: 6.wMin, children: tags);
  }

  Widget _buildPatternInfoBottomTagsWidget() {
    final target = controller.target.value;
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
    if (target?.pointOrder != null) {
      tags.add(
        _buildTagWidget(
          tagText: '要点${target?.pointOrder}',
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
    final target = controller.target.value;
    final data = controller.paradigmCompareData.value;
    final dimensionName = LearningLangUtils.getLocalLang(data?.dimension?.name);
    final name = LearningLangUtils.getLocalLang(data?.name);
    final description = LearningLangUtils.getLocalLang(data?.description);
    final transformationKindName = LearningLangUtils.getLocalLang(data?.transformationKind?.name);
    final int memberCount = data?.memberList?.length ?? 0;
    final int sentenceRealizationSetCount = data?.sentenceRealizationSetList?.length ?? 0;
    final Color statusColor = _statusColorMap[target?.status] ?? AppTheme.cTextSecondary.color;

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
              tagText: target?.statusLabel ?? target?.status ?? '-',
              textColor: statusColor,
              bgColor: statusColor.withValues(alpha: 0.12),
              borderColor: statusColor.withValues(alpha: 0.2),
            ),
            if (target?.pointOrder != null) ...[
              SizedBox(width: 6.wMin),
              _buildTagWidget(tagText: '要点${target?.pointOrder}'),
            ],
          ],
        ),
        SizedBox(height: 10.wMin),
        Row(
          spacing: 4.wMin,
          children: [
            Flexible(
              child: Text(
                name?.text ?? target?.title ?? target?.assetNid ?? 'Target详情',
                style: TextStyle(
                  fontSize: 28.wMin,
                  fontWeight: FontWeight.w500,
                  color: _textPrimary,
                ),
              ),
            ),
            CopyTagWidget(
              name: '对照',
              value: data?.nid ?? target?.assetNid ?? '',
            ),
            if (target?.uid != null)
              CopyTagWidget(
                name: 'targetUid',
                value: '${target?.uid}',
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
            isManagement: true,
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
    final target = controller.target.value;
    final data = controller.grammarPanoramaData.value;
    final name = LearningLangUtils.getLocalLang(data?.name);
    final description = LearningLangUtils.getLocalLang(data?.description);
    final int subCount = data?.minimalSubGridCount ?? 0;
    final Color statusColor = _statusColorMap[target?.status] ?? AppTheme.cTextSecondary.color;

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
              value: data?.nid ?? target?.assetNid ?? '',
            ),
            const Spacer(),
            _buildTagWidget(
              tagText: target?.statusLabel ?? target?.status ?? '-',
              textColor: statusColor,
              bgColor: statusColor.withValues(alpha: 0.12),
              borderColor: statusColor.withValues(alpha: 0.2),
            ),
            if (target?.pointOrder != null) ...[
              SizedBox(width: 6.wMin),
              _buildTagWidget(tagText: '要点${target?.pointOrder}'),
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
              name?.text ?? target?.title ?? target?.assetNid ?? 'Target详情',
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w500,
                color: _textPrimary,
              ),
            ),
            if (target?.uid != null)
              CopyTagWidget(
                name: 'targetUid',
                value: '${target?.uid}',
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
    final target = controller.target.value;
    final pair = controller.pairData.value;
    final String pairTypeName =
        LearningLangUtils.getLocalLang(pair?.pairType?.name)?.text ?? '问答配对';
    final String pairName =
        LearningLangUtils.getLocalLang(pair?.name)?.text ??
        target?.title ??
        target?.assetNid ??
        'Target详情';
    final String pairDescription =
        LearningLangUtils.getLocalLang(pair?.description)?.text ??
        target?.description ??
        '';
    final PracticeModeEnum? practiceModeEnum = PracticeModeEnum.fromValue(
      pair?.practiceMode,
    );
    final PairRacticeKindEnum? preferredPracticeEnum =
        PairRacticeKindEnum.fromValue(pair?.preferredPractice);
    final Color statusColor =
        _statusColorMap[target?.status] ?? AppTheme.cTextSecondary.color;
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
                  tagText: target?.statusLabel ?? target?.status ?? '-',
                  textColor: statusColor,
                  bgColor: statusColor.withValues(alpha: 0.12),
                  borderColor: statusColor.withValues(alpha: 0.2),
                ),
                if (target?.pointOrder != null)
                  _buildTagWidget(tagText: '要点${target?.pointOrder}'),
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
              value: pair?.nid ?? target?.assetNid ?? '',
            ),
            if (target?.uid != null)
              CopyTagWidget(
                name: 'targetUid',
                value: '${target?.uid}',
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

    final List<SentencePairForkEntity> pairForks =
        (pair.pairForks ?? const []).whereType<SentencePairForkEntity>().toList();
    final List<SentencePairSemanticAnchorMappingEntity> semanticAnchorMappings =
        (pair.semanticAnchorMappings ?? const [])
            .whereType<SentencePairSemanticAnchorMappingEntity>()
            .toList();

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
          child: SentencePairingLinkDetailTableWidget(
            pairOrderConstraint: PairOrderConstraintEnum.fromValue(pair.orderConstraint),
            realizationSetList: pair.realizationSetList,
            fromRealization: pair.fromRealization,
            toRealization: pair.toRealization,
            isManagement: true,
          ),
        ),
        if (pairForks.isNotEmpty) _buildQaPairForkChainWidget(pairForks),
        if (semanticAnchorMappings.isNotEmpty)
          _buildQaPairWhyMatchWidget(semanticAnchorMappings),
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
    final String forkName =
        LearningLangUtils.getLocalLang(fork.name)?.text ?? fork.nid ?? '';
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
                  LearningLangUtils.getLocalLang(mapping.fromPatternSlot?.name)?.text ??
                  mapping.fromPatternSlotKey ??
                  '';
              final String toSlotName =
                  LearningLangUtils.getLocalLang(mapping.toPatternSlot?.name)?.text ??
                  mapping.toPatternSlotKey ??
                  '';
              return _buildTagWidget(tagText: '$fromSlotName → $toSlotName');
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPairForkInfoWidget() {
    final target = controller.target.value;
    final fork = controller.pairForkData.value;
    final String pairTypeName =
        LearningLangUtils.getLocalLang(fork?.pairType?.name)?.text ?? '';
    final String contrastDimensionName =
        LearningLangUtils.getLocalLang(fork?.contrastDimension?.name)?.text ?? '';
    final String forkName =
        LearningLangUtils.getLocalLang(fork?.name)?.text ??
        target?.title ??
        target?.assetNid ??
        'Target详情';
    final String forkDescription =
        LearningLangUtils.getLocalLang(fork?.description)?.text ??
        target?.description ??
        '';
    final PairRacticeKindEnum? kindEnum = PairRacticeKindEnum.fromValue(fork?.kind);
    final SoloPairPracticeEnum? soloPairPracticeEnum =
        SoloPairPracticeEnum.fromValue(fork?.soloPairPractice);
    final Color statusColor =
        _statusColorMap[target?.status] ?? AppTheme.cTextSecondary.color;
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
                    [pairTypeName, contrastDimensionName]
                        .where((item) => item.isNotEmpty)
                        .join(' · '),
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
                    ),
                ],
              ),
            ),
            Row(
              spacing: 6.wMin,
              children: [
                _buildTagWidget(
                  tagText: target?.statusLabel ?? target?.status ?? '-',
                  textColor: statusColor,
                  bgColor: statusColor.withValues(alpha: 0.12),
                  borderColor: statusColor.withValues(alpha: 0.2),
                ),
                if (target?.pointOrder != null)
                  _buildTagWidget(tagText: '要点${target?.pointOrder}'),
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
              ),
            if (target?.uid != null)
              CopyTagWidget(
                name: 'targetUid',
                value: '${target?.uid}',
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
    final String usageText = LearningLangUtils.getLocalLang(fork.usage)?.text ?? '';

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
              width: 1.wMin,
            ),
          ),
          child: SentencePairingLinkForkDetailsTableWidget(
            realizationSetList: fork.realizationSetList,
            isManagement: true,
          ),
        ),
        if (usageText.isNotEmpty)
          Container(
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
                  '出题人怎么用',
                  style: TextStyle(
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w500,
                    color: _textPrimary,
                  ),
                ),
                SizedBox(height: 10.wMin),
                Text(
                  usageText,
                  style: TextStyle(
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w400,
                    color: _textTertiary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPairInfoWidget() {
    final target = controller.target.value;
    final payload = controller.grammarStructPayload;
    final String pairName = _findLocalText(payload['name']) ?? target?.title ?? target?.assetNid ?? 'Target详情';
    final String pairDescription = _findLocalText(payload['description']) ?? target?.description ?? '';
    final String pairTypeName = _findLocalText(_readMap(payload['pairType'])?['name']) ?? '一组对照';
    final Color statusColor = _statusColorMap[target?.status] ?? AppTheme.cTextSecondary.color;

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
              value: payload['nid']?.toString() ?? target?.assetNid ?? '',
            ),
            const Spacer(),
            _buildTagWidget(tagText: pairTypeName),
            SizedBox(width: 6.wMin),
            _buildTagWidget(
              tagText: target?.statusLabel ?? target?.status ?? '-',
              textColor: statusColor,
              bgColor: statusColor.withValues(alpha: 0.12),
              borderColor: statusColor.withValues(alpha: 0.2),
            ),
            if (target?.pointOrder != null) ...[
              SizedBox(width: 6.wMin),
              _buildTagWidget(tagText: '要点${target?.pointOrder}'),
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
              value: target?.assetNid ?? '',
            ),
            if (target?.uid != null)
              CopyTagWidget(
                name: 'targetUid',
                value: '${target?.uid}',
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
            ),
          ),
        ],
      ),
    );
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
