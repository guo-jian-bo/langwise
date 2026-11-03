

import 'package:get/get.dart';

import '../../../../common/entities/entities.dart';
import '../controllers/manage_admin_auth_controller.dart';

class ManageAuthUtils{

  static final ManageAuthController _controller = Get.find<ManageAuthController>();

  /// 初始化
  static Future<bool> init() async{
    return await _controller.getAdminAuth();
  }


  /// 根据code[ManageAuthCode]查询是否有权限
  static bool isAuth(String code){
    List<AdminAuthEntityRoutes> list = _controller.authRoutes.toList();
    for(var item in list){
      String? url = item.url;
      if(url == null || url.isEmpty) continue;
      if(url == code){
        return true;
      }
    }
    return false;
  }

  /// 根据codes[ManageAuthCode]查询是否有权限（需要全部匹配）
  static bool isAuths(List<String> codes){
    List<AdminAuthEntityRoutes> list = _controller.authRoutes.toList();
    if(codes.isEmpty) return false;
    Set<String> authUrls = list.map((e) => e.url ?? '').where((url) => url.isNotEmpty).toSet();
    for(var code in codes){
      if(!authUrls.contains(code)){
        return false;
      }
    }
    return true;
  }

  /// 根据codes[ManageAuthCode]查询是否有任一权限
  static bool isAnyAuth(List<String> codes){
    List<AdminAuthEntityRoutes> list = _controller.authRoutes.toList();
    if(codes.isEmpty) return false;
    Set<String> authUrls = list.map((e) => e.url ?? '').where((url) => url.isNotEmpty).toSet();
    for(var code in codes){
      if(authUrls.contains(code)){
        return true;
      }
    }
    return false;
  }


}


class ManageAuthCode{

  // ==================== 管理员模块 ====================
  /// 查找部门下成员
  static const String adminDepartmentUserList = "GET:/admin/department/{departmentId}/user/list";
  /// 编辑用户
  static const String adminUserEdit = "POST:/admin/user/{uid}/edit";
  /// 管理员列表
  static const String adminUserPage = "POST:/admin/user/page";
  /// 添加用户
  static const String adminUserAdd = "POST:/admin/user/add";
  /// 删除用户
  static const String adminUserRemove = "POST:/admin/user/{uid}/remove";
  /// 获取OSS上传token
  static const String adminToken = "POST:/admin/token";
  /// 角色详情
  static const String adminRoleDetail = "GET:/admin/role/{uid}/detail";
  /// 自身所有路由权限
  static const String adminRoleSelfRouteList = "GET:/admin/role/self/route/list";
  /// 自身所有角色
  static const String adminRoleSelfList = "GET:/admin/role/self/list";
  /// 角色列表
  static const String adminRolePage = "POST:/admin/role/page";
  /// 创建角色
  static const String adminRoleAdd = "POST:/admin/role/add";
  /// 编辑角色
  static const String adminRoleUpdate = "POST:/admin/role/{uid}/update";
  /// 部门列表
  static const String adminDepartmentPage = "POST:/admin/department/page";
  /// 创建部门
  static const String adminDepartmentAdd = "POST:/admin/department/add";
  /// 删除部门
  static const String adminDepartmentRemove = "POST:/admin/department/{uid}/remove";
  /// 操作记录
  static const String adminUserLogPages = "POST:/admin/user/log/pages";

  // ==================== 课程管理模块 ====================
  /// 课程
  static const String coursePages = "POST:/course/pages";
  /// 等级
  static const String courseLevelPages = "POST:/course/level/pages";
  /// 模块
  static const String courseModulePages = "POST:/course/module/pages";
  /// 单元
  static const String courseUnitPages = "POST:/course/unit/pages";
  /// 课时
  static const String courseLessonPages = "POST:/course/lesson/pages";
  /// 课时模版
  static const String courseLessonTemplatePages = "POST:/course/lesson/template/pages";
  /// 题目
  static const String exercisePage = "POST:/exercise/page";
  /// 题目模版
  static const String exerciseTemplateList = "GET:/exercise/template/list";
  /// 超记题目列表
  static const String superMemoExerciseNeedResolvePages = "POST:/super/memo/exercise/need/resolve/pages";
  /// 题目配置
  static const String courseLessonTemplateConfigPages = "POST:/course/lesson/template/config/pages";

  /// 音频
  static const String accentList = "POST:/accent/list";
  /// 单词
  static const String enWordPages = "POST:/en/word/pages";
  /// 短语
  static const String enPhrasePages = "POST:/en/phrase/pages";
  /// 句子
  static const String enSentencePages = "POST:/en/sentence/pages";
  /// 文章
  static const String enTextPages = "POST:/en/text/pages";
  /// 歌曲
  static const String enSongPages = "POST:/en/song/pages";
  /// 专栏
  static const String enRevealsPages = "POST:/en/reveals/pages";

  /// 图片审核 - 删除任务
  static const String contentReviewImageTaskFail = "POST:/admin/content/review/image/task/fail";
  /// 图片审核 - 重新生成图片
  static const String contentReviewImageRegenerateV2 = "POST:/admin/content/review/image/regenerate/v2";
  /// 图片审核 - 重新生成提示词prompt
  static const String contentReviewLoadPromptV3 = "POST:/admin/content/review/load/prompt/v3";
  /// 图片审核 - 图片审核统计
  static const String contentReviewImageAuditStatistics = "POST:/admin/content/review/image/audit/statistics";
  /// 图片审核 - 审核历史
  static const String contentReviewImageAuditHistory = "POST:/admin/content/review/image/audit/history";

  /// 查询创建图片页信息
  static const String contentReviewImageCreateInfo = "POST:/admin/content/review/image/create/page/info";

  /// 书籍列表
  static const String bookPages = "POST:/book/pages";

  /// 编辑题目
  static const String exerciseEdit = "POST:/exercise/edit";
  /// 删除题目
  static const String exerciseDelete = "POST:/exercise/review/delete";
  /// 重新生成
  static const String exerciseRegenerate = "POST:/exercise/review/regenerate";
  /// 审核题目 - 审核统计
  static const String exerciseReviewStatistics = "POST:/exercise/review/statistics";
  /// 审核题目 - 审核历史
  static const String exerciseReviewHistory = "POST:/exercise/review/history";
  /// 查询题目类型列表
  static const String exerciseTypeList = "GET:/exercise/exerciseType/list";
  


  /// 单词 - 删除单词
  static const String enWordDelete  = "GET:/en/word/{uid}/delete";
  /// 单词 - 删除单词语义
  static const String enWordSemanticDelete = "POST:/en/word/semantic/{uid}/delete";
  /// 单词 - 编辑单词语义
  static const String enWordSemanticEdit = "POST:/en/word/semantic/{uid}/edit";
  /// 单词 - 编辑单词
  static const String enWordEdit = "POST:/en/word/{uid}/edit";
  /// 单词 - 关联语义 
  static const String enWordEditSemanticAdd = "POST:/en/word/{uid}/semantic/add";

  /// 短语 - 删除单词
  static const String enPhraseDelete  = "GET:/en/phrase/{uid}/delete";
  /// 短语 - 删除单词语义
  static const String enPhraseSemanticDelete = "POST:/en/phrase/semantic/{uid}/delete";
  /// 短语 - 编辑
  static const String enPhraseEdit = "POST:/en/phrase/{uid}/edit";

  /// 查询语义列表
  static const String enContentSemanticList = "POST:/en/content/semantic/list";
  /// 加载知识点图片
  static const String adminContentReviewKnowledgeImages = "POST:/admin/content/review/knowledge/images";
  ///加载题目的课程信息
  static const String unitKnowledgeCourseInfos = "POST:/unit/{unitId}/knowledge/course/infos";

  /// 图片定稿
  static const String contentReviewImageLock = "POST:/admin/content/review/image/lock";
  /// 图片解锁定稿
  static const String contentReviewImageUnlock = "POST:/admin/content/review/image/unlock";

  /// 图片裁剪
  static const String adminContentReviewImageCrop = "POST:/admin/content/review/image/crop";
  /// 撤销裁剪
  static const String adminContentReviewImageCropUndo = "POST:/admin/content/review/image/crop/undo";

  /// 查询短语/句子/文章/歌曲音频管理
  static const String audioExpressQuery = "POST:/audio/express/query";
  /// 单词音频管理
  static const String audioWordIpaQuery = "POST:/audio/word/{contentId}/ipa/query";
  /// 匹配或创建单词
  static const String enWordMatchDetail = "POST:/en/word/match/detail";
  /// 查看知识点创建历史
  static const String enContentKnowledgeCreateHistory = "POST:/en/content/knowledge/create/history";
  /// 生成单词/短语/句子/文章/歌曲音频
  static const String audioGenerate = "POST:/audio/generate";
  /// 编辑单词发音
  static const String audioWordEdit = "POST:/audio/word/edit";
  /// 发布/取消发布单词
  static const String audioWordIpaPublish = "POST:/audio/word/{contentId}/ipa/{ipaId}/publish";
  /// 查询题目
  static const String audioWordExerciseList = "POST:/en/word/exercise/list";
  /// 标识音节
  static const String audioWordBlockMark = "POST:/audio/word/block/mark";
  /// AI划分
  static const String audioSoundBlocks = "POST:/audio/sound_blocks";
  /// 发布/取消发布音节
  static const String audioWordIpaBlockPublish = "POST:/audio/word/ipa/{ipaId}/block/{soundBlockId}/publish";
  /// 编辑单词音节
  static const String audioWordBlockEdit = "POST:/audio/word/block/edit";
  /// 生成音素音频
  static const String audioPhoneme = "POST:/audio/phoneme";
  /// 自定义生成音频
  static const String audioCustomGenerate = "POST:/audio/custom/generate";

  /// 创建或匹配短语
  static const String enPhraseMatchDetail = "POST:/en/phrase/match/detail";

  /// 查询核心知识点
  static const String enContentKnowledgeList = "POST:/en/content/knowledge/list";

  /// 用户人群管理
  static const String apiTagsParamsList = "POST:/api/tags/params/list";

