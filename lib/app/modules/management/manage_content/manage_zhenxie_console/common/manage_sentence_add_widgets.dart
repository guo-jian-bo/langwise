import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/values/values.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../../common/widgets/zhenxie_widgets/same_group_compare_highlight_text_widget.dart';
import '../../../../../../utils/utils.dart';
import '../../../common/commons.dart';

/// 绑句卡片的页面态模型。
class ManageSentenceAddBindingCardModel {
  /// 当前句位下标，从 0 开始。
  final int index;

  /// 当前句位标题。
  final String title;

  /// 当前句位已绑定的句子摘要。
  final PatternBlueprintSentenceBriefEntity? sentence;

  /// 配对模式下当前格位标识，如 from / to。
  final String? cellKey;

  /// 对照模式下当前格位的 valueNid。
  final String? valueNid;

  /// 对照模式下顶部样句。
  final PatternBlueprintSentenceBriefEntity? exampleSentence;

  /// 对照模式下样句高亮信息。
  final SentencePatternCompareContrastFocusEntity? contrastFocus;

  /// 对照模式下服务端直接返回的高亮区间。
  final List<SentencePatternCompareFocusEntity?>? foci;

  /// 当前句位需要按骨架槽位高亮的槽 key。
  final List<String> highlightSlotKeys;

  /// 蓝图页当前使用的 pattern，用于把受控槽归一到同一个骨架孔位。
  final PatternBlueprintEntity? patternBlueprint;

  const ManageSentenceAddBindingCardModel({
    required this.index,
    required this.title,
    this.sentence,
    this.cellKey,
    this.valueNid,
    this.exampleSentence,
    this.contrastFocus,
    this.foci,
    this.highlightSlotKeys = const [],
    this.patternBlueprint,
  });
}

