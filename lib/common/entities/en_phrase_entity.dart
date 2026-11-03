import 'package:common_utils/common_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/models/manage_english_content_management_sentence_model.dart';
import '../../../../../../../common/entities/entities.dart';
import 'package:langwise/common/static/static_data.dart';
import 'package:langwise/common/values/values.dart';
import 'package:langwise/common/widgets/data_table_widget/data_table.dart';
import 'package:langwise/utils/utils.dart';

import '../public_controller/config_controller.dart';


class EnEntitySemantics<T> extends Dessert with JsonSerializableMixin {
/*
 {
            "uid": 727962,
            "descriptions": [
              {
                "lang": "en",
                "text": "A fermented dairy product made from milk, often consumed cold with fruits or sold in individual portions"
              },
              {
                "lang": "zh",
                "text": "由牛奶发酵制成的乳制品，通常冷藏食用并添加水果，或以独立小份装出售"
              }
            ],
            "gloss": [
              {
                "lang": "en",
                "text": "yoghurt (dairy product)"
              },
              {
                "lang": "zh",
                "text": "酸奶 (乳制品)"
              }
            ],
            "imageUrl": "http://img.timelywise.cn/knowledge/semantic/4C65D4B9B131CC182A06ADCEA0DE8794.webp?auth_key=1749793133-unu7ej0s9cw7-0-c02f0ffa82b4e8aa461c968c0d3bac57",
            "difficulty": 1,
            "semanticTypeIds": null,
            "semanticTypes": null,
            "references": null,
            "topics": [
              351
            ],
            "topicInfoList": [
              {
                "uid": 351,
                "title": "Food",
                "descriptions": [
                  {
                    "lang": "en",
                    "text": "Food"
                  }
                ],
                "difficulty": 6,
                "access": "NORMAL",
                "updated": "2025-04-03T07:37:37.260+00:00",
                "created": "2025-04-03T07:37:37.260+00:00"
              }
            ],
            "access": "NORMAL",
            "updated": "2025-06-05T06:04:40.862+00:00",
            "created": "2025-04-16T04:31:40.617+00:00"
          }
*/
  String? text;
  String? description;
  List<LanguageText>? descriptions;
  List<LanguageText>? gloss;
  String? imageUrl;
  int? difficulty;
  List<String?>? semanticTypes;
  List<String?>? semanticTypeTitles;
  List<String?>? expressions;
  List<String?>? tags;
  String? access;
  String? updated;
  String? created;
  String flag;
  String? language;
  String? definition;
  int? in_course_cnt;
  bool? in_course;
  int? exercise_cnt;
  int? image_cnt;
  int? video_cnt;

  // 关联语义列表
  List<EnEntitySemantics>? references;

  // 关联主题列表
  List<EnEntityTopic>? topicInfoList;

  // 语义关系类型
  String? relationShip;

  // 关系类型标题
  String? relationShipTitle;

  // 国家/口音列表
  List<String>? nationals;

  // 国家/口音名称列表
  List<String>? nationalNames;

  // 备注说明
  String? note;

  // 是否选中
  bool isSelected = false;

  EnEntitySemantics(
      {this.text,
      this.description,
      this.definition,
      this.descriptions,
      this.imageUrl,
      this.difficulty,
      this.semanticTypes,
      this.semanticTypeTitles,
      this.expressions,
      this.in_course_cnt,
      this.in_course,
      this.exercise_cnt,
      this.image_cnt,
      this.video_cnt,
      this.tags,
      this.access,
      this.updated,
      this.created,
      this.language,
      this.references,
      this.topicInfoList,
      this.relationShip,
      this.relationShipTitle,
      this.nationals,
      this.nationalNames,
      this.note,
      this.gloss,
      required int uid,
      this.flag = "flag"})
      : globalKey = GlobalKey(debugLabel: uid.toString()),
        super(uid: uid);

  final GlobalKey globalKey;

