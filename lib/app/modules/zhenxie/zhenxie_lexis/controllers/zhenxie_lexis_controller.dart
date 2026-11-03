import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import 'package:langwise/common/https/zhenxie.dart';
import 'package:langwise/theme/theme_utils.dart';
import 'package:langwise/utils/utils.dart';

class ZhenxieLexisController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  ZhenxieLexisController({required this.tagText});

  /// 词法页原始数据，字段和接口保持一一对应。
  final Rxn<ZhenxieLexisHomeData> homeData = Rxn<ZhenxieLexisHomeData>();
  String? autoOpenDoorCode;
  bool hasAutoOpenedDoor = false;

  @override
  String get breadcrumbRoute => Routes.ZHENXIE_LEXIS;

  @override
  String get breadcrumbTitle => "词法";

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    if (Get.arguments != null) {
      autoOpenDoorCode = Get.arguments["autoOpenDoorCode"]?.toString();
    }
    initData();
  }

  /// 初始化词法页数据。
  Future<void> initData() async {
    ToastUtils.showLoading();
    try {
      final Map<String, dynamic>? data = await ZhenxieRequest.getLexisHomeData();
      if (data == null) {
        homeData.value = null;
        return;
      }
      homeData.value = ZhenxieLexisHomeData.fromJson(data);
    } finally {
      ToastUtils.hideLoading();
    }
    _tryAutoOpenDoor();
  }

  /// 获取当前可展示的分组列表。
  List<ZhenxieLexisHomeGroup> buildGroupList() {
    return homeData.value?.groups ?? const <ZhenxieLexisHomeGroup>[];
  }

  Future<void> onTapDoor(String code) async {
    switch (code) {
      case "wordMorphology":
        await TagRoutes.toNamed(
          Routes.MANAGE_WORD_MORPHOLOGY,
          arguments: {"isManagement": false},
        );
        return;
      case "etymology":
        await TagRoutes.toNamed(
          Routes.ZHENXIE_ETYMOLOGY_FOREST,
          arguments: {"isManagement": false},
        );
        return;
      case "phraseParadigm":
        await TagRoutes.toNamed(
          Routes.ZHENXIE_PHRASE_CONTRAST,
          arguments: {"isManagement": false},
        );
        return;
      case "phrasePair":
        await TagRoutes.toNamed(
          Routes.ZHENXIE_PHRASE_PAIR,
          arguments: {"isManagement": false},
        );
        return;
      case "phraseCluster":
        await TagRoutes.toNamed(
          Routes.ZHENXIE_PHRASE_MATCH,
          arguments: {"isManagement": false},
        );
        return;
      case "phraseStructure":
        await TagRoutes.toNamed(
          Routes.ZHENXIE_PHRASE_STRUCTURE,
          arguments: {"isManagement": false},
        );
        return;
      case "phraseGrammaticalProfile":
        await TagRoutes.toNamed(
          Routes.ZHENXIE_ENTER_SENTENCE,
          arguments: {"isManagement": false},
        );
        return;
      default:
        ToastUtils.showToast(text: "建设中");
        return;
    }
  }

  void _tryAutoOpenDoor() {
    if (hasAutoOpenedDoor) return;
    if (autoOpenDoorCode == null || autoOpenDoorCode!.isEmpty) return;
    hasAutoOpenedDoor = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onTapDoor(autoOpenDoorCode!);
    });
  }
}

class ZhenxieLexisHomeData {
  final String? title;
  final String? subTitle;
  final String code;
  final String? description;
  final String? tip;
  final List<ZhenxieLexisHomeGroup> groups;

  const ZhenxieLexisHomeData({
    this.title,
    this.subTitle,
    this.code = "",
    this.description,
    this.tip,
    this.groups = const <ZhenxieLexisHomeGroup>[],
  });

