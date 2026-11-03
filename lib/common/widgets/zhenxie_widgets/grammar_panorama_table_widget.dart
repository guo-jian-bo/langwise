import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../app/modules/management/common/commons.dart';
import '../../../theme/theme.dart';
import '../../entities/entities.dart';
import '../../enum/enum.dart';
import '../widgets.dart';

class GrammarPanoramaMinTableWidget extends StatelessWidget {
  final List<ManageGrammarPanoramaAxisEntity?>? axes;
  final List<ManageGrammarPanoramaCellEntity?>? cells;

  /// 语法全景表 - 小
  const GrammarPanoramaMinTableWidget({super.key, this.axes, this.cells});

  @override
  Widget build(BuildContext context) {
    final rowAxis = axes?.isNotEmpty == true ? axes?.first : null;
    final colAxis = axes != null && axes!.length > 1 ? axes![1] : null;
    final rowValues = rowAxis?.values?.whereType<String>().toList() ?? [];
    final colValues = colAxis?.values?.whereType<String>().toList() ?? [];
    if (rowAxis == null || colAxis == null || rowValues.isEmpty || colValues.isEmpty || (cells?.isEmpty ?? true)) {
      return const SizedBox.shrink();
    }
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        border: Border.all(
          color: AppTheme.cBorderSubtle.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleWidget(rowAxis, colAxis),
          _buildTableWidget(rowAxis, colAxis, rowValues, colValues),
        ],
      ),
    );
  }

  Widget _buildTitleWidget(ManageGrammarPanoramaAxisEntity rowAxis, ManageGrammarPanoramaAxisEntity colAxis) {
    final rowTitle = LearningLangUtils.getLocalLang(rowAxis.dimension?.name)?.text ?? '';
    final colTitle = LearningLangUtils.getLocalLang(colAxis.dimension?.name)?.text ?? '';
    return Container(
      padding: EdgeInsets.all(16.wMin),
      child: Text(
        "$rowTitle × $colTitle",
        style: TextStyle(
          fontSize: 20.wMin,
          fontWeight: FontWeight.w500,
          color: AppTheme.cTextSecondary.color,
        ),
      ),
    );
  }

  Widget _buildTableWidget(
    ManageGrammarPanoramaAxisEntity rowAxis,
    ManageGrammarPanoramaAxisEntity colAxis,
    List<String> rowValues,
    List<String> colValues,
  ) {
    final rowLabelMap = _buildAxisValueLabelMap(rowAxis.valuesLabels);
    final colLabelMap = _buildAxisValueLabelMap(colAxis.valuesLabels);
    final cellLabelMap = _buildCellLabelMap(cells);
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.cBorderSubtle.color,
            width: 1.wMin,
          ),
        ),
      ),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                _buildTableLeftUnitWidget(""),
                ...List.generate(colValues.length, (index) {
                  final value = colValues[index];
                  return _buildTableTitleUnitWidget(colLabelMap[value] ?? '', isLast: index == colValues.length - 1);
                }),
              ],
            ),
          ),
          Column(
              children: List.generate(rowValues.length, (index) {
            final rowValue = rowValues[index];
            return _buildTableRowItemWidget(
              rowLabel: rowLabelMap[rowValue] ?? '',
              colValues: colValues,
              rowValue: rowValue,
              cellLabelMap: cellLabelMap,
            );
          })),
        ],
      ),
    );
  }

  Widget _buildTableRowItemWidget({
    required String rowLabel,
    required List<String> colValues,
    required String rowValue,
    required Map<String, String> cellLabelMap,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.cBorderSubtle.color,
            width: 1.wMin,
          ),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _buildTableLeftUnitWidget(rowLabel),
            ...List.generate(colValues.length, (index) {
              final colValue = colValues[index];
              return _buildTableItemUnitWidget(cellLabelMap["$rowValue|$colValue"] ?? '', isLast: index == colValues.length - 1);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTableLeftUnitWidget(String text) {
    return Container(
      width: 120.wMin,
      padding: EdgeInsets.all(16.wMin),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border(
          right: BorderSide(
            color: AppTheme.cBorderSubtle.color,
            width: 1.wMin,
          ),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 20.wMin,
          fontWeight: FontWeight.w500,
          color: AppTheme.cTextPrimary.color,
        ),
      ),
    );
  }

  Widget _buildTableTitleUnitWidget(String text, {bool isLast = false}) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.wMin),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceLayerBase.color,
          border: isLast
              ? null
              : Border(
                  right: BorderSide(
                    color: AppTheme.cBorderSubtle.color,
                    width: 1.wMin,
                  ),
                ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 20.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
      ),
    );
  }

  Widget _buildTableItemUnitWidget(String text, {bool isLast = false}) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.wMin),
        alignment: Alignment.center,
        decoration: isLast
            ? null
            : BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: AppTheme.cBorderSubtle.color,
                    width: 1.wMin,
                  ),
                ),
              ),
        child: SelectableText(
          text,
          style: TextStyle(
            fontSize: 16.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextSecondary.color,
          ),
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

  Map<String, String> _buildCellLabelMap(List<ManageGrammarPanoramaCellEntity?>? cells) {
    final map = <String, String>{};
    for (final item in cells ?? []) {
      final key = item?.key;
      final text = LearningLangUtils.getLocalLang(item?.label)?.text;
      if (key?.isNotEmpty == true && text?.isNotEmpty == true) {
        map[key!] = text!;
      }
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
  final List<GrammarPanoramaExampleEntity> exampleList;

  /// 组上下架回调
  final void Function(GrammarPanoramaExampleEntity group)? onShelfChange;
  /// 组删除回调
  final void Function(GrammarPanoramaExampleEntity group)? onDelete;

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

  Widget _buildContentWidget(GrammarPanoramaExampleEntity example, int index) {
    return Container(
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceLayerElevated.color,
        border: Border.all(
          color: AppTheme.cBorderThin.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "宫格${widget.exampleList.length > 1 ? index + 1 : ''}",
                style: TextStyle(
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextPrimary.color,
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
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.cSurfaceTertiary.color,
                    borderRadius: BorderRadius.circular(6.wMin),
                  ),
                  child: Row(
                    children: [
                      Visibility(
                        visible: widget.onShelfChange != null,
                        child: ListingAndDelistingWidget(
                          value: example.isNormal,
                          showBorder: widget.onDelete != null,
                          onChange: () {
                            widget.onShelfChange?.call(example);
                          },
                        ),
                      ),
                      Visibility(
                        visible: widget.onDelete != null,
                        child: Container(
                          margin: EdgeInsets.only(left: widget.onDelete != null ? 8.wMin : 0),
                          child: TapScaleWidget(
                            onTap: () async {
                              widget.onDelete?.call(example);
                            },
                            sclae: 1,
                            borderRadius: 8.wMin,
                            backColor: AppTheme.cSurfaceTertiary.color,
                            child: Container(
                              width: 50.wMin,
                              height: 40.wMin,
                              alignment: Alignment.center,
                              child: SvgPicture.asset(
                                "assets/svg/public/icon_delete.svg",
                                width: 24.wMin,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Visibility(
              //   visible: widget.isManagement,
              //   child: Row(
              //     children: [
              //       _buildButtonWidget(
              //         text: "删除",
              //         color: AppTheme.cSurfaceError.color,
              //       ),
              //       SizedBox(width: 8.wMin),
              //       _buildButtonWidget(
              //         text: "编辑",
              //         color: AppTheme.cTextSecondary.color,
              //       ),
              //       SizedBox(width: 8.wMin),
              //       _buildButtonWidget(
              //         text: "上架",
              //         color: AppTheme.cSurfaceSuccess.color,
              //       ),
              //       SizedBox(width: 8.wMin),
              //       _buildButtonWidget(
              //         text: "练习",
              //         color: AppTheme.cSurfaceBrand.color,
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
          SizedBox(height: 16.wMin),
          _buildTableWidget(example),
        ],
      ),
    );
  }

  /// 填充当前示例对应的表格内容。
  Widget _buildTableWidget(GrammarPanoramaExampleEntity example) {
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
    final exampleItemMap = _buildExampleItemMap(example.memberList);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        border: Border.all(
          color: AppTheme.cBorderSubtle.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                _buildTableLeftUnitWidget("", ""),
                ...List.generate(colValues.length, (index) {
                  final value = colValues[index];
                  return _buildTableTitleUnitWidget(
                    colLabelMap[value] ?? '',
                    value,
                    isLast: index == colValues.length - 1,
                  );
                }),
              ],
            ),
          ),
          Column(
            children: List.generate(rowValues.length, (index) {
              final rowValue = rowValues[index];
              return _buildTableRowItemWidget(
                rowLabel: rowLabelMap[rowValue] ?? '',
                rowValue: rowValue,
                colValues: colValues,
                cellMap: cellMap,
                exampleItemMap: exampleItemMap,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTableLeftUnitWidget(String text, String sub) {
    return Container(
      width: 120.wMin,
      padding: EdgeInsets.all(10.wMin),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.06),
        border: Border(
          right: BorderSide(
            color: AppTheme.cBorderSubtle.color,
            width: 1.wMin,
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          Text(
            sub,
            style: TextStyle(
              fontSize: 14.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableTitleUnitWidget(String text, String sub, {bool isLast = false}) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(10.wMin),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.06),
          border: isLast
              ? null
              : Border(
                  right: BorderSide(
                    color: AppTheme.cBorderSubtle.color,
                    width: 1.wMin,
                  ),
                ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 20.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
            Text(
              sub,
              style: TextStyle(
                fontSize: 14.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextTertiary.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableRowItemWidget({
    required String rowLabel,
    required String rowValue,
    required List<String> colValues,
    required Map<String, ManageGrammarPanoramaCellEntity> cellMap,
    required Map<String, GrammarPanoramaExampleMemberListItemEntity> exampleItemMap,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.cBorderSubtle.color,
            width: 1.wMin,
          ),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _buildTableLeftUnitWidget(rowLabel, rowValue),
            ...List.generate(colValues.length, (index) {
              final colValue = colValues[index];
              final cell = cellMap["$rowValue|$colValue"];
              final exampleItem = cell?.key == null ? null : exampleItemMap[cell!.key!];
              return _buildTableItemUnitWidget(
                cellLabel: LearningLangUtils.getLocalLang(cell?.label)?.text ?? '',
                content: exampleItem?.sentence?.content ?? '',
                definition: exampleItem?.sentence?.definition ?? '',
                ranges: _getCurrentFocusRanges(exampleItem?.foci),
                isLast: index == colValues.length - 1,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTableItemUnitWidget({
    required String cellLabel,
    required String content,
    required String definition,
    required List<GrammarPanoramaExampleRangeEntity> ranges,
    bool isLast = false,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.wMin),
        alignment: Alignment.center,
        decoration: isLast
            ? null
            : BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: AppTheme.cBorderSubtle.color,
                    width: 1.wMin,
                  ),
                ),
              ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              spacing: 8.wMin,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6.wMin,
                  height: 6.wMin,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.8),
                  ),
                ),
                SelectableText(
                  cellLabel,
                  style: TextStyle(
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.wMin),
            SelectableText.rich(
              TextSpan(
                style: TextStyle(
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextPrimary.color,
                ),
                children: _buildSentenceTextSpanChildren(content, ranges),
              ),
            ),
            SizedBox(height: 6.wMin),
            SelectableText(
              definition,
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextTertiary.color,
              ),
            ),
          ],
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

  Map<String, GrammarPanoramaExampleMemberListItemEntity> _buildExampleItemMap(
    List<GrammarPanoramaExampleMemberListItemEntity?>? memberList,
  ) {
    final map = <String, GrammarPanoramaExampleMemberListItemEntity>{};
    for (final item in memberList ?? []) {
      final valueNid = item?.valueNid;
      if (valueNid?.isNotEmpty != true || item == null) continue;
      map[valueNid!] = item;
    }
    return map;
  }

  List<GrammarPanoramaExampleRangeEntity> _getCurrentFocusRanges(
    List<GrammarPanoramaExampleFocusEntity?>? foci,
  ) {
    final currentFocus = widget.focusKey;
    if (currentFocus == null) return const [];
    GrammarPanoramaExampleFocusEntity? focusEntity;
    for (final item in foci ?? []) {
      if (item?.focusKeyEnum == currentFocus) {
        focusEntity = item;
        break;
      }
    }
    final list = <GrammarPanoramaExampleRangeEntity>[];
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
    List<GrammarPanoramaExampleRangeEntity> ranges,
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
        TextSpan(
          text: text.substring(start, end),
          style: TextStyle(
            color: AppTheme.cSurfaceWarning.color,
            height: 1.4,
            backgroundColor: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.12),
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

  // Widget _buildButtonWidget({
  //   required String text,
  //   void Function()? onTap,
  //   Color color = AppTheme.cTextSecondary,
  // }) {
  //   return ButtonWidget(
  //     text: text,
  //     sclae: 1.03,
  //     onTap: onTap,
  //     padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 6.wMin),
  //     borderRadius: 6.wMin,
  //     color: color.withValues(alpha: 0.12),
  //     border: Border.all(
  //       color: color.withValues(alpha: 0.2),
  //       width: 1.wMin,
  //     ),
  //     fontSize: 16.wMin,
  //     fontColor: color,
  //     fontWeight: FontWeight.w500,
  //   );
  // }

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