  factory EnEntitySemantics.fromJson(Map<String, dynamic> json) {
    var _semanticTypes = <String>[];
    if (json['semanticTypes'] != null) {
      final v = json['semanticTypes'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      _semanticTypes = arr0;
    }

    var _semanticTypeTitles = <String>[];
    if (json['semanticTypeTitles'] != null) {
      final v = json['semanticTypeTitles'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      _semanticTypeTitles = arr0;
    }

    var _expressions = <String>[];
    if (json['expressions'] != null) {
      final v = json['expressions'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      _expressions = arr0;
    }

    var _tags = <String>[];
    if (json['tags'] != null) {
      final v = json['tags'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      _tags = arr0;
    }

    var _descriptions = <LanguageText>[];
    if (json['descriptions'] != null) {
      final v = json['descriptions'];
      final arr0 = <LanguageText>[];
      v.forEach((v) {
        arr0.add(LanguageText.fromJson(v));
      });
      _descriptions = arr0;
    }

    // 解析关联语义列表
    var _references = <EnEntitySemantics>[];
    if (json['references'] != null) {
      final v = json['references'];
      final arr0 = <EnEntitySemantics>[];
      v.forEach((v) {
        if (v['semanticId'] != null) {
          // 创建关联语义实体
          arr0.add(EnEntitySemantics(
            uid: v['semanticId']?.toInt() ?? 0,
            text: v['semantic']?.toString(),
            relationShip: v['relationShip']?.toString(),
            relationShipTitle: v['relationShipTitle']?.toString(),
            language: v['language']?.toString(),
            nationals: (v['nationals'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
            nationalNames: (v['nationalNames'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
            note: v['note']?.toString(),
          ));
        }
      });
      _references = arr0;
    }

    // 解析关联主题列表
    var _topics = <EnEntityTopic>[];
    if (json['topicInfoList'] != null) {
      final v = json['topicInfoList'];
      final arr0 = <EnEntityTopic>[];
      v.forEach((v) {
        if (v is Map<String, dynamic>) {
          arr0.add(EnEntityTopic.fromJson(v));
        }
      });
      _topics = arr0;
    }

    // 解析gloss列表
    var _gloss = <LanguageText>[];
    if (json['gloss'] != null) {
      final v = json['gloss'];
      final arr0 = <LanguageText>[];
      v.forEach((v) {
        if (v is Map<String, dynamic>) {
          arr0.add(LanguageText.fromJson(v));
        }
      });
      _gloss = arr0;
    }

    return EnEntitySemantics(
        uid: json['uid']?.toInt() ?? 0,
        text: json['text']?.toString(),
        definition: json['definition']?.toString(),
        description: json['description']?.toString(),
        descriptions: _descriptions,
        imageUrl: json['imageUrl']?.toString(),
        in_course_cnt: json['in_course_cnt']?.toInt(),
        exercise_cnt: json['exercise_cnt']?.toInt(),
        image_cnt: json['image_cnt']?.toInt(),
        video_cnt: json['video_cnt']?.toInt(),
        in_course: json["in_course"]??false,
        difficulty: json['difficulty']?.toInt(),
        semanticTypes: _semanticTypes,
        semanticTypeTitles: _semanticTypeTitles,
        expressions: _expressions,
        tags: _tags,
        access: json['access']?.toString(),
        updated: json['updated']?.toString(),
        created: json['created']?.toString(),
        language: json["language"]?.toString(),
        references: _references,
        topicInfoList: _topics,
        gloss: _gloss);
  }

  @override
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = uid;
    data['text'] = text;
    data['description'] = description;
    data['imageUrl'] = imageUrl;
    data['difficulty'] = difficulty;
    data['definition'] = definition;
    data['in_course_cnt'] = in_course_cnt;
    if (descriptions != null) {
      final v = descriptions;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v.toJson());
      }
      data['descriptions'] = arr0;
    }

    if (semanticTypes != null) {
      final v = semanticTypes;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v);
      }
      data['semanticTypes'] = arr0;
    }
    if (semanticTypeTitles != null) {
      final v = semanticTypeTitles;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v);
      }
      data['semanticTypeTitles'] = arr0;
    }
    if (expressions != null) {
      final v = expressions;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v);
      }
      data['expressions'] = arr0;
    }
    if (tags != null) {
      final v = tags;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v);
      }
      data['tags'] = arr0;
    }
    data['access'] = access;
    data['updated'] = updated;
    data['created'] = created;

    // 序列化关联语义
    if (references != null) {
      final v = references;
      final arr0 = [];
      for (var v in v!) {
        arr0.add({
          'semanticId': v.uid,
          'semantic': v.text,
          'relationShip': v.relationShip,
          'relationShipTitle': v.relationShipTitle,
          'language': v.language,
          'nationals': v.nationals,
          'nationalNames': v.nationalNames,
          'note': v.note,
        });
      }
      data['references'] = arr0;
    }

    // 序列化关联主题
    if (topicInfoList != null) {
      final topicIds = topicInfoList!.map((topic) => topic.uid).toList();
      data['topicInfoList'] = topicIds;
    }

    if (gloss != null) {
      final v = gloss;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v.toJson());
      }
      data['gloss'] = arr0;
    }

    return data;
  }

  EnEntitySemantics copyWith({
    int? uid,
    String? text,
    String? description,
    List<LanguageText>? descriptions,
    String? imageUrl,
    String? definition,
    int? difficulty,
    List<String?>? semanticTypes,
    List<String?>? semanticTypeTitles,
    List<String?>? expressions,
    List<String?>? tags,
    int? in_course_cnt,
    String? access,
    String? updated,
    String? created,
    bool? isSelected,
    String? language,
    List<EnEntitySemantics>? references,
    List<EnEntityTopic>? topicInfoList,
    List<LanguageText>? gloss,
    String? relationShip,
    String? relationShipTitle,
    List<String>? nationals,
    List<String>? nationalNames,
    String? note,
  }) {
    return EnEntitySemantics(
      uid: uid ?? this.uid,
      text: text ?? this.text,
      description: description ?? this.description,
      descriptions: descriptions ?? this.descriptions,
      in_course_cnt: in_course_cnt ?? this.in_course_cnt,
      imageUrl: imageUrl ?? this.imageUrl,
      definition: definition ?? this.definition,
      difficulty: difficulty ?? this.difficulty,
      semanticTypes: semanticTypes != null ? List.from(semanticTypes) : List.from(this.semanticTypes ?? []),
      semanticTypeTitles: semanticTypeTitles != null ? List.from(semanticTypeTitles) : List.from(this.semanticTypeTitles ?? []),
      expressions: expressions != null ? List.from(expressions) : List.from(this.expressions ?? []),
      tags: tags != null ? List.from(tags) : List.from(this.tags ?? []),
      access: access ?? this.access,
      updated: updated ?? this.updated,
      created: created ?? this.created,
      language: language ?? this.language,
      references: references ?? this.references,
      topicInfoList: topicInfoList ?? this.topicInfoList,
      relationShip: relationShip ?? this.relationShip,
      relationShipTitle: relationShipTitle ?? this.relationShipTitle,
      nationals: nationals ?? this.nationals,
      nationalNames: nationalNames ?? this.nationalNames,
      note: note ?? this.note,
      gloss: gloss ?? this.gloss,
    )..isSelected = isSelected ?? this.isSelected;
  }

  // 时间格式化（复用相同逻辑）
  String get newUpdate => _formatDate(updated);

  String get newCreate => _formatDate(created);

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    return DateUtil.formatDateStr(dateStr, format: "yyyy/MM/dd");
  }

  // 英文title
  String get descriptionEnglishTitle {
    if (descriptions == null) {
      return "";
    }

    if (descriptions!.isEmpty) {
      return "";
    }

    final LanguageText? targetObj = descriptions!.firstWhereOrNull((element) => element.lang == StaticData.english);

    return targetObj?.text ?? '';
  }

  // 中文title
  String get descriptionZhTitle {
    if (descriptions == null) {
      return "";
    }

    if (descriptions!.isEmpty) {
      return "";
    }

    final LanguageText? targetObj = descriptions!.firstWhereOrNull((element) => element.lang == StaticData.zh);

    return targetObj?.text ?? '';
  }

  // 中文title
  String get glossZhTitle {
    if (gloss == null) {
      return "";
    }

    if (gloss!.isEmpty) {
      return "";
    }

    final LanguageText? targetObj = gloss!.firstWhereOrNull((element) => element.lang == StaticData.zh);

    return targetObj?.text ?? '';
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is EnEntitySemantics && uid == other.uid && flag == other.flag;
  }

  @override
  int get hashCode => Object.hash(uid, flag);

  @override
  String toString() {
    return 'EnEntitySemantics('
        'uid: $uid, hashCode:$hashCode,'
        'glossZhTitle: $glossZhTitle, isSelected: $isSelected, '
        'language: $language, difficulty: $difficulty'
        ')';
  }
}

