import '../enum/enum.dart';
import 'entities.dart';

class KnowledgeCommonEntityListProgress {
/*
{
  "type": "all",
  "progress": 100,
  "status": 1
} 
*/

  String? type;
  int? progress;
  int? status;

  KnowledgeCommonEntityListProgress({
    this.type,
    this.progress,
    this.status,
  });
  KnowledgeCommonEntityListProgress.fromJson(Map<String, dynamic> json) {
    type = json['type']?.toString();
    progress = json['progress']?.toInt();
    status = json['status']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['type'] = type;
    data['progress'] = progress;
    data['status'] = status;
    return data;
  }
}

class KnowledgeCommonEntityListGloss {
/*
{
  "gloss": [
    {
      "lang": "en",
      "text": "Feelings & Emotions"
    }
  ],
  "style": [
    {
      "theme": "LIGHT",
      "color": "rgba(245, 158, 11, 1)",
      "fontsize": 16,
      "italic": false,
      "weight": 400,
      "backgroundColor": "rgba(245, 158, 11, 0.20)"
    }
  ]
} 
*/

  List<LanguageText?>? gloss;
  List<ThemeTextStyleEntity?>? style;

  KnowledgeCommonEntityListGloss({
    this.gloss,
    this.style,
  });
  KnowledgeCommonEntityListGloss.fromJson(Map<String, dynamic> json) {
    if (json['gloss'] != null) {
      final v = json['gloss'];
      final arr0 = <LanguageText>[];
      v.forEach((v) {
        arr0.add(LanguageText.fromJson(v));
      });
      gloss = arr0;
    }
    if (json['style'] != null) {
      final v = json['style'];
      final arr0 = <ThemeTextStyleEntity>[];
      v.forEach((v) {
        arr0.add(ThemeTextStyleEntity.fromJson(v));
      });
      style = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (gloss != null) {
      final v = gloss;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['gloss'] = arr0;
    }
    if (style != null) {
      final v = style;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['style'] = arr0;
    }
    return data;
  }
}

class KnowledgeCommonEntityListCategory {
/*
{
  "text": "Feelings & Emotions"
} 
*/

  String? text;

  KnowledgeCommonEntityListCategory({
    this.text,
  });
  KnowledgeCommonEntityListCategory.fromJson(Map<String, dynamic> json) {
    text = json['text']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['text'] = text;
    return data;
  }
}

class KnowledgeCommonEntityListCoverImage {
/*
{
  "type": "image",
  "mediaId": 4609436,
  "url": "https://img.timelywise.cn/knowledge/semantic/3986ECA0CD5AC6DDAE3541A09A939DEF.webp?auth_key=1782997216-w57s206ukp1z-0-9038232c3854fb05a56eddf4f3dbfe13",
  "key": "knowledge/semantic/3986ECA0CD5AC6DDAE3541A09A939DEF.webp",
  "md5": "3986ECA0CD5AC6DDAE3541A09A939DEF"
} 
*/

  String? type;
  int? mediaId;
  String? url;
  String? key;
  String? md5;

  KnowledgeCommonEntityListCoverImage({
    this.type,
    this.mediaId,
    this.url,
    this.key,
    this.md5,
  });
  KnowledgeCommonEntityListCoverImage.fromJson(Map<String, dynamic> json) {
    type = json['type']?.toString();
    mediaId = json['mediaId']?.toInt();
    url = json['url']?.toString();
    key = json['key']?.toString();
    md5 = json['md5']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['type'] = type;
    data['mediaId'] = mediaId;
    data['url'] = url;
    data['key'] = key;
    data['md5'] = md5;
    return data;
  }
}

class KnowledgeCommonEntityListCoverVideo {
  // {
//           "type": "video",
//           "mediaId": 2007189,
//           "url": "https://video.timelywise.cn/video/generated/620C714135CD198123B248B43CFCAFFD.mp4?auth_key=1782999705-vf0t40w0n6l0-0-3d21d581733a61028b3790b3695713b6",
//           "key": "video/generated/620C714135CD198123B248B43CFCAFFD.mp4",
//           "md5": "620C714135CD198123B248B43CFCAFFD",
//           "duration": 5.16,
//           "start": 0,
//           "end": 2.91
//         }