  // ==================== 电子书管理模块 ====================
  /// 绘本列表
  static const String ebookPage = "POST:/ebook/page";
  /// 添加绘本模块
  static const String ebookAddModule = "POST:/ebook/add/module/{ebookId}";
  /// 修改绘本模块
  static const String ebookUpdateModule = "POST:/ebook/update/module/{uid}";
  /// 媒体新增绘本
  static const String ebookMediaCreate = "POST:/ebook/media/create";
  /// 修改Cefr等级
  static const String ebookUpdateCefr = "POST:/ebook/update/cefr/{uid}";
  /// 删除绘本模块
  static const String ebookDeleteModule = "POST:/ebook/delete/module/{uid}";
  /// 修改全局排序
  static const String ebookUpdateSortOrder = "POST:/ebook/update/sort-order/{uid}";
  /// 获取所有trackId不为空的电子绘本
  static const String ebookGetAllTrack = "POST:/ebook/get/all/track";
  /// 所有绘本模块
  static const String ebookFindModuleAll = "GET:/ebook/find/module/all";
  /// 查询绘本的核心题目
  static const String ebookFindQuestionType = "POST:/ebook/find/question/type";
  /// 编辑绘本核心题目
  static const String ebookQuestionEditType = "POST:/ebook/question/edit/type";
  /// 修改绘本
  static const String ebookUpdate = "POST:/ebook/{uid}/update";
  /// 查询绘本模块
  static const String ebookFindModule = "POST:/ebook/find/module/{ebookId}";
  /// 新增绘本
  static const String ebookCreate = "POST:/ebook/create";
  /// 编辑套系
  static const String ebookSeriesEdit = "POST:/ebook/series/{uid}/edit";
  /// 套系列表
  static const String ebookSeriesPages = "POST:/ebook/series/pages";
  /// 创建套系
  static const String ebookSeriesCreate = "POST:/ebook/series/create";
  /// 查询绘本页码内容
  static const String ebookPageFindPageIdx = "POST:/ebook/page/find/pageIdx";
  /// 批量添加分页
  static const String ebookPageBatchAdd = "POST:/ebook/page/{ebookId}/batch/add";
  /// 删除分页
  static const String ebookPageBatchRemove = "POST:/ebook/page/batch/remove";
  /// 添加分页
  static const String ebookPageAdd = "POST:/ebook/page/{ebookId}/add";
  /// 修改分页
  static const String ebookPageUpdate = "POST:/ebook/page/{uid}/update";
  /// 分页列表
  static const String ebookPageList = "POST:/ebook/page/list";
  /// 添加分级
  static const String ebookLevelAdd = "POST:/ebook/level/add";
  /// 分级列表
  static const String ebookLevelPage = "POST:/ebook/level/page";
  /// 根据专辑获取分级
  static const String ebookLevelAlbumCate = "POST:/ebook/level/album/{albumId}/cate";
  /// 修改分级
  static const String ebookLevelUpdate = "POST:/ebook/level/{uid}/update";
  /// 媒体字幕添加OCR
  static const String ebookOcrMediaSentenceInsert = "POST:/ebook/ocr/media/sentence/insert";
  /// 修改ocr
  static const String ebookOcrSave = "POST:/ebook/ocr/save";
  /// 分析绘本单词
  static const String ebookSplitSentenceWords = "POST:/ebook/split/sentence/words";
  /// 重置句子
  static const String ebookOcrRemove = "POST:/ebook/ocr/{ocrId}/remove";

  // ==================== 资源管理模块 ====================
  /// 资源分类编辑
  static const String materialCategoryEdit = "POST:/materialCategory/{uid}/edit";
  /// 资源分类列表
  static const String materialCategoryPage = "POST:/materialCategory/page";
  /// 资源分类创建
  static const String materialCategoryCreate = "POST:/materialCategory/create";
  /// 资源专辑编辑
  static const String albumEdit = "POST:/album/{uid}/edit";
  /// 资源专辑列表
  static const String albumPage = "POST:/album/page";
  /// 资源专辑创建
  static const String albumCreate = "POST:/album/create";
  /// 资源标签编辑
  static const String materialTagEdit = "POST:/materialTag/{uid}/edit";
  /// 资源标签列表
  static const String materialTagPage = "POST:/materialTag/page";
  /// 资源标签创建
  static const String materialTagCreate = "POST:/materialTag/create";

  // ==================== 媒体管理模块 ====================
  /// 专辑关联编辑
  static const String albumRelationEdit = "POST:/album/relation/edit";
  /// 编辑专辑媒体排序
  static const String albumRelationOrderUpdate = "POST:/album/relation/order/update";
  /// 专辑关联列表
  static const String albumRelationPages = "POST:/album/relation/pages";
  /// 专辑关联创建
  static const String albumRelationCreate = "POST:/album/relation/create";
  /// 媒体视频列表
  static const String videoTrackPage = "POST:/videoTrack/page";
  /// 媒体编辑
  static const String mediaEdit = "POST:/media/{mediaId}/edit";
  /// 批量创建音频媒体
  static const String mediaAudioMultiCreate = "POST:/media/audio/multi/create";
  /// 批量创建视频媒体
  static const String mediaVideoMultiCreate = "POST:/media/video/multi/create";
  /// 媒体列表
  static const String mediaPage = "POST:/media/page";
  /// 媒体创建
  static const String mediaCreate = "POST:/media/create";
  /// 媒体音频列表
  static const String audioTrackPage = "POST:/audioTrack/page";
  /// 媒体CEFR等级评估编辑
  static const String mediaCefrLevelAssessmentEdit = "POST:/media/cefr/level/assessment/{uid}/edit";
  /// 媒体CEFR等级评估列表
  static const String mediaCefrLevelAssessmentPage = "POST:/media/cefr/level/assessment/page";
  /// 媒体CEFR等级评估创建
  static const String mediaCefrLevelAssessmentCreate = "POST:/media/cefr/level/assessment/create";
  /// 音频单词列表
  static const String wordTrackKnowledgePage = "POST:/word/track/knowledge/page";
  /// 音频单词删除
  static const String wordTrackKnowledgeDelete = "POST:/word/track/knowledge/{uid}/delete";
  /// 音频单词批量添加
  static const String wordTrackKnowledgeMultiCreate = "POST:/word/track/knowledge/multi/create";
  /// 音频单词创建
  static const String wordTrackKnowledgeCreate = "POST:/word/track/knowledge/create";
  /// 媒体题目列表
  static const String mediaKnowledgeQuestionPages = "POST:/media/knowledge/question/pages";
  /// 添加媒体题目
  static const String mediaKnowledgeQuestionAdd = "POST:/media/knowledge/question/add";
  /// 移除媒体题目
  static const String mediaKnowledgeQuestionRemove = "POST:/media/knowledge/question/remove";
  /// 编辑媒体题目信息
  static const String mediaKnowledgeQuestionEdit = "POST:/media/knowledge/question/{uid}/edit";
  /// 批量编辑题目专题
  static const String mediaKnowledgeQuestionEditBatch = "POST:/media/knowledge/question/edit/batch";
  /// 字幕编辑
  static const String mediaLyricSentenceEdit = "POST:/media/lyric/sentence/{uid}/edit";
  /// 导入SRT
  static const String mediaLyricSentenceImportSrtCreate = "POST:/media/lyric/sentence/import/srt/create";
  /// 批量拆句
  static const String mediaLyricSentenceSplitEdit = "POST:/media/lyric/sentence/split/edit";
  /// 批量设置广告
  static const String mediaLyricSentenceUpdateAdList = "POST:/media/lyric/sentence/update/ad/list";
  /// 生成字幕
  static const String mediaLyricSentenceMediaLyricCreate = "POST:/media/lyric/sentence/media/{mediaId}/lyric/create";
  /// 字幕列表
  static const String mediaLyricSentencePage = "POST:/media/lyric/sentence/page";
  /// 字幕创建
  static const String mediaLyricSentenceCreate = "POST:/media/lyric/sentence/create";
  /// 音频语法资源列表
  static const String grammarTrackKnowledgePage = "POST:/grammar/track/knowledge/page";
  /// 音频语法资源删除
  static const String grammarTrackKnowledgeDelete = "POST:/grammar/track/knowledge/{uid}/delete";
  /// 音频语法资源创建
  static const String grammarTrackKnowledgeCreate = "POST:/grammar/track/knowledge/create";
  /// 编辑音频
  static const String mediaEditTrack = "POST:/media/{mediaId}/edit/track";
  /// 需处理过的列表
  static const String mediaUntreatedPage = "POST:/media/untreated/page";
  /// 生成所有字幕文件
  static const String mediaLyricSentenceAllGenerateLyricMessage = "POST:/media/lyric/sentence/all/generate/lyric/message";
  /// 查询媒体所有句子
  static const String mediaLyricSentenceAll = "POST:/media/lyric/sentence/all";
  /// 同步知识库单词
  static const String mediaSyncLyricSentenceWord = "POST:/media/sync/Lyric/sentence/word";