class EnEntityStructure with JsonSerializableMixin {
  int? contentId;
  int? semanticId;
  String? content;
  String? semantic;
  List<int>? positions;

  EnEntityStructure({this.contentId, this.semanticId, this.content, this.semantic, this.positions}) : globalKey = GlobalKey();

  final GlobalKey globalKey;

  factory EnEntityStructure.fromJson(Map<String, dynamic> json) {
    var _tags = <int>[];
    if (json['positions'] != null) {
      final v = json['positions'];
      final arr0 = <int>[];
      v.forEach((v) {
        if (v != null) {
          arr0.add(v);
        }
      });
      _tags = arr0;
    }

    return EnEntityStructure(
      contentId: json['contentId'],
      semanticId: json['semanticId'],
      content: json['content'],
      semantic: json['semantic'],
      positions: _tags,
    );
  }

  @override
  String toString() {
    return 'EnEntityStructure('
        'contentId: $contentId, semanticId:$semanticId,'
        'content: $content, semantic:$semantic,positions: $positions'
        ')';
  }
}

class EnEntityLearn with JsonSerializableMixin {
  String? zh;
  String? en;

  EnEntityLearn({this.zh, this.en}) : globalKey = GlobalKey();

  final GlobalKey globalKey;

  factory EnEntityLearn.fromJson(Map<String, dynamic> json) {
    return EnEntityLearn(zh: json['zh'], en: json['en']);
  }

