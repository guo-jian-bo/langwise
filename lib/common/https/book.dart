import 'package:api/api.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:wise_http/wise_http.dart';

import '../../app/modules/management/dialog/manage_edit_book/manage_edit_book_level_model.dart';


class BookUtil {
  // 获取books
  static Future<ResponseEntity<ListResponseEntity<BookResponseEntity>>> fetchBooks({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/book/pages", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<ListResponseEntity<BookResponseEntity>>.fromJson(response,
        fromJson: (json) => ListResponseEntity<BookResponseEntity>.fromJson(json, fromJson: (json) => BookResponseEntity.fromJson(json)));
  }

  // 获取ISBN
  static Future<ResponseEntity<BookResponseEntity>> fetchIsbn({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/book/isbn/search", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<BookResponseEntity>.fromJson(response, fromJson: (json) => BookResponseEntity.fromJson(json));
  }

  // 创建
  static Future<ResponseEntity<BookResponseEntity>> create({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/book/create", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<BookResponseEntity>.fromJson(response, fromJson: (json) => BookResponseEntity.fromJson(json));
  }

  // 编辑
  static Future<ResponseEntity<BookResponseEntity>?> edit({required int uid, required RequestConfig config}) async {
    try {
      final rawHeader = config.headers ?? {};
      var response = await WiseHttp().request("/course-console/book/$uid/edit", Method.post,
          data: config.data,
          parameters: config.parameters,
          options: config.options,
          cancelToken: config.cancelToken,
          requireToken: config.requireToken,
          requireCache: config.requireCache,
          headers: rawHeader);
      return ResponseEntity<BookResponseEntity>.fromJson(response, fromJson: (json) => BookResponseEntity.fromJson(json));
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  // 获取level列表
  static Future<ResponseEntity<List<ManageEditBookLevelModel>>?> getLevelList({required RequestConfig config}) async {
    try {
      final rawHeader = config.headers ?? {};
      var response = await WiseHttp().request("/course-console/book/course/level", Method.post,
          data: config.data,
          parameters: config.parameters,
          options: config.options,
          cancelToken: config.cancelToken,
          requireToken: config.requireToken,
          requireCache: config.requireCache,
          headers: rawHeader);

      return ResponseEntity<List<ManageEditBookLevelModel>>.fromJson(response, fromJson: (json) => (json as List).map((e) => ManageEditBookLevelModel.fromJson(e)).toList());
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  // 绑定新的等级ID
  static Future<ResponseEntity<BookResponseEntity>?> bindNewLevelId({required int bookId, required int levelId, required RequestConfig config}) async {
    try {
      final rawHeader = config.headers ?? {};
      var response = await WiseHttp().request("/course-console/book/$bookId/relation/$levelId", Method.post,
          data: config.data,
          parameters: config.parameters,
          options: config.options,
          cancelToken: config.cancelToken,
          requireToken: config.requireToken,
          requireCache: config.requireCache,
          headers: rawHeader);
      return ResponseEntity<BookResponseEntity>.fromJson(response, fromJson: (json) => BookResponseEntity.fromJson(json));
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  // 分析书页
  static Future<ResponseEntity<String>?> analysis({required int bookId, required RequestConfig config}) async {
    try {
      final rawHeader = config.headers ?? {};
      var response = await WiseHttp().request("/course-console/book/$bookId/analysis/page/start", Method.post,
          data: config.data,
          parameters: config.parameters,
          options: config.options,
          cancelToken: config.cancelToken,
          requireToken: config.requireToken,
          requireCache: config.requireCache,
          headers: rawHeader);
      return ResponseEntity<String>.fromJson(response);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  // 书内页列表
  static Future<ResponseEntity<ListEntity<WordImageEntity>>> pages({required int bookId, required int chapterId, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/book/$bookId/chapter/$chapterId/page/list", Method.get,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<ListEntity<WordImageEntity>>.fromJson(response,
        fromJson: (json) => ListEntity<WordImageEntity>.fromJson(json, fromJson: (json) => WordImageEntity.fromJson(json)));
  }

  // 批量增删书内页
  static Future<ResponseEntity> batch({required int bookId, required int chapterId, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/book/$bookId/page/chapter/$chapterId/batch/edit", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity.fromJson(response);
  }

  // 确认
  static Future<ResponseEntity<String?>> confirm({required String uid, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/book/$uid/confirm/knowledge", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<String?>.fromJson(response);
  }

  // 章节管理
  static Future<ResponseEntity<Book>> chapter({required int bookId, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/book/$bookId/load/chapter", Method.get,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<Book>.fromJson(response, fromJson: (json) => Book.fromJson(json));
  }

  // 章节类型
  static Future<ResponseEntity<ResponseWrapper<ChapterType>>> chapterType({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/book/load/chapter/type/list", Method.get,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<ResponseWrapper<ChapterType>>.fromJson(response,
        fromJson: (json) => ResponseWrapper<ChapterType>.fromJson(json, fromJson: (json) => ChapterType.fromJson(json)));
  }

  // 关联单元
  static Future<ResponseEntity<String>?> relatedUnit({required int bookId, required int chapterId, required RequestConfig config}) async {
    try {
      final rawHeader = config.headers ?? {};
      var response = await WiseHttp().request("/course-console/book/$bookId/chapter/$chapterId/relation", Method.post,
          data: config.data,
          parameters: config.parameters,
          options: config.options,
          cancelToken: config.cancelToken,
          requireToken: config.requireToken,
          requireCache: config.requireCache,
          headers: rawHeader);
      return ResponseEntity<String>.fromJson(response);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  // 批量编辑章节
  static Future<ResponseEntity<String>> batchEditChapter({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/book/chapter/batch/edit", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<String>.fromJson(response);
  }

  // 新增单个章节
  static Future<ResponseEntity<String>?> addChapter({required RequestConfig config}) async {
    try {
      final rawHeader = config.headers ?? {};
      var response = await WiseHttp().request("/course-console/book/chapter/create", Method.post,
          data: config.data,
          parameters: config.parameters,
          options: config.options,
          cancelToken: config.cancelToken,
          requireToken: config.requireToken,
          requireCache: config.requireCache,
          headers: rawHeader);
      return ResponseEntity<String>.fromJson(response);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  // 删除单个章节
  static Future<ResponseEntity<String>?> deleteChapter({required chapterId, required RequestConfig config}) async {
    try {
      final rawHeader = config.headers ?? {};
      var response = await WiseHttp().request("/course-console/book/chapter/$chapterId/delete", Method.post,
          data: config.data,
          parameters: config.parameters,
          options: config.options,
          cancelToken: config.cancelToken,
          requireToken: config.requireToken,
          requireCache: config.requireCache,
          headers: rawHeader);
      return ResponseEntity<String>.fromJson(response);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  // 分割章节
  static Future<ResponseEntity<String>?> splitChapter({required bookId, required RequestConfig config}) async {
    try {
      final rawHeader = config.headers ?? {};
      var response = await WiseHttp().request("/course-console/book/$bookId/chapters/split", Method.post,
          data: config.data,
          parameters: config.parameters,
          options: config.options,
          cancelToken: config.cancelToken,
          requireToken: config.requireToken,
          requireCache: config.requireCache,
          headers: rawHeader);
      return ResponseEntity<String>.fromJson(response);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  // 提取正文
  static Future<ResponseEntity<String>?> extractText({required bookId, required RequestConfig config}) async {
    try {
      final rawHeader = config.headers ?? {};
      var response = await WiseHttp().request("/course-console/book/$bookId/chapters/extract/unit", Method.post,
          data: config.data,
          parameters: config.parameters,
          options: config.options,
          cancelToken: config.cancelToken,
          requireToken: config.requireToken,
          requireCache: config.requireCache,
          headers: rawHeader);
      return ResponseEntity<String>.fromJson(response);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  // 提取目录
  static Future<ResponseEntity<String>?> extractTableOfContents({required bookId, required RequestConfig config}) async {
    try {
      final rawHeader = config.headers ?? {};
      var response = await WiseHttp().request("/course-console/book/$bookId/chapters/extract/content", Method.post,
          data: config.data,
          parameters: config.parameters,
          options: config.options,
          cancelToken: config.cancelToken,
          requireToken: config.requireToken,
          requireCache: config.requireCache,
          headers: rawHeader);
      return ResponseEntity<String>.fromJson(response);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<ResponseEntity<BookResponseEntity>> changeStatus({required bookId, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/book/$bookId/edit/status", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<BookResponseEntity>.fromJson(response, fromJson: (json) => BookResponseEntity.fromJson(json));
  }
}

class BookAppUtil {
  // 获取ISBN
  static Future<ResponseEntity<BookResponseEntity>> fetchIsbn({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course/user/custom/isbn/info", Method.get,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<BookResponseEntity>.fromJson(response, fromJson: (json) => BookResponseEntity.fromJson(json));
  }

  // 创建
  static Future<ResponseEntity<AppCourseModuleResponseEntity>> create({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course/user/custom/course/book/create", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<AppCourseModuleResponseEntity>.fromJson(response, fromJson: (json) => AppCourseModuleResponseEntity.fromJson(json));
  }

  // 编辑
  static Future<ResponseEntity<AppCourseModuleResponseEntity>> edit({required int uid, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course/user/custom/course/module/$uid/edit", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<AppCourseModuleResponseEntity>.fromJson(response, fromJson: (json) => AppCourseModuleResponseEntity.fromJson(json));
  }

  // 书籍详情
  static Future<ResponseEntity<BookInfoResponseEntity>> info({required int uid, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course/user/custom/course/book/$uid/info", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<BookInfoResponseEntity>.fromJson(response, fromJson: (json) => BookInfoResponseEntity.fromJson(json));
  }

  // 批量增删书内页
  static Future<ResponseEntity<String>> batch({required int bookId, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course/user/custom/course/book/$bookId/page/batch/edit", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<String>.fromJson(response);
  }

  // 分析书页
  static Future<ResponseEntity<String?>> analysis({required int bookId, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course/user/custom/course/book/$bookId/analysis/page/start", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<String?>.fromJson(response);
  }
}
