import 'package:flutter/widgets.dart';

import '../../../enum/enum.dart';
import 'writing_boards.dart';

class BoardBoxWidget extends StatefulWidget {
  final WritingBoardData data;
  final bool isManagement;
  final WritingBoardRuntimeState? runtimeState;
  final WritingBoardControllers? controllers;
  final WritingBoardFrameSectionType? highlightedFrameSection;
  final void Function(WritingBoardFrameSectionType type)? onTapFrameSection;
  final void Function(String beatNid)? onTapStep;
  final void Function(String beatNid)? onSelectBeatNid;
  final void Function(String beatNid)? onRequestStepFocus;
  final void Function(String beatNid, String text)? onStepTextChanged;
  final void Function(String text)? onHeadChanged;
  final void Function(String text)? onTailChanged;
  final void Function(List<WritingBoardMediaItemData> items)? onImageItemsChanged;
  final void Function(List<WritingBoardMediaItemData> items)? onVideoItemsChanged;
  final void Function(List<WritingBoardMediaItemData> items)? onAudioItemsChanged;
  const BoardBoxWidget({
    super.key,
    required this.data,
    this.isManagement = false,
    this.runtimeState,
    this.controllers,
    this.highlightedFrameSection,
    this.onTapFrameSection,
    this.onTapStep,
    this.onSelectBeatNid,
    this.onRequestStepFocus,
    this.onStepTextChanged,
    this.onHeadChanged,
    this.onTailChanged,
    this.onImageItemsChanged,
    this.onVideoItemsChanged,
    this.onAudioItemsChanged,
  });

  @override
  State<BoardBoxWidget> createState() => _BoardBoxWidgetState();
}

class _BoardBoxWidgetState extends State<BoardBoxWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: _buildBodyWidget(),
    );
  }

  Widget _buildBodyWidget() {
    final skinNid = _parseSkinNid(widget.data.skinNid);
    final answerKind = widget.data.answerKind ?? "text";

    if (skinNid == SkinNidEnum.sticky_note) {
      return BoardNoteWidget(
        child: _buildTextContentWidget(),
      );
    } else if (skinNid == SkinNidEnum.name_tag) {
      return BoardLabelPaperWidget(
        child: _buildTextContentWidget(),
      );
    } else if (skinNid == SkinNidEnum.form_blank) {
      return BoardTablePaperWidget(
        child: _buildTextContentWidget(),
      ); // 标签(填写)
    } else if (skinNid == SkinNidEnum.profile_card) {
      return BoardTitleBandPaper(
        child: _buildTextContentWidget(),
      );
    } else if (skinNid == SkinNidEnum.email_client) {
      return BoardNowMessangeWidget(
        child: _buildTextContentWidget(),
      );
    } else if (skinNid == SkinNidEnum.letter_paper) {
      return BoardNoisePaperWidget(
        showRuleLines: true,
        child: _buildTextContentWidget(),
      );
    } else if (skinNid == SkinNidEnum.message_slip) {
      return BoardMessageNotePaperWidget(
        child: _buildTextContentWidget(),
      );
    } else if (skinNid == SkinNidEnum.diary_notebook) {
      return BoardDiaryPaperWidget(
        child: _buildTextContentWidget(),
      );
    } else if (skinNid == SkinNidEnum.textbook_page) {
      return BoardUnitPaperWidget(
        child: _buildTextContentWidget(),
      );
    } else if (skinNid == SkinNidEnum.report_paper) {
      return BoardReportPaperWidget(
        child: _buildTextContentWidget(),
      );
    } else if (skinNid == SkinNidEnum.bulletin_board) {
      return BoardNoisePaperWidget(
        showPin: true,
        child: _buildTextContentWidget(),
      );
    } else if (skinNid == SkinNidEnum.speech_card) {
      return BoardPpeechWidget(
        child: _buildTextContentWidget(),
      );
    } else if (skinNid == SkinNidEnum.newspaper_column) {
      return BoardSchoolTimesWidget(
        child: _buildTextContentWidget(),
      );
    } else if (skinNid == SkinNidEnum.storybook_spread) {
      return BoardNoisePaperWidget(
        child: _buildTextContentWidget(),
      );
    } else if (skinNid == SkinNidEnum.picture_page) {
      return WritLookImageWidget(
        data: widget.data,
        isManagement: widget.isManagement,
        controllers: widget.controllers,
        answerKind: answerKind,
        highlightedFrameSection: widget.highlightedFrameSection,
        onTapFrameSection: widget.onTapFrameSection,
        onTapStep: widget.onTapStep,
        onSelectBeatNid: widget.onSelectBeatNid,
        onRequestStepFocus: widget.onRequestStepFocus,
        onStepTextChanged: widget.onStepTextChanged,
        onHeadChanged: widget.onHeadChanged,
        onTailChanged: widget.onTailChanged,
        onImageItemsChanged: widget.onImageItemsChanged,
        onVideoItemsChanged: widget.onVideoItemsChanged,
        onAudioItemsChanged: widget.onAudioItemsChanged,
      );
    }

    return const SizedBox.shrink();
  }

  /// 根据渲染数据决定正文区使用纯正文还是首尾结构。
  Widget _buildTextContentWidget() {
    final useHeadTailWidget = widget.data.showHead || widget.data.showTail;
    if (!useHeadTailWidget) {
      return WritJustTextWidget(
        data: widget.data,
        isManagement: widget.isManagement,
        runtimeState: widget.runtimeState,
        controllers: widget.controllers,
        onTapStep: widget.onTapStep,
        onSelectBeatNid: widget.onSelectBeatNid,
        onRequestStepFocus: widget.onRequestStepFocus,
        onStepTextChanged: widget.onStepTextChanged,
      );
    }
    return WritHeadTailWidget(
      data: widget.data,
      isManagement: widget.isManagement,
      controllers: widget.controllers,
      highlightedFrameSection: widget.highlightedFrameSection,
      useTitleHeadStyle: _isTitleHeadStyle(widget.data),
      onTapFrameSection: widget.onTapFrameSection,
      onTapStep: widget.onTapStep,
      onSelectBeatNid: widget.onSelectBeatNid,
      onRequestStepFocus: widget.onRequestStepFocus,
      onStepTextChanged: widget.onStepTextChanged,
      onHeadChanged: widget.onHeadChanged,
      onTailChanged: widget.onTailChanged,
    );
  }

  /// 根据头部标签判断当前是否应该按标题样式渲染。
  bool _isTitleHeadStyle(WritingBoardData data) {
    final headLabel = data.headLabel ?? '';
    return data.showHead && (headLabel.contains('标题') || headLabel.toLowerCase().contains('title'));
  }

  SkinNidEnum _parseSkinNid(String? skinNid) {
    for (final item in SkinNidEnum.values) {
      if (item.skinNid == skinNid) {
        return item;
      }
    }
    return SkinNidEnum.picture_page;
  }
}
