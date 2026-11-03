import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/theme/theme_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../zhenxie_composition_stages/models/zhenxie_composition_stages_models.dart';

class _BeatDisplayItem {
  final String? fill;
  final String caption;

  const _BeatDisplayItem({
    required this.fill,
    required this.caption,
  });
}

class ZhenxieCompositionSlotStripWidget extends StatelessWidget {
  static const double _edgeBeatWidth = 84;
  static const double _connectorWidth = 24;

  final CompositionStageModel stage;
  final Map<String, ParagraphRhetoricalEntityList> beatMap;
  final List<String> beatOrderList;
  final String Function(List<LanguageText>? values, String lang) langTextGetter;
  final String Function(String? beatNid) beatNameGetter;
  final String Function(CompositionStageModel stage) headLabelGetter;
  final String Function(CompositionStageModel stage) tailLabelGetter;
  final bool Function(CompositionStageModel stage) hasHeadGetter;
  final bool Function(CompositionStageModel stage) hasTailGetter;

  const ZhenxieCompositionSlotStripWidget({
    super.key,
    required this.stage,
    required this.beatMap,
    required this.beatOrderList,
    required this.langTextGetter,
    required this.beatNameGetter,
    required this.headLabelGetter,
    required this.tailLabelGetter,
    required this.hasHeadGetter,
    required this.hasTailGetter,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> middleBeatNids = beatOrderList.where((item) => item.isNotEmpty).toList();
    final Map<String, CompositionStageSlotModel> slotMap = <String, CompositionStageSlotModel>{
      for (final CompositionStageSlotModel slot in stage.slots)
        if ((slot.beatNid ?? '').isNotEmpty) slot.beatNid!: slot,
    };
    final bool hasHead = _hasHead(stage);
    final bool hasTail = _hasTail(stage);
    final String headFill = hasHead ? (stage.headFill ?? 'hidden') : 'hidden';
    final String tailFill = hasTail ? (stage.tailFill ?? 'hidden') : 'hidden';
    final String headCaption = _liveFill(headFill) != null ? (_headLabel(stage).isNotEmpty ? _headLabel(stage) : '文首') : '无';
    final String tailCaption = _liveFill(tailFill) != null ? (_tailLabel(stage).isNotEmpty ? _tailLabel(stage) : '文末') : '无';

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildEdgeBeatSeal('文首', headFill),
            _buildBeatConnector(),
            Expanded(
              child: _buildMiddleBeatGroup(middleBeatNids, slotMap),
            ),
            _buildBeatConnector(),
            _buildEdgeBeatSeal('文末', tailFill),
          ],
        ),
        SizedBox(height: 10.wMin),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: _edgeBeatWidth.wMin,
              child: _buildBeatCaption(headCaption, idle: _liveFill(headFill) == null),
            ),
            SizedBox(width: _connectorWidth.wMin),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.wMin),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: middleBeatNids.map((beatNid) {
                    final _BeatDisplayItem item = _buildBeatDisplayItem(beatNid, slotMap);
                    return SizedBox(
                      width: 48.wMin,
                      child: _buildBeatCaption(item.caption, idle: item.fill == null),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(width: _connectorWidth.wMin),
            SizedBox(
              width: _edgeBeatWidth.wMin,
              child: _buildBeatCaption(tailCaption, idle: _liveFill(tailFill) == null),
            ),
          ],
        ),
    
      ],
    );
  }

  Widget _buildMiddleBeatGroup(
    List<String> middleBeatNids,
    Map<String, CompositionStageSlotModel> slotMap,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.wMin, vertical: 10.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceTranslucentElevated,
        borderRadius: BorderRadius.circular(999.wMin),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: middleBeatNids.map((beatNid) {
          final _BeatDisplayItem item = _buildBeatDisplayItem(beatNid, slotMap);
          return Center(
            child: _buildBeatSeal(
              beatNid,
              _beatSealText(beatNid),
              item.fill,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEdgeBeatSeal(String text, String fill) {
    final bool isWrite = fill == 'write';
    final bool isGiven = fill == 'given';
    final Widget textWidget = Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 20.wMin,
        fontWeight: FontWeight.w500,
        color: isWrite
            ?  AppTheme.cZhenxieFontPrimary
            : isGiven
                ?  AppTheme.cZhenxieFontPrimary
                : AppTheme.cTextTertiary,
      ),
    );
    return SizedBox(
      width: _edgeBeatWidth.wMin,
      height: 76.wMin,
      child: Center(
        child: isGiven
            ? DottedBorder(
                color: AppTheme.cZhenxieFontSecondary,
                strokeWidth: 1.5.wMin,
                borderType: BorderType.RRect,
                radius: Radius.circular(999.wMin),
                dashPattern: [3.wMin, 2.wMin],
                padding: EdgeInsets.zero,
                child: Container(
                  height: 48.wMin,
                  padding: EdgeInsets.symmetric(horizontal: 18.wMin),
                  decoration: BoxDecoration(
                    color: AppTheme.cZhenxieBackgroundPrimary,
                    borderRadius: BorderRadius.circular(999.wMin),
                  ),
                  alignment: Alignment.center,
                  child: textWidget,
                ),
              )
            : Container(
                height: 48.wMin,
                padding: EdgeInsets.symmetric(horizontal: 18.wMin),
                decoration: BoxDecoration(
                  color: isWrite ? AppTheme.cZhenxieBackgroundPrimary : AppTheme.cSurfaceTranslucentElevated,
                  borderRadius: BorderRadius.circular(999.wMin),
                  border: Border.all(
                    color: isWrite ? AppTheme.cZhenxieFontSecondary : AppTheme.cBorderTranslucentDefault,
                    width: 1.wMin,
                  ),
                ),
                alignment: Alignment.center,
                child: textWidget,
              ),
      ),
    );
  }

  Widget _buildBeatConnector() {
    return SizedBox(
      width: _connectorWidth.wMin,
      height: 76.wMin,
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 8.wMin),
          height: 1.wMin,
          color: AppTheme.cZhenxieFontSecondary,
        ),
      ),
    );
  }

  Widget _buildBeatSeal(String beatNid, String text, String? fill) {
    final bool isWrite = fill == 'write';
    final bool isGiven = fill == 'given';
    final Color beatColor = _beatColor(beatNid);
    final Color beatTextColor = _beatTextColor(beatNid);
    final Widget textWidget = Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 20.wMin,
        fontWeight: FontWeight.w500,
        color: isWrite
            ? beatTextColor
            : isGiven
                ? beatColor
                : AppTheme.cTextTertiary.color,
      ),
    );
    if (isGiven) {
      return SizedBox(
        width: 48.wMin,
        height: 48.wMin,
        child: DottedBorder(
          color: beatColor,
          strokeWidth: 1.5.wMin,
          borderType: BorderType.Circle,
          dashPattern: [3.wMin, 2.wMin],
          padding: EdgeInsets.zero,
          child: Container(
            width: 48.wMin,
            height: 48.wMin,
            decoration: BoxDecoration(
              color: AppTheme.cSurfaceTranslucentElevated.color,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: textWidget,
          ),
        ),
      );
    }
    return Container(
      width: 48.wMin,
      height: 48.wMin,
      decoration: BoxDecoration(
        color: isWrite ? beatColor : AppTheme.cSurfaceTranslucentElevated.color,
        shape: BoxShape.circle,
        border: isWrite
            ? null
            : Border.all(
                color: AppTheme.cBorderTranslucentDefault.color,
                width: 1.wMin,
              ),
      ),
      alignment: Alignment.center,
      child: textWidget,
    );
  }

  Widget _buildBeatCaption(String text, {required bool idle}) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16.wMin,
        fontWeight: FontWeight.w400,
        color: idle ? AppTheme.cTextTertiary : AppTheme.cTextSecondary,
      ),
    );
  }

  _BeatDisplayItem _buildBeatDisplayItem(
    String beatNid,
    Map<String, CompositionStageSlotModel> slotMap,
  ) {
    final CompositionStageSlotModel? slot = slotMap[beatNid];
    final CompositionBlueprintSlotModel? blueprintSlot = _findBlueprintSlot(beatNid);
    final bool hasExplicitParagraphType = slot != null && slot.paragraphTypeName.isNotEmpty;
    final bool inBlueprint = hasExplicitParagraphType
        ? true
        : blueprintSlot != null
            ? (blueprintSlot.repeatMax ?? 0) > 0
            : slot != null;
    final String? fill = _liveFill(inBlueprint ? slot?.fill : null);
    if (fill == null || slot == null) {
      return const _BeatDisplayItem(fill: null, caption: '无');
    }
    final String paragraphTypeName = hasExplicitParagraphType
        ? langTextGetter(slot.paragraphTypeName, 'zh')
        : _findParagraphTypeName(blueprintSlot, slot.paragraphTypeNid);
    return _BeatDisplayItem(
      fill: fill,
      caption: paragraphTypeName.isNotEmpty ? paragraphTypeName : '无',
    );
  }

  CompositionBlueprintSlotModel? _findBlueprintSlot(String beatNid) {
    for (final CompositionBlueprintSlotModel slot in stage.compositionBlueprint?.slots ?? const <CompositionBlueprintSlotModel>[]) {
      if (slot.beatNid == beatNid) return slot;
    }
    return null;
  }

  String _findParagraphTypeName(
    CompositionBlueprintSlotModel? blueprintSlot,
    String? paragraphTypeNid,
  ) {
    if (blueprintSlot == null || paragraphTypeNid == null || paragraphTypeNid.isEmpty) return '';
    for (final CompositionBlueprintAllowedParagraphModel item in blueprintSlot.allowedParagraphs) {
      if (item.paragraphTypeNid == paragraphTypeNid) {
        return langTextGetter(item.paragraphTypeName, 'zh');
      }
    }
    return '';
  }

  String _beatSealText(String beatNid) {
    final String name = beatNameGetter(beatNid);
    if (name.isEmpty) return '';
    if (name.contains('·')) return name.split('·').first;
    return name.substring(0, 1);
  }

  String? _liveFill(String? fill) {
    if (fill == 'write' || fill == 'given') return fill;
    return null;
  }

  bool _hasHead(CompositionStageModel stage) {
    if (stage.hasHead != null) return stage.hasHead == true;
    return hasHeadGetter(stage);
  }

  bool _hasTail(CompositionStageModel stage) {
    if (stage.hasTail != null) return stage.hasTail == true;
    return hasTailGetter(stage);
  }

  String _headLabel(CompositionStageModel stage) {
    if (stage.headName.isNotEmpty) {
      return langTextGetter(stage.headName, 'zh');
    }
    return headLabelGetter(stage);
  }

  String _tailLabel(CompositionStageModel stage) {
    if (stage.tailName.isNotEmpty) {
      return langTextGetter(stage.tailName, 'zh');
    }
    return tailLabelGetter(stage);
  }

  Color _beatColor(String beatNid) {
    final String themeKey = ThemeUtils.isCurrentTheme(AppThemeKey.light.value)
        ? AppThemeKey.light.value
        : AppThemeKey.dark.value;
    final ParagraphRhetoricalEntityColorItem? themeColor = beatMap[beatNid]?.findThemeColorItem(themeKey);
    return themeColor?.colorValue ?? beatMap[beatNid]?.colorValue ?? AppTheme.cBorderThin.color;
  }

  Color _beatTextColor(String beatNid) {
    final String themeKey = ThemeUtils.isCurrentTheme(AppThemeKey.light.value)
        ? AppThemeKey.light.value
        : AppThemeKey.dark.value;
    final ParagraphRhetoricalEntityColorItem? themeColor = beatMap[beatNid]?.findThemeColorItem(themeKey);
    return themeColor?.textColorValue ?? AppTheme.cTextInverse.color;
  }
}
