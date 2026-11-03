import 'package:flutter/foundation.dart';

import '../enum/enum.dart';
import '../widgets/widgets.dart';

/// 静态的数据
class StaticData {
  static String get english => 'en';

  static String get zh => 'zh';

  /// 黄金学练说明
  static String goldRatioDesc = "根据材料掌握程度灵活调整转换时机；练习难度应随掌握程度逐步提高；整合适当反馈能显著增强效果；将练习分散在更长时间内进行效果更佳。";

  /// 超级记忆说明
  static String superMemoDesc = "根据认知科学学习平台Traverse的研究，SuperMemo算法比艾宾浩斯记忆曲线更强大，合理安排复习时间记忆效率可以提升7倍以上。";

  /// 倍速列表
  static List<double> playSpeedList = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  /// 年级列表
  static List<StaticDataEntity> gradeList = [
    StaticDataEntity(name: "学龄前", value: "0"),
    StaticDataEntity(name: "一年级", value: "1"),
    StaticDataEntity(name: "二年级", value: "2"),
    StaticDataEntity(name: "三年级", value: "3"),
    StaticDataEntity(name: "四年级", value: "4"),
    StaticDataEntity(name: "五年级", value: "5"),
    StaticDataEntity(name: "六年级", value: "6"),
    StaticDataEntity(name: "初一", value: "7"),
    StaticDataEntity(name: "初二", value: "8"),
    StaticDataEntity(name: "初三", value: "9"),
    StaticDataEntity(name: "高一", value: "10"),
    StaticDataEntity(name: "高二", value: "11"),
    StaticDataEntity(name: "高三", value: "12"),
    StaticDataEntity(name: "成人", value: "99"),
  ];

  /// 语言
  static List<StaticDataEntity> languageList = [
    StaticDataEntity(name: "英语", value: english),
    StaticDataEntity(name: "中文", value: zh),
  ];

  /// 学习locale列表
  static List<StaticDataEntity> learnLocaleList = [
    StaticDataEntity(name: "china", value: "china"),
    StaticDataEntity(name: "us_uk", value: "us_uk"),
    StaticDataEntity(name: "japan", value: "japan"),
  ];



  /// 专项课程
  static List<StaticDataEntity> specialtyList = [
    StaticDataEntity(name: "自然拼读课", value: SpecialtyEnum.EN_PHONICS),
  ];

  /// 考核方向
  static List<StaticDataEntity> assessmentDirection = [
    StaticDataEntity(name: "学", value: "LEARN"),
    StaticDataEntity(name: "练", value: "PRACTICE"),
    StaticDataEntity(name: "测", value: "TEST"),
  ];

  /// 上架下架
  static List<StaticDataEntity> onOffShelfList = [
    StaticDataEntity(name: "上架", value: "NORMAL"),
    StaticDataEntity(name: "下架", value: "INTERNAL"),
    StaticDataEntity(name: "删除", value: "DELETED"),
  ];

  /// 课程归属
  static List<StaticDataEntity> courseList = [
    StaticDataEntity(name: "在课程", value: "inCourse"),
    StaticDataEntity(name: "不在课程", value: "notInCourse"),
  ];

  /// 发布状态
  static List<StaticDataEntity> publishStatusList = [
    StaticDataEntity(name: "已发布", value: "PUBLISHED"),
    StaticDataEntity(name: "未发布", value: "UNPUBLISHED"),
  ];

  /// 音色
  static List<StaticDataEntity> timbreList = [
    StaticDataEntity(name: "全部", value: "timbreAll"),
    StaticDataEntity(name: "UK Rosie", value: "timbreUKRosie"),
    StaticDataEntity(name: "US Rosie", value: "timbreUSRosie"),
  ];

  /// 上架下架(新建/编辑)
  static List<StaticDataEntity> onOffShelfForCreateOrEdit = [
    StaticDataEntity(name: "上架", value: "NORMAL"),
    StaticDataEntity(name: "下架", value: "INTERNAL"),
  ];

  /// 升序/降序
  static List<StaticDataEntity> sortList = [
    StaticDataEntity(name: "升序", value: "", svg: "assets/svg/manage/icon_sort_up.svg"),
    StaticDataEntity(name: "降序", value: "-", svg: "assets/svg/manage/icon_sort.svg"),
  ];

  /// 作者
  static List<StaticDataEntity> authors = [
    StaticDataEntity(name: "官方", value: "OFFICIAL"),
    StaticDataEntity(name: "机构", value: "CHANNEL"),
    StaticDataEntity(name: "主播", value: "KOL"),
    StaticDataEntity(name: "个人", value: "USER"),
  ];

