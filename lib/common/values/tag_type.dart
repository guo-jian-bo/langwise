import 'package:flutter/cupertino.dart';
import 'package:langwise/theme/theme.dart';

enum TagType {
  // 成功
  success(0, "成功", Color(0xff63DE77), Color.fromRGBO(23, 201, 100, 0.15)),
  // 失败
  error(1, "错误", Color(0xffFF2D46), Color.fromRGBO(243, 18, 96, 0.15)),
  // 重复
  duplicate(2, "重复", Color(0xffFF781F), Color.fromRGBO(255, 120, 31, 0.15)),
  // 待处理
  pending(3, "待处理", Color(0xff1777E7), Color.fromRGBO(23, 119, 231, 0.15)),
  // 已拒绝
  rejected(4, "已拒绝", Color(0xffBAC0CC), Color.fromRGBO(53, 62, 92, 0.15)),
  // 未知
  unknown(-1, "未知状态", Color(0xffBAC0CC), Color.fromRGBO(53, 62, 92, 0.15));

  final int value;
  final String title;
  final Color textColor;
  final Color backgroundColor;

  const TagType(this.value, this.title, this.textColor, this.backgroundColor);

  // 工厂方法
  factory TagType.fromValue(int value) {
    return TagType.values.firstWhere(
      (type) => type.value == value,
      // 默认值
      orElse: () => TagType.unknown,
    );
  }
}

extension TagTypeExtension on TagType {
  bool get isSuccess => this == TagType.success;

  bool get isError => this == TagType.error;

  bool get isDuplicated => this == TagType.duplicate;

  bool get isPending => this == TagType.pending;

  bool get isRejected => this == TagType.rejected;

  bool get isUnknown => this == TagType.unknown;
}

enum ScanWordType {
  // 未解析
  unresolved('NONE', "未解析", Color(0xffBAC0CC), Color.fromRGBO(53, 62, 92, 0.15)),
  // 正在进行解析
  parsing('ANALYSIS', "正在进行解析", Color(0xff1777E7), Color.fromRGBO(23, 119, 231, 0.15)),
  // 解析完成,等待确认
  pending('ANALYSIS_FINISH', "解析完成,等待确认", Color(0xffFF781F), Color.fromRGBO(255, 120, 31, 0.15)),
  // 词汇已确认
  confirmed('CONFIRM', "词汇已确认", Color(0xff63DE77), Color.fromRGBO(23, 201, 100, 0.15)),
  // 单元已整合
  united('UNITED', "单元已整合", Color(0xff6869FF), Color.fromRGBO(104, 105, 255, 0.15)),
  // 章节已整合
  chaptered('CHAPTERED', "章节已整合", Color(0xffFF649C), Color.fromRGBO(255, 100, 156, 0.15)),
  // 解析失败
  error('ANALYSIS_ERROR', "解析失败", Color(0xffBAC0CC), Color.fromRGBO(53, 62, 92, 0.15));

  final String value;
  final String title;
  final Color textColor;
  final Color backgroundColor;

  const ScanWordType(this.value, this.title, this.textColor, this.backgroundColor);

  // 工厂方法
  factory ScanWordType.fromValue(String value) {
    return ScanWordType.values.firstWhere(
      (type) => type.value == value,
      // 默认值
      orElse: () => ScanWordType.unresolved,
    );
  }
}

extension ScanWordTypeExtension on ScanWordType {
  bool get isConfirmed => this == ScanWordType.confirmed;

  bool get isPending => this == ScanWordType.pending;

  bool get isParsing => this == ScanWordType.parsing;

  bool get isUnresolved => this == ScanWordType.unresolved;

  bool get isError => this == ScanWordType.error;

  bool get isUnited => this == ScanWordType.united;

  bool get isChaptered => this == ScanWordType.chaptered;
}

/// 书籍分析状态
///
/// 表示书籍在系统中解析/分析的不同阶段:
/// - NONE: 未解析状态，表示书籍未开始分析
/// - ANALYSIS: 正在解析状态，表示系统正在分析书籍内容
/// - ANALYSIS_FINISH: 解析完成状态，表示书籍已成功解析但尚未确认
/// - CONFIRM: 已确认状态，表示书籍解析结果已被确认
/// - ANALYSIS_ERROR: 解析失败状态，表示书籍解析过程中出现错误
enum BookAnalysisStatus {
  // 词汇已确认
  confirmed('CONFIRM', "词汇已确认", Color(0xff63DE77), Color.fromRGBO(23, 201, 100, 0.15)),
  // 解析完成,等待确认
  pending('ANALYSIS_FINISH', "解析完成,等待确认", Color(0xffFF781F), Color.fromRGBO(255, 120, 31, 0.15)),
  // 正在进行解析
  parsing('ANALYSIS', "正在进行解析", Color(0xff1777E7), Color.fromRGBO(23, 119, 231, 0.15)),
  // 未解析
  unresolved('NONE', "未解析", Color(0xffBAC0CC), Color.fromRGBO(53, 62, 92, 0.15)),
  // 解析失败
  error('ANALYSIS_ERROR', "解析失败", Color(0xffBAC0CC), Color.fromRGBO(53, 62, 92, 0.15));

  final String value;
  final String title;
  final Color textColor;
  final Color backgroundColor;

  const BookAnalysisStatus(this.value, this.title, this.textColor, this.backgroundColor);

