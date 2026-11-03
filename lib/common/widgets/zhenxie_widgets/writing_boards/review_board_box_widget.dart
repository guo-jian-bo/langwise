import 'dart:async';

import 'package:flutter/material.dart';
import 'package:langwise/utils/review_marker_id_utils.dart';

import '../../../entities/entities.dart';
import '../../../enum/enum.dart';
import 'board_box_widget.dart';
import 'board_diary_paper.dart';
import 'board_label_paper.dart';
import 'board_message_note_paper.dart';
import 'board_noise_paper.dart';
import 'board_note.dart';
import 'board_now_messange.dart';
import 'board_report_paper.dart';
import 'board_school_times.dart';
import 'board_speech.dart';
import 'board_table_paper.dart';
import 'board_title_band_paper.dart';
import 'board_unit_paper.dart';
import 'model/writing_board_data.dart';
import 'review_head_tail_widget.dart';
import 'review_just_text_widget.dart';
import 'utils/review_board_mark_helper.dart';
import 'writ_look_image.dart';

/// 批改模式下的左侧稿纸容器。
class ReviewBoardBoxWidget extends StatefulWidget {
  /// 当前写作板基础显示数据。
  final WritingBoardData data;

  /// 当前作答数据，批改态优先从这里读取正文块。
  final ZhenxieTaskDetailsMemberWriting? memberWriting;

  /// 当前批改结果。
  final ZhenxieTaskDetailsMemberWritingReview? review;

  /// 当前批改稿纸显示模式。
  final ZhenxieTaskCorrectionWritingBoardModeEnum correctionMode;

  /// 当前稿纸上选中的 marker id。
  final String? activeMarkerId;

  /// 当前稿纸需要闪一下的 marker。
  final ZhenxieTaskCorrectionPulse? flashMarkerPulse;

  /// 当前稿纸需要闪一下的正文块。
  final ZhenxieTaskCorrectionPulse? flashPartPulse;

  /// 当前需要高亮的一组 focus anchors。
  final List<ZhenxieTaskDetailsMemberWritingReviewAnchor> focusAnchors;

  /// 点击拍位印章。
  final void Function(String beatNid)? onTapStep;

  /// 选中当前拍位。
  final void Function(String beatNid)? onSelectBeatNid;

  /// 点击 marker 后的联动回调。
  final void Function(String markerId)? onSelectMarker;

  const ReviewBoardBoxWidget({
    super.key,
    required this.data,
    this.memberWriting,
    this.review,
    required this.correctionMode,
    this.activeMarkerId,
    this.flashMarkerPulse,
    this.flashPartPulse,
    this.focusAnchors = const <ZhenxieTaskDetailsMemberWritingReviewAnchor>[],
    this.onTapStep,
    this.onSelectBeatNid,
    this.onSelectMarker,
  });

  @override
  State<ReviewBoardBoxWidget> createState() => _ReviewBoardBoxWidgetState();
}

class _ReviewBoardBoxWidgetState extends State<ReviewBoardBoxWidget> {
  /// 当前真实挂在 widget 上的正文块 key，只允许一块内容对应一把 key。
  final Map<String, GlobalKey> _partWidgetKeys = <String, GlobalKey>{};

  /// 当前正文块 alias 到真实 partKey 的映射，仅用于滚动定位查找。
  final Map<String, String> _partAliasKeyMap = <String, String>{};

  /// 当前局部闪动的 marker id。
  String? _flashMarkerId;

  /// 当前局部闪动的正文块 key。
  String? _flashPartKey;

  /// marker 闪动结束计时器。
  Timer? _flashMarkerTimer;

  /// part 闪动结束计时器。
  Timer? _flashPartTimer;

