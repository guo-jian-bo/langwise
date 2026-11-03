class ManageEnglishContentManagementAudioAccentModel {
  // 唯一标识（字符串）
  final String? id;

  // 版本
  final int? v;

  // 业务 uid（可空）
  final int? uid;

  // 名称与国家
  final String? name;
  final String? national;

  // 来源/模型信息
  final String? sourceType;
  final String? provider;

  // 音色与情绪
  final String? timbre;
  final String? emotion;

  // 用户关联
  final int? userId;

  // 描述与访问级别
  final String? description;
  final String? access;

  // 时间戳
  final DateTime? updated;
  final DateTime? created;

  // 性别
  final String? gender;

  const ManageEnglishContentManagementAudioAccentModel({
    this.id,
    this.v,
    this.uid,
    this.name,
    this.national,
    this.sourceType,
    this.provider,
    this.timbre,
    this.emotion,
    this.userId,
    this.description,
    this.access,
    this.updated,
    this.created,
    this.gender,
  });

  // JSON 反序列化（字段可空）
  factory ManageEnglishContentManagementAudioAccentModel.fromJson(
      Map<String, dynamic> json) {
    return ManageEnglishContentManagementAudioAccentModel(
      id: json['id']?.toString(),
      v: (json['v'] is int) ? json['v'] as int : null,
      uid: (json['uid'] is int) ? json['uid'] as int : null,
      name: json['name']?.toString(),
      national: json['national']?.toString(),
      sourceType: json['sourceType']?.toString(),
      provider: json['provider']?.toString(),
      timbre: json['timbre']?.toString(),
      emotion: json['emotion']?.toString(),
      userId: (json['userId'] is int) ? json['userId'] as int : null,
      description: json['description']?.toString(),
      access: json['access']?.toString(),
      updated: (json['updated'] is String)
          ? DateTime.tryParse(json['updated'])
          : null,
      created: (json['created'] is String)
          ? DateTime.tryParse(json['created'])
          : null,
      gender: json['gender']?.toString(),
    );
  }

  // JSON 序列化（保留可空）
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'v': v,
      'uid': uid,
      'name': name,
      'national': national,
      'sourceType': sourceType,
      'provider': provider,
      'timbre': timbre,
      'emotion': emotion,
      'userId': userId,
      'description': description,
      'access': access,
      'updated': updated?.toIso8601String(),
      'created': created?.toIso8601String(),
      'gender': gender,
    };
  }
}

class ManageEnglishContentManagementAudioModel {
  final String? phoneme;
  final double? duration;
  final int? size;
  final String? url;
  final String? dialog;
  final String? message;
  final String? audioKey;

  const ManageEnglishContentManagementAudioModel({
    this.phoneme,
    this.duration,
    this.size,
    this.url,
    this.dialog,
    this.message,
    this.audioKey,
  });

  factory ManageEnglishContentManagementAudioModel.fromJson(
      Map<String, dynamic> json) {
    // 规范化 URL：去除可能的反引号与首尾空格
    final String? normalizedUrl = (json['url'] == null)
        ? null
        : json['url'].toString().replaceAll('`', '').trim();

    // 兼容 number 与字符串解析
    double? parseDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    return ManageEnglishContentManagementAudioModel(
      phoneme: json['phoneme']?.toString(),
      duration: parseDouble(json['duration']),
      size: parseInt(json['size']),
      url: normalizedUrl,
      dialog: json['dialog']?.toString(),
      message: json['message']?.toString(),
      audioKey: json['audio_key']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phoneme': phoneme,
      'duration': duration,
      'size': size,
      'url': url,
      'dialog': dialog,
      'message': message,
      'audio_key': audioKey,
    };
  }
}
