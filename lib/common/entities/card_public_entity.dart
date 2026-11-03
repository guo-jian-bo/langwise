
import 'entities.dart';

class LanguageText {
/*
{
  "lang": "en",
  "text": "The pronoun 'me' serves as the direct object of the verb 'Excuse', indicating the recipient of the action."
} 
*/

  String? lang;
  String? text;

  LanguageText({
    this.lang,
    this.text,
  });
  LanguageText.fromJson(Map<String, dynamic> json) {
    lang = json['lang']?.toString();
    text = json['text']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['lang'] = lang;
    data['text'] = text;
    return data;
  }
}

class TextReference {
/*
{
  "start": 2,
  "end": 2
} 
*/

  int? start;
  int? end;

  TextReference({
    this.start,
    this.end,
  });
  TextReference.fromJson(Map<String, dynamic> json) {
    start = json['start']?.toInt();
    end = json['end']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['start'] = start;
    data['end'] = end;
    return data;
  }
}

class CardContentDifficulty {
/*
{
  "max": 3,
  "min": 3
} 
*/

  int? max;
  int? min;

  CardContentDifficulty({
    this.max,
    this.min,
  });
  CardContentDifficulty.fromJson(Map<String, dynamic> json) {
    max = json['max']?.toInt();
    min = json['min']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['max'] = max;
    data['min'] = min;
    return data;
  }
}

class CardDetilsEntityStat {
/*
{
  "listen": 1,
  "listenExp": 100,
  "speak": 1,
  "speakExp": 1,
  "read": 1,
  "readExp": 1,
  "write": 1,
  "writeExp": 1
  "write": 1
} 
*/

  int? listen;
  double? listenPct;
  int? listenExp;
  int? speak;
  double? speakPct;
  int? speakExp;
  int? read;
  double? readPct;
  int? readExp;
  int? write;
  double? writePct;
  int? writeExp;

  CardDetilsEntityStat({
    this.listen,
    this.listenPct,
    this.listenExp,
    this.speak,
    this.speakPct,
    this.speakExp,
    this.read,
    this.readPct,
    this.readExp,
    this.write,
    this.writePct,
    this.writeExp,
  });
  CardDetilsEntityStat.fromJson(Map<String, dynamic> json) {
    listen = json['listen']?.toInt();
    listenPct = json['listenPct']?.toDouble();

    listenExp = json['listenExp']?.toInt();
    speak = json['speak']?.toInt();
    speakPct = json['speakPct']?.toDouble();
    speakExp = json['speakExp']?.toInt();
    read = json['read']?.toInt();
    readPct = json['readPct']?.toDouble();
    readExp = json['readExp']?.toInt();
    write = json['write']?.toInt();
    writePct = json['writePct']?.toDouble();
    writeExp = json['writeExp']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['listen'] = listen;
    data['listenPct'] = listenPct;
    data['listenExp'] = listenExp;
    data['speak'] = speak;
    data['speakPct'] = speakPct;
    data['speakExp'] = speakExp;
    data['read'] = read;
    data['readPct'] = readPct;
    data['readExp'] = readExp;
    data['write'] = write;
    data['writePct'] = writePct;
    data['writeExp'] = writeExp;
    return data;
  }
}

class ElementsCardStar {
/*
{
  "star": 4,
  "title": "A",
  "color": "0xffF59E0B",
  "iconUrl": "",
} 
*/

  int? star;
  String? title;
  String? color;
  String? iconUrl;

  ElementsCardStar({
    this.star,
    this.title,
    this.color,
    this.iconUrl,
  });
  ElementsCardStar.fromJson(Map<String, dynamic> json) {
    star = json['star']?.toInt();
    title = json['title']?.toString();
    color = json['color']?.toString();
    iconUrl = json['iconUrl']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['star'] = star;
    data['title'] = title;
    data['color'] = color;
    data['iconUrl'] = iconUrl;
    return data;
  }
}



class ElementsCardEntityDatasags {
/*
{
  "gloss": [
    {
      "lang": "en",
      "text": "n."
    }
  ],
  "style": [
    {
      "theme": "DARK",
      "color": "#FFFFFF",
      "fontsize": 16,
      "italic": false,
      "weight": 400,
      "backgroundColor": "rgba(59, 130, 246, 0.8)",
      "borderColor": "#3B82F6"
    }
  ]
} 
*/

  List<LanguageText?>? gloss;
  List<ThemeTextStyleEntity?>? style;

