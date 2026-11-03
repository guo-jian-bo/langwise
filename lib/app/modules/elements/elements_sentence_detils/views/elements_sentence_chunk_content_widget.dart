import 'dart:math' as math;

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../common/widgets/dialog_box_widget.dart';
import '../../../../../common/widgets/not_data_widget.dart';
import '../../../../../common/widgets/tap_scale_widget.dart';
import '../../../../../theme/theme.dart';
import 'elements_sentence_dialog_body_widget.dart';
import 'elements_sentence_chunk_layout_helper.dart';

class ElementsSentenceChunkContentWidget extends StatelessWidget {
  final EnSentenceStructureDetailEntity detils;
  final SentenceChunkAnalysisMode analysisMode;
  const ElementsSentenceChunkContentWidget({
    super.key,
    required this.detils,
    this.analysisMode = SentenceChunkAnalysisMode.chunking,
  });

  static const double _columnGap = 10;
  static const double _laneTrackHeight = 98;
  static const double _laneGap = 8;
  static const double _pillWidthSlack = 16;
  static const double _tokenWidthSlack = 12;
  static const double _labelGap = 12;

  @override
  Widget build(BuildContext context) {
    if (Get.isRegistered<ConfigController>()) {
      return Obx(() {
        Get.find<ConfigController>().colorConfigs.value;
        return _buildContent(context);
      });
    }
    return _buildContent(context);
  }

