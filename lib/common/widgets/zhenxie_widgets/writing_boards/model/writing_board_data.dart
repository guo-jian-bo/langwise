import 'package:flutter/material.dart';

import '../../../../entities/zhenxie_task_details_entity.dart';

/// 写作板内容来源宏。
class WritingBoardContentSourceMacro {
  /// 内容来源稳定值，用于路由参数、`Get.arguments` 和持久化传递。
  final String value;

  /// 内容来源调试名，仅用于日志排查。
  final String debugName;

  /// 内容来源宏私有构造。
  const WritingBoardContentSourceMacro._({
    required this.value,
    required this.debugName,
  });

  /// 任务作答数据来源。
  static const WritingBoardContentSourceMacro task = WritingBoardContentSourceMacro._(
    value: 'task',
    debugName: 'task',
  );

  /// 范文数据来源。
  static const WritingBoardContentSourceMacro exemplar = WritingBoardContentSourceMacro._(
    value: 'exemplar',
    debugName: 'exemplar',
  );

  /// 当前支持的全部内容来源宏。
  static const List<WritingBoardContentSourceMacro> values = [
    task,
    exemplar,
  ];

  /// 根据稳定值反查对应内容来源宏，默认回退到任务作答态。
  static WritingBoardContentSourceMacro fromValue(String? value) {
    for (final item in values) {
      if (item.value == value) return item;
    }
    return task;
  }
}

/// 写作板编辑策略宏。
class WritingBoardEditPolicyMacro {
  /// 编辑策略稳定值，用于路由参数、`Get.arguments` 和持久化传递。
  final String value;

  /// 编辑策略调试名，仅用于日志排查。
  final String debugName;

  /// 编辑策略宏私有构造。
  const WritingBoardEditPolicyMacro._({
    required this.value,
    required this.debugName,
  });

  /// 按任务 `stage.fill` 规则控制可编辑区域。
  static const WritingBoardEditPolicyMacro stageRule = WritingBoardEditPolicyMacro._(
    value: 'stage_rule',
    debugName: 'stageRule',
  );

  /// 全部只读，不允许输入。
  static const WritingBoardEditPolicyMacro readOnly = WritingBoardEditPolicyMacro._(
    value: 'read_only',
    debugName: 'readOnly',
  );

  /// 强制全部可编辑，用于范文编辑态。
  static const WritingBoardEditPolicyMacro forceEditable = WritingBoardEditPolicyMacro._(
    value: 'force_editable',
    debugName: 'forceEditable',
  );

  /// 当前支持的全部编辑策略宏。
  static const List<WritingBoardEditPolicyMacro> values = [
    stageRule,
    readOnly,
    forceEditable,
  ];

  /// 根据稳定值反查对应编辑策略宏，默认回退到任务作答规则。
  static WritingBoardEditPolicyMacro fromValue(String? value) {
    for (final item in values) {
      if (item.value == value) return item;
    }
    return stageRule;
  }
}

/// 写作板统一渲染数据。
class WritingBoardData {
  /// 当前写作板板式皮肤主键。
  final String? skinNid;

  /// 当前答卷区作答类型。
  final String? answerKind;

  /// 当前写作板展示的数据来源宏。
  final WritingBoardContentSourceMacro contentSource;

  /// 当前写作板可编辑策略宏。
  final WritingBoardEditPolicyMacro editPolicy;

  /// 当前正文是否展示知识点下划线。
  final bool showKnowledgeAnchors;

  /// 当前板式是否展示文首区域。
  final bool showHead;

  /// 当前板式是否展示文尾区域。
  final bool showTail;

  /// 当前文首区域是否允许输入。
  final bool headEditable;

  /// 当前文尾区域是否允许输入。
  final bool tailEditable;

  /// 文首区域标题文案。
  final String? headLabel;

  /// 文尾区域标题文案。
  final String? tailLabel;

  /// 文首区域当前展示内容。
  final String? headText;

  /// 文尾区域当前展示内容。
  final String? tailText;

  /// 当前正文拍位渲染列表。
  final List<WritingBoardStepData> steps;

  /// 当前顶部题干素材列表。
  final List<WritingBoardMaterialData> materials;

