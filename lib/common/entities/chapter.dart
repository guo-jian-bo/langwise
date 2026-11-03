import 'package:flutter/material.dart';

/// 教材模型
/// 用于表示整本教材的信息
class Book {
  /// 教材唯一标识符
  final int bookId;

  /// 教材名称
  final String? bookName;

  final int? moduleId;

  /// 是否显示保存所有信息按钮
  final bool? isDone;

  /// 教材章节列表
  final List<BookChapter>? chapterList;

  /// 全局Key，用于UI关联
  final GlobalKey globalKey = GlobalKey();

  Book({
    required this.bookId,
    this.bookName = '',
    this.moduleId,
    this.isDone,
    this.chapterList,
  });

  /// 从JSON构造
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      bookId: json['bookId'] as int,
      bookName: json['bookName'] as String?,
      moduleId: json['moduleId'] as int?,
      isDone: json['isDone'] as bool?,
      chapterList: json['chapterList'] != null
          ? (json['chapterList'] as List<dynamic>)
              .map((e) => BookChapter.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'bookId': bookId,
      if (bookName != null) 'bookName': bookName,
      if (moduleId != null) 'moduleId': moduleId,
      if (isDone != null) 'isDone': isDone,
      if (chapterList != null)
        'chapterList': chapterList!.map((e) => e.toJson()).toList(),
    };
  }

  /// 创建副本并更新指定字段
  Book copyWith({
    int? bookId,
    String? bookName,
    int? moduleId,
    bool? isDone,
    List<BookChapter>? chapterList,
  }) {
    return Book(
      bookId: bookId ?? this.bookId,
      bookName: bookName ?? this.bookName,
      moduleId: moduleId ?? this.moduleId,
      isDone: isDone ?? this.isDone,
      chapterList: chapterList ?? this.chapterList,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Book && other.bookId == bookId;
  }

  @override
  int get hashCode => Object.hash(runtimeType, bookId);

  @override
  String toString() {
    return 'Book(bookId: $bookId, bookName: $bookName, moduleId: $moduleId, isDone: $isDone, chapters: ${chapterList?.length ?? 0})';
  }
}

/// 教材章节模型
/// 用于表示教材中的章节信息，包含章节名称、类型、页码范围等数据
class BookChapter {
  /// 章节唯一标识符
  final int uid;

  /// 单元ID
  final int? unitId;

  ///是否分割
  final bool? splited;

  /// 是否提取
  final bool? extracted;

  /// 是否关联单元
  final bool? united;

  /// 章节类型ID
  int? chapterTypeId;

  /// 章节名称
  final String? chapterName;

  /// 章节包含的页面列表
  final List<BookPage>? bookPageList;

  /// 页码范围
  PageRange? pageRange;

  /// 值键Key，用于UI关联
  final ValueKey valueKey;

  /// 章节名称输入控制器
  TextEditingController? nameController;

  BookChapter({
    required this.uid,
    this.unitId,
    this.splited,
    this.extracted,
    this.united,
    String? uuid,
    this.chapterTypeId,
    this.chapterName,
    this.bookPageList,
    this.pageRange,
    TextEditingController? nameController,
    ValueKey? valueKey,
  })  : valueKey = valueKey ?? ValueKey(uid),
        nameController =
            nameController ?? TextEditingController(text: chapterName ?? '');

  /// 从JSON构造
  factory BookChapter.fromJson(Map<String, dynamic> json) {
    return BookChapter(
      uid: json['uid'] as int,
      unitId: json['unitId'] as int?,
      splited: json['splited'] as bool?,
      extracted: json['extracted'] as bool?,
      united: json['united'] as bool?,
      uuid: json['uuid'] as String?,
      chapterTypeId: json['chapterTypeId'] as int?,
      chapterName: json['chapterName'] as String?,
      bookPageList: json['bookPageList'] != null
          ? (json['bookPageList'] as List<dynamic>)
              .map((e) => BookPage.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      pageRange: json['pageRange'] != null
          ? PageRange.fromJson(json['pageRange'] as Map<String, dynamic>)
          : null,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      if (uid > 0) 'uid': uid,
      if (unitId != null) 'unitId': unitId,
      if (splited != null) 'splited': splited,
      if (extracted != null) 'extracted': extracted,
      if (united != null) 'united': united,
      if (chapterTypeId != null) 'chapterTypeId': chapterTypeId,
      'chapterName': nameController?.text ?? '',
      if (pageRange != null) 'pageRange': pageRange!.toJson(),
    };
  }

  /// 释放控制器
  void disposeControllers() {
    nameController?.dispose();
    nameController = null;

    pageRange?.disposeControllers();
    pageRange = null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookChapter && other.uid == uid;
  }

  @override
  int get hashCode => Object.hash(runtimeType, uid);

  /// 检查章节名称是否为空
  bool get isNameEmpty =>
      nameController?.text == null || (nameController?.text.isEmpty ?? true);

  @override
  String toString() {
    return 'BookChapter(uid: $uid, unitId: $unitId, splited: $splited, extracted: $extracted, united: $united, chapterName: $chapterName, chapterTypeId: $chapterTypeId,pageRange: $pageRange)';
  }
}

/// 教材页面模型
/// 用于表示教材中的单个页面
class BookPage {
  /// 页面唯一标识符
  final int? uid;

  /// 页面在存储中的键
  final String? key;

  /// 页面图片URL
  final String? url;

  /// 页面图片大小（字节）
  final int? size;

  /// 页面索引
  final int? index;

  /// 页面访问权限
  final String? access;

  /// 更新时间
  final DateTime? updated;

  /// 创建时间
  final DateTime? created;

  /// 全局Key，用于UI关联
  final GlobalKey globalKey = GlobalKey();

