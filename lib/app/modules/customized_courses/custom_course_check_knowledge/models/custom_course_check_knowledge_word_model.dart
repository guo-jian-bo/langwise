class CustomCourseCheckKnowledgeWordModel {
  final int? uid;
  final int? moduleId;
  final int? unitId;
  final String? contentType;
  final int? contentId;
  final String? content;
  final String? definition;
  final int? difficulty;
  final double? order;
  final int? semanticId;
  final String? coverUrl;
  final String? audioUrl;

  CustomCourseCheckKnowledgeWordModel({
    this.uid,
    this.moduleId,
    this.unitId,
    this.contentType,
    this.contentId,
    this.content,
    this.definition,
    this.difficulty,
    this.order,
    this.semanticId,
    this.coverUrl,
    this.audioUrl,
  });

  factory CustomCourseCheckKnowledgeWordModel.fromJson(Map<String, dynamic> json) => CustomCourseCheckKnowledgeWordModel(
    uid: json["uid"],
    moduleId: json["moduleId"],
    unitId: json["unitId"],
    contentType: json["contentType"],
    contentId: json["contentId"],
    content: json["content"],
    definition: json["definition"],
    difficulty: json["difficulty"],
    order: json["order"],
    semanticId: json["semanticId"],
    coverUrl: json["coverUrl"],
    audioUrl: json["audioUrl"],
  );

  Map<String, dynamic> toJson() => {
    "uid": uid,
    "moduleId": moduleId,
    "unitId": unitId,
    "contentType": contentType,
    "contentId": contentId,
    "content": content,
    "definition": definition,
    "difficulty": difficulty,
    "order": order,
    "semanticId": semanticId,
    "coverUrl": coverUrl,
    "audioUrl": audioUrl,
  };
}