  @override
  String toString() {
    return 'EnEntityLearn('
        'zh: $zh, en:$en,'
        ')';
  }
}

class EnPhraseEntity extends BaseKnowledge {
  List<ManageEnglishContentManagementSentenceIpaAudioModel>? audioExpressionList;
  String? imageUrl;
  String? audioUrl;
  int? posFormId;

  String? pos;
  String? posTitle;
  String? form;
  String? formTitle;

  List<int?>? semanticIds;
  List<EnEntitySemantics>? semantics;
  List<Knowledge>? knowledgeList;
  List<EnEntityStructure>? structures;
  String? access;
  List<EnEntityLearn>? learnTips;
  ManageEnglishContentManagementSongKnowledgeStatisticsModel? contentKnowledgeStatistics;

  final int? minDifficulty;
  final int? maxDifficulty;

  EnPhraseEntity({
    String? contentType,
    this.audioExpressionList,
    String? content,
    String? definition,
    String? language,
    this.imageUrl,
    this.audioUrl,
    this.posFormId,
    this.pos,
    this.posTitle,
    this.form,
    this.formTitle,
    this.semanticIds,
    this.semantics,
    this.structures,
    this.learnTips,
    this.access,
    this.knowledgeList,
    Map? difficulty,
    this.minDifficulty,
    this.maxDifficulty,
    this.contentKnowledgeStatistics,
    String? updated,
    String? created,
    required int uid,
  }) : super(uid: uid, contentType: contentType, content: content, definition: definition, difficulty: difficulty, language: language, created: created, updated: updated);