  factory ZhenxieLexisHomeData.fromJson(Map<String, dynamic> json) {
    return ZhenxieLexisHomeData(
      title: json['title']?.toString(),
      subTitle: json['subTitle']?.toString(),
      code: json['code']?.toString() ?? "",
      description: json['description']?.toString(),
      tip: json['tip']?.toString(),
      groups: (json['groups'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((item) => ZhenxieLexisHomeGroup.fromJson(item))
          .toList(),
    );
  }
}

class ZhenxieLexisHomeGroup {
  final String? title;
  final String? description;
  final List<ZhenxieLexisHomeDoorItem> items;

  const ZhenxieLexisHomeGroup({
    this.title,
    this.description,
    this.items = const <ZhenxieLexisHomeDoorItem>[],
  });

  factory ZhenxieLexisHomeGroup.fromJson(Map<String, dynamic> json) {
    return ZhenxieLexisHomeGroup(
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      items: (json['items'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((item) => ZhenxieLexisHomeDoorItem.fromJson(item))
          .toList(),
    );
  }
}

class ZhenxieLexisHomeDoorItem {
  final String code;
  final String? title;
  final String? description;
  final List<ZhenxieLexisHomeCountItem> items;
  final List<ZhenxieLexisHomeSlotCombinationItem> slotCombinationItems;

  const ZhenxieLexisHomeDoorItem({
    this.code = "",
    this.title,
    this.description,
    this.items = const <ZhenxieLexisHomeCountItem>[],
    this.slotCombinationItems = const <ZhenxieLexisHomeSlotCombinationItem>[],
  });

  factory ZhenxieLexisHomeDoorItem.fromJson(Map<String, dynamic> json) {
    return ZhenxieLexisHomeDoorItem(
      code: json['code']?.toString() ?? "",
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      items: (json['items'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((item) => ZhenxieLexisHomeCountItem.fromJson(item))
          .toList(),
      slotCombinationItems: (json['slotCombinationItems'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((item) => ZhenxieLexisHomeSlotCombinationItem.fromJson(item))
          .toList(),
    );
  }
}

class ZhenxieLexisHomeCountItem {
  final String name;
  final int? count;

  const ZhenxieLexisHomeCountItem({
    this.name = "",
    this.count,
  });

  factory ZhenxieLexisHomeCountItem.fromJson(Map<String, dynamic> json) {
    return ZhenxieLexisHomeCountItem(
      name: json['name']?.toString() ?? "",
      count: json['count'] is num ? (json['count'] as num).toInt() : null,
    );
  }
}

class ZhenxieLexisHomeSlotCombinationItem {
  final String? slotTitle;
  final List<ZhenxieLexisHomeSlotItem> slots;

  const ZhenxieLexisHomeSlotCombinationItem({
    this.slotTitle,
    this.slots = const <ZhenxieLexisHomeSlotItem>[],
  });

  factory ZhenxieLexisHomeSlotCombinationItem.fromJson(Map<String, dynamic> json) {
    return ZhenxieLexisHomeSlotCombinationItem(
      slotTitle: json['slotTitle']?.toString(),
      slots: (json['slots'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((item) => ZhenxieLexisHomeSlotItem.fromJson(item))
          .toList(),
    );
  }
}

class ZhenxieLexisHomeSlotItem {
  final String? name;
  final String content;
  final String? tip;
  final bool highlight;
  final ZhenxieLexisHomeSlotStyle style;
  final List<ZhenxieLexisHomeSlotStyle> styles;

  ZhenxieLexisHomeSlotStyle get currentThemeStyle {
    for (final ZhenxieLexisHomeSlotStyle item in styles) {
      if (ThemeUtils.isCurrentTheme(item.theme ?? "")) {
        return item;
      }
    }
    return style;
  }

  const ZhenxieLexisHomeSlotItem({
    this.name,
    this.content = "",
    this.tip,
    this.highlight = false,
    this.style = const ZhenxieLexisHomeSlotStyle(),
    this.styles = const <ZhenxieLexisHomeSlotStyle>[],
  });

  factory ZhenxieLexisHomeSlotItem.fromJson(Map<String, dynamic> json) {
    return ZhenxieLexisHomeSlotItem(
      name: json['name']?.toString(),
      content: json['content']?.toString() ?? "",
      tip: json['tip']?.toString(),
      highlight: json['highlight'] == true,
      style: json['style'] is Map<String, dynamic>
          ? ZhenxieLexisHomeSlotStyle.fromJson(json['style'] as Map<String, dynamic>)
          : const ZhenxieLexisHomeSlotStyle(),
      styles: (json['styles'] as List<dynamic>? ?? <dynamic>[]).whereType<Map<String, dynamic>>().map((item) => ZhenxieLexisHomeSlotStyle.fromJson(item)).toList(),
    );
  }
}

class ZhenxieLexisHomeSlotStyle {
  final String? theme;
  final String? color;
  final String? backgroundColor;
  final String? borderColor;

  const ZhenxieLexisHomeSlotStyle({
    this.theme,
    this.color,
    this.backgroundColor,
    this.borderColor,
  });

  factory ZhenxieLexisHomeSlotStyle.fromJson(Map<String, dynamic> json) {
    return ZhenxieLexisHomeSlotStyle(
      theme: json['theme']?.toString(),
      color: json['color']?.toString(),
      backgroundColor: json['backgroundColor']?.toString(),
      borderColor: json['borderColor']?.toString(),
    );
  }
}
