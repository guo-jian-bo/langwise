import 'package:api/api.dart';
import 'package:langwise/app/modules/management/manage_study/manage_book_scan/manage_book_word_list/manage_book_word_list_check_knowledge/models/manage_book_word_list_check_knowledge_response_entity.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:wise_http/wise_http.dart';

class UnitUtil {
  // 获取unit
  static Future<ResponseEntity<ListResponseEntity<NewUnitResponseEntity<MiniLessonResponseEntity>>>> fetchPages({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/course/unit/pages", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<ListResponseEntity<NewUnitResponseEntity<MiniLessonResponseEntity>>>.fromJson(response,
        fromJson: (json) => ListResponseEntity<NewUnitResponseEntity<MiniLessonResponseEntity>>.fromJson(json,
            fromJson: (json) => NewUnitResponseEntity<MiniLessonResponseEntity>.fromJson(json, fromJson: (json) => MiniModuleResponseEntity.fromJson(json))));
  }

  // 创建
  static Future<ResponseEntity<NewUnitResponseEntity<LessonResponseEntity>?>> create({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/course/unit/create", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<NewUnitResponseEntity<LessonResponseEntity>?>.fromJson(response,
        fromJson: (json) => NewUnitResponseEntity<LessonResponseEntity>.fromJson(json, fromJson: (json) => LessonResponseEntity.fromJson(json)));
  }

