import 'package:get/get.dart';

enum LessonTypeEnum {
  course("course", "课程"),
  supermemo("supermemo", "超记"),
  phonics("phonics", "发音课"),
  test("test", "测试");

  final String value;
  final String name;

  const LessonTypeEnum(this.value, this.name);

  static LessonTypeEnum? fromRawValue(String? value) {
    LessonTypeEnum? res = values.firstWhereOrNull(
      (element) => element.value == value,
    );
    return res;
  }
  
}