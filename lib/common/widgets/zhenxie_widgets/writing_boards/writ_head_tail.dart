import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'model/writing_board_frame_section_type.dart';
import 'model/writing_board_data.dart';
import 'utils/writing_board_controller_bundle.dart';
import 'writ_head_box_widget.dart';
import 'writ_just_text.dart';

class WritHeadTailWidget extends StatelessWidget {
  final WritingBoardData data;
  final bool isManagement;
  final WritingBoardControllers? controllers;
  final WritingBoardFrameSectionType? highlightedFrameSection;
  final bool useTitleHeadStyle;
  final void Function(WritingBoardFrameSectionType type)? onTapFrameSection;
  final void Function(String beatNid)? onTapStep;
  final void Function(String beatNid)? onSelectBeatNid;
  final void Function(String beatNid)? onRequestStepFocus;
  final void Function(String beatNid, String text)? onStepTextChanged;
  final void Function(String text)? onHeadChanged;
  final void Function(String text)? onTailChanged;

  /// 首尾格式
  const WritHeadTailWidget({
    super.key,
    required this.data,
    this.isManagement = false,
    this.controllers,
    this.highlightedFrameSection,
    this.useTitleHeadStyle = false,
    this.onTapFrameSection,
    this.onTapStep,
    this.onSelectBeatNid,
    this.onRequestStepFocus,
    this.onStepTextChanged,
    this.onHeadChanged,
    this.onTailChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data.showHead) ...[
            Align(
              alignment: useTitleHeadStyle ? Alignment.center : Alignment.centerLeft,
              child: WritHeadBoxWidget(
                type: useTitleHeadStyle ? "标题格式" : "文首格式",
                title: data.headLabel ?? (useTitleHeadStyle ? "标题" : "称呼"),
                content: data.headText ?? "",
                placeholder: data.headLabel ?? (useTitleHeadStyle ? "输入标题" : "输入文首"),
                editable: data.headEditable,
                controller: controllers?.headController,
                focusNode: controllers?.headFocusNode,
                onChanged: onHeadChanged,
                textStyle: useTitleHeadStyle
                    ? TextStyle(
                        fontSize: 28.wMin,
                        fontWeight: FontWeight.w500,
                        color: Colors.black.withValues(alpha: 0.75),
                      )
                    : null,
                highlighted: highlightedFrameSection ==
                    (useTitleHeadStyle ? WritingBoardFrameSectionType.headings : WritingBoardFrameSectionType.head),
                onTap: _canTapFrameSection
                    ? () => onTapFrameSection
                        ?.call(useTitleHeadStyle ? WritingBoardFrameSectionType.headings : WritingBoardFrameSectionType.head)
                    : null,
              ),
            ),
            SizedBox(height: 32.wMin),
          ],
          WritJustTextWidget(
            data: data,
            isManagement: isManagement,
            controllers: controllers,
            onTapStep: onTapStep,
            onSelectBeatNid: onSelectBeatNid,
            onRequestStepFocus: onRequestStepFocus,
            onStepTextChanged: onStepTextChanged,
          ),
          if (data.showTail) ...[
            SizedBox(height: 32.wMin),
            Container(
              alignment: Alignment.centerRight,
              child: WritHeadBoxWidget(
                type: "文尾格式",
                title: data.tailLabel ?? "落款",
                content: data.tailText ?? "",
                placeholder: data.tailLabel ?? "输入文尾",
                editable: data.tailEditable,
                controller: controllers?.tailController,
                focusNode: controllers?.tailFocusNode,
                onChanged: onTailChanged,
                highlighted: highlightedFrameSection == WritingBoardFrameSectionType.tail,
                onTap: _canTapFrameSection ? () => onTapFrameSection?.call(WritingBoardFrameSectionType.tail) : null,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 只有范文只读态允许点击蓝图框架区域做高亮联动。
  bool get _canTapFrameSection {
    return data.mode == WritingBoardModeEnum.exemplar;
  }
}
