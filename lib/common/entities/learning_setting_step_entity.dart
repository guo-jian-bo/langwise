import 'package:langwise/common/entities/entities.dart';

import '../enum/enum.dart';

class LearningSettingStepEntitySubButton {
/*
{
  "title": "开始评测",
  "jump": {
    "code": "userEvaluation",
    "params": {}
  }
} 
*/

  String? title;
  PushMessageEntityJump? jump;

  LearningSettingStepEntitySubButton({
    this.title,
    this.jump,
  });
  LearningSettingStepEntitySubButton.fromJson(Map<String, dynamic> json) {
    title = json['title']?.toString();
    jump = (json['jump'] != null) ? PushMessageEntityJump.fromJson(json['jump']) : null;
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['title'] = title;
    if (jump != null) {
      data['jump'] = jump!.toJson();
    }
    return data;
  }
}

class LearningSettingStepEntityButton {
/*
{
  "title": "开始评测",
  "jump": {
    "code": "userEvaluation",
    "params": {}
  }
} 
*/

  String? title;
  PushMessageEntityJump? jump;

  LearningSettingStepEntityButton({
    this.title,
    this.jump,
  });
  LearningSettingStepEntityButton.fromJson(Map<String, dynamic> json) {
    title = json['title']?.toString();
    jump = (json['jump'] != null) ? PushMessageEntityJump.fromJson(json['jump']) : null;
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['title'] = title;
    if (jump != null) {
      data['jump'] = jump!.toJson();
    }
    return data;
  }
}

class LearningSettingStepEntityStepTitles {
/*
{
  "stepIndex": 1,
  "stepCount": 4,
  "title": "填写信息"
} 
*/

  int? stepIndex;
  int? stepCount;
  String? title;

  LearningSettingStepEntityStepTitles({
    this.stepIndex,
    this.stepCount,
    this.title,
  });
  LearningSettingStepEntityStepTitles.fromJson(Map<String, dynamic> json) {
    stepIndex = json['stepIndex']?.toInt();
    stepCount = json['stepCount']?.toInt();
    title = json['title']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['stepIndex'] = stepIndex;
    data['stepCount'] = stepCount;
    data['title'] = title;
    return data;
  }
}

class LearningSettingStepEntity {
/*
{
  "uid": 2,
  "step": "ASSESSMENT",
  "stepIndex": 2,
  "stepCount": 4,
  "stepTitles": [
    {
      "stepIndex": 1,
      "stepCount": 4,
      "title": "填写信息"
    }
  ],
  "title": "做评测",
  "icon": null,
  "iconSvg": "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 576 512\"><path d=\"M234.7 42.7L197 56.8c-3 1.1-5 4-5 7.2s2 6.1 5 7.2l37.7 14.1L248.8 123c1.1 3 4 5 7.2 5s6.1-2 7.2-5l14.1-37.7L315 71.2c3-1.1 5-4 5-7.2s-2-6.1-5-7.2L277.3 42.7 263.2 5c-1.1-3-4-5-7.2-5s-6.1 2-7.2 5L234.7 42.7zM46.1 395.4c-18.7 18.7-18.7 49.1 0 67.9l34.6 34.6c18.7 18.7 49.1 18.7 67.9 0L529.9 116.5c18.7-18.7 18.7-49.1 0-67.9L495.3 14.1c-18.7-18.7-49.1-18.7-67.9 0L46.1 395.4zM484.6 82.6l-105 105-23.3-23.3 105-105 23.3 23.3zM7.5 117.2C3 118.9 0 123.2 0 128s3 9.1 7.5 10.8L64 160l21.2 56.5c1.7 4.5 6 7.5 10.8 7.5s9.1-3 10.8-7.5L128 160l56.5-21.2c4.5-1.7 7.5-6 7.5-10.8s-3-9.1-7.5-10.8L128 96 106.8 39.5C105.1 35 100.8 32 96 32s-9.1 3-10.8 7.5L64 96 7.5 117.2zm352 256c-4.5 1.7-7.5 6-7.5 10.8s3 9.1 7.5 10.8L416 416l21.2 56.5c1.7 4.5 6 7.5 10.8 7.5s9.1-3 10.8-7.5L480 416l56.5-21.2c4.5-1.7 7.5-6 7.5-10.8s-3-9.1-7.5-10.8L480 352l-21.2-56.5c-1.7-4.5-6-7.5-10.8-7.5s-9.1 3-10.8 7.5L416 352l-56.5 21.2z\" fill=\"currentColor\"/></svg>",
  "stepTitle": "开始听说读写能力评估",
  "stepDescription": "谁来学，就由谁来测。这不是一张固定卷子，系统会分别看听、说、读、写四项表现，答得轻松就会稍微变难，答得吃力就会回到更合适的难度。",
  "guideItems": [
    "四项能力分开判断，更容易看出真正短板"
  ],
  "color": "linear-gradient(180deg, rgba(255, 32, 86, 0.30) 0%, rgba(255, 32, 86, 0.00) 100%)",
  "button": {
    "title": "开始评测",
    "jump": {
      "code": "userEvaluation",
      "params": {}
    }
  },
  "subButton": {
    "title": "开始评测",
    "jump": {
      "code": "userEvaluation",
      "params": {}
    }
  },
  "jump": {
    "code": "userEvaluation",
    "params": {}
  },
  "created": "2026-06-16T14:58:01.152+00:00",
  "updated": "2026-06-16T14:58:01.152+00:00"
} 
*/

  int? uid;
  String? step;
  int? stepIndex;
  int? stepCount;
  List<LearningSettingStepEntityStepTitles?>? stepTitles;
  String? title;
  String? icon;
  String? iconSvg;
  String? stepTitle;
  String? stepDescription;
  List<String?>? guideItems;
  String? color;
  LearningSettingStepEntityButton? button;
  LearningSettingStepEntitySubButton? subButton;
  Map<String, dynamic>? params;
  PushMessageEntityJump? jump;
  String? created;
  String? updated;

  LearningSettingStepsEnum? get currentStep => LearningSettingStepsEnum.fromValue(step);

  LearningSettingStepEntity({
    this.uid,
    this.step,
    this.stepIndex,
    this.stepCount,
    this.stepTitles,
    this.title,
    this.icon,
    this.iconSvg,
    this.stepTitle,
    this.stepDescription,
    this.guideItems,
    this.color,
    this.button,
    this.params,
    this.subButton,
    this.jump,
    this.created,
    this.updated,
  });
  LearningSettingStepEntity.fromJson(Map<String, dynamic> json) {
    uid = json['uid']?.toInt();
    step = json['step']?.toString();
    stepIndex = json['stepIndex']?.toInt();
    stepCount = json['stepCount']?.toInt();
    if (json['stepTitles'] != null) {
      final v = json['stepTitles'];
      final arr0 = <LearningSettingStepEntityStepTitles>[];
      v.forEach((v) {
        arr0.add(LearningSettingStepEntityStepTitles.fromJson(v));
      });
      stepTitles = arr0;
    }
    title = json['title']?.toString();
    icon = json['icon']?.toString();
    iconSvg = json['iconSvg']?.toString();
    stepTitle = json['stepTitle']?.toString();
    stepDescription = json['stepDescription']?.toString();
    if (json['guideItems'] != null) {
      final v = json['guideItems'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      guideItems = arr0;
    }
    color = json['color']?.toString();
    button = (json['button'] != null) ? LearningSettingStepEntityButton.fromJson(json['button']) : null;
    subButton = (json['subButton'] != null) ? LearningSettingStepEntitySubButton.fromJson(json['subButton']) : null;
    if(json['params'] != null) {
      params = Map<String, dynamic>.from(json['params']);
    }
    jump = (json['jump'] != null) ? PushMessageEntityJump.fromJson(json['jump']) : null;
    created = json['created']?.toString();
    updated = json['updated']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = uid;
    data['step'] = step;
    data['stepIndex'] = stepIndex;
    data['stepCount'] = stepCount;
    if (stepTitles != null) {
      final v = stepTitles;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['stepTitles'] = arr0;
    }
    data['title'] = title;
    data['icon'] = icon;
    data['iconSvg'] = iconSvg;
    data['stepTitle'] = stepTitle;
    data['stepDescription'] = stepDescription;
    if (guideItems != null) {
      final v = guideItems;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['guideItems'] = arr0;
    }
    data['color'] = color;
    if (button != null) {
      data['button'] = button!.toJson();
    }
    if (subButton != null) {
      data['subButton'] = subButton!.toJson();
    }
    if (params != null) {
      data['params'] = params;
    }
    if (jump != null) {
      data['jump'] = jump!.toJson();
    }
    data['created'] = created;
    data['updated'] = updated;
    return data;
  }
}
