import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import 'package:langwise/common/values/app_font_value.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/https/zhenxie.dart';
import '../../../../theme/theme.dart';
import '../../../../theme/theme_utils.dart';
import '../../../../utils/utils.dart';

class ZhenxieController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  ZhenxieController({required this.tagText});

  /// 首页原始数据，字段尽量和接口返回保持一一对应。
  final Rxn<ZhenxieHomeData> homeData = Rxn<ZhenxieHomeData>();

  @override
  String get breadcrumbRoute => Routes.ZHENXIE;

  @override
  String get breadcrumbTitle => "甄写";

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    initData();
  }

  /// 初始化首页数据。
  Future<void> initData() async {
    try {
      ToastUtils.showLoading();
      final Map<String, dynamic>? data = await ZhenxieRequest.getHomeData();
      if (data == null) return;
      homeData.value = ZhenxieHomeData.fromJson(data);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 构建首页主标题。
  String buildPageTitleText() {
    final String text = homeData.value?.title ?? "";
    if (text.isEmpty) return "";
    return text.replaceFirst("，", "，\n");
  }

  /// 构建首页副标题描述。
  String buildPageDescriptionText() {
    final ZhenxieHomeData? data = homeData.value;
    if (data == null) return "";
    final String prefix = data.subTitles.where((item) => item.isNotEmpty).join("、");
    if (prefix.isEmpty) return data.description ?? "";
    final String suffix = data.description ?? "";
    if (suffix.isEmpty) return prefix;
    return "$prefix，$suffix";
  }

  /// 顶部统计区。
  List<ZhenxieHomeTopStatData> buildTopStatList() {
    final List<ZhenxieHomeContentItem> list = homeData.value?.contentItems ?? const <ZhenxieHomeContentItem>[];
    return list.where((item) => item.name.isNotEmpty && item.count != null).map((item) {
      return ZhenxieHomeTopStatData(label: item.name, value: item.count!);
    }).toList();
  }

  /// 顶部里程碑轴，优先高亮最后一个 current=true 的组。
  List<ZhenxieHomeMilestoneData> buildMilestoneList() {
    final List<ZhenxieHomeMilestoneGroup> list = homeData.value?.milestones ?? const <ZhenxieHomeMilestoneGroup>[];
    final int currentIndex = list.lastIndexWhere((item) => item.current == true);
    return list.asMap().entries.map((entry) {
      final List<ZhenxieHomeMilestoneItem> items = entry.value.items;
      final ZhenxieHomeMilestoneItem? first = items.isEmpty ? null : items.first;
      final List<String> aliasParts = items.skip(1).map((item) => item.findText(preferLang: "zh")).where((item) => item.isNotEmpty).toList();
      return ZhenxieHomeMilestoneData(
        title: first?.findText(preferLang: "zh") ?? "",
        alias: aliasParts.join(" · "),
        isCurrent: currentIndex >= 0 ? entry.key == currentIndex : entry.key == 0,
      );
    }).where((item) => item.title.isNotEmpty).toList();
  }

  /// 构建左侧主卡片数据。
  ZhenxieHomeLayerCardData? buildLayerCardData({
    required String code,
    required String toastText,
  }) {
    final ZhenxieHomeModuleItem? item = findModuleItem(code);
    if (item == null) return null;
    return ZhenxieHomeLayerCardData(
      code: code,
      title: item.title ?? "",
      subTitle: item.subTitle ?? "",
      description: item.description ?? "",
      toastText: toastText,
      chips: buildChipList(code),
    );
  }

  /// 构建写作课卡片数据：印章沿用 course 模块，卡片内容来自 writeCourseInfo。
  ZhenxieHomeCourseHeaderData? buildCourseHeaderData() {
    final ZhenxieHomeWriteCourseInfo? courseInfo = homeData.value?.writeCourseInfo;
    if (courseInfo == null) return null;
    final ZhenxieHomeModuleItem? item = findModuleItem("course");
    final List<ZhenxieHomeWriteCourseUnit> units = courseInfo.units;
    // 当前单元优先取 current=true 的一项，没有则默认第一个。
    final int currentIndex = units.indexWhere((unit) => unit.current);
    final int activeIndex = currentIndex >= 0 ? currentIndex : (units.isEmpty ? -1 : 0);
    // 只有 current=true 的单元用最深色，其余单元用中间色。
    final List<ZhenxieHomeCourseUnitData> unitList = units.map((unit) {
      return ZhenxieHomeCourseUnitData(
        name: unit.unitName,
        state: unit.current ? ZhenxieHomeCourseUnitState.current : ZhenxieHomeCourseUnitState.normal,
      );
    }).toList();
    // 方块数量不足四个时补最淡的占位块。
    while (unitList.length < 4) {
      unitList.add(const ZhenxieHomeCourseUnitData(name: "", state: ZhenxieHomeCourseUnitState.none));
    }
    return ZhenxieHomeCourseHeaderData(
      title: item?.title ?? "",
      subTitle: item?.subTitle ?? "",
      levelModuleText: <String>[courseInfo.levelName ?? "", courseInfo.moduleName ?? ""].where((text) => text.isNotEmpty).join(" · "),
      unitText: activeIndex < 0 ? "" : "第 ${activeIndex + 1} 单元 · ${units[activeIndex].unitName}",
      progress: courseInfo.moduleProgress,
      units: unitList,
      hasCurrentUnit: currentIndex >= 0,
    );
  }

  /// 打开写作课：跳转课程等级页。
  Future<void> openWriteCourse() async {
    final String? writeCourseMessage = homeData.value?.writeCourseMessage;
    final ZhenxieHomeWriteCourseInfo? courseInfo = homeData.value?.writeCourseInfo;
    if (courseInfo == null) return;
    if (courseInfo.courseId == null) {
      await MqttNotificationToast.showModal(
        messages: [
          PushMessageEntity(
            title: "敬请期待",
            content: writeCourseMessage,
            contentType: "txt",
          ),
        ],
        buttonText: "确定",
        titleTextStyle: TextStyle(
          fontFamily: AppFontValue.sourceHanSerifCN,
          color: AppTheme.cZhenxieFontPrimary.color,
        ),
        contentTextStyle: TextStyle(
          fontFamily: AppFontValue.sourceHanSerifCN,
          color: AppTheme.cZhenxieFontTertiary.color,
        ),
        buttonTextStyle: TextStyle(
          fontFamily: AppFontValue.sourceHanSerifCN,
          color: AppTheme.cZhenxieFontPrimary.color,
          fontWeight: FontWeight.w600,
        ),
      );
      return;
    }

    final Map<String, dynamic> arguments = <String, dynamic>{
      "courseId": courseInfo.courseId,
      "levelId": courseInfo.levelId,
      "moduleId": courseInfo.moduleId,
    };
    // units 里没有 current 时不指定单元，进入页自行定位。
    final int currentIndex = courseInfo.units.indexWhere((unit) => unit.current);
    if (currentIndex >= 0) {
      arguments["unitId"] = courseInfo.units[currentIndex].unitId;
    }
    await TagRoutes.toNamed(Routes.OFFICIAL_COURSE_DETAILS_LEVEL, arguments: arguments);
  }

  /// 构建词法示意区。
  List<ZhenxieHomeLexisSlotRowData> buildLexisSlotRows() {
    final ZhenxieHomeModuleItem? item = findModuleItem("lexis");
    final List<ZhenxieHomeSlotCombinationItem> rows = item?.slotCombinationItems ?? const <ZhenxieHomeSlotCombinationItem>[];
    return rows.map((row) {
      final String tip = row.slots.map((slot) => slot.tip ?? "").firstWhere((item) => item.isNotEmpty, orElse: () => "");
      return ZhenxieHomeLexisSlotRowData(
        tip: tip,
        slots: row.slots.where((slot) => slot.content.isNotEmpty).map((slot) {
          final currentStyle = slot.currentThemeStyle;
          return ZhenxieHomeLexisSlotData(
            content: slot.content,
            borderColor: ColorUtils.parseColor(currentStyle.borderColor),
            backgroundColor: ColorUtils.parseColor(currentStyle.backgroundColor),
            textColor: ColorUtils.parseColor(currentStyle.color),
          );
        }).toList(),
      );
    }).where((row) => row.slots.isNotEmpty).toList();
  }

  /// 构建句法示意区。
  List<ZhenxieHomeSyntaxSlotRowData> buildSyntaxSlotRows() {
    final ZhenxieHomeModuleItem? item = findModuleItem("syntax");
    final List<ZhenxieHomeSlotCombinationItem> rows = item?.slotCombinationItems ?? const <ZhenxieHomeSlotCombinationItem>[];
    return rows.map((row) {
      return ZhenxieHomeSyntaxSlotRowData(
        slots: row.slots.where((slot) => slot.content.isNotEmpty).map((slot) {
          final currentStyle = slot.currentThemeStyle;
          return ZhenxieHomeSyntaxSlotData(
            role: slot.name ?? "",
            content: slot.content,
            color: ColorUtils.parseColor(currentStyle.borderColor),
            dashed: !_hasEnglishLetter(slot.content),
          );
        }).toList(),
      );
    }).where((row) => row.slots.isNotEmpty).toList();
  }

  /// 构建章法示意区颜色数据。
  ZhenxieHomeDiscourseSpecimenData buildDiscourseSpecimenData() {
    final ZhenxieHomeModuleItem? item = findModuleItem("discourse");
    final List<ZhenxieHomeSlotCombinationItem> rows = item?.slotCombinationItems ?? const <ZhenxieHomeSlotCombinationItem>[];
    List<Color?> fourGenreColors = const <Color?>[];
    List<Color?> structureColors = const <Color?>[];
    List<Color?> stageColors = const <Color?>[];
    for (final ZhenxieHomeSlotCombinationItem row in rows) {
      final List<Color?> colors = row.slots.map((slot) => ColorUtils.parseColor(slot.currentThemeStyle.color)).toList();
      switch (row.slotTitle) {
        case "四文类":
          fourGenreColors = colors;
          break;
        case "起承转合":
          structureColors = colors;
          break;
        case "阶梯·大关":
          stageColors = colors;
          break;
      }
    }
    return ZhenxieHomeDiscourseSpecimenData(
      fourGenreColors: fourGenreColors,
      structureColors: structureColors,
      stageColors: stageColors,
    );
  }

  /// 查找首页模块项。
  ZhenxieHomeModuleItem? findModuleItem(String code) {
    final List<ZhenxieHomeModuleItem> list = homeData.value?.items ?? const <ZhenxieHomeModuleItem>[];
    for (final ZhenxieHomeModuleItem item in list) {
      if (item.code == code) return item;
    }
    return null;
  }

  /// 构建模块 chips。
  List<ZhenxieHomeChipData> buildChipList(String code) {
    final ZhenxieHomeModuleItem? item = findModuleItem(code);
    final List<ZhenxieHomeModuleCountItem> list = item?.items ?? const <ZhenxieHomeModuleCountItem>[];
    return list.where((item) => item.name.isNotEmpty).map((item) {
      return ZhenxieHomeChipData(title: item.name, count: item.count);
    }).toList();
  }

  bool _hasEnglishLetter(String text) {
    return RegExp(r'[A-Za-z]').hasMatch(text);
  }

}

class ZhenxieHomeTopStatData {
  final String label;
  final int value;

  const ZhenxieHomeTopStatData({
    required this.label,
    required this.value,
  });
}

class ZhenxieHomeMilestoneData {
  final String title;
  final String alias;
  final bool isCurrent;

  const ZhenxieHomeMilestoneData({
    required this.title,
    required this.alias,
    required this.isCurrent,
  });
}

class ZhenxieHomeChipData {
  final String title;
  final int? count;

  const ZhenxieHomeChipData({
    required this.title,
    required this.count,
  });
}

class ZhenxieHomeLayerCardData {
  final String code;
  final String title;
  final String subTitle;
  final String description;
  final String toastText;
  final List<ZhenxieHomeChipData> chips;

  const ZhenxieHomeLayerCardData({
    required this.code,
    required this.title,
    required this.subTitle,
    required this.description,
    required this.toastText,
    required this.chips,
  });
}

class ZhenxieHomeCourseHeaderData {
  final String title;
  final String subTitle;
  final String levelModuleText;
  final String unitText;
  final double progress;
  final List<ZhenxieHomeCourseUnitData> units;
  final bool hasCurrentUnit;

  const ZhenxieHomeCourseHeaderData({
    required this.title,
    required this.subTitle,
    required this.levelModuleText,
    required this.unitText,
    required this.progress,
    required this.units,
    required this.hasCurrentUnit,
  });
}

/// 写作课单元方块状态：none=最淡（占位），normal=中间（在单元列表内），current=最深（当前单元）。
enum ZhenxieHomeCourseUnitState { none, normal, current }

class ZhenxieHomeCourseUnitData {
  final String name;
  final ZhenxieHomeCourseUnitState state;

  const ZhenxieHomeCourseUnitData({
    required this.name,
    required this.state,
  });
}

class ZhenxieHomeLexisSlotRowData {
  final String tip;
  final List<ZhenxieHomeLexisSlotData> slots;

  const ZhenxieHomeLexisSlotRowData({
    required this.tip,
    required this.slots,
  });
}

class ZhenxieHomeLexisSlotData {
  final String content;
  final Color? borderColor;
  final Color? backgroundColor;
  final Color? textColor;

  const ZhenxieHomeLexisSlotData({
    required this.content,
    required this.borderColor,
    required this.backgroundColor,
    required this.textColor,
  });
}

class ZhenxieHomeSyntaxSlotRowData {
  final List<ZhenxieHomeSyntaxSlotData> slots;

  const ZhenxieHomeSyntaxSlotRowData({
    required this.slots,
  });
}

class ZhenxieHomeSyntaxSlotData {
  final String role;
  final String content;
  final Color? color;
  final bool dashed;

  const ZhenxieHomeSyntaxSlotData({
    required this.role,
    required this.content,
    required this.color,
    required this.dashed,
  });
}

class ZhenxieHomeDiscourseSpecimenData {
  final List<Color?> fourGenreColors;
  final List<Color?> structureColors;
  final List<Color?> stageColors;

  const ZhenxieHomeDiscourseSpecimenData({
    required this.fourGenreColors,
    required this.structureColors,
    required this.stageColors,
  });
}

class ZhenxieHomeData {
  final String? title;
  final List<String> subTitles;
  final String? description;
  final List<ZhenxieHomeMilestoneGroup> milestones;
  final List<ZhenxieHomeModuleItem> items;
  final List<ZhenxieHomeContentItem> contentItems;
  final ZhenxieHomeWriteCourseInfo? writeCourseInfo;
  final String? writeCourseMessage;

  const ZhenxieHomeData({
    this.title,
    this.subTitles = const <String>[],
    this.description,
    this.milestones = const <ZhenxieHomeMilestoneGroup>[],
    this.items = const <ZhenxieHomeModuleItem>[],
    this.contentItems = const <ZhenxieHomeContentItem>[],
    this.writeCourseInfo,
    this.writeCourseMessage,
  });

  factory ZhenxieHomeData.fromJson(Map<String, dynamic> json) {
    return ZhenxieHomeData(
      title: json['title']?.toString(),
      subTitles: (json['subTitles'] as List<dynamic>? ?? <dynamic>[]).map((item) => item.toString()).toList(),
      description: json['description']?.toString(),
      milestones: (json['milestones'] as List<dynamic>? ?? <dynamic>[]).whereType<Map<String, dynamic>>().map((item) => ZhenxieHomeMilestoneGroup.fromJson(item)).toList(),
      items: (json['items'] as List<dynamic>? ?? <dynamic>[]).whereType<Map<String, dynamic>>().map((item) => ZhenxieHomeModuleItem.fromJson(item)).toList(),
      contentItems: (json['contentItems'] as List<dynamic>? ?? <dynamic>[]).whereType<Map<String, dynamic>>().map((item) => ZhenxieHomeContentItem.fromJson(item)).toList(),
      writeCourseInfo: json['writeCourseInfo'] is Map<String, dynamic> ? ZhenxieHomeWriteCourseInfo.fromJson(json['writeCourseInfo'] as Map<String, dynamic>) : null,
        writeCourseMessage: json['writeCourseMessage']?.toString(),
    );
  }
}

/// 写作课进度信息，字段与接口 writeCourseInfo 一一对应。
class ZhenxieHomeWriteCourseInfo {
  final int? courseId;
  final String? courseName;
  final int? levelId;
  final String? levelName;
  final int? moduleId;
  final String? moduleName;
  final double moduleProgress;
  final List<ZhenxieHomeWriteCourseUnit> units;

  const ZhenxieHomeWriteCourseInfo({
    this.courseId,
    this.courseName,
    this.levelId,
    this.levelName,
    this.moduleId,
    this.moduleName,
    this.moduleProgress = 0,
    this.units = const <ZhenxieHomeWriteCourseUnit>[],
  });

  factory ZhenxieHomeWriteCourseInfo.fromJson(Map<String, dynamic> json) {
    return ZhenxieHomeWriteCourseInfo(
      courseId: json['courseId'] is num ? (json['courseId'] as num).toInt() : null,
      courseName: json['courseName']?.toString(),
      levelId: json['levelId'] is num ? (json['levelId'] as num).toInt() : null,
      levelName: json['levelName']?.toString(),
      moduleId: json['moduleId'] is num ? (json['moduleId'] as num).toInt() : null,
      moduleName: json['moduleName']?.toString(),
      moduleProgress: json['moduleProgress'] is num ? (json['moduleProgress'] as num).toDouble() : 0,
      units: (json['units'] as List<dynamic>? ?? <dynamic>[]).whereType<Map<String, dynamic>>().map((item) => ZhenxieHomeWriteCourseUnit.fromJson(item)).toList(),
    );
  }
}

class ZhenxieHomeWriteCourseUnit {
  final int? unitId;
  final String unitName;
  final double progress;
  final bool current;

  const ZhenxieHomeWriteCourseUnit({
    this.unitId,
    this.unitName = "",
    this.progress = 0,
    this.current = false,
  });

  factory ZhenxieHomeWriteCourseUnit.fromJson(Map<String, dynamic> json) {
    return ZhenxieHomeWriteCourseUnit(
      unitId: json['unitId'] is num ? (json['unitId'] as num).toInt() : null,
      unitName: json['unitName']?.toString() ?? "",
      progress: json['progress'] is num ? (json['progress'] as num).toDouble() : 0,
      current: json['current'] == true,
    );
  }
}

class ZhenxieHomeMilestoneGroup {
  final List<ZhenxieHomeMilestoneItem> items;
  final int? difficulty;
  final bool current;

  const ZhenxieHomeMilestoneGroup({
    this.items = const <ZhenxieHomeMilestoneItem>[],
    this.difficulty,
    this.current = false,
  });

  factory ZhenxieHomeMilestoneGroup.fromJson(Map<String, dynamic> json) {
    return ZhenxieHomeMilestoneGroup(
      items: (json['items'] as List<dynamic>? ?? <dynamic>[]).whereType<Map<String, dynamic>>().map((item) => ZhenxieHomeMilestoneItem.fromJson(item)).toList(),
      difficulty: json['difficulty'] is num ? (json['difficulty'] as num).toInt() : null,
      current: json['current'] == true,
    );
  }
}

class ZhenxieHomeMilestoneItem {
  final List<ZhenxieHomeMilestoneName> name;
  final String? nid;
  final String? kind;
  final int? order;

  const ZhenxieHomeMilestoneItem({
    this.name = const <ZhenxieHomeMilestoneName>[],
    this.nid,
    this.kind,
    this.order,
  });

  factory ZhenxieHomeMilestoneItem.fromJson(Map<String, dynamic> json) {
    return ZhenxieHomeMilestoneItem(
      name: (json['name'] as List<dynamic>? ?? <dynamic>[]).whereType<Map<String, dynamic>>().map((item) => ZhenxieHomeMilestoneName.fromJson(item)).toList(),
      nid: json['nid']?.toString(),
      kind: json['kind']?.toString(),
      order: json['order'] is num ? (json['order'] as num).toInt() : null,
    );
  }

  String findText({String? preferLang}) {
    if (preferLang != null) {
      for (final ZhenxieHomeMilestoneName item in name) {
        if (item.lang == preferLang && item.text.isNotEmpty) return item.text;
      }
    }
    for (final ZhenxieHomeMilestoneName item in name) {
      if (item.text.isNotEmpty) return item.text;
    }
    return "";
  }
}

class ZhenxieHomeMilestoneName {
  final String? lang;
  final String text;

  const ZhenxieHomeMilestoneName({
    this.lang,
    this.text = "",
  });

  factory ZhenxieHomeMilestoneName.fromJson(Map<String, dynamic> json) {
    return ZhenxieHomeMilestoneName(
      lang: json['lang']?.toString(),
      text: json['text']?.toString() ?? "",
    );
  }
}

class ZhenxieHomeModuleItem {
  final String code;
  final String? title;
  final String? subTitle;
  final String? description;
  final List<ZhenxieHomeModuleCountItem> items;
  final List<ZhenxieHomeSlotCombinationItem> slotCombinationItems;

  const ZhenxieHomeModuleItem({
    this.code = "",
    this.title,
    this.subTitle,
    this.description,
    this.items = const <ZhenxieHomeModuleCountItem>[],
    this.slotCombinationItems = const <ZhenxieHomeSlotCombinationItem>[],
  });

  factory ZhenxieHomeModuleItem.fromJson(Map<String, dynamic> json) {
    return ZhenxieHomeModuleItem(
      code: json['code']?.toString() ?? "",
      title: json['title']?.toString(),
      subTitle: json['subTitle']?.toString(),
      description: json['description']?.toString(),
      items: (json['items'] as List<dynamic>? ?? <dynamic>[]).whereType<Map<String, dynamic>>().map((item) => ZhenxieHomeModuleCountItem.fromJson(item)).toList(),
      slotCombinationItems: (json['slotCombinationItems'] as List<dynamic>? ?? <dynamic>[]).whereType<Map<String, dynamic>>().map((item) => ZhenxieHomeSlotCombinationItem.fromJson(item)).toList(),
    );
  }
}

class ZhenxieHomeModuleCountItem {
  final String name;
  final int? count;

  const ZhenxieHomeModuleCountItem({
    this.name = "",
    this.count,
  });

  factory ZhenxieHomeModuleCountItem.fromJson(Map<String, dynamic> json) {
    return ZhenxieHomeModuleCountItem(
      name: json['name']?.toString() ?? "",
      count: json['count'] is num ? (json['count'] as num).toInt() : null,
    );
  }
}

class ZhenxieHomeSlotCombinationItem {
  final String? slotTitle;
  final List<ZhenxieHomeSlotItem> slots;

  const ZhenxieHomeSlotCombinationItem({
    this.slotTitle,
    this.slots = const <ZhenxieHomeSlotItem>[],
  });

  factory ZhenxieHomeSlotCombinationItem.fromJson(Map<String, dynamic> json) {
    return ZhenxieHomeSlotCombinationItem(
      slotTitle: json['slotTitle']?.toString(),
      slots: (json['slots'] as List<dynamic>? ?? <dynamic>[]).whereType<Map<String, dynamic>>().map((item) => ZhenxieHomeSlotItem.fromJson(item)).toList(),
    );
  }
}

class ZhenxieHomeSlotItem {
  final String? name;
  final String content;
  final String? tip;
  final ZhenxieHomeSlotStyle style;
  final List<ZhenxieHomeSlotStyle> styles;

  ZhenxieHomeSlotStyle get currentThemeStyle {
    for (final ZhenxieHomeSlotStyle item in styles) {
      if (ThemeUtils.isCurrentTheme(item.theme ?? "")) {
        return item;
      }
    }
    return style;
  }

  const ZhenxieHomeSlotItem({
    this.name,
    this.content = "",
    this.tip,
    this.style = const ZhenxieHomeSlotStyle(),
    this.styles = const <ZhenxieHomeSlotStyle>[],
  });

  factory ZhenxieHomeSlotItem.fromJson(Map<String, dynamic> json) {
    return ZhenxieHomeSlotItem(
      name: json['name']?.toString(),
      content: json['content']?.toString() ?? "",
      tip: json['tip']?.toString(),
      style: json['style'] is Map<String, dynamic> ? ZhenxieHomeSlotStyle.fromJson(json['style'] as Map<String, dynamic>) : const ZhenxieHomeSlotStyle(),
      styles: (json['styles'] as List<dynamic>? ?? <dynamic>[]).whereType<Map<String, dynamic>>().map((item) => ZhenxieHomeSlotStyle.fromJson(item)).toList(),
    );
  }
}

class ZhenxieHomeSlotStyle {
  final String? theme;
  final String? color;
  final String? backgroundColor;
  final String? borderColor;

  const ZhenxieHomeSlotStyle({
    this.theme,
    this.color,
    this.backgroundColor,
    this.borderColor,
  });

  factory ZhenxieHomeSlotStyle.fromJson(Map<String, dynamic> json) {
    return ZhenxieHomeSlotStyle(
      theme: json['theme']?.toString(),
      color: json['color']?.toString(),
      backgroundColor: json['backgroundColor']?.toString(),
      borderColor: json['borderColor']?.toString(),
    );
  }
}

class ZhenxieHomeContentItem {
  final String name;
  final int? count;

  const ZhenxieHomeContentItem({
    this.name = "",
    this.count,
  });

  factory ZhenxieHomeContentItem.fromJson(Map<String, dynamic> json) {
    return ZhenxieHomeContentItem(
      name: json['name']?.toString() ?? "",
      count: json['count'] is num ? (json['count'] as num).toInt() : null,
    );
  }
}
