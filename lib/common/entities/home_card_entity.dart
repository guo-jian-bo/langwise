import 'entities.dart';



class HomeCardEntityItemsButton {
  String? pattern;
  List<ThemeColorEntity?>? color;
  HomeCardEntityItemsButton({
    this.pattern,
    this.color,
  });

  HomeCardEntityItemsButton.fromJson(Map<String, dynamic> json) {
    pattern = json['pattern']?.toString();
    if (json['color'] != null) {
      final v = json['color'];
      final arr0 = <ThemeColorEntity>[];
      v.forEach((v) {
        arr0.add(ThemeColorEntity.fromJson(v));
      });
      color = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['pattern'] = pattern;
    if (color != null) {
      final v = color;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['color'] = arr0;
    }
    return data;
  }
}

class HomeCardEntityItems {
  String? code;
  String? access;
  LockEntity? rights;
  PushMessageEntityJump? jump;
  List<dynamic>? list;
  ThemeTextEntity? title;
  ThemeTextEntity? subTitle;
  List<ThemeColorEntity?>? bgColor;
  List<ThemeImageEntity?>? bgImage;
  List<ThemeTextEntity?>? descriptions;
  HomeCardEntityItemsButton? button;
  String? helpVideoUrl;

  HomeCardEntityItems({
    this.code,
    this.access,
    this.rights,
    this.jump,
    this.list,
    this.title,
    this.subTitle,
    this.bgColor,
    this.bgImage,
    this.descriptions,
    this.button,
    this.helpVideoUrl,
  });
  HomeCardEntityItems.fromJson(Map<String, dynamic> json) {
    code = json['code']?.toString();
    access = json['access']?.toString();
    rights = (json['rights'] != null)
        ? LockEntity.fromJson(json['rights'])
        : null;
    list = json['list'];
    title = (json['title'] != null)
        ? ThemeTextEntity.fromJson(json['title'])
        : null;
    subTitle = (json['subTitle'] != null)
        ? ThemeTextEntity.fromJson(json['subTitle'])
        : null;
    if (json['bgColor'] != null) {
      final v = json['bgColor'];
      final arr0 = <ThemeColorEntity>[];
      v.forEach((v) {
        arr0.add(ThemeColorEntity.fromJson(v));
      });
      bgColor = arr0;
    }
    if (json['bgImage'] != null) {
      final v = json['bgImage'];
      final arr0 = <ThemeImageEntity>[];
      v.forEach((v) {
        arr0.add(ThemeImageEntity.fromJson(v));
      });
      bgImage = arr0;
    }
    if (json['descriptions'] != null) {
      final v = json['descriptions'];
      final arr0 = <ThemeTextEntity>[];
      v.forEach((v) {
        arr0.add(ThemeTextEntity.fromJson(v));
      });
      descriptions = arr0;
    }
    button = (json['button'] != null)
        ? HomeCardEntityItemsButton.fromJson(json['button'])
        : null;
    jump = (json['jump'] != null)
        ? PushMessageEntityJump.fromJson(json['jump'])
        : null;
    helpVideoUrl = json['helpVideoUrl']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['code'] = code;
    data['access'] = access;
    
    if(data['rights'] != null){
      data['rights'] = rights!.toJson();
    }

    if (title != null) {
      data['title'] = title!.toJson();
    }
    if (subTitle != null) {
      data['subTitle'] = subTitle!.toJson();
    }
    if (bgImage != null) {
      final v = bgImage;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['bgImage'] = arr0;
    }
    if (descriptions != null) {
      final v = descriptions;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['descriptions'] = arr0;
    }
    if (button != null) {
      data['button'] = button!.toJson();
    }
    if (jump != null) {
      data['jump'] = jump!.toJson();
    }
    data['helpVideoUrl'] = helpVideoUrl;
    return data;
  }
}

class HomeCardEntity {
/*
{
  "items": [
    {
      "code": "todayTask",
      "jump": {
        "code": "startExercise",
        "params": {
          "exerciseIds": [
            82103
          ]
        }
      },
      "list": [
        {
          "title": {
            "text": "今日任务",
            "style": [
              {
                "theme": "DARK",
                "color": "rgb(255, 255, 255, 1)",
                "fontsize": 36,
                "italic": false,
                "weight": 600
              }
            ]
          },
          "subTitle": {
            "text": "先集中复习同语言的所有记忆内容，再统一学习同语言的所有计划的新知识，智能去重提高学习效率。",
            "style": [
              {
                "theme": "DARK",
                "color": "rgb(255, 255, 255, 0.6)",
                "fontsize": 28,
                "italic": false,
                "weight": 600
              }
            ]
          },
          "data": {
            "exerciseIds": [
              82103
            ]
          }
        }
      ]
    }
  ]
} 
*/

  List<HomeCardEntityItems?>? items;

  HomeCardEntity({
    this.items,
  });
  HomeCardEntity.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      final v = json['items'];
      final arr0 = <HomeCardEntityItems>[];
      v.forEach((v) {
        arr0.add(HomeCardEntityItems.fromJson(v));
      });
      items = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (items != null) {
      final v = items;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['items'] = arr0;
    }
    return data;
  }
}
