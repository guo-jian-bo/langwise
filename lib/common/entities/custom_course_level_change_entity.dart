class CustomCourseLevelChangeEntity {
  final int? uid;
  final String? name;
  final int? tier;
  final int? grade;
  final String? description;
  final String? language;
  final List<int>? moduleIds;
  final num? order;
  final String? access;

  CustomCourseLevelChangeEntity({
    this.uid,
    this.name,
    this.tier,
    this.grade,
    this.description,
    this.language,
    this.moduleIds,
    this.order,
    this.access,
  });

  factory CustomCourseLevelChangeEntity.fromJson(Map<String, dynamic> json) {
    final dynamic moduleIdsRaw = json['moduleIds'];
    List<int>? moduleIds;
    if (moduleIdsRaw is List) {
      moduleIds = moduleIdsRaw
          .map((e) => e is num ? e.toInt() : int.tryParse(e?.toString() ?? ''))
          .whereType<int>()
          .toList();
    }

    return CustomCourseLevelChangeEntity(
      uid: json['uid'] is num ? (json['uid'] as num).toInt() : int.tryParse(json['uid']?.toString() ?? ''),
      name: json['name']?.toString(),
      tier: json['tier'] is num ? (json['tier'] as num).toInt() : int.tryParse(json['tier']?.toString() ?? ''),
      grade: json['grade'] is num ? (json['grade'] as num).toInt() : int.tryParse(json['grade']?.toString() ?? ''),
      description: json['description']?.toString(),
      language: json['language']?.toString(),
      moduleIds: moduleIds,
      order: json['order'] is num ? (json['order'] as num) : num.tryParse(json['order']?.toString() ?? ''),
      access: json['access']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'uid': uid,
      'name': name,
      'tier': tier,
      'grade': grade,
      'description': description,
      'language': language,
      'moduleIds': moduleIds,
      'order': order,
      'access': access,
    };
  }
}
