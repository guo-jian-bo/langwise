import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'model/writing_board_data.dart';
import 'utils/writing_board_controller_bundle.dart';
import 'utils/writing_board_runtime_state.dart';
import 'writ_step_text_widget.dart';

class WritJustTextWidget extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final WritingBoardData data;
  final bool isManagement;
  final WritingBoardRuntimeState? runtimeState;
  final WritingBoardControllers? controllers;
  final void Function(String beatNid)? onTapStep;
  final void Function(String beatNid)? onSelectBeatNid;
  final void Function(String beatNid)? onRequestStepFocus;
  final void Function(String beatNid, String text)? onStepTextChanged;

  const WritJustTextWidget({
    super.key,
    required this.data,
    this.padding,
    this.isManagement = false,
    this.runtimeState,
    this.controllers,
    this.onTapStep,
    this.onSelectBeatNid,
    this.onRequestStepFocus,
    this.onStepTextChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: Column(
        spacing: 32.wMin,
        children: data.steps.map((step) {
          return WritStepTextWidget(
            data: step,
            showKnowledgeAnchors: data.showKnowledgeAnchors,
            isManagement: isManagement,
            controller: controllers?.stepControllers[step.beatNid],
            focusNode: controllers?.stepFocusNodes[step.beatNid],
            onTapStep: onTapStep,
            onSelectBeatNid: onSelectBeatNid,
            onRequestStepFocus: onRequestStepFocus,
            onStepTextChanged: onStepTextChanged,
          );
        }).toList(),
      ),
    );
  }
}