  /// 当前任务作答区媒体数据。
  final WritingBoardMediaAnswerData? mediaAnswer;

  /// 当前范文作答区媒体数据。
  final WritingBoardMediaAnswerData? exemplarMediaAnswer;

  const WritingBoardData({
    this.skinNid,
    this.answerKind,
    this.contentSource = WritingBoardContentSourceMacro.task,
    this.editPolicy = WritingBoardEditPolicyMacro.stageRule,
    this.showKnowledgeAnchors = false,
    this.showHead = false,
    this.showTail = false,
    this.headEditable = false,
    this.tailEditable = false,
    this.headLabel,
    this.tailLabel,
    this.headText,
    this.tailText,
    this.steps = const [],
    this.materials = const [],
    this.mediaAnswer,
    this.exemplarMediaAnswer,
  });

  /// 基于当前渲染数据复制一个新实例。
  WritingBoardData copyWith({
    String? skinNid,
    String? answerKind,
    WritingBoardContentSourceMacro? contentSource,
    WritingBoardEditPolicyMacro? editPolicy,
    bool? showKnowledgeAnchors,
    bool? showHead,
    bool? showTail,
    bool? headEditable,
    bool? tailEditable,
    String? headLabel,
    String? tailLabel,
    String? headText,
    String? tailText,
    List<WritingBoardStepData>? steps,
    List<WritingBoardMaterialData>? materials,
    WritingBoardMediaAnswerData? mediaAnswer,
    WritingBoardMediaAnswerData? exemplarMediaAnswer,
  }) {
    return WritingBoardData(
      skinNid: skinNid ?? this.skinNid,
      answerKind: answerKind ?? this.answerKind,
      contentSource: contentSource ?? this.contentSource,
      editPolicy: editPolicy ?? this.editPolicy,
      showKnowledgeAnchors: showKnowledgeAnchors ?? this.showKnowledgeAnchors,
      showHead: showHead ?? this.showHead,
      showTail: showTail ?? this.showTail,
      headEditable: headEditable ?? this.headEditable,
      tailEditable: tailEditable ?? this.tailEditable,
      headLabel: headLabel ?? this.headLabel,
      tailLabel: tailLabel ?? this.tailLabel,
      headText: headText ?? this.headText,
      tailText: tailText ?? this.tailText,
      steps: steps ?? this.steps,
      materials: materials ?? this.materials,
      mediaAnswer: mediaAnswer ?? this.mediaAnswer,
      exemplarMediaAnswer: exemplarMediaAnswer ?? this.exemplarMediaAnswer,
    );
  }
}

/// 单个拍位在写作板上的显示数据。
class WritingBoardStepData {
  /// 当前拍位主键。
  final String beatNid;

  /// 当前拍位显示名称。
  final String beatLabel;

  /// 当前拍位段落类型主键。
  final String? paragraphTypeNid;

  /// 当前拍位段落类型名称。
  final String? paragraphTypeName;

  /// 当前拍位用途名称。
  final String? usageName;

  /// 当前拍位用途说明。
  final String? usageDescription;

  /// 当前拍位填充规则。
  final String fill;

  /// 当前拍位是否为页面选中项。
  final bool selected;

  /// 当前拍位是否允许输入。
  final bool editable;

  /// 当前拍位是否隐藏。
  final bool hidden;

  /// 当前拍位是否允许点击圆章后打开详情弹窗。
  final bool canOpenStepDialog;

  /// 当前拍位输入框是否持有焦点。
  final bool focused;

  /// 当前拍位圆章主色。
  final Color? beatColor;

  /// 当前拍位圆章文字颜色。
  final Color? beatTextColor;

  /// 当前拍位正文展示内容。
  final String? text;

  /// 当前拍位正文知识点锚点列表，仅范文只读态展示。
  final List<ZhenxieTaskDetailsEntityContentAnchor?> knowledgeAnchors;

  /// 当前拍位输入占位提示。
  final String? placeholder;

  /// 当前拍位绑定的段落实例主键。
  final int? paragraphId;

