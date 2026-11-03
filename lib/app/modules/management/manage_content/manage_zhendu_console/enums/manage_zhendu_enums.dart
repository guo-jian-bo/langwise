// ignore_for_file: constant_identifier_names

import '../../../../../../common/widgets/widgets.dart';

/// 人声音色分类枚举。
enum ManageZhenduVocalTimbreCategoryEnum {
  general('general'),
  special('special'),
  narrator('narrator');

  const ManageZhenduVocalTimbreCategoryEnum(this.value);

  /// 后端存储值。
  final String value;

  /// 通过存储值反查枚举。
  static ManageZhenduVocalTimbreCategoryEnum? fromValue(String? value) {
    if (value == null) return null;
    for (final item in ManageZhenduVocalTimbreCategoryEnum.values) {
      if (item.value == value) {
        return item;
      }
    }
    return null;
  }
}

/// 性别枚举。
enum ManageZhenduGenderEnum {
  male('male'),
  female('female'),
  unknown('unknown');

  const ManageZhenduGenderEnum(this.value);

  /// 后端存储值。
  final String value;

  /// 通过存储值反查枚举。
  static ManageZhenduGenderEnum? fromValue(String? value) {
    if (value == null) return null;
    for (final item in ManageZhenduGenderEnum.values) {
      if (item.value == value) {
        return item;
      }
    }
    return null;
  }
}

/// 年龄段枚举。
enum ManageZhenduAgeGroupEnum {
  child('child'),
  teen('teen'),
  youngAdult('young_adult'),
  middleAged('middle_aged'),
  elderly('elderly'),
  ageless('ageless');

  const ManageZhenduAgeGroupEnum(this.value);

  /// 后端存储值。
  final String value;

  /// 通过存储值反查枚举。
  static ManageZhenduAgeGroupEnum? fromValue(String? value) {
    if (value == null) return null;
    for (final item in ManageZhenduAgeGroupEnum.values) {
      if (item.value == value) {
        return item;
      }
    }
    return null;
  }
}

/// 人声音色说话风格枚举。
enum ManageZhenduVocalTimbreMannerEnum {
  formal('formal'),
  neutral('neutral'),
  wild('wild');

  const ManageZhenduVocalTimbreMannerEnum(this.value);

  /// 后端存储值。
  final String value;

  /// 通过存储值反查枚举。
  static ManageZhenduVocalTimbreMannerEnum? fromValue(String? value) {
    if (value == null) return null;
    for (final item in ManageZhenduVocalTimbreMannerEnum.values) {
      if (item.value == value) {
        return item;
      }
    }
    return null;
  }
}

/// 人声音色道德倾向枚举。
enum ManageZhenduVocalTimbreMoralityEnum {
  light('light'),
  neutral('neutral'),
  dark('dark');

  const ManageZhenduVocalTimbreMoralityEnum(this.value);

  /// 后端存储值。
  final String value;

  /// 通过存储值反查枚举。
  static ManageZhenduVocalTimbreMoralityEnum? fromValue(String? value) {
    if (value == null) return null;
    for (final item in ManageZhenduVocalTimbreMoralityEnum.values) {
      if (item.value == value) {
        return item;
      }
    }
    return null;
  }
}

/// 人声音色背景阶层枚举。
enum ManageZhenduVocalTimbreBackgroundEnum {
  elite('elite'),
  standard('standard'),
  common('common'),
  outcast('outcast');

  const ManageZhenduVocalTimbreBackgroundEnum(this.value);

  /// 后端存储值。
  final String value;

  /// 通过存储值反查枚举。
  static ManageZhenduVocalTimbreBackgroundEnum? fromValue(String? value) {
    if (value == null) return null;
    for (final item in ManageZhenduVocalTimbreBackgroundEnum.values) {
      if (item.value == value) {
        return item;
      }
    }
    return null;
  }
}

/// 角色作用域枚举。
enum ManageZhenduPersonaScopeEnum {
  global('GLOBAL'),
  series('SERIES'),
  book('BOOK'),
  content('CONTENT');

  const ManageZhenduPersonaScopeEnum(this.value);

  /// 后端存储值。
  final String value;

  /// 通过存储值反查枚举。
  static ManageZhenduPersonaScopeEnum? fromValue(String? value) {
    if (value == null) return null;
    for (final item in ManageZhenduPersonaScopeEnum.values) {
      if (item.value == value) {
        return item;
      }
    }
    return null;
  }
}

/// 人声音色方言枚举。
enum ManageZhenduDialectEnum{
  enUS("en-US"),
  enGB("en-GB"),
  zhCN("zh-CN");

  const ManageZhenduDialectEnum(this.value);

  /// 后端存储值。
  final String value;

  /// 通过存储值反查枚举。
  static ManageZhenduDialectEnum? fromValue(String? value) {
    if (value == null) return null;
    for (final item in ManageZhenduDialectEnum.values) {
      if (item.value == value) {
        return item;
      }
    }
    return null;
  }
}


