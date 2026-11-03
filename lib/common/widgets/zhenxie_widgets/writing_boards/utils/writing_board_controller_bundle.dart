import 'package:flutter/material.dart';

import '../model/writing_board_data.dart';
import 'writing_board_runtime_state.dart';

/// 写作板运行时控制器集合。
class WritingBoardControllers {
  final TextEditingController? headController;
  final TextEditingController? tailController;
  final FocusNode? headFocusNode;
  final FocusNode? tailFocusNode;
  final Map<String, TextEditingController> stepControllers;
  final Map<String, FocusNode> stepFocusNodes;

  WritingBoardControllers({
    this.headController,
    this.tailController,
    this.headFocusNode,
    this.tailFocusNode,
    Map<String, TextEditingController>? stepControllers,
    Map<String, FocusNode>? stepFocusNodes,
  })  : stepControllers = stepControllers ?? <String, TextEditingController>{},
        stepFocusNodes = stepFocusNodes ?? <String, FocusNode>{};

  /// 释放写作板内部创建的控制器资源。
  void dispose() {
    headController?.dispose();
    tailController?.dispose();
    headFocusNode?.dispose();
    tailFocusNode?.dispose();
    for (final controller in stepControllers.values) {
      controller.dispose();
    }
    for (final focusNode in stepFocusNodes.values) {
      focusNode.dispose();
    }
  }
}

/// 根据写作板数据和运行时状态构建输入控制器。
WritingBoardControllers buildWritingBoardControllers({
  required WritingBoardData data,
  required WritingBoardRuntimeState runtimeState,
}) {
  final stepControllers = <String, TextEditingController>{};
  final stepFocusNodes = <String, FocusNode>{};

  for (final step in data.steps) {
    if (!step.editable) continue;
    stepControllers[step.beatNid] = TextEditingController(
      text: runtimeState.stepTextMap[step.beatNid] ?? '',
    );
    stepFocusNodes[step.beatNid] = FocusNode();
  }

  return WritingBoardControllers(
    headController: data.headEditable ? TextEditingController(text: runtimeState.headText) : null,
    tailController: data.tailEditable ? TextEditingController(text: runtimeState.tailText) : null,
    headFocusNode: data.headEditable ? FocusNode() : null,
    tailFocusNode: data.tailEditable ? FocusNode() : null,
    stepControllers: stepControllers,
    stepFocusNodes: stepFocusNodes,
  );
}
