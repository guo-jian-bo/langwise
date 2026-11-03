import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import 'package:langwise/common/https/zhenxie.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/theme/theme_utils.dart';
import 'package:langwise/utils/utils.dart';

class ZhenxieSyntaxController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  ZhenxieSyntaxController({required this.tagText});

  /// 句法页原始数据，字段和接口保持一一对应。
  final Rxn<ZhenxieSyntaxHomeData> homeData = Rxn<ZhenxieSyntaxHomeData>();
  final ConfigController configController = Get.find<ConfigController>();
  String? autoOpenDoorCode;
  bool hasAutoOpenedDoor = false;

  @override
  String get breadcrumbRoute => Routes.ZHENXIE_SYNTAX;

  @override
  String get breadcrumbTitle => "句法";

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    if (Get.arguments != null) {
      autoOpenDoorCode = Get.arguments["autoOpenDoorCode"]?.toString();
    }
    initData();
  }

  /// 初始化句法页数据。
  Future<void> initData() async {
    ToastUtils.showLoading();
    try {
      final Map<String, dynamic>? data = await ZhenxieRequest.getSyntaxHomeData(
        parameters: {},
      );
      if (data == null) {
        homeData.value = null;
        return;
      }
      homeData.value = ZhenxieSyntaxHomeData.fromJson(data);
    } finally {
      ToastUtils.hideLoading();
    }
    _tryAutoOpenDoor();
  }

  /// 获取当前可展示的分组列表。
  List<ZhenxieSyntaxHomeDisplayGroup> buildDisplayGroupList() {
    final ZhenxieSyntaxHomeData? data = homeData.value;
    if (data == null) return const <ZhenxieSyntaxHomeDisplayGroup>[];
    final List<ZhenxieSyntaxHomeDisplayGroup> result = <ZhenxieSyntaxHomeDisplayGroup>[];
    for (final _ZhenxieSyntaxDisplayConfig config in _displayConfigList) {
      final ZhenxieSyntaxHomeGroup? sourceGroup = _findGroupByTitle(config.title);
      final List<ZhenxieSyntaxHomeDoorItem> items = config.codes.map(findDoorByCode).whereType<ZhenxieSyntaxHomeDoorItem>().toList();
      if ((sourceGroup?.title ?? "").isEmpty && (sourceGroup?.description ?? "").isEmpty && items.isEmpty) continue;
      result.add(
        ZhenxieSyntaxHomeDisplayGroup(
          title: sourceGroup?.title,
          description: sourceGroup?.description,
          items: items,
        ),
      );
    }
    return result;
  }

  ZhenxieSyntaxHomeDoorItem? findDoorByCode(String code) {
    final List<ZhenxieSyntaxHomeGroup> groups = homeData.value?.groups ?? const <ZhenxieSyntaxHomeGroup>[];
    for (final ZhenxieSyntaxHomeGroup group in groups) {
      for (final ZhenxieSyntaxHomeDoorItem item in group.items) {
        if (item.code == code) return item;
      }
    }
    return null;
  }

  ZhenxieSyntaxHomeGroup? _findGroupByTitle(String title) {
    final List<ZhenxieSyntaxHomeGroup> groups = homeData.value?.groups ?? const <ZhenxieSyntaxHomeGroup>[];
    for (final ZhenxieSyntaxHomeGroup group in groups) {
      if (group.title == title) return group;
    }
    return null;
  }

  Future<void> onTapDoor(String code) async {
    switch (code) {
      case "sentencePattern":
        await TagRoutes.toNamed(
          Routes.ZHENXIE_PATTERN_BLUEPRINT,
          arguments: {"isManagement": false},
        );
        return;
      case "pyramidPattern":
        await TagRoutes.toNamed(
          Routes.ZHENXIE_PATTERN_BLUEPRINT,
          arguments: {
            "isManagement": false,
            "supportsPyramid": true,
          },
        );
        return;
      case "sentenceParadigm":
        await TagRoutes.toNamed(
          Routes.ZHENXIE_SENTENCE_PATTERN_COMPARE,
          arguments: {"isManagement": false},
        );
        return;
      case "sentenceGrammarGrid":
        await TagRoutes.toNamed(
          Routes.ZHENXIE_GRAMMAR_PANORAMA,
          arguments: {"isManagement": false},
        );
        return;
      case "sentenceLinking":
        await TagRoutes.toNamed(
          Routes.ZHENXIE_SENTENCE_PAIR,
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

class ZhenxieSyntaxHomeData {
  final String? title;
  final String? subTitle;
  final String code;
  final String? description;
  final List<ZhenxieSyntaxHomeGroup> groups;

  const ZhenxieSyntaxHomeData({
    this.title,
    this.subTitle,
    this.code = "",
    this.description,
    this.groups = const <ZhenxieSyntaxHomeGroup>[],
  });

  factory ZhenxieSyntaxHomeData.fromJson(Map<String, dynamic> json) {
    return ZhenxieSyntaxHomeData(
      title: json['title']?.toString(),
      subTitle: json['subTitle']?.toString(),
      code: json['code']?.toString() ?? "",
      description: json['description']?.toString(),
      groups: (json['groups'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((item) => ZhenxieSyntaxHomeGroup.fromJson(item))
          .toList(),
    );
  }
}

class ZhenxieSyntaxHomeGroup {
  final String? title;
  final String? description;
  final List<ZhenxieSyntaxHomeDoorItem> items;

  const ZhenxieSyntaxHomeGroup({
    this.title,
    this.description,
    this.items = const <ZhenxieSyntaxHomeDoorItem>[],
  });

  factory ZhenxieSyntaxHomeGroup.fromJson(Map<String, dynamic> json) {
    return ZhenxieSyntaxHomeGroup(
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      items: (json['items'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((item) => ZhenxieSyntaxHomeDoorItem.fromJson(item))
          .toList(),
    );
  }
}

class ZhenxieSyntaxHomeDisplayGroup {
  final String? title;
  final String? description;
  final List<ZhenxieSyntaxHomeDoorItem> items;

  const ZhenxieSyntaxHomeDisplayGroup({
    this.title,
    this.description,
    this.items = const <ZhenxieSyntaxHomeDoorItem>[],
  });
}

class ZhenxieSyntaxHomeDoorItem {
  final String code;
  final String? title;
  final String? description;
  final List<ZhenxieSyntaxHomeCountItem> items;
  final List<ZhenxieSyntaxHomeSlotCombinationItem> slotCombinationItems;

  const ZhenxieSyntaxHomeDoorItem({
    this.code = "",
    this.title,
    this.description,
    this.items = const <ZhenxieSyntaxHomeCountItem>[],
    this.slotCombinationItems = const <ZhenxieSyntaxHomeSlotCombinationItem>[],
  });

  factory ZhenxieSyntaxHomeDoorItem.fromJson(Map<String, dynamic> json) {
    return ZhenxieSyntaxHomeDoorItem(
      code: json['code']?.toString() ?? "",
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      items: (json['items'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((item) => ZhenxieSyntaxHomeCountItem.fromJson(item))
          .toList(),
      slotCombinationItems: (json['slotCombinationItems'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((item) => ZhenxieSyntaxHomeSlotCombinationItem.fromJson(item))
          .toList(),
    );
  }
}

class ZhenxieSyntaxHomeCountItem {
  final String name;
  final int? count;

  const ZhenxieSyntaxHomeCountItem({
    this.name = "",
    this.count,
  });

  factory ZhenxieSyntaxHomeCountItem.fromJson(Map<String, dynamic> json) {
    return ZhenxieSyntaxHomeCountItem(
      name: json['name']?.toString() ?? "",
      count: json['count'] is num ? (json['count'] as num).toInt() : null,
    );
  }
}

class ZhenxieSyntaxHomeSlotCombinationItem {
  final String? slotTitle;
  final List<ZhenxieSyntaxHomeSlotItem> slots;

  const ZhenxieSyntaxHomeSlotCombinationItem({
    this.slotTitle,
    this.slots = const <ZhenxieSyntaxHomeSlotItem>[],
  });

  factory ZhenxieSyntaxHomeSlotCombinationItem.fromJson(Map<String, dynamic> json) {
    return ZhenxieSyntaxHomeSlotCombinationItem(
      slotTitle: json['slotTitle']?.toString(),
      slots: (json['slots'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((item) => ZhenxieSyntaxHomeSlotItem.fromJson(item))
          .toList(),
    );
  }
}

class ZhenxieSyntaxHomeSlotItem {
  final String? name;
  final String content;
  final bool highlight;
  final ZhenxieSyntaxHomeSlotStyle style;
  final List<ZhenxieSyntaxHomeSlotStyle> styles;

  ZhenxieSyntaxHomeSlotStyle get currentThemeStyle {
    for (final ZhenxieSyntaxHomeSlotStyle item in styles) {
      if (ThemeUtils.isCurrentTheme(item.theme ?? "")) {
        return item;
      }
    }
    return style;
  }

  const ZhenxieSyntaxHomeSlotItem({
    this.name,
    this.content = "",
    this.highlight = false,
    this.style = const ZhenxieSyntaxHomeSlotStyle(),
    this.styles = const <ZhenxieSyntaxHomeSlotStyle>[],
  });

  factory ZhenxieSyntaxHomeSlotItem.fromJson(Map<String, dynamic> json) {
    return ZhenxieSyntaxHomeSlotItem(
      name: json['name']?.toString(),
      content: json['content']?.toString() ?? "",
      highlight: json['highlight'] == true,
      style: json['style'] is Map<String, dynamic>
          ? ZhenxieSyntaxHomeSlotStyle.fromJson(json['style'] as Map<String, dynamic>)
          : const ZhenxieSyntaxHomeSlotStyle(),
      styles: (json['styles'] as List<dynamic>? ?? <dynamic>[]).whereType<Map<String, dynamic>>().map((item) => ZhenxieSyntaxHomeSlotStyle.fromJson(item)).toList(),
    );
  }
}

class ZhenxieSyntaxHomeSlotStyle {
  final String? theme;
  final String? color;
  final String? backgroundColor;
  final String? borderColor;

  const ZhenxieSyntaxHomeSlotStyle({
    this.theme,
    this.color,
    this.backgroundColor,
    this.borderColor,
  });

  factory ZhenxieSyntaxHomeSlotStyle.fromJson(Map<String, dynamic> json) {
    return ZhenxieSyntaxHomeSlotStyle(
      theme: json['theme']?.toString(),
      color: json['color']?.toString(),
      backgroundColor: json['backgroundColor']?.toString(),
      borderColor: json['borderColor']?.toString(),
    );
  }
}

class _ZhenxieSyntaxDisplayConfig {
  final String title;
  final List<String> codes;

  const _ZhenxieSyntaxDisplayConfig({
    required this.title,
    required this.codes,
  });
}

const List<_ZhenxieSyntaxDisplayConfig> _displayConfigList = [
  _ZhenxieSyntaxDisplayConfig(
    title: "立",
    codes: <String>[
      "sentencePattern",
      "pyramidPattern",
    ],
  ),
  _ZhenxieSyntaxDisplayConfig(
    title: "变",
    codes: <String>[
      "sentenceParadigm",
      "sentenceGrammarGrid",
    ],
  ),
  _ZhenxieSyntaxDisplayConfig(
    title: "接",
    codes: <String>[
      "sentenceLinking",
    ],
  ),
];
