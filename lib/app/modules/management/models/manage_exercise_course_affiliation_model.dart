import 'dart:math';

import 'package:langwise/common/widgets/data_table_widget/data_sources.dart';

class ManageExerciseCourseAffiliationModel extends Dessert {
  String? courseName;
  int? courseId;
  String? courseLevelName;
  int? courseLevelId;
  String? courseModuleName;
  String? courseModuleId;
  String? courseUnitName;
  String? courseUnitId;
  String? courseLessonName;
  String? courseLessonId;
  int? exerciseId;
  String? access;

  /// 是否上架
  bool get accessNormal => access == "NORMAL";

  ManageExerciseCourseAffiliationModel({
    required int uid,
    this.courseName,
    this.courseId,
    this.courseLevelName,
    this.courseLevelId,
    this.courseModuleName,
    this.courseModuleId,
    this.courseUnitName,
    this.courseUnitId,
    this.courseLessonName,
    this.courseLessonId,
    this.exerciseId,
    this.access,
  }) : super(uid: uid);

  ManageExerciseCourseAffiliationModel.fromJson(Map<String, dynamic> json) : super(uid: json['uid']?.toInt() ?? Random().nextInt(100000)) {
    courseName = json['courseName']?.toString();
    courseId = json['courseId']?.toInt();
    courseLevelName = json['courseLevelName']?.toString();
    courseLevelId = json['courseLevelId']?.toInt();
    courseModuleName = json['courseModuleName']?.toString();
    courseModuleId = json['courseModuleId']?.toString();
    courseUnitName = json['courseUnitName']?.toString();
    courseUnitId = json['courseUnitId']?.toString();
    courseLessonName = json['courseLessonName']?.toString();
    courseLessonId = json['courseLessonId']?.toString();
    exerciseId = json['exerciseId']?.toInt();
    access = json['access']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'courseName': courseName,
      'courseId': courseId,
      'courseLevelName': courseLevelName,
      'courseLevelId': courseLevelId,
      'courseModuleName': courseModuleName,
      'courseModuleId': courseModuleId,
      'courseUnitName': courseUnitName,
      'courseUnitId': courseUnitId,
      'courseLessonName': courseLessonName,
      'courseLessonId': courseLessonId,
      'exerciseId': exerciseId,
      'access': access,
    };
  }
}