  factory EnPhraseEntity.fromJson(Map<String, dynamic> json) {
    List<int?> _semanticIds = [];
    if (json['semanticIds'] != null) {
      final v = json['semanticIds'];
      final arr0 = <int>[];
      v.forEach((v) {
        arr0.add(v.toInt());
      });
      _semanticIds = arr0;
    }

    List<EnEntitySemantics> _semantics = [];
    if (json['semantics'] != null) {
      final v = json['semantics'];
      final arr0 = <EnEntitySemantics>[];
      v.forEach((v) {
        if (v != null) {
          arr0.add(EnEntitySemantics.fromJson(v));
        }
      });
      _semantics = arr0;
    }

    List<EnEntityStructure> _structures = [];
    if (json['structures'] != null) {
      final v = json['structures'];
      final arr0 = <EnEntityStructure>[];
      v.forEach((v) {
        if (v != null) {
          arr0.add(EnEntityStructure.fromJson(v));
        }
      });
      _structures = arr0;
    }

    List<EnEntityLearn> _learnTips = [];
    if (json['learnTips'] != null) {
      final v = json['learnTips'];
      final arr0 = <EnEntityLearn>[];
      v.forEach((v) {
        if (v != null) {
          arr0.add(EnEntityLearn.fromJson(v));
        }
      });
      _learnTips = arr0;
    }

    List<Knowledge> _knowledgeList = [];
    if (json['knowledgeList'] != null) {
      final v = json['knowledgeList'];
      final arr0 = <Knowledge>[];
      v.forEach((v) {
        arr0.add(Knowledge.fromJson(v));
      });
      _knowledgeList = arr0;
    }

    return EnPhraseEntity(
      uid: json['uid']?.toInt(),
      audioExpressionList:
          json['audioExpressionList'] != null ? (json['audioExpressionList'] as List).map((e) => ManageEnglishContentManagementSentenceIpaAudioModel.fromJson(e)).toList() : null,
      contentType: json['contentType']?.toString(),
      content: json['content']?.toString(),
      definition: json['definition']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      audioUrl: json['audioUrl']?.toString(),
      posFormId: json['posFormId']?.toInt(),
      pos: json['pos']?.toString(),
      posTitle: json['posTitle']?.toString(),
      form: json['form']?.toString(),
      formTitle: json['formTitle']?.toString(),
      semanticIds: _semanticIds,
      semantics: _semantics,
      structures: _structures,
      learnTips: _learnTips,
      knowledgeList: _knowledgeList,
      access: json['access']?.toString(),
      updated: json['updated']?.toString(),
      created: json['created']?.toString(),
      language: json['language']?.toString(),
      difficulty: json['difficulty'],
      minDifficulty: json['minDifficulty'],
      maxDifficulty: json['maxDifficulty'],
      contentKnowledgeStatistics: json['contentKnowledgeStatistics'] != null
          ? ManageEnglishContentManagementSongKnowledgeStatisticsModel.fromJson(json['contentKnowledgeStatistics'] as Map<String, dynamic>)
          : null,
    );
  }

