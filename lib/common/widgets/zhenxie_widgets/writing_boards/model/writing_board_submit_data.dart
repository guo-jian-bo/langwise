import 'writing_board_data.dart';

/// 写作板页面层提交占位数据。
class WritingBoardSubmitData {
  final int? taskUid;
  final int? taskId;
  final String? stageNid;
  final String? skinNid;
  final String? answerKind;
  final String? selectBeatNid;
  final String? headText;
  final String? tailText;
  final List<WritingBoardSubmitStepData> steps;
  final List<WritingBoardSubmitMediaItemData> answerImages;
  final List<WritingBoardSubmitMediaItemData> answerVideos;
  final List<WritingBoardSubmitMediaItemData> answerAudios;

  const WritingBoardSubmitData({
    this.taskUid,
    this.taskId,
    this.stageNid,
    this.skinNid,
    this.answerKind,
    this.selectBeatNid,
    this.headText,
    this.tailText,
    this.steps = const [],
    this.answerImages = const [],
    this.answerVideos = const [],
    this.answerAudios = const [],
  });

  /// 转成页面层便于调试和后续接接口的 Map 结构。
  Map<String, dynamic> toJson() {
    return {
      'taskUid': taskUid,
      'taskId': taskId,
      'stageNid': stageNid,
      'skinNid': skinNid,
      'answerKind': answerKind,
      'selectBeatNid': selectBeatNid,
      'headText': headText,
      'tailText': tailText,
      'steps': steps.map((item) => item.toJson()).toList(),
      'answerImages': answerImages.map((item) => item.toJson()).toList(),
      'answerVideos': answerVideos.map((item) => item.toJson()).toList(),
      'answerAudios': answerAudios.map((item) => item.toJson()).toList(),
    };
  }
}

/// 单个拍位的提交占位数据。
class WritingBoardSubmitStepData {
  final String beatNid;
  final int? order;
  final String? paragraphTypeNid;
  final String text;

  const WritingBoardSubmitStepData({
    required this.beatNid,
    this.order,
    this.paragraphTypeNid,
    this.text = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'beatNid': beatNid,
      'order': order,
      'paragraphTypeNid': paragraphTypeNid,
      'text': text,
    };
  }
}

/// 单个媒体资源的提交占位数据。
class WritingBoardSubmitMediaItemData {
  final String? key;
  final String? url;
  final String? localPath;

  const WritingBoardSubmitMediaItemData({
    this.key,
    this.url,
    this.localPath,
  });

  factory WritingBoardSubmitMediaItemData.fromBoardItem(WritingBoardMediaItemData item) {
    return WritingBoardSubmitMediaItemData(
      key: item.key,
      url: item.url,
      localPath: item.localPath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'url': url,
      'localPath': localPath,
    };
  }
}