  Widget _buildContent(BuildContext context) {
    final List<EnSentenceStructureToken> tokens = (detils.analysisData?.tokens ?? <EnSentenceStructureToken?>[])
        .whereType<EnSentenceStructureToken>()
        .toList()
      ..sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
    final List<EnSentenceStructureClause> clauses = (detils.analysisData?.clauses ?? <EnSentenceStructureClause?>[])
        .whereType<EnSentenceStructureClause>()
        .toList()
      ..sort((a, b) => (a.orderInSentence ?? 0).compareTo(b.orderInSentence ?? 0));
    if (tokens.isEmpty || clauses.isEmpty) {
      return NotDataWidget(
        message: analysisMode == SentenceChunkAnalysisMode.svoca ? '当前句子暂无成分数据' : '当前句子暂无语块数据',
      );
    }
    final Map<int, int> clauseOrderById = {
      for (final EnSentenceStructureClause clause in clauses)
        if (clause.clauseId != null) clause.clauseId!: clause.orderInSentence ?? 0,
    };
    final SentenceChunkLayoutResult layout = SentenceChunkLayoutHelper.build(
      sentence: detils.content,
      tokens: tokens,
      clauses: clauses,
      mode: analysisMode,
    );
    int? activeClauseId = clauses
        .firstWhere(
          (clause) => clause.clauseId != null,
          orElse: () => clauses.first,
        )
        .clauseId;
    String? selectedSegmentKey;
    int? focusedClauseId;
    int focusRequestId = 0;

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setSharedState) {
        return SingleChildScrollView(
          child: Column(
            children: [
              _buildGridCard(
                context,
                layout,
                clauseOrderById,
                activeClauseId: activeClauseId,
                selectedSegmentKey: selectedSegmentKey,
                onClauseSelect: (int? clauseId) {
                  if (clauseId == null) return;
                  setSharedState(() {
                    activeClauseId = clauseId;
                    focusedClauseId = clauseId;
                    focusRequestId += 1;
                  });
                },
                onSegmentTap: (SentenceChunkLayoutPill pill) async {
                  setSharedState(() {
                    selectedSegmentKey = pill.key;
                    if (pill.clauseId != null) {
                      activeClauseId = pill.clauseId;
                    }
                  });
                  await _openGridSegmentDialog(context, pill);
                  setSharedState(() {
                    selectedSegmentKey = null;
                  });
                },
              ),
              SizedBox(height: 16.wMin),
              _buildChunkStructureCard(
                sentence: detils.content,
                tokens: tokens,
                clauses: clauses,
                layout: layout,
                clauseOrderById: clauseOrderById,
                analysisMode: analysisMode,
                activeClauseId: activeClauseId,
                selectedSegmentKey: selectedSegmentKey,
                focusedClauseId: focusedClauseId,
                focusRequestId: focusRequestId,
                onClauseSelect: (int? clauseId) {
                  if (clauseId == null) return;
                  setSharedState(() {
                    activeClauseId = clauseId;
                  });
                },
                onSelectedSegmentChange: (String? key) {
                  setSharedState(() {
                    selectedSegmentKey = key;
                  });
                },
              ),
                SizedBox(height: 120.wMin),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGridCard(
    BuildContext context,
    SentenceChunkLayoutResult layout,
    Map<int, int> clauseOrderById,
    {
    required int? activeClauseId,
    required String? selectedSegmentKey,
    required ValueChanged<int?> onClauseSelect,
    required Future<void> Function(SentenceChunkLayoutPill pill) onSegmentTap,
    }
  ) {
    final _ChunkGridMetrics gridMetrics = _buildGridMetrics(context, layout);
    final double labelWidth = _buildLabelWidth(context, layout.rows, clauseOrderById);
    final double canvasWidth = math.max(gridMetrics.canvasWidth, 1);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceTranslucentBase,
        borderRadius: BorderRadius.circular(24.wMin),
        border: Border.all(color: AppTheme.cBorderTranslucentThin, width: 1.wMin),
      ),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: labelWidth + canvasWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTokenRail(layout.columns, labelWidth, gridMetrics),
                SizedBox(height: 14.wMin),
                ..._buildGridRows(
                  context,
                  layout.rows,
                  clauseOrderById,
                  labelWidth,
                  gridMetrics,
                  canvasWidth,
                  activeClauseId: activeClauseId,
                  selectedSegmentKey: selectedSegmentKey,
                  onClauseSelect: onClauseSelect,
                  onSegmentTap: onSegmentTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTokenRail(
    List<SentenceChunkLayoutColumn> columns,
    double labelWidth,
    _ChunkGridMetrics gridMetrics,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: labelWidth),
        ...columns.asMap().entries.map((entry) {
          final int index = entry.key;
          final SentenceChunkLayoutColumn column = entry.value;
          return Padding(
            padding: EdgeInsets.only(
              right: index == columns.length - 1 ? 0 : _columnGap.wMin,
            ),
            child: SizedBox(
              width: gridMetrics.widths[index],
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.wMin),
                child: Text(
                  column.label,
                  maxLines: 1,
                  // softWrap: false,
                  style: TextStyle(
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cTextSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  _ChunkGridMetrics _buildGridMetrics(
    BuildContext context,
    SentenceChunkLayoutResult layout,
  ) {
    if (layout.columns.isEmpty) {
      return const _ChunkGridMetrics(
        widths: [],
        offsets: [],
        canvasWidth: 0,
      );
    }
    final TextScaler textScaler = MediaQuery.textScalerOf(context);
    final List<double> widths = layout.columns.map((column) {
      return _measureTextWidth(
            column.label,
            TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w500,
            ),
            textScaler: textScaler,
          ) +
          _tokenWidthSlack.wMin;
    }).toList();
    final List<SentenceChunkLayoutPill> pills = layout.rows.expand((row) => row.pills).toList()
      ..sort((a, b) {
        final int aSpan = a.endColumnIndex - a.startColumnIndex;
        final int bSpan = b.endColumnIndex - b.startColumnIndex;
        if (aSpan != bSpan) return aSpan.compareTo(bSpan);
        return a.startColumnIndex.compareTo(b.startColumnIndex);
      });
    for (final SentenceChunkLayoutPill pill in pills) {
      final double requiredWidth = _measureGridPillWidth(pill, textScaler);
      final int start = pill.startColumnIndex;
      final int end = pill.endColumnIndex;
      final double currentWidth = _spanWidth(widths, start, end);
      if (requiredWidth <= currentWidth) continue;
      final double extraWidth = (requiredWidth - currentWidth) / (end - start + 1);
      for (int index = start; index <= end; index++) {
        widths[index] += extraWidth;
      }
    }
    final List<double> offsets = [];
    double cursor = 0;
    for (int index = 0; index < widths.length; index++) {
      offsets.add(cursor);
      cursor += widths[index];
      if (index != widths.length - 1) {
        cursor += _columnGap.wMin;
      }
    }
    return _ChunkGridMetrics(
      widths: widths,
      offsets: offsets,
      canvasWidth: cursor,
    );
  }

  double _buildLabelWidth(
    BuildContext context,
    List<SentenceChunkLayoutRow> rows,
    Map<int, int> clauseOrderById,
  ) {
    final TextScaler textScaler = MediaQuery.textScalerOf(context);
    double maxWidth = 0;
    for (final SentenceChunkLayoutRow row in rows) {
      final double rowWidth = _measureRowLabelWidth(row, clauseOrderById, textScaler);
      if (rowWidth > maxWidth) {
        maxWidth = rowWidth;
      }
    }
    return maxWidth + _labelGap.wMin;
  }

  double _measureRowLabelWidth(
    SentenceChunkLayoutRow row,
    Map<int, int> clauseOrderById,
    TextScaler textScaler,
  ) {
    if (row.kind == SentenceChunkLayoutRowKind.residual) {
      return _measureChipWidth(
        '余文',
        fontSize: 18.wMin,
        fontWeight: FontWeight.w600,
        horizontalPadding: 12.wMin,
        borderWidth: 0.8.wMin,
        textScaler: textScaler,
      );
    }
    if (row.kind == SentenceChunkLayoutRowKind.conjunction) {
      return _measureChipWidth(
        '连接',
        fontSize: 18.wMin,
        fontWeight: FontWeight.w700,
        horizontalPadding: 12.wMin,
        borderWidth: 1.wMin,
        textScaler: textScaler,
      );
    }
    final EnSentenceStructureClause? clause = row.clause;
    if (clause == null) return 0;
    final String orderText = '${clause.orderInSentence ?? 0}';
    final int? parentOrder = clauseOrderById[clause.parentClauseId];
    final String relationText = parentOrder != null ? ' ↳ $parentOrder' : '';
    final double orderChipWidth = _measureChipWidth(
      orderText,
      fontSize: 18.wMin,
      fontWeight: FontWeight.w700,
      horizontalPadding: 12.wMin,
      borderWidth: 1.wMin,
      textScaler: textScaler,
    );
    final double relationWidth = relationText.isEmpty
        ? 0
        : _measureTextWidth(
              relationText,
              TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w500,
              ),
              textScaler: textScaler,
            );
    final double typeChipWidth = _measureChipWidth(
      _clauseTypeLabelText(clause.type),
      fontSize: 18.wMin,
      fontWeight: FontWeight.w600,
      horizontalPadding: 12.wMin,
      borderWidth: 1.wMin,
      textScaler: textScaler,
    );
    return orderChipWidth + relationWidth + 8.wMin + typeChipWidth;
  }

  double _measureChipWidth(
    String text, {
    required double fontSize,
    required FontWeight fontWeight,
    required double horizontalPadding,
    required double borderWidth,
    required TextScaler textScaler,
  }) {
    return _measureTextWidth(
          text,
          TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
          textScaler: textScaler,
        ) +
        horizontalPadding * 2 +
        borderWidth * 2;
  }

  double _measureGridPillWidth(
    SentenceChunkLayoutPill pill,
    TextScaler textScaler,
  ) {
      final _ChunkPalette palette = _gridPillPalette(pill);
      final double labelWidth = _measureTextWidth(
        _gridPillLabelText(pill),
      TextStyle(
        fontSize: 18.wMin,
        fontWeight: FontWeight.w500,
        color: palette.label.withValues(alpha: 0.45),
      ),
      textScaler: textScaler,
    );
    final double textWidth = _measureTextWidth(
      pill.text,
      TextStyle(
        fontSize: 28.wMin,
        fontWeight: FontWeight.w500,
        color: palette.label,
      ),
      textScaler: textScaler,
    );
    return math.max(labelWidth, textWidth) + 28.wMin + _pillWidthSlack.wMin;
  }

  double _measureTextWidth(
    String text,
    TextStyle style, {
    required TextScaler textScaler,
  }) {
    if (text.isEmpty) return 0;
    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: text,
        style: style,
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      textScaler: textScaler,
    )..layout();
    return painter.width.ceilToDouble() + 1;
  }

  double _spanWidth(
    List<double> widths,
    int start,
    int end,
  ) {
    double total = 0;
    for (int index = start; index <= end; index++) {
      total += widths[index];
    }
    total += (end - start) * _columnGap.wMin;
    return total;
  }

  List<Widget> _buildGridRows(
    BuildContext context,
    List<SentenceChunkLayoutRow> rows,
    Map<int, int> clauseOrderById,
    double labelWidth,
    _ChunkGridMetrics gridMetrics,
    double canvasWidth,
    {
    required int? activeClauseId,
    required String? selectedSegmentKey,
    required ValueChanged<int?> onClauseSelect,
    required Future<void> Function(SentenceChunkLayoutPill pill) onSegmentTap,
    }
  ) {
    final List<Widget> widgets = [];
    for (final SentenceChunkLayoutRow row in rows) {
      final List<List<_ChunkLaneItem>> lanes = _buildRowLanes(row.pills);
      final double laneTrackHeight = _laneTrackHeight.wMin;
      final double laneGap = _laneGap.wMin;
      final double rowHeight = math.max(lanes.length, 1) * laneTrackHeight + math.max(lanes.length - 1, 0) * laneGap;
      widgets.add(
        Padding(
          padding: EdgeInsets.only(bottom: 16.wMin),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: labelWidth,
                child: Padding(
                  padding: EdgeInsets.only(right: 12.wMin),
                  child: _buildRowLabel(
                    row,
                    clauseOrderById,
                    activeClauseId: activeClauseId,
                    onClauseSelect: onClauseSelect,
                  ),
                ),
              ),
              SizedBox(
                width: canvasWidth,
                height: rowHeight,
                child: Stack(
                  children: [
                    for (int laneIndex = 0; laneIndex < lanes.length; laneIndex++)
                      for (final _ChunkLaneItem item in lanes[laneIndex])
                        Positioned(
                          left: gridMetrics.offsets[item.start],
                          top: laneIndex * (laneTrackHeight + laneGap),
                          width: _spanWidth(gridMetrics.widths, item.start, item.end),
                          child: _buildGridPill(
                            context,
                            item.pill,
                            isSelected: selectedSegmentKey == item.pill.key,
                            onTap: () => onSegmentTap(item.pill),
                          ),
                        ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return widgets;
  }

  Widget _buildRowLabel(
    SentenceChunkLayoutRow row,
    Map<int, int> clauseOrderById,
    {
    required int? activeClauseId,
    required ValueChanged<int?> onClauseSelect,
    }
  ) {
    if (row.kind == SentenceChunkLayoutRowKind.residual) {
      return _buildResidualLabel();
    }
    if (row.kind == SentenceChunkLayoutRowKind.conjunction) {
      return _buildConjunctionLabel();
    }
    final EnSentenceStructureClause? clause = row.clause;
    if (clause == null) return const SizedBox.shrink();
    return _buildClauseLabel(
      clause,
      parentOrder: clauseOrderById[clause.parentClauseId],
      isActive: clause.clauseId != null && clause.clauseId == activeClauseId,
      onTap: () => onClauseSelect(clause.clauseId),
    );
  }

  Widget _buildClauseLabel(
    EnSentenceStructureClause clause, {
    int? parentOrder,
    required bool isActive,
    VoidCallback? onTap,
  }) {
    final String orderText = '${clause.orderInSentence ?? 0}';
    final String relationText = parentOrder != null ? ' ↳ $parentOrder' : '';
    final _ChunkPalette clausePalette = _clauseTypePalette(clause.type);
    final Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 6.wMin),
          decoration: BoxDecoration(
            color: _clauseIndexBadgeBackgroundColor(isActive),
            borderRadius: BorderRadius.circular(999.wMin),
            border: Border.all(
              color: _clauseIndexBadgeBorderColor(isActive),
              width: 1.wMin,
            ),
          ),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                    text: orderText,
                  style: TextStyle(
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w500,
                    color: _clauseIndexBadgeLableColor(isActive),
                  ),
                ),
                if (parentOrder != null)
                  TextSpan(
                      text: relationText,
                    style: TextStyle(
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w500,
                      color: _clauseIndexBadgeLableSubColor(isActive),
                    ),
                  ),
              ],
            ),
          ),
        ),
        SizedBox(width: 8.wMin),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 6.wMin),
          decoration: BoxDecoration(
            color: clausePalette.background,
            borderRadius: BorderRadius.circular(6.wMin),
            border: Border.all(
              color: clausePalette.border,
              width: 1.wMin,
            ),
          ),
          child: Text(
            _clauseTypeLabelText(clause.type),
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w600,
              color: clausePalette.label,
            ),
          ),
        ),
      ],
    );
    if (onTap == null) return child;
    return TapScaleWidget(
      sclae: 1.01,
      onTap: onTap,
      child: child,
    );
  }

  Widget _buildConjunctionLabel() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 6.wMin),
        decoration: BoxDecoration(
          color: AppTheme.cFeedbackWarningBg.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999.wMin),
          border: Border.all(
            color: AppTheme.cFeedbackWarningBg.withValues(alpha: 0.20),
            width: 1.wMin,
          ),
        ),
        child: Text(
          '连接',
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w700,
            color: AppTheme.cFeedbackWarningBg,
          ),
        ),
      ),
    );
  }

  Widget _buildResidualLabel() {
    return DottedBorder(
      color: AppTheme.cBorderTranslucentThin.color,
      strokeWidth: 0.8.wMin,
      dashPattern: [3.wMin, 1.5.wMin],
      borderType: BorderType.RRect,
      radius: Radius.circular(999.wMin),
      padding: EdgeInsets.zero,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 6.wMin),
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceTranslucentElevated.color,
          borderRadius: BorderRadius.circular(999.wMin),
        ),
        child: Text(
          '余文',
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w600,
            color: AppTheme.cTextPrimary,
          ),
        ),
      ),
    );
  }

  List<List<_ChunkLaneItem>> _buildRowLanes(List<SentenceChunkLayoutPill> pills) {
    final List<_ChunkLaneItem> items = pills.map((pill) {
      return _ChunkLaneItem(
        start: pill.startColumnIndex,
        end: pill.endColumnIndex,
        span: pill.endColumnIndex - pill.startColumnIndex + 1,
        type: pill.sourceType,
        surface: pill.text,
        pill: pill,
      );
    }).toList()
      ..sort((a, b) {
        if (a.start != b.start) return a.start.compareTo(b.start);
        return a.end.compareTo(b.end);
      });
    final List<List<_ChunkLaneItem>> lanes = [];
    for (final _ChunkLaneItem item in items) {
      bool placed = false;
      for (final List<_ChunkLaneItem> lane in lanes) {
        final _ChunkLaneItem last = lane.last;
        if (item.start > last.end) {
          lane.add(item);
          placed = true;
          break;
        }
      }
      if (!placed) {
        lanes.add([item]);
      }
    }
    return lanes;
  }

  Widget _buildGridPill(
    BuildContext context,
    SentenceChunkLayoutPill pill,
    {
    required bool isSelected,
    required VoidCallback onTap,
    }
  ) {
    final _ChunkPalette palette = _gridPillPalette(pill);
    final Widget content = Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: _laneTrackHeight.wMin),
      padding: EdgeInsets.symmetric(horizontal: 14.wMin, vertical: 8.wMin),
        decoration: BoxDecoration(
          color: palette.background,
          borderRadius: BorderRadius.circular(16.wMin),
          border:  Border.all(
                color:  palette.border,
                width: 0.8.wMin,
              ),
        ),
        child: _buildGridItemContent(
          label: _gridPillLabelText(pill),
        text: pill.text,
        primaryColor: palette.label,
      ),
    );
    final Widget decoratedContent = !palette.isDotted
        ? content
        : DottedBorder(
      color: palette.border,
      strokeWidth: 0.8.wMin,
      dashPattern: [3.wMin, 1.5.wMin],
      borderType: BorderType.RRect,
      radius: Radius.circular(16.wMin),
      padding: EdgeInsets.zero,
      child: content,
    );
    return TapScaleWidget(
      sclae: 1.01,
      onTap: onTap,
      child: decoratedContent,
    );
  }

  _ChunkPalette _gridPillPalette(SentenceChunkLayoutPill pill) {
    if (pill.kind == SentenceChunkLayoutPillKind.conjunction) {
      return _ChunkPalette(
        background: AppTheme.cFeedbackWarningBg.withValues(alpha: 0.12),
        border: AppTheme.cFeedbackWarningBg.withValues(alpha: 0.30),
        label: AppTheme.cFeedbackWarningBg,
      );
    }
    if (pill.kind == SentenceChunkLayoutPillKind.residual) {
      return _ChunkPalette(
        background: AppTheme.cSurfaceTranslucentElevated.color,
        border: AppTheme.cBorderTranslucentThin.color,
        label: AppTheme.cTextPrimary.color,
        isDotted: true,
      );
    }
    if (analysisMode == SentenceChunkAnalysisMode.svoca) {
      return _svocaPaletteForType(pill.sourceType);
    }
    return _chunkPaletteForPill(pill);
  }

  String _gridPillLabelText(SentenceChunkLayoutPill pill) {
    if (pill.kind == SentenceChunkLayoutPillKind.conjunction ||
        pill.kind == SentenceChunkLayoutPillKind.residual) {
      return pill.label;
    }
    if (analysisMode == SentenceChunkAnalysisMode.svoca) {
      return _svocaGridPillLabelText(pill);
    }
    final List<EnSentenceStructureClause> clauses =
        (detils.analysisData?.clauses ?? <EnSentenceStructureClause?>[]).whereType<EnSentenceStructureClause>().toList();
    final EnSentenceStructureClause clause = clauses.firstWhere(
      (item) => item.clauseId == pill.clauseId,
      orElse: () => EnSentenceStructureClause(),
    );
    final List<EnSentenceStructureChunking> chunkings =
        (clause.chunking ?? <EnSentenceStructureChunking?>[]).whereType<EnSentenceStructureChunking>().toList();
    for (final EnSentenceStructureChunking chunk in chunkings) {
      if ((chunk.textReference?.start ?? 0) == pill.startTokenId &&
          (chunk.textReference?.end ?? 0) == pill.endTokenId &&
          (chunk.type ?? '') == pill.sourceType) {
        return _languageTextZh(
          chunk.chunkType?.name,
          fallback: chunk.type ?? pill.label,
        );
      }
    }
    return pill.label;
  }

  Widget _buildGridItemContent({
    required String label,
    required String text,
    required Color primaryColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            Text(
              label,
              softWrap: false,
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextSecondary.color,
              ),
            ),
            Text(
              label,
              softWrap: false,
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w500,
                color: primaryColor.withValues(alpha: 0.45),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.wMin),
        Stack(
          children: [
            Text(
              text,
              softWrap: false,
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
            Text(
              text,
              softWrap: false,
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w500,
                color: primaryColor.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChunkStructureCard({
    required String? sentence,
    required List<EnSentenceStructureToken> tokens,
    required List<EnSentenceStructureClause> clauses,
    required SentenceChunkLayoutResult layout,
    required Map<int, int> clauseOrderById,
    required SentenceChunkAnalysisMode analysisMode,
    required int? activeClauseId,
    required String? selectedSegmentKey,
    required int? focusedClauseId,
    required int focusRequestId,
    required ValueChanged<int?> onClauseSelect,
    required ValueChanged<String?> onSelectedSegmentChange,
  }) {
    return _ChunkBracketSection(
      sentence: sentence,
      tokens: tokens,
      clauses: clauses,
      layout: layout,
      clauseOrderById: clauseOrderById,
      analysisMode: analysisMode,
      activeClauseId: activeClauseId,
      selectedSegmentKey: selectedSegmentKey,
      focusedClauseId: focusedClauseId,
      focusRequestId: focusRequestId,
      onClauseSelect: onClauseSelect,
      onSelectedSegmentChange: onSelectedSegmentChange,
    );
  }

  _ChunkPalette _chunkPaletteForPill(SentenceChunkLayoutPill pill) {
    return _chunkPaletteForType(pill.sourceType);
  }

  Future<void> _openGridSegmentDialog(
    BuildContext context,
    SentenceChunkLayoutPill pill,
  ) {
    final bool isResidual = pill.kind == SentenceChunkLayoutPillKind.residual;
    final List<LanguageText?> descriptions = isResidual ? const [] : _findGridPillDescriptions(pill);
    final _ChunkPalette palette = _gridPillPalette(pill);
    final String zhText = isResidual
        ? (analysisMode == SentenceChunkAnalysisMode.svoca
            ? '原句中未被当前 SVOCA 分析标注的部分。'
            : '原句中未被当前语块分析标注的部分。')
        : _descriptionTextForLang(descriptions, 'zh');
    final String enText = isResidual
        ? (analysisMode == SentenceChunkAnalysisMode.svoca
            ? 'This part is not annotated in the current SVOCA analysis.'
            : 'This part is not annotated in the current chunk analysis.')
        : _descriptionTextForLang(descriptions, 'en');
    return showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return DialogUserWidget(
          title: '片段详情',
          width: 960.wMin,
          physics: const ClampingScrollPhysics(),
          child: ElementsSentenceDialogBodyWidget(
            chipText: _gridDialogChipText(pill),
            titleText: pill.text,
            chipTextColor: palette.label,
            chipBackground: palette.background,
            chipBorderColor: palette.border,
            zhText: zhText,
            enText: enText,
          ),
        );
      },
    );
  }

  List<LanguageText?> _findGridPillDescriptions(SentenceChunkLayoutPill pill) {
    final List<EnSentenceStructureClause> clauses =
        (detils.analysisData?.clauses ?? <EnSentenceStructureClause?>[]).whereType<EnSentenceStructureClause>().toList();
    final EnSentenceStructureClause clause = clauses.firstWhere(
      (item) => item.clauseId == pill.clauseId,
      orElse: () => EnSentenceStructureClause(),
    );
    if (pill.kind == SentenceChunkLayoutPillKind.conjunction) {
      final List<EnSentenceStructureConjunction> conjunctions =
          (clause.conjunctions ?? <EnSentenceStructureConjunction?>[]).whereType<EnSentenceStructureConjunction>().toList();
      for (final EnSentenceStructureConjunction conjunction in conjunctions) {
        if ((conjunction.textReference?.start ?? 0) == pill.startTokenId &&
            (conjunction.textReference?.end ?? 0) == pill.endTokenId) {
          return conjunction.descriptions ?? const [];
        }
      }
      return const [];
    }
    if (analysisMode == SentenceChunkAnalysisMode.svoca) {
      final List<EnSentenceStructureSvocaElement> elements =
          (clause.svoca?.elements ?? <EnSentenceStructureSvocaElement?>[])
              .whereType<EnSentenceStructureSvocaElement>()
              .toList();
      for (final EnSentenceStructureSvocaElement element in elements) {
        if ((element.textReference?.start ?? 0) == pill.startTokenId &&
            (element.textReference?.end ?? 0) == pill.endTokenId &&
            (element.typeNid ?? '') == pill.sourceType) {
          return _svocaElementPopupDescriptions(element);
        }
      }
      return const [];
    }
    final List<EnSentenceStructureChunking> chunkings =
        (clause.chunking ?? <EnSentenceStructureChunking?>[]).whereType<EnSentenceStructureChunking>().toList();
    for (final EnSentenceStructureChunking chunk in chunkings) {
      if ((chunk.textReference?.start ?? 0) == pill.startTokenId &&
          (chunk.textReference?.end ?? 0) == pill.endTokenId &&
          (chunk.type ?? '') == pill.sourceType) {
        return chunk.descriptions ?? const [];
      }
    }
    return const [];
  }

  String _gridDialogChipText(SentenceChunkLayoutPill pill) {
    if (pill.kind == SentenceChunkLayoutPillKind.conjunction ||
        pill.kind == SentenceChunkLayoutPillKind.residual) {
      return pill.label;
    }
    if (analysisMode == SentenceChunkAnalysisMode.svoca) {
      final List<EnSentenceStructureClause> clauses =
          (detils.analysisData?.clauses ?? <EnSentenceStructureClause?>[]).whereType<EnSentenceStructureClause>().toList();
      final EnSentenceStructureClause clause = clauses.firstWhere(
        (item) => item.clauseId == pill.clauseId,
        orElse: () => EnSentenceStructureClause(),
      );
      final List<EnSentenceStructureSvocaElement> elements =
          (clause.svoca?.elements ?? <EnSentenceStructureSvocaElement?>[])
              .whereType<EnSentenceStructureSvocaElement>()
              .toList();
      for (final EnSentenceStructureSvocaElement element in elements) {
        if ((element.textReference?.start ?? 0) == pill.startTokenId &&
            (element.textReference?.end ?? 0) == pill.endTokenId &&
            (element.typeNid ?? '') == pill.sourceType) {
          return _compactBilingualText(
            element.type?.name,
            fallback: element.typeNid ?? pill.sourceType,
          );
        }
      }
      return pill.sourceType;
    }
    final List<EnSentenceStructureClause> clauses =
        (detils.analysisData?.clauses ?? <EnSentenceStructureClause?>[]).whereType<EnSentenceStructureClause>().toList();
    final EnSentenceStructureClause clause = clauses.firstWhere(
      (item) => item.clauseId == pill.clauseId,
      orElse: () => EnSentenceStructureClause(),
    );
    final List<EnSentenceStructureChunking> chunkings =
        (clause.chunking ?? <EnSentenceStructureChunking?>[]).whereType<EnSentenceStructureChunking>().toList();
    for (final EnSentenceStructureChunking chunk in chunkings) {
      if ((chunk.textReference?.start ?? 0) == pill.startTokenId &&
          (chunk.textReference?.end ?? 0) == pill.endTokenId &&
          (chunk.type ?? '') == pill.sourceType) {
        return _compactBilingualText(
          chunk.chunkType?.name,
          fallback: chunk.type ?? pill.label,
        );
      }
    }
    return pill.label;
  }

  String _svocaGridPillLabelText(SentenceChunkLayoutPill pill) {
    final List<EnSentenceStructureClause> clauses =
        (detils.analysisData?.clauses ?? <EnSentenceStructureClause?>[]).whereType<EnSentenceStructureClause>().toList();
    final EnSentenceStructureClause clause = clauses.firstWhere(
      (item) => item.clauseId == pill.clauseId,
      orElse: () => EnSentenceStructureClause(),
    );
    final List<EnSentenceStructureSvocaElement> elements =
        (clause.svoca?.elements ?? <EnSentenceStructureSvocaElement?>[])
            .whereType<EnSentenceStructureSvocaElement>()
            .toList();
    for (final EnSentenceStructureSvocaElement element in elements) {
        if ((element.textReference?.start ?? 0) == pill.startTokenId &&
            (element.textReference?.end ?? 0) == pill.endTokenId &&
            (element.typeNid ?? '') == pill.sourceType) {
          final String text = _languageTextZh(
            element.type?.name,
            fallback: element.typeNid ?? pill.sourceType,
          );
        if (text.isNotEmpty) return text;
      }
    }
      return pill.sourceType;
  }
}

class _ChunkBracketSection extends StatefulWidget {
  final String? sentence;
  final List<EnSentenceStructureToken> tokens;
  final List<EnSentenceStructureClause> clauses;
  final SentenceChunkLayoutResult layout;
  final Map<int, int> clauseOrderById;
  final SentenceChunkAnalysisMode analysisMode;
  final int? activeClauseId;
  final String? selectedSegmentKey;
  final int? focusedClauseId;
  final int focusRequestId;
  final ValueChanged<int?> onClauseSelect;
  final ValueChanged<String?> onSelectedSegmentChange;

  const _ChunkBracketSection({
    required this.sentence,
    required this.tokens,
    required this.clauses,
    required this.layout,
    required this.clauseOrderById,
    required this.analysisMode,
    required this.activeClauseId,
    required this.selectedSegmentKey,
    required this.focusedClauseId,
    required this.focusRequestId,
    required this.onClauseSelect,
    required this.onSelectedSegmentChange,
  });

  @override
  State<_ChunkBracketSection> createState() => _ChunkBracketSectionState();
}

class _ChunkBracketSectionState extends State<_ChunkBracketSection> {
  final Map<String, bool> _expanded = {};
  final Map<int, GlobalKey> _clauseAnchorKeys = {};

  @override
  void didUpdateWidget(covariant _ChunkBracketSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusRequestId == oldWidget.focusRequestId) return;
    _focusClause(widget.focusedClauseId);
  }

  bool _isExpanded(String id) => _expanded[id] ?? true;

  GlobalKey _clauseAnchorKey(int clauseId) {
    return _clauseAnchorKeys.putIfAbsent(clauseId, () => GlobalKey());
  }

  void _toggleExpanded(String id) {
    setState(() {
      _expanded[id] = !(_expanded[id] ?? true);
    });
  }

  void _focusClause(int? clauseId) {
    if (clauseId == null) return;
    final EnSentenceStructureClause? clause = widget.clauses.where((item) => item.clauseId == clauseId).firstOrNull;
    if (clause == null) return;
    final String headerId = 'clause-head-${clause.clauseId ?? clause.orderInSentence ?? 0}';
    setState(() {
      _expanded[headerId] = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final BuildContext? targetContext = _clauseAnchorKey(clauseId).currentContext;
      if (targetContext == null) return;
      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        alignment: 0.08,
      );
    });
  }

  void _selectClause(int? clauseId) {
    if (clauseId == null) return;
    widget.onClauseSelect(clauseId);
  }

  Future<void> _openSegmentDialog(_SegmentPopupData popup) async {
    widget.onSelectedSegmentChange(popup.key);
    if (popup.clauseId != null) {
      widget.onClauseSelect(popup.clauseId);
    }
    await _showElementsStyleDialog(
      title: '语块详情',
      chipText: popup.label,
      chipTextColor: popup.palette.label,
      chipBackground: popup.palette.background,
      chipBorderColor: popup.palette.border,
      zhText: _popupDescriptionText(popup, 'zh'),
      enText: _popupDescriptionText(popup, 'en'),
    );
    if (!mounted) return;
    widget.onSelectedSegmentChange(null);
  }

  String _popupDescriptionText(_SegmentPopupData popup, String lang) {
    if (popup.isResidual) {
      if (widget.analysisMode == SentenceChunkAnalysisMode.svoca) {
        return lang == 'zh'
            ? '原句中未被当前 SVOCA 分析标注的部分。'
            : 'This part is not annotated in the current SVOCA analysis.';
      }
      return lang == 'zh'
          ? '原句中未被当前语块分析标注的部分。'
          : 'This part is not annotated in the current chunk analysis.';
    }
    return _descriptionTextForLang(
      popup.descriptions,
      lang,
      emptyText: lang == 'zh' ? '无详细描述' : 'No detailed description.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceTranslucentBase,
        borderRadius: BorderRadius.circular(24.wMin),
        border: Border.all(color: AppTheme.cBorderTranslucentThin, width: 1.wMin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.analysisMode == SentenceChunkAnalysisMode.svoca ? '成分结构（点击展开/折叠）' : '句法结构（点击展开/折叠）',
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w700,
              color: AppTheme.cTextPrimary,
            ),
          ),
          SizedBox(height: 12.wMin),
          ...widget.layout.rows.asMap().entries.map((entry) {
            final SentenceChunkLayoutRow row = entry.value;
            if (row.kind == SentenceChunkLayoutRowKind.residual) {
              return _buildResidualRow(row, entry.key);
            }
            if (row.kind == SentenceChunkLayoutRowKind.conjunction) {
              return _buildConjunctionRow(row, entry.key);
            }
            return _buildClauseRow(row);
          }),
        ],
      ),
    );
  }

  Widget _buildResidualRow(
    SentenceChunkLayoutRow row,
    int index,
  ) {
    final SentenceChunkLayoutPill? pill = row.pills.isEmpty ? null : row.pills.first;
    return Padding(
      padding: EdgeInsets.only(left: row.depth * 16.wMin, bottom: 10.wMin),
      child: Container(
        padding: EdgeInsets.all(14.wMin),
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceTranslucentElevated.color,
          borderRadius: BorderRadius.circular(18.wMin),
          border: Border.all(
            color: AppTheme.cBorderTranslucentThin.color,
            width: 1.wMin,
          ),
        ),
        child: pill == null
            ? const SizedBox.shrink()
            : _buildResidualInlineCard(
                label: pill.label,
                text: pill.text,
              ),
      ),
    );
  }

  Widget _buildConjunctionRow(
    SentenceChunkLayoutRow row,
    int index,
  ) {
    final SentenceChunkLayoutPill? pill = row.pills.isEmpty ? null : row.pills.first;
    return Padding(
      padding: EdgeInsets.only(left: row.depth * 16.wMin, bottom: 10.wMin),
      child: Container(
        padding: EdgeInsets.all(14.wMin),
        decoration: BoxDecoration(

          borderRadius: BorderRadius.circular(18.wMin),
          border: Border.all(
            color: const Color(0xFFF97316).withValues(alpha: 0.26),
            width: 1.wMin,
          ),
        ),
        child: pill == null
            ? const SizedBox.shrink()
            : _buildTapSegmentCard(
                popup: _popupFromPill(pill),
                card: _buildSegmentDetailCard(
                  label: '连接词',
                  surfaceText: pill.text,
                  descriptions: row.conjunction?.descriptions ?? const [],
                  palette: _paletteFromPill(pill),
                  isResidual: false,
                  isConjunction: true,
                  isSelected: widget.selectedSegmentKey == pill.key,
                  showDescriptions: true,
                ),
              ),
      ),
    );
  }

  Widget _buildClauseRow(SentenceChunkLayoutRow row) {
    final EnSentenceStructureClause? clause = row.clause;
    if (clause == null) return const SizedBox.shrink();
    final String headerId = 'clause-head-${clause.clauseId ?? clause.orderInSentence ?? 0}';
    final bool expanded = _isExpanded(headerId);
    final bool isActive = clause.clauseId != null && clause.clauseId == widget.activeClauseId;
    final int? parentOrder = widget.clauseOrderById[clause.parentClauseId];
    final List<_ChunkTreeNodeData> treeNodes =
        widget.analysisMode == SentenceChunkAnalysisMode.chunking ? _buildChunkTree(clause) : const [];
    final List<SentenceChunkLayoutPill> analysisPills =
        row.pills.where((pill) => pill.kind == SentenceChunkLayoutPillKind.analysis).toList();
    final List<SentenceChunkLayoutPill> residualPills =
        row.pills.where((pill) => pill.kind == SentenceChunkLayoutPillKind.residual).toList();
    final List<Widget> orderedChunkContentWidgets = _buildOrderedChunkContentWidgets(
      treeNodes: treeNodes,
      residualPills: residualPills,
    );
    final List<Widget> orderedSvocaContentWidgets = _buildOrderedSvocaContentWidgets(
      analysisPills: analysisPills,
      residualPills: residualPills,
    );
    return Padding(
      key: clause.clauseId == null ? null : _clauseAnchorKey(clause.clauseId!),
      padding: EdgeInsets.only(left: row.depth * 16.wMin, bottom: 10.wMin),
      child: Container(
        padding: EdgeInsets.all(14.wMin),
        decoration: BoxDecoration(
        
          borderRadius: BorderRadius.circular(18.wMin),
          border: Border.all(
            color: isActive ? AppTheme.cSurfaceBrand.withValues(alpha: 0.30) : AppTheme.cBorderTranslucentThin.color,
            width: 1.wMin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TapScaleWidget(
              sclae: 1.00,
              onTap: () {
                _selectClause(clause.clauseId);
                _toggleExpanded(headerId);
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 2.wMin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          expanded ? '▼' : '▶',
                          style: TextStyle(
                            fontSize: 14.wMin,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.cTextSecondary,
                          ),
                        ),
                        SizedBox(width: 8.wMin),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 6.wMin),
                          decoration: BoxDecoration(
                            color: _clauseIndexBadgeBackgroundColor(isActive),
                            borderRadius: BorderRadius.circular(999.wMin),
                            border: Border.all(
                              color: _clauseIndexBadgeBorderColor(isActive),
                              width: 1.wMin,
                            ),
                          ),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${clause.orderInSentence ?? 0}',
                                  style: TextStyle(
                                    fontSize: 18.wMin,
                                    fontWeight: FontWeight.w500,
                                    color: _clauseIndexBadgeLableColor(isActive),
                                  ),
                                ),
                                if (parentOrder != null)
                                  TextSpan(
                                    text: ' ↳$parentOrder',
                                    style: TextStyle(
                                      fontSize: 16.wMin,
                                      fontWeight: FontWeight.w500,
                                      color: _clauseIndexBadgeLableSubColor(isActive),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 8.wMin),
                        Flexible(
                          child: Wrap(
                            spacing: 8.wMin,
                            runSpacing: 8.wMin,
                            children: [
                              _buildMetaChip(
                                text: _clauseTypeLabelText(clause.type),
                                textColor: _clauseTypePalette(clause.type).label,
                                background: _clauseTypePalette(clause.type).background,
                                borderColor: _clauseTypePalette(clause.type).border,
                              ),
                              ..._buildFeatureChips(clause),
                            ],
                          ),
                        ),
                      ],
                    ),
                
                
                  ],
                ),
              ),
            ),
            if (expanded) ...[
              SizedBox(height: 12.wMin),
              if (widget.analysisMode == SentenceChunkAnalysisMode.svoca) ...[
                _buildSvocaPatternCard(clause),//NEXT: 显示成分
                ...orderedSvocaContentWidgets,
              ],
              if (widget.analysisMode == SentenceChunkAnalysisMode.chunking &&
                  treeNodes.isEmpty &&
                  residualPills.isEmpty)
                Padding(
                  padding: EdgeInsets.only(left: 2.wMin),
                  child: Text(
                    '无可用的语块',
                    style: TextStyle(
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.cTextSecondary,
                    ),
                  ),
                ),
              if (widget.analysisMode == SentenceChunkAnalysisMode.svoca &&
                  analysisPills.isEmpty &&
                  residualPills.isEmpty)
                Padding(
                  padding: EdgeInsets.only(left: 2.wMin),
                  child: Text(
                    '无可用的成分',
                    style: TextStyle(
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.cTextSecondary,
                    ),
                  ),
                ),
              if (widget.analysisMode == SentenceChunkAnalysisMode.chunking) ...orderedChunkContentWidgets,
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFeatureChips(EnSentenceStructureClause clause) {
    final List<Widget> chips = [];
    final List<EnSentenceStructureGrammarFeature> grammarFeatures =
        (clause.grammaticalFeatures ?? <EnSentenceStructureGrammarFeature?>[]).whereType<EnSentenceStructureGrammarFeature>().toList();
    for (final EnSentenceStructureGrammarFeature feature in grammarFeatures) {
      final LanguageConfigColorEntityInfo? config = _grammarFeatureConfig(feature);
      final String name = _grammarFeatureLabelText(feature, config);
      if (name.isEmpty) continue;
      final _ChunkPalette palette = _grammarFeaturePalette(config);
      chips.add(
        _buildMetaChip(
          text: name,
          textColor: palette.label,
          background: palette.background,
          borderColor: palette.border,
          onTap: (feature.feature?.description ?? feature.descriptions ?? const []).isEmpty
              ? null
              : () => _openMetaDialog(
                    chipText: name,
                    chipTextColor: palette.label,
                    chipBackground: palette.background,
                    chipBorderColor: palette.border,
                    descriptions: feature.feature?.description ?? feature.descriptions ?? const [],
                  ),
        ),
      );
    }
    final List<EnSentenceStructureSpecialClauseFeature> specialClauseFeatures =
        (clause.specialClauseFeatures ?? <EnSentenceStructureSpecialClauseFeature?>[])
            .whereType<EnSentenceStructureSpecialClauseFeature>()
            .toList();
    for (final EnSentenceStructureSpecialClauseFeature feature in specialClauseFeatures) {
      final LanguageConfigColorEntityInfo? config = _specialClauseFeatureConfig(feature);
      final String name = _specialClauseFeatureLabelText(feature, config);
      if (name.isEmpty) continue;
      final _ChunkPalette palette = _grammarFeaturePalette(config);
      chips.add(
        _buildMetaChip(
          text: name,
          textColor: palette.label,
          background: palette.background,
          borderColor: palette.border,
          onTap: (feature.descriptions ?? const []).isEmpty
              ? null
              : () => _openMetaDialog(
                    chipText: name,
                    chipTextColor: palette.label,
                    chipBackground: palette.background,
                    chipBorderColor: palette.border,
                    descriptions: feature.descriptions ?? const [],
                  ),
        ),
      );
    }
    return chips;
  }

  Future<void> _openMetaDialog({
    required String chipText,
    required Color chipTextColor,
    required Color chipBackground,
    required Color chipBorderColor,
    required List<LanguageText?> descriptions,
  }) {
    return _showElementsStyleDialog(
      title: '句法结构详情',
      chipText: chipText,
      chipTextColor: chipTextColor,
      chipBackground: chipBackground,
      chipBorderColor: chipBorderColor,
      zhText: _descriptionTextForLang(descriptions, 'zh'),
      enText: _descriptionTextForLang(descriptions, 'en'),
    );
  }

  Future<T?> _showElementsStyleDialog<T>({
    required String title,
    required String chipText,
    required Color chipTextColor,
    required Color chipBackground,
    required Color chipBorderColor,
    required String zhText,
    required String enText,
  }) {
    return showCupertinoDialog<T>(
      context: context,
      builder: (BuildContext dialogContext) {
        return DialogUserWidget(
          title: title,
          width: 960.wMin,
          physics: const ClampingScrollPhysics(),
            child: ElementsSentenceDialogBodyWidget(
            chipText: chipText,
            chipTextColor: chipTextColor,
            chipBackground: chipBackground,
            chipBorderColor: chipBorderColor,
            zhText: zhText,
            enText: enText,
          ),
        );
      },
    );
  }

  Widget _buildMetaChip({
    required String text,
    required Color textColor,
    required Color background,
    required Color borderColor,
    VoidCallback? onTap,
  }) {
    final Widget child = Container(
      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 6.wMin),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6.wMin),
        border: Border.all(color: borderColor, width: 1.wMin),
      ),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 18.wMin,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
    if (onTap == null) return child;
    return TapScaleWidget(
      sclae: 1.01,
      onTap: onTap,
      child: child,
    );
  }

  Widget _buildSvocaPatternCard(EnSentenceStructureClause clause) {
    final EnSentenceStructureSvoca? svoca = clause.svoca;
    if (svoca == null || (svoca.codeNid ?? '').isEmpty) return const SizedBox.shrink();
    final String codeTitle = _svocaCodeLabelText(svoca);
    final _ChunkPalette palette = _svocaCodePalette(svoca.codeNid);
    final List<LanguageText?> popupDescriptions = _svocaPopupDescriptions(svoca);
    final List<LanguageText?> descriptions = svoca.descriptions ?? const [];
    final List<Widget> descriptionTexts = _buildDescriptionTexts(descriptions);
    return Padding(
      padding: EdgeInsets.only(bottom: 12.wMin,left: 20.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMetaChip(
            text: codeTitle,
            textColor: palette.label,
            background: palette.background,
            borderColor: palette.border,
            onTap: popupDescriptions.isEmpty
                ? null
                : () => _openMetaDialog(
                      chipText: codeTitle,
                      chipTextColor: palette.label,
                      chipBackground: palette.background,
                      chipBorderColor: palette.border,
                      descriptions: popupDescriptions,
                    ),
          ),
          if (descriptionTexts.isNotEmpty) ...[
            SizedBox(height: 10.wMin),
            ...descriptionTexts,
          ],
        ],
      ),
    );
  }

  Widget _buildSvocaSegmentCard(SentenceChunkLayoutPill pill) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.wMin,left: 20.wMin),
      child: _buildTapSegmentCard(
        popup: _popupFromPill(pill),
        card: _buildSegmentDetailCard(
          label: _svocaPillLabelText(pill),
          surfaceText: pill.text,
          descriptions: _findPillDescriptions(pill),
          palette: _paletteFromPill(pill),
          isResidual: false,
          isConjunction: false,
          isSelected: widget.selectedSegmentKey == pill.key,
          showDescriptions: true,
        ),
      ),
    );
  }

  List<Widget> _buildOrderedChunkContentWidgets({
    required List<_ChunkTreeNodeData> treeNodes,
    required List<SentenceChunkLayoutPill> residualPills,
  }) {
    final List<MapEntry<int, Widget>> entries = [
      ...treeNodes.map((node) => MapEntry(node.textReference.start ?? 0, _buildTreeNode(node))),
      ...residualPills.map(
        (pill) => MapEntry(
          pill.startTokenId,
          Padding(
            padding: EdgeInsets.only(bottom: 16.wMin,left: 20.wMin),
            child: _buildTapSegmentCard(
              popup: _popupFromPill(pill),
              card: _buildSegmentDetailCard(
                label: pill.label,
                surfaceText: pill.text,
                descriptions: const [],
                palette: _paletteFromPill(pill),
                isResidual: true,
                isConjunction: false,
                isSelected: widget.selectedSegmentKey == pill.key,
                showDescriptions: false,
              ),
            ),
          ),
        ),
      ),
    ]..sort((a, b) => a.key.compareTo(b.key));
    return entries.map((entry) => entry.value).toList();
  }

  List<Widget> _buildOrderedSvocaContentWidgets({
    required List<SentenceChunkLayoutPill> analysisPills,
    required List<SentenceChunkLayoutPill> residualPills,
  }) {
    final List<MapEntry<int, Widget>> entries = [
      ...analysisPills.map((pill) => MapEntry(pill.startTokenId, _buildSvocaSegmentCard(pill))),
      ...residualPills.map(
        (pill) => MapEntry(
          pill.startTokenId,
          Padding(
            padding: EdgeInsets.only(bottom: 16.wMin,left: 20.wMin),
            child: _buildTapSegmentCard(
              popup: _popupFromPill(pill),
              card: _buildSegmentDetailCard(
                label: pill.label,
                surfaceText: pill.text,
                descriptions: const [],
                palette: _paletteFromPill(pill),
                isResidual: true,
                isConjunction: false,
                isSelected: widget.selectedSegmentKey == pill.key,
                showDescriptions: false,
              ),
            ),
          ),
        ),
      ),
    ]..sort((a, b) => a.key.compareTo(b.key));
    return entries.map((entry) => entry.value).toList();
  }

  List<_ChunkTreeNodeData> _buildChunkTree(EnSentenceStructureClause clause) {
    final List<EnSentenceStructureChunking> chunkings = (clause.chunking ?? <EnSentenceStructureChunking?>[])
        .whereType<EnSentenceStructureChunking>()
        .where((chunk) => chunk.textReference?.start != null && chunk.textReference?.end != null)
        .toList()
      ..sort((a, b) => (a.textReference?.start ?? 0).compareTo(b.textReference?.start ?? 0));

    final List<_ChunkTreeNodeData> roots = [];
    final List<_ChunkRange> covered = [];
    for (final EnSentenceStructureChunking chunk in chunkings) {
      final int start = chunk.textReference?.start ?? 0;
      final int end = chunk.textReference?.end ?? 0;
      if (start <= 0 || end <= 0) continue;
      final bool contained = covered.any((range) => start >= range.start && end <= range.end);
      if (contained) continue;
      covered.add(_ChunkRange(start: start, end: end));

      final List<_ChunkTreeNodeData> children = [];
      for (final EnSentenceStructureChunking child in chunkings) {
        final int childStart = child.textReference?.start ?? 0;
        final int childEnd = child.textReference?.end ?? 0;
        if (childStart <= 0 || childEnd <= 0) continue;
        if (childStart >= start && childEnd <= end && !(childStart == start && childEnd == end)) {
            children.add(
              _ChunkTreeNodeData(
                key: 'chunk-${clause.clauseId}-$childStart-$childEnd-${child.type ?? ''}',
                type: child.type ?? '',
                label: _compactBilingualText(child.chunkType?.name, fallback: child.type ?? ''),
              textReference: child.textReference!,
              descriptions: child.descriptions ?? const [],
              popupDescriptions: child.chunkType?.description ?? child.descriptions ?? const [],
              clauseId: clause.clauseId,
              surfaceText: SentenceChunkLayoutHelper.sliceSurface(
                sentence: widget.sentence,
                tokens: widget.tokens,
                start: childStart,
                end: childEnd,
              ),
            ),
          );
        }
      }
      children.sort((a, b) => (a.textReference.start ?? 0).compareTo(b.textReference.start ?? 0));
        roots.add(
          _ChunkTreeNodeData(
            key: 'chunk-${clause.clauseId}-$start-$end-${chunk.type ?? ''}',
            type: chunk.type ?? '',
            label: _compactBilingualText(chunk.chunkType?.name, fallback: chunk.type ?? ''),
          textReference: chunk.textReference!,
          descriptions: chunk.descriptions ?? const [],
          popupDescriptions: chunk.chunkType?.description ?? chunk.descriptions ?? const [],
          clauseId: clause.clauseId,
          surfaceText: SentenceChunkLayoutHelper.sliceSurface(
            sentence: widget.sentence,
            tokens: widget.tokens,
            start: start,
            end: end,
          ),
          children: children,
        ),
      );
    }
    return roots;
  }

  Widget _buildTreeNode(_ChunkTreeNodeData node) {
    final bool expanded = _isExpanded(node.key);
      final _ChunkPalette palette = _chunkPaletteForType(node.type);
    final _SegmentPopupData popup = _SegmentPopupData(
      key: node.key,
      label: node.label,
      surfaceText: node.surfaceText,
      descriptions: node.popupDescriptions,
      clauseId: node.clauseId,
      isResidual: false,
      isConjunction: false,
      palette: palette,
    );
    return Padding(
      padding: EdgeInsets.only(bottom: 16.wMin,left: 20.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTapSegmentCard(
            popup: popup,
            card: _buildSegmentDetailCard(
              label: node.label,
              surfaceText: node.surfaceText,
              descriptions: node.descriptions,
              palette: palette,
              isResidual: false,
              isConjunction: false,
              isSelected: widget.selectedSegmentKey == node.key,
              showDescriptions: true,
            ),
          ),
          if (node.children.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(left: 12.wMin, top: 8.wMin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TapScaleWidget(
                    sclae: 1.01,
                    onTap: () => setState(() => _expanded[node.key] = !expanded),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.wMin, vertical: 4.wMin),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            expanded ? '▼' : '▶',
                            style: TextStyle(
                              fontSize: 12.wMin,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.cTextSecondary,
                            ),
                          ),
                          SizedBox(width: 6.wMin),
                          Text(
                            '内部语块（${node.children.length}）',
                            style: TextStyle(
                              fontSize: 15.wMin,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.cTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (expanded)
                    Container(
                      margin: EdgeInsets.only(left: 6.wMin, top: 4.wMin),
                      padding: EdgeInsets.only(left: 14.wMin),
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: AppTheme.cBorderTranslucentThin.color,
                            width: 1.wMin,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: node.children.map(_buildTreeNode).toList(),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  
  }

  Widget _buildTapSegmentCard({
    required _SegmentPopupData popup,
    required Widget card,
  }) {
    return TapScaleWidget(
      sclae: 1.01,
      onTap: () => _openSegmentDialog(popup),
      child: card,
    );
  }

  Widget _buildSegmentDetailCard({
    required String label,
    required String surfaceText,
    required List<LanguageText?> descriptions,
    required _ChunkPalette palette,
    required bool isResidual,
    required bool isConjunction,
    required bool isSelected,
    required bool showDescriptions,
  }) {
    final List<Widget> descriptionTexts = _buildDescriptionTexts(descriptions);
    final bool showBody = isResidual || (showDescriptions && descriptionTexts.isNotEmpty);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8.wMin,
          runSpacing: 8.wMin,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 6.wMin),
              decoration: BoxDecoration(
                color: AppTheme.cSurfaceTranslucentElevated.color,
                borderRadius: BorderRadius.circular(6.wMin),
                border: Border.all(
                  color: AppTheme.cBorderTranslucentThin.color,
                  width: 1.wMin,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w600,
                  color: palette.label.withValues(alpha: 0.88),
                ),
              ),
            ),
            if (surfaceText.isNotEmpty)
              Text(
                surfaceText,
                style: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.cTextPrimary,
                ),
              ),
          ],
        ),
       
        if (showBody) ...[
          SizedBox(height: 10.wMin),
          if (!isResidual && showDescriptions && descriptionTexts.isNotEmpty) ...descriptionTexts,
          if (!isResidual && showDescriptions && descriptionTexts.isEmpty)
            Text(
              '无详细描述',
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextSecondary,
              ),
            ),
        ],
      ],
    );
  }

  List<Widget> _buildDescriptionTexts(List<LanguageText?> descriptions) {
    return _visibleTexts(descriptions).map((item) {
      return Padding(
        padding: EdgeInsets.only(bottom: 6.wMin),
        child: Text(
          item.text ?? '',
          style: TextStyle(
            fontSize: item.lang == 'en' ? 24.wMin : 18.wMin,
            fontWeight: FontWeight.w400,
            color: item.lang == 'en' ? AppTheme.cTextSecondary.color : AppTheme.cTextTertiary.color,
            height: 1.45,
          ),
        ),
      );
    }).toList();
  }

  Widget _buildResidualInlineCard({
    required String label,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.wMin, vertical: 10.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceTranslucentElevated.color,
        borderRadius: BorderRadius.circular(14.wMin),
        border: Border.all(color: AppTheme.cBorderTranslucentThin.color, width: 1.wMin),
      ),
      child: Wrap(
        spacing: 8.wMin,
        runSpacing: 8.wMin,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15.wMin,
              fontWeight: FontWeight.w600,
              color: AppTheme.cTextPrimary,
            ),
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  _SegmentPopupData _popupFromPill(SentenceChunkLayoutPill pill) {
    final bool isSvoca = widget.analysisMode == SentenceChunkAnalysisMode.svoca;
    return _SegmentPopupData(
      key: pill.key,
      label: pill.kind == SentenceChunkLayoutPillKind.conjunction
          ? '连接词'
            : (isSvoca
                ? _svocaPillLabelText(pill)
                : _chunkPillLabelText(pill)),
      surfaceText: pill.text,
      descriptions: pill.kind == SentenceChunkLayoutPillKind.residual ? const [] : _findPillPopupDescriptions(pill),
      clauseId: pill.clauseId,
      isResidual: pill.kind == SentenceChunkLayoutPillKind.residual,
      isConjunction: pill.kind == SentenceChunkLayoutPillKind.conjunction,
      palette: _paletteFromPill(pill),
    );
  }

  List<LanguageText?> _findPillPopupDescriptions(SentenceChunkLayoutPill pill) {
    final EnSentenceStructureClause clause = widget.clauses.firstWhere(
      (item) => item.clauseId == pill.clauseId,
      orElse: () => EnSentenceStructureClause(),
    );
    if (pill.kind == SentenceChunkLayoutPillKind.conjunction) {
      final List<EnSentenceStructureConjunction> conjunctions =
          (clause.conjunctions ?? <EnSentenceStructureConjunction?>[]).whereType<EnSentenceStructureConjunction>().toList();
      for (final EnSentenceStructureConjunction conjunction in conjunctions) {
        if ((conjunction.textReference?.start ?? 0) == pill.startTokenId &&
            (conjunction.textReference?.end ?? 0) == pill.endTokenId) {
          return conjunction.descriptions ?? const [];
        }
      }
      return const [];
    }
    if (widget.analysisMode == SentenceChunkAnalysisMode.svoca) {
      final List<EnSentenceStructureSvocaElement> elements =
          (clause.svoca?.elements ?? <EnSentenceStructureSvocaElement?>[])
              .whereType<EnSentenceStructureSvocaElement>()
              .toList();
      for (final EnSentenceStructureSvocaElement element in elements) {
        if ((element.textReference?.start ?? 0) == pill.startTokenId &&
            (element.textReference?.end ?? 0) == pill.endTokenId &&
            (element.typeNid ?? '') == pill.sourceType) {
          return _svocaElementPopupDescriptions(element);
        }
      }
      return const [];
    }
    final List<EnSentenceStructureChunking> chunkings =
        (clause.chunking ?? <EnSentenceStructureChunking?>[]).whereType<EnSentenceStructureChunking>().toList();
    for (final EnSentenceStructureChunking chunk in chunkings) {
      if ((chunk.textReference?.start ?? 0) == pill.startTokenId &&
          (chunk.textReference?.end ?? 0) == pill.endTokenId &&
          (chunk.type ?? '') == pill.sourceType) {
        return chunk.descriptions ?? const [];
      }
    }
    return const [];
  }

  String _chunkPillLabelText(SentenceChunkLayoutPill pill) {
    final EnSentenceStructureClause clause = widget.clauses.firstWhere(
      (item) => item.clauseId == pill.clauseId,
      orElse: () => EnSentenceStructureClause(),
    );
    final List<EnSentenceStructureChunking> chunkings =
        (clause.chunking ?? <EnSentenceStructureChunking?>[]).whereType<EnSentenceStructureChunking>().toList();
    for (final EnSentenceStructureChunking chunk in chunkings) {
      if ((chunk.textReference?.start ?? 0) == pill.startTokenId &&
          (chunk.textReference?.end ?? 0) == pill.endTokenId &&
          (chunk.type ?? '') == pill.sourceType) {
        return _compactBilingualText(
          chunk.chunkType?.name,
          fallback: chunk.type ?? pill.label,
        );
      }
    }
    return pill.label;
  }

  List<LanguageText?> _findPillDescriptions(SentenceChunkLayoutPill pill) {
    final EnSentenceStructureClause clause = widget.clauses.firstWhere(
      (item) => item.clauseId == pill.clauseId,
      orElse: () => EnSentenceStructureClause(),
    );
    if (pill.kind == SentenceChunkLayoutPillKind.conjunction) {
      final List<EnSentenceStructureConjunction> conjunctions =
          (clause.conjunctions ?? <EnSentenceStructureConjunction?>[]).whereType<EnSentenceStructureConjunction>().toList();
      for (final EnSentenceStructureConjunction conjunction in conjunctions) {
        if ((conjunction.textReference?.start ?? 0) == pill.startTokenId && (conjunction.textReference?.end ?? 0) == pill.endTokenId) {
          return conjunction.descriptions ?? const [];
        }
      }
      return const [];
    }
    if (widget.analysisMode == SentenceChunkAnalysisMode.svoca) {
      final List<EnSentenceStructureSvocaElement> elements =
          (clause.svoca?.elements ?? <EnSentenceStructureSvocaElement?>[])
              .whereType<EnSentenceStructureSvocaElement>()
              .toList();
      for (final EnSentenceStructureSvocaElement element in elements) {
        if ((element.textReference?.start ?? 0) == pill.startTokenId &&
            (element.textReference?.end ?? 0) == pill.endTokenId &&
            (element.typeNid ?? '') == pill.sourceType) {
          return element.descriptions ?? const [];
        }
      }
      return const [];
    }
    final List<EnSentenceStructureChunking> chunkings =
        (clause.chunking ?? <EnSentenceStructureChunking?>[]).whereType<EnSentenceStructureChunking>().toList();
    for (final EnSentenceStructureChunking chunk in chunkings) {
      if ((chunk.textReference?.start ?? 0) == pill.startTokenId &&
          (chunk.textReference?.end ?? 0) == pill.endTokenId &&
          (chunk.type ?? '') == pill.sourceType) {
        return chunk.descriptions ?? const [];
      }
    }
    return const [];
  }

  _ChunkPalette _paletteFromPill(SentenceChunkLayoutPill pill) {
    if (pill.kind == SentenceChunkLayoutPillKind.conjunction) {
      return _ChunkPalette(
        background: const Color(0xFFF59E0B).withValues(alpha: 0.12),
        border: const Color(0xFFF59E0B).withValues(alpha: 0.30),
        label: const Color(0xFFF59E0B),
      );
    }
    if (pill.kind == SentenceChunkLayoutPillKind.residual) {
      return _ChunkPalette(
        background: AppTheme.cSurfaceTranslucentElevated.color,
        border: AppTheme.cBorderTranslucentThin.color,
        label: AppTheme.cTextPrimary,
        isDotted: true,
      );
    }
    if (widget.analysisMode == SentenceChunkAnalysisMode.svoca) {
      return _svocaPaletteForType(pill.sourceType);
    }
    return _chunkPaletteForPill(pill, tokens: widget.tokens);
  }

  String _svocaCodeLabelText(EnSentenceStructureSvoca svoca) {
    final String text = _namedBilingualText(svoca.code?.name);
    if (text.isNotEmpty) return text;
    return svoca.codeNid?.isNotEmpty == true ? svoca.codeNid! : '成分骨架';
  }

  String _svocaPillLabelText(SentenceChunkLayoutPill pill) {
    final EnSentenceStructureClause clause = widget.clauses.firstWhere(
      (item) => item.clauseId == pill.clauseId,
      orElse: () => EnSentenceStructureClause(),
    );
    final List<EnSentenceStructureSvocaElement> elements =
        (clause.svoca?.elements ?? <EnSentenceStructureSvocaElement?>[])
            .whereType<EnSentenceStructureSvocaElement>()
            .toList();
    for (final EnSentenceStructureSvocaElement element in elements) {
      if ((element.textReference?.start ?? 0) == pill.startTokenId &&
          (element.textReference?.end ?? 0) == pill.endTokenId &&
          (element.typeNid ?? '') == pill.sourceType) {
        final String text = _compactBilingualText(
          element.type?.name,
          fallback: element.typeNid ?? pill.sourceType,
        );
        if (text.isNotEmpty) return text;
      }
    }
    return pill.sourceType;
  }
}

