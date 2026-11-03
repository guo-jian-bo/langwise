// 章法页（用户端）壳数据与蓝图书架列表的模型，对齐
// GET /languages/write/zhenxie/composition/discourse/home
// POST /languages/write/zhenxie/composition/blueprint/list

import '../../../../../common/entities/entities.dart';
import 'zhenxie_composition_stages_models.dart';

/// 一套主题色：同一语义在 LIGHT / DARK 下取不同的颜色值。
class CompositionThemeColorModel {
  /// 主题标识：LIGHT / DARK
  String? theme;

  /// 色的用途标识，如 primary
  String? code;

  /// 该主题下的主色
  String? color;

  /// 该主题下的文字色
  String? textColor;

  CompositionThemeColorModel({this.theme, this.code, this.color, this.textColor});

  factory CompositionThemeColorModel.fromJson(Map<String, dynamic> json) {
    return CompositionThemeColorModel(
      theme: json['theme']?.toString(),
      code: json['code']?.toString(),
      color: json['color']?.toString(),
      textColor: json['textColor']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'theme': theme,
      'code': code,
      'color': color,
      'textColor': textColor,
    };
  }
}

/// 一个里程碑：学段 / 雅思 / CEFR / 剑桥。
class CompositionMilestoneModel {
  String? nid;

  /// 里程碑类型：school / ielts / cefr / cambridge，可能为空串
  String? kind;

  /// 同难度档内排序
  int? order;

  List<LanguageText> name;

  CompositionMilestoneModel({
    this.nid,
    this.kind,
    this.order,
    this.name = const <LanguageText>[],
  });