  // ==================== 知识库管理模块 ====================
  /// 英语语法列表
  static const String grammarEnPage = "POST:/grammar/en/page";
  /// 创建英语语法
  static const String grammarEnCreate = "POST:/grammar/en/create";
  /// 编辑英语语法
  static const String grammarEnEdit = "POST:/grammar/en/{uid}/edit";
  /// 题库编辑
  static const String knowledgeQuestionBankEdit = "POST:/knowledge/question/bank/{uid}/edit";
  /// 题库列表
  static const String knowledgeQuestionBankPages = "POST:/knowledge/question/bank/pages";
  /// 题库添加
  static const String knowledgeQuestionBankAdd = "POST:/knowledge/question/bank/add";
  /// 根据uid获取问题题目详情信息
  static const String knowledgeQuestionBankDetail = "GET:/knowledge/question/bank/{uid}";
  /// 英文单词考级级别编辑
  static const String knowledgeEnWordExamLevelEdit = "POST:/knowledge/en/word/exam/level/{uid}/edit";
  /// 英文单词考级级别列表
  static const String knowledgeEnWordExamLevelPages = "POST:/knowledge/en/word/exam/level/pages";
  /// 导入单词考级级别
  static const String knowledgeEnWordExamLevelImport = "POST:/knowledge/en/word/exam/level/import/exam/level";
  /// 英文单词考级级别创建
  static const String knowledgeEnWordExamLevelCreate = "POST:/knowledge/en/word/exam/level/create";
  /// 英文单词主题编辑
  static const String knowledgeEnWordThemeEdit = "POST:/knowledge/en/word/theme/{uid}/edit";
  /// 英文单词主题列表
  static const String knowledgeEnWordThemePages = "POST:/knowledge/en/word/theme/pages";
  /// 英文单词主题创建
  static const String knowledgeEnWordThemeCreate = "POST:/knowledge/en/word/theme/create";
  /// 字素列表
  static const String morphemeKnowledgePointPages = "POST:/morpheme/knowledge/point/pages";
  /// 字素更新
  static const String morphemeKnowledgePointUpdate = "POST:/morpheme/knowledge/point/{uid}/update";
  /// 字素添加
  static const String morphemeKnowledgePointCreate = "POST:/morpheme/knowledge/point/create";
  /// 英语单词关联有道列表
  static const String wordKnowledgePointEnYoudaoPage = "POST:/word/knowledge/point/en/youdao/page";
  /// 英文字典列表
  static const String wordKnowledgePointEnPage = "POST:/word/knowledge/point/en/page";
  /// 创建英语词典
  static const String wordKnowledgePointEnCreate = "POST:/word/knowledge/point/en/create";
  /// 编辑英语词典
  static const String wordKnowledgePointEnEdit = "POST:/word/knowledge/point/en/{uid}/edit";
  /// 英文释义列表
  static const String wordKnowledgePointEnWordDefinitionPage = "POST:/word/knowledge/point/en/word/definition/page";
  /// 英语字音列表
  static const String wordKnowledgePointEnWordAudioPage = "POST:/word/knowledge/point/en/word/audio/page";
  /// 批量创建英语单词音频
  static const String wordKnowledgePointEnWordAudioBatchCreate = "POST:/word/knowledge/point/en/word/audio/batch/create";
  /// 英语句子音频列表
  static const String wordKnowledgePointEnWordDefinitionAudioPage = "POST:/word/knowledge/point/en/word/definition/audio/page";
  /// 英语句子音频创建
  static const String wordKnowledgePointEnWordDefinitionAudioCreate = "POST:/word/knowledge/point/en/word/definition/audio/create";
  /// 批量创建英语句子音频
  static const String wordKnowledgePointEnWordDefinitionAudioBatchCreate = "POST:/word/knowledge/point/en/word/definition/audio/batch/create";
  /// 创建英语单词音频
  static const String wordKnowledgePointEnWordAudioCreate = "POST:/word/knowledge/point/en/word/audio/create";
  /// 编辑英语字音
  static const String wordKnowledgePointEnWordAudioEdit = "POST:/word/knowledge/point/en/word/audio/{uid}/edit";
  /// 编辑有道关联
  static const String wordKnowledgePointEnYoudaoEdit = "POST:/word/knowledge/point/en/{uid}/youdao/edit";
  /// 移除有道释义
  static const String wordKnowledgePointEnYoudaoRemove = "POST:/word/knowledge/point/en/{uid}/youdao/remove";
  /// 英语句子音频编辑
  static const String wordKnowledgePointEnWordDefinitionAudioEdit = "POST:/word/knowledge/point/en/word/definition/audio/{uid}/edit";
  /// 移除有道释义批量
  static const String wordKnowledgePointEnYoudaoRemoveBatch = "POST:/word/knowledge/point/en/youdao/remove/batch";
  /// 隐藏释义批量
  static const String wordKnowledgePointEnYoudaoHideBatch = "POST:/word/knowledge/point/en/youdao/hide/batch";
  /// 确认有道释义
  static const String wordKnowledgePointEnYoudaoConfirm = "POST:/word/knowledge/point/en/{uid}/youdao/confirm";
  /// CEFR等级列表
  static const String cefrLevelPage = "POST:/cefr/level/page";
  /// 测评等级详情
  static const String cefrLevelDetail = "GET:/cefr/level/detail/{uid}";
  /// 修改CEFR等级
  static const String cefrLevelEdit = "PUT:/cefr/level/{uid}/edit";
  /// 删除测评等级
  static const String cefrLevelDelete = "DELETE:/cefr/level/delete/{uid}";
  /// 添加CEFR等级
  static const String cefrLevelCreate = "POST:/cefr/level/create";
  /// 知识媒体编辑
  static const String knowledgeMediaEdit = "POST:/knowledge/media/{uid}/edit";
  /// 知识媒体列表
  static const String knowledgeMediaPages = "POST:/knowledge/media/pages";
  /// 知识媒体创建
  static const String knowledgeMediaCreate = "POST:/knowledge/media/create";
  /// 题库推送到已审核题库
  static const String assessmentPushedQuestionsBatchCreate = "POST:/assessmentPushedQuestions/batch/create";
  /// 已审核测评题列表
  static const String assessmentPushedQuestionsPage = "POST:/assessmentPushedQuestions/page";
  /// 编辑已审核的题目
  static const String assessmentPushedQuestionsUpdate = "POST:/assessmentPushedQuestions/{uid}/update";
  /// 创建已审核测评题
  static const String assessmentPushedQuestionsCreate = "POST:/assessmentPushedQuestions/create";
  /// 考核方向编辑
  static const String knowledgeAssessDirectEdit = "POST:/knowledge/assess/direct/{uid}/edit";
  /// 考核方向列表
  static const String knowledgeAssessDirectPages = "POST:/knowledge/assess/direct/pages";
  /// 考核方向添加
  static const String knowledgeAssessDirectAdd = "POST:/knowledge/assess/direct/add";
  /// 题目形式编辑
  static const String knowledgeQuestionBankTypeEdit = "POST:/knowledge/question/bank/type/{uid}/edit";
  /// 题目形式列表
  static const String knowledgeQuestionBankTypePages = "POST:/knowledge/question/bank/type/pages";
  /// 题目形式添加
  static const String knowledgeQuestionBankTypeAdd = "POST:/knowledge/question/bank/type/add";

  // ==================== 语言/发音模块 ====================
  /// 音频列表
  static const String accentListV2 = "POST:/accent/list";
  /// 查询单词音频管理
  static const String audioWordIpaQueryV2 = "POST:/audio/word/{contentId}/ipa/query";
  /// 编辑单词发音V2
  static const String audioWordEditV2 = "POST:/audio/word/edit";
  /// 发布/取消发布单词
  static const String audioWordIpaPublishV2 = "POST:/audio/word/{contentId}/ipa/{ipaId}/publish";
  /// 标识音节
  static const String audioWordBlockMarkV2 = "POST:/audio/word/block/mark";
  /// 发布/取消发布音节
  static const String audioWordIpaBlockPublishV2 = "POST:/audio/word/ipa/{ipaId}/block/{soundBlockId}/publish";
  /// 编辑单词音节
  static const String audioWordBlockEditV2 = "POST:/audio/word/block/edit";
  /// 查询短语/句子/文章/歌曲音频管理
  static const String audioExpressQueryV2 = "POST:/audio/express/query";
  /// 编辑短语/句子/文章/歌曲
  static const String audioExpressEdit = "POST:/audio/express/edit";
  /// 删除短语/句子/文章/歌曲
  static const String audioExpressDelete = "GET:/audio/express/{expressId}/delete";
  /// AI划分
  static const String audioSoundBlocksV2 = "POST:/audio/sound_blocks";

  // ==================== 英语单词模块 ====================
  /// 删除
  static const String enWordDeleteV2 = "GET:/en/word/{uid}/delete";
  /// 编辑单词语义
  static const String enWordSemanticEditV2 = "POST:/en/word/semantic/{uid}/edit";
  /// 列表
  static const String enWordPagesV2 = "POST:/en/word/pages";
  /// 编辑
  static const String enWordEditV2 = "POST:/en/word/{uid}/edit";
  /// 查询题目
  static const String enWordExerciseList = "POST:/en/word/exercise/list";
  /// 匹配或创建单词
  static const String enWordMatchDetailV2 = "POST:/en/word/match/detail";
  /// 获取内容统计
  static const String enWordStatistics = "GET:/en/word/statistics";
  /// 清洗enword的accentIds
  static const String enWordAccentIdsClean = "GET:/en/word/accentIds/clean";
  /// 删除单词语义
  static const String enWordSemanticDeleteV2 = "POST:/en/word/semantic/{uid}/delete";
  /// 单词关联其他语义
  static const String enWordSemanticAddV2 = "POST:/en/word/{uid}/semantic/add";
  /// 查询语义列表
  static const String enWordSemanticList = "POST:/en/word/semantic/list";
  /// 获取知识点列表图片prompt
  static const String enWordContentImageList = "POST:/en/word/content/image/list";
  /// 获取单词原型
  static const String enWordLemmaWord = "GET:/en/word/lemma/word";
  /// 创建(已废弃)
  static const String enWordCreate = "POST:/en/word/create";
  /// 重新生成知识点列表图片prompt
  static const String enWordRegenerateContentImagePrompt = "POST:/en/word/regenerate/content/image/prompt";
  /// 重新生成单词的音频
  static const String enWordContentAudioReGenerate = "GET:/en/word/content/audio/re/generate";
  /// 洗ipa数据audio_word_ipa到audio_ipa
  static const String enWordIpaSync = "GET:/en/word/ipa/sync";
  /// 列表V2
  static const String enWordPagesV3 = "POST:/en/word/pages/v2";

  // ==================== 语素模块 ====================
  /// 创建
  static const String enMorphemeCreate = "POST:/en/morpheme/create";
  /// 编辑
  static const String enMorphemeEdit = "POST:/en/morpheme/{uid}/edit";
  /// 列表
  static const String enMorphemePages = "POST:/en/morpheme/pages";

  // ==================== 内容管理模块 ====================
  /// 编辑核心知识点
  static const String enContentKnowledgeOperation = "POST:/en/content/knowledge/{operation}";
  /// 查询创建知识点历史
  static const String enContentKnowledgeCreateHistoryV2 = "POST:/en/content/knowledge/create/history";
  /// 查询核心知识点
  static const String enContentKnowledgeListV2 = "POST:/en/content/knowledge/list";
  /// 查询语义列表
  static const String enContentSemanticListV2 = "POST:/en/content/semantic/list";

  // ==================== 英语短语模块 ====================
  /// 删除
  static const String enPhraseDeleteV2 = "GET:/en/phrase/{uid}/delete";
  /// 创建
  static const String enPhraseCreate = "POST:/en/phrase/create";
  /// 列表
  static const String enPhrasePagesV2 = "POST:/en/phrase/pages";
  /// 编辑
  static const String enPhraseEditV2 = "POST:/en/phrase/{uid}/edit";
  /// 匹配短语
  static const String enPhraseMatchDetailV2 = "POST:/en/phrase/match/detail";
  /// 删除短语语义
  static const String enPhraseSemanticDeleteV2 = "POST:/en/phrase/semantic/{uid}/delete";
  /// 单词关联其他语义
  static const String enPhraseSemanticAdd = "POST:/en/phrase/{uid}/semantic/add";

  // ==================== 英语句子模块 ====================
  /// 删除
  static const String enSentenceDelete = "GET:/en/sentence/{uid}/delete";
  /// 创建
  static const String enSentenceCreate = "POST:/en/sentence/create";
  /// 搜索测试列表
  static const String enSentenceAtlaPages = "POST:/en/sentence/atla/pages";
  /// 编辑
  static const String enSentenceEdit = "POST:/en/sentence/{uid}/edit";
  /// 列表
  static const String enSentencePagesV2 = "POST:/en/sentence/pages";
  /// 生成图片
  static const String enSentenceGenerateImage = "POST:/en/sentence/{uid}/generate/image";
  /// 匹配句子
  static const String enSentenceMatchDetail = "POST:/en/sentence/match/detail";