class _ChunkGridMetrics {
  final List<double> widths;
  final List<double> offsets;
  final double canvasWidth;

  const _ChunkGridMetrics({
    required this.widths,
    required this.offsets,
    required this.canvasWidth,
  });
}

class _ChunkLaneItem {
  final int start;
  final int end;
  final int span;
  final String type;
  final String surface;
  final SentenceChunkLayoutPill pill;

  _ChunkLaneItem({
    required this.start,
    required this.end,
    required this.span,
    required this.type,
    required this.surface,
    required this.pill,
  });
}

class _ChunkPalette {
  final Color background;
  final Color border;
  final Color label;
  final bool isDotted;

  _ChunkPalette({
    required this.background,
    required this.border,
    required this.label,
    this.isDotted = false,
  });
}

class _ChunkTreeNodeData {
  final String key;
  final String type;
  final String label;
  final TextReference textReference;
  final List<LanguageText?> descriptions;
  final List<LanguageText?> popupDescriptions;
  final int? clauseId;
  final String surfaceText;
  final List<_ChunkTreeNodeData> children;

  _ChunkTreeNodeData({
    required this.key,
    required this.type,
    required this.label,
    required this.textReference,
    required this.descriptions,
    required this.popupDescriptions,
    required this.clauseId,
    required this.surfaceText,
    List<_ChunkTreeNodeData>? children,
  }) : children = children ?? [];
}

