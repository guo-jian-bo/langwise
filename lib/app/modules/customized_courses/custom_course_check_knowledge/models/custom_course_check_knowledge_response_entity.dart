import 'custom_course_check_knowledge_unit_model.dart';

class CustomCourseCheckKnowledgeResponseEntity {
  final int? uid;
  final String? name;
  final String? coverUrl;
  final String? cover;
  final String? description;
  final List<CustomCourseCheckKnowledgeUnitModel> unitList;
  final CustomCourseCheckKnowledgeUnitModel unGrouped;

  CustomCourseCheckKnowledgeResponseEntity({
    this.uid,
    this.name,
    this.coverUrl,
    this.cover,
    this.description,
    required this.unitList,
    required this.unGrouped,
  });

  factory CustomCourseCheckKnowledgeResponseEntity.fromJson(Map<String, dynamic> json) => CustomCourseCheckKnowledgeResponseEntity(
    uid: json["uid"],
    name: json["name"],
    coverUrl: json["coverUrl"],
    cover: json["cover"],
    description: json["description"],
    unitList: List<CustomCourseCheckKnowledgeUnitModel>.from(json["unitList"].map((x) => CustomCourseCheckKnowledgeUnitModel.fromJson(x))),
    unGrouped: CustomCourseCheckKnowledgeUnitModel.fromJson(json["unGrouped"]),
  );

  Map<String, dynamic> toJson() => {
    "uid": uid,
    "name": name,
    "coverUrl": coverUrl,
    "cover": cover,
    "description": description,
    "unitList": List<Map<String, dynamic>>.from(unitList.map((x) => x.toJson())),
    "unGrouped": unGrouped.toJson(),
  };
}