  factory CompositionMilestoneModel.fromJson(Map<String, dynamic> json) {
    return CompositionMilestoneModel(
      nid: json['nid']?.toString(),
      kind: json['kind']?.toString(),
      order: json['order']?.toInt(),
      name: (json['name'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(LanguageText.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'nid': nid,
      'kind': kind,
      'order': order,
      'name': name.map((item) => item.toJson()).toList(),
    };
  }
}

/// 一道大关：同一难度档上的全部里程碑。
class CompositionMilestoneGateModel {
  /// 难度档位，与蓝图 difficulty 对齐
  int? difficulty;

  List<CompositionMilestoneModel> items;

  CompositionMilestoneGateModel({this.difficulty, this.items = const <CompositionMilestoneModel>[]});

  factory CompositionMilestoneGateModel.fromJson(Map<String, dynamic> json) {
    return CompositionMilestoneGateModel(
      difficulty: json['difficulty']?.toInt(),
      items: (json['items'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(CompositionMilestoneModel.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'difficulty': difficulty,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

/// 一种段型：底栏「每篇都由这 N 种段拼出来」的一条。
class CompositionParagraphTypeModel {
  String? nid;
  List<LanguageText> name;
  List<LanguageText> description;
  int? order;

  CompositionParagraphTypeModel({
    this.nid,
    this.name = const <LanguageText>[],
    this.description = const <LanguageText>[],
    this.order,
  });

  factory CompositionParagraphTypeModel.fromJson(Map<String, dynamic> json) {
    return CompositionParagraphTypeModel(
      nid: json['nid']?.toString(),
      name: (json['name'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(LanguageText.fromJson)
          .toList(),
      description: (json['description'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(LanguageText.fromJson)
          .toList(),
      order: json['order']?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'nid': nid,
      'name': name.map((item) => item.toJson()).toList(),
      'description': description.map((item) => item.toJson()).toList(),
      'order': order,
    };
  }
}

/// 章法页壳卡片信息。
class CompositionDiscourseCardModel {
  String? code;
  String? title;
  String? subTitle;
  String? description;

  CompositionDiscourseCardModel({this.code, this.title, this.subTitle, this.description});

  factory CompositionDiscourseCardModel.fromJson(Map<String, dynamic> json) {
    return CompositionDiscourseCardModel(
      code: json['code']?.toString(),
      title: json['title']?.toString(),
      subTitle: json['subTitle']?.toString(),
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'code': code,
      'title': title,
      'subTitle': subTitle,
      'description': description,
    };
  }
}

/// 一种文类在章法页的汇总：文类本体 + 各主题下的颜色 + 蓝图 / 阶梯计数。
class CompositionGenreSummaryModel {
  CompositionGenreModel? genre;

  /// 各主题下的文类色，按 theme 匹配当前项目主题取用
  List<CompositionThemeColorModel> colors;

  /// 该文类的蓝图张数
  int? compositionBlueprintCount;

  /// 该文类的阶梯个数
  int? compositionStageCount;

  CompositionGenreSummaryModel({
    this.genre,
    this.colors = const <CompositionThemeColorModel>[],
    this.compositionBlueprintCount,
    this.compositionStageCount,
  });

  factory CompositionGenreSummaryModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? genreJson = json['genre'] is Map<String, dynamic>
        ? json['genre'] as Map<String, dynamic>
        : null;
    return CompositionGenreSummaryModel(
      genre: genreJson == null ? null : CompositionGenreModel.fromJson(genreJson),
      colors: (genreJson?['colors'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(CompositionThemeColorModel.fromJson)
          .toList(),
      compositionBlueprintCount: json['compositionBlueprintCount']?.toInt(),
      compositionStageCount: json['compositionStageCount']?.toInt(),
    );
  }

  /// 取某个主题下的文类色值，没有该主题时返回空。
  String? themeColorCode(String themeName) {
    for (final CompositionThemeColorModel item in colors) {
      if ((item.theme ?? '').toUpperCase() == themeName.toUpperCase()) return item.color;
    }
    return '';
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'genre': genre?.toJson(),
      'colors': colors.map((item) => item.toJson()).toList(),
      'compositionBlueprintCount': compositionBlueprintCount,
      'compositionStageCount': compositionStageCount,
    };
  }
}

/// 书架一格大关：由 milestones 按难度档派生，学段 / 雅思当抬头，其余进别名。
/// 派生在 controller 完成，模型只承载结果。
class CompositionShelfGateModel {
  /// 难度档位，与蓝图 difficulty 对齐
  int difficulty;

  /// 抬头
  String title;

  /// 别名，多个用「 · 」拼接
  String alias;

  CompositionShelfGateModel({required this.difficulty, required this.title, required this.alias});
}

/// 章法页壳数据。
class CompositionDiscourseHomeModel {
  CompositionDiscourseCardModel? card;

  /// 六道大关，按难度档升序
  List<CompositionMilestoneGateModel> milestones;

  /// 段型条文案，如「每篇都由这 9 种段拼出来」
  String? paragraphTypeHint;

  List<CompositionParagraphTypeModel> paragraphTypes;

  /// 四种文类及各自的主题色、计数
  List<CompositionGenreSummaryModel> genres;

  /// 书架视图的汇总后缀，如「张蓝图 · 六道大关」
  String? shelfSummaryText;

  /// 地图视图的汇总后缀，如「个阶梯 · 顺着走」
  String? mapSummaryText;

  CompositionDiscourseHomeModel({
    this.card,
    this.milestones = const <CompositionMilestoneGateModel>[],
    this.paragraphTypeHint,
    this.paragraphTypes = const <CompositionParagraphTypeModel>[],
    this.genres = const <CompositionGenreSummaryModel>[],
    this.shelfSummaryText,
    this.mapSummaryText,
  });

  factory CompositionDiscourseHomeModel.fromJson(Map<String, dynamic> json) {
    return CompositionDiscourseHomeModel(
      card: json['card'] is Map<String, dynamic> ? CompositionDiscourseCardModel.fromJson(json['card']) : null,
      milestones: (json['milestones'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(CompositionMilestoneGateModel.fromJson)
          .toList(),
      paragraphTypeHint: json['paragraphTypeHint']?.toString(),
      paragraphTypes: (json['paragraphTypes'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(CompositionParagraphTypeModel.fromJson)
          .toList(),
      genres: (json['genres'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(CompositionGenreSummaryModel.fromJson)
          .toList(),
      shelfSummaryText: json['shelfSummaryText']?.toString(),
      mapSummaryText: json['mapSummaryText']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'card': card?.toJson(),
      'milestones': milestones.map((item) => item.toJson()).toList(),
      'paragraphTypeHint': paragraphTypeHint,
      'paragraphTypes': paragraphTypes.map((item) => item.toJson()).toList(),
      'genres': genres.map((item) => item.toJson()).toList(),
      'shelfSummaryText': shelfSummaryText,
      'mapSummaryText': mapSummaryText,
    };
  }
}

/// 书架瓦片：一张文章蓝图。
class CompositionShelfBlueprintModel {
  String? nid;

  /// 所属家族，点开瓦片按家族维度打开蓝图详情
  String? compositionFamilyNid;

  /// 所属文类，决定瓦片颜色
  String? genreNid;

  List<LanguageText> name;
  List<LanguageText> description;

  /// 封面，可能为空，空则退回文类色块 + 皮图标
  String? coverUrl;

  /// 皮的 nid，无封面时退回这张皮的线稿图标
  String? skinNid;

  /// 开始教这张蓝图的难度档，决定它落在哪一格大关
  int? difficulty;

  /// 有文首
  bool hasHead;

  /// 有文尾
  bool hasTail;

  CompositionShelfBlueprintModel({
    this.nid,
    this.compositionFamilyNid,
    this.genreNid,
    this.name = const <LanguageText>[],
    this.description = const <LanguageText>[],
    this.coverUrl,
    this.skinNid,
    this.difficulty,
    this.hasHead = false,
    this.hasTail = false,
  });

  factory CompositionShelfBlueprintModel.fromJson(Map<String, dynamic> json) {
    return CompositionShelfBlueprintModel(
      nid: json['nid']?.toString(),
      compositionFamilyNid: json['compositionFamilyNid']?.toString(),
      genreNid: json['genreNid']?.toString(),
      name: (json['name'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(LanguageText.fromJson)
          .toList(),
      description: (json['description'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(LanguageText.fromJson)
          .toList(),
      coverUrl: json['coverUrl']?.toString(),
      skinNid: json['skinNid']?.toString(),
      difficulty: json['difficulty']?.toInt(),
      hasHead: json['hasHead'] == true,
      hasTail: json['hasTail'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'nid': nid,
      'compositionFamilyNid': compositionFamilyNid,
      'genreNid': genreNid,
      'name': name.map((item) => item.toJson()).toList(),
      'description': description.map((item) => item.toJson()).toList(),
      'coverUrl': coverUrl,
      'skinNid': skinNid,
      'difficulty': difficulty,
      'hasHead': hasHead,
      'hasTail': hasTail,
    };
  }
}
