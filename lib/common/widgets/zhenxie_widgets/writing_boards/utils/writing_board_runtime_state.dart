import '../../../../entities/entities.dart';
import '../../../../enum/enum.dart';
import '../model/writing_board_data.dart';

/// 写作板运行时状态，只保存当前页面临时输入结果。
class WritingBoardRuntimeState {
  /// 当前运行时状态对应的写作板模式。
  final WritingBoardModeEnum mode;

  /// 当前文字作答提交模式。
  final ZhenxieTaskTextSubmitModeEnum writingBoardTextMode;

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

  /// 当前文字题“写在纸上”模式的纸面照片结果。
  List<WritingBoardMediaItemData> paperImages;

  WritingBoardRuntimeState({
    this.mode = WritingBoardModeEnum.task,
    this.writingBoardTextMode = ZhenxieTaskTextSubmitModeEnum.typing,
    this.headText = '',
    this.tailText = '',
    this.focusedBeatNid,
    Map<String, String>? stepTextMap,
    List<WritingBoardMediaItemData>? answerImages,
    List<WritingBoardMediaItemData>? answerVideos,
    List<WritingBoardMediaItemData>? answerAudios,
    List<WritingBoardMediaItemData>? paperImages,
  })  : stepTextMap = stepTextMap ?? <String, String>{},
        answerImages = answerImages ?? <WritingBoardMediaItemData>[],
        answerVideos = answerVideos ?? <WritingBoardMediaItemData>[],
        answerAudios = answerAudios ?? <WritingBoardMediaItemData>[],
        paperImages = paperImages ?? <WritingBoardMediaItemData>[];

  /// 基于当前运行时状态复制一个新实例。
  WritingBoardRuntimeState copyWith({
    WritingBoardModeEnum? mode,
    ZhenxieTaskTextSubmitModeEnum? writingBoardTextMode,
    String? headText,
    String? tailText,
    String? focusedBeatNid,
    Map<String, String>? stepTextMap,
    List<WritingBoardMediaItemData>? answerImages,
    List<WritingBoardMediaItemData>? answerVideos,
    List<WritingBoardMediaItemData>? answerAudios,
    List<WritingBoardMediaItemData>? paperImages,
  }) {
    return WritingBoardRuntimeState(
      mode: mode ?? this.mode,
      writingBoardTextMode: writingBoardTextMode ?? this.writingBoardTextMode,
      headText: headText ?? this.headText,
      tailText: tailText ?? this.tailText,
      focusedBeatNid: focusedBeatNid ?? this.focusedBeatNid,
      stepTextMap: stepTextMap ?? this.stepTextMap,
      answerImages: answerImages ?? this.answerImages,
      answerVideos: answerVideos ?? this.answerVideos,
      answerAudios: answerAudios ?? this.answerAudios,
      paperImages: paperImages ?? this.paperImages,
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
  final mediaData = data.mode.usesExemplarContent ? data.exemplarMediaAnswer : data.mediaAnswer;

  return WritingBoardRuntimeState(
    mode: data.mode,
    writingBoardTextMode: data.writingBoardTextMode,
    headText: data.headText ?? '',
    tailText: data.tailText ?? '',
    focusedBeatNid: focusedBeatNid,
    stepTextMap: stepTextMap,
    answerImages: data.answerKindEnum == ZhenxieTaskAnswerKindEnum.image ? List<WritingBoardMediaItemData>.from(mediaData?.items ?? const []) : [],
    answerVideos: data.answerKindEnum == ZhenxieTaskAnswerKindEnum.video ? List<WritingBoardMediaItemData>.from(mediaData?.items ?? const []) : [],
    answerAudios: data.answerKindEnum == ZhenxieTaskAnswerKindEnum.audio ? List<WritingBoardMediaItemData>.from(mediaData?.items ?? const []) : [],
    paperImages: data.answerKindEnum.isText ? List<WritingBoardMediaItemData>.from(data.paperImageAnswer?.items ?? const []) : [],
  );
}