class ManageSentenceAddTitleWidget extends StatelessWidget {
  final String? desc;
  const ManageSentenceAddTitleWidget({super.key, this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
          Text(
            "添加一组",
            style: TextStyle(
              fontSize: 24.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            desc ?? "先画表，再一格绑一句。空格只在补句时交给系统。",
            style: TextStyle(
              fontSize: 18.wMin,
              color: AppTheme.cTextSecondary.color,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class ManageSentenceAddTableWidget extends StatelessWidget {
  final String? subTitle;
  final String? asset;
  final Widget? child;
  const ManageSentenceAddTableWidget({super.key, this.subTitle, this.asset, this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "1.先画表",
          style: TextStyle(
            fontSize: 18.wMin,
            color: AppTheme.cTextTertiary.color,
            fontWeight: FontWeight.w500,
          ),
        ),
        Visibility(
          visible: subTitle != null,
          child: Container(
            margin: EdgeInsets.only(top: 10.wMin),
            child: Text(
              subTitle ?? "",
              style: TextStyle(
                fontSize: 18.wMin,
                color: AppTheme.cTextSecondary.color,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        SizedBox(height: 10.wMin),
        SizedBox(child: child),
        SizedBox(height: 10.wMin),
        Visibility(
          visible: asset != null,
          child: Container(
            margin: EdgeInsets.only(top: 10.wMin),
            child: Text(
              "资产 ${asset ?? ''}",
              style: TextStyle(
                fontSize: 18.wMin,
                color: AppTheme.cTextTertiary.color,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ManageSentenceAddBingListWidget extends StatelessWidget {
  final int itemCount;
  final Widget Function(int index) itemBuilder;
  const ManageSentenceAddBingListWidget({super.key, required this.itemCount, required this.itemBuilder});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "2.再绑句",
          style: TextStyle(
            fontSize: 18.wMin,
            color: AppTheme.cTextTertiary.color,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 10.wMin),
        // 列表
        Column(
          spacing: 10.wMin,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(itemCount, (index) {
            return itemBuilder(index);
          }),
        ),
      ],
    );
  }
}

class ManageSentenceAddBingWidget extends StatelessWidget {
  final int index;
  final String title;
  final Widget? centerWidget;
  final Widget? bottomWidget;
  final bool hasSentence;
  final bool isClearSentenceEnabled;
  final bool isPickSentenceEnabled;
  final bool isInputUidEnabled;
  final String hasSentenceActionText;
  final void Function()? pickSentence;
  final void Function()? inputUid;
  final void Function()? clearSentence;
  const ManageSentenceAddBingWidget(
      {super.key,
      required this.index,
      required this.title,
      this.centerWidget,
      this.bottomWidget,
      this.hasSentence = false,
      this.isClearSentenceEnabled = true,
      this.isPickSentenceEnabled = true,
      this.isInputUidEnabled = true,
      this.hasSentenceActionText = "换一句",
      this.pickSentence,
      this.inputUid,
      this.clearSentence});

  @override
  Widget build(BuildContext context) {
    return Container(
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
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.wMin,
                  color: AppTheme.cTextSecondary.color,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Expanded(
                child: Container(
                  child: centerWidget,
                ), // 显示不同样式的句子
              ),
              hasSentence
                  ? isClearSentenceEnabled
                      ? ButtonWidget(
                          text: hasSentenceActionText,
                          height: 48.wMin,
                          width: 110.wMin,
                          color: AppTheme.cSurfaceLayerBase.color,
                          border: Border.all(
                            width: 0.8.wMin,
                            color: AppTheme.cBorderSubtle.color,
                          ),
                          fontSize: 20.wMin,
                          fontColor: AppTheme.cTextSecondary.color,
                          fontWeight: FontWeight.w500,
                          sclae: 1.03,
                          onTap: OptimizeUtils.noneThrottle(() {
                            clearSentence?.call();
                          }, 1000),
                        )
                      : Container(
                          width: 110.wMin,
                          alignment: Alignment.center,
                          child: Text(
                            hasSentenceActionText,
                            style: TextStyle(
                              fontSize: 18.wMin,
                              color: AppTheme.cTextTertiary.color,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        )
                  : Row(
                      children: [
                        ButtonWidget(
                          text: "挑一句",
                          height: 48.wMin,
                          width: 110.wMin,
                          color: AppTheme.cSurfaceLayerBase.color,
                          border: Border.all(
                            width: 0.8.wMin,
                            color: AppTheme.cBorderSubtle.color,
                          ),
                          fontSize: 20.wMin,
                          fontColor: AppTheme.cTextSecondary.color.withValues(alpha: isPickSentenceEnabled ? 1 : 0.45),
                          fontWeight: FontWeight.w500,
                          sclae: 1.03,
                          onTap: OptimizeUtils.noneThrottle(() {
                            if (!isPickSentenceEnabled) {
                              return;
                            }
                            pickSentence?.call();
                          }, 1000),
                        ),
                        SizedBox(width: 16.wMin),
                        ButtonWidget(
                          text: "手输uid",
                          height: 48.wMin,
                          width: 110.wMin,
                          color: AppTheme.cSurfaceLayerBase.color,
                          border: Border.all(
                            width: 0.8.wMin,
                            color: AppTheme.cBorderSubtle.color,
                          ),
                          fontSize: 20.wMin,
                          fontColor: AppTheme.cTextSecondary.color.withValues(alpha: isInputUidEnabled ? 1 : 0.45),
                          fontWeight: FontWeight.w500,
                          sclae: 1.03,
                          onTap: OptimizeUtils.noneThrottle(() {
                            if (!isInputUidEnabled) {
                              return;
                            }
                            inputUid?.call();
                          }, 1000),
                        ),
                      ],
                    ),
            ],
          ),
          Visibility(
            visible: bottomWidget != null,
            child: Container(
              margin: EdgeInsets.only(top: 10.wMin),
              child: bottomWidget,
            ),
          ),
        ],
      ),
    );
  }
}

class ManageSentenceAddBingSentenceWidget extends StatelessWidget {
  /// 当前句位的展示态。
  final ManageSentenceAddBindingCardModel model;
  final AlignmentGeometry? alignment;

  const ManageSentenceAddBingSentenceWidget({
    super.key,
    required this.model,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    final PatternBlueprintSentenceBriefEntity? sentence = model.sentence;
    if (sentence == null) {
      return Container();
    }
    final bool useSlotTint = model.highlightSlotKeys.isNotEmpty && sentence.segmentList?.isNotEmpty == true;
    return Container(
      alignment: alignment ?? Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: useSlotTint
                ? ManageSentenceAddSlotTintedSentenceWidget(
                    sentence: sentence,
                    highlightSlotKeys: model.highlightSlotKeys,
                    patternBlueprint: model.patternBlueprint,
                    fontSize: 24.wMin,
                  )
                : Text(
                    sentence.content ?? "",
                    style: TextStyle(
                      fontSize: 24.wMin,
                      color: AppTheme.cTextPrimary.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          Container(
            margin: EdgeInsets.only(left: 10.wMin),
            child: CopyTagWidget(
              name: "句子",
              value: "${sentence.sentenceId ?? ''}",
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildTagWidget({
  //   required String tagText,
  //   Color textColor = AppTheme.cTextSecondary,
  //   Color bgColor = AppTheme.cSurfaceLayerBase,
  //   Color borderColor = AppTheme.cBorderThin,
  // }) {
  //   return Container(
  //     margin: EdgeInsets.only(left: 10.wMin),
  //     height: 28.wMin,
  //     padding: EdgeInsets.symmetric(horizontal: 10.wMin),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(99),
  //       color: bgColor,
  //       border: Border.all(
  //         color: borderColor.withValues(alpha: 0.2),
  //         width: 0.5.wMin,
  //       ),
  //     ),
  //     child: Row(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Text(
  //           tagText,
  //           style: TextStyle(
  //             fontSize: 16.wMin,
  //             fontWeight: FontWeight.w400,
  //             color: textColor,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}

class ManageSentenceAddSlotTintedSentenceWidget extends StatelessWidget {
  /// 当前已绑定句子的完整句子结构。
  final PatternBlueprintSentenceBriefEntity sentence;

  /// 当前骨架中被选中、需要映射到句面的槽位 key。
  final List<String> highlightSlotKeys;

  /// 当前蓝图，用于把受控槽统一折叠到 rendersAs 骨架孔位。
  final PatternBlueprintEntity? patternBlueprint;

  /// 句面字体大小。
  final double fontSize;

  const ManageSentenceAddSlotTintedSentenceWidget({
    super.key,
    required this.sentence,
    required this.highlightSlotKeys,
    this.patternBlueprint,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final String text = sentence.content ?? '';
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }
    final List<_ManageSentenceAddTintFragment> fragmentList = _buildFragmentList(
      text: text,
      segmentList: sentence.segmentList,
      highlightSlotKeys: highlightSlotKeys,
      patternBlueprint: patternBlueprint,
    );
    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          color: AppTheme.cTextPrimary.color,
          fontWeight: FontWeight.w600,
          fontFamily: AppFontValue.robotoMono,
        ),
        children: fragmentList.map((item) {
          if (!item.isHighlight) {
            return TextSpan(text: item.text);
          }
          return WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4.wMin),
                border: Border(
                  bottom: BorderSide(
                    color: item.color.withValues(alpha: 0.8),
                    width: 1.wMin,
                  ),
                ),
              ),
              child: Text(
                item.text,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.cTextPrimary.color,
                  fontFamily: AppFontValue.robotoMono,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 按命中的槽位文本，把整句切成普通片段和高亮片段。
  List<_ManageSentenceAddTintFragment> _buildFragmentList({
    required String text,
    required List<PatternBlueprintSentenceBriefSegmentEntity?>? segmentList,
    required List<String> highlightSlotKeys,
    required PatternBlueprintEntity? patternBlueprint,
  }) {
    final List<_ManageSentenceAddTintCandidate> candidateList = _collectTintCandidateList(
      segmentList: segmentList,
      highlightSlotKeys: highlightSlotKeys,
      patternBlueprint: patternBlueprint,
    );
    if (candidateList.isEmpty) {
      return [_ManageSentenceAddTintFragment(text: text)];
    }

    final List<bool> used = List<bool>.filled(text.length, false);
    final List<_ManageSentenceAddTintRange> rangeList = [];
    candidateList.sort((a, b) => b.text.length.compareTo(a.text.length));
    for (final _ManageSentenceAddTintCandidate item in candidateList) {
      final _ManageSentenceAddTintRange? range = _findSurfaceRange(
        text: text,
        needle: item.text,
        used: used,
        color: item.color,
      );
      if (range != null) {
        rangeList.add(range);
      }
    }
    if (rangeList.isEmpty) {
      return [_ManageSentenceAddTintFragment(text: text)];
    }

    rangeList.sort((a, b) => a.start.compareTo(b.start));
    final List<_ManageSentenceAddTintFragment> resp = [];
    int cursor = 0;
    for (final _ManageSentenceAddTintRange item in rangeList) {
      if (item.start > cursor) {
        resp.add(_ManageSentenceAddTintFragment(text: text.substring(cursor, item.start)));
      }
      resp.add(
        _ManageSentenceAddTintFragment(
          text: text.substring(item.start, item.end),
          isHighlight: true,
          color: item.color,
        ),
      );
      cursor = item.end;
    }
    if (cursor < text.length) {
      resp.add(_ManageSentenceAddTintFragment(text: text.substring(cursor)));
    }
    return resp.where((item) => item.text.isNotEmpty).toList();
  }

  /// 递归收集当前句子里命中 highlightSlotKeys 的叶子 segment 文本。
  List<_ManageSentenceAddTintCandidate> _collectTintCandidateList({
    required List<PatternBlueprintSentenceBriefSegmentEntity?>? segmentList,
    required List<String> highlightSlotKeys,
    required PatternBlueprintEntity? patternBlueprint,
  }) {
    if (segmentList == null || segmentList.isEmpty || highlightSlotKeys.isEmpty) {
      return const [];
    }
    final Set<String> wantedKeys =
        highlightSlotKeys.map((item) => _resolvePatternHoleKey(patternBlueprint, item)).where((item) => item.isNotEmpty).toSet();
    final List<_ManageSentenceAddTintCandidate> resp = [];
    void collect(List<PatternBlueprintSentenceBriefSegmentEntity?>? currentList) {
      if (currentList == null || currentList.isEmpty) {
        return;
      }
      for (final PatternBlueprintSentenceBriefSegmentEntity? segment in currentList) {
        if (segment == null) continue;
        final List<PatternBlueprintSentenceBriefSegmentEntity?>? childList = segment.childStruct?.segmentList;
        if (childList != null && childList.isNotEmpty) {
          collect(childList);
          continue;
        }
        final String text = segment.text?.trim() ?? '';
        if (text.isEmpty) continue;
        final String matchedHoleKey = _resolveMatchedHoleKey(
          segment: segment,
          wantedKeys: wantedKeys,
          patternBlueprint: patternBlueprint,
        );
        if (matchedHoleKey.isEmpty) continue;
        final Color color = ColorUtils.parseColor(segment.slot?.color) ?? AppTheme.cSurfaceBrand.color;
        final bool exists = resp.any(
          (item) => item.text == text && item.color.toARGB32() == color.toARGB32() && item.slotKey == matchedHoleKey,
        );
        if (!exists) {
          resp.add(
            _ManageSentenceAddTintCandidate(
              text: text,
              color: color,
              slotKey: matchedHoleKey,
            ),
          );
        }
      }
    }

    collect(segmentList);
    return resp;
  }

  /// 把受控槽的源 key / rendersAs key 统一折成同一个骨架孔位 key。
  String _resolvePatternHoleKey(PatternBlueprintEntity? patternBlueprint, String? rawKey) {
    final String key = rawKey?.trim() ?? '';
    if (key.isEmpty || patternBlueprint == null) {
      return key;
    }
    for (final PatternBlueprintControlledGrammarSlotEntity? slot in patternBlueprint.controlledGrammarSlots ?? const []) {
      final String slotKey = slot?.slotKey?.trim() ?? '';
      final String rendersAs = slot?.rendersAs?.trim() ?? '';
      if (slotKey == key || rendersAs == key) {
        return rendersAs.isNotEmpty ? rendersAs : slotKey;
      }
    }
    return key;
  }

  /// 在当前 segment 的多个槽位 key 中，找出命中的骨架孔位 key。
  String _resolveMatchedHoleKey({
    required PatternBlueprintSentenceBriefSegmentEntity segment,
    required Set<String> wantedKeys,
    required PatternBlueprintEntity? patternBlueprint,
  }) {
    final List<String> candidateKeys = <String>[
      segment.slotKey ?? '',
      segment.sourceSlotKey ?? '',
      segment.renderSlotKey ?? '',
    ];
    for (final String rawKey in candidateKeys) {
      final String holeKey = _resolvePatternHoleKey(patternBlueprint, rawKey);
      if (holeKey.isNotEmpty && wantedKeys.contains(holeKey)) {
        return holeKey;
      }
    }
    return '';
  }

  /// 在整句中查找某个 segment 文本第一次未占用的命中范围。
  _ManageSentenceAddTintRange? _findSurfaceRange({
    required String text,
    required String needle,
    required List<bool> used,
    required Color color,
  }) {
    final String normalizedNeedle = _foldApostrophe(needle.trim());
    if (normalizedNeedle.isEmpty) {
      return null;
    }
    final String folded = _foldApostrophe(text);
    final String lower = folded.toLowerCase();
    final String target = normalizedNeedle.toLowerCase();
    final bool isClitic = normalizedNeedle.startsWith("'");
    int from = 0;
    while (from <= lower.length - target.length) {
      final int index = lower.indexOf(target, from);
      if (index < 0) {
        return null;
      }
      final int end = index + target.length;
      final bool leftOk = isClitic || !_isWordChar(normalizedNeedle[0]) || index == 0 || !_isWordChar(folded[index - 1]);
      final bool rightOk = !_isWordChar(normalizedNeedle[normalizedNeedle.length - 1]) || end == folded.length || !_isWordChar(folded[end]);
      if (leftOk && rightOk && _claimRange(used: used, start: index, end: end)) {
        return _ManageSentenceAddTintRange(start: index, end: end, color: color);
      }
      from = index + 1;
    }
    return null;
  }

  bool _claimRange({
    required List<bool> used,
    required int start,
    required int end,
  }) {
    if (end <= start) {
      return false;
    }
    if (used.sublist(start, end).any((item) => item)) {
      return false;
    }
    for (int index = start; index < end; index++) {
      used[index] = true;
    }
    return true;
  }

  bool _isWordChar(String value) {
    return RegExp(r"[A-Za-z0-9']").hasMatch(value);
  }

  String _foldApostrophe(String text) {
    return text.replaceAll(RegExp(r"[\u2018\u2019\u02BC]"), "'");
  }
}

class _ManageSentenceAddTintCandidate {
  final String text;
  final Color color;
  final String slotKey;

  const _ManageSentenceAddTintCandidate({
    required this.text,
    required this.color,
    required this.slotKey,
  });
}

class _ManageSentenceAddTintRange {
  final int start;
  final int end;
  final Color color;

  const _ManageSentenceAddTintRange({
    required this.start,
    required this.end,
    required this.color,
  });
}

class _ManageSentenceAddTintFragment {
  final String text;
  final bool isHighlight;
  final Color color;

  const _ManageSentenceAddTintFragment({
    required this.text,
    this.isHighlight = false,
    this.color = AppTheme.cSurfaceBrand,
  });
}

class ManageSentenceAddExampleWidget extends StatelessWidget {
  /// 顶部用于辅助理解当前格位的样句。
  final PatternBlueprintSentenceBriefEntity? sentence;

  /// 对照模式下当前格位的高亮焦点。
  final SentencePatternCompareContrastFocusEntity? contrastFocus;

  /// 对照模式下服务端直接返回的高亮区间。
  final List<SentencePatternCompareFocusEntity?>? foci;

  const ManageSentenceAddExampleWidget({
    super.key,
    this.sentence,
    this.contrastFocus,
    this.foci,
  });

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      color: AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.4),
      strokeWidth: 0.8.wMin,
      dashPattern: [3.wMin, 3.wMin],
      borderType: BorderType.RRect,
      radius: Radius.circular(12.wMin),
      padding: EdgeInsets.zero,
      child: Container(
        padding: EdgeInsets.all(12.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.wMin),
          color: AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTagWidget(tagText: "样句"),
            SizedBox(width: 12.wMin),
            Expanded(
              child: SameGroupCompareHighlightTextWidget(
                sentenceStruct: sentence,
                contrastFocus: contrastFocus,
                foci: foci,
                sentenceId: sentence?.sentenceId,
                fontSize: 24.wMin,
                fontColor: AppTheme.cZhenxieFontPrimary.color,
                contentFontFamily: AppFontValue.robotoMono,
                highlightBackgroundColor: Color(0xffEAB308),
                emptyLabel: "暂无样句",
                showSentenceTag: false,
                isManagement: false,
                showSentenceDefinition: true,
              ),
            ),
          ],
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
      margin: EdgeInsets.only(left: 10.wMin),
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

class ManageSentenceAddButtonsWidget extends StatelessWidget {
  final int bindCount;
  final int totalCount;

  /// 补句落库
  final void Function()? addSentence;

  /// 满句落库
  final void Function()? fullSentence;

  /// 补句落库是否亮起
  final bool isAddSentenceEnabled;

  /// 满句落库是否亮起
  final bool isFullSentenceEnabled;

  /// 构造函数
  const ManageSentenceAddButtonsWidget({
    super.key,
    this.bindCount = 0,
    this.totalCount = 0,
    this.addSentence,
    this.fullSentence,
    this.isAddSentenceEnabled = true,
    this.isFullSentenceEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24.wMin, horizontal: 90.wMin),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.cBorderDefault.color,
            width: 0.8.wMin,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            "已绑 $bindCount/$totalCount",
            style: TextStyle(
              fontSize: 18.wMin,
              color: AppTheme.cTextSecondary.color,
              fontWeight: FontWeight.w400,
            ),
          ),
          Spacer(),
          ButtonWidget(
            text: "取消",
            height: 56.wMin,
            width: 120.wMin,
            color: AppTheme.cSurfaceLayerBase.color,
            border: Border.all(
              width: 0.8.wMin,
              color: AppTheme.cBorderSubtle.color,
            ),
            fontSize: 24.wMin,
            fontColor: AppTheme.cTextSecondary.color,
            fontWeight: FontWeight.w500,
            sclae: 1.03,
            onTap: OptimizeUtils.noneThrottle(() {
              Get.back();
            }, 1000),
          ),
          SizedBox(width: 24.wMin),
          ButtonWidget(
            text: "补句落库",
            height: 56.wMin,
            width: 160.wMin,
            color: AppTheme.cSurfaceSecondary.color,
            border: Border.all(
              width: 0.8.wMin,
              color: AppTheme.cBorderSubtle.color,
            ),
            fontSize: 24.wMin,
            fontColor: AppTheme.cTextSecondary.color.withValues(alpha: isAddSentenceEnabled ? 1 : 0.6),
            fontWeight: FontWeight.w500,
            sclae: 1.03,
            onTap: OptimizeUtils.noneThrottle(() {
              if (!isAddSentenceEnabled) {
                return;
              }
              addSentence?.call();
            }, 1000),
          ),
          SizedBox(width: 24.wMin),
          ButtonWidget(
            text: "满句落库",
            height: 56.wMin,
            width: 160.wMin,
            color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.12),
            border: Border.all(
              width: 0.8.wMin,
              color: AppTheme.cSurfaceBrand.color,
            ),
            fontSize: 24.wMin,
            fontColor: AppTheme.cSurfaceBrand.color.withValues(alpha: isFullSentenceEnabled ? 1 : 0.6),
            fontWeight: FontWeight.w500,
            sclae: 1.03,
            onTap: OptimizeUtils.noneThrottle(() {
              fullSentence?.call();
            }, 1000),
          ),
        ],
      ),
    );
  }
}
