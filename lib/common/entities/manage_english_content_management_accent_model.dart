class ManageEnglishContentManagementAccentModel {
  String? id;
  int? v;
  int? uid;
  String? name;
  String? national;
  String? sourceType;
  String? provider;
  int? modelId;
  String? timbre;
  String? emotion;
  int? userId;
  String? description;
  String? access;
  DateTime? updated;
  DateTime? created;
  String? gender;

  ManageEnglishContentManagementAccentModel({
    this.id,
    this.v,
    this.uid,
    this.name,
    this.national,
    this.sourceType,
    this.provider,
    this.modelId,
    this.timbre,
    this.emotion,
    this.userId,
    this.description,
    this.access,
    this.updated,
    this.created,
    this.gender,
  });

  factory ManageEnglishContentManagementAccentModel.fromJson(
      Map<String, dynamic> json) {
    return ManageEnglishContentManagementAccentModel(
      id: json['id'] as String?,
      v: json['v'] as int?,
      uid: json['uid'] as int?,
      name: json['name'] as String?,
      national: json['national'] as String?,
      sourceType: json['sourceType'] as String?,
      provider: json['provider'] as String?,
      modelId: json['modelId'] as int?,
      timbre: json['timbre'] as String?,
      emotion: json['emotion'] as String?,
      userId: json['userId'] as int?,
      description: json['description'] as String?,
      access: json['access'] as String?,
      updated: json['updated'] != null ? DateTime.parse(json['updated']) : null,
      created: json['created'] != null ? DateTime.parse(json['created']) : null,
      gender: json['gender'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'v': v,
      'uid': uid,
      'name': name,
      'national': national,
      'sourceType': sourceType,
      'provider': provider,
      'modelId': modelId,
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