enum ManageZhenduPersonaViewEnum{
  front_full_body('front_full_body', '正面全身'),
  front_half_body('front_half_body', '正面半身'),
  side_full_body('side_full_body', '侧面全身'),
  front_headshot('front_headshot', '正面大头贴'),
  back_full_body('back_full_body', '背面全身');

  const ManageZhenduPersonaViewEnum(this.value, this.name);

  /// 后端存储值。
  final String value;
  final String name;

  /// 通过存储值反查枚举。
  static ManageZhenduPersonaViewEnum? fromValue(String? value) {
    if (value == null) return null;
    for (final item in ManageZhenduPersonaViewEnum.values) {
      if (item.value == value) {
        return item;
      }
    }
    return null;
  }
}

enum ManageZhenduAudioFilterEnum{
  /// 不加滤镜
  none('none', "不加滤镜"),
  /// 座机电话
  phone('phone', "座机电话"),
  /// 老式收音机
  old_radio('old_radio', "老式收音机"),
  /// 洞穴回声
  echo('echo', "洞穴回声"),
  /// 风中说话
  wind('wind', "风中说话");


  const ManageZhenduAudioFilterEnum(this.value, this.name);

  /// 后端存储值。
  final String value;
  final String name;

  /// 通过存储值反查枚举。
  static ManageZhenduAudioFilterEnum fromValue(String? value) {
    if (value == null) return none;
    for (final item in ManageZhenduAudioFilterEnum.values) {
      if (item.value == value) {
        return item;
      }
    }
    return none;
  }
}


/// 知读控制台通用枚举集合。
class ManageZhenduDropdownEnums {
  /// 人声音色分类枚举集合。
  static List<IconDropdownCheckData<ManageZhenduVocalTimbreCategoryEnum>> categorys = [
    IconDropdownCheckData<ManageZhenduVocalTimbreCategoryEnum>(
      value: ManageZhenduVocalTimbreCategoryEnum.general,
      title: ManageZhenduVocalTimbreCategoryEnum.general.value,
    ),
    IconDropdownCheckData<ManageZhenduVocalTimbreCategoryEnum>(
      value: ManageZhenduVocalTimbreCategoryEnum.special,
      title: ManageZhenduVocalTimbreCategoryEnum.special.value,
    ),
    IconDropdownCheckData<ManageZhenduVocalTimbreCategoryEnum>(
      value: ManageZhenduVocalTimbreCategoryEnum.narrator,
      title: ManageZhenduVocalTimbreCategoryEnum.narrator.value,
    ),
  ];

  /// 性别枚举集合。
  static List<IconDropdownCheckData<ManageZhenduGenderEnum>> genders = [
    IconDropdownCheckData<ManageZhenduGenderEnum>(
      value: ManageZhenduGenderEnum.male,
      title: ManageZhenduGenderEnum.male.value,
    ),
    IconDropdownCheckData<ManageZhenduGenderEnum>(
      value: ManageZhenduGenderEnum.female,
      title: ManageZhenduGenderEnum.female.value,
    ),
    IconDropdownCheckData<ManageZhenduGenderEnum>(
      value: ManageZhenduGenderEnum.unknown,
      title: ManageZhenduGenderEnum.unknown.value,
    ),
  ];

  /// 年龄段枚举集合。
  static List<IconDropdownCheckData<ManageZhenduAgeGroupEnum>> ageGroups = [
    IconDropdownCheckData<ManageZhenduAgeGroupEnum>(
      value: ManageZhenduAgeGroupEnum.child,
      title: ManageZhenduAgeGroupEnum.child.value,
    ),
    IconDropdownCheckData<ManageZhenduAgeGroupEnum>(
      value: ManageZhenduAgeGroupEnum.teen,
      title: ManageZhenduAgeGroupEnum.teen.value,
    ),
    IconDropdownCheckData<ManageZhenduAgeGroupEnum>(
      value: ManageZhenduAgeGroupEnum.youngAdult,
      title: ManageZhenduAgeGroupEnum.youngAdult.value,
    ),
    IconDropdownCheckData<ManageZhenduAgeGroupEnum>(
      value: ManageZhenduAgeGroupEnum.middleAged,
      title: ManageZhenduAgeGroupEnum.middleAged.value,
    ),
    IconDropdownCheckData<ManageZhenduAgeGroupEnum>(
      value: ManageZhenduAgeGroupEnum.elderly,
      title: ManageZhenduAgeGroupEnum.elderly.value,
    ),
    IconDropdownCheckData<ManageZhenduAgeGroupEnum>(
      value: ManageZhenduAgeGroupEnum.ageless,
      title: ManageZhenduAgeGroupEnum.ageless.value,
    ),
  ];

