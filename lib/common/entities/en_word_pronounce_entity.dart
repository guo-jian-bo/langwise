import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:uuid/uuid.dart';

///
/// EnWordPronounceEntity - 单词发音实体类
/// 用于封装单词发音相关的数据，包括音节和音素信息
///

/// 单词发音实体类
class EnWordPronounceEntity extends Dessert with JsonSerializableMixin {
  /*
  {
    "uid": 127575,
    "content": "disinherit",
    "nationalIpa": "US",
    "ipa": "ˌdɪsɪnˈherɪt",
    "syllables": [...],
    "phonics": [...]
  }
  */
  String? content;
  String? nationalIpa;
  String? ipa;
  List<EnWordPronounceEntitySyllable>? syllables;
  List<EnWordPronounceEntityPhonic>? phonics;
  String? ipaAudioUrl;
  String? updated;
  String? created;

  EnWordPronounceEntity({
    required int uid,
    this.content,
    this.nationalIpa,
    this.ipa,
    this.syllables,
    this.phonics,
    this.ipaAudioUrl,
    this.updated,
    this.created,
  })  : globalKey = GlobalKey(debugLabel: uid.toString()),
        super(uid: uid);

  final GlobalKey globalKey;

  factory EnWordPronounceEntity.fromJson(Map<String, dynamic> json) {
    // 处理syllables字段
    List<EnWordPronounceEntitySyllable> _syllables = [];
    if (json['syllables'] != null) {
      final v = json['syllables'];
      final arr0 = <EnWordPronounceEntitySyllable>[];
      v.forEach((v) {
        if (v != null) {
          arr0.add(EnWordPronounceEntitySyllable.fromJson(v));
        }
      });
      _syllables = arr0;
    }

    // 处理phonics字段
    List<EnWordPronounceEntityPhonic> _phonics = [];
    if (json['phonics'] != null) {
      final v = json['phonics'];
      final arr0 = <EnWordPronounceEntityPhonic>[];
      v.forEach((v) {
        if (v != null) {
          arr0.add(EnWordPronounceEntityPhonic.fromJson(v));
        }
      });
      _phonics = arr0;
    }

    return EnWordPronounceEntity(
      uid: json['uid']?.toInt() ?? 0,
      content: json['content']?.toString(),
      nationalIpa: json['nationalIpa']?.toString(),
      ipa: json['ipa']?.toString(),
      syllables: _syllables,
      phonics: _phonics,
      ipaAudioUrl: json['ipaAudioUrl']?.toString(),
      updated: json['updated']?.toString(),
      created: json['created']?.toString(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = uid;
    data['content'] = content;
    data['nationalIpa'] = nationalIpa;
    data['ipa'] = ipa;
    data['ipaAudioUrl'] = ipaAudioUrl;

    // 处理syllables字段
    if (syllables != null) {
      final v = syllables;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v.toJson());
      }
      data['syllables'] = arr0;
    }

    // 处理phonics字段
    if (phonics != null) {
      final v = phonics;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v.toJson());
      }
      data['phonics'] = arr0;
    }

    return data;
  }

  // 获取完整的IPA表示
  String get fullIpa => '$ipa';

  // 获取音节数量
  int get syllableCount => syllables?.length ?? 0;

  // 获取音素数量
  int get phonicCount => phonics?.length ?? 0;

  // 获取有音频的音素列表
  List<EnWordPronounceEntityPhonic> get phonicsWithAudio {
    return phonics?.where((phonic) => phonic.audioUrl != null && phonic.audioUrl!.isNotEmpty).toList() ?? [];
  }

  // 直接用·连接所有音节的ipa值
  String get syllableText {
    if (syllables == null || syllables!.isEmpty) {
      return '';
    }

    List<String> syllableIpas = [];
    for (var syllable in syllables!) {
      if (syllable.ipa != null && syllable.ipa!.isNotEmpty) {
        syllableIpas.add(syllable.ipa!);
      }
    }

    // 用·连接所有音节的ipa值
    return syllableIpas.join('·');
  }

  // 直接用·连接所有音素的ipa值
  String get phonicText {
    if (phonics == null || phonics!.isEmpty) {
      return '';
    }

    List<String> phonicIpas = [];
    for (var phonic in phonics!) {
      if (phonic.ipa != null && phonic.ipa!.isNotEmpty) {
        phonicIpas.add(phonic.ipa!);
      }
    }

    // 用·连接所有音素的ipa值
    return phonicIpas.join('·');
  }

  // 时间格式化（复用相同逻辑）
  String get newUpdate => _formatDate(updated);

  String get newCreate => _formatDate(created);

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    return DateUtil.formatDateStr(dateStr, format: "yyyy/MM/dd");
  }
}

/// 音节实体类
class EnWordPronounceEntitySyllable {
  /*
  {
    "ipa": "ˌɪ",
    "graphemes": "di",
    "positions": [0, 1]
  }
  */
  String? ipa;
  String? graphemes;
  List<int>? positions;
  final String uuid;
  final GlobalKey globalKey;

  // 用于编辑字形的控制器
  TextEditingController? ipaTextController;

  // IPA错误状态
  bool ipaError = false;

  // 用于编辑字形的控制器
  TextEditingController? graphemesTextController;

  // 字母错误状态
  bool graphemesError = false;

  // 用于编辑位置的控制器
  TextEditingController? positionController;

  // 位置错误状态
  bool positionError = false;

  /// 唯一ID生成策略
  static String _generateUniqueId() {
    return const Uuid().v6();
  }

