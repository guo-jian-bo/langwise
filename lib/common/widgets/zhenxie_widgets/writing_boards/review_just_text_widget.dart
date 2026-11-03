import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../entities/entities.dart';
import '../../../enum/enum.dart';
import 'model/writing_board_data.dart';
import 'review_step_text_widget.dart';
import 'utils/review_board_mark_helper.dart';

/// 批改稿纸的纯正文区域。
class ReviewJustTextWidget extends StatelessWidget {
  /// 当前写作板基础显示数据。
  final WritingBoardData data;

  /// 当前作答数据，批改态优先从这里读取正文块。
  final ZhenxieTaskDetailsMemberWriting? memberWriting;

  /// 当前批改结果。
  final ZhenxieTaskDetailsMemberWritingReview? review;

  /// 当前批改稿纸显示模式。
  final ZhenxieTaskCorrectionWritingBoardModeEnum correctionMode;

  /// 当前是否允许展示批改态富文本。
  final bool showReviewDisplay;

  /// 当前全部 marker 分组结果。
  final ReviewBoardMarkerBundle markerBundle;

  /// 当前选中的 marker id。
  final String? activeMarkerId;

  /// 当前需要闪一下的 marker id。
  final String? flashMarkerId;

  /// 当前需要闪一下的正文块 key。
  final String? flashPartKey;

  /// 当前需要高亮的一组 focus anchors。
  final List<ZhenxieTaskDetailsMemberWritingReviewAnchor> focusAnchors;

  /// 返回当前正文块用于滚动定位的 key。
  final GlobalKey Function(String partKey, Set<String> aliasKeys)? partItemKeyBuilder;

  /// 点击 marker 后的选中回调。
  final void Function(String markerId)? onSelectMarker;

  /// 点击拍位印章。
  final void Function(String beatNid)? onTapStep;

  /// 选中当前拍位。
  final void Function(String beatNid)? onSelectBeatNid;

  const ReviewJustTextWidget({
    super.key,
    required this.data,
    required this.memberWriting,
    required this.review,
    required this.correctionMode,
    required this.showReviewDisplay,
    required this.markerBundle,
    this.activeMarkerId,
    this.flashMarkerId,
    this.flashPartKey,
    this.focusAnchors = const <ZhenxieTaskDetailsMemberWritingReviewAnchor>[],
    this.partItemKeyBuilder,
    this.onSelectMarker,
    this.onTapStep,
    this.onSelectBeatNid,
  });

  @override
  Widget build(BuildContext context) {
    final displayItems = _buildDisplayItems();
    return Column(
      spacing: 32.wMin,
      children: displayItems.map((item) {
        final partData = item.partData;
        return ReviewStepTextWidget(
          key: partItemKeyBuilder?.call(partData.partKey, item.aliasKeys),
          data: item.step,
          partKey: partData.partKey,
          fill: partData.fill,
          text: partData.text,
          issues: partData.issues,
          correctedText: partData.correctedText,
          improvedText: partData.improvedText,
          markers: markerBundle.markersByPart[partData.partKey] ?? const <ReviewBoardMarkerData>[],
          correctionMode: correctionMode,
          showReviewDisplay: showReviewDisplay,
          activeMarkerId: activeMarkerId,
          flashMarkerId: flashMarkerId,
          isFlashingPart: item.aliasKeys.any((key) => flashPartKey == key),
          focusAnchors: _resolveFocusAnchors(item.aliasKeys),
          showBeatStamp: item.showBeatStamp,
          onSelectMarker: onSelectMarker,
          onTapStep: item.showBeatStamp ? onTapStep : null,
          onSelectBeatNid: item.showBeatStamp ? onSelectBeatNid : null,
        );
      }).toList(),
    );
  }

