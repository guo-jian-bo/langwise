import 'dart:developer';
import 'package:langwise/common/static/static_data.dart';
import 'package:langwise/common/values/values.dart';
import 'package:langwise/generated/assets.dart';
import 'package:url_launcher/url_launcher.dart';

class CommonUtil {
  static bool isSuccess(int code) {
    return code == 200;
  }

  static String get langwise => 'langwise';

  static String get us => 'US';

  static String get uk => 'UK';

  /// 跳转到 App Store
  static void launchAppStore(String appId) async {
    if (await canLaunchUrl(Uri.parse('https://apps.apple.com/app/id$appId'))) {
      await launchUrl(Uri.parse("https://apps.apple.com/app/id$appId"));
    } else {
      log('Could not launch App Store');
    }
  }

  static List<LanguageEntity> languages() {
    return [
      const LanguageEntity(flag: Assets.customCourseFlag, title: '中文（粤语）'),
      const LanguageEntity(flag: Assets.customCourseFlag, title: '英语'),
      const LanguageEntity(flag: Assets.customCourseFlag, title: '日语'),
      const LanguageEntity(flag: Assets.customCourseFlag, title: '韩语'),
      const LanguageEntity(flag: Assets.customCourseFlag, title: '法语'),
      const LanguageEntity(flag: Assets.customCourseFlag, title: '西班牙语'),
      const LanguageEntity(flag: Assets.customCourseFlag, title: '意大利语'),
      const LanguageEntity(flag: Assets.customCourseFlag, title: '俄语'),
    ];
  }

  // 语言
  static List<Map<String, String>> get language =>
      StaticData.languageList.map((element) => {element.value: element.name}).toList();

  // 学科
  static List<Map<String, String>> subjects = <Map<String, String>>[
    {'ENGLISH': "英语"},
    {'MATHS': "数学"},
    {'CHINESE': "语文"}
  ];

  // 年级
  static List<String> grades = ["一年级", "二年级", "三年级", "四年级", "五年级", "六年级", "七年级", "八年级", "九年级", "高一", "高二", "高三"];

  // 学期
  static List<String> schoolTerms = ["一", "二"];

  // cefr
  static List<int> cefr = <int>[0, 1, 2, 3, 4, 5, 6];

  static List<String> get languageKeys {
    final List<String> allKeys = [];
    for (var subject in CommonUtil.language) {
      subject.forEach((key, value) {
        allKeys.add(key);
      });
    }
    return allKeys;
  }

  static List<String> get languageValues {
    final List<String> allValues = [];
    for (var subject in CommonUtil.language) {
      subject.forEach((key, value) {
        allValues.add(value);
      });
    }
    return allValues;
  }

  static List<String> get subjectValues {
    final List<String> allValues = [];
    for (var subject in CommonUtil.subjects) {
      subject.forEach((key, value) {
        allValues.add(value);
      });
    }
    return allValues;
  }

  static List<String> get subjectKeys {
    final List<String> allKeys = [];
    for (var subject in CommonUtil.subjects) {
      subject.forEach((key, value) {
        allKeys.add(key);
      });
    }
    return allKeys;
  }

  static const List<KnowledgeSelectEntity> knowledgeOptions = <KnowledgeSelectEntity>[
    KnowledgeSelectEntity(
      isKnowledge: false,
      title: "否",
    ),
    KnowledgeSelectEntity(
      isKnowledge: true,
      title: "是",
    ),
  ];

  // 口音
  static List<Map<String, String>> get nationalIpa => [
        {us: "英音"},
        {uk: "美音"},
      ];

  static List<String> get nationalIpaKeys {
    final List<String> allKeys = [];
    for (var subject in CommonUtil.nationalIpa) {
      subject.forEach((key, value) {
        allKeys.add(key);
      });
    }
    return allKeys;
  }

  static List<String> get nationalIpaValues {
    final List<String> allValues = [];
    for (var subject in CommonUtil.nationalIpa) {
      subject.forEach((key, value) {
        allValues.add(value);
      });
    }
    return allValues;
  }

  // 类型
  static List<Map<String, String>> get semanticType => [
        {"cultural": "文化"},
        {"variant": "变种"},
      ];

  static List<String> get semanticTypeKeys {
    final List<String> allKeys = [];
    for (var subject in CommonUtil.semanticType) {
      subject.forEach((key, value) {
        allKeys.add(key);
      });
    }
    return allKeys;
  }

  static List<String> get semanticTypeValues {
    final List<String> allValues = [];
    for (var subject in CommonUtil.semanticType) {
      subject.forEach((key, value) {
        allValues.add(value);
      });
    }
    return allValues;
  }

  /// Checks if string is an image file.
  static bool isImage(String filePath) {
    final ext = filePath.toLowerCase();
    return ext.endsWith(".heif") ||
        ext.endsWith(".heic") ||
        ext.endsWith(".webp") ||
        ext.endsWith(".jpg") ||
        ext.endsWith(".jpeg") ||
        ext.endsWith(".png") ||
        ext.endsWith(".gif") ||
        ext.endsWith(".bmp");
  }
}

class KnowledgeSelectEntity {
  final bool isKnowledge;
  final String title;

  const KnowledgeSelectEntity({this.isKnowledge = false, required this.title});
}