class _ChunkRange {
  final int start;
  final int end;

  const _ChunkRange({
    required this.start,
    required this.end,
  });
}

class _SegmentPopupData {
  final String key;
  final String label;
  final String surfaceText;
  final List<LanguageText?> descriptions;
  final int? clauseId;
  final bool isResidual;
  final bool isConjunction;
  final _ChunkPalette palette;

  const _SegmentPopupData({
    required this.key,
    required this.label,
    required this.surfaceText,
    required this.descriptions,
    required this.clauseId,
    required this.isResidual,
    required this.isConjunction,
    required this.palette,
  });
}

List<LanguageText> _visibleTexts(List<LanguageText?>? texts) {
  return (texts ?? <LanguageText?>[]).whereType<LanguageText>().where((item) => (item.text ?? '').trim().isNotEmpty).toList();
}

String _languageTextValue(List<LanguageText?>? texts) {
  final List<LanguageText> list = _visibleTexts(texts);
  String zhText = '';
  String enText = '';
  for (final LanguageText item in list) {
    final String lang = (item.lang ?? '').toLowerCase();
    final String text = (item.text ?? '').trim();
    if (text.isEmpty) continue;
    if (lang == 'zh' && zhText.isEmpty) zhText = text;
    if (lang == 'en' && enText.isEmpty) enText = text;
  }
  if (zhText.isNotEmpty && enText.isNotEmpty) return '$zhText / $enText';
  if (zhText.isNotEmpty) return zhText;
  if (enText.isNotEmpty) return enText;
  return list.map((LanguageText item) => item.text ?? '').join(' / ').trim();
}

