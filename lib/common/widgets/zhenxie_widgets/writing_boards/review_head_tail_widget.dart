import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../entities/entities.dart';
import '../../../enum/enum.dart';
import 'model/writing_board_data.dart';
import 'review_just_text_widget.dart';
import 'review_step_text_widget.dart';
import 'utils/review_board_mark_helper.dart';

/// 批改稿纸的首尾结构区域。
class ReviewHeadTailWidget extends StatelessWidget {
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

  /// 是否按标题头部样式渲染。
  final bool useTitleHeadStyle;

  const ReviewHeadTailWidget({
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
    this.useTitleHeadStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    final headPartData = _resolveFramePartData(role: 'head', fallbackKey: 'head', fallbackText: data.headText ?? '');
    final tailPartData = _resolveFramePartData(role: 'tail', fallbackKey: 'tail', fallbackText: data.tailText ?? '');
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data.showHead) ...[
            Align(
              alignment: useTitleHeadStyle ? Alignment.center : Alignment.centerLeft,
              child: _ReviewFrameBoxWidget(
                key: partItemKeyBuilder?.call(headPartData.partKey, <String>{headPartData.partKey, 'head'}),
                type: useTitleHeadStyle ? '标题格式' : '文首格式',
                title: data.headLabel ?? (useTitleHeadStyle ? '标题' : '称呼'),
                text: headPartData.text,
                fill: headPartData.fill,
                partKey: headPartData.partKey,
                issues: headPartData.issues,
                correctedText: headPartData.correctedText,
                improvedText: headPartData.improvedText,
                markers: markerBundle.markersByPart[headPartData.partKey] ?? const <ReviewBoardMarkerData>[],
                correctionMode: correctionMode,
                showReviewDisplay: showReviewDisplay,
                activeMarkerId: activeMarkerId,
                flashMarkerId: flashMarkerId,
                isFlashing: _isFlashingFramePart(headPartData.partKey, const <String>{'head'}),
                focusAnchors: _resolveFocusAnchors(<String>{headPartData.partKey, 'head'}),
                onSelectMarker: onSelectMarker,
                textStyle: useTitleHeadStyle
                    ? TextStyle(
                        fontSize: 28.wMin,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                        color: Colors.black.withValues(alpha: 0.75),
                      )
                    : null,
                emptyText: '（没写）',
              ),
            ),
            SizedBox(height: 32.wMin),
          ],
          ReviewJustTextWidget(
            data: data,
            memberWriting: memberWriting,
            review: review,
            correctionMode: correctionMode,
            showReviewDisplay: showReviewDisplay,
            markerBundle: markerBundle,
            activeMarkerId: activeMarkerId,
            flashMarkerId: flashMarkerId,
            flashPartKey: flashPartKey,
            focusAnchors: focusAnchors,
            partItemKeyBuilder: partItemKeyBuilder,
            onSelectMarker: onSelectMarker,
            onTapStep: onTapStep,
            onSelectBeatNid: onSelectBeatNid,
          ),
          if (data.showTail) ...[
            SizedBox(height: 32.wMin),
            Align(
              alignment: Alignment.centerRight,
              child: _ReviewFrameBoxWidget(
                key: partItemKeyBuilder?.call(tailPartData.partKey, <String>{tailPartData.partKey, 'tail'}),
                type: '文尾格式',
                title: data.tailLabel ?? '落款',
                text: tailPartData.text,
                fill: tailPartData.fill,
                partKey: tailPartData.partKey,
                issues: tailPartData.issues,
                correctedText: tailPartData.correctedText,
                improvedText: tailPartData.improvedText,
                markers: markerBundle.markersByPart[tailPartData.partKey] ?? const <ReviewBoardMarkerData>[],
                correctionMode: correctionMode,
                showReviewDisplay: showReviewDisplay,
                activeMarkerId: activeMarkerId,
                flashMarkerId: flashMarkerId,
                isFlashing: _isFlashingFramePart(tailPartData.partKey, const <String>{'tail'}),
                focusAnchors: _resolveFocusAnchors(<String>{tailPartData.partKey, 'tail'}),
                onSelectMarker: onSelectMarker,
                emptyText: '（没写）',
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 解析文首 / 文尾真正应该显示的正文内容。
  _ReviewFramePartData _resolveFramePartData({
    required String role,
    required String fallbackKey,
    required String fallbackText,
  }) {
    final parts =
        memberWriting?.parts?.whereType<ZhenxieTaskDetailsMemberWritingPart>().toList() ?? const <ZhenxieTaskDetailsMemberWritingPart>[];
    if (data.mode == WritingBoardModeEnum.correction) {
      for (final part in parts) {
        if ((part.role ?? '') != role) continue;
        final partKey = part.key?.isNotEmpty == true ? part.key! : fallbackKey;
        final aliasKeys = <String>{partKey, fallbackKey, role};
        return _ReviewFramePartData(
          partKey: partKey,
          fill: part.fill ?? 'write',
          text: part.text ?? '',
          issues: _resolvePartIssues(aliasKeys),
          correctedText: _resolveReviewPart(aliasKeys)?.correctedText ?? '',
          improvedText: _resolveReviewPart(aliasKeys)?.improvedText ?? '',
        );
      }
    }
    final aliasKeys = <String>{fallbackKey, role};
    return _ReviewFramePartData(
      partKey: fallbackKey,
      fill: 'write',
      text: fallbackText,
      issues: _resolvePartIssues(aliasKeys),
      correctedText: _resolveReviewPart(aliasKeys)?.correctedText ?? '',
      improvedText: _resolveReviewPart(aliasKeys)?.improvedText ?? '',
    );
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
  ZhenxieTaskDetailsMemberWritingReviewPart? _resolveReviewPart(Set<String> aliasKeys) {
    final parts =
        review?.parts?.whereType<ZhenxieTaskDetailsMemberWritingReviewPart>() ?? const <ZhenxieTaskDetailsMemberWritingReviewPart>[];
    for (final part in parts) {
      if (aliasKeys.contains(part.key ?? '')) return part;
    }
    return null;
  }

  /// 当前文首 / 文尾是否需要闪一下。
  bool _isFlashingFramePart(String partKey, Set<String> aliasKeys) {
    final flashKey = flashPartKey ?? '';
    if (flashKey.isEmpty) return false;
    return flashKey == partKey || aliasKeys.contains(flashKey);
  }

  /// 返回当前首尾正文块命中的 focus anchors。
  List<ZhenxieTaskDetailsMemberWritingReviewAnchor> _resolveFocusAnchors(Set<String> aliasKeys) {
    return focusAnchors.where((item) => aliasKeys.contains(item.partKey ?? '')).toList();
  }
}

/// 批改稿纸里的首尾内容盒子。
class _ReviewFrameBoxWidget extends StatelessWidget {
  /// 盒子类型文案。
  final String type;

  /// 盒子标题文案。
  final String title;

  /// 当前正文块文本。
  final String text;

  /// 当前正文块填充规则。
  final String fill;

  /// 当前正文块 key。
  final String partKey;

  /// 当前正文块对应的 marker 列表。
  final List<ReviewBoardMarkerData> markers;

  /// 当前正文块命中的 issue 列表。
  final List<ZhenxieTaskDetailsMemberWritingReviewIssue> issues;

  /// 当前正文块的订正文案。
  final String correctedText;

  /// 当前正文块的升格文案。
  final String improvedText;

  /// 当前批改稿纸显示模式。
  final ZhenxieTaskCorrectionWritingBoardModeEnum correctionMode;

  /// 当前是否允许展示批改态富文本。
  final bool showReviewDisplay;

  /// 当前选中的 marker id。
  final String? activeMarkerId;

  /// 当前需要闪一下的 marker id。
  final String? flashMarkerId;

  /// 当前是否正在闪动。
  final bool isFlashing;

  /// 当前命中的 focus anchors。
  final List<ZhenxieTaskDetailsMemberWritingReviewAnchor> focusAnchors;

  /// 点击 marker 后的选中回调。
  final void Function(String markerId)? onSelectMarker;

  /// 覆盖默认正文样式。
  final TextStyle? textStyle;

  /// 空内容时的占位文案。
  final String? emptyText;

  const _ReviewFrameBoxWidget({
    super.key,
    required this.type,
    required this.title,
    required this.text,
    required this.fill,
    required this.partKey,
    required this.markers,
    required this.issues,
    required this.correctedText,
    required this.improvedText,
    required this.correctionMode,
    required this.showReviewDisplay,
    this.activeMarkerId,
    this.flashMarkerId,
    this.isFlashing = false,
    this.focusAnchors = const <ZhenxieTaskDetailsMemberWritingReviewAnchor>[],
    this.onSelectMarker,
    this.textStyle,
    this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    final hasMarkers = markers.isNotEmpty;
    final borderColor = isFlashing ? const Color(0xff9A3412) : const Color(0xffCCBCB8).withValues(alpha: hasMarkers ? 0.65 : 0.45);
    final backgroundColor =
        isFlashing ? const Color(0xffF97316).withValues(alpha: 0.12) : const Color(0xffCCBCB8).withValues(alpha: hasMarkers ? 0.16 : 0.12);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: backgroundColor,
        border: Border.all(
          color: borderColor,
          width: 1.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            type,
            style: TextStyle(
              fontSize: 14.wMin,
              fontWeight: FontWeight.w500,
              color: const Color(0xffF97316).withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: 8.wMin),
          Text(
            title,
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w500,
              color: Colors.black.withValues(alpha: 0.8),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 4.wMin),
            child: ReviewBoardAnnotatedTextWidget(
              partKey: partKey,
              fill: fill,
              text: text,
              issues: issues,
              correctedText: correctedText,
              improvedText: improvedText,
              markers: markers,
              correctionMode: correctionMode,
              showReviewDisplay: showReviewDisplay,
              activeMarkerId: activeMarkerId,
              flashMarkerId: flashMarkerId,
              focusAnchors: focusAnchors,
              onSelectMarker: onSelectMarker,
              textStyle: textStyle,
              emptyText: emptyText,
            ),
          ),
        ],
      ),
    );
  }
}

/// 首尾正文块的显示结果。
class _ReviewFramePartData {
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

  const _ReviewFramePartData({
    required this.partKey,
    required this.fill,
    required this.text,
    required this.issues,
    required this.correctedText,
    required this.improvedText,
  });
}