  @override
  void dispose() {
    _flashMarkerTimer?.cancel();
    _flashPartTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ReviewBoardBoxWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final writingChanged = oldWidget.memberWriting != widget.memberWriting;
    final reviewChanged = oldWidget.review != widget.review;
    final modeChanged = oldWidget.correctionMode != widget.correctionMode || oldWidget.data.mode != widget.data.mode;
    if (widget.flashMarkerPulse?.tick != oldWidget.flashMarkerPulse?.tick && (widget.flashMarkerPulse?.id ?? '').isNotEmpty) {
      _startFlashMarker(widget.flashMarkerPulse!.id);
      _scheduleEnsureMarkerVisible(widget.flashMarkerPulse!.id);
    }
    if (widget.activeMarkerId != oldWidget.activeMarkerId && (widget.activeMarkerId ?? '').isNotEmpty) {
      _scheduleEnsureMarkerVisible(widget.activeMarkerId!);
    }
    if (widget.flashPartPulse?.tick != oldWidget.flashPartPulse?.tick && (widget.flashPartPulse?.id ?? '').isNotEmpty) {
      _startFlashPart(widget.flashPartPulse!.id);
      _scheduleEnsurePartVisible(widget.flashPartPulse!.id);
    }
    if (!writingChanged && !reviewChanged && !modeChanged) return;
    _flashMarkerTimer?.cancel();
    _flashPartTimer?.cancel();
    _partWidgetKeys.clear();
    _partAliasKeyMap.clear();
    if (!mounted) return;
    setState(() {
      _flashMarkerId = null;
      _flashPartKey = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: _buildBodyWidget(),
    );
  }

  /// 根据皮肤和批改模式拼装当前稿纸。
  Widget _buildBodyWidget() {
    // 媒体作答在批改态也先走资源展示板，后续再叠加音视频转写区。
    if (!widget.data.answerKindEnum.isText) {
      return WritLookImageWidget(
        data: widget.data,
        memberWriting: widget.memberWriting,
        onTapStep: widget.onTapStep,
        onSelectBeatNid: widget.onSelectBeatNid,
      );
    }
    if (_shouldShowOriginalPaperWidget()) {
      return BoardBoxPaperPhotoWidget(
        mediaData: widget.data.paperImageAnswer,
        materials: widget.data.materials,
        mode: widget.data.mode,
      );
    }
    final markerBundle = buildReviewBoardMarkerBundle(
      parts: widget.memberWriting?.parts?.whereType<ZhenxieTaskDetailsMemberWritingPart>().toList() ??
          const <ZhenxieTaskDetailsMemberWritingPart>[],
      review: widget.review,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final boardBody = _buildBoxWidget(markerBundle, viewportHeight: constraints.maxHeight);
        return _buildScrollableTextBoard(
          boardBody,
          viewportHeight: constraints.maxHeight,
        );
      },
    );
  }

  /// 根据皮肤类型拼装批改态稿纸壳子。
  Widget _buildBoxWidget(ReviewBoardMarkerBundle markerBundle, {double? viewportHeight}) {
    final contentWidget = _buildTextContentWidget(markerBundle);
    SkinNidEnum skinNid = SkinNidEnum.fromSkinNid(widget.data.skinNid ?? '');

    Widget boardWidget;
    if (skinNid == SkinNidEnum.sticky_note) {
      boardWidget = BoardNoteWidget(child: contentWidget);
    } else if (skinNid == SkinNidEnum.name_tag) {
      boardWidget = BoardLabelPaperWidget(child: contentWidget);
    } else if (skinNid == SkinNidEnum.form_blank) {
      boardWidget = BoardTablePaperWidget(child: contentWidget);
    } else if (skinNid == SkinNidEnum.profile_card) {
      boardWidget = BoardTitleBandPaper(child: contentWidget);
    } else if (skinNid == SkinNidEnum.email_client) {
      boardWidget = BoardNowMessangeWidget(child: contentWidget);
    } else if (skinNid == SkinNidEnum.letter_paper) {
      boardWidget = BoardNoisePaperWidget(
        showRuleLines: true,
        child: contentWidget,
      );
    } else if (skinNid == SkinNidEnum.message_slip) {
      boardWidget = BoardMessageNotePaperWidget(child: contentWidget);
    } else if (skinNid == SkinNidEnum.diary_notebook) {
      boardWidget = BoardDiaryPaperWidget(child: contentWidget);
    } else if (skinNid == SkinNidEnum.textbook_page) {
      boardWidget = BoardUnitPaperWidget(child: contentWidget);
    } else if (skinNid == SkinNidEnum.report_paper) {
      boardWidget = BoardReportPaperWidget(child: contentWidget);
    } else if (skinNid == SkinNidEnum.bulletin_board) {
      boardWidget = BoardNoisePaperWidget(
        showPin: true,
        child: contentWidget,
      );
    } else if (skinNid == SkinNidEnum.speech_card) {
      boardWidget = BoardSpeechWidget(child: contentWidget);
    } else if (skinNid == SkinNidEnum.newspaper_column) {
      boardWidget = BoardSchoolTimesWidget(child: contentWidget);
    } else if (skinNid == SkinNidEnum.storybook_spread || skinNid == SkinNidEnum.picture_page) {
      boardWidget = BoardNoisePaperWidget(child: contentWidget);
    } else {
      boardWidget = BoardNoisePaperWidget(child: contentWidget);
    }

    return _buildBoardWithMaterials(boardWidget, viewportHeight: viewportHeight);
  }

