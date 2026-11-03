class ManageExerciseFilterModel {
  List<ManageExerciseFilterQuizTypeData>? exerciseTypeList;
  List<String>? cefrLevels;

  ManageExerciseFilterModel({
    this.exerciseTypeList,
    this.cefrLevels,
  });

  factory ManageExerciseFilterModel.fromJson(Map<String, dynamic> json) {
    return ManageExerciseFilterModel(
      exerciseTypeList: json['exerciseTypeList'] != null ? (json['exerciseTypeList'] as List).map((e) => ManageExerciseFilterQuizTypeData.fromJson(e)).toList() : null,
      cefrLevels: json['cefrLevels'] != null ? List<String>.from(json['cefrLevels']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseTypeList': exerciseTypeList?.map((e) => e.toJson()).toList(),
      'cefrLevels': cefrLevels,
    };
  }
}

class ManageExerciseFilterQuizTypeData {
  String? type;
  String? typeName;

  ManageExerciseFilterQuizTypeData({
    this.type,
    this.typeName,
  });

  factory ManageExerciseFilterQuizTypeData.fromJson(Map<String, dynamic> json) => ManageExerciseFilterQuizTypeData(
        type: json['type']?.toString(),
        typeName: json['typeName']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        'typeName': typeName,
      };
}