String _descriptionTextForLang(
  List<LanguageText?>? descriptions,
  String lang, {
  String? emptyText,
}) {
  final List<LanguageText> items = _visibleTexts(descriptions);
  for (final LanguageText item in items) {
    if ((item.lang ?? '').toLowerCase() == lang) {
      return (item.text ?? '').trim();
    }
  }
  if (lang == 'zh' && items.isNotEmpty) {
    return (items.first.text ?? '').trim();
  }
  if (lang == 'en' && items.length > 1) {
    return (items[1].text ?? '').trim();
  }
  return emptyText ?? '无详细描述';
}

List<LanguageText?> _svocaElementPopupDescriptions(
  EnSentenceStructureSvocaElement element,
) {
  final List<LanguageText?> descriptions = element.type?.description ?? const [];
  if (descriptions.isNotEmpty) return descriptions;
  return element.descriptions ?? const [];
}

List<LanguageText?> _svocaPopupDescriptions(EnSentenceStructureSvoca svoca) {
  final List<LanguageText?> descriptions = svoca.code?.description ?? const [];
  if (descriptions.isNotEmpty) return descriptions;
  return svoca.descriptions ?? const [];
}

LanguageConfigColorEntity? _colorConfigsOrNull() {
  if (!Get.isRegistered<ConfigController>()) return null;
  return Get.find<ConfigController>().colorConfigs.value;
}

LanguageConfigColorEntityInfo? _findConfigItem(
  List<LanguageConfigColorEntityInfo?>? configs,
  String? code,
) {
  if (configs == null || (code ?? '').isEmpty) return null;
  for (final LanguageConfigColorEntityInfo? item in configs) {
    if ((item?.code ?? '').toUpperCase() == code!.toUpperCase()) {
      return item;
    }
  }
  return null;
}

_ChunkPalette _paletteFromConfig(
  LanguageConfigColorEntityInfo? item, {
  required _ChunkPalette fallback,
}) {
  final Color? primaryColor = ColorUtils.parseColor(item?.color?.textColor);
  if (primaryColor == null) return fallback;
  return _ChunkPalette(
    background: primaryColor.withValues(alpha: 0.12),
    border: primaryColor.withValues(alpha: 0.30),
    label: primaryColor,
  );
}

String _clauseTypeLabelText(String? type) {
  final LanguageConfigColorEntity? configs = _colorConfigsOrNull();
  final LanguageConfigColorEntityInfo? config = _findConfigItem(
    configs?.clauseTypes,
    _normalizeClauseTypeCode(type),
  );
  if ((config?.title ?? '').isNotEmpty) {
    return config!.title!;
  }
  return type?.isNotEmpty == true ? type! : '子句';
}

