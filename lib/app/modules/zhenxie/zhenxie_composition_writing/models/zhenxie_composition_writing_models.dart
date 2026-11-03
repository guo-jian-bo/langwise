import '../../zhenxie_composition_stages/models/zhenxie_composition_stages_models.dart';
import '../../../../../common/entities/entities.dart';

class CompositionTaskModel {
  int? uid;
  String? cover;
  String? coverUrl;
  String? coverMd5;
  String? stageNid;
  String? genreNid;
  List<LanguageText> name;
  List<LanguageText> stem;
  CompositionBlueprintModel? blueprint;
  CompositionStageModel? stage;
  CardContentDifficulty? difficulty;
  int? exemplarCompositionId;
  String? status;

  CompositionTaskModel({
    this.uid,
    this.cover,
    this.coverUrl,
    this.coverMd5,
    this.stageNid,
    this.genreNid,
    this.name = const <LanguageText>[],
    this.stem = const <LanguageText>[],
    this.blueprint,
    this.stage,
    this.difficulty,
    this.exemplarCompositionId,
    this.status,
  });

  factory CompositionTaskModel.fromJson(Map<String, dynamic> json) {
    return CompositionTaskModel(
      uid: json['uid']?.toInt(),
      cover: json['cover']?.toString(),
      coverUrl: json['coverUrl']?.toString(),
      coverMd5: json['coverMd5']?.toString(),
      stageNid: json['stageNid']?.toString(),
      genreNid: json['genreNid']?.toString(),
      name: (json['name'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(LanguageText.fromJson)
          .toList(),
      stem: (json['stem'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(LanguageText.fromJson)
          .toList(),
      blueprint: json['blueprint'] is Map<String, dynamic>
          ? CompositionBlueprintModel.fromJson(json['blueprint'])
          : null,
      stage: json['stage'] is Map<String, dynamic> ? CompositionStageModel.fromJson(json['stage']) : null,
      difficulty: json['difficulty'] is Map<String, dynamic>
          ? CardContentDifficulty.fromJson(json['difficulty'])
          : null,
      exemplarCompositionId: json['exemplarCompositionId']?.toInt(),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'uid': uid,
      'cover': cover,
      'coverUrl': coverUrl,
      'coverMd5': coverMd5,
      'stageNid': stageNid,
      'genreNid': genreNid,
      'name': name.map((item) => item.toJson()).toList(),
      'stem': stem.map((item) => item.toJson()).toList(),
      'blueprint': blueprint?.toJson(),
      'stage': stage?.toJson(),
      'difficulty': difficulty?.toJson(),
      'exemplarCompositionId': exemplarCompositionId,
      'status': status,
    };
  }
}
