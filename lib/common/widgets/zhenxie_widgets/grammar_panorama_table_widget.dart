import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../../../theme/theme.dart';
import '../../entities/entities.dart';
import '../../enum/enum.dart';
import '../../values/values.dart';
import 'set_expansion_buttons_widget.dart';

class GrammarPanoramaMinTableWidget extends StatelessWidget {
  final List<ManageGrammarPanoramaAxisEntity?>? axes;
  final List<ManageGrammarPanoramaCellEntity?>? cells;
  final List<ZhenxieRealizationSetsEntity?>? realizationSets;

  /// 语法全景表 - 小
  const GrammarPanoramaMinTableWidget({
    super.key,
    this.axes,
    this.cells,
    this.realizationSets,
  });

  @override
  Widget build(BuildContext context) {
    final rowAxis = axes?.isNotEmpty == true ? axes?.first : null;
    final colAxis = axes != null && axes!.length > 1 ? axes![1] : null;
    final rowValues = rowAxis?.values?.whereType<String>().toList() ?? [];
    final colValues = colAxis?.values?.whereType<String>().toList() ?? [];
    if (rowAxis == null || colAxis == null || rowValues.isEmpty || colValues.isEmpty || (cells?.isEmpty ?? true)) {
      return const SizedBox.shrink();
    }
    final rowLabelMap = _buildAxisValueLabelMap(rowAxis.valuesLabels);
    final colLabelMap = _buildAxisValueLabelMap(colAxis.valuesLabels);
    final cellMap = _buildCellCoordinateMap(cells);
    final sentenceMap = _buildPreviewSentenceMap(realizationSets);
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Row(
            children: [
              _buildEmptyCornerWidget(),
              ...List.generate(colValues.length, (index) {
                final value = colValues[index];
                return Expanded(
                  child: _buildAxisLabelWidget(
                    colLabelMap[value] ?? '',
                    isRow: false,
                  ),
                );
              }),
            ],
          ),
          ...List.generate(rowValues.length, (index) {
            final rowValue = rowValues[index];
            return Padding(
              padding: EdgeInsets.only(top: 6.wMin),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildAxisLabelWidget(
                      rowLabelMap[rowValue] ?? '',
                      isRow: true,
                    ),
                    ...List.generate(colValues.length, (colIndex) {
                      final colValue = colValues[colIndex];
                      final cell = cellMap["$rowValue|$colValue"];
                      final sentence = cell?.key == null ? null : sentenceMap[cell!.key!];
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 6.wMin),
                          child: _buildPreviewCellWidget(sentence?.content ?? ''),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyCornerWidget() {
    return SizedBox(
      width: 58.wMin,
      height: 32.wMin,
    );
  }

  Widget _buildAxisLabelWidget(String text, {required bool isRow}) {
    return SizedBox(
      width: isRow ? 58.wMin : null,
      height: isRow ? 52.wMin : 32.wMin,
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cZhenxieFontSecondary.color,
            fontFamily: AppFontValue.sourceHanSerifCN,
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCellWidget(String text) {
    if (text.isEmpty) {
      return DottedBorder(
        color: AppTheme.cBorderThin.color.withValues(alpha: 0.16),
        strokeWidth: 1.wMin,
        dashPattern: [4, 4],
        borderType: BorderType.RRect,
        radius: Radius.circular(8.wMin),
        child: SizedBox(
          height: 52.wMin,
          width: double.infinity,
        ),
      );
    }
    return Container(
      constraints: BoxConstraints(minHeight: 52.wMin),
      padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 8.wMin),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: const Color(0xFF298AEA).withValues(alpha: 0.12),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 16.wMin,
          fontWeight: FontWeight.w500,
          color: AppTheme.cZhenxieFontBlue.color,
          fontFamily: AppFontValue.robotoMono,
          height: 1.35,
        ),
      ),
    );
  }

  Map<String, String> _buildAxisValueLabelMap(List<ManageGrammarPanoramaAxisValueLabelEntity?>? labels) {
    final map = <String, String>{};
    for (final item in labels ?? []) {
      final nid = item?.nid;
      final text = LearningLangUtils.getLocalLang(item?.name)?.text;
      if (nid?.isNotEmpty == true && text?.isNotEmpty == true) {
        map[nid!] = text!;
      }
    }
    return map;
  }

  Map<String, ManageGrammarPanoramaCellEntity> _buildCellCoordinateMap(List<ManageGrammarPanoramaCellEntity?>? cellList) {
    final map = <String, ManageGrammarPanoramaCellEntity>{};
    for (final item in cellList ?? []) {
      final rowValue = item?.rowValue;
      final colValue = item?.colValue;
      if (rowValue?.isNotEmpty != true || colValue?.isNotEmpty != true || item == null) continue;
      map["$rowValue|$colValue"] = item;
    }
    return map;
  }

  Map<String, ZhenxieSentenceMemberSentenceEntity> _buildPreviewSentenceMap(
    List<ZhenxieRealizationSetsEntity?>? sets,
  ) {
    final map = <String, ZhenxieSentenceMemberSentenceEntity>{};
    ZhenxieRealizationSetsEntity? currentSet;
    for (final item in sets ?? []) {
      if (item != null) {
        currentSet = item;
        break;
      }
    }
    final List<ZhenxieSentenceMemberEntity?> memberList = currentSet?.members ?? [];
    for (final item in memberList) {
      final valueNid = item?.valueNid;
      final sentence = item?.sentence;
      if (valueNid?.isNotEmpty != true || sentence == null) continue;
      map[valueNid!] = sentence;
    }
    return map;
  }
}

class GrammarPanoramaTableWidget extends StatefulWidget {
  final bool isManagement;

  /// 句子高亮的部分
  final FocusKeyEnum? focusKey;

  final List<ManageGrammarPanoramaAxisEntity?>? axes;
  final List<ManageGrammarPanoramaCellEntity?>? cells;
  final List<ZhenxieRealizationSetsEntity> exampleList;

  /// 组上下架回调
  final void Function(ZhenxieRealizationSetsEntity group)? onShelfChange;

  /// 组删除回调
  final void Function(ZhenxieRealizationSetsEntity group)? onDelete;

  /// 句子编辑返回后的刷新回调。
  final void Function(ZhenxieSentenceMemberSentenceEntity? sentence)? onSentenceShelfChange;

  /// 单句刷新
  final void Function(ZhenxieSentenceMemberSentenceEntity? sentence)? onRefresh;

  /// 语法全景表格
  const GrammarPanoramaTableWidget({
    super.key,
    this.axes,
    this.cells,
    required this.exampleList,
    this.isManagement = false,
    this.focusKey,
    this.onShelfChange,
    this.onDelete,
    this.onSentenceShelfChange,
    this.onRefresh,
  });

  @override
  State<GrammarPanoramaTableWidget> createState() => _GrammarPanoramaTableWidgetState();
}

class _GrammarPanoramaTableWidgetState extends State<GrammarPanoramaTableWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16.wMin,
      children: List.generate(widget.exampleList.length, (index) {
        return _buildContentWidget(widget.exampleList[index], index);
      }),
    );
  }

  Widget _buildContentWidget(ZhenxieRealizationSetsEntity example, int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cZhenxieBackgroundPrimary.color,
        border: Border.all(
          color: AppTheme.cZhenxieBorderPrimary.color,
          width: 0.8.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 16.wMin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "宫格${widget.exampleList.length > 1 ? index + 1 : ''}",
                      style: TextStyle(
                        fontSize: 20.wMin,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.cZhenxieFontPrimary.color,
                        fontFamily: AppFontValue.sourceHanSerifCN,
                      ),
                    ),
                    SizedBox(width: 6.wMin),
                    Visibility(
                      visible: widget.isManagement,
                      child: _buildTagWidget(
                        tagText: example.isNormal ? "已上架" : "未上架",
                        textColor: example.isNormal ? AppTheme.cSurfaceSuccess.color : AppTheme.cSurfaceWarning.color,
                        bgColor: example.isNormal
                            ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.12)
                            : AppTheme.cSurfaceWarning.color.withValues(alpha: 0.12),
                        borderColor: example.isNormal
                            ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.2)
                            : AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2),
                      ),
                    ),
                    Spacer(),
                    Visibility(
                      visible: widget.isManagement && (widget.onShelfChange != null || widget.onDelete != null),
                      child: ManageIpDownEditDelWidget(
                        isNormal: example.isNormal,
                        onShelf: widget.onShelfChange == null ? null : () {
                          widget.onShelfChange?.call(example);
                        },
                        onDelete: widget.onDelete == null ? null :() {
                          widget.onDelete?.call(example);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 1.wMin,
            color: AppTheme.cZhenxieBorderPrimary.color,
          ),
          _buildTableWidget(example),
        ],
      ),
    );
  }

  /// 填充当前示例对应的表格内容。
  Widget _buildTableWidget(ZhenxieRealizationSetsEntity example) {
    final rowAxis = widget.axes?.isNotEmpty == true ? widget.axes?.first : null;
    final colAxis = widget.axes != null && widget.axes!.length > 1 ? widget.axes![1] : null;
    final rowValues = rowAxis?.values?.whereType<String>().toList() ?? [];
    final colValues = colAxis?.values?.whereType<String>().toList() ?? [];
    if (rowAxis == null || colAxis == null || rowValues.isEmpty || colValues.isEmpty) {
      return const SizedBox.shrink();
    }
    final rowLabelMap = _buildAxisValueLabelMap(rowAxis.valuesLabels);
    final colLabelMap = _buildAxisValueLabelMap(colAxis.valuesLabels);
    final cellMap = _buildCellCoordinateMap(widget.cells);
    final List<ZhenxieSentenceMemberEntity?> exampleMembers = List<ZhenxieSentenceMemberEntity?>.from(
      example.members ?? const <ZhenxieSentenceMemberEntity?>[],
    );
    final exampleItemMap = _buildExampleItemMap(exampleMembers);
    return Padding(
      padding: EdgeInsets.all(24.wMin),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Row(
              children: [
                _buildTableEmptyCornerWidget(),
                ...List.generate(colValues.length, (index) {
                  final value = colValues[index];
                  return Expanded(
                    child: _buildTableAxisLabelWidget(
                      colLabelMap[value] ?? '',
                      isRow: false,
                    ),
                  );
                }),
              ],
            ),
            ...List.generate(rowValues.length, (index) {
              final rowValue = rowValues[index];
              return Padding(
                padding: EdgeInsets.only(top: 10.wMin),
                child: IntrinsicHeight(
                  child: _buildTableRowItemWidget(
                    rowLabel: rowLabelMap[rowValue] ?? '',
                    rowValue: rowValue,
                    colValues: colValues,
                    cellMap: cellMap,
                    exampleItemMap: exampleItemMap,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTableEmptyCornerWidget() {
    return SizedBox(
      width: 58.wMin,
      height: 32.wMin,
    );
  }

  Widget _buildTableAxisLabelWidget(String text, {required bool isRow}) {
    return SizedBox(
      width: isRow ? 100.wMin : null,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 10.wMin),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cZhenxieFontSecondary.color,
            fontFamily: AppFontValue.sourceHanSerifCN,
          ),
        ),
      ),
    );
  }

  Widget _buildTableRowItemWidget({
    required String rowLabel,
    required String rowValue,
    required List<String> colValues,
    required Map<String, ManageGrammarPanoramaCellEntity> cellMap,
    required Map<String, ZhenxieSentenceMemberEntity> exampleItemMap,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildTableAxisLabelWidget(rowLabel, isRow: true),
        ...List.generate(colValues.length, (index) {
          final colValue = colValues[index];
          final cell = cellMap["$rowValue|$colValue"];
          final exampleItem = cell?.key == null ? null : exampleItemMap[cell!.key!];
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10.wMin),
              child: _buildTableItemUnitWidget(
                cellLabel: LearningLangUtils.getLocalLang(cell?.label)?.text ?? '',
                sentence: exampleItem?.sentence,
                sentenceId: exampleItem?.sentenceId,
                content: exampleItem?.sentence?.content ?? '',
                definition: exampleItem?.sentence?.definition ?? '',
                ranges: _getCurrentFocusRanges(exampleItem?.foci),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTableItemUnitWidget({
    required String cellLabel,
    required ZhenxieSentenceMemberSentenceEntity? sentence,
    required int? sentenceId,
    required String content,
    required String definition,
    required List<ZhenxieSentenceMemberFocusRangeEntity> ranges,
  }) {
    if (content.isEmpty) {
      return DottedBorder(
        color: AppTheme.cBorderThin.color.withValues(alpha: 0.2),
        strokeWidth: 1.wMin,
        dashPattern: [4.wMin, 4.wMin],
        borderType: BorderType.RRect,
        radius: Radius.circular(8.wMin),
        child: SizedBox(
          width: double.infinity,
        ),
      );
    }
    return Container(
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: const Color(0xFF298AEA).withValues(alpha: 0.06),
        border: Border.all(
          color: AppTheme.cZhenxieBorderPrimary.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SelectableText.rich(
            TextSpan(
              style: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cZhenxieFontPrimary.color,
                fontFamily: AppFontValue.robotoMono,
              ),
              children: _buildSentenceTextSpanChildren(content, ranges),
            ),
            textAlign: TextAlign.center,
          ),
          if (definition.isNotEmpty) ...[
            SizedBox(height: 10.wMin),
            SelectableText(
              definition,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cZhenxieFontTertiary.color,
                fontFamily: AppFontValue.sourceHanSerifCN,
              ),
            ),
          ],
          SizedBox(height: 10.wMin),
          SetExpansionButtonsWidget(
            isManagement: widget.isManagement,
            sentenceId: sentenceId,
            content: content,
            isNormal: sentence?.isNormal ?? false,
            onShelf: () {
              widget.onSentenceShelfChange?.call(sentence);
            },
            onRefresh: () {
              widget.onRefresh?.call(sentence);
            },
          ),
        ],
      ),
    );
  }

  Map<String, String> _buildAxisValueLabelMap(List<ManageGrammarPanoramaAxisValueLabelEntity?>? labels) {
    final map = <String, String>{};
    for (final item in labels ?? []) {
      final nid = item?.nid;
      final text = LearningLangUtils.getLocalLang(item?.name)?.text;
      if (nid?.isNotEmpty == true && text?.isNotEmpty == true) {
        map[nid!] = text!;
      }
    }
    return map;
  }

  Map<String, ManageGrammarPanoramaCellEntity> _buildCellCoordinateMap(List<ManageGrammarPanoramaCellEntity?>? cells) {
    final map = <String, ManageGrammarPanoramaCellEntity>{};
    for (final item in cells ?? []) {
      final rowValue = item?.rowValue;
      final colValue = item?.colValue;
      if (rowValue?.isNotEmpty != true || colValue?.isNotEmpty != true || item == null) continue;
      map["$rowValue|$colValue"] = item;
    }
    return map;
  }

  Map<String, ZhenxieSentenceMemberEntity> _buildExampleItemMap(
    List<ZhenxieSentenceMemberEntity?>? memberList,
  ) {
    final map = <String, ZhenxieSentenceMemberEntity>{};
    for (final item in memberList ?? []) {
      final valueNid = item?.valueNid;
      if (valueNid?.isNotEmpty != true || item == null) continue;
      map[valueNid!] = item;
    }
    return map;
  }

  List<ZhenxieSentenceMemberFocusRangeEntity> _getCurrentFocusRanges(
    List<ZhenxieSentenceMemberFocusEntity?>? foci,
  ) {
    final currentFocus = widget.focusKey;
    if (currentFocus == null) return const [];
    ZhenxieSentenceMemberFocusEntity? focusEntity;
    for (final item in foci ?? []) {
      if (item?.focusKey == currentFocus.value) {
        focusEntity = item;
        break;
      }
    }
    final list = <ZhenxieSentenceMemberFocusRangeEntity>[];
    for (final item in focusEntity?.ranges ?? []) {
      final start = item?.start;
      final end = item?.end;
      if (start == null || end == null || end <= start) continue;
      list.add(item!);
    }
    list.sort((a, b) => a.start!.compareTo(b.start!));
    return list;
  }

  List<InlineSpan> _buildSentenceTextSpanChildren(
    String text,
    List<ZhenxieSentenceMemberFocusRangeEntity> ranges,
  ) {
    if (text.isEmpty || ranges.isEmpty) {
      return [TextSpan(text: text)];
    }
    final textLength = text.length;
    final children = <InlineSpan>[];
    int cursor = 0;
    for (final item in ranges) {
      final start = item.start!.clamp(0, textLength);
      final end = item.end!.clamp(0, textLength);
      if (end <= start || start < cursor) continue;
      if (start > cursor) {
        children.add(TextSpan(text: text.substring(cursor, start)));
      }
      children.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.wMin),
            decoration: BoxDecoration(
              color: AppTheme.cZhenxieFontBlue.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4.wMin),
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.cZhenxieFontBlue.color,
                  width: 1.wMin,
                ),
              ),
            ),
            child: Text(
              text.substring(start, end),
              style: TextStyle(
                color: AppTheme.cZhenxieFontPrimary.color,
                fontSize: 24.wMin,
                fontWeight: FontWeight.w600,
                fontFamily: AppFontValue.robotoMono,
              ),
            ),
          ),
        ),
      );
      cursor = end;
    }
    if (cursor < textLength) {
      children.add(TextSpan(text: text.substring(cursor)));
    }
    return children;
  }

  Widget _buildTagWidget({
    required String tagText,
    Color textColor = AppTheme.cZhenxieFontTertiary,
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
              fontFamily: AppFontValue.sourceHanSerifCN,
            ),
          ),
        ],
      ),
    );
  }
}
