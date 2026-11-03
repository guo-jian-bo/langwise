


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

  String? title;
  String? content;
  PushMessageEntityJump? jump;
  String? category;
  String? module;
  String? code;
  String? extra;
  int? read;
  String? created;

  PushMessageEntity({
    this.title,
    this.content,
    this.jump,
    this.category,
    this.module,
    this.code,
    this.extra,
    this.read,
    this.created,
  });
  PushMessageEntity.fromJson(Map<String, dynamic> json) {
    title = json['title']?.toString();
    content = json['content']?.toString();
    jump = (json['jump'] != null) ? PushMessageEntityJump.fromJson(json['jump']) : null;
    category = json['category']?.toString();
    module = json['module']?.toString();
    code = json['code']?.toString();
    extra = json['extra']?.toString();
    read = json['read']?.toInt();
    created = json['created']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['title'] = title;
    data['content'] = content;
    if (jump != null) {
      data['jump'] = jump!.toJson();
    }
    data['category'] = category;
    data['module'] = module;
    data['code'] = code;
    data['extra'] = extra;
    data['read'] = read;
    data['created'] = created;
    return data;
  }
}
