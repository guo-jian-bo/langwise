class CustomCourseBookListEntity {
  final List<CustomCourseBookEntity>? list;

  CustomCourseBookListEntity({this.list});

  factory CustomCourseBookListEntity.fromJson(Map<String, dynamic> json) {
    return CustomCourseBookListEntity(
      list: (json['list'] as List<dynamic>?)
          ?.map(
              (e) => CustomCourseBookEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'list': list,
    };
  }
}

class CustomCourseBookEntity {
  int? uid;
  final String? title;
  final String? mode;
  final int? recordId;

  /// 0 识别不到isbn
  /// 1 识别到isbn，库中没有
  /// 2 识别到isbn，库中有，不支持
  /// 3 成功
  int? status;

  final String? tip;

  /// 封面
  final String? cover;
  final String? coverUrl;

  final int? grade;
  final int? difficulty;
  final int? hasBook;

  /// 作者
  final String? author;

  /// 出版社
  final String? publisher;

  /// 出版时间
  final String? pubDate;

  /// 书唯一码
  final String? isbn;

  /// 书唯一码，老版
  final String? isbn10;

  /// 一共有几页数据
  final int? pageCount;

  CustomCourseBookEntity({
    this.uid,
    this.title,
    this.mode,
    this.recordId,
    this.status,
    this.tip,
    this.cover,
    this.coverUrl,
    this.grade,
    this.difficulty,
    this.hasBook,
    this.author,
    this.publisher,
    this.pubDate,
    this.isbn,
    this.isbn10,
    this.pageCount,
  });

  factory CustomCourseBookEntity.fromJson(Map<String, dynamic> json) {
    return CustomCourseBookEntity(
      uid: json['uid'],
      title: json['title'],
      mode: json['mode'],
      recordId: json['recordId'],
      status: json['status'],
      tip: json['tip'],
      cover: json['cover'],
      coverUrl: json['coverUrl'],
      grade: json['grade'],
      difficulty: json['difficulty'],
      hasBook: json['hasBook'],
      author: json['author'],
      publisher: json['publisher'],
      pubDate: json['pubDate'],
      isbn: json['isbn'],
      isbn10: json['isbn10'],
      pageCount: json['pageCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'title': title,
      'mode': mode,
      'recordId': recordId,
      'status': status,
      'tip': tip,
      'cover': cover,
      'coverUrl': coverUrl,
      'grade': grade,
      'difficulty': difficulty,
      'hasBook': hasBook,
      'author': author,
      'publisher': publisher,
      'pubDate': pubDate,
      'isbn': isbn,
      'isbn10': isbn10,
      'pageCount': pageCount,
    };
  }
}