LanguageConfigColorEntityInfo? _grammarFeatureConfig(EnSentenceStructureGrammarFeature feature) {
  final LanguageConfigColorEntity? configs = _colorConfigsOrNull();
  return _findConfigItem(
    configs?.grammaticalFeatures,
    feature.featureNid ?? feature.feature?.nid,
  );
}

LanguageConfigColorEntityInfo? _specialClauseFeatureConfig(EnSentenceStructureSpecialClauseFeature feature) {
  final LanguageConfigColorEntity? configs = _colorConfigsOrNull();
  return _findConfigItem(
    configs?.sentenceSpecialFeatures,
    feature.codeNid ?? feature.featureNid,
  );
}

String _grammarFeatureLabelText(
  EnSentenceStructureGrammarFeature feature,
  LanguageConfigColorEntityInfo? config,
) {
  final String featureName = _configTitleText(
    config,
    fallback: _languageTextValue(feature.feature?.name),
  );
  if (featureName.isEmpty) return '';
  final String categoryName = _categoryNameText(config?.categoryName);
  if (categoryName.isEmpty) return featureName;
  return '$categoryName:$featureName';
}

String _specialClauseFeatureLabelText(
  EnSentenceStructureSpecialClauseFeature feature,
  LanguageConfigColorEntityInfo? config,
) {
  final String featureName = _configTitleText(
    config,
    fallback: feature.codeNid ?? feature.featureNid ?? '',
  );
  if (featureName.isEmpty) return '';
  final String categoryName = _categoryNameText(config?.categoryName);
  if (categoryName.isEmpty) return featureName;
  return '$categoryName:$featureName';
}

