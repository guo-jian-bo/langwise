import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../routes/routes.dart';
import '../../../common/commons.dart';
import '../bindings/manage_unit_grammar_hub_binding.dart';
import '../controllers/manage_unit_grammar_hub_controller.dart';
import 'manage_unit_grammar_step_widget.dart';

class ManageUnitGrammarHubView extends GetView<ManageUnitGrammarHubController> {
  final String tagText;
  const ManageUnitGrammarHubView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_UNIT_GRAMMAR_HUB}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageUnitGrammarHubView(tagText: tag),
      binding: ManageUnitGrammarHubBinding(tag: tag),
      routeName: Routes.MANAGE_UNIT_GRAMMAR_HUB,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  ///透明背景
  static final Color _panelColor = AppTheme.cBorderNone.color;
  static const Color _borderColor = AppTheme.cSurfaceGhostBgSubtle;
  static final Color _textPrimary = AppTheme.cTextPrimary.color;
  static final Color _textSecondary = AppTheme.cTextSecondary.color;
  static const Color _cyan = Color(0xff22D3EE);
  static const Color _amber = AppTheme.cAmber;
  static const Color _emerald = Color(0xff34D399);
  static final Color _dividerColor = AppTheme.cBorderDefault.color;

  static const Map<String, Color> _kindColorMap = {
    'pattern': Color(0xff8B5CF6),
    'pair': Color(0xffFB7185),
    'pair_fork': Color(0xffF97316),
    'paradigm': Color(0xffD946EF),
    'pyramid': Color(0xffA855F7),
    'grid': Color(0xffEC4899),
  };

  static const Map<String, Color> _statusColorMap = {
    'candidate': Color(0xffF59E0B),
    'approved': Color(0xff34D399),
    'disabled': Color(0xff94A3B8),
  };

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      onRefresh: () => controller.fetchData(showLoading: true),
      body: Obx(() {
        if (controller.isLoading.value && controller.hubData.value == null) {
          return const SizedBox.shrink();
        }

        if (controller.hubData.value == null) {
          return Center(
            child: Text(
              '暂无单元语法数据',
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 16.wMin,
                ),
              ),
            );
        }

        return Padding(
          padding: EdgeInsets.fromLTRB(90.wMin, 24.wMin, 90.wMin, 20.wMin),
          child: Column(
            children: [
              _buildSummaryHeader(),
              SizedBox(height: 16.wMin),
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width: 450.wMin,
                      child: _buildOutlinePanel(),
                    ),
                    VerticalDivider(
                      color: _dividerColor,
                      width: 48.wMin,
                    ),
                    Expanded(
                      child: _buildMainPanel(),
                    ),
                  ],
                ),
              ),
              Divider(
                color: _dividerColor,
              ),
              _buildPipelineBar(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSummaryHeader() {
    final ManageUnitGrammarHeaderEntity? header = controller.header.value;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.wMin),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.unitName ?? '单元语法',
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 26.wMin,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 10.wMin,
            runSpacing: 10.wMin,
            alignment: WrapAlignment.end,
            children: [
              _buildSummaryChip(
                label: 'Target',
                valueSpan: TextSpan(
                  text: '${header?.targetTotalCount ?? 0}',
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              _buildSummaryChip(
                label: '备选',
                valueSpan: TextSpan(
                  text: '${header?.candidateCount ?? 0}',
                  style: TextStyle(
                    color: _amber,
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                labelColor: _amber,
                textColor: _amber,
                bgColor: _amber.withValues(alpha: 0.12),
                borderColor: _amber,
              ),
              _buildSummaryChip(
                label: '句',
                valueSpan: TextSpan(
                  children: [
                    TextSpan(
                      text: '${header?.boundSentenceCount ?? 0}',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 16.wMin,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextSpan(
                      text: '/${header?.sentenceTotalCount ?? 0}',
                      style: TextStyle(
                        color: _emerald,
                        fontSize: 16.wMin,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryChip({
    required String label,
    required InlineSpan valueSpan,
    Color labelColor = AppTheme.cTextSecondary,
    Color textColor = AppTheme.cTextSecondary,
    Color bgColor = AppTheme.cSurfaceLayerBase,
    Color borderColor = AppTheme.cBorderThin,
  }) {
    return Container(
      height: 28.wMin,
      padding: EdgeInsets.symmetric(horizontal: 10.wMin),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999.wMin),
        border: Border.all(
          color: borderColor.withValues(alpha: 0.2),
          width: 0.5.wMin,
        ),
      ),
      child: Text.rich(
        TextSpan(
          style: TextStyle(
            fontSize: 16.wMin,
            fontWeight: FontWeight.w400,
            color: textColor,
          ),
          children: [
            TextSpan(
              text: '$label ',
              style: TextStyle(
                color: labelColor,
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
              ),
            ),
            valueSpan,
          ],
        ),
      ),
    );
  }

  Widget _buildOutlinePanel() {
    return Container(
        height: double.infinity,
        child: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '大纲要点',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8.wMin),
              if (controller.hubData.value?.outline == null || controller.points.isEmpty)
                Text(
                  '尚未生成。先执行底部产线第 1 步「生成单元语法」。',
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 16.wMin,
                    height: 1.5,
                  ),
                )
              else ...[
                if ((controller.hubData.value?.outline?.summary?.isNotEmpty ?? false))
                  Padding(
                    padding: EdgeInsets.only(bottom: 24.wMin),
                    child: Text(
                      controller.hubData.value?.outline?.summary ?? '',
                      style: TextStyle(
                        color: const Color(0xffCBD5E1),
                        fontSize: 16.wMin,
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView(
                    children: [
                      _buildPointFilterItem(
                        title: '全部要点',
                        description: null,
                        selected: controller.pointFilter.value == 0,
                        onTap: () => controller.onChangePointFilter(null),
                        mark: _buildPointMark(
                          pendingCount: controller.points.fold<int>(
                            0,
                            (sum, point) => sum + (point.candidateCount ?? 0),
                          ),
                          deficitCount: controller.points.fold<int>(
                            0,
                            (sum, point) => sum + (point.patternDeficitCount ?? 0),
                          ),
                        ),
                      ),
                      ...controller.points.map((point) {
                        return _buildPointFilterItem(
                          title: '${point.pointOrder ?? 0}. ${point.title ?? '未命名要点'}',
                          description: point.objective ?? point.description,
                          selected: controller.pointFilter.value == (point.pointOrder ?? 0),
                          onTap: () => controller.onChangePointFilter(point.pointOrder),
                          mark: _buildPointMark(
                            pendingCount: point.candidateCount ?? 0,
                            deficitCount: point.patternDeficitCount ?? 0,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ],
          );
        }));
  }

  Widget _buildPointFilterItem({
    required String title,
    required String? description,
    required bool selected,
    required VoidCallback onTap,
    required Widget mark,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.wMin),
      child: TapScaleWidget(
        sclae: 1.01,
        borderRadius: 16.wMin,
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(14.wMin),
          decoration: BoxDecoration(
            color: selected ? AppTheme.cFeedbackInfoBackground : AppTheme.cSurfaceTranslucentBase,
            borderRadius: BorderRadius.circular(8.wMin),
            border: Border.all(
              color: selected ? AppTheme.cFeedbackInfoBackground : AppTheme.cBorderTranslucentThin,
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
                      title,
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 20.wMin,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.wMin),
                  mark,
                ],
              ),
              if (description?.isNotEmpty ?? false) ...[
                SizedBox(height: 6.wMin),
                Text(
                  description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 16.wMin,
                    height: 1.45,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPointMark({
    required int pendingCount,
    required int deficitCount,
  }) {
    if (pendingCount > 0) {
      return Text(
        '$pendingCount 待审',
        style: TextStyle(
          color: _amber,
          fontSize: 20.wMin,
          fontWeight: FontWeight.w600,
        ),
      );
    }
    if (deficitCount > 0) {
      return Text(
        '缺 $deficitCount',
        style: TextStyle(
          color: const Color(0xffFBBF24),
          fontSize: 20.wMin,
          fontWeight: FontWeight.w600,
        ),
      );
    }
    return SvgPicture.asset(
      "assets/svg/manage/icon_yes.svg",
      width: 12.wMin,
      height: 12.wMin,
      colorFilter: const ColorFilter.mode(AppTheme.cMorphemeTagPrefix, BlendMode.srcIn),
    );
  }

  Widget _buildMainPanel() {
    return Container(
      height: double.infinity,
      child: Column(
        children: [
          Row(
            children: [
              _buildSwitchTab(
                label: '语法列表',
                selected: controller.pane.value == 'targets',
                onTap: () => controller.onChangePane('targets'),
              ),
              SizedBox(width: 10.wMin),
              _buildSwitchTab(
                label: '句子列表',
                badgeText: controller.newCreatedSentenceCount() > 0
                    ? 
                    '新 ${controller.newCreatedSentenceCount()}'
                    : null,
                selected: controller.pane.value != 'targets',
                onTap: () => controller.onChangePane('sentences'),
              ),
            ],
          ),
          SizedBox(height: 24.wMin),
          controller.pane.value == 'targets'
              ? Row(
                  spacing: 12.wMin,
                  children: [
                    _buildFilterChip(
                      label: '全部',
                      selected: controller.kindFilter.value == 'all',
                      onTap: () => controller.onChangeKindFilter('all'),
                    ),
                    ...controller.targetTabs.where((e) => e.code != 'all').map((tab) => _buildFilterChip(
                          label: tab.label ?? tab.code ?? '-',
                          selected: controller.kindFilter.value == tab.code,
                            tagColor: _kindColorMap[tab.code],
                          onTap: () => controller.onChangeKindFilter(
                            tab.code ?? 'all',
                          ),
                        )),
                  ],
                )
              : Row(
                  spacing: 12.wMin,
                  children: controller.sentenceTabs
                      .where((tab) => tab.code?.isNotEmpty == true)
                      .map(
                        (tab) => _buildFilterChip(
                          label: '${tab.label ?? tab.code ?? '-'} ${tab.count ?? 0}',
                          selected: controller.sentenceQueue.value == tab.code,
                          onTap: () => controller.onChangeSentenceQueue(tab.code!),
                        ),
                      )
                      .toList(),
                ),
          if (controller.hubData.value?.reviewEntry?.hasCandidate == true && controller.pane.value == 'targets')
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: 12.wMin),
              padding: EdgeInsets.symmetric(
                horizontal: 12.wMin,
                vertical: 12.wMin,
              ),
              color: _amber.withValues(alpha: 0.12),
              child: Text(
                '还有 ${controller.header.value?.candidateCount ?? 0} 条备选。每条标成「通过」或「未通过」后，才能进入后续绑定与补句步骤。',
                style: TextStyle(
                  color: _amber,
                  fontSize: 16.wMin,
                ),
              ),
            ),
          SizedBox(height: 12.wMin),
          Expanded(
            child: controller.pane.value == 'targets' ? _buildTargetList() : _buildSentenceList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTab({
    required String label,
    String? badgeText,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return TapScaleWidget(
      sclae: 1.01,
      borderRadius: 999.wMin,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.wMin, vertical: 10.wMin),
        decoration: BoxDecoration(
          color: selected ? AppTheme.cFeedbackInfoBackground : AppTheme.cSurfaceGhostBgSubtle,
          borderRadius: BorderRadius.circular(999.wMin),
          border: Border.all(
            color: selected ? AppTheme.cFeedbackInfoBackground : _borderColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? AppTheme.cBgBrand : _textPrimary,
                fontSize: 20.wMin,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (badgeText?.isNotEmpty == true) ...[
              SizedBox(width: 8.wMin),
              Container(
                height: 24.wMin,
                padding: EdgeInsets.symmetric(horizontal: 8.wMin),
                decoration: BoxDecoration(
                  color: const Color(0xffF59E0B).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999.wMin),
                  border: Border.all(
                    color: const Color(0xffF59E0B).withValues(alpha: 0.28),
                    width: 0.5.wMin,
                  ),
                ),
                child: Center(
                  child: Text(
                    badgeText ?? '',
                    style: TextStyle(
                      color: const Color(0xffF59E0B),
                      fontSize: 16.wMin,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    Color? tagColor,
    required VoidCallback onTap,
  }) {
    final Color backgroundColor;
    final Color borderColor;
    final Color textColor;
    if (tagColor != null && selected) {
      backgroundColor = tagColor.withValues(alpha: 0.12);
      borderColor = tagColor.withValues(alpha: 0.22);
      textColor = tagColor;
    } else {
      backgroundColor =
          selected ? AppTheme.cFeedbackInfoBackground : AppTheme.cSurfaceGhostBgSubtle;
      borderColor = selected ? AppTheme.cFeedbackInfoBackground : _borderColor;
      textColor = selected ? AppTheme.cBgBrand : _textSecondary;
    }
    return TapScaleWidget(
      sclae: 1.01,
      borderRadius: 999.wMin,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 6.wMin),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999.wMin),
          border: Border.all(
            color: borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 18.wMin,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTargetList() {
    final groups = controller.groupedTargets();
    if (controller.filteredTargets().isEmpty) {
      return Center(
        child: Text(
          controller.hubData.value?.outline != null ? '没有可展示的 Target。' : '先生成单元语法，再在这里审核 Target。',
          style: TextStyle(
            color: _textSecondary,
            fontSize: 20.wMin,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 18.wMin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (group.point != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 10.wMin),
                  child: Text(
                    '要点 ${group.point?.pointOrder ?? 0} · ${group.point?.title ?? ''}',
                    style: TextStyle(
                      color: _textSecondary,
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              LayoutBuilder(
                builder: (context, constraints) {
                  final double itemWidth = constraints.maxWidth > 900.wMin ? (constraints.maxWidth - 12.wMin) / 2 : constraints.maxWidth;
                  return Wrap(
                    spacing: 12.wMin,
                    runSpacing: 12.wMin,
                    children: group.targets
                        .map(
                          (target) => SizedBox(
                            width: itemWidth,
                            child: _buildTargetCard(target),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTargetCard(ManageUnitGrammarTargetEntity target) {
    final Color kindColor = _kindColorMap[target.assetKind] ?? _cyan;
    final Color statusColor = _statusColorMap[target.status] ?? _textSecondary;
    final bool isPattern = target.assetKind == 'pattern';
    final int boundCount = target.boundCount ?? 0;
    final int needCount = target.needCount ?? 0;
    final int deficitCount = target.deficitCount ?? 0;
    return TapScaleWidget(
      sclae: 1.01,
      borderRadius: 16.wMin,
      onTap: () => controller.onOpenTargetDetails(target),
      child: Container(
        padding: EdgeInsets.all(16.wMin),
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceTranslucentBase,
          borderRadius: BorderRadius.circular(16.wMin),
          border: Border.all(
            color: target.status == 'candidate' ? _amber.withValues(alpha: 0.4) : _borderColor,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 8.wMin,
              children: [
                _buildTinyTag(
                  text: target.assetLabel ?? target.assetKind ?? '-',
                  color: kindColor,
                  useHeaderStyle: true,
                ),
                _buildTinyTag(
                  text: target.statusLabel ?? target.status ?? '-',
                  color: statusColor,
                  useHeaderStyle: true,
                ),
                if (target.reviewScore != null)
                  Text(
                    '自评 ${target.reviewScore}',
                    style: TextStyle(
                      color: _textSecondary,
                      fontSize: 14.wMin,
                    ),
                  ),
                  Spacer(),
                  if (target.uid != null)
                    CopyTagWidget(
                      name: 'target',
                      value: '${target.uid}',
                    ),
              ],
            ),
            SizedBox(height: 10.wMin),
            Text(
              target.title ?? '未命名 Target',
              style: TextStyle(
                color: _textPrimary,
                fontSize: 20.wMin,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 6.wMin),
            Text(
              target.assetNid ?? '—',
              style: TextStyle(
                color: _textSecondary,
                fontSize: 14.wMin,
              ),
            ),
            SizedBox(height: 10.wMin),
            if (isPattern)
              Text.rich(
                deficitCount > 0
                    ? TextSpan(
                        children: [
                          TextSpan(
                            text: '句 $boundCount/$needCount  ',
                            style: TextStyle(
                              color: AppTheme.cTextSecondary.color,
                              fontSize: 14.wMin,
                            ),
                          ),
                          TextSpan(
                            text: '缺 $deficitCount',
                            style: TextStyle(
                              color: const Color(0xffFBBF24),
                              fontSize: 14.wMin,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : TextSpan(
                        children: [
                          TextSpan(
                            text: '句 ',
                            style: TextStyle(
                              color: AppTheme.cTextSecondary.color,
                              fontSize: 14.wMin,
                            ),
                          ),
                          TextSpan(
                            text: '$boundCount',
                            style: TextStyle(
                              color: AppTheme.cTextPrimary.color,
                              fontSize: 14.wMin,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: '/$needCount  ',
                            style: TextStyle(
                              color: AppTheme.cTextSecondary.color,
                              fontSize: 14.wMin,
                            ),
                          ),
                          TextSpan(
                            text: '已满',
                            style: TextStyle(
                              color: const Color(0xff34D399),
                              fontSize: 14.wMin,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              )
            else
              Text(
                '高阶结构内容，句子最终落在关联 pattern 下',
                style: TextStyle(
                  color: AppTheme.cTextBrand.color.withValues(alpha: 0.8),
                  fontSize: 12.wMin,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTinyTag({
    required String text,
    required Color color,
    bool useHeaderStyle = false,
  }) {
    return Container(
      height: 28.wMin,
      padding: EdgeInsets.symmetric(horizontal: 10.wMin),
      decoration: BoxDecoration(
        color: color.withValues(alpha: useHeaderStyle ? 0.12 : 0.15),
        borderRadius: BorderRadius.circular(999.wMin),
        border: Border.all(
          color: color.withValues(alpha: 0.20),
          width: 0.5.wMin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentenceList() {
    final rows = controller.sentenceRows();
    if (rows.isEmpty) {
      return Center(
        child: Text(
          controller.sentenceQueue.value == 'bound' ? '还没有已绑定的句子。先跑「已有句子绑定语法」。' : '这个队列是空的。',
            style: TextStyle(
              color: _textSecondary,
              fontSize: 20.wMin,
            ),
          ),
      );
    }

    return ListView.separated(
      itemCount: rows.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.wMin),
      itemBuilder: (context, index) => _buildSentenceCard(rows[index]),
    );
  }

  Widget _buildSentenceCard(ManageUnitGrammarSentenceEntity sentence) {
    final bool isBound = controller.sentenceQueue.value == 'bound';
    final bool isNotTargetSentence = sentence.grammarBindStatus == 'not_target';
    final bool hasLinkedTargets = sentence.targetBadges?.isNotEmpty ?? false;
    final bool isNewCreated = sentence.access == 'INTERNAL';
    final bool canAnalyseSentence = sentence.hasStructure != true && hasLinkedTargets;
    final bool isAnalysingSentence = controller.sentenceAnalyseLoadingUid.value == sentence.uid;
    final String? queueLabel = isBound
        ? null
        : controller.getSentenceQueueLabel(sentence.grammarBindStatus ?? '');
    final footerTexts = _buildSentenceFooterTexts(
      sentence: sentence,
      isBound: isBound,
      hasLinkedTargets: hasLinkedTargets,
    );
    return Container(
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceTranslucentBase,
        borderRadius: BorderRadius.circular(16.wMin),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  sentence.content ?? '',
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 20.wMin,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: 12.wMin),
              Row(
                spacing: 8.wMin,
              
                children: [
                    if (sentence.contentId != null)
                      CopyTagWidget(
                        name: 'contentId',
                        value: '${sentence.contentId}',
                      ),
                  if (isNewCreated)
                    _buildSentenceStateTag(
                      text: '新创建',
                      textColor: const Color(0xffF59E0B),
                      backgroundColor: const Color(0xffF59E0B).withValues(alpha: 0.12),
                      borderColor: const Color(0xffF59E0B).withValues(alpha: 0.30),
                    ),
                  if (queueLabel?.isNotEmpty == true)
                    _buildSentenceStateTag(
                      text: queueLabel ?? '',
                      textColor: sentence.grammarBindStatus == 'unchecked'
                          ? const Color(0xffFDE68A)
                          : const Color(0xffCBD5E1),
                      backgroundColor: sentence.grammarBindStatus == 'unchecked'
                          ? const Color(0xffF59E0B).withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.08),
                      borderColor: sentence.grammarBindStatus == 'unchecked'
                          ? const Color(0xffF59E0B).withValues(alpha: 0.30)
                          : Colors.white.withValues(alpha: 0.14),
                    ),
                  if (sentence.hasStructure == true)
                    _buildSentenceStateTag(
                      text: '已分析',
                      textColor: const Color(0xffA7F3D0),
                      backgroundColor: const Color(0xff10B981).withValues(alpha: 0.16),
                    )
                  else if (canAnalyseSentence || isAnalysingSentence)
                    _buildSentenceActionButton(
                      text: isAnalysingSentence ? '分析中' : '分析句子',
                      textColor: const Color(0xffF59E0B),
                      borderColor: const Color(0xffF59E0B).withValues(alpha: 0.35),
                      backgroundColor: const Color(0xffF59E0B).withValues(alpha: 0.12),
                      onTap: isAnalysingSentence
                          ? null
                          : () {
                              controller.onAnalyseSentence(sentence);
                            },
                    )
                  else
                    _buildSentenceStateTag(
                      text: '未分析',
                      textColor: const Color(0xff94A3B8),
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                    ),
                ],
              ),
            ],
          ),
          if (isBound && hasLinkedTargets) ...[
            SizedBox(height: 12.wMin),
            Wrap(
              spacing: 6.wMin,
              runSpacing: 6.wMin,
              children: (sentence.targetBadges ?? const [])
                  .map(
                    (badge) => _buildSentenceTargetBadge(badge),
                  )
                  .toList(),
            ),
          ],
          if (footerTexts.isNotEmpty) ...[
            SizedBox(height: 10.wMin),
            if (isNotTargetSentence)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 12.wMin,
                      runSpacing: 6.wMin,
                      children: footerTexts
                          .map(
                            (text) => Text(
                              text,
                              style: TextStyle(
                                color: const Color(0xff64748B),
                                fontSize: 14.wMin,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  SizedBox(width: 12.wMin),
                  _buildSentenceActionButton(
                    text: '从单元移除',
                    textColor: const Color(0xffFCA5A5),
                    borderColor: const Color(0xffFB7185).withValues(alpha: 0.35),
                    backgroundColor: const Color(0xffFB7185).withValues(alpha: 0.12),
                    onTap: () {
                      controller.onRemoveSentenceFromUnit(sentence.uid);
                    },
                  ),
                ],
              )
            else
              Wrap(
                spacing: 12.wMin,
                runSpacing: 6.wMin,
                children: footerTexts
                    .map(
                      (text) => Text(
                        text,
                        style: TextStyle(
                          color: const Color(0xff64748B),
                          fontSize: 14.wMin,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildSentenceStateTag({
    required String text,
    required Color textColor,
    required Color backgroundColor,
    Color? borderColor,
  }) {
    return Container(
      height: 28.wMin,
      padding: EdgeInsets.symmetric(horizontal: 10.wMin),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999.wMin),
        border: Border.all(
          color: (borderColor ?? textColor).withValues(alpha: 0.20),
          width: 0.5.wMin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentenceActionButton({
    required String text,
    required Color textColor,
    required Color borderColor,
    required Color backgroundColor,
    VoidCallback? onTap,
  }) {
    return TapScaleWidget(
      sclae: 1.01,
      borderRadius: 999.wMin,
      onTap: onTap,
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
    );
  }

  Widget _buildSentenceTargetBadge(ManageUnitGrammarTargetBadgeEntity badge) {
    final target = _findTargetByBadge(badge);
    final kind = target?.assetKind;
    final dotColor = _kindColorMap[kind] ?? const Color(0xff8B5CF6);
    final statusColor = _statusColorMap[badge.status] ?? const Color(0xff94A3B8);
    final canOpen = target != null;
    return TapScaleWidget(
      onTap: canOpen ? () => controller.onOpenTargetDetails(target) : null,
      sclae: 1.0,
      child: Container(
        constraints: BoxConstraints(maxWidth: 460.wMin),
        height: 28.wMin,
        padding: EdgeInsets.symmetric(horizontal: 10.wMin),
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceLayerBase.color,
          borderRadius: BorderRadius.circular(999.wMin),
          border: Border.all(
            color: AppTheme.cBorderThin.color.withValues(alpha: 0.2),
            width: 0.5.wMin,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 6.wMin,
              height: 6.wMin,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 6.wMin),
            Flexible(
              child: Text(
                badge.title ?? 'Target',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            SizedBox(width: 6.wMin),
            Text(
              badge.statusLabel ?? badge.status ?? '',
              style: TextStyle(
                color: statusColor,
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  ManageUnitGrammarTargetEntity? _findTargetByBadge(
    ManageUnitGrammarTargetBadgeEntity badge,
  ) {
    final int? targetUid = badge.targetUid;
    if (targetUid == null) {
      return null;
    }
    final targets = controller.points.expand((e) => e.targets);
    for (final target in targets) {
      if (target.uid == targetUid) {
        return target;
      }
    }
    return null;
  }

  List<String> _buildSentenceFooterTexts({
    required ManageUnitGrammarSentenceEntity sentence,
    required bool isBound,
    required bool hasLinkedTargets,
  }) {
    final List<String> texts = [];
    if (sentence.sourceLabel?.isNotEmpty == true) {
      texts.add(sentence.sourceLabel!);
    }
    if (!isBound && sentence.grammarBindStatus == 'unchecked') {
      texts.add('跑「已有句子绑定语法」后会归到 Target');
    }
    if (!isBound && sentence.grammarBindStatus == 'not_target') {
      texts.add('绑定判定：不是本单元语法句');
    }
    if (isBound && !hasLinkedTargets) {
      texts.add('已绑定，但 Target 已不在本单元');
    }
    return texts;
  }

  Widget _buildPipelineBar() {
    final steps = controller.steps;
    if (steps.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.wMin, vertical: 14.wMin),
      child: ManageUnitGrammarStepWidget(
        steps: steps.toList(),
        canRunStep: controller.canRunStep,
        getActionLabel: controller.getStepActionLabel,
        onTap: controller.runStep,
      ),
    );
  }
}