  // ==================== 自拼规则模块 ====================
  /// 创建
  static const String enPhonicsRuleCreate = "POST:/en/phonics/rule/create";
  /// 编辑
  static const String enPhonicsRuleEdit = "POST:/en/phonics/rule/{uid}/edit";
  /// 列表
  static const String enPhonicsRulePages = "POST:/en/phonics/rule/pages";

  // ==================== 英语歌曲模块 ====================
  /// 删除
  static const String enSongDelete = "GET:/en/song/{uid}/delete";
  /// 创建
  static const String enSongCreate = "POST:/en/song/create";
  /// 列表
  static const String enSongPagesV2 = "POST:/en/song/pages";
  /// 编辑
  static const String enSongEdit = "POST:/en/song/{uid}/edit";
  /// 批量编辑歌曲状态
  static const String enSongEditBatch = "POST:/en/song/edit/batch";

  // ==================== 英语文章模块 ====================
  /// 批量编辑
  static const String enTextEditBatch = "POST:/en/text/edit/batch";
  /// 英语文章 - 创建
  static const String enTextCreate = "POST:/en/text/create";
  /// 英语文章 - 编辑
  static const String enTextEdit = "POST:/en/text/{uid}/edit";
  /// 英语文章 - 删除
  static const String enTextDelete = "GET:/en/text/{uid}/delete";

  // ==================== 审核模块 ====================
  /// 新建图片
  static const String contentReviewImageCreate = "POST:/admin/content/review/image/create";
  /// 加载知识点图片
  static const String contentReviewKnowledgeImagesV2 = "POST:/admin/content/review/knowledge/images";
  /// 重新生成提示词prompt
  static const String contentReviewLoadPromptV3V2 = "POST:/admin/content/review/load/prompt/v3";
  /// 下架图片
  static const String contentReviewImageTakedown = "POST:/admin/content/review/image/takedown";
  /// 根据prompt新建图片
  static const String contentReviewImageCreateByPrompt = "POST:/admin/content/review/image/create/by/prompt";
  /// 删除任务
  static const String contentReviewImageTaskFailV2 = "POST:/admin/content/review/image/task/fail";
  /// 转换图片
  static const String contentReviewImageConvert = "POST:/admin/content/review/image/convert";
  /// 重新生成图片
  static const String contentReviewImageRegenerateV2V2 = "POST:/admin/content/review/image/regenerate/v2";
  /// 图片审核统计
  static const String contentReviewImageAuditStatisticsV2 = "POST:/admin/content/review/image/audit/statistics";
  /// 图片审核历史
  static const String contentReviewImageAuditHistoryV2 = "POST:/admin/content/review/image/audit/history";
  /// 图片定稿
  static const String contentReviewImageLockV2 = "POST:/admin/content/review/image/lock";
  /// 解锁定稿
  static const String contentReviewImageUnlockV2 = "POST:/admin/content/review/image/unlock";
  /// 知识点上传图片
  static const String adminContentReviewImageUpload = "POST:/admin/content/review/image/upload"; 

  // ==================== 视频审核模块 ====================
  /// 加载知识点视频
  static const String videoReviewKnowledgeVideos = "POST:/admin/video/review/knowledge/videos";
  /// 重新生成提示词和图片
  static const String videoReviewTaskRetryImagePrompt = "POST:/admin/video/review/task/retry/image/prompt";
  /// 用提示词重新生成图片
  static const String videoReviewTaskRetryImageGenerate = "POST:/admin/video/review/task/retry/image/generate";
  /// 升级为首尾帧模式
  static const String videoReviewTaskUpgradeStartEndFrames = "POST:/admin/video/review/task/upgrade/start_end_frames";
  /// 仅首帧模式生成视频
  static const String videoReviewGenerateFrameStart = "POST:/admin/video/review/generate/frame_start";
  /// 首尾帧模式生成视频
  static const String videoReviewGenerateStartEndFrames = "POST:/admin/video/review/generate/start_end_frames";
  /// 重新生成视频提示词和视频
  static const String videoReviewTaskRetryVideoPrompt = "POST:/admin/video/review/task/retry/video/prompt";
  /// 用已有提示词重新生成视频
  static const String videoReviewTaskRetryVideoGenerate = "POST:/admin/video/review/task/retry/video/generate";
  /// 放弃视频任务
  static const String videoReviewTaskAbandon = "POST:/admin/video/review/task/abandon";
  /// 分配视频审核任务
  static const String videoReviewTaskDistribute = "POST:/admin/video/review/task/distribute";
  /// 视频审核历史
  static const String videoReviewAuditHistory = "POST:/admin/video/review/video/audit/history";
  /// 视频审核员列表
  static const String videoReviewReviewerList = "GET:/admin/video/review/reviewer/list";
  /// 视频审核统计
  static const String videoReviewAuditStatistics = "POST:/admin/video/review/audit/statistics";
  /// 视频定稿
  static const String videoReviewVideoLock = "POST:/admin/video/review/video/lock";
  /// 解锁视频定稿
  static const String videoReviewVideoUnlock = "POST:/admin/video/review/video/unlock";
  /// 下架视频
  static const String videoReviewVideoTakedown = "POST:/admin/video/review/video/takedown";
  /// 音频增强
  static const String videoReviewVideoAudioEnhance = "POST:/admin/video/review/video/audio/enhance";
  /// 修改视频prompt
  static const String videoReviewPromptEdit = "POST:/admin/video/review/prompt/edit";
  /// 修改视频信息
  static const String videoReviewVideoEdit = "POST:/admin/video/review/video/edit";

  // ==================== 超级记忆管理模块 ====================
  
  /// 超记题目编辑
  static const String superMemoExerciseNeedResolveEdit = "POST:/super/memo/exercise/need/resolve/edit";
  /// 超记题目同步数据
  static const String superMemoExerciseNeedResolveAutoSync = "POST:/super/memo/exercise/need/resolve/auto/sync";



  // ==================== 题目配置模块 ====================
  /// 编辑
  static const String exerciseSuggestEdit = "PUT:/exercise/suggest/edit";
  /// 列表
  static const String exerciseSuggestTypeList = "GET:/exercise/suggest/type/list";

  // ==================== 知识练习/题目管理模块 ====================
  /// 根据知识点类型获取题目配置
  static const String exerciseConfigList = "POST:/exercise/config/list";
  /// 编辑题目
  static const String exerciseEditV2 = "POST:/exercise/edit";
  /// 题目查重
  static const String exerciseCheckExist = "POST:/exercise/check/exist";
  /// 获取题目模板分类
  static const String exerciseTypeListV2 = "POST:/exercise/type/list";
  /// 加载题目时长
  static const String exerciseAllExerciseDuration = "GET:/exercise/all/exercise/duration";
  /// 题目绑定课程
  static const String exerciseLessonBind = "POST:/exercise/lesson/bind";
  /// 题目创建v2
  static const String exerciseV2Create = "POST:/exercise/v2/create";
  /// 题目详情
  static const String exerciseDetailList = "POST:/exercise/detail/list";
  /// 删除本题
  static const String exerciseReviewDeleteV2 = "POST:/exercise/review/delete";
  /// 根据id获取题目详情edit
  static const String exerciseUidDetail = "POST:/exercise/{uid}/detail";
  /// 放弃ai生成
  static const String exerciseAbortAiRecord = "POST:/exercise/abort/ai/record/{recordId}";
  /// 审核统计
  static const String exerciseReviewStatisticsV2 = "POST:/exercise/review/statistics";
  /// 配置返回题目
  static const String exerciseTemplateQueryConfig = "POST:/exercise/template/query/config";
  /// 操作列表
  static const String exerciseOperationTypeList = "GET:/exercise/operation/type/list";
  /// 根据知识点查询题目
  static const String exerciseInnerKnowledgeExercise = "POST:/exercise/inner/knowledge/exercise";
  /// 获取题目类型列表
  static const String exerciseExerciseTypeList = "GET:/exercise/exerciseType/list";
  /// 查询题目待审核数量
  static const String exerciseReviewPendingCount = "POST:/exercise/review/pending/count";
  /// 根据知识点类型获取题目配置
  static const String exerciseConfigListV2 = "POST:/exercise/config/list/v2";
  /// 分页查询题目详情
  static const String exercisePageV2 = "POST:/exercise/page";
  /// 已有题目列表
  static const String exerciseListQueryConfig = "POST:/exercise/list/query/config";
  /// 获取课时题目ai记录
  static const String exerciseAiRecordV2 = "POST:/exercise/ai/record/v2";
  /// 删除ai题目生成记录
  static const String exerciseAiRecordRemove = "POST:/exercise/ai/record/remove/{recordId}";
  /// 题目上下架
  static const String exerciseOperationCode = "POST:/exercise/operation/{code}";
  /// 加载题目的课程信息
  static const String exerciseExerciseCourseInfos = "GET:/exercise/exercise/course/infos";
  /// 题目上下架 题目本身内部
  static const String exerciseInnerOperation = "POST:/exercise/inner/operation";
  /// 重新生成本题
  static const String exerciseReviewRegenerateV2 = "POST:/exercise/review/regenerate";
  /// 题目模板
  static const String exerciseTemplateListV2 = "GET:/exercise/template/list";
  /// 审核历史列表
  static const String exerciseReviewHistoryV2 = "POST:/exercise/review/history";