  const WritingBoardStepData({
    required this.beatNid,
    required this.beatLabel,
    this.paragraphTypeNid,
    this.paragraphTypeName,
    this.usageName,
    this.usageDescription,
    this.fill = 'write',
    this.selected = false,
    this.editable = false,
    this.hidden = false,
    this.canOpenStepDialog = false,
    this.focused = false,
    this.beatColor,
    this.beatTextColor,
    this.text,
    this.knowledgeAnchors = const [],
    this.placeholder,
    this.paragraphId,
  });

  /// 基于当前拍位数据复制一个新实例。
  WritingBoardStepData copyWith({
    String? beatNid,
    String? beatLabel,
    String? paragraphTypeNid,
    String? paragraphTypeName,
    String? usageName,
    String? usageDescription,
    String? fill,
    bool? selected,
    bool? editable,
    bool? hidden,
    bool? canOpenStepDialog,
    bool? focused,
    Color? beatColor,
    Color? beatTextColor,
    String? text,
    List<ZhenxieTaskDetailsEntityContentAnchor?>? knowledgeAnchors,
    String? placeholder,
    int? paragraphId,
  }) {
    return WritingBoardStepData(
      beatNid: beatNid ?? this.beatNid,
      beatLabel: beatLabel ?? this.beatLabel,
      paragraphTypeNid: paragraphTypeNid ?? this.paragraphTypeNid,
      paragraphTypeName: paragraphTypeName ?? this.paragraphTypeName,
      usageName: usageName ?? this.usageName,
      usageDescription: usageDescription ?? this.usageDescription,
      fill: fill ?? this.fill,
      selected: selected ?? this.selected,
      editable: editable ?? this.editable,
      hidden: hidden ?? this.hidden,
      canOpenStepDialog: canOpenStepDialog ?? this.canOpenStepDialog,
      focused: focused ?? this.focused,
      beatColor: beatColor ?? this.beatColor,
      beatTextColor: beatTextColor ?? this.beatTextColor,
      text: text ?? this.text,
      knowledgeAnchors: knowledgeAnchors ?? this.knowledgeAnchors,
      placeholder: placeholder ?? this.placeholder,
      paragraphId: paragraphId ?? this.paragraphId,
    );
  }
}

/// 顶部题干素材统一模型。
class WritingBoardMaterialData {
  /// 当前素材类型。
  final String kind;

  /// 当前素材可访问地址。
  final String url;

  /// 当前素材资源主键。
  final String? key;

  const WritingBoardMaterialData({
    required this.kind,
    required this.url,
    this.key,
  });
}

/// 作答区媒体配置。
class WritingBoardMediaAnswerData {
  /// 当前媒体作答类型。
  final String kind;

  /// 当前媒体作答最少数量限制。
  final int minCount;

  /// 当前媒体作答最多数量限制。
  final int maxCount;

  /// 当前媒体作答项列表。
  final List<WritingBoardMediaItemData> items;

  const WritingBoardMediaAnswerData({
    required this.kind,
    this.minCount = 0,
    this.maxCount = 0,
    this.items = const [],
  });

  /// 基于当前媒体作答配置复制一个新实例。
  WritingBoardMediaAnswerData copyWith({
    String? kind,
    int? minCount,
    int? maxCount,
    List<WritingBoardMediaItemData>? items,
  }) {
    return WritingBoardMediaAnswerData(
      kind: kind ?? this.kind,
      minCount: minCount ?? this.minCount,
      maxCount: maxCount ?? this.maxCount,
      items: items ?? this.items,
    );
  }
}

/// 单个媒体答案项。
class WritingBoardMediaItemData {
  /// 当前媒体资源主键。
  final String? key;

  /// 当前媒体远端访问地址。
  final String? url;

  /// 当前媒体本地路径。
  final String? localPath;

  const WritingBoardMediaItemData({
    this.key,
    this.url,
    this.localPath,
  });

  /// 基于当前媒体项复制一个新实例。
  WritingBoardMediaItemData copyWith({
    String? key,
    String? url,
    String? localPath,
  }) {
    return WritingBoardMediaItemData(
      key: key ?? this.key,
      url: url ?? this.url,
      localPath: localPath ?? this.localPath,
    );
  }
}
