class ExerciseLearnScoreConfigEntity {
  List<ExerciseLearnScoreConfigTestType>? testTypes;
  List<ExerciseLearnScoreConfigScore>? scoreConfigs;

  ExerciseLearnScoreConfigEntity({
    this.testTypes,
    this.scoreConfigs,
  });

  factory ExerciseLearnScoreConfigEntity.fromJson(Map<String, dynamic> json) {
    return ExerciseLearnScoreConfigEntity(
      testTypes: (json['testTypes'] as List?)
          ?.whereType<Map<String, dynamic>>()
          .map(ExerciseLearnScoreConfigTestType.fromJson)
          .toList(),
      scoreConfigs: (json['scoreConfigs'] as List?)
          ?.whereType<Map<String, dynamic>>()
          .map(ExerciseLearnScoreConfigScore.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'testTypes': testTypes?.map((e) => e.toJson()).toList(),
      'scoreConfigs': scoreConfigs?.map((e) => e.toJson()).toList(),
    };
  }
}

class ExerciseLearnScoreConfigTestType {
  String? code;
  String? title;

  ExerciseLearnScoreConfigTestType({
    this.code,
    this.title,
  });

  factory ExerciseLearnScoreConfigTestType.fromJson(Map<String, dynamic> json) {
    return ExerciseLearnScoreConfigTestType(
      code: json['code']?.toString(),
      title: json['title']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'title': title,
    };
  }
}

class ExerciseLearnScoreConfigScore {
  String? code;
  String? title;

  ExerciseLearnScoreConfigScore({
    this.code,
    this.title,
  });

  factory ExerciseLearnScoreConfigScore.fromJson(Map<String, dynamic> json) {
    return ExerciseLearnScoreConfigScore(
      code: json['code']?.toString(),
      title: json['title']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'title': title,
    };
  }
}