  String? type;
  int? mediaId;
  String? url;
  String? key;
  String? md5;
  double? duration;
  int? start;
  double? end;

  KnowledgeCommonEntityListCoverVideo({
    this.type,
    this.mediaId,
    this.url,
    this.key,
    this.md5,
    this.duration,
    this.start,
    this.end,
  });
  KnowledgeCommonEntityListCoverVideo.fromJson(Map<String, dynamic> json) {
    type = json['type']?.toString();
    mediaId = json['mediaId']?.toInt();
    url = json['url']?.toString();
    key = json['key']?.toString();
    md5 = json['md5']?.toString();
    duration = json['duration']?.toDouble();
    start = json['start']?.toInt();
    end = json['end']?.toDouble();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['type'] = type;
    data['mediaId'] = mediaId;
    data['url'] = url;
    data['key'] = key;
    data['md5'] = md5;
    data['duration'] = duration;
    data['start'] = start;
    data['end'] = end;
    return data;
  }
}

class KnowledgeCommonEntityListContent {
/*
{
  "type": "EN_SONG",
  "uid": 45329
} 
*/

  String? type;
  int? styleId;
  String? dialect;
  int? uid;
  int? semanticId;

  KnowledgeCommonEntityListContent({
    this.type,
    this.styleId,
    this.dialect,
    this.uid,
    this.semanticId,
  });
  KnowledgeCommonEntityListContent.fromJson(Map<String, dynamic> json) {
    type = json['type']?.toString();
    styleId = json['styleId']?.toInt();
    dialect = json['dialect']?.toString();
    uid = json['uid']?.toInt();
    semanticId = json['semanticId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['type'] = type;
    data['styleId'] = styleId;
    data['dialect'] = dialect;
    data['uid'] = uid;
    data['semanticId'] = semanticId;
    return data;
  }
}

class KnowledgeCommonEntityListParamsDataSlot {
  int? order;
  String? beatNid;
  String? paragraphTypeNid;
  ArticleBlueprintEntityOption? paragraphType;
  String? fill;

  KnowledgeCommonEntityListParamsDataSlot({
    this.order,
    this.beatNid,
    this.paragraphTypeNid,
    this.paragraphType,
    this.fill,
  });
  KnowledgeCommonEntityListParamsDataSlot.fromJson(Map<String, dynamic> json) {
    order = json['order']?.toInt();
    beatNid = json['beatNid']?.toString();
    paragraphTypeNid = json['paragraphTypeNid']?.toString();
    paragraphType = json['paragraphType'] != null ? ArticleBlueprintEntityOption.fromJson(json['paragraphType']) : null;
    fill = json['fill']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['order'] = order;
    data['beatNid'] = beatNid;
    data['paragraphTypeNid'] = paragraphTypeNid;
    if (paragraphType != null) {
      data['paragraphType'] = paragraphType!.toJson();
    }
    data['fill'] = fill;
    return data;
  }
}

class KnowledgeCommonEntityListParamsData {
  String? nid;
  List<LanguageText?>? name;
  String? compositionBlueprintNid;
  ArticleBlueprintEntityDifficulty? difficulty;
  String? headFill;
  String? tailFill;
  bool? hasHead;
  List<LanguageText?>? headName;
  bool? hasTail;
  List<LanguageText?>? tailName;
  List<KnowledgeCommonEntityListParamsDataSlot?>? slots;
  String? coverUrl;
  String? coverKey;
  String? text;
  PushMessageEntityJump? jump;
  List<Pronunciations?>? pronunciations;

