// ignore_for_file: constant_identifier_names

import 'dart:ui';

class SpecialtyEnum {
  static const String EN_OFFICIAL = 'EN_OFFICIAL';
  static const String EN_PHONICS = 'EN_PHONICS';
  static const String EN_TEXTBOOK = 'EN_TEXTBOOK';



  static SpecialtyColor getCourseColor(String specialty){
    if(specialty == SpecialtyEnum.EN_OFFICIAL){
      return SpecialtyColor(Color(0xff0EA5E9), Color(0xff0284C7)); // 官方课程颜色
    } else if(specialty == SpecialtyEnum.EN_TEXTBOOK){
      return SpecialtyColor(Color(0xffF59E0B), Color(0xffD97706)); // 教材拓展课颜色
    } else if(specialty == SpecialtyEnum.EN_PHONICS){
      return SpecialtyColor(Color(0xffA855F7), Color(0xff9333EA)); // 发音专项课颜色
    }
    return SpecialtyColor(Color(0xff0EA5E9), Color(0xff0284C7)); // 默认颜色
  }

  /// 获取课程名称
  static String? getCourseName(String specialty){
    if(specialty == SpecialtyEnum.EN_OFFICIAL){
      return "官方主课程";
    } else if(specialty == SpecialtyEnum.EN_TEXTBOOK){
      return "教材拓展课";
    } else if(specialty == SpecialtyEnum.EN_PHONICS){
      return "发音专项课";
    }
    return null;
  }  

}

class SpecialtyColor{
  Color color1;
  Color color2;
  SpecialtyColor(this.color1, this.color2);
}