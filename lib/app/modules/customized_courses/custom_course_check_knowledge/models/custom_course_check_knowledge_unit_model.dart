import 'custom_course_check_knowledge_word_model.dart';

class CustomCourseCheckKnowledgeUnitModel {
  final int? uid;
  final String? name;
  final String? language;
  final String? description;
  final List<CustomCourseCheckKnowledgeWordModel> knowledgeList;

  CustomCourseCheckKnowledgeUnitModel({
    this.uid,
    this.name,
    this.language,
    this.description,
    required this.knowledgeList,
  });

  factory CustomCourseCheckKnowledgeUnitModel.fromJson(Map<String, dynamic> json) => CustomCourseCheckKnowledgeUnitModel(
    uid: json["uid"],
    name: json["name"],
    language: json["language"],
    description: json["description"],
    knowledgeList: json["knowledgeList"] == null ? [] : List<CustomCourseCheckKnowledgeWordModel>.from(json["knowledgeList"].map((x) => CustomCourseCheckKnowledgeWordModel.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "uid": uid,
    "name": name,
    "language": language,
    "description": description,
    "knowledgeList": List<dynamic>.from(knowledgeList.map((x) => x.toJson())),
  };
}
