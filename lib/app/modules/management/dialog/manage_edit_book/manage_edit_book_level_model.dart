import 'dart:convert';

class ManageEditBookLevelModel {
  final String? id;
  final int? v;
  final String? scope;
  final String? vendor;
  final String? vendorId;
  final int? uid;
  final String? name;
  final String? description;
  final String? language;
  final String? gradeInfo;
  final List<int>? moduleIds;
  final String? access;
  final int? unitNormalCnt;
  final int? unitTotal;
  final String? difficulty;
  final double? order;
  final DateTime? updated;
  final DateTime? created;

  ManageEditBookLevelModel({
    this.id,
    this.v,
    this.scope,
    this.vendor,
    this.vendorId,
    this.uid,
    this.name,
    this.description,
    this.language,
    this.gradeInfo,
    this.moduleIds,
    this.access,
    this.unitNormalCnt,
    this.unitTotal,
    this.difficulty,
    this.order,
    this.updated,
    this.created,
  });

  factory ManageEditBookLevelModel.fromJson(Map<String, dynamic> json) {
    return ManageEditBookLevelModel(
      id: json['id'] as String?,
      v: json['v'] as int?,
      scope: json['scope'] as String?,
      vendor: json['vendor'] as String?,
      vendorId: json['vendorId'] as String?,
      uid: json['uid'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      language: json['language'] as String?,
      gradeInfo: json['gradeInfo'] as String?,
      moduleIds: (json['moduleIds'] as List?)?.map((e) => e as int).toList(),
      access: json['access'] as String?,
      unitNormalCnt: json['unitNormalCnt'] as int?,
      unitTotal: json['unitTotal'] as int?,
      difficulty: json['difficulty'] as String?,
      order: (json['order'] as num?)?.toDouble(),
      updated:
          json['updated'] != null ? DateTime.tryParse(json['updated']) : null,
      created:
          json['created'] != null ? DateTime.tryParse(json['created']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'v': v,
      'scope': scope,
      'vendor': vendor,
      'vendorId': vendorId,
      'uid': uid,
      'name': name,
      'description': description,
      'language': language,
      'gradeInfo': gradeInfo,
      'moduleIds': moduleIds,
      'access': access,
      'unitNormalCnt': unitNormalCnt,
      'unitTotal': unitTotal,
      'difficulty': difficulty,
      'order': order,
      'updated': updated?.toIso8601String(),
      'created': created?.toIso8601String(),
    };
  }

  @override
  String toString() => jsonEncode(toJson());
}
