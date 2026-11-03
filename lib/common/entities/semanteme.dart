import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/data_table_widget/data_sources.dart';
import 'package:langwise/utils/utils.dart';

/// 语素实体类
class SemantemeResponseEntity extends Dessert with JsonSerializableMixin {
  final String? content;
  final String? type;
  final String? typeTitle;
  final List<EnWordEntityIpa>? ipa;
  final String? definition;
  final String? etymology;
  final String? origin;
  final String? originTitle;
  final int? difficulty;
  final List<SemantemeResponseEntity>? relatedMorphemes;
  final List<int>? exampleIds;
  final List<EnWordEntity>? examples; // 与 PhonicsResponseEntity 中的 wordList 相同类型
  final String? updated;
  final String? created;

  SemantemeResponseEntity({
    required int uid,
    this.content,
    this.type,
    this.typeTitle,
    this.ipa,
    this.definition,
    this.etymology,
    this.origin,
    this.originTitle,
    this.difficulty,
    this.relatedMorphemes,
    this.exampleIds,
    this.examples,
    this.updated,
    this.created,
  })  : globalKey = GlobalKey(debugLabel: uid.toString()),
        super(uid: uid);

  final GlobalKey globalKey;

  factory SemantemeResponseEntity.fromJson(Map<String, dynamic> json) {
    // 处理 ipa 字段
    List<EnWordEntityIpa> ipaList = [];
    if (json['ipa'] != null) {
      final v = json['ipa'];
      final arr0 = <EnWordEntityIpa>[];
      v.forEach((v) {
        arr0.add(EnWordEntityIpa.fromJson(v));
      });
      ipaList = arr0;
    }

    // 处理 exampleIds 字段
    List<int> exampleIdsList = [];
    if (json['exampleIds'] != null) {
      final v = json['exampleIds'];
      final arr0 = <int>[];
      v.forEach((v) {
        arr0.add(v.toInt());
      });
      exampleIdsList = arr0;
    }

    // 处理 examples 字段 (与 PhonicsResponseEntity 中的 wordList 处理相同)
    List<EnWordEntity> examplesList = [];
    if (json['examples'] != null) {
      final v = json['examples'];
      final arr0 = <EnWordEntity>[];
      v.forEach((v) {
        if (v != null) {
          arr0.add(EnWordEntity.fromJson(v));
        }
      });
      examplesList = arr0;
    }

    return SemantemeResponseEntity(
      uid: json['uid']?.toInt() ?? 0,
      content: json['content'],
      type: json['type'],
      typeTitle: json['typeTitle'],
      ipa: ipaList,
      definition: json['definition'],
      etymology: json['etymology'],
      origin: json['origin'],
      originTitle: json['originTitle'],
      difficulty: json['difficulty']?.toInt(),
      relatedMorphemes: null,
      // 暂时为null，后续会替换
      exampleIds: exampleIdsList,
      examples: examplesList,
      updated: json['updated']?.toString(),
      created: json['created']?.toString(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = uid;
    data['content'] = content;
    data['type'] = type;
    data['typeTitle'] = typeTitle;

    if (ipa != null) {
      final v = ipa;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v.toJson());
      }
      data['ipa'] = arr0;
    }

    // 主要JSON字段
    data['definition'] = definition;
    data['etymology'] = etymology;
    data['origin'] = origin;
    data['originTitle'] = originTitle;
    data['difficulty'] = difficulty;

    if (relatedMorphemes != null) {
      final v = relatedMorphemes;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v.toJson());
      }
      data['relatedMorphemes'] = arr0;
    }

    if (exampleIds != null) {
      data['exampleIds'] = exampleIds;
    }

    if (examples != null) {
      final v = examples;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v.toJson());
      }
      data['examples'] = arr0;
    }

    data['updated'] = updated;
    data['created'] = created;

    return data;
  }

  SemantemeResponseEntity copyWith({
    int? uid,
    String? content,
    String? type,
    String? typeTitle,
    List<EnWordEntityIpa>? ipa,
    String? definition,
    String? etymology,
    String? origin,
    String? originTitle,
    int? difficulty,
    List<SemantemeResponseEntity>? relatedMorphemes,
    List<int>? exampleIds,
    List<EnWordEntity>? examples,
    String? updated,
    String? created,
  }) {
    return SemantemeResponseEntity(
      uid: uid ?? this.uid,
      content: content ?? this.content,
      type: type ?? this.type,
      typeTitle: typeTitle ?? this.typeTitle,
      ipa: ipa ?? this.ipa,
      definition: definition ?? this.definition,
      etymology: etymology ?? this.etymology,
      origin: origin ?? this.origin,
      originTitle: originTitle ?? this.originTitle,
      difficulty: difficulty ?? this.difficulty,
      relatedMorphemes: relatedMorphemes ?? this.relatedMorphemes,
      exampleIds: exampleIds ?? this.exampleIds,
      examples: examples ?? this.examples,
      updated: updated ?? this.updated,
      created: created ?? this.created,
    );
  }

  // 获取美音
  String? get americanIpa {
    if (ipa != null && ipa!.isNotEmpty) {
      for (var item in ipa!) {
        if (item.accent == CommonUtil.us) {
          return item.text;
        }
      }
    }
    return null;
  }

  // 获取英音
  String? get britishIpa {
    if (ipa != null && ipa!.isNotEmpty) {
      for (var item in ipa!) {
        if (item.accent == CommonUtil.uk) {
          return item.text;
        }
      }
    }
    return null;
  }

  // 时间格式化（复用相同逻辑）
  String get newUpdate => formatDate(updated);

  String get newCreate => formatDate(created);

  String formatDate(String? dateStr) {
    if (dateStr == null) return '';
    return DateUtil.formatDateStr(dateStr, format: "yyyy/MM/dd");
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is SemantemeResponseEntity && other.uid == uid;
  }

  @override
  int get hashCode => Object.hash(runtimeType, uid);
}
