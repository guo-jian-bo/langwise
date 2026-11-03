import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/data_table_widget/data_sources.dart';
import 'package:langwise/utils/utils.dart';

class EnLetterPatternEntity {
  String? text;

  EnLetterPatternEntity({
    this.text,
  }) : globalKey = GlobalKey();

  final GlobalKey globalKey;

  factory EnLetterPatternEntity.fromJson(Map<String, dynamic> json) {
    return EnLetterPatternEntity(text: json['text']?.toString());
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['text'] = text;
    return data;
  }
}

/// 音标实体类
class PhonicsResponseEntity extends Dessert with JsonSerializableMixin {
  final String? content;
  final String? type;
  final String? typeTitle;
  final List<EnWordEntityIpa>? ipa;
  final List<EnLetterPatternEntity>? letterPattern;
  final List<int>? wordIds;
  final List<EnWordEntity>? wordList;
  final dynamic rules;
  final List<EnEntityLearn>? learnTips;
  final String? access;
  final String? updated;
  final String? created;

  PhonicsResponseEntity({
    required int uid,
    this.content,
    this.type,
    this.typeTitle,
    this.ipa,
    this.letterPattern,
    this.wordIds,
    this.wordList,
    this.rules,
    this.learnTips,
    this.access,
    this.updated,
    this.created,
  })  : globalKey = GlobalKey(debugLabel: uid.toString()),
        super(uid: uid);

  final GlobalKey globalKey;

  factory PhonicsResponseEntity.fromJson(Map<String, dynamic> json) {
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

    // 处理 letterPattern 字段
    List<EnLetterPatternEntity> letterPatternList = [];
    if (json['letterPattern'] != null) {
      final v = json['letterPattern'];
      final arr0 = <EnLetterPatternEntity>[];
      v.forEach((v) {
        arr0.add(EnLetterPatternEntity(text: v));
      });
      letterPatternList = arr0;
    }

    // 处理 wordIds 字段
    List<int> wordIdsList = [];
    if (json['wordIds'] != null) {
      final v = json['wordIds'];
      final arr0 = <int>[];
      v.forEach((v) {
        arr0.add(v.toInt());
      });
      wordIdsList = arr0;
    }

    // 处理 wordList 字段
    List<EnWordEntity> wordEntityList = [];
    if (json['wordList'] != null) {
      final v = json['wordList'];
      final arr0 = <EnWordEntity>[];
      v.forEach((v) {
        if (v != null) {
          arr0.add(EnWordEntity.fromJson(v));
        }
      });
      wordEntityList = arr0;
    }

    // 处理 learnTips 字段
    List<EnEntityLearn> learnTipsList = [];
    if (json['learnTips'] != null) {
      final v = json['learnTips'];
      final arr0 = <EnEntityLearn>[];
      v.forEach((v) {
        arr0.add(EnEntityLearn.fromJson(v));
      });
      learnTipsList = arr0;
    }

    return PhonicsResponseEntity(
      uid: json['uid']?.toInt() ?? 0,
      content: json['content'],
      type: json['type'],
      typeTitle: json['typeTitle'],
      ipa: ipaList,
      letterPattern: letterPatternList,
      wordIds: wordIdsList,
      wordList: wordEntityList,
      rules: json['rules'],
      learnTips: learnTipsList,
      access: json['access']?.toString(),
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

    if (letterPattern != null) {
      data['letterPattern'] = letterPattern;
    }

    if (wordIds != null) {
      data['wordIds'] = wordIds;
    }

    if (wordList != null) {
      final v = wordList;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v.toJson());
      }
      data['wordList'] = arr0;
    }

    if (rules != null) {
      data['rules'] = rules;
    }

    if (learnTips != null) {
      final v = learnTips;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v.toJson());
      }
      data['learnTips'] = arr0;
    }

    data['access'] = access;
    data['updated'] = updated;
    data['created'] = created;

    return data;
  }

  PhonicsResponseEntity copyWith({
    int? uid,
    String? content,
    String? type,
    String? typeTitle,
    List<EnWordEntityIpa>? ipa,
    List<EnLetterPatternEntity>? letterPattern,
    List<int>? wordIds,
    List<EnWordEntity>? wordList,
    dynamic rules,
    List<EnEntityLearn>? learnTips,
    String? access,
    String? updated,
    String? created,
  }) {
    return PhonicsResponseEntity(
      uid: uid ?? this.uid,
      content: content ?? this.content,
      type: type ?? this.type,
      typeTitle: typeTitle ?? this.typeTitle,
      ipa: ipa ?? this.ipa,
      letterPattern: letterPattern ?? this.letterPattern,
      wordIds: wordIds ?? this.wordIds,
      wordList: wordList ?? this.wordList,
      rules: rules ?? this.rules,
      learnTips: learnTips ?? this.learnTips,
      access: access ?? this.access,
      updated: updated ?? this.updated,
      created: created ?? this.created,
    );
  }

  // 获取美音
  String? get americanIpa {
    if (ipa != null && ipa!.isNotEmpty) {
      for (var item in ipa!) {
        if (item.accent == 'US') {
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
  String get newUpdate => _formatDate(updated);

  String get newCreate => _formatDate(created);

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    return DateUtil.formatDateStr(dateStr, format: "yyyy/MM/dd");
  }
}
