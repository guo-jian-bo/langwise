import '../../../../entities/entities.dart';
import '../model/writing_board_data.dart';
import '../model/writing_board_submit_data.dart';
import 'writing_board_runtime_state.dart';

/// 将当前写作板运行时结果整理成页面层暂存 / 提交占位结构。
WritingBoardSubmitData buildWritingBoardSubmitData({
  required ZhenxieTaskDetailsEntity details,
  required WritingBoardData data,
  required WritingBoardRuntimeState runtimeState,
  String? selectBeatNid,
}) {
  final stageSlots = details.stage?.slots ?? const <ZhenxieTaskDetailsEntityStageSlot?>[];
  final slotMap = <String, ZhenxieTaskDetailsEntityStageSlot>{};
  for (final slot in stageSlots) {
    if (slot?.beatNid?.isEmpty != false) continue;
    slotMap[slot!.beatNid!] = slot;
  }

  return WritingBoardSubmitData(
    taskUid: details.uid,
    taskId: details.taskId,
    stageNid: details.stageNid ?? details.stage?.nid,
    skinNid: data.skinNid,
    answerKind: data.answerKind,
    selectBeatNid: selectBeatNid,
    headText: data.showHead ? runtimeState.headText : null,
    tailText: data.showTail ? runtimeState.tailText : null,
    steps: data.steps.map((step) {
      final slot = slotMap[step.beatNid];
      return WritingBoardSubmitStepData(
        beatNid: step.beatNid,
        order: slot?.order,
        paragraphTypeNid: step.paragraphTypeNid ?? slot?.paragraphTypeNid,
        text: runtimeState.stepTextMap[step.beatNid] ?? step.text ?? '',
      );
    }).toList(),
    answerImages: _buildSubmitMediaItems(runtimeState.answerImages),
    answerVideos: _buildSubmitMediaItems(runtimeState.answerVideos),
    answerAudios: _buildSubmitMediaItems(runtimeState.answerAudios),
  );
}

List<WritingBoardSubmitMediaItemData> _buildSubmitMediaItems(List<WritingBoardMediaItemData> items) {
  return items.map(WritingBoardSubmitMediaItemData.fromBoardItem).toList();
}