  /// 说话风格枚举集合。
  static List<IconDropdownCheckData<ManageZhenduVocalTimbreMannerEnum>> manners = [
    IconDropdownCheckData<ManageZhenduVocalTimbreMannerEnum>(
      value: ManageZhenduVocalTimbreMannerEnum.formal,
      title: ManageZhenduVocalTimbreMannerEnum.formal.value,
    ),
    IconDropdownCheckData<ManageZhenduVocalTimbreMannerEnum>(
      value: ManageZhenduVocalTimbreMannerEnum.neutral,
      title: ManageZhenduVocalTimbreMannerEnum.neutral.value,
    ),
    IconDropdownCheckData<ManageZhenduVocalTimbreMannerEnum>(
      value: ManageZhenduVocalTimbreMannerEnum.wild,
      title: ManageZhenduVocalTimbreMannerEnum.wild.value,
    ),
  ];

  /// 道德倾向枚举集合。
  static List<IconDropdownCheckData<ManageZhenduVocalTimbreMoralityEnum>> moralities = [
    IconDropdownCheckData<ManageZhenduVocalTimbreMoralityEnum>(
      value: ManageZhenduVocalTimbreMoralityEnum.light,
      title: ManageZhenduVocalTimbreMoralityEnum.light.value,
    ),
    IconDropdownCheckData<ManageZhenduVocalTimbreMoralityEnum>(
      value: ManageZhenduVocalTimbreMoralityEnum.neutral,
      title: ManageZhenduVocalTimbreMoralityEnum.neutral.value,
    ),
    IconDropdownCheckData<ManageZhenduVocalTimbreMoralityEnum>(
      value: ManageZhenduVocalTimbreMoralityEnum.dark,
      title: ManageZhenduVocalTimbreMoralityEnum.dark.value,
    ),
  ];

  /// 背景阶层枚举集合。
  static List<IconDropdownCheckData<ManageZhenduVocalTimbreBackgroundEnum>> backgrounds = [
    IconDropdownCheckData<ManageZhenduVocalTimbreBackgroundEnum>(
      value: ManageZhenduVocalTimbreBackgroundEnum.elite,
      title: ManageZhenduVocalTimbreBackgroundEnum.elite.value,
    ),
    IconDropdownCheckData<ManageZhenduVocalTimbreBackgroundEnum>(
      value: ManageZhenduVocalTimbreBackgroundEnum.standard,
      title: ManageZhenduVocalTimbreBackgroundEnum.standard.value,
    ),
    IconDropdownCheckData<ManageZhenduVocalTimbreBackgroundEnum>(
      value: ManageZhenduVocalTimbreBackgroundEnum.common,
      title: ManageZhenduVocalTimbreBackgroundEnum.common.value,
    ),
    IconDropdownCheckData<ManageZhenduVocalTimbreBackgroundEnum>(
      value: ManageZhenduVocalTimbreBackgroundEnum.outcast,
      title: ManageZhenduVocalTimbreBackgroundEnum.outcast.value,
    ),
  ];

  /// 角色作用域枚举集合。
  static List<IconDropdownCheckData<ManageZhenduPersonaScopeEnum>> personaScopes = [
    IconDropdownCheckData<ManageZhenduPersonaScopeEnum>(
      value: ManageZhenduPersonaScopeEnum.global,
      title: ManageZhenduPersonaScopeEnum.global.value,
    ),
    IconDropdownCheckData<ManageZhenduPersonaScopeEnum>(
      value: ManageZhenduPersonaScopeEnum.series,
      title: ManageZhenduPersonaScopeEnum.series.value,
    ),
    IconDropdownCheckData<ManageZhenduPersonaScopeEnum>(
      value: ManageZhenduPersonaScopeEnum.book,
      title: ManageZhenduPersonaScopeEnum.book.value,
    ),
    IconDropdownCheckData<ManageZhenduPersonaScopeEnum>(
      value: ManageZhenduPersonaScopeEnum.content,
      title: ManageZhenduPersonaScopeEnum.content.value,
    ),
  ];

  /// 角色视图类型 ManageZhenduPersonaViewEnum
  static List<IconDropdownCheckData<ManageZhenduPersonaViewEnum>> personaViews = List.generate(ManageZhenduPersonaViewEnum.values.length, (index){
    return IconDropdownCheckData<ManageZhenduPersonaViewEnum>(
      value: ManageZhenduPersonaViewEnum.values[index],
      title: ManageZhenduPersonaViewEnum.values[index].name,
    );
  });

  /// 人声音色方言枚举集合。
  static List<IconDropdownCheckData<ManageZhenduDialectEnum>> dialects = List.generate(ManageZhenduDialectEnum.values.length, (index){
    return IconDropdownCheckData<ManageZhenduDialectEnum>(
      value: ManageZhenduDialectEnum.values[index],
      title: ManageZhenduDialectEnum.values[index].value,
    );
  });

  /// 音频滤镜枚举集合。
  static List<IconDropdownCheckData<ManageZhenduAudioFilterEnum>> audioFilters = List.generate(ManageZhenduAudioFilterEnum.values.length, (index){
    return IconDropdownCheckData<ManageZhenduAudioFilterEnum>(
      value: ManageZhenduAudioFilterEnum.values[index],
      title: ManageZhenduAudioFilterEnum.values[index].name,
    );
  });
}