  // 工厂方法
  factory BookAnalysisStatus.fromValue(String value) {
    return BookAnalysisStatus.values.firstWhere(
      (type) => type.value == value,
      // 默认值
      orElse: () => BookAnalysisStatus.unresolved,
    );
  }
}

extension BookAnalysisStatusExtension on BookAnalysisStatus {
  bool get isConfirmed => this == BookAnalysisStatus.confirmed;

  bool get isPending => this == BookAnalysisStatus.pending;

  bool get isParsing => this == BookAnalysisStatus.parsing;

  bool get isUnresolved => this == BookAnalysisStatus.unresolved;

  bool get isError => this == BookAnalysisStatus.error;
}

enum KnowledgeType {
  // 英语单词
  EN_WORD("EN_WORD", "英语单词"),
  // 英语短语
  EN_PHRASE("EN_PHRASE", "英语短语"),
  // 英语句子
  EN_SENTENCE("EN_SENTENCE", "英语句子"),
  // 英语文章
  EN_TEXT("EN_TEXT", "英语文章");

  final String value;
  final String title;

  const KnowledgeType(this.value, this.title);

  // 工厂方法
  factory KnowledgeType.fromValue(String value) {
    return KnowledgeType.values.firstWhere(
      (type) => type.value == value,
      // 默认值
      orElse: () => KnowledgeType.EN_WORD,
    );
  }
}

/// KnowledgeType扩展 - 提供is类型的便捷判断方法
extension KnowledgeTypeExtension on KnowledgeType {
  /// 是否为英语单词
  bool get isWord => this == KnowledgeType.EN_WORD;

  /// 是否为英语短语
  bool get isPhrase => this == KnowledgeType.EN_PHRASE;

  /// 是否为英语句子
  bool get isSentence => this == KnowledgeType.EN_SENTENCE;

  /// 是否为英语文章
  bool get isText => this == KnowledgeType.EN_TEXT;
}

enum BookType {
  // 教材
  TEXTBOOK("TEXTBOOK", "教材"),
  // 绘本
  PICTURE("PICTURE", "绘本");

  final String value;
  final String title;

  const BookType(this.value, this.title);

  // 工厂方法
  factory BookType.fromValue(String value) {
    return BookType.values.firstWhere(
      (type) => type.value == value,
      // 默认值
      orElse: () => BookType.TEXTBOOK,
    );
  }
}

/// 知识点状态
///
/// 表示知识点在系统中的不同状态:
/// - UN_INCLUDED: 未收录状态，表示知识点尚未被系统收录
/// - INCLUDED: 已收录状态，表示知识点已被系统收录
/// - NORMAL: 正常状态，表示知识点处于正常状态
enum KnowledgePointStatus {
  // 未收录
  unIncluded('UN_INCLUDED', '未收录', AppTheme.cFeedbackErrorText, AppTheme.cFeedbackErrorBackground),
  // 重复添加
  repeatAdd('REPEAT_ADD', '重复添加', AppTheme.cFeedbackWarningText, AppTheme.cFeedbackWarningText),
  // 正常状态
  normal('NORMAL', '正常状态', Color(0xff63DE77), Color.fromRGBO(23, 201, 100, 0.15));

  final String value;
  final String title;
  final Color textColor;
  final Color backgroundColor;

  const KnowledgePointStatus(this.value, this.title, this.textColor, this.backgroundColor);

  // 工厂方法
  factory KnowledgePointStatus.fromValue(String value) {
    return KnowledgePointStatus.values.firstWhere(
      (type) => type.value == value,
      // 默认值
      orElse: () => KnowledgePointStatus.normal,
    );
  }
}

extension KnowledgePointStatusExtension on KnowledgePointStatus {
  bool get isUnIncluded => this == KnowledgePointStatus.unIncluded;

  bool get isRepeatAdd => this == KnowledgePointStatus.repeatAdd;

  bool get isNormal => this == KnowledgePointStatus.normal;
}

enum UnmountType {
  // 上架
  normal("NORMAL", "上架", Color(0xff44af5c)),
  // 下架
  internal("INTERNAL", "下架", Color(0xffFF2D46)),
  // 删除
  deleted("DELETED", "删除", Color.fromRGBO(53, 62, 92, 0.15));

  final String value;
  final String title;
  final Color backgroundColor;

  const UnmountType(this.value, this.title, this.backgroundColor);

  // 工厂方法
  factory UnmountType.fromValue(String value) {
    return UnmountType.values.firstWhere(
      (type) => type.value == value,
      // 默认值
      orElse: () => UnmountType.normal,
    );
  }
}

extension UnmountTypeExtension on UnmountType {
  bool get isNormal => this == UnmountType.normal;

  bool get isInternal => this == UnmountType.internal;

  bool get isDeleted => this == UnmountType.deleted;
}

enum InventoryType {
  // 已在库
  ALREADY_IN("ALREADY_IN", "已在库", Color(0xff44af5c)),
  // 新入库
  newlyAdded("NEWLY_ADDED", "新入库", Color(0xffFF2D46));

  final String value;
  final String title;
  final Color backgroundColor;

  const InventoryType(this.value, this.title, this.backgroundColor);

  // 工厂方法
  factory InventoryType.fromValue(String value) {
    return InventoryType.values.firstWhere(
      (type) => type.value == value,
      // 默认值
      orElse: () => InventoryType.ALREADY_IN,
    );
  }
}

extension InventoryTypeExtension on InventoryType {
  bool get isAlreadyIn => this == InventoryType.ALREADY_IN;

  bool get isNewlyAdded => this == InventoryType.newlyAdded;
}
