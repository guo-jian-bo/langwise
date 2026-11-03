import 'dart:math';

import 'package:langwise/common/widgets/data_table_widget/data_sources.dart';

class ManageEnglishWordCourseUsageModel extends Dessert {
  String? courseName;
  int? courseId;
  String? courseLevelName;
  int? courseLevelId;
  String? courseModuleName;
  String? courseModuleId;
  String? courseUnitName;
  String? courseUnitId;

  ManageEnglishWordCourseUsageModel({
    required int uid,
    this.courseName,
    this.courseId,
    this.courseLevelName,
    this.courseLevelId,
    this.courseModuleName,
    this.courseModuleId,
    this.courseUnitName,
    this.courseUnitId,
  }) : super(uid: uid);

  ManageEnglishWordCourseUsageModel.fromJson(Map<String, dynamic> json)
      : super(uid: json['uid']?.toInt() ?? Random().nextInt(100000)) {
    courseName = json['courseName']?.toString();
    courseId = json['courseId']?.toInt();
    courseLevelName = json['courseLevelName']?.toString();
    courseLevelId = json['courseLevelId']?.toInt();
    courseModuleName = json['courseModuleName']?.toString();
    courseModuleId = json['courseModuleId']?.toString();
    courseUnitName = json['courseUnitName']?.toString();
    courseUnitId = json['courseUnitId']?.toString();
  }
}