  // 复制
  static Future<ResponseEntity<NewUnitResponseEntity?>> copy({required String uid, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/course/unit/$uid/copy", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<NewUnitResponseEntity?>.fromJson(response, fromJson: (json) => NewUnitResponseEntity.fromJson(json));
  }

  // 编辑
  static Future<ResponseEntity<NewUnitResponseEntity?>?> edit({required String uid, required RequestConfig config}) async {
    try {
      final rawHeader = config.headers ?? {};
      var response = await WiseHttp().request("/course-console/course/unit/$uid/edit", Method.post,
          data: config.data,
          parameters: config.parameters,
          options: config.options,
          cancelToken: config.cancelToken,
          requireToken: config.requireToken,
          requireCache: config.requireCache,
          headers: rawHeader);
      return ResponseEntity<NewUnitResponseEntity?>.fromJson(response, fromJson: (json) => NewUnitResponseEntity.fromJson(json));
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  // 批量编辑
  static Future<ResponseEntity<ListEntity<UnitResponseEntity>>> batchEdit({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/course/unit/knowledge/edit/unit/batch", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);

    return ResponseEntity<ListEntity<UnitResponseEntity>>.fromJson(response,
        fromJson: (json) => ListEntity<UnitResponseEntity>.fromJson(json, fromJson: (json) => UnitResponseEntity.fromJson(json)));
  }

  //生成音频
  static Future<ResponseEntity<String>?> generateAudio({required String moduleId, required RequestConfig config}) async {
    try {
      final rawHeader = config.headers ?? {};
      var response = await WiseHttp().request("/course-console/course/module/$moduleId/generate/audio?knowledges", Method.post,
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

  // 生成单元计划
  static Future<ResponseEntity<String>?> generateUnitPlan({required unitId, required RequestConfig config}) async {
    try {
      final rawHeader = config.headers ?? {};
      var response = await WiseHttp().request("/course-console/book/unit/$unitId/plan", Method.post,
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

  //生成句子
  static Future<ResponseEntity<String>?> generateSentence({required unitId, required RequestConfig config}) async {
    try {
      final rawHeader = config.headers ?? {};
      var response = await WiseHttp().request("/course-console/book/unit/$unitId/sentence", Method.post,
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

  //生成课时计划
  static Future<ResponseEntity<String>?> generateLessonPlan({required unitId, required RequestConfig config}) async {
    try {
      final rawHeader = config.headers ?? {};
      var response = await WiseHttp().request("/course-console/book/unit/$unitId/lesson/plan", Method.post,
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

  //生成课时题目
  static Future<ResponseEntity<String>?> generateLessonTitle({required unitId, required RequestConfig config}) async {
    try {
      final rawHeader = config.headers ?? {};
      var response = await WiseHttp().request("/course-console/book/unit/$unitId/lesson/exercise", Method.post,
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

  //刷新单个课时计划
  static Future<ResponseEntity<String>?> refreshLessonPlan({required unitId, required lessonId, required RequestConfig config}) async {
    try {
      final rawHeader = config.headers ?? {};
      var response = await WiseHttp().request("/course-console/book/unit/$unitId/lesson/$lessonId/refresh", Method.post,
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

  // Module下所有单元的知识点详情
  static Future<ResponseEntity<ManageBookWordListCheckKnowledgeResponseEntity>> allKnowledgeInfo({required moduleId, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/course/module/$moduleId/unit/list", Method.get,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);

    return ResponseEntity<ManageBookWordListCheckKnowledgeResponseEntity>.fromJson(response, fromJson: (json) => ManageBookWordListCheckKnowledgeResponseEntity.fromJson(json));
  }

  //拖拽知识点后更新位置
  static Future<ResponseEntity<String>?> refreshKnowledge({required unitId, required knowledgeId, required RequestConfig config}) async {
    try {
      final rawHeader = config.headers ?? {};
      var response = await WiseHttp().request("/course-console/unit/$unitId/knowledge/$knowledgeId/drag/order", Method.post,
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

  //添加知识点到缓存区
  static Future<ResponseEntity<ManageBookWordListAddKnowledgeResponseEntity>?> addKnowledge({required moduleId, required RequestConfig config}) async {
    try {
      final rawHeader = config.headers ?? {};
      var response = await WiseHttp().request("/course-console/course/module/knowledge/$moduleId/add", Method.post,
          data: config.data,
          parameters: config.parameters,
          options: config.options,
          cancelToken: config.cancelToken,
          requireToken: config.requireToken,
          requireCache: config.requireCache,
          headers: rawHeader);
      return ResponseEntity<ManageBookWordListAddKnowledgeResponseEntity>.fromJson(response, fromJson: (json) => ManageBookWordListAddKnowledgeResponseEntity.fromJson(json));
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  // 单个单元的知识点详情
  static Future<ResponseEntity<KnowledgeInfo<Knowledge>>> knowledgeInfo({required unitId, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/course/unit/$unitId/knowledge/type/info", Method.get,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);

    return ResponseEntity<KnowledgeInfo<Knowledge>>.fromJson(response, fromJson: (json) => KnowledgeInfo<Knowledge>.fromJson(json, fromJson: (json) => Knowledge.fromJson(json)));
  }

  // 单元课时列表
  static Future<ResponseEntity<NewUnitResponseEntity<LessonResponseEntity>?>> lessonList({required unitId, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/course/unit/$unitId/lesson/list", Method.get,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<NewUnitResponseEntity<LessonResponseEntity>?>.fromJson(response,
        fromJson: (json) => NewUnitResponseEntity<LessonResponseEntity>.fromJson(json, fromJson: (json) => LessonResponseEntity.fromJson(json)));
  }

  // 删除单元下的知识点单元
  static Future<ResponseEntity<String?>> deleteKnowledge({required unitId, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/unit/$unitId/knowledge/remove", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<String?>.fromJson(response);
  }

  // 知识点解除绑定
  static Future<ResponseEntity<String?>> revokeMatchKnowledge({required unitId, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/unit/$unitId/knowledge/match/revoke", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<String?>.fromJson(response);
  }

  // 知识点绑定
  static Future<ResponseEntity<String?>> confirmMatchKnowledge({required unitId, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/unit/$unitId/knowledge/match/confirm", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<String?>.fromJson(response);
  }

  // 自动匹配知识点
  static Future<ResponseEntity<String?>> autoMatchKnowledge({required String bookId, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/book/$bookId/match/batch", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<String?>.fromJson(response);
  }

  // 编辑知识点
  static Future<ResponseEntity<UnitResponseEntity?>> editKnowledgeDetail({required unitId, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/unit/$unitId/knowledge/edit/detail", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<UnitResponseEntity?>.fromJson(response, fromJson: (json) => UnitResponseEntity.fromJson(json));
  }

  /// 更新释义
  static Future<ResponseEntity<String?>> editKnowledgeSemantic({required unitId, required knowledgeId, required semanticId, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/unit/$unitId/knowledge/$knowledgeId/edit/semantic/$semanticId", Method.post,
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

class UnitAppUtil {
  // 创建
  static Future<ResponseEntity<AppUnitResponseEntity>> create({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course/user/custom/course/unit/create", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<AppUnitResponseEntity>.fromJson(response, fromJson: (json) => AppUnitResponseEntity.fromJson(json));
  }

  // 编辑
  static Future<ResponseEntity<AppUnitResponseEntity>> edit({required int uid, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course/user/custom/course/unit/$uid/edit", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<AppUnitResponseEntity>.fromJson(response, fromJson: (json) => AppUnitResponseEntity.fromJson(json));
  }

  // 课程单元知识点排序
  static Future<ResponseEntity<String?>> orderKnowledge({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course/user/custom/course/unit/knowledge/order", Method.post,
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
