enum CourseAffiliationEnum{
  inCourse("inCourse", "在课程"),
  notInCourse("notInCourse", "不在课程");

  final String value;
  final String name;
  const CourseAffiliationEnum(this.value, this.name);
}