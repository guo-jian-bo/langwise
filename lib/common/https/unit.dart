import 'dart:io';

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

  // 单元语法 Hub 数据
  static Future<ResponseEntity<ManageUnitGrammarHubEntity?>> unitGrammarHub({required String unitId, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/unit/$unitId/knowledge/grammar/list", Method.get,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<ManageUnitGrammarHubEntity?>.fromJson(response,
        fromJson: (json) => ManageUnitGrammarHubEntity.fromJson(json));
  }

  // 单元语法句子列表
  static Future<ResponseEntity<ManageUnitGrammarSentenceListEntity?>> unitGrammarSentences({required String unitId, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/unit/$unitId/knowledge/grammar/sentences", Method.get,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<ManageUnitGrammarSentenceListEntity?>.fromJson(response,
        fromJson: (json) => ManageUnitGrammarSentenceListEntity.fromJson(json));
  }

  // 单元语法 Target 详情
  static Future<ResponseEntity<ManageUnitGrammarTargetDetailEntity?>?> unitGrammarTargetDetail({required String unitId, required RequestConfig config}) async {
    try {
      final rawHeader = config.headers ?? {};
      final bool isManagement =
          config.parameters?['isManagement'] == true || config.parameters?['isManagement']?.toString() == 'true';
      final String targetUid = config.parameters?['targetUid']?.toString() ?? '';
      final String path = isManagement
          ? "/course-console/unit/$unitId/knowledge/grammar/targets/detail/v2"
          : "/course/course/write/unit/$unitId/target/$targetUid/detail";
      final Map<String, dynamic> parameters = isManagement
          ? Map<String, dynamic>.from(config.parameters ?? const {})
          : <String, dynamic>{};
      parameters.remove('isManagement');
      var response = await WiseHttp().request(path, Method.get,
          data: config.data,
          parameters: parameters,
          options: config.options,
          cancelToken: config.cancelToken,
          requireToken: config.requireToken,
          requireCache: config.requireCache,
          headers: rawHeader);
      return ResponseEntity<ManageUnitGrammarTargetDetailEntity?>.fromJson(response,
          fromJson: (json) => ManageUnitGrammarTargetDetailEntity.fromJson(json));
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  // 单元语法 Target 底部句组列表
  static Future<ResponseEntity<ListResponseEntity<ManageUnitGrammarTargetSentenceSetPageEntity>?>?> unitGrammarTargetSentenceSetPages({
    required String unitId,
    required RequestConfig config,
  }) async {
    try {
      final rawHeader = config.headers ?? {};
      final bool isManagement =
          config.parameters?['isManagement'] == true || config.parameters?['isManagement']?.toString() == 'true';
      final String targetUid = config.parameters?['targetUid']?.toString() ?? '';
      final String path = isManagement
          ? "/course-console/unit/$unitId/knowledge/grammar/target/sentence/realization/set/pages"
          : "/course/course/write/unit/$unitId/target/$targetUid/sentence/realization/set/pages";
      final Map<String, dynamic> parameters = Map<String, dynamic>.from(config.parameters ?? const {});
      parameters.remove('isManagement');
      if (!isManagement) {
        parameters.remove('targetUid');
      }
      var response = await WiseHttp().request(path, Method.get,
          data: config.data,
          parameters: parameters,
          options: config.options,
          cancelToken: config.cancelToken,
          requireToken: config.requireToken,
          requireCache: config.requireCache,
          headers: rawHeader);
      return ResponseEntity<ListResponseEntity<ManageUnitGrammarTargetSentenceSetPageEntity>?>.fromJson(
        response,
        fromJson: (json) => ListResponseEntity<ManageUnitGrammarTargetSentenceSetPageEntity>.fromJson(
          json,
          fromJson: (item) => ManageUnitGrammarTargetSentenceSetPageEntity.fromJson(
            Map<String, dynamic>.from(item),
          ),
        ),
      );
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  // 更新单元语法 Target 审核状态
  static Future<ResponseEntity<ManageUnitGrammarTargetStatusUpdateEntity?>?> updateUnitGrammarTargetStatus({required String unitId, required RequestConfig config}) async {
    try {
      final rawHeader = config.headers ?? {};
      var response = await WiseHttp().request("/course-console/unit/$unitId/knowledge/grammar/targets/status", Method.post,
          data: config.data,
          parameters: config.parameters,
          options: config.options,
          cancelToken: config.cancelToken,
          requireToken: config.requireToken,
          requireCache: config.requireCache,
          headers: rawHeader);
      return ResponseEntity<ManageUnitGrammarTargetStatusUpdateEntity?>.fromJson(response,
          fromJson: (json) => ManageUnitGrammarTargetStatusUpdateEntity.fromJson(json));
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  // 单点预览匹配库句
  static Future<ResponseEntity<ManageUnitGrammarMatchPreviewEntity?>?> previewUnitGrammarTargetMatch({required String unitId, required RequestConfig config}) async {
    try {
      final rawHeader = config.headers ?? {};
      var response = await WiseHttp().request("/course-console/unit/$unitId/knowledge/grammar/targets/actions/match-preview", Method.post,
          data: config.data,
          parameters: config.parameters,
          options: config.options,
          cancelToken: config.cancelToken,
          requireToken: config.requireToken,
          requireCache: config.requireCache,
          headers: rawHeader);
      return ResponseEntity<ManageUnitGrammarMatchPreviewEntity?>.fromJson(response,
          fromJson: (json) => ManageUnitGrammarMatchPreviewEntity.fromJson(json));
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  // 单点保存勾选句子
  static Future<ResponseEntity<ManageUnitGrammarAppendSelectedEntity?>?> appendUnitGrammarTargetSelectedSentences({required String unitId, required RequestConfig config}) async {
    try {
      final rawHeader = config.headers ?? {};
      var response = await WiseHttp().request("/course-console/unit/$unitId/knowledge/grammar/targets/actions/match-append-selected", Method.post,
          data: config.data,
          parameters: config.parameters,
          options: config.options,
          cancelToken: config.cancelToken,
          requireToken: config.requireToken,
          requireCache: config.requireCache,
          headers: rawHeader);
      return ResponseEntity<ManageUnitGrammarAppendSelectedEntity?>.fromJson(response,
          fromJson: (json) => ManageUnitGrammarAppendSelectedEntity.fromJson(json));
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  // 单点强制绑定句子
  static Future<String?> forceBindUnitGrammarTargetSentences({required String unitId, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/unit/$unitId/knowledge/grammar/targets/actions/force-bind",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );

      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return responseEntity.data.toString();
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      ToastUtils.showToast(text: '强制绑定句子失败');
      return null;
    }
  }

  // 单点按句型生成
  static Future<ResponseEntity<String>?> createUnitGrammarSentenceByPattern({required String unitId, required RequestConfig config}) async {
    try {
      final rawHeader = config.headers ?? {};
      var response = await WiseHttp().request("/course-console/unit/$unitId/knowledge/grammar/targets/actions/create-by-pattern", Method.post,
          data: config.data,
          parameters: config.parameters,
          options: config.options,
          cancelToken: config.cancelToken,
          requireToken: config.requireToken,
          requireCache: config.requireCache,
          headers: rawHeader);
      return ResponseEntity<String>.fromJson(response);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message, type: ToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  // 单点高阶加练
  static Future<ResponseEntity<String>?> createUnitGrammarSentenceByRelation({required String unitId, required RequestConfig config}) async {
    try {
      final rawHeader = config.headers ?? {};
      var response = await WiseHttp().request("/course-console/unit/$unitId/knowledge/grammar/targets/actions/create-by-relation", Method.post,
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

  // 从当前 Target 移除句子
  static Future<ResponseEntity<String>?> removeUnitGrammarTargetSentence({required String unitId, required RequestConfig config}) async {
    try {
      final rawHeader = config.headers ?? {};
      var response = await WiseHttp().request("/course-console/unit/$unitId/knowledge/grammar/targets/sentences/remove", Method.post,
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

  // 从单元内容里移除知识点，支持整单元删除或从目标解绑。
  static Future<ResponseEntity<String?>?> removeUnitKnowledgeContents({
    required String unitId,
    required RequestConfig config,
  }) async {
    try {
      final rawHeader = config.headers ?? {};
      var response = await WiseHttp().request(
        "/course-console/unit/$unitId/knowledge/remove/contents",
        Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader,
      );
      return ResponseEntity<String?>.fromJson(response);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(
        text: e.source.message,
        type: ManageToastType.error,
      );
      return null;
    } catch (e) {
      return null;
    }
  }

  // 从整个单元移除句子
  static Future<ResponseEntity<String?>?> removeUnitGrammarSentenceFromUnit({
    required String unitId,
    required RequestConfig config,
  }) async {
    try {
      final rawHeader = config.headers ?? {};
      var response = await WiseHttp().request(
        "/course-console/unit/$unitId/knowledge/remove",
        Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader,
      );
      return ResponseEntity<String?>.fromJson(response);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(
        text: e.source.message,
        type: ManageToastType.error,
      );
      return null;
    } catch (e) {
      return null;
    }
  }

  // 生成单元语法
  static Future<ResponseEntity<String>?> generateUnitGrammar({required String unitId, required RequestConfig config}) async {
    try {
      final rawHeader = config.headers ?? {};
      var response = await WiseHttp().request("/course-console/unit/$unitId/knowledge/grammar/actions/analyze", Method.post,
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

  // 已有句子绑定语法
  static Future<ResponseEntity<String>?> bindUnitGrammarTargets({required String unitId, required RequestConfig config}) async {
    try {
      final rawHeader = config.headers ?? {};
      var response = await WiseHttp().request("/course-console/unit/$unitId/knowledge/grammar/actions/bind-targets", Method.post,
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

  // 匹配库里已有句子
  static Future<ResponseEntity<dynamic>?> matchUnitGrammarDeficit({required String unitId, required RequestConfig config}) async {
    try {
      final rawHeader = config.headers ?? {};
      var response = await WiseHttp().request("/course-console/unit/$unitId/knowledge/grammar/actions/match-deficit", Method.post,
          data: config.data,
          parameters: config.parameters,
          options: config.options,
          cancelToken: config.cancelToken,
          requireToken: config.requireToken,
          requireCache: config.requireCache,
          headers: rawHeader);
      return ResponseEntity<dynamic>.fromJson(response);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  // 自动生成语法句子
  static Future<ResponseEntity<String>?> createUnitGrammarAuto({required String unitId, required RequestConfig config}) async {
    try {
      final rawHeader = config.headers ?? {};
      var response = await WiseHttp().request("/course-console/unit/$unitId/knowledge/grammar/actions/create-auto", Method.post,
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

  // 分析已绑定语法句子
  static Future<ResponseEntity<String>?> analyseBoundUnitGrammarSentences({required String unitId, required RequestConfig config}) async {
    try {
      final rawHeader = config.headers ?? {};
      var response = await WiseHttp().request("/course-console/unit/$unitId/knowledge/grammar/actions/analyse-bound-sentences", Method.post,
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

  // 分析指定 Target 下的已绑定句子结构
  static Future<ResponseEntity<String>?> analyseUnitGrammarSentence({required RequestConfig config}) async {
    try {
      final rawHeader = config.headers ?? {};
      var response = await WiseHttp().request("/course-console/grammar/sentence/analyse", Method.post,
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

  // 生成语法课
  static Future<ResponseEntity<String>?> generateUnitGrammarCourse({required String unitId, required RequestConfig config}) async {
    try {
      final rawHeader = config.headers ?? {};
      var response = await WiseHttp().request("/course-console/unit/$unitId/knowledge/grammar/actions/generate-course", Method.post,
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