  ElementsCardEntityDatasags({
    this.gloss,
    this.style,
  });
  ElementsCardEntityDatasags.fromJson(Map<String, dynamic> json) {
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

class ElementsCardEntityDataVideo {
/*
{
  "styleId": 10,
  "videoId": 1985062,
  "videoUrl": "https://video.timelywise.cn/video/generated/36FDCDF9BA0E37D792AD78F7F7C3A9F6.mp4",
  "videoKey": "video/generated/36FDCDF9BA0E37D792AD78F7F7C3A9F6.mp4",
  "duration": 2.92,
  "startSeconds": 0.0,
  "endSeconds": 2.92,
  "md5": "36FDCDF9BA0E37D792AD78F7F7C3A9F6",
  "isMute": false,
  "firstFrameUrl": "https://img.timelywise.cn/knowledge/semantic/5AE29A86FC852E46861900CCD610EAB6.webp",
  "firstFrameKey": "knowledge/semantic/5AE29A86FC852E46861900CCD610EAB6.webp",
  "firstFrameMd5": "5AE29A86FC852E46861900CCD610EAB6",
  "ass": "Dialogue: ...",
  "translateAss": [
    {
      "lang": "zh",
      "text": "Dialogue: ..."
    }
  ]
}
*/
  int? styleId;
  int? videoId;
  String? videoUrl;
  String? videoKey;
  double? duration;
  double? startSeconds;
  double? endSeconds;
  String? md5;
  bool? isMute;
  String? firstFrameUrl;
  String? firstFrameKey;
  String? firstFrameMd5;
  String? ass;
  List<LanguageText?>? translateAss;

  ElementsCardEntityDataVideo({
    this.styleId,
    this.videoId,
    this.videoUrl,
    this.videoKey,
    this.duration,
    this.startSeconds,
    this.endSeconds,
    this.md5,
    this.isMute,
    this.firstFrameUrl,
    this.firstFrameKey,
    this.firstFrameMd5,
    this.ass,
    this.translateAss,
  });

  ElementsCardEntityDataVideo.fromJson(Map<String, dynamic> json) {
    styleId = json['styleId']?.toInt();
    videoId = json['videoId']?.toInt();
    videoUrl = json['videoUrl']?.toString();
    videoKey = json['videoKey']?.toString();
    duration = json['duration']?.toDouble();
    startSeconds = json['startSeconds']?.toDouble();
    endSeconds = json['endSeconds']?.toDouble();
    md5 = json['md5']?.toString();
    isMute = json['isMute'];
    firstFrameUrl = json['firstFrameUrl']?.toString();
    firstFrameKey = json['firstFrameKey']?.toString();
    firstFrameMd5 = json['firstFrameMd5']?.toString();
    ass = json['ass']?.toString();
    if (json['translateAss'] != null) {
      final v = json['translateAss'];
      final arr0 = <LanguageText>[];
      v.forEach((v) {
        arr0.add(LanguageText.fromJson(v));
      });
      translateAss = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['styleId'] = styleId;
    data['videoId'] = videoId;
    data['videoUrl'] = videoUrl;
    data['videoKey'] = videoKey;
    data['duration'] = duration;
    data['startSeconds'] = startSeconds;
    data['endSeconds'] = endSeconds;
    data['md5'] = md5;
    data['isMute'] = isMute;
    data['firstFrameUrl'] = firstFrameUrl;
    data['firstFrameKey'] = firstFrameKey;
    data['firstFrameMd5'] = firstFrameMd5;
    data['ass'] = ass;
    if (translateAss != null) {
      final v = translateAss;
      final arr0 = [];
      for (final item in v!) {
        arr0.add(item!.toJson());
      }
      data['translateAss'] = arr0;
    }
    return data;
  }
}

class ElementsCardEntityDatas {
/*
{
  "contentType": "EN_WORD",
  "contentTypeTitle": "英语单词",
  "contentId": 143500,
  "semanticId": 1,
  "semanticIds" [1,2],
  "content": "the",
  "definition": "用于特指或泛指名词的定冠词，表示特定、已知或唯一的事物，或用于强调、计量单位等特定语境",
  "difficulty": {
    "max": 1,
    "min": 1
  },
  "imageUrl": "http://img.timelywise.cn/knowledge/semantic/FE4E50E6DD6C1D9B0911F4A6348B6444.webp?auth_key=1748960416-0kq6dg4dt20g-0-87769d8b7f073a85d279a815a1360f8d",
  "phonetic": "ðə",
  "audioUrl": null,
  "rights": "NORMAL",
  "jump": null,
  "pos": "PREFIX",
  "posTitle": "前缀",
  "cardStar": {
    "star": 4,
    "title": "A",
    "color": "0xffF59E0B"
  },
  "contentList": [
    {
      "contentType": "EN_WORD",
      "contentTypeTitle": "单词",
      "contentId": 101838,
      "content": "addition",
      "definition": "添加物；加法 (数学运算)",
      "audioUrl": "",
      "difficulty": {
        "max": 3,
        "min": 3
      },
      "phonetic": "əˈdɪʃn",
      "pos": "n.",
      "posTitle": "名词"
    }
  ],
  "gloss": [
    {
      "lang": "en",
      "text": "in (preposition of place/time)"
    },
    {
      "lang": "zh",
      "text": "在...里 (表示位置/时间的介词)"
    }
  ],
} 
*/
  int? uid;
  String? contentType;
  String? contentTypeTitle;
  int? contentId;
  int? semanticId;
  List<int?>? semanticIds;
  String? content;
  String? definition;
  CardContentDifficulty? difficulty;
  String? imageUrl;
  String? phonetic;
  String? audioUrl;
  String? rights;
  String? jump;
  String? pos;
  String? posTitle;
  List<ElementsCardEntityDatas?>? contentList;
  List<LanguageText?>? gloss;
  ElementsCardStar? cardStar;
  List<PronunciationsEntity?>? pronunciations;
  ElementsCardEntityDataVideo? video;
  List<ElementsCardEntityDatasags?>? tags;
  bool? favorited;

  bool get isFavorited => favorited??false;

  ElementsCardEntityDatas({
    this.uid,
    this.contentType,
    this.contentTypeTitle,
    this.contentId,
    this.semanticId,
    this.content,
    this.definition,
    this.difficulty,
    this.imageUrl,
    this.phonetic,
    this.audioUrl,
    this.rights,
    this.jump,
    this.pos,
    this.posTitle,
    this.contentList,
    this.gloss,
    this.cardStar,
    this.pronunciations,
    this.video,
    this.tags,
    this.favorited,
  });
  ElementsCardEntityDatas.fromJson(Map<String, dynamic> json) {
    uid = json['uid']?.toInt();
    contentType = json['contentType']?.toString();
    contentTypeTitle = json['contentTypeTitle']?.toString();
    contentId = json['contentId']?.toInt();
    semanticId = json['semanticId']?.toInt();
    semanticIds = json['semanticIds']?.cast<int>();
    content = json['content']?.toString();
    definition = json['definition']?.toString();
    difficulty = (json['difficulty'] != null) ? CardContentDifficulty.fromJson(json['difficulty']) : null;
    imageUrl = json['imageUrl']?.toString();
    phonetic = json['phonetic']?.toString();
    audioUrl = json['audioUrl']?.toString();
    rights = json['rights']?.toString();
    jump = json['jump']?.toString();
    pos = json['pos']?.toString();
    posTitle = json['posTitle']?.toString();
    if (json['contentList'] != null) {
      final v = json['contentList'];
      final arr0 = <ElementsCardEntityDatas>[];
      v.forEach((v) {
        arr0.add(ElementsCardEntityDatas.fromJson(v));
      });
      contentList = arr0;
    }
    if (json['gloss'] != null) {
      final v = json['gloss'];
      final arr0 = <LanguageText>[];
      v.forEach((v) {
        arr0.add(LanguageText.fromJson(v));
      });
      gloss = arr0;
    }
    if (json['cardStar'] != null) {
      cardStar = ElementsCardStar.fromJson(json['cardStar']);
    }
    if (json['pronunciations'] != null) {
      final v = json['pronunciations'];
      final arr0 = <PronunciationsEntity>[];
      v.forEach((v) {
        arr0.add(PronunciationsEntity.fromJson(v));
      });
      pronunciations = arr0;
    }
    if (json['video'] != null) {
      video = ElementsCardEntityDataVideo.fromJson(json['video']);
    }
    if (json['tags'] != null) {
      final v = json['tags'];
      final arr0 = <ElementsCardEntityDatasags>[];
      v.forEach((v) {
        arr0.add(ElementsCardEntityDatasags.fromJson(v));
      });
      tags = arr0;
    }
    favorited = json['favorited'];
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = uid;
    data['contentType'] = contentType;
    data['contentTypeTitle'] = contentTypeTitle;
    data['contentId'] = contentId;
    data['semanticId'] = semanticId;
    data['semanticIds'] = semanticIds;
    data['content'] = content;
    data['definition'] = definition;
    if (difficulty != null) {
      data['difficulty'] = difficulty!.toJson();
    }
    data['imageUrl'] = imageUrl;
    data['phonetic'] = phonetic;
    data['audioUrl'] = audioUrl;
    data['rights'] = rights;
    data['jump'] = jump;
    data['pos'] = pos;
    data['posTitle'] = posTitle;
    if (contentList != null) {
      final v = contentList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['contentList'] = arr0;
    }
    if (gloss != null) {
      final v = gloss;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['gloss'] = arr0;
    }
    if (cardStar != null) {
      data['cardStar'] = cardStar!.toJson();
    }
    if (pronunciations != null) {
      final v = pronunciations;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['pronunciations'] = arr0;
    }
    if (video != null) {
      data['video'] = video!.toJson();
    }
    if (tags != null) {
      final v = tags;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['tags'] = arr0;
    }
    data['favorited'] = favorited;
    return data;
  }
}