  // ==================== 书籍模块 ====================
  /// 创建
  static const String bookCreate = "POST:/book/create";
  /// 返回courseid = 50 的level
  static const String bookCourseLevel = "POST:/book/course/level";
  /// 编辑
  static const String bookEdit = "POST:/book/{uid}/edit";
  /// 章节类型
  static const String bookLoadChapterTypeList = "GET:/book/load/chapter/type/list";
  /// 新增一个章节
  static const String bookChapterCreate = "POST:/book/chapter/create";
  /// 章节关联单元unit
  static const String bookChapterRelation = "POST:/book/{uid}/chapter/{chapterId}/relation";
  /// 批量编辑章节
  static const String bookChapterBatchEdit = "POST:/book/chapter/batch/edit";
  /// 获取教材章节
  static const String bookLoadChapter = "GET:/book/{uid}/load/chapter";
  /// 删除一个章节
  static const String bookChapterDelete = "POST:/book/chapter/{chapterId}/delete";
  /// 编辑书内页
  static const String bookPageBatchEdit = "POST:/book/{uid}/page/batch/edit";
  /// 书内页
  static const String bookPageList = "GET:/book/{uid}/page/list";
  /// 列表
  static const String bookPagesV2 = "POST:/book/pages";
  /// 确认知识点
  static const String bookConfirmKnowledge = "POST:/book/{uid}/confirm/knowledge";
  /// 编辑book状态
  static const String bookEditStatus = "POST:/book/{uid}/edit/status";
  /// 关联教材book到模块
  static const String bookRelationLevel = "POST:/book/{uid}/relation/{levelId}";
  /// 匹配教材知识点
  static const String bookMatchBatch = "POST:/book/{uid}/match/batch";
  /// ISBN搜索
  static const String bookIsbnSearch = "POST:/book/isbn/search";
  /// 分析书页
  static const String bookAnalysisPageStart = "POST:/book/{uid}/analysis/page/start";
  /// 获取章节内页
  static const String bookChapterPageList = "GET:/book/{uid}/chapter/{chapterId}/page/list";
  /// 编辑章节内页
  static const String bookPageChapterBatchEdit = "POST:/book/{uid}/page/chapter/{chapterId}/batch/edit";
  /// 拆分教材
  static const String bookChaptersSplit = "POST:/book/{uid}/chapters/split";
  /// 提取正文内容
  static const String bookChaptersExtractUnit = "POST:/book/{uid}/chapters/extract/unit";
  /// 提取目录
  static const String bookChaptersExtractContent = "POST:/book/{uid}/chapters/extract/content";
  /// 生成单元计划
  static const String bookUnitPlan = "POST:/book/unit/{unitId}/plan";
  /// 生成单元句子
  static const String bookUnitSentence = "POST:/book/unit/{unitId}/sentence";
  /// 生成全部课时计划
  static const String bookUnitLessonPlan = "POST:/book/unit/{unitId}/lesson/plan";
  /// 生成全部课时题目/刷新课时题目
  static const String bookUnitLessonExercise = "POST:/book/unit/{unitId}/lesson/exercise";
  /// 刷新课时计划
  static const String bookUnitLessonRefresh = "POST:/book/unit/{unitId}/lesson/{lessonId}/refresh";

  // ==================== 单元管理/知识点模块 ====================
  /// 排序
  static const String unitKnowledgeOrder = "POST:/unit/{unitId}/knowledge/{uid}/order";
  /// 列表
  static const String unitKnowledgePages = "POST:/unit/{unitId}/knowledge/pages";
  /// 列表
  static const String unitKnowledgeList = "POST:/unit/{unitId}/knowledge/list";
  /// 解除匹配
  static const String unitKnowledgeMatchRevoke = "POST:/unit/{unitId}/knowledge/match/revoke";
  /// 添加知识点到单元
  static const String unitKnowledgeAdd = "POST:/unit/{unitId}/knowledge/add";
  /// 删除
  static const String unitKnowledgeRemove = "POST:/unit/{unitId}/knowledge/remove";
  /// 拖拽排序换单元
  static const String unitKnowledgeDragOrder = "POST:/unit/{unitId}/knowledge/{uid}/drag/order";
  /// 关联知识点
  static const String unitKnowledgeMatchConfirm = "POST:/unit/{unitId}/knowledge/match/confirm";
  /// 修改知识点
  static const String unitKnowledgeEditDetail = "POST:/unit/{unitId}/knowledge/edit/detail";
  /// 修改语义
  static const String unitKnowledgeEditSemantic = "POST:/unit/{unitId}/knowledge/{uid}/edit/semantic/{semanticId}";
  /// 查询词汇表获取的状态
  static const String unitKnowledgeStatus = "POST:/unit/{unitId}/knowledge/status";
  /// 重新获取词汇表
  static const String unitKnowledgeVocabulary = "POST:/unit/{unitId}/knowledge/vocabulary";
  /// 编辑知识点单元
  static const String unitKnowledgeEditUnit = "POST:/unit/{unitId}/knowledge/edit/unit";
  /// 加载题目的课程信息
  static const String unitKnowledgeCourseInfosV2 = "POST:/unit/{unitId}/knowledge/course/infos";

  // ==================== 课程管理/单元模块 ====================
  /// 创建
  static const String courseUnitCreate = "POST:/course/unit/create";
  /// 课程单元排序
  static const String courseUnitModuleOrder = "POST:/course/unit/{uid}/module/{moduleId}/order";
  /// 编辑
  static const String courseUnitEdit = "POST:/course/unit/{uid}/edit";
  /// 单元课时列表
  static const String courseUnitLessonList = "GET:/course/unit/{uid}/lesson/list";
  /// 列表
  static const String courseUnitPagesV2 = "POST:/course/unit/pages";
  /// 知识点详情
  static const String courseUnitKnowledgeTypeInfo = "GET:/course/unit/{uid}/knowledge/type/info";
  /// 生成歌曲
  static const String courseUnitSongGenerate = "POST:/course/unit/{uid}/song/generate";
  /// 关联课程课时
  static const String courseUnitRelationLesson = "POST:/course/unit/{uid}/relation/lesson";
  /// 复制课程单元
  static const String courseUnitCopy = "POST:/course/unit/{uid}/copy";
  /// 歌曲风格列表
  static const String courseUnitSongGenres = "POST:/course/unit/{uid}/song/genres";
  /// 拖拽排序换单元
  static const String courseUnitKnowledgeDragOrder = "POST:/course/unit/knowledge/{uid}/drag/order";
  /// 批量编辑课时单元
  static const String courseUnitKnowledgeEditUnitBatch = "POST:/course/unit/knowledge/edit/unit/batch";
  /// 生成remix文章
  static const String courseUnitTextRemix = "POST:/course/unit/{uid}/text/remix";
  /// 根据知识点和题目类型查询出可放的课时列表
  static const String courseUnitLessonExerciseInfo = "POST:/course/unit/lesson/exercise/info";
  /// 单元内批量生成知识点音频
  static const String courseModuleGenerateAudio = "POST:/course/module/{uid}/generate/audio";


  // ==================== 课时模版管理模块 ====================
  /// 删除模版配置
  static const String courseLessonTemplateConfigDelete = "POST:/course/lesson/template/config/delete";
  /// 课时模版的题目配置排序
  static const String courseLessonTemplateConfigSort = "POST:/course/lesson/template/{templateId}/config/sort";
  /// 创建
  static const String courseLessonTemplateCreate = "POST:/course/lesson/template/create";
  /// 编辑
  static const String courseLessonTemplateEdit = "POST:/course/lesson/template/{uid}/edit";
  /// 习题列表
  static const String courseLessonTemplateExerciseTemplateList = "POST:/course/lesson/template/{lessonId}/exercise/template/list";
  /// 创建模版配置
  static const String courseLessonTemplateConfigCreate = "POST:/course/lesson/template/config/create";
  /// 列表
  static const String courseLessonTemplatePagesV2 = "POST:/course/lesson/template/pages";
  /// 课时模版绑定题目配置
  static const String courseLessonTemplateConfigBindV2 = "POST:/course/lesson/template/{templateId}/config/bind/v2";
  /// 编辑模版配置
  static const String courseLessonTemplateConfigEdit = "POST:/course/lesson/template/config/edit";
  /// 查询课时模版配置列表
  static const String courseLessonTemplateConfigPagesV2 = "POST:/course/lesson/template/config/pages";

  // ==================== 自然拼读模块 ====================
  /// 创建
  static const String courseModulePhonicsCreate = "POST:/course/module/phonics/create";
  /// 编辑
  static const String courseModulePhonicsEdit = "POST:/course/module/phonics/{uid}/edit";
  /// 列表
  static const String courseModulePhonicsPages = "POST:/course/module/phonics/pages";

  // ==================== 课时习题模块 ====================
  /// 删除
  static const String lessonExerciseDelete = "DELETE:/lesson/exercise/delete";
  /// 创建
  static const String lessonExerciseCreate = "POST:/lesson/exercise/create";
  /// 排序
  static const String lessonExerciseEditOrder = "PUT:/lesson/exercise/edit/order";
  /// 列表
  static const String lessonExerciseList = "GET:/lesson/{lessonId}/exercise/list";

  // ==================== 课程管理/课程模块 ====================
  /// 创建
  static const String courseCreate = "POST:/course/create";
  /// 课程排序
  static const String courseOrder = "POST:/course/{uid}/order";
  /// 重复加书 发送mq消息
  static const String courseLevelModuleSendRepairProgress = "POST:/course/level/module/send/repair/progress";
  /// 编辑
  static const String courseEdit = "POST:/course/{uid}/edit";
  /// 列表
  static const String coursePagesV2 = "POST:/course/pages";
  /// 复制课程
  static const String courseCopy = "POST:/course/{uid}/copy";
  /// 关联课程等级
  static const String courseRelationLevel = "POST:/course/{uid}/relation/level";
  /// 课程等级及模块查询
  static const String courseLevelModuleList = "POST:/course/{uid}/level/module/list";
  /// 课程下的等级列表
  static const String courseLevelList = "POST:/course/{uid}/level/list";

  // ==================== 课程管理/等级模块 ====================
  /// 复制课程等级
  static const String courseLevelCopy = "POST:/course/level/{uid}/copy";
  /// 创建
  static const String courseLevelCreate = "POST:/course/level/create";
  /// 课程等级排序
  static const String courseLevelCourseOrder = "POST:/course/level/{uid}/course/{courseId}/order";
  /// 编辑
  static const String courseLevelEdit = "POST:/course/level/{uid}/edit";
  /// 列表
  static const String courseLevelPagesV2 = "POST:/course/level/pages";
  /// 等级模块列表
  static const String courseLevelModuleListV2 = "GET:/course/level/{uid}/module/list";
  /// 关联课程模块
  static const String courseLevelRelationModule = "POST:/course/level/{uid}/relation/module";

  // ==================== 课程管理/模块模块 ====================
  /// 创建
  static const String courseModuleCreate = "POST:/course/module/create";
  /// 课程模块排序
  static const String courseModuleLevelOrder = "POST:/course/module/{uid}/level/{levelId}/order";
  /// 编辑
  static const String courseModuleEdit = "POST:/course/module/{uid}/edit";
  /// 列表
  static const String courseModulePagesV2 = "POST:/course/module/pages";
  /// 关联课程单元
  static const String courseModuleRelationUnit = "POST:/course/module/{uid}/relation/unit";
  /// 复制课程模块
  static const String courseModuleCopy = "POST:/course/module/{uid}/copy";
  /// 添加模块单元知识点
  static const String courseModuleKnowledgeAdd = "POST:/course/module/{uid}/knowledge/add";
  /// 添加知识点到模块
  static const String courseModuleKnowledgeAddV2 = "POST:/course/module/knowledge/{uid}/add";
  /// 获取模块下的知识点
  static const String courseModuleKnowledgeList = "GET:/course/module/{uid}/knowledge/list";
  /// 获取单元课时列表
  static const String courseModuleUnitLessonList = "GET:/course/module/{uid}/unit/lesson/list";
  /// 获取简单单元列表
  static const String courseModuleUnitSimpleList = "GET:/course/module/{uid}/unit/simple/list";
  /// 获取单元知识点列表
  static const String courseModuleUnitList = "GET:/course/module/{uid}/unit/list";
  /// 删除知识点
  static const String courseModuleKnowledgeRemove = "DELETE:/course/module/{uid}/knowledge/remove";

  // ==================== 课程管理/课时模块 ====================
  /// 创建
  static const String courseLessonCreate = "POST:/course/lesson/create";
  /// 课程课时排序
  static const String courseLessonUnitOrder = "POST:/course/lesson/{uid}/unit/{unitId}/order";
  /// 编辑
  static const String courseLessonEdit = "POST:/course/lesson/{uid}/edit";
  /// 复制课程课时
  static const String courseLessonCopy = "POST:/course/lesson/{uid}/copy";
  /// 列表
  static const String courseLessonPagesV2 = "POST:/course/lesson/pages";

  // ==================== 角色管理模块 ====================
  /// 用户角色详情
  static const String userRoleUserDetail = "GET:/user/role/user/{userId}/detail";
  /// 用户角色编辑
  static const String userRoleUserEdit = "POST:/user/role/user/{userId}/edit";
  /// 所有admin接口权限列表
  static const String userRoleAdminApiList = "GET:/user/role/admin-api/list";
  /// 批量更新用户角色
  static const String userRoleBatchUpdate = "POST:/user/role/batch/update";
  /// 所有app接口权限列表
  static const String userRoleApiList = "GET:/user/role/api/list";

  // ==================== 专栏合集管理模块 ====================
  /// 专栏合集列表
  static const String contentCollectionRevealsContentCollectionList = "POST:/content/collection/reveals/contentCollection/list";
  /// 专栏合集创建
  static const String contentCollectionCreate = "POST:/content/collection/create";
  /// 专栏合集更改封面图
  static const String contentCollectionUpdateAvatar = "POST:/content/collection/update/avatar";
  /// 专栏合集更改推送模式
  static const String contentCollectionUpdatePushType = "POST:/content/collection/update/pushType";
  /// 英语专栏 - 创建
  static const String enRevealsCreate = "POST:/en/reveals/create";
  /// 英语专栏 - 查询分组专栏数据
  static const String enRevealsPageGroupEnReveals = "POST:/en/reveals/page/group/enReveals";
  /// 英语专栏 - group批量上架
  static const String enRevealsGroupUpdateContent = "POST:/en/reveals/group/update/content";
  /// 英语专栏 - 编辑
  static const String enRevealsEdit = "POST:/en/reveals/edit";
  /// 英语专栏 - 删除
  static const String enRevealsDelect = "POST:/en/reveals/delect";

  // =================== 视频审核模块 ===========================
  /// 升级为首尾帧模式
  static const String adminVideoReviewTaskUpgradeToFirstLastFrameMode = "POST:/admin/video/review/task/upgrade/start_end_frames";
  /// 修改图片提示词
  static const String adminContentReviewPromptEdit = "POST:/admin/content/review/prompt/edit";
  /// 重新生成图片提示词
  static const String adminVideoReviewTaskRetryImagePrompt = "POST:/admin/video/review/task/retry/image/prompt";
  /// 用提示词重新生成图片
  static const String adminVideoReviewTaskRetryImageGenerate = "POST:/admin/video/review/task/retry/image/generate";
  /// 审核视频 删除任务
  static const String adminVideoReviewTaskDelete = "POST:/admin/video/review/video/task/fail";
  /// 根据提示词生成视频
  static const String adminVideoReviewGenerateByPrompy = "POST:/admin/video/review/generate/by/prompt";

  // ==================== 版本管理模块 ====================
  /// 版本列表
  static const String versionPage = "POST:/version/page";
  /// 版本修改
  static const String versionEdit = "POST:/version/{uid}/edit";
  /// 版本创建
  static const String versionCreate = "POST:/version/create";

  // ==================== 题目管理扩展 ====================
  /// 题目预览
  static const String exerciseTemplatePreview = "POST:/exercise/template/preview";
  /// 题目创建
  static const String exerciseCreate = "POST:/exercise/create";
  /// 获取课时题目ai记录
  static const String exerciseAiRecordLesson = "GET:/exercise/ai/record/lesson/{lessonId}";
  /// 获取标注图片
  static const String exerciseLoadLabelPictureImage = "POST:/exercise/load/label/picture/image";
  /// 重新生成标注提示
  static const String exerciseLoadLabelPictureRegenerateTip = "POST:/exercise/load/label/picture/regenerate/tip";
  /// 重新生成图片
  static const String exerciseRegenerateAiImageRecord = "POST:/exercise/regenerate/ai/image/record/{recordId}";
  /// 重新生成ai题目
  static const String exerciseRegenerateAiRecord = "POST:/exercise/regenerate/ai/record/{recordId}";
  /// 获取题目AI生成结果
  static const String exerciseAiResult = "POST:/exercise/ai/result";

  // ==================== 用户管理模块 ====================
  /// 用户日志列表
  static const String userLogPages = "POST:/user/log/pages";
  /// 初始用户VIP
  static const String userInitialVipPro = "POST:/user/initial/vip/pro";
  /// 根据手机号查询信息
  static const String userListByPhones = "POST:/user/list/by/phones";
  /// 查询用户详细信息
  static const String userDetail = "POST:/user/detail";
  /// 查询用户昵称信息
  static const String userApplicationListInfo = "POST:/user/application/list/info";

  // ==================== 权益模块 ====================
  /// 创建用户权益
  static const String babyRightsCreate = "POST:/baby/rights/create";
  /// 用户权益列表
  static const String babyRightsPage = "POST:/baby/rights/page";
  /// 编辑用户权益
  static const String babyRightsEdit = "POST:/baby/rights/{masterId}/edit";
  /// 创建系统权益
  static const String rightsCreate = "POST:/rights/create";
  /// 编辑系统权益
  static const String rightsEdit = "POST:/rights/{uid}/edit";
  /// 系统权益列表
  static const String rightsPages = "POST:/rights/pages";

  // ==================== 角色管理模块扩展 ====================
  /// 删除角色
  static const String roleRemove = "POST:/role/{uid}/remove";
  /// 编辑角色
  static const String roleEdit = "POST:/role/{uid}/edit";
  /// 创建角色
  static const String roleCreate = "POST:/role/create";
  /// 角色列表
  static const String rolePages = "POST:/role/pages";
  /// 所有角色列表
  static const String roleList = "GET:/role/list";
  /// 角色详情
  static const String roleDetail = "GET:/role/{uid}/detail";
  /// 移除用户角色
  static const String userRoleRemove = "POST:/user/role/{uid}/remove";
  /// 用户角色创建
  static const String userRoleCreate = "POST:/user/role/create";
  /// 用户角色列表
  static const String userRolePages = "POST:/user/role/pages";
  /// 用户的角色列表
  static const String userRoleUserList = "GET:/user/role/user/{userId}/list";
  /// 角色下的用户列表
  static const String userRoleRoleList = "GET:/user/role/role/{roleId}/list";

  // ==================== 支付模块 ====================
  /// 优惠券批量记录列表
  static const String couponBatchFileRecordPage = "POST:/coupon/batch/file/record/page";
  /// 创建优惠券
  static const String couponSupplyCreate = "POST:/coupon/supply/create";
  /// 优惠券列表
  static const String couponSupplyPage = "POST:/coupon/supply/page";
  /// 编辑优惠券
  static const String couponSupplyEdit = "POST:/coupon/supply/{uid}/edit";
  /// 批量生成优惠劵
  static const String couponSupplyGenerateCoupon = "POST:/coupon/supply/generate/coupon";
  /// 订单列表
  static const String orderPage = "POST:/order/page";
  /// 取消订单
  static const String orderRevokeOrder = "POST:/order/revoke/order";
  /// 创建服务包
  static const String servicePackageCreate = "POST:/service/package/create";
  /// 服务包列表
  static const String servicePackagePage = "POST:/service/package/page";
  /// 编辑服务包
  static const String servicePackageEdit = "POST:/service/package/{uid}/edit";
  /// 创建服务包权益
  static const String servicePackageRightsCreate = "POST:/service/package/rights/create";
  /// 服务包权益列表
  static const String servicePackageRightsPage = "POST:/service/package/rights/page";
  /// 编辑服务包权益
  static const String servicePackageRightsEdit = "POST:/service/package/rights/{uid}/edit";
  /// VIP配置创建
  static const String vipStoreServicePackageCreate = "POST:/vip/store/service/package/create";
  /// VIP配置编辑
  static const String vipStoreServicePackageEdit = "POST:/vip/store/service/package/{uid}/edit";

  // ==================== 语言/音色模块 ====================
  /// 创建音色
  static const String accentCreate = "POST:/accent/create";
  /// 音色列表
  static const String accentPages = "POST:/accent/pages";
  /// 编辑音色
  static const String accentEdit = "POST:/accent/{uid}/edit";

  // ==================== 用户错误报告模块 ====================
  /// 用户报告列表
  static const String reportUserReportPages = "POST:/report/user_report/pages";
  /// 音频反馈记录列表
  static const String reportWordAudioRecordPages = "POST:/report/word_audio_record/pages";
  /// 用户报告状态更新
  static const String reportUserReportEdit = "POST:/report/user_report/{uid}/edit";
  /// 音频反馈状态更新
  static const String reportWordAudioRecordEdit = "POST:/report/word_audio_record/{uid}/edit";

  // ==================== 语义管理模块 ====================
  /// 创建语义
  static const String semanticCreate = "POST:/semantic/create";
  /// 获取指定ID的语义列表
  static const String semanticGenImageList = "POST:/semantic/gen/image/list";
  /// 编辑语义
  static const String semanticEdit = "POST:/semantic/{uid}/edit";
  /// 语义列表
  static const String semanticPages = "POST:/semantic/pages";
  /// 获取未生成图片的语义列表
  static const String semanticDifficultyNotImage = "GET:/semantic/difficulty/not/image";

  // ==================== 英语专栏扩展 ====================
  /// 合集内列表
  static const String enRevealsPageEnReveals = "POST:/en/reveals/page/enReveals";
  /// 设置推送时间
  static const String enRevealsUpdatePushTime = "POST:/en/reveals/update/push/time";
  /// 推送类型列表
  static const String enRevealsPushTimeList = "GET:/en/reveals/push/time/list";
  /// 更新Group
  static const String enRevealsUpdateGroup = "GET:/en/reveals/updateGroup";
  /// 查询专栏审核数据
  static const String enRevealsEnRevealsReviewList = "POST:/en/reveals/enReveals/review/list";
  /// 审核专栏
  static const String enRevealsReviewEnRevealsStatus = "POST:/en/reveals/review/enReveals/status";

  // ==================== 发音模块扩展 ====================
  /// 生成ass字幕
  static const String audioExpressAss = "POST:/audio/express/{expressId}/ass";
  /// 优化歌曲ass字幕
  static const String audioExpressAssRefine = "POST:/audio/express/{expressId}/ass/refine";
  /// 生成ass翻译字幕
  static const String audioExpressAssTranslate = "POST:/audio/express/{expressId}/ass/translate";
  /// 发布/取消发布短语/句子/文章/歌曲
  static const String audioExpressPublish = "POST:/audio/express/{expressId}/publish";
  /// 发布歌曲字幕
  static const String audioExpressPublishAss = "POST:/audio/express/{expressId}/publish/ass";
  /// AI生成reveal文章prompt
  static const String audioPrompt = "POST:/audio/prompt";
  /// 查询题目(发音)
  static const String audioExerciseList = "POST:/audio/exercise/list";

  // ==================== 英语文章扩展 ====================
  /// 批量编辑是否在课程
  static const String enTextInnerEditInCourse = "POST:/en/text/inner/edit/in_course";

  // ==================== 客服人员管理模块 ====================
  /// 客服人员列表
  static const String customerServiceAgentPages = "POST:/customer-service/agent/pages";
  /// 客服人员详情
  static const String customerServiceAgentDetail = "GET:/customer-service/agent/{uid}/detail";
  /// 删除客服人员
  static const String customerServiceAgentRemove = "POST:/customer-service/agent/{uid}/remove";
  /// 创建客服人员
  static const String customerServiceAgentCreate = "POST:/customer-service/agent/create";
  /// 客服人员全部列表
  static const String customerServiceAgentList = "GET:/customer-service/agent/list";
  /// 编辑客服人员
  static const String customerServiceAgentEdit = "POST:/customer-service/agent/{uid}/edit";

  // ==================== 客服排班管理模块 ====================
  /// 删除排班配置
  static const String customerServiceScheduleConfigRemove = "POST:/customer-service/schedule/config/{uid}/remove";
  /// 创建排班配置
  static const String customerServiceScheduleConfigCreate = "POST:/customer-service/schedule/config/create";
  /// 创建排班记录
  static const String customerServiceScheduleRecordCreate = "POST:/customer-service/schedule/record/create";
  /// 删除排班记录
  static const String customerServiceScheduleRecordRemove = "POST:/customer-service/schedule/record/{uid}/remove";
  /// 调整排班
  static const String customerServiceScheduleAdjust = "POST:/customer-service/schedule/adjust";
  /// 排班配置全部列表
  static const String customerServiceScheduleConfigList = "GET:/customer-service/schedule/config/list";
  /// 排班配置列表
  static const String customerServiceScheduleConfigPages = "POST:/customer-service/schedule/config/pages";
  /// 编辑排班配置
  static const String customerServiceScheduleConfigEdit = "POST:/customer-service/schedule/config/{uid}/edit";
  /// 排班配置详情
  static const String customerServiceScheduleConfigDetail = "GET:/customer-service/schedule/config/{uid}/detail";
  /// 排班记录列表
  static const String customerServiceScheduleRecordPages = "POST:/customer-service/schedule/record/pages";
  /// 编辑排班记录
  static const String customerServiceScheduleRecordEdit = "POST:/customer-service/schedule/record/{uid}/edit";
  /// 排班记录详情
  static const String customerServiceScheduleRecordDetail = "GET:/customer-service/schedule/record/{uid}/detail";
  /// 生成排班
  static const String customerServiceScheduleGenerate = "POST:/customer-service/schedule/generate";

  // ==================== 审核字幕 ======================
  /// 审核字幕 删除任务
  static const String adminAssReviewAssTaskDelete = "POST:/admin/ass/review/ass/task/delete";
  /// 审核字幕 创建音频字幕对齐任务
  static const String adminAssReviewTaskAlignAudioCreate = "POST:/admin/ass/review/task/align/audio/create";
  /// 审核字幕 创建视频字幕对齐任务
  static const String adminAssReviewTaskAlignVideoCreate = "POST:/admin/ass/review/task/align/video/create";
  /// 审核字幕 创建字幕翻译任务
  static const String adminAssReviewTaskTranslateCreate = "POST:/admin/ass/review/task/translate/create";
  /// 审核字幕 审核历史
  static const String adminAssReviewAssAuditHistory = "POST:/admin/ass/review/ass/audit/history";
  /// 审核字幕 审核统计
  static const String adminAssReviewAssAuditStatistics = "POST:/admin/ass/review/ass/audit/statistics";
  /// 字幕 字幕详情
  static const String adminAssReviewAssDetail = "POST:/admin/ass/review/ass/detail";
  /// 字幕 定稿字幕
  static const String adminAssReviewAssLock = "POST:/admin/ass/review/ass/lock";
  /// 字幕 解锁字幕定稿
  static const String adminAssReviewAssUnlock = "POST:/admin/ass/review/ass/unlock";

  // ==================== 审核音频 =======================
  /// 审核音频 删除任务
  static const String adminAudioReviewTaskDelete = "POST:/admin/audio/review/task/delete";
  /// 审核音频 审核历史
  static const String adminAudioReviewAuditHistory = "POST:/admin/audio/review/audit/history";
  /// 审核音频 审核统计
  static const String adminAudioReviewAuditStatistics = "POST:/admin/audio/review/audit/statistics";
  /// 审核音频 根据提示词生成音频
  static const String adminAudioReviewTaskRetryPromptGenerate = "POST:/admin/audio/review/task/retry/prompt/generate";
  /// 审核音频 生成提示词和音频
  static const String adminAudioReviewTaskRetryPromptRegenerate = "POST:/admin/audio/review/task/retry/prompt/regenerate";

  /// 创建短语句子文章音频任务
  static const String adminAudioReviewTaskVoiceSegmentCreate = "POST:/admin/audio/review/task/voice/segment/create";
  /// 创建歌曲专栏音频任务
  static const String adminAudioReviewTaskMusicMinimaxCreate = "POST:/admin/audio/review/task/music/minimax/create";
  /// 音频定稿
  static const String adminAudioReviewAudioLock = "POST:/admin/audio/review/audio/lock";
  /// 解锁音频定稿
  static const String adminAudioReviewAudioUnlock = "POST:/admin/audio/review/audio/unlock";

  /// 知识点上传音频
  static const String adminKnowledgeAudioUploadAudio = "POST:/admin/audio/review/audio/upload";

  /// ================== 甄读剧本 ============================
  /// 人声情绪列表
  static const String dramaVoiceEmotionPages = "POST:/drama/voice/emotion/pages";
  /// 人声情绪删除
  static const String dramaVoiceEmotionDelete = "GET:/drama/voice/emotion/{uid}/delete";
  /// 人声情绪编辑
  static const String dramaVoiceEmotionEdit = "POST:/drama/voice/emotion/{uid}/edit";
  /// 新增人声情绪
  static const String dramaVoiceEmotionCreate = "POST:/drama/voice/emotion/create";
  /// 人声情绪试听
  static const String dramaVoiceEmotionPreview = "POST:/drama/voice/emotion/preview";

  /// 人声音色列表
  static const String dramaVoiceTimbreColorList = "POST:/drama/voice/timbre/pages";
  /// 人声音色删除
  static const String dramaVoiceTimbreDelete = "GET:/drama/voice/timbre/{uid}/delete";
  /// 人声音色编辑
  static const String dramaVoiceTimbreEdit = "POST:/drama/voice/timbre/{uid}/edit";
  /// 新增人声音色
  static const String dramaVoiceTimbreCreate = "POST:/drama/voice/timbre/create";
  /// 人声音色上传音频
  static const String dramaVoiceTimbreUploadAudio = "POST:/drama/voice/timbre/audio/upload";
  /// 人声音色 生成音频
  static const String dramaVoiceTimbreAudioGenerate = "POST:/drama/voice/timbre/audio/generate";
  /// 人声音色 设计台词
  static const String dramaVoiceTimbreAudioTextDesign = "POST:/drama/voice/timbre/audio_text/design";

  /// 甄读角色列表
  static const String dramaPersonaPages = "POST:/drama/persona/pages";
  /// 甄读角色创建
  static const String dramaPersonaCreate = "POST:/drama/persona/create";
  /// 甄读角色编辑
  static const String dramaPersonaEdit = "POST:/drama/persona/{uid}/edit";
  /// 甄读角色编辑
  static const String dramaPersonaDelete = "GET:/drama/persona/{uid}/delete";
  /// 甄读角色 创建变体
  static const String dramaPersonaVariantCreate = "POST:/drama/persona/variant/create";
  /// 甄读角色 编辑变体
  static const String dramaPersonaVariantEdit = "POST:/drama/persona/variant/{uid}/edit";
  /// 甄读角色 删除变体
  static const String dramaPersonaVariantDelete = "GET:/drama/persona/variant/{uid}/delete";
  /// 甄读角色 增加设定图
  static const String dramaPersonaVariantImageGenerate = "POST:/drama/persona/variant/image/generate";

  /// 剧本主题 列表
  static const String dramaScriptThemeList = "POST:/drama/script/theme/list";
  /// 剧本主题 创建
  static const String dramaScriptThemeCreate = "POST:/drama/script/theme/create";
  /// 剧本主题 编辑
  static const String dramaScriptThemeEdit = "POST:/drama/script/theme/edit";
  /// 剧本主题 删除
  static const String dramaScriptThemeDelete = "GET:/drama/script/theme/delete";

  /// 剧本题材 列表
  static const String dramaScriptGenreList = "POST:/drama/script/genre/list";
  /// 剧本题材 创建
  static const String dramaScriptGenreCreate = "POST:/drama/script/genre/create";
  /// 剧本题材编辑
  static const String dramaScriptGenreEdit = "POST:/drama/script/genre/edit";
  /// 剧本题材 删除
  static const String dramaScriptGenreDelete = "GET:/drama/script/genre/delete";