  /// 获取分钟数字列表
  static List<IconDropdownCheckData<int>> getMinuteList({int jump = 5, int max = 120}) {
    List<IconDropdownCheckData<int>> list = [];
    for (int i = jump; i <= max; i += jump) {
      list.add(IconDropdownCheckData<int>(title: "$i分钟", value: i));
    }
    return list;
  }

  /// 根据语言代码获取语言名称
  static String? getLanguageName(String? value) {
    if (value == null || value == "") return null;
    for (var item in languageList) {
      if (item.value == value) {
        return item.name;
      }
    }
    return null;
  }

  /// 根据语言代码获取语言列表下标
  static int? getLanguageIndex(String? value) {
    if (value == null || value == "") return null;
    for (var i = 0; i < languageList.length; i++) {
      if (languageList[i].value == value) {
        return i;
      }
    }
    return null;
  }

  /// 根据考核方向获取名称
  static String? getAssessmentDirectionName(String? value) {
    if (value == null || value == "") return null;
    for (var item in assessmentDirection) {
      if (item.value == value) {
        return item.name;
      }
    }
    return null;
  }

  /// 根据考核方向获取列表下标
  static int? getAssessmentDirectionIndex(String? value) {
    if (value == null || value == "") return null;
    for (var i = 0; i < assessmentDirection.length; i++) {
      if (assessmentDirection[i].value == value) {
        return i;
      }
    }
    return null;
  }

  /// 根据作者获取列表下标
  static int? getAuthorIndex(String? value) {
    if (value == null || value == "") return null;
    for (var i = 0; i < authors.length; i++) {
      if (authors[i].value == value) {
        return i;
      }
    }
    return null;
  }

  // 是否命中上架下架
  static bool isOnOffShelfNormal(String? value) {
    if (value == null) return false;
    if (value.trim().isEmpty) return false;
    String _value = "";
    for (var item in onOffShelfList) {
      if (item.value == value.trim()) {
        _value = value.trim();
        break;
      }
    }
    if (_value == 'NORMAL') return true;

    return false;
  }

  /// 根据上架下架获取名称
  static String? getOnOffShelfName(String? value) {
    if (value == null || value == "") return null;
    for (var item in onOffShelfList) {
      if (item.value == value) {
        return item.name;
      }
    }
    return null;
  }

  /// 根据上架下架获取列表下标
  static int? getOnOffShelfIndex(String? value) {
    if (value == null || value == "") return null;
    for (var i = 0; i < onOffShelfList.length; i++) {
      if (onOffShelfList[i].value == value) {
        return i;
      }
    }
    return null;
  }

  /// 根据在不在课程获取列表下标
  static int? getCourseListIndex(String? value) {
    if (value == null || value == "") return null;
    for (var i = 0; i < courseList.length; i++) {
      if (courseList[i].value == value) {
        return i;
      }
    }
    return null;
  }

  /// 根据发布状态获取列表下标
  static int? getPublishStatusIndex(String? value) {
    if (value == null || value == "") return null;
    for (var i = 0; i < publishStatusList.length; i++) {
      if (publishStatusList[i].value == value) {
        return i;
      }
    }
    return null;
  }

  /// 根据音色获取列表下标
  static int? getTimbreIndex(String? value) {
    if (value == null || value == "") return null;
    for (var i = 0; i < timbreList.length; i++) {
      if (timbreList[i].value == value) {
        return i;
      }
    }
    return null;
  }

  /// 根据上架下架获取名称
  static String? getOnOffShelfForCreateOrEditName(String? value) {
    if (value == null || value == "") return null;
    for (var item in onOffShelfForCreateOrEdit) {
      if (item.value == value) {
        return item.name;
      }
    }
    return null;
  }

  /// 根据上架下架获取列表下标
  static int? getOnOffShelfForCreateOrEditIndex(String? value) {
    if (value == null || value == "") return null;
    for (var i = 0; i < onOffShelfForCreateOrEdit.length; i++) {
      if (onOffShelfForCreateOrEdit[i].value == value) {
        return i;
      }
    }
    return null;
  }

  /// 根据上架下架获取列表下标
  static String getOnOffShelfForCreateOrEdit(int index) {
    String title = '';
    try {
      final StaticDataEntity item = onOffShelfForCreateOrEdit[index];
      title = item.name;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return title;
  }

  static List<String> get getOnOffShelfForCreateOrEditNames {
    final List<String> allNames = [];
    for (var item in onOffShelfForCreateOrEdit) {
      allNames.add(item.name);
    }
    return allNames;
  }
}

class StaticDataEntity {
  String name;
  String value;
  String? svg;

  StaticDataEntity({
    required this.name,
    required this.value,
    this.svg,
  });
}
