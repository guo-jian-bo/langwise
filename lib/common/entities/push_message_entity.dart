


class PushMessageEntityJump {
/*
{
  "code": "manage_lesson_execirse_ai_prevew",
  "params": {
    "aiRecordId": "10"
  }
} 
*/

  String? code;
  Map<String, dynamic>? params;

  PushMessageEntityJump({
    this.code,
    this.params,
  });

  PushMessageEntityJump.fromJson(Map<String, dynamic> json) {
    code = json['code']?.toString();
    if(json['params'] != null) {
      params = Map<String, dynamic>.from(json['params']);
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['code'] = code;
    if (params != null) {
      data['params'] = params;
    }
    return data;
  }
}

class PushMessageEntityLayout{
  /// 图片高度
  double? height;
  /// 图片比例 例如 "5/1"
  String? ratio;

  PushMessageEntityLayout({
    this.height,
    this.ratio,
  });

  PushMessageEntityLayout.fromJson(Map<String, dynamic> json) {
    height = json['height']?.toDouble();
    ratio = json['ratio']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['height'] = height;
    data['ratio'] = ratio;
    return data;
  }
}

class PushMessageEntity {
/*
{
  "title": "《完形填空》题型创建完成",
  "content": null,
  "jump": {
    "code": "manage_lesson_execirse_ai_prevew",
    "params": {
      "aiRecordId": "10"
    }
  },
  "category": "MANAGE",
  "module": "SYSTEM",
  "code": "question",
  "extra": null,
  "read": 0,
  "created": "2025-04-10T03:39:41.327+00:00"
} 
*/

  int? uid;
  /// `0`: 只有红点, `1`: 顶部 Banner, `2`: Toast, `4`: 弹窗 Modal
  int? display;
  /// display的点击后的操作模式
  /// * 0，null 按照jump来操作，jump == null 弹默认窗，jump != null 直接跳转页面
  /// * 1 一定弹model，如果jump != null 显示按钮“去查看”
  /// * 2 直接跳转, 如果jump == null 则弹窗显示
  /// * 3 直接关闭
  int? displayOperate;
  String? title;
  String? desc;
  String? content;
  /// 支持 txt、md，默认 txt
  String? contentType;
  PushMessageEntityJump? jump;
  String? category;
  String? module;
  String? code;
  String? extra;
  int? read;
  String? created;

  // --- 以下是首页活动相关 -----
  String? iconUrl;
  String? started;
  String? ended;
  PushMessageEntityLayout? layout;

  /// 是否上报消息 消息分发中心使用
  bool? report;

  /// 分类是不是管理端消息
  bool get categoryIsManage => category == "MANAGE";

  /// 是否是默认格式
  bool get isContentMd => contentType == "md";

  PushMessageEntity({
    this.uid,
    this.display,
    this.displayOperate,
    this.title,
    this.desc,
    this.content,
    this.contentType,
    this.jump,
    this.category,
    this.module,
    this.code,
    this.extra,
    this.read,
    this.created,
    this.iconUrl,
    this.started,
    this.ended,
    this.layout,
    this.report,
  });
  PushMessageEntity.fromJson(Map<String, dynamic> json) {
    uid = json['uid']?.toInt();
    display = json['display']?.toInt();
    displayOperate = json['displayOperate']?.toInt();
    title = json['title']?.toString();
    desc = json['desc']?.toString();
    content = json['content']?.toString();
    contentType = json['contentType']?.toString();
    jump = (json['jump'] != null) ? PushMessageEntityJump.fromJson(json['jump']) : null;
    category = json['category']?.toString();
    module = json['module']?.toString();
    code = json['code']?.toString();
    extra = json['extra']?.toString();
    read = json['read']?.toInt();
    created = json['created']?.toString();
    iconUrl = json['iconUrl']?.toString();
    started = json['started']?.toString();
    ended = json['ended']?.toString();
    layout = (json['layout'] != null) ? PushMessageEntityLayout.fromJson(json['layout']) : null;
    report = json['report'];
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = uid;
    data['display'] = display;
    data['displayOperate'] = displayOperate;
    data['title'] = title;
    data['desc'] = desc;
    data['content'] = content;
    data['contentType'] = contentType;
    if (jump != null) {
      data['jump'] = jump!.toJson();
    }
    data['category'] = category;
    data['module'] = module;
    data['code'] = code;
    data['extra'] = extra;
    data['read'] = read;
    data['created'] = created;
    data['iconUrl'] = iconUrl;
    data['started'] = started;
    data['ended'] = ended;
    if (layout != null) {
      data['layout'] = layout!.toJson();
    }
    data['report'] = report;
    return data;
  }
}



class PushMessageServiceEnitiy {

  /// 消息
  PushMessageEntity message;

  /// 是否是返回页面
  bool isBackPage;

  /// 页面返回的参数
  dynamic backPageResult;

  PushMessageServiceEnitiy({
    required this.message,
    this.isBackPage = false,
    this.backPageResult,
  });

}