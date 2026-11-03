class CustomizedCoursesDifficultyInfoEntity {
  final List<CustomizedCoursesDifficultyInfo>? list;

  CustomizedCoursesDifficultyInfoEntity({this.list});

  factory CustomizedCoursesDifficultyInfoEntity.fromJson(
      Map<String, dynamic> json) {
    return CustomizedCoursesDifficultyInfoEntity(
      list: (json['list'] as List<dynamic>?)
          ?.map((e) => CustomizedCoursesDifficultyInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'list': list,
    };
  }
}

class CustomizedCoursesDifficultyInfo {
  final int? uid;
  final int? grade;
  final String? gradeTitle;
  final int? difficulty;
  final String? cefrTitle;
  final String? cambridge;
  final String? langWiseTitle;

  CustomizedCoursesDifficultyInfo({
    this.uid,
    this.grade,
    this.gradeTitle,
    this.difficulty,
    this.cefrTitle,
    this.cambridge,
    this.langWiseTitle,
  });

  factory CustomizedCoursesDifficultyInfo.fromJson(
      Map<String, dynamic> json) {
    return CustomizedCoursesDifficultyInfo(
      uid: json['uid'] as int?,
      grade: json['grade'] as int?,
      gradeTitle: json['gradeTitle'] as String?,
      difficulty: json['difficulty'] as int?,
      cefrTitle: json['cefrTitle'] as String?,
      cambridge: json['cambridge'] as String?,
      langWiseTitle: json['langWiseTitle'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'grade': grade,
      'gradeTitle': gradeTitle,
      'difficulty': difficulty,
      'cefrTitle': cefrTitle,
      'cambridge': cambridge,
      'langWiseTitle': langWiseTitle,
    };
  }
}