  KnowledgeCommonEntityListParamsData({
    this.nid,
    this.name,
    this.compositionBlueprintNid,
    this.difficulty,
    this.headFill,
    this.tailFill,
    this.hasHead,
    this.headName,
    this.hasTail,
    this.tailName,
    this.slots,
    this.coverUrl,
    this.coverKey,
    this.text,
    this.jump,
    this.pronunciations,
  });
  KnowledgeCommonEntityListParamsData.fromJson(Map<String, dynamic> json) {
    nid = json['nid']?.toString();
    if (json['name'] != null) {
      final v = json['name'];
      final arr0 = <LanguageText>[];
      v.forEach((v) {
        arr0.add(LanguageText.fromJson(v));
      });
      name = arr0;
    }
    compositionBlueprintNid = json['compositionBlueprintNid']?.toString();
    difficulty = json['difficulty'] != null ? ArticleBlueprintEntityDifficulty.fromJson(json['difficulty']) : null;
    headFill = json['headFill']?.toString();
    tailFill = json['tailFill']?.toString();
    hasHead = json['hasHead'];
    if (json['headName'] != null) {
      final v = json['headName'];
      final arr0 = <LanguageText>[];
      v.forEach((v) {
        arr0.add(LanguageText.fromJson(v));
      });
      headName = arr0;
    }
    hasTail = json['hasTail'];
    if (json['tailName'] != null) {
      final v = json['tailName'];
      final arr0 = <LanguageText>[];
      v.forEach((v) {
        arr0.add(LanguageText.fromJson(v));
      });
      tailName = arr0;
    }
    if (json['slots'] != null) {
      final v = json['slots'];
      final arr0 = <KnowledgeCommonEntityListParamsDataSlot>[];
      v.forEach((v) {
        arr0.add(KnowledgeCommonEntityListParamsDataSlot.fromJson(v));
      });
      slots = arr0;
    }
    coverUrl = json['coverUrl']?.toString();
    coverKey = json['coverKey']?.toString();
    text = json['text']?.toString();
    jump = json['jump'] != null ? PushMessageEntityJump.fromJson(json['jump']) : null;

    if (json['pronunciations'] != null) {
      final v = json['pronunciations'];
      final arr0 = <Pronunciations>[];
      v.forEach((v) {
        arr0.add(Pronunciations.fromJson(v));
      });
      pronunciations = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['nid'] = nid;
    if (name != null) {
      final v = name;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['name'] = arr0;
    }
    data['compositionBlueprintNid'] = compositionBlueprintNid;
    if (difficulty != null) {
      data['difficulty'] = difficulty!.toJson();
    }
    data['headFill'] = headFill;
    data['tailFill'] = tailFill;
    data['hasHead'] = hasHead;
    if (headName != null) {
      final v = headName;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['headName'] = arr0;
    }
    data['hasTail'] = hasTail;
    if (tailName != null) {
      final v = tailName;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['tailName'] = arr0;
    }
    if (slots != null) {
      final v = slots;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['slots'] = arr0;
    }
    data['coverUrl'] = coverUrl;
    data['coverKey'] = coverKey;
    data['text'] = text;
    data['jump'] = jump?.toJson();

    if (pronunciations != null) {
      final v = pronunciations;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['pronunciations'] = arr0;
    }

    return data;
  }
}

class KnowledgeCommonEntityListParams {
  String? type;
  PushMessageEntityJump? jump;
  KnowledgeCommonEntityListParamsData? data;

  bool get isSource => type == "source";
  bool get isPronunciation => type == "pronunciation";
  bool get isCompositionStage => type == "compositionStage";

  KnowledgeCommonEntityListParams({
    this.type,
    this.jump,
    this.data,
  });

  KnowledgeCommonEntityListParams.fromJson(Map<String, dynamic> json) {
    type = json['type']?.toString();
    jump = json['jump'] != null ? PushMessageEntityJump.fromJson(json['jump']) : null;
    data = json['data'] != null ? KnowledgeCommonEntityListParamsData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final dataMap = <String, dynamic>{};
    dataMap['type'] = type;
    dataMap['jump'] = jump?.toJson();
    dataMap['data'] = data?.toJson();
    return dataMap;
  }
}

class KnowledgeCommonEntityListMemberStudy {
  ElementsCardStar? starInfo;
  dynamic progressInfo;

  KnowledgeCommonEntityListMemberStudy({
    this.starInfo,
    this.progressInfo,
  });