  EnPhraseEntity copyWith({
    int? uid,
    List<ManageEnglishContentManagementSentenceIpaAudioModel>? audioExpressionList,
    String? contentType,
    String? content,
    String? definition,
    String? imageUrl,
    String? audioUrl,
    int? posFormId,
    String? pos,
    String? posTitle,
    String? form,
    String? formTitle,
    List<int?>? semanticIds,
    List<EnEntitySemantics>? semantics,
    List<EnEntityStructure>? structures,
    List<EnEntityLearn>? learnTips,
    List<Knowledge>? knowledgeList,
    String? access,
    String? language,
    Map? difficulty,
    int? minDifficulty,
    int? maxDifficulty,
    String? updated,
    String? created,
  }) {
    return EnPhraseEntity(
      uid: uid ?? this.uid,
      audioExpressionList: audioExpressionList ?? this.audioExpressionList,
      contentType: contentType ?? this.contentType,
      content: content ?? this.content,
      definition: definition ?? this.definition,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      posFormId: posFormId ?? this.posFormId,
      pos: pos ?? this.pos,
      posTitle: posTitle ?? this.posTitle,
      form: form ?? this.form,
      formTitle: formTitle ?? this.formTitle,
      semanticIds: semanticIds ?? this.semanticIds,
      semantics: semantics ?? this.semantics,
      structures: structures ?? this.structures,
      learnTips: learnTips ?? this.learnTips,
      knowledgeList: knowledgeList ?? this.knowledgeList,
      access: access ?? this.access,
      language: language ?? this.language,
      difficulty: difficulty ?? this.difficulty,
      minDifficulty: minDifficulty ?? this.minDifficulty,
      maxDifficulty: maxDifficulty ?? this.maxDifficulty,
      updated: updated ?? this.updated,
      created: created ?? this.created,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = uid;
    if (audioExpressionList != null) {
      final v = audioExpressionList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v.toJson());
      });
      data['audioExpressionList'] = arr0;
    }
    data['contentType'] = contentType;
    data['difficulty'] = difficulty;
    data['contentKnowledgeStatistics'] = contentKnowledgeStatistics?.toJson();
    data['content'] = content;
    data['definition'] = definition;
    data['imageUrl'] = imageUrl;
    data['audioUrl'] = audioUrl;
    data['posFormId'] = posFormId;
    data['pos'] = pos;
    data['posTitle'] = posTitle;
    data['form'] = form;
    data['formTitle'] = formTitle;
    if (semanticIds != null) {
      final v = semanticIds;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['semanticIds'] = arr0;
    }
    if (semantics != null) {
      final v = semantics;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v.toJson());
      }
      data['semantics'] = arr0;
    }
    if (structures != null) {
      final v = structures;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['structures'] = arr0;
    }
    data['access'] = access;
    data['updated'] = updated;
    data['created'] = created;
    return data;
  }

  // 选中的语义
  EnEntitySemantics? get selectedSemantics {
    if (semantics == null) {
      return null;
    }

    if (semantics!.isEmpty) {
      return null;
    }

    if (semantics!.length == 1) {
      return semantics!.first;
    }

    return semantics!.firstWhereOrNull((element) => element.isSelected);
  }

  // 语义
  String get allGlossZhTitle {
    if (semantics == null) {
      return "";
    }

    if (semantics!.isEmpty) {
      return "";
    }

    return semantics!.map((element) => element.glossZhTitle).join(";");
  }

  // 状态
  UnmountType get unmountType => UnmountType.fromValue(access ?? '');

  // 最小难度等级显示名称
  String get newMinDifficulty {
    String difficulty = "";
    try {
      final List<DifficultieEntity> difficultieList = getConfig();
      if (difficultieList.isNotEmpty) {
        if (minDifficulty != null) {
          difficulty = difficultieList[minDifficulty!].name?.text ?? '';
        }
      }
    } catch (e) {
      if (kDebugMode) print('最小难度等级显示名称转换异常: $e');
    }
    return difficulty;
  }

  // 最大难度等级显示名称
  String get newMaxDifficulty {
    String difficulty = "";
    try {
      final List<DifficultieEntity> difficultieList = getConfig();
      if (difficultieList.isNotEmpty) {
        if (maxDifficulty != null) {
          difficulty = difficultieList[maxDifficulty!].name?.text ?? '';
        }
      }
    } catch (e) {
      if (kDebugMode) print('最大难度等级显示名称转换异常: $e');
    }
    return difficulty;
  }

  List<DifficultieEntity> getConfig() {
    final int selectLanguageIndex = StaticData.getLanguageIndex(language) ?? 0;
    final ConfigEntity configData = Get.find<ConfigController>().appConfig.value;
    final String languageCode = StaticData.languageList[selectLanguageIndex].value;
    final List<DifficultieEntity>? diffList = DifficultieUtils.getDifficultieList(configData, languageCode);
    if (diffList == null) return [];
    return diffList;
  }
}