  EnWordPronounceEntitySyllable({
    this.ipa,
    this.graphemes,
    this.positions,
    this.ipaTextController,
    this.graphemesTextController,
    this.positionController,
    String? uuid,
  })  : uuid = uuid ?? _generateUniqueId(),
        globalKey = GlobalKey(debugLabel: uuid);

  factory EnWordPronounceEntitySyllable.fromJson(Map<String, dynamic> json) {
    List<int> _positions = [];
    if (json['positions'] != null) {
      final v = json['positions'];
      final arr0 = <int>[];
      v.forEach((v) {
        arr0.add(v.toInt());
      });
      _positions = arr0;
    }

    return EnWordPronounceEntitySyllable(
      ipa: json['ipa']?.toString(),
      graphemes: json['graphemes']?.toString(),
      positions: _positions,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['ipa'] = ipa;
    data['graphemes'] = graphemes;
    if (positions != null) {
      final v = positions;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v);
      }
      data['positions'] = arr0;
    }
    return data;
  }

  /// 解析位置控制器的文本，将逗号分割的字符串转换为整数数组
  List<int> parsePositions() {
    if (positionController == null || positionController!.text.trim().isEmpty) {
      return [];
    }

    try {
      // 按逗号分割字符串
      List<String> parts = positionController!.text.split(',');
      // 将每个部分转换为整数
      return parts.map((part) => int.tryParse(part.trim()) ?? 0).toList();
    } catch (e) {
      return [];
    }
  }

  /// 从控制器生成JSON数据
  Map<String, dynamic> toJsonFromControllers() {
    return {
      "ipa": ipaTextController?.text.trim() ?? "",
      "graphemes": graphemesTextController?.text.trim() ?? "",
      "positions": parsePositions()
    };
  }

  bool get isIpaEmpty => ipaTextController == null || ipaTextController!.text.trim().isEmpty;

  bool get isGraphemesEmpty => graphemesTextController == null || graphemesTextController!.text.trim().isEmpty;

  bool get isPositionEmpty => positionController == null || positionController!.text.trim().isEmpty;

  bool containsInWord(String word) {
    final graphemes = graphemesTextController?.text.trim() ?? '';
    return graphemes.isNotEmpty && word.contains(graphemes);
  }
}

/// 音素实体类
class EnWordPronounceEntityPhonic {
  /*
  {
    "ipa": "d",
    "graphemes": "d",
    "positions": [0],
    "audioUrl": "http://track.timelywise.cn/..."
  }
  */
  String? ipa;
  String? graphemes;
  List<int>? positions;
  String? audioUrl;
  final String uuid;
  final GlobalKey globalKey;

  // IPA错误状态
  bool ipaError = false;

  // 字母错误状态
  bool graphemesError = false;

  // 位置错误状态
  bool positionError = false;

// 用于编辑字形的控制器
  TextEditingController? ipaTextController;

  // 用于编辑字形的控制器
  TextEditingController? graphemesTextController;

  // 用于编辑位置的控制器
  TextEditingController? positionController;

  /// 唯一ID生成策略
  static String _generateUniqueId() {
    return const Uuid().v6();
  }

  EnWordPronounceEntityPhonic({
    this.ipa,
    this.graphemes,
    this.positions,
    this.audioUrl,
    this.ipaTextController,
    this.graphemesTextController,
    this.positionController,
    String? uuid,
  })  : uuid = uuid ?? _generateUniqueId(),
        globalKey = GlobalKey(debugLabel: uuid);

  factory EnWordPronounceEntityPhonic.fromJson(Map<String, dynamic> json) {
    List<int> _positions = [];
    if (json['positions'] != null) {
      final v = json['positions'];
      final arr0 = <int>[];
      v.forEach((v) {
        arr0.add(v.toInt());
      });
      _positions = arr0;
    }

    return EnWordPronounceEntityPhonic(
      ipa: json['ipa']?.toString(),
      graphemes: json['graphemes']?.toString(),
      positions: _positions,
      audioUrl: json['audioUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['ipa'] = ipa;
    data['graphemes'] = graphemes;
    if (positions != null) {
      final v = positions;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v);
      }
      data['positions'] = arr0;
    }
    data['audioUrl'] = audioUrl;
    return data;
  }

  /// 解析位置控制器的文本，将逗号分割的字符串转换为整数数组
  List<int> parsePositions() {
    if (positionController == null || positionController!.text.trim().isEmpty) {
      return [];
    }

    try {
      // 按逗号分割字符串
      List<String> parts = positionController!.text.split(',');
      // 将每个部分转换为整数
      return parts.map((part) => int.tryParse(part.trim()) ?? 0).toList();
    } catch (e) {
      return [];
    }
  }

  /// 从控制器生成JSON数据
  Map<String, dynamic> toJsonFromControllers() {
    return {
      "ipa": ipaTextController?.text.trim() ?? "",
      "graphemes": graphemesTextController?.text.trim() ?? "",
      "positions": parsePositions(),
    };
  }

  bool get isIpaEmpty => ipaTextController == null || ipaTextController!.text.trim().isEmpty;

  bool get isGraphemesEmpty => graphemesTextController == null || graphemesTextController!.text.trim().isEmpty;

  bool get isPositionEmpty => positionController == null || positionController!.text.trim().isEmpty;

  bool containsInWord(String word) {
    final graphemes = graphemesTextController?.text.trim() ?? '';
    return graphemes.isNotEmpty && word.contains(graphemes);
  }
}