  /// 按当前模式拼出正文显示列表，纸上写批改态直接按真实 parts 渲染。
  List<_ReviewBoardDisplayItem> _buildDisplayItems() {
    if (data.mode != WritingBoardModeEnum.correction) {
      return data.steps.map((step) {
        final partData = _resolveStepPartData(step);
        return _ReviewBoardDisplayItem(
          step: step,
          partData: partData,
          aliasKeys: <String>{partData.partKey, step.beatNid},
          showBeatStamp: _containsRhetoricalKey(step.beatNid),
        );
      }).toList();
    }
    final parts =
        memberWriting?.parts?.whereType<ZhenxieTaskDetailsMemberWritingPart>().toList() ?? const <ZhenxieTaskDetailsMemberWritingPart>[];
    final contentParts = parts.where((item) {
      final role = item.role ?? '';
      return role == 'beat' || role == 'body';
    }).toList();
    if (contentParts.isEmpty) {
      return data.steps.map((step) {
        final partData = _resolveStepPartData(step);
        return _ReviewBoardDisplayItem(
          step: step,
          partData: partData,
          aliasKeys: <String>{partData.partKey, step.beatNid},
          showBeatStamp: _containsRhetoricalKey(step.beatNid),
        );
      }).toList();
    }
    return contentParts.map(_buildCorrectionDisplayItem).toList();
  }

  /// 把单个批改态正文块映射成稿纸上的显示数据。
  _ReviewBoardDisplayItem _buildCorrectionDisplayItem(ZhenxieTaskDetailsMemberWritingPart part) {
    final step = _resolveStepForPart(part);
    final partKey = part.key?.isNotEmpty == true ? part.key! : step.beatNid;
    final aliasKeys = <String>{partKey};
    if ((part.beatNid ?? '').isNotEmpty) aliasKeys.add(part.beatNid!);
    if ((part.role ?? '') == 'beat') aliasKeys.add(step.beatNid);
    final partData = _ReviewBoardPartData(
      partKey: partKey,
      fill: part.fill ?? step.fill,
      text: part.text ?? '',
      issues: _resolvePartIssues(aliasKeys),
      correctedText: _resolveReviewPart(
            aliasKeys: aliasKeys,
            writePartIndex: _resolveWritePartIndex(
              memberWriting?.parts?.whereType<ZhenxieTaskDetailsMemberWritingPart>().toList() ??
                  const <ZhenxieTaskDetailsMemberWritingPart>[],
              part,
            ),
          )?.correctedText ??
          '',
      improvedText: _resolveReviewPart(
            aliasKeys: aliasKeys,
            writePartIndex: _resolveWritePartIndex(
              memberWriting?.parts?.whereType<ZhenxieTaskDetailsMemberWritingPart>().toList() ??
                  const <ZhenxieTaskDetailsMemberWritingPart>[],
              part,
            ),
          )?.improvedText ??
          '',
    );
    return _ReviewBoardDisplayItem(
      step: step,
      partData: partData,
      aliasKeys: aliasKeys,
      showBeatStamp: (part.role ?? '') == 'beat' && _containsRhetoricalKey(step.beatNid),
    );
  }

  /// 解析当前拍位真正应该显示的正文内容。
  _ReviewBoardPartData _resolveStepPartData(WritingBoardStepData step) {
    final parts =
        memberWriting?.parts?.whereType<ZhenxieTaskDetailsMemberWritingPart>().toList() ?? const <ZhenxieTaskDetailsMemberWritingPart>[];
    if (data.mode == WritingBoardModeEnum.correction) {
      for (final part in parts) {
        final sameKey = (part.key ?? '') == step.beatNid;
        final sameBeat = (part.role ?? '') == 'beat' && (part.beatNid ?? '') == step.beatNid;
        if (!sameKey && !sameBeat) continue;
        final partKey = part.key?.isNotEmpty == true ? part.key! : step.beatNid;
        final aliasKeys = <String>{partKey, step.beatNid};
        return _ReviewBoardPartData(
          partKey: partKey,
          fill: part.fill ?? step.fill,
          text: part.text ?? '',
          issues: _resolvePartIssues(aliasKeys),
          correctedText: _resolveReviewPart(
                aliasKeys: aliasKeys,
                writePartIndex: _resolveWritePartIndex(parts, part),
              )?.correctedText ??
              '',
          improvedText: _resolveReviewPart(
                aliasKeys: aliasKeys,
                writePartIndex: _resolveWritePartIndex(parts, part),
              )?.improvedText ??
              '',
        );
      }
    }
    final aliasKeys = <String>{step.beatNid};
    return _ReviewBoardPartData(
      partKey: step.beatNid,
      fill: step.fill,
      text: step.text ?? '',
      issues: _resolvePartIssues(aliasKeys),
      correctedText: _resolveReviewPart(aliasKeys: aliasKeys)?.correctedText ?? '',
      improvedText: _resolveReviewPart(aliasKeys: aliasKeys)?.improvedText ?? '',
    );
  }

