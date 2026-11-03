import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../entities/zhenxie_task_details_entity.dart';

/// 真写详情页右栏信息区的 tab 类型。
enum ZhenxieTaskDetailsTabType {
  materials("materials", "资料"),
  blueprint("blueprint", "蓝图"),
  correction("correction", "批改"),
  exercise("exercise", "练习"),
  ;

  final String value;
  final String text;

  const ZhenxieTaskDetailsTabType(this.value, this.text);

  static ZhenxieTaskDetailsTabType fromValue(String? value) {
    for (final item in ZhenxieTaskDetailsTabType.values) {
      if (item.value == value) return item;
    }
    return ZhenxieTaskDetailsTabType.materials;
  }
}

/// 真写任务作答状态。
enum ZhenxieTaskAnswerStatusEnum {
  draft("draft"),
  submitted("submitted");

  final String value;

  const ZhenxieTaskAnswerStatusEnum(this.value);

  static ZhenxieTaskAnswerStatusEnum? fromValue(String? value) {
    for (final item in ZhenxieTaskAnswerStatusEnum.values) {
      if (item.value == value) return item;
    }
    return null;
  }
}

/// 真写批改状态。
enum ZhenxieReviewStatusEnum {
  queued("queued"),
  running("running"),
  failed("failed"),
  done("done");

  final String value;

  const ZhenxieReviewStatusEnum(this.value);

  static ZhenxieReviewStatusEnum? fromValue(String? value) {
    for (final item in ZhenxieReviewStatusEnum.values) {
      if (item.value == value) return item;
    }
    return null;
  }
}

/// 真写稿纸里的特殊拍位 key。
enum ZhenxieTaskPartKeyEnum {
  head("head", "文首", "首"),
  tail("tail", "文尾", "尾");

  final String value;
  final String label;
  final String shortLabel;

  const ZhenxieTaskPartKeyEnum(this.value, this.label, this.shortLabel);

  static ZhenxieTaskPartKeyEnum? fromValue(String? value) {
    for (final item in ZhenxieTaskPartKeyEnum.values) {
      if (item.value == value) return item;
    }
    return null;
  }
}

/// 真写任务TEXT 提交模式 打字输入/写在纸上
enum ZhenxieTaskTextSubmitModeEnum {
  /// 打字输入
  typing("typed", "打字输入", AppTheme.cZhenxieFontPrimary),

  /// 写在纸上
  paper("paper", "写在纸上", AppTheme.cZhenxieColorPrimary);

  final String value;
  final String label;
  final Color color;

  const ZhenxieTaskTextSubmitModeEnum(this.value, this.label, this.color);

  /// 根据页面模式值反查文字提交模式。
  static ZhenxieTaskTextSubmitModeEnum fromValue(String? value) {
    for (final item in ZhenxieTaskTextSubmitModeEnum.values) {
      if (item.value == value) return item;
    }
    return ZhenxieTaskTextSubmitModeEnum.typing;
  }
}

/// 批改写作板显示模式。
enum ZhenxieTaskCorrectionWritingBoardModeEnum {
  /// 批注模式。
  annotation("批注"),

  /// 订正模式。
  correct("订正"),

  /// 升格模式。
  upgrade("升格"),

  /// 原稿模式。
  original("原稿")

  ;

  final String text;

  const ZhenxieTaskCorrectionWritingBoardModeEnum(this.text);
}

/// 批改区一次性闪动请求。
class ZhenxieTaskCorrectionPulse {
  /// 当前需要闪动的目标 id。
  final String id;

  /// 同一 id 连续触发时，用 tick 强制刷新。
  final int tick;

  const ZhenxieTaskCorrectionPulse({
    required this.id,
    required this.tick,
  });
}

enum ZhenxieReviewMarkerTabEnum {
  all("all", "全部"),
  taskAchievement("taskAchievement", "任务"),
  coherence("coherence", "连贯"),
  lexical("lexical", "词汇"),
  grammar("grammar", "语法"),
  highlight("highlight", "亮点");

  final String value;
  final String name;

  const ZhenxieReviewMarkerTabEnum(this.value, this.name);

  static ZhenxieReviewMarkerTabEnum fromValue(String? value) {
    for (final item in ZhenxieReviewMarkerTabEnum.values) {
      if (item.value == value) return item;
    }
    return ZhenxieReviewMarkerTabEnum.all;
  }
}

enum ZhenxieReviewTaskPointStatusEnum {
  covered("covered", "✓", Color(0xff22C55E)),
  partial("partial", "◐", Color(0xffF59E0B)),
  missing("missing", "✗", Color(0xffEF4444));

  final String value;
  final String symbol;
  final Color color;

  const ZhenxieReviewTaskPointStatusEnum(this.value, this.symbol, this.color);

  static ZhenxieReviewTaskPointStatusEnum fromValue(String? value) {
    for (final item in ZhenxieReviewTaskPointStatusEnum.values) {
      if (item.value == value) return item;
    }
    return ZhenxieReviewTaskPointStatusEnum.missing;
  }
}

enum ZhenxieReviewIssueSeverityEnum {
  suggestion("suggestion", Color(0xffF59E0B)),
  error("error", Color(0xffEF4444)),
  highlight("highlight", Color(0xff16A34A)),
  normal("", null);

  final String value;
  final Color? color;

  const ZhenxieReviewIssueSeverityEnum(this.value, this.color);

  static ZhenxieReviewIssueSeverityEnum fromValue(String? value) {
    for (final item in ZhenxieReviewIssueSeverityEnum.values) {
      if (item.value == value) return item;
    }
    return ZhenxieReviewIssueSeverityEnum.normal;
  }
}

enum ZhenxieReviewGradeEnum {
  excellent(
    "excellent",
    "优秀",
    Color(0xff22C55E),
    Color(0xff22C55E),
    Color(0xff22C55E),
  ),
  good(
    "good",
    "良好",
    Color(0xff3B82F6),
    Color(0xff3B82F6),
    Color(0xff3B82F6),
  ),
  pass(
    "pass",
    "达标",
    Color(0xffF59E0B),
    Color(0xffF59E0B),
    Color(0xffF59E0B),
  ),
  retry(
    "retry",
    "再练练",
    Color(0xffEF4444),
    Color(0xffEF4444),
    Color(0xffEF4444),
  );

  final String value;
  final String name;
  final Color backgroundBase;
  final Color borderBase;
  final Color foreground;

  const ZhenxieReviewGradeEnum(
    this.value,
    this.name,
    this.backgroundBase,
    this.borderBase,
    this.foreground,
  );

  Color get background => backgroundBase.withValues(alpha: 0.12);

  Color get border => borderBase.withValues(alpha: 0.2);

  static ZhenxieReviewGradeEnum? fromValue(String? value) {
    if (value == null) return null;
    for (final item in ZhenxieReviewGradeEnum.values) {
      if (item.value == value) return item;
    }
    return null;
  }
}

/// 真写当前作答详情的状态派生。
extension ZhenxieTaskDetailsMemberWritingStatusX on ZhenxieTaskDetailsMemberWriting {
  /// 当前作答状态枚举。
  ZhenxieTaskAnswerStatusEnum? get statusEnum => ZhenxieTaskAnswerStatusEnum.fromValue(status);
}

/// 真写当前批改详情的状态派生。
extension ZhenxieTaskDetailsMemberWritingReviewStatusX on ZhenxieTaskDetailsMemberWritingReview {
  /// 当前批改状态枚举。
  ZhenxieReviewStatusEnum? get statusEnum => ZhenxieReviewStatusEnum.fromValue(status);
}