  BookPage({
    this.uid,
    this.key,
    this.url,
    this.size,
    this.index,
    this.access,
    this.updated,
    this.created,
  });

  /// 从JSON构造
  factory BookPage.fromJson(Map<String, dynamic> json) {
    return BookPage(
      uid: json['uid'] != null ? json['uid'] as int : null,
      key: json['key'] != null ? json['key'] as String : null,
      url: json['url'] != null ? json['url'] as String : null,
      size: json['size'] != null ? json['size'] as int : null,
      index: json['index'] != null ? json['index'] as int : null,
      access: json['access'] != null ? json['access'] as String : null,
      updated: json['updated'] != null
          ? DateTime.parse(json['updated'] as String)
          : null,
      created: json['created'] != null
          ? DateTime.parse(json['created'] as String)
          : null,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      if (uid != null) 'uid': uid,
      if (key != null) 'key': key,
      if (url != null) 'url': url,
      if (size != null) 'size': size,
      if (index != null) 'index': index,
      if (access != null) 'access': access,
      if (updated != null) 'updated': updated!.toIso8601String(),
      if (created != null) 'created': created!.toIso8601String(),
    };
  }

  /// 创建副本并更新指定字段
  BookPage copyWith({
    int? uid,
    String? key,
    String? url,
    int? size,
    int? index,
    String? access,
    DateTime? updated,
    DateTime? created,
  }) {
    return BookPage(
      uid: uid ?? this.uid,
      key: key ?? this.key,
      url: url ?? this.url,
      size: size ?? this.size,
      index: index ?? this.index,
      access: access ?? this.access,
      updated: updated ?? this.updated,
      created: created ?? this.created,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookPage && other.uid == uid;
  }

  @override
  int get hashCode => uid?.hashCode ?? 0;

  @override
  String toString() {
    return 'BookPage(uid: $uid, index: $index)';
  }
}

/// 页码范围模型
/// 用于表示PDF页码和实际书籍页码的范围
class PageRange {
  /// PDF页码范围
  PageMinMax? _pdf;

  PageMinMax? get pdf => _pdf;

  set pdf(PageMinMax? value) {
    _pdf = value;
  }

  /// 实际书籍页码范围
  PageMinMax? _book;

  PageMinMax? get book => _book;

  set book(PageMinMax? value) {
    _book = value;
  }

  /// 释放控制器
  void disposeControllers() {
    pdf?.disposeControllers();
    book?.disposeControllers();
  }

  PageRange({
    PageMinMax? pdf,
    PageMinMax? book,
  })  : _pdf = pdf,
        _book = book;

  /// 从JSON构造
  factory PageRange.fromJson(Map<String, dynamic> json) {
    return PageRange(
      pdf: json['pdf'] != null
          ? PageMinMax.fromJson(json['pdf'] as Map<String, dynamic>)
          : null,
      book: json['book'] != null
          ? PageMinMax.fromJson(json['book'] as Map<String, dynamic>)
          : null,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      if (_pdf != null) 'pdf': _pdf!.toJson(),
      if (_book != null) 'book': _book!.toJson(),
    };
  }

  @override
  String toString() {
    return 'PageRange(pdf: $pdf, book: $book)';
  }
}

/// 页码最小最大值模型
/// 用于表示页码的起始和结束值
class PageMinMax {
  /// 起始页码
  int _start;

  int get start => _start;

  set start(int value) {
    _start = value;
    startController?.text = "$value";
  }

  /// 结束页码
  int _end;

  int get end => _end;

  set end(int value) {
    _end = value;
    endController?.text = "$value";
  }

  /// 起始页码输入控制器
  TextEditingController? startController;

  /// 结束页码输入控制器
  TextEditingController? endController;

  PageMinMax({
    int start = 0,
    int end = 0,
    TextEditingController? startController,
    TextEditingController? endController,
  })  : _start = start,
        _end = end,
        startController =
            startController ?? TextEditingController(text: "$start"),
        endController = endController ?? TextEditingController(text: "$end");

  /// 从JSON构造
  factory PageMinMax.fromJson(Map<String, dynamic> json) {
    return PageMinMax(
      start: json['start'] ?? 0,
      end: json['end'] ?? 0,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'start': startController?.text ?? '0',
      'end': endController?.text ?? '0'
    };
  }

  /// 释放所有控制器
  void disposeControllers() {
    startController?.dispose();
    startController = null;

    endController?.dispose();
    endController = null;
  }

  @override
  String toString() {
    return 'PageMinMax( pages: ${startController?.text}-${endController?.text})';
  }
}

class ChapterType {
  final int v;
  final int uid;
  final String? title;
  final String? access;
  final String? created;
  final String? updated;

  /// 检查标题是否有效（非空且非空字符串）
  bool get hasValidTitle => title != null && title!.isNotEmpty;

  ChapterType({
    required this.v,
    required this.uid,
    this.title,
    this.access,
    this.created,
    this.updated,
  });

  factory ChapterType.fromJson(Map<String, dynamic> json) {
    return ChapterType(
      v: json['v'] as int? ?? 0,
      uid: json['uid'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      access: json['access'] as String?,
      created: json['created'] as String? ?? '',
      updated: json['updated'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'v': v,
      'uid': uid,
      'title': title,
      'access': access,
      'created': created,
      'updated': updated,
    };
  }

  ChapterType copyWith({
    int? v,
    int? uid,
    String? title,
    String? access,
    String? created,
    String? updated,
  }) {
    return ChapterType(
      v: v ?? this.v,
      uid: uid ?? this.uid,
      title: title ?? this.title,
      access: access ?? this.access,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  @override
  String toString() {
    return 'ChapterType{v: $v, uid: $uid, title: $title, access: $access, '
        'created: $created, updated: $updated}';
  }
}
