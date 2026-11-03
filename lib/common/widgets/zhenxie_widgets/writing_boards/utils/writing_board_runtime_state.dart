import '../model/writing_board_data.dart';

/// 写作板运行时状态，只保存当前页面临时输入结果。
class WritingBoardRuntimeState {
  /// 当前运行时状态对应的数据来源宏。
  final WritingBoardContentSourceMacro contentSource;

  /// 当前运行时状态对应的编辑策略宏。
  final WritingBoardEditPolicyMacro editPolicy;

  /// 当前文首输入结果。
  String headText;

  /// 当前文尾输入结果。
  String tailText;

  /// 当前持有焦点的拍位主键。
  String? focusedBeatNid;

  /// 当前正文各拍位输入结果。
  Map<String, String> stepTextMap;

  /// 当前图片作答结果。
  List<WritingBoardMediaItemData> answerImages;

  /// 当前视频作答结果。
  List<WritingBoardMediaItemData> answerVideos;

  /// 当前音频作答结果。
  List<WritingBoardMediaItemData> answerAudios;

  WritingBoardRuntimeState({
    this.contentSource = WritingBoardContentSourceMacro.task,
    this.editPolicy = WritingBoardEditPolicyMacro.stageRule,
    this.headText = '',
    this.tailText = '',
    this.focusedBeatNid,
    Map<String, String>? stepTextMap,
    List<WritingBoardMediaItemData>? answerImages,
    List<WritingBoardMediaItemData>? answerVideos,
    List<WritingBoardMediaItemData>? answerAudios,
  })  : stepTextMap = stepTextMap ?? <String, String>{},
        answerImages = answerImages ?? <WritingBoardMediaItemData>[],
        answerVideos = answerVideos ?? <WritingBoardMediaItemData>[],
        answerAudios = answerAudios ?? <WritingBoardMediaItemData>[];

  /// 基于当前运行时状态复制一个新实例。
  WritingBoardRuntimeState copyWith({
    WritingBoardContentSourceMacro? contentSource,
    WritingBoardEditPolicyMacro? editPolicy,
    String? headText,
    String? tailText,
    String? focusedBeatNid,
    Map<String, String>? stepTextMap,
    List<WritingBoardMediaItemData>? answerImages,
    List<WritingBoardMediaItemData>? answerVideos,
    List<WritingBoardMediaItemData>? answerAudios,
  }) {
    return WritingBoardRuntimeState(
      contentSource: contentSource ?? this.contentSource,
      editPolicy: editPolicy ?? this.editPolicy,
      headText: headText ?? this.headText,
      tailText: tailText ?? this.tailText,
      focusedBeatNid: focusedBeatNid ?? this.focusedBeatNid,
      stepTextMap: stepTextMap ?? this.stepTextMap,
      answerImages: answerImages ?? this.answerImages,
      answerVideos: answerVideos ?? this.answerVideos,
      answerAudios: answerAudios ?? this.answerAudios,
    );
  }
}

/// 根据写作板渲染数据构建初始运行时状态。
WritingBoardRuntimeState buildWritingBoardRuntimeState({
  required WritingBoardData data,
}) {
  final stepTextMap = <String, String>{};
  String? focusedBeatNid;
  for (final step in data.steps) {
    stepTextMap[step.beatNid] = step.text ?? '';
    if (step.focused) {
      focusedBeatNid = step.beatNid;
    }
  }
  final mediaData = data.contentSource == WritingBoardContentSourceMacro.exemplar ? data.exemplarMediaAnswer : data.mediaAnswer;

  return WritingBoardRuntimeState(
    contentSource: data.contentSource,
    editPolicy: data.editPolicy,
    headText: data.headText ?? '',
    tailText: data.tailText ?? '',
    focusedBeatNid: focusedBeatNid,
    stepTextMap: stepTextMap,
    answerImages: data.answerKind == 'image' ? List<WritingBoardMediaItemData>.from(mediaData?.items ?? const []) : [],
    answerVideos: data.answerKind == 'video' ? List<WritingBoardMediaItemData>.from(mediaData?.items ?? const []) : [],
    answerAudios: data.answerKind == 'audio' ? List<WritingBoardMediaItemData>.from(mediaData?.items ?? const []) : [],
  );
}