  /// 剧本分组 列表
  static const String dramaScriptGroupPages = "POST:/drama/script/group/pages";
  /// 剧本分组 创建
  static const String dramaScriptGroupCreate = "POST:/drama/script/group/create";
  /// 剧本分组 编辑
  static const String dramaScriptGroupEdit = "POST:/drama/script/group/{uid}/edit";
  /// 剧本分组 删除
  static const String dramaScriptGroupDelete = "GET:/drama/script/group/{uid}/delete";

  /// 剧本 列表
  static const String dramaScriptPages = "POST:/drama/script/pages";
  /// 剧本 详情
  static const String dramaScriptDetail = "GET:/drama/script/{uid}/detail";
  /// 剧本 编辑剧本
  static const String dramaScriptEdit = "POST:/drama/script/{uid}/edit";
  /// 剧本 创建单元剧本
  static const String dramaScriptGenerateUnit = "POST:/drama/script/generate/unit";
  /// 剧本 创建词汇剧本
  static const String dramaScriptGenerateVocabulary = "POST:/drama/script/generate/vocabulary";
  /// 剧本 编辑场景
  static const String dramaScriptSceneEdit = "POST:/drama/script/scene/{uid}/edit";
  /// 剧本 新增台词
  static const String dramaScriptDialogueCreate = "POST:/drama/script/dialogue/create";
  /// 剧本 编辑台词
  static const String dramaScriptDialogueEdit = "POST:/drama/script/dialogue/{uid}/edit";
  /// 剧本 删除台词
  static const String dramaScriptDialogueDelete = "GET:/drama/script/dialogue/{uid}/delete";
  /// 剧本 台词排序
  static const String dramaScripSceneDialogueSort = "POST:/drama/script/scene/{sceneId}/dialogue/sort";
  /// 剧本 删除剧本
  static const String dramaScriptDelete = "POST:/drama/script/{uid}/delete";

  /// 音频项目 列表
  static const String dramaAudioProjectPages = "POST:/drama/audio/project/pages";
  /// 音频项目 详情
  static const String dramaAudioProjectDetail = "GET:/drama/audio/project/{uid}/detail";
  /// 音频项目 创建
  static const String dramaAudioProjectCreate = "POST:/drama/audio/project/create/from-script";
  /// 音频项目 新建台词音频
  static const String dramaAudioProjectDialogueAudioGenerate = "POST:/drama/audio/project/voice/dialogue";
  /// 音频项目 合成音频项目
  static const String dramaAudioProjectCompose = "POST:/drama/audio/project/compose";
  /// 音频项目 删除音频项目
  static const String dramaAudioProjectDelete = "POST:/drama/audio/project/delete";


  /// 视觉项目 列表
  static const String dramaVisualProjectPages = "POST:/drama/visual/project/pages";
  /// 视觉项目 项目详情
  static const String dramaVisualProjectDetail = "GET:/drama/visual/project/{uid}/detail";
  /// 视觉项目 删除视觉项目
  static const String dramaVisualProjectDelete = "POST:/drama/visual/project/delete";
  /// 视觉项目 创建视觉项目
  static const String dramaVisualProjectCreate = "POST:/drama/visual/project/create";
  /// 视觉项目 查看提示词
  static const String dramaVisualProjectStoryboardSheetPromptView = "POST:/drama/visual/project/storyboard/sheet/prompt/view";
  /// 视觉项目 生成提示词
  static const String dramaVisualProjectStoryboardSheetPromptGenerate = "POST:/drama/visual/project/storyboard/sheet/prompt/generate";
  /// 视觉项目 导入分镜词图片
  static const String dramaVisualProjectStoryboardSheetImageImport = "POST:/drama/visual/project/storyboard/sheet/image/import"; 
  /// 视觉项目 根据prompt生成分镜图
  static const String dramaVisualProjectStoryboardSheetImageTaskByPrompt = "POST:/drama/visual/project/storyboard/sheet/image/task/by/prompt"; 
  /// 视觉项目 重新裁切分镜表图片
  static const String dramaVisualProjectStoryboardSheetImageCrop = "POST:/drama/visual/project/storyboard/sheet/image/crop"; 
  /// 视觉项目 生成单场景视频
  static const String dramaVisualProjectGenerateVideoScene = "POST:/drama/visual/project/generate/video/scene"; 
  /// 视觉项目 生成过渡场景视频
  static const String dramaVisualProjectGenerateVideoBetweenScenes = "POST:/drama/visual/project/generate/video/between/scenes"; 
  /// 视觉项目 合成完整视频
  static const String dramaVisualProjectVideoCompose = "POST:/drama/visual/project/video/compose"; 
  /// 视觉项目 查询片段视频列表
  static const String dramaVisualProjectVideoSegments = "POST:/drama/visual/project/video/segments"; 
  /// 视觉项目 片段视频排序
  static const String dramaVisualProjectVideoSegmentSort = "POST:/drama/visual/project/video/segment/sort"; 
  /// 视觉项目 删除视频片段
  static const String dramaVisualProjectVideoSegmentDelete = "POST:/drama/visual/project/video/segment/delete"; 
  /// 视觉项目 导入完整视频
  static const String dramaVisualProjectVideoImport = "POST:/drama/visual/project/video/import"; 
  /// 视觉项目 字幕映射
  static const String dramaVisualProjectFrameMappingDetail = "POST:/drama/visual/project/frame/mapping/detail"; 
  /// 视觉项目 保存字幕映射
  static const String dramaVisualProjectFrameMapping = "POST:/drama/visual/project/frame/mapping"; 
  /// 视觉项目 生成关键帧字幕
  static const String dramaVisualProjectFrameAss = "POST:/drama/visual/project/frame/ass"; 
  /// 视觉项目 生成关键帧翻译
  static const String dramaVisualProjectFramaAssTranslate = "POST:/drama/visual/project/frame/ass/translate";
  /// 视觉项目 字幕映射清除关键帧字幕映射
  static const String dramaVisualProjectFrameAssClearMapping = "POST:/drama/visual/project/frame/ass/clear";
  /// 视觉项目 - 修改剧本封面
  static const String dramaVisualProjectScriptCoverUpdate = "POST:/drama/visual/project/script/cover/update";

  /// 甄读 异步任务 创建记录
  static const String zhenduGenerateTaskPages = "POST:/algorithm/task/pages";

  // ======================== 运营 ==========================

  /// 通知模板管理 编辑模板
  static const String notifyTemplateEdit = "POST:/notify/template/{uid}/edit";
  /// 通知模板管理 模板详情
  static const String notifyTemplateDetail = "GET:/notify/template/{uid}/detail";
  /// 通知模板管理 类型列表
  static const String notifyTemplateTypePages = "POST:/notify/template/type/pages";
  /// 通知模板管理 编辑类型
  static const String notifyTemplateTypeEdit = "POST:/notify/template/type/{uid}/edit";
  /// 通知模板管理 创建类型
  static const String notifyTemplateTypeCreate = "POST:/notify/template/type/create";
  /// 通知模板管理 模板列表
  static const String notifyTemplatePages = "POST:/notify/template/pages";
  /// 通知模板管理 创建模板
  static const String notifyTemplateCreate = "POST:/notify/template/create";
  /// 通知模板管理 删除模板
  static const String notifyTemplateRemove = "POST:/notify/template/{uid}/remove";
  /// 通知模板管理 类型全部列表
  static const String notifyTemplateTypeAllList = "GET:/notify/template/type/all/list";
  /// 通知模板管理 按类型模板列表
  static const String notifyTemplateTypeTemplateList = "GET:/notify/template/type/{type}/template/list";
  /// 通知模板管理 发送模板
  static const String notifyTemplateSend = "POST:/notify/template/send";
  /// 通知模板管理 可发送模板列表
  static const String notifyTemplateSendableList = "GET:/notify/template/sendable/list";

  /// 渠道管理 渠道列表
  static const String channelPages = "POST:/channel/pages";
  /// 渠道管理 渠道详情
  static const String channelDetail = "GET:/channel/{uid}/detail";
  /// 渠道管理 删除渠道
  static const String channelRemove = "POST:/channel/{uid}/remove";
  /// 渠道管理 创建渠道
  static const String channelCreate = "POST:/channel/create";
  /// 渠道管理 编辑渠道
  static const String channelEdit = "POST:/channel/{uid}/edit";
  /// 渠道管理 创建渠道V2
  static const String channelCreateV2 = "POST:/channel/create/v2";
  /// 渠道管理 编辑渠道V2
  static const String channelEditV2 = "POST:/channel/{uid}/edit/v2";

  /// 渠道协管员管理 渠道协管员创建
  static const String channelUserCreate = "POST:/channel/user/create";
  /// 渠道协管员管理 渠道协管员编辑
  static const String channelUserEdit = "POST:/channel/user/user/{userId}/edit";
  /// 渠道协管员管理 模拟用户登录
  static const String channelUserImpersonateMember = "POST:/channel/user/impersonate/member";
  /// 渠道协管员管理 渠道协管员列表
  static const String channelUserPages = "POST:/channel/user/pages";

  /// 工作人员操作台 顶部统计
  static const String staffConsoleSummary = "POST:/staff/console/summary";
  /// 工作人员操作台 学员巡检分页
  static const String staffConsoleMemberPages = "POST:/staff/console/member/pages";
  /// 工作人员操作台 关注学员
  static const String channelStaffAccountFollow = "POST:/channel/staff/account/follow";


  /// 巡检操作记录
  static const String channelUserLogPages = "POST:/channel/user/log/pages";
  /// 巡检领取
  static const String channelStaffAccountGet = "POST:/channel/staff/account/get";
  /// 巡检转交
  static const String channelStaffAccountChange = "POST:/channel/staff/account/change";

  /// 工单模板列表
  static const String channelTicketTemplatePages = "POST:/channel/ticket/template/pages";
  /// 删除工单模板
  static const String channelTicketTemplateRemove = "POST:/channel/ticket/template/{uid}/remove";
  /// 创建工单模板
  static const String channelTicketTemplateCreate = "POST:/channel/ticket/template/create";
  /// 编辑工单模板
  static const String channelTicketTemplateEdit = "POST:/channel/ticket/template/{uid}/edit";
  /// 工单记录列表
  static const String channelTicketRecordPages = "POST:/channel/ticket/record/pages";

  /// 工单详情
  static const String channelTicketRecordDetail = "GET:/channel/ticket/record/{uid}/detail";
  /// 完成工单 
  static const String channelTicketRecordComplete = "POST:/channel/ticket/record/{uid}/complete";
  /// 工单需要修改
  static const String channelTicketRecordRevision = "POST:/channel/ticket/record/{uid}/revision";

  /// 管理员控制台统计
  static const String channelUserConsoleSummary = "GET:/channel/user/console/summary";

}
