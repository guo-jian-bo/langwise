import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:langwise/common/entities/page_image.dart';
import 'package:langwise/common/values/values.dart';
import 'package:langwise/common/widgets/data_table_widget/data_table.dart';
import 'package:langwise/utils/utils.dart';
import 'package:uuid/uuid.dart';

// 创建Book
class BookRequestEntity {
  final String title;
  final String? cover;
  final String? author;
  final String? publisher;

  // 2015-12-01
  final String? pubDate;
  final String? isbn;
  final List<dynamic>? isbns;
  final int? pageCount;
  final String? subject;
  final String? grade;
  final String? semester;
  final String? access;
  final String? type;
  final String? version;

  const BookRequestEntity(
      {required this.title,
      this.cover,
      this.author,
      this.publisher,
      this.pubDate,
      this.isbn,
      this.isbns,
      this.pageCount,
      this.subject,
      this.grade,
      this.semester,
      this.access,
      this.type,
      this.version});

  Map<String, dynamic> toJson() => {
        "title": title,
        "cover": cover,
        "author": author,
        "publisher": publisher,
        "pubDate": pubDate,
        "isbn": isbn,
        "isbns": isbns,
        "pageCount": pageCount,
        "subject": subject,
        "grade": grade,
        "semester": semester,
        "access": access,
        "type": type,
        "version": version
      };
}

// 书籍Response
class BookResponseEntity extends Dessert {
  final String? type;
  final String? title;
  final String? cover;
  final String? coverUrl;
  final String? author;
  final String? publisher;
  final String? pubDate;
  final String? isbn;
  final List<dynamic>? isbns;
  final String? isbn10;
  final int? pageCount;
  final String? status;
  final String? access;
  final int? moduleId;
  final int? levelId;
  final String? moduleName;

  // 学科
  final String? subject;

  // 年级
  final int? grade;

  // 学期
  final int? semester;

  // 版次
  final int? version;

  // 章节/词汇ID
  final int? glossaryChapterId;

  // 难度等级
  final int? difficulty;

  /// 0 没有 1 有
  final int? hasBook;

  BookResponseEntity(
      {this.type,
      this.title,
      this.cover,
      this.coverUrl,
      this.author,
      this.publisher,
      this.pubDate,
      this.isbn,
      this.isbns,
      this.isbn10,
      this.pageCount,
      this.status,
      this.access,
      this.moduleId,
      this.levelId,
      this.moduleName,
      this.subject,
      this.grade,
      this.semester,
      this.version,
      this.glossaryChapterId,
      this.difficulty,
      this.hasBook,
      required super.uid,
      super.calories});

  factory BookResponseEntity.fromJson(Map<String, dynamic> json,
          {Function? fromJson}) =>
      BookResponseEntity(
          uid: json["uid"] ?? 0,
          type: json["type"],
          title: json["title"],
          cover: json["cover"],
          coverUrl: json["coverUrl"],
          author: json["author"],
          publisher: json["publisher"],
          pubDate: json["pubDate"],
          isbn: json["isbn"],
          isbns: json["isbns"],
          isbn10: json["isbn10"],
          pageCount: json["pageCount"],
          status: json["status"],
          access: json["access"],
          moduleId: json["moduleId"],
          levelId: json["levelId"],
          moduleName: json["moduleName"],
          subject: json["subject"],
          grade: json["grade"],
          semester: json["semester"],
          version: json["version"],
          difficulty: json['difficulty'],
          hasBook: json['hasBook'],
          glossaryChapterId: json["glossaryChapterId"],
          calories: 0);

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "type": type,
        "title": title,
        "cover": cover,
        "coverUrl": coverUrl,
        "author": author,
        "publisher": publisher,
        "pubDate": pubDate,
        "isbn": isbn,
        "isbns": isbns?.toList(),
        "isbn10": isbn10,
        "pageCount": pageCount,
        "status": status,
        "access": access,
        "moduleId": moduleId,
        "levelId": levelId,
        "moduleName": moduleName,
        "subject": subject,
        "grade": grade,
        "semester": semester,
        "version": version,
        "glossaryChapterId": glossaryChapterId,
        "hasBook": hasBook,
        "difficulty": difficulty,
      };

  ScanWordType get wordType => ScanWordType.fromValue(status ?? '');

  // 学科
  String get newSubject {
    String? s;
    try {
      s = CommonUtil.subjects
          .map((element) => element[subject])
          .toList()
          .where((element) => element != null)
          .toList()
          .first;
    } catch (e) {
      if (kDebugMode) {
        // print('学科e:$e');
      }
    }
    return s ?? '';
  }

  // 年级
  String get newGrade {
    if (grade == null) return '';
    String? s;
    try {
      s = CommonUtil.grades[grade! - 1];
    } catch (e) {
      if (kDebugMode) {
        // print('年级e:$e');
      }
    }
    return s ?? '';
  }

  // 学期
  String get newSemester {
    if (semester == null) return '';
    String? s;
    try {
      s = CommonUtil.schoolTerms[semester! - 1];
    } catch (e) {
      if (kDebugMode) {
        // print('学期e:$e');
      }
    }
    return s ?? '';
  }

  BookType get newType => BookType.fromValue(type ?? '');
}

/// 书籍信息响应实体类
class BookInfoResponseEntity {
  /// uid标识符
  final int uid;

  /// 标题
  final String? title;

  /// 封面
  final String? cover;

  /// 封面URL
  final String? coverUrl;

  /// ISBN
  final String? isbn;

  final List<dynamic>? isbns;

  /// 学科
  final String? subject;

  /// 书籍页面列表
  final List<PageImage>? bookPageList;

  /// UI关联的全局键
  final GlobalKey globalKey;

  /// 唯一标识符
  final String uniqueId;

  /// 构造函数
  BookInfoResponseEntity({
    required this.uid,
    this.title,
    this.cover,
    this.coverUrl,
    this.isbn,
    this.isbns,
    this.subject,
    this.bookPageList,
    String? uniqueId,
  })  : uniqueId = uniqueId ?? const Uuid().v6(),
        globalKey = GlobalKey(debugLabel: uid.toString());

  /// 从JSON创建实例
  factory BookInfoResponseEntity.fromJson(Map<String, dynamic> json) {
    List<PageImage>? pageList;
    if (json['bookPageList'] != null) {
      pageList = <PageImage>[];
      json['bookPageList'].forEach((v) {
        pageList!.add(PageImage.fromJson(v));
      });
    }

    return BookInfoResponseEntity(
      uid: json['uid'] ?? 0,
      title: json['title'],
      cover: json['cover'],
      coverUrl: json['coverUrl'],
      isbn: json['isbn'],
      isbns: json['isbns'],
      subject: json['subject'],
      bookPageList: pageList,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() => {
        'uid': uid,
        'title': title,
        'cover': cover,
        'coverUrl': coverUrl,
        'isbn': isbn,
        'isbns': isbns,
        'subject': subject,
        'bookPageList': bookPageList?.map((e) => e.toJson()).toList(),
      };

  /// 相等性比较
  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is BookInfoResponseEntity && other.uid == uid;
  }

  /// 哈希值
  @override
  int get hashCode => Object.hash(runtimeType, uid);
}