  /// 给批改态文本稿纸补上顶部题干素材区。
  Widget _buildBoardWithMaterials(Widget child, {double? viewportHeight}) {
    if (widget.data.materials.isEmpty) return child;
    return WritingBoardMaterialsFillLayout(
      viewportHeight: viewportHeight ?? 0,
      materials: widget.data.materials,
      child: child,
    );
  }

  /// 批改态文本稿纸统一由外层滚动，便于定位和键盘避让保持一致。
  Widget _buildScrollableTextBoard(Widget child, {required double viewportHeight}) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          scrollbars: false,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(left: MediaQuery.of(context).padding.left),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: viewportHeight),
            child: IntrinsicHeight(
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  /// 按当前首版能力选择正文容器。
  Widget _buildTextContentWidget(ReviewBoardMarkerBundle markerBundle) {
    final showReviewDisplay = _shouldShowReviewDisplay();
    final useHeadTailWidget = widget.data.showHead || widget.data.showTail;
    if (!useHeadTailWidget) {
      return ReviewJustTextWidget(
        data: widget.data,
        memberWriting: widget.memberWriting,
        review: widget.review,
        correctionMode: widget.correctionMode,
        showReviewDisplay: showReviewDisplay,
        markerBundle: markerBundle,
        activeMarkerId: widget.activeMarkerId,
        flashMarkerId: _flashMarkerId,
        flashPartKey: _flashPartKey,
        focusAnchors: widget.focusAnchors,
        partItemKeyBuilder: _partItemKey,
        onSelectMarker: widget.onSelectMarker,
        onTapStep: widget.onTapStep,
        onSelectBeatNid: widget.onSelectBeatNid,
      );
    }
    return ReviewHeadTailWidget(
      data: widget.data,
      memberWriting: widget.memberWriting,
      review: widget.review,
      correctionMode: widget.correctionMode,
      showReviewDisplay: showReviewDisplay,
      markerBundle: markerBundle,
      activeMarkerId: widget.activeMarkerId,
      flashMarkerId: _flashMarkerId,
      flashPartKey: _flashPartKey,
      focusAnchors: widget.focusAnchors,
      partItemKeyBuilder: _partItemKey,
      onSelectMarker: widget.onSelectMarker,
      onTapStep: widget.onTapStep,
      onSelectBeatNid: widget.onSelectBeatNid,
      useTitleHeadStyle: _isTitleHeadStyle(widget.data),
    );
  }

  /// 当前是否允许展示批改态富文本。
  bool _shouldShowReviewDisplay() {
    return widget.data.mode == WritingBoardModeEnum.correction && widget.review?.statusEnum == ZhenxieReviewStatusEnum.done;
  }

  /// 当前是否应该直接显示纸面原稿照片。
  bool _shouldShowOriginalPaperWidget() {
    return widget.correctionMode == ZhenxieTaskCorrectionWritingBoardModeEnum.original &&
        widget.memberWriting?.source == ZhenxieTaskTextSubmitModeEnum.paper.value;
  }

  /// 根据头部标签判断当前是否应该按标题样式渲染。
  bool _isTitleHeadStyle(WritingBoardData data) {
    final headLabel = data.headLabel ?? '';
    return data.showHead && (headLabel.contains('标题') || headLabel.toLowerCase().contains('title'));
  }

  /// 启动一次 marker 闪动。
  void _startFlashMarker(String markerId) {
    _flashMarkerTimer?.cancel();
    if (!mounted) return;
    setState(() {
      _flashMarkerId = markerId;
    });
    _flashMarkerTimer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted || _flashMarkerId != markerId) return;
      setState(() {
        _flashMarkerId = null;
      });
    });
  }

  /// 启动一次正文块闪动。
  void _startFlashPart(String partKey) {
    _flashPartTimer?.cancel();
    if (!mounted) return;
    setState(() {
      _flashPartKey = partKey;
    });
    _flashPartTimer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted || _flashPartKey != partKey) return;
      setState(() {
        _flashPartKey = null;
      });
    });
  }

  /// 返回当前正文块用于滚动定位的稳定 key。
  GlobalKey _partItemKey(String partKey, Set<String> aliasKeys) {
    _registerPartAlias(partKey, aliasKeys);
    if (_partWidgetKeys[partKey] case final existingKey?) return existingKey;
    final key = GlobalKey(debugLabel: partKey);
    _partWidgetKeys[partKey] = key;
    return key;
  }

  /// 记录当前正文块可用于查找的 alias，但不让 alias 直接复用 widget key。
  void _registerPartAlias(String partKey, Set<String> aliasKeys) {
    if (partKey.isEmpty) return;
    _partAliasKeyMap[partKey] = partKey;
    for (final aliasKey in aliasKeys) {
      if (aliasKey.isEmpty) continue;
      _partAliasKeyMap.putIfAbsent(aliasKey, () => partKey);
    }
  }

  /// 按 marker 所属正文块滚动到对应区域。
  void _scheduleEnsureMarkerVisible(String markerId) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final partKey = _resolveMarkerPartKey(markerId);
      if (partKey.isEmpty) return;
      final targetContext = _partWidgetKeys[_resolveWidgetPartKey(partKey)]?.currentContext;
      if (targetContext == null) return;
      await Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 220),
        alignment: 0.12,
        curve: Curves.easeOut,
      );
    });
  }

  /// 按正文块 key 滚动到对应区域，文首文尾也走 alias 解析。
  void _scheduleEnsurePartVisible(String partKey) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || partKey.isEmpty) return;
      final targetContext = _partWidgetKeys[_resolveWidgetPartKey(partKey)]?.currentContext;
      if (targetContext == null) return;
      await Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 220),
        alignment: 0.5,
        curve: Curves.easeOut,
      );
    });
  }

  /// 将业务 partKey 或 alias 解析成真正挂在 widget 上的 partKey。
  String _resolveWidgetPartKey(String partKey) {
    if (_partWidgetKeys.containsKey(partKey)) return partKey;
    return _partAliasKeyMap[partKey] ?? partKey;
  }

  /// 根据 marker id 解析所属正文块 key。
  String _resolveMarkerPartKey(String markerId) {
    final issueRows = widget.review?.issues ?? const [];
    final issues = issueRows.whereType<ZhenxieTaskDetailsMemberWritingReviewIssue>().toList();
    for (var sourceIndex = 0; sourceIndex < issues.length; sourceIndex++) {
      final item = issues[sourceIndex];
      if (_stableMarkerId(kind: ZhenxieReviewMarkerKind.issue, id: item.id, anchor: item.anchor, sourceIndex: sourceIndex) != markerId) continue;
      return item.anchor?.partKey ?? '';
    }
    final highlightRows = widget.review?.highlights ?? const [];
    final highlights = highlightRows.whereType<ZhenxieTaskDetailsMemberWritingReviewHighlight>().toList();
    for (var sourceIndex = 0; sourceIndex < highlights.length; sourceIndex++) {
      final item = highlights[sourceIndex];
      if (_stableMarkerId(kind: ZhenxieReviewMarkerKind.highlight, id: item.id, anchor: item.anchor, sourceIndex: sourceIndex) != markerId) continue;
      return item.anchor?.partKey ?? '';
    }
    return '';
  }

  /// 返回和右栏统一口径的 marker 稳定 id。
  String _stableMarkerId({
    required ZhenxieReviewMarkerKind kind,
    String? id,
    ZhenxieTaskDetailsMemberWritingReviewAnchor? anchor,
    required int sourceIndex,
  }) {
    if (anchor == null) return '';
    return buildZhenxieReviewMarkerId(
      kind: kind,
      rawId: id,
      anchor: anchor,
      sourceIndex: sourceIndex,
    );
  }
}
