class CustomCourseAddGradeModelEntity {
  int? uid;
  String? name;
  String? description;
  List<CustomCourseAddGradeModel>? levels;

  CustomCourseAddGradeModelEntity({
    this.uid,
    this.name,
    this.description,
    this.levels,
  });

  factory CustomCourseAddGradeModelEntity.fromJson(Map<String, dynamic> json) =>
      CustomCourseAddGradeModelEntity(
        uid: json["uid"]?.toInt(),
        name: json["name"],
        description: json["description"],
        levels: json["levels"] == null
            ? []
            : List<CustomCourseAddGradeModel>.from(json["levels"]?.map(
                (x) => CustomCourseAddGradeModel.fromJson(x),
              )),
      );

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "name": name,
        "description": description,
        "levels": levels == null
            ? []
            : List<dynamic>.from(levels!.map((x) => x.toJson())),
      };
}

class CustomCourseAddGradeModel {
  int? uid;
  String? name;
  String? description;
  String? language;

  CustomCourseAddGradeModel({
    this.uid,
    this.name,
    this.description,
    this.language,
  });

  factory CustomCourseAddGradeModel.fromJson(Map<String, dynamic> json) =>
      CustomCourseAddGradeModel(
        uid: json["uid"]?.toInt(),
        name: json["name"],
        description: json["description"],
        language: json["language"],
      );

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "name": name,
        "description": description,
        "language": language,
      };
}