  KnowledgeCommonEntityListMemberStudy.fromJson(Map<String, dynamic> json) {
    starInfo = json['starInfo'] != null
        ? ElementsCardStar.fromJson(json['starInfo'])
        : null;
    progressInfo = json['progressInfo'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (starInfo != null) {
      data['starInfo'] = starInfo!.toJson();
    }
    data['progressInfo'] = progressInfo;
    return data;
  }
}

class KnowledgeCommonEntityList {
/*
{
  "contentType": "EN_SONG",
  "contentTypeTitle": "Song",
  "contentId": 45329,
  "content": {
    "type": "EN_SONG",
    "uid": 45329
  },
  "title": "How Do You Feel Today?",
  "subTitle": "Hello, hello, how do you feel?\nTell me now, if it's real.\nI am excited on a sunny day.\nShe is angry, but it's okay.\nThey are sad when things go wrong.\nWe are worried, but we stay strong.\nHow do you feel?\nHow do you feel?\nI am glad, and you, it's a big deal.\nShare your emotions loud and clear.\nHappy or sad, we have nothing to fear.\nHe looks worried, why is that?\nWith a friend, we have a chat.\nI saw her yesterday.\nShe was glad, now she's excited, not too sad.\nHow do you feel?\nHow do you feel?\nI am glad, and you, it's a big deal.\nShare your emotions loud and clear.\nHappy or sad, we have nothing to fear.\nDon't worry, don't be poor in spirit.\nHelpful words can bring us near.\nWhy are you late? It's not too bad.\nTogether we were happy, not angry or sad.\nFeelings, feelings, all around.\nIn our hearts, they can be found.",
  "description": [
    {
      "lang": "zh",
      "text": "这是一首以情绪为主题的英语儿歌，体裁为中国民谣儿歌（Chinese Folk Kids），难度约A1。歌词通过重复的问答句式介绍excited、angry、sad、worried、glad等常见情绪词汇，并鼓励孩子大声分享感受，整体旋律轻快、易于跟唱。适合小学低年级、约6-9岁的学习者，用于情绪词汇启蒙和跟唱练习。"
    }
  ],
  "focus": [
    {
      "lang": "zh",
      "text": "情绪主题英语儿歌；情绪词汇（excited/angry/sad/worried/glad）；A1 跟唱启蒙；中国民谣儿歌风格；适龄小学低年级 / 约6-9岁；重复问答句式；鼓励表达感受"
    }
  ],
  "coverImage": {
    "type": "image",
    "mediaId": 4609436,
    "url": "https://img.timelywise.cn/knowledge/semantic/3986ECA0CD5AC6DDAE3541A09A939DEF.webp?auth_key=1782997216-w57s206ukp1z-0-9038232c3854fb05a56eddf4f3dbfe13",
    "key": "knowledge/semantic/3986ECA0CD5AC6DDAE3541A09A939DEF.webp",
    "md5": "3986ECA0CD5AC6DDAE3541A09A939DEF"
  },
  "coverVideo": null,
  "category": {
    "text": "Feelings & Emotions"
  },
  "subCategory": {
    "text": "Chinese Folk Kids"
  },
  "tags": [
    {
      "gloss": [
        {
          "lang": "en",
          "text": "Feelings & Emotions"
        }
      ],
      "style": [
        {
          "theme": "LIGHT",
          "color": "rgba(245, 158, 11, 1)",
          "fontsize": 16,
          "italic": false,
          "weight": 400,
          "backgroundColor": "rgba(245, 158, 11, 0.20)"
        }
      ]
    }
  ],
  "params": null,
  "rights": {
    "access": "NORMAL",
    "rights": "NORMAL"
  },
  "progress": {
    "type": "all",
    "progress": 100,
    "status": 1
  },
  "learnModules": [
    {
      "type": "listen",
      "progress": 100,
      "status": 1
    }
  ],
  "jump": {
    "code": "songMV",
    "params": {
      "contents": [
        {
          "contentId": 45329,
          "contentType": "EN_SONG"
        }
      ],
      "contentId": 45329,
      "contentType": "EN_SONG"
    }
  }
} 
*/

  String? contentType;
  KnowledgeCommonEntityListGloss? contentTypeTitle;
  int? knowledgeId;
  int? contentId;
  KnowledgeCommonEntityListContent? content;
  String? title;
  String? subTitle;
  List<LanguageText?>? subTitles;
  List<LanguageText?>? description;
  List<LanguageText?>? focus;
  KnowledgeCommonEntityListCoverImage? coverImage;
  KnowledgeCommonEntityListCoverVideo? coverVideo;
  KnowledgeCommonEntityListCategory? category;
  KnowledgeCommonEntityListCategory? subCategory;
  List<KnowledgeCommonEntityListGloss?>? tags;
  KnowledgeCommonEntityListMemberStudy? memberStudy;
  KnowledgeCommonEntityListParams? params;
  LockEntity? rights;
  KnowledgeCommonEntityListProgress? progress;
  List<KnowledgeCommonEntityListProgress?>? learnModules;
  PushMessageEntityJump? jump;
  bool? favorited;
  int? duration;
  String? pos;
  String? posTitle;
  bool? locked;
  String? access;