String _configTitleText(
  LanguageConfigColorEntityInfo? config, {
  String fallback = '',
}) {
  final String title = (config?.title ?? '').trim();
  final String englishName = (config?.englishName ?? '').trim();
  if (title.isNotEmpty && englishName.isNotEmpty) return '$title / $englishName';
  if (title.isNotEmpty) return title;
  if (englishName.isNotEmpty) return englishName;
  return fallback;
}

String _categoryNameText(List<LanguageText?>? texts) {
  final List<LanguageText> list = _visibleTexts(texts);
  String zhText = '';
  for (final LanguageText item in list) {
    final String lang = (item.lang ?? '').toLowerCase();
    final String text = (item.text ?? '').trim();
    if (text.isEmpty) continue;
    if (lang == 'zh' && zhText.isEmpty) zhText = text;
  }
  if (zhText.isNotEmpty) return zhText;
  return list.isNotEmpty ? (list.first.text ?? '').trim() : '';
}

String _normalizeClauseTypeCode(String? type) {
  switch (type) {
    case 'relative':
      return 'relative_clause';
    default:
      return type ?? '';
  }
}

_ChunkPalette _clauseTypePalette(String? type) {
  final _ChunkPalette fallback = _ChunkPalette(
    background: AppTheme.cSurfaceTranslucentElevated.color,
    border: AppTheme.cBorderTranslucentThin.color,
    label: AppTheme.cTextPrimary,
  );
  final LanguageConfigColorEntity? configs = _colorConfigsOrNull();
  final LanguageConfigColorEntityInfo? config = _findConfigItem(
    configs?.clauseTypes,
    _normalizeClauseTypeCode(type),
  );
  return _paletteFromConfig(config, fallback: fallback);
}

_ChunkPalette _chunkPaletteForPill(
  SentenceChunkLayoutPill pill, {
  required List<EnSentenceStructureToken> tokens,
}) {
  return _chunkPaletteForType(pill.sourceType);
}

_ChunkPalette _svocaPaletteForType(String? typeNid) {
  final _ChunkPalette fallback = _ChunkPalette(
    background: AppTheme.cSurfaceTranslucentElevated.color,
    border: AppTheme.cBorderTranslucentThin.color,
    label: AppTheme.cTextPrimary,
  );
  return _paletteFromConfig(_sentenceSvocaElementTypeConfigForType(typeNid), fallback: fallback);
}

_ChunkPalette _grammarFeaturePalette(LanguageConfigColorEntityInfo? config) {
  final _ChunkPalette fallback = _ChunkPalette(
    background: AppTheme.cSurfaceTranslucentBase.color,
    border: AppTheme.cBorderTranslucentThin.color,
    label: AppTheme.cTextPrimary.color,
  );
  return _paletteFromConfig(config, fallback: fallback);
}

Color _clauseIndexBadgeBackgroundColor(bool isActive) {
  return isActive
      ? AppTheme.cListenBg2.withValues(alpha: 0.12)
      : AppTheme.cSurfaceTranslucentBase.color;
}

Color _clauseIndexBadgeBorderColor(bool isActive) {
  return isActive
      ? AppTheme.cListenBg2.withValues(alpha: 0.30)
      : AppTheme.cBorderTranslucentThin.color;
}

Color _clauseIndexBadgeLableColor(bool isActive) {
  return isActive
      ? AppTheme.cListenBg2
      : AppTheme.cTextPrimary;
}

Color _clauseIndexBadgeLableSubColor(bool isActive) {
  return isActive
      ? AppTheme.cListenBg2.withValues(alpha: 0.8)
      : AppTheme.cTextSecondary;
}


_ChunkPalette _svocaCodePalette(String? codeNid) {
  const Color fallbackColor = Color(0xFFF59E0B);
  final _ChunkPalette fallback = _ChunkPalette(
    background: fallbackColor.withValues(alpha: 0.16),
    border: fallbackColor.withValues(alpha: 0.26),
    label: const Color(0xFFFCD34D),
  );
  final LanguageConfigColorEntity? configs = _colorConfigsOrNull();
  final LanguageConfigColorEntityInfo? config = _findConfigItem(
    configs?.structuralLevels,
    codeNid,
  );
  return _paletteFromConfig(config, fallback: fallback);
}

String _compactBilingualText(
  List<LanguageText?>? texts, {
  String fallback = '',
}) {
  final List<LanguageText> list = _visibleTexts(texts);
  String zhText = '';
  String enText = '';
  for (final LanguageText item in list) {
    final String lang = (item.lang ?? '').toLowerCase();
    final String text = (item.text ?? '').trim();
    if (text.isEmpty) continue;
    if (lang == 'zh' && zhText.isEmpty) zhText = text;
    if (lang == 'en' && enText.isEmpty) enText = text;
  }
  if (zhText.isNotEmpty && enText.isNotEmpty) return '$zhText/$enText';
  if (zhText.isNotEmpty) return zhText;
  if (enText.isNotEmpty) return enText;
  return fallback;
}

String _languageTextZh(
  List<LanguageText?>? texts, {
  String fallback = '',
}) {
  final List<LanguageText> list = _visibleTexts(texts);
  for (final LanguageText item in list) {
    if ((item.lang ?? '').toLowerCase() == 'zh') {
      final String text = (item.text ?? '').trim();
      if (text.isNotEmpty) return text;
    }
  }
  return fallback;
}

_ChunkPalette _chunkPaletteForType(String? type) {
  final _ChunkPalette fallback = _ChunkPalette(
    background: AppTheme.cSurfaceTranslucentElevated.color,
    border: AppTheme.cBorderTranslucentThin.color,
    label: AppTheme.cTextPrimary,
  );
  final LanguageConfigColorEntity? configs = _colorConfigsOrNull();
  final LanguageConfigColorEntityInfo? chunkTypeConfig = _findConfigItem(
    configs?.chunkTypes,
    type,
  );
  final LanguageConfigColorEntityInfo? config =
      ColorUtils.parseColor(chunkTypeConfig?.color?.textColor) != null
      ? chunkTypeConfig
      : _findConfigItem(configs?.upos, type);
  return _paletteFromConfig(config, fallback: fallback);
}

LanguageConfigColorEntityInfo? _sentenceSvocaElementTypeConfigForType(String? typeNid) {
  final LanguageConfigColorEntity? configs = _colorConfigsOrNull();
  return _findConfigItem(
    configs?.sentenceSvocaElementTypes,
    typeNid,
  );
}

String _namedBilingualText(List<LanguageText?>? texts) {
  return _languageTextValue(texts);
}