  /// 根据正文块找到当前应该沿用的拍位显示数据。
  WritingBoardStepData _resolveStepForPart(ZhenxieTaskDetailsMemberWritingPart part) {
    final beatNid = part.beatNid ?? '';
    for (final step in data.steps) {
      if (beatNid.isNotEmpty && step.beatNid == beatNid) return step;
      if ((part.key ?? '') == step.beatNid) return step;
    }
    return WritingBoardStepData(
      beatNid: part.key ?? beatNid,
      beatLabel: '',
      fill: part.fill ?? 'write',
      text: part.text ?? '',
    );
  }

  /// 当前 key 是否来自段落修辞拍位配置。
  bool _containsRhetoricalKey(String? key) {
    if ((key ?? '').isEmpty) return false;
    return data.steps.any((item) => item.beatNid == key);
  }

  /// 返回当前正文块命中的全部 issue。
  List<ZhenxieTaskDetailsMemberWritingReviewIssue> _resolvePartIssues(Set<String> partKeys) {
    return review?.issues
            ?.whereType<ZhenxieTaskDetailsMemberWritingReviewIssue>()
            .where((item) => partKeys.contains(item.anchor?.partKey ?? ''))
            .toList() ??
        const <ZhenxieTaskDetailsMemberWritingReviewIssue>[];
  }

  /// 返回当前正文块的订正 / 升格结果。
  ZhenxieTaskDetailsMemberWritingReviewPart? _resolveReviewPart({
    required Set<String> aliasKeys,
    int? writePartIndex,
  }) {
    final parts = review?.parts?.whereType<ZhenxieTaskDetailsMemberWritingReviewPart>().toList() ??
        const <ZhenxieTaskDetailsMemberWritingReviewPart>[];
    for (final part in parts) {
      if (aliasKeys.contains(part.key ?? '')) return part;
    }
    if (writePartIndex != null && writePartIndex >= 0 && writePartIndex < parts.length) return parts[writePartIndex];
    return null;
  }

  /// 返回当前 write part 在整篇 write parts 里的顺序。
  int? _resolveWritePartIndex(
    List<ZhenxieTaskDetailsMemberWritingPart> parts,
    ZhenxieTaskDetailsMemberWritingPart currentPart,
  ) {
    final writeParts = parts.where((item) => (item.fill ?? '') == 'write').toList();
    for (var index = 0; index < writeParts.length; index++) {
      if (identical(writeParts[index], currentPart)) return index;
    }
    return null;
  }

  /// 返回当前正文块命中的 focus anchors。
  List<ZhenxieTaskDetailsMemberWritingReviewAnchor> _resolveFocusAnchors(Set<String> aliasKeys) {
    return focusAnchors.where((item) {
      final key = item.partKey ?? '';
      return aliasKeys.contains(key);
    }).toList();
  }
}

/// 单个正文块在稿纸里的显示项。
class _ReviewBoardDisplayItem {
  /// 当前显示项对应的拍位展示数据。
  final WritingBoardStepData step;

  /// 当前显示项的正文数据。
  final _ReviewBoardPartData partData;

  /// 当前显示项可用于定位 / 匹配批改锚点的全部 key。
  final Set<String> aliasKeys;

  /// 当前显示项是否显示左侧拍位印章。
  final bool showBeatStamp;

  const _ReviewBoardDisplayItem({
    required this.step,
    required this.partData,
    required this.aliasKeys,
    required this.showBeatStamp,
  });
}

/// 单个正文块的显示结果。
class _ReviewBoardPartData {
  /// 正文块 key。
  final String partKey;

  /// 正文块填充规则。
  final String fill;

  /// 正文块文本。
  final String text;

  /// 当前正文块命中的 issue 列表。
  final List<ZhenxieTaskDetailsMemberWritingReviewIssue> issues;

  /// 当前正文块的订正文案。
  final String correctedText;

  /// 当前正文块的升格文案。
  final String improvedText;

  const _ReviewBoardPartData({
    required this.partKey,
    required this.fill,
    required this.text,
    required this.issues,
    required this.correctedText,
    required this.improvedText,
  });
}