  KnowledgeTypeEnum? get contentTypeEnum => KnowledgeTypeEnum.fromRawValue(contentType ?? "");

  /// 是否是词典
  bool get isDictionary =>
      contentTypeEnum == KnowledgeTypeEnum.EN_WORD ||
      contentTypeEnum == KnowledgeTypeEnum.EN_PHRASE ||
      contentTypeEnum == KnowledgeTypeEnum.EN_SENTENCE;

  /// 是否前端可见
  bool get accessIsVisible => access == "NORMAL";

  KnowledgeCommonEntityList({
    this.contentType,
    this.contentTypeTitle,
    this.knowledgeId,
    this.contentId,
    this.content,
    this.title,
    this.subTitle,
    this.subTitles,
    this.description,
    this.focus,
    this.coverImage,
    this.coverVideo,
    this.category,
    this.subCategory,
    this.tags,
    this.memberStudy,
    this.params,
    this.rights,
    this.progress,
    this.learnModules,
    this.jump,
    this.favorited,
    this.duration,
    this.pos,
    this.posTitle,
    this.locked,
    this.access,
  });
  KnowledgeCommonEntityList.fromJson(Map<String, dynamic> json) {
    contentType = json['contentType']?.toString();

    contentTypeTitle = (json['contentTypeTitle'] != null) ? KnowledgeCommonEntityListGloss.fromJson(json['contentTypeTitle']) : null;
    knowledgeId = json['knowledgeId']?.toInt();
    contentId = json['contentId']?.toInt();
    content = (json['content'] != null) ? KnowledgeCommonEntityListContent.fromJson(json['content']) : null;
    title = json['title']?.toString();
    subTitle = json['subTitle']?.toString();
    if(json['subTitles'] != null){
      final v = json['subTitles'];
      final arr0 = <LanguageText?>[];
      v.forEach((v) {
        arr0.add(LanguageText.fromJson(v));
      });
      subTitles = arr0;
    }

    if (json['description'] != null) {
      final v = json['description'];
      final arr0 = <LanguageText>[];
      v.forEach((v) {
        arr0.add(LanguageText.fromJson(v));
      });
      description = arr0;
    }
    if (json['focus'] != null) {
      final v = json['focus'];
      final arr0 = <LanguageText>[];
      v.forEach((v) {
        arr0.add(LanguageText.fromJson(v));
      });
      focus = arr0;
    }
    coverImage = (json['coverImage'] != null) ? KnowledgeCommonEntityListCoverImage.fromJson(json['coverImage']) : null;
    coverVideo = json['coverVideo'] != null ? KnowledgeCommonEntityListCoverVideo.fromJson(json['coverVideo']) : null;
    category = (json['category'] != null) ? KnowledgeCommonEntityListCategory.fromJson(json['category']) : null;
    subCategory = (json['subCategory'] != null) ? KnowledgeCommonEntityListCategory.fromJson(json['subCategory']) : null;
    if (json['tags'] != null) {
      final v = json['tags'];
      final arr0 = <KnowledgeCommonEntityListGloss>[];
      v.forEach((v) {
        arr0.add(KnowledgeCommonEntityListGloss.fromJson(v));
      });
      tags = arr0;
    }
    memberStudy = json['memberStudy'] != null
        ? KnowledgeCommonEntityListMemberStudy.fromJson(json['memberStudy'])
        : null;
    params = (json['params'] != null) ? KnowledgeCommonEntityListParams.fromJson(json['params']) : null;
    rights = (json['rights'] != null) ? LockEntity.fromJson(json['rights']) : null;
    progress = (json['progress'] != null) ? KnowledgeCommonEntityListProgress.fromJson(json['progress']) : null;
    if (json['learnModules'] != null) {
      final v = json['learnModules'];
      final arr0 = <KnowledgeCommonEntityListProgress>[];
      v.forEach((v) {
        arr0.add(KnowledgeCommonEntityListProgress.fromJson(v));
      });
      learnModules = arr0;
    }
    jump = (json['jump'] != null) ? PushMessageEntityJump.fromJson(json['jump']) : null;
    favorited = json['favorited'];
    duration = json['duration']?.toInt();
    pos = json['pos']?.toString();
    posTitle = json['posTitle']?.toString();
    locked = json['locked'];
    access = json['access']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['contentType'] = contentType;
    data['contentTypeTitle'] = contentTypeTitle?.toJson();
    data['knowledgeId'] = knowledgeId;
    data['contentId'] = contentId;
    if (content != null) {
      data['content'] = content!.toJson();
    }
    data['title'] = title;
    data['subTitle'] = subTitle;
    if(subTitles != null){
      final v = subTitles;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['subTitles'] = arr0;
    }

    if (description != null) {
      final v = description;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['description'] = arr0;
    }
    if (focus != null) {
      final v = focus;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['focus'] = arr0;
    }
    if (coverImage != null) {
      data['coverImage'] = coverImage!.toJson();
    }
    data['coverVideo'] = coverVideo?.toJson();
    if (category != null) {
      data['category'] = category!.toJson();
    }
    if (subCategory != null) {
      data['subCategory'] = subCategory!.toJson();
    }
    if (tags != null) {
      final v = tags;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['tags'] = arr0;
    }
    if (memberStudy != null) {
      data['memberStudy'] = memberStudy!.toJson();
    }
    if (params != null) {
      data['params'] = params!.toJson();
    }
    if (rights != null) {
      data['rights'] = rights!.toJson();
    }
    if (progress != null) {
      data['progress'] = progress!.toJson();
    }
    if (learnModules != null) {
      final v = learnModules;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['learnModules'] = arr0;
    }
    if (jump != null) {
      data['jump'] = jump!.toJson();
    }
    data['favorited'] = favorited;
    data['duration'] = duration;
    data['pos'] = pos;
    data['posTitle'] = posTitle;
    data['locked'] = locked;
    data['access'] = access;
    return data;
  }
}

class KnowledgeCommonEntity {
/*
{
  "list": [
    {
      "courseType": "OFFICIAL",
      "courseTypeName": "官方课程",
      "moduleId": 249,
      "moduleName": "日常活动",
      "moduleCoverUrl": "https://img.timelywise.cn/knowledge/semantic/46CF341EB84F677DD6B90B79E32C187C.webp?auth_key=1782980106-jtt9f96zcjds-0-0d8bfa588c6732d7b6fb6de14137f616",
      "unitId": 2752,
      "unitName": "Unit 1 日常活动1",
      "unitDescription": "学习4个常见的和日常互动相关的动词，2个名词。学习最简单的打招呼方式。",
      "moduleDifficulty": {
        "max": 0,
        "min": 0
      },
      "intentCards": [
        {
          "uid": 13442,
          "unitId": 2752,
          "status": "active",
          "kind": "theme",
          "priority": "core",
          "sort": 10,
          "title": [
            {
              "lang": "zh",
              "text": "日常活动与问候主题内容推荐"
            }
          ],
          "subtitle": [
            {
              "lang": "zh",
              "text": "本单元围绕日常活动和问候展开，看看更多相关主题的有趣内容。"
            }
          ],
          "cta": [
            {
              "lang": "zh",
              "text": "探索更多日常活动主题"
            }
          ],
          "explanation": [
            {
              "lang": "zh",
              "text": "基于单元主题“日常活动与问候”生成搜索词，帮助用户巩固主题认知。"
            }
          ],
          "query": [
            {
              "lang": "zh",
              "text": "适合Pre A1学习者的日常活动和问候主题英语内容"
            }
          ],
          "filters": [
            {
              "code": "difficulty",
              "values": [
                "0"
              ]
            }
          ]
        }
      ]
    }
  ]
} 
*/

  List<KnowledgeCommonEntityList?>? list;

  KnowledgeCommonEntity({
    this.list,
  });
  KnowledgeCommonEntity.fromJson(Map<String, dynamic> json) {
    if (json['list'] != null) {
      final v = json['list'];
      final arr0 = <KnowledgeCommonEntityList>[];
      v.forEach((v) {
        arr0.add(KnowledgeCommonEntityList.fromJson(v));
      });
      list = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (list != null) {
      final v = list;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['list'] = arr0;
    }
    return data;
  }
}
