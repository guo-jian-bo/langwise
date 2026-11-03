import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';

class MissionContentSelectAction {
  MissionContentSelectAction._();

  static const String preview = "preview";
  static const String flashNotes = "flash_notes";
  static const String dictation = "dictation";
  static const String speakingSoundBlock = "speaking_sound_block";
  static const String speakingPronunciation = "speaking_pronunciation";
}

enum MissionContentSelectFilter {
  all,
  oldKnowledge,
  newKnowledge,
}

class MissionContentSelectItemModel {
  final TaskMissionEntityMissionKnowledgeItem source;
  final UnitKnowledgePointsEntityKnowledgeList detail;

  MissionContentSelectItemModel({
    required this.source,
    required this.detail,
  });

  String get key => source.uniqueKey;
  bool get isNew => source.isNewKnowledge;
  bool get isOld => source.isOldKnowledge;

  String get contentType => detail.contentType ?? source.contentType ?? "";
  bool get isWord => contentType == ElementsCardType.word.value;
  bool get isPhrase => contentType == ElementsCardType.phrase.value;
  bool get isSentence => contentType == ElementsCardType.sentence.value;

  String get typeLabel => ElementsCardType.fromRawValue(contentType).name;

  UnitKnowledgePointsEntityKnowledgeList get previewKnowledge {
    final data = detail.toJson();
    data['uid'] ??= detail.contentId;
    return UnitKnowledgePointsEntityKnowledgeList.fromJson(data);
  }
}
