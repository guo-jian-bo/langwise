import 'package:flutter/material.dart';

import '../../../../entities/zhenxie_task_details_entity.dart';
import '../../../../enum/enum.dart';

/// 写作板模式宏。
class WritingBoardModeEnum {
  /// 模式稳定值，用于路由参数、`Get.arguments` 和持久化传递。
  final String value;

  /// 写作板模式私有构造。
  const WritingBoardModeEnum._({
    required this.value,
  });

  /// 任务模式。
  static const WritingBoardModeEnum task = WritingBoardModeEnum._(
    value: 'task',
  );

  /// 范文模式。
  static const WritingBoardModeEnum exemplar = WritingBoardModeEnum._(
    value: 'exemplar',
  );

  /// 任务查看范文模式。
  static const WritingBoardModeEnum taskExemplar = WritingBoardModeEnum._(
    value: 'task_exemplar',
  );

  /// 编辑范文模式。
  static const WritingBoardModeEnum exemplarEdit = WritingBoardModeEnum._(
    value: 'exemplar_edit',
  );

  /// 批改模式。
  static const WritingBoardModeEnum correction = WritingBoardModeEnum._(
    value: 'correction',
  );

  /// 批改查看范文模式。
  static const WritingBoardModeEnum correctionExemplar = WritingBoardModeEnum._(
    value: 'correction_exemplar',
  );

  /// 当前支持的全部写作板模式。
  static const List<WritingBoardModeEnum> values = [
    task,
    exemplar,
    taskExemplar,
    exemplarEdit,
    correction,
    correctionExemplar,
  ];

  /// 根据稳定值反查对应写作板模式，默认回退到任务模式。
  static WritingBoardModeEnum fromValue(String? value) {
    for (final item in values) {
      if (item.value == value) return item;
    }
    return task;
  }

  /// 当前模式是否展示范文内容。
  bool get usesExemplarContent {
    return this == exemplar || this == taskExemplar || this == exemplarEdit || this == correctionExemplar;
  }

  /// 当前模式是否属于任务查看范文态。
  bool get isTaskExemplarMode {
    return this == taskExemplar;
  }

  /// 当前模式是否属于范文编辑态。
  bool get isExemplarEditMode {
    return this == exemplarEdit;
  }

  /// 当前模式是否属于范文查看态。
  bool get isExemplarReadOnlyMode {
    return this == exemplar || this == taskExemplar;
  }

  /// 当前模式是否属于批改查看态。
  bool get isCorrectionMode {
    return this == correction;
  }

  /// 当前模式是否属于批改查看范文态。
  bool get isCorrectionExemplarMode {
    return this == correctionExemplar;
  }

  /// 当前模式是否属于任意批改上下文。
  bool get isCorrectionContextMode {
    return this == correction || this == correctionExemplar;
  }

  /// 当前模式是否只读。
  bool get isReadOnlyMode {
    return this == exemplar || this == taskExemplar || this == correction || this == correctionExemplar;
  }
}

/// 写作板统一渲染数据。
class WritingBoardData {
  /// 当前写作板板式皮肤主键。
  final String? skinNid;

  /// 当前答卷区作答类型。
  final String? answerKind;

  /// 当前文字写作板提交模式。
  final ZhenxieTaskTextSubmitModeEnum writingBoardTextMode;

  /// 当前写作板模式宏。
  final WritingBoardModeEnum mode;

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

  /// 当前文字题“写在纸上”模式的纸面照片数据。
  final WritingBoardMediaAnswerData? paperImageAnswer;

  /// 当前答卷区作答类型宏，统一收口 `answerKind` 的字符串判断。
  ZhenxieTaskAnswerKindEnum get answerKindEnum => ZhenxieTaskAnswerKindEnum.fromValue(answerKind);

  const WritingBoardData({
    this.skinNid,
    this.answerKind,
    this.writingBoardTextMode = ZhenxieTaskTextSubmitModeEnum.typing,
    this.mode = WritingBoardModeEnum.task,
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
    this.paperImageAnswer,
  });

  /// 基于当前渲染数据复制一个新实例。
  WritingBoardData copyWith({
    String? skinNid,
    String? answerKind,
    ZhenxieTaskTextSubmitModeEnum? writingBoardTextMode,
    WritingBoardModeEnum? mode,
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
    WritingBoardMediaAnswerData? paperImageAnswer,
  }) {
    return WritingBoardData(
      skinNid: skinNid ?? this.skinNid,
      answerKind: answerKind ?? this.answerKind,
      writingBoardTextMode: writingBoardTextMode ?? this.writingBoardTextMode,
      mode: mode ?? this.mode,
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
      paperImageAnswer: paperImageAnswer ?? this.paperImageAnswer,
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
