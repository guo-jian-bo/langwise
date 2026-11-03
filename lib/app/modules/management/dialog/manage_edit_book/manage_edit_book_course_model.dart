import 'dart:convert';

import 'manage_edit_book_level_model.dart';

class ManageEditBookCourseModel {
  final int? uid;
  final String? name;
  final String? cover;
  final String? coverUrl;
  final String? description;
  final String? specialty;
  final List<int>? levelIds;
  final List<ManageEditBookLevelModel>? levelList;
  final String? language;
  final String? scope;
  final String? scopeName;
  final String? vendor;
  final String? vendorName;
  final String? access;
  final String? status;
  final int? unitNormalCnt;
  final int? unitTotal;
  final double? order;
  final DateTime? updated;
  final DateTime? created;

  ManageEditBookCourseModel({
    this.uid,
    this.name,
    this.cover,
    this.coverUrl,
    this.description,
    this.specialty,
    this.levelIds,
    this.levelList,
    this.language,
    this.scope,
    this.scopeName,
    this.vendor,
    this.vendorName,
    this.access,
    this.status,
    this.unitNormalCnt,
    this.unitTotal,
    this.order,
    this.updated,
    this.created,
  });

  factory ManageEditBookCourseModel.fromJson(Map<String, dynamic> json) {
    return ManageEditBookCourseModel(
      uid: json['uid'] as int?,
      name: json['name'] as String?,
      cover: json['cover'] as String?,
      coverUrl: json['coverUrl'] as String?,
      description: json['description'] as String?,
      specialty: json['specialty'] as String?,
      levelIds: (json['levelIds'] as List?)?.map((e) => e as int).toList(),
      levelList: (json['levelList'] as List?)
          ?.map((e) => ManageEditBookLevelModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      language: json['language'] as String?,
      scope: json['scope'] as String?,
      scopeName: json['scopeName'] as String?,
      vendor: json['vendor'] as String?,
      vendorName: json['vendorName'] as String?,
      access: json['access'] as String?,
      status: json['status'] as String?,
      unitNormalCnt: json['unitNormalCnt'] as int?,
      unitTotal: json['unitTotal'] as int?,
      order: (json['order'] as num?)?.toDouble(),
      updated: json['updated'] != null ? DateTime.tryParse(json['updated']) : null,
      created: json['created'] != null ? DateTime.tryParse(json['created']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'cover': cover,
      'coverUrl': coverUrl,
      'description': description,
      'specialty': specialty,
      'levelIds': levelIds,
      'levelList': levelList?.map((e) => e.toJson()).toList(),
      'language': language,
      'scope': scope,
      'scopeName': scopeName,
      'vendor': vendor,
      'vendorName': vendorName,
      'access': access,
      'status': status,
      'unitNormalCnt': unitNormalCnt,
      'unitTotal': unitTotal,
      'order': order,
      'updated': updated?.toIso8601String(),
      'created': created?.toIso8601String(),
    };
  }

  @override
  String toString() => jsonEncode(toJson());
}
