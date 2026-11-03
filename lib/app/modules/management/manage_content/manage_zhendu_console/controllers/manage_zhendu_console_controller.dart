import 'package:get/get.dart';

import '../../../../../routes/routes.dart';
import '../../../models/models.dart';
import '../../../utils/utils.dart';

class ManageZhenduConsoleController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageZhenduConsoleController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_ZHENDU_CONSOLE;

  @override
  String get breadcrumbTitle => '甄读管理台';

  /// 角色列表
  final RxList<ManageAuthMenuModel> roleList = <ManageAuthMenuModel>[].obs;

  /// 剧本列表
  final RxList<ManageAuthMenuModel> scriptList = <ManageAuthMenuModel>[].obs;

  /// 项目列表
  final RxList<ManageAuthMenuModel> projectList = <ManageAuthMenuModel>[].obs;


  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    // TODO: 初始化逻辑
    initAuth();
  }


  void initAuth(){

    // ============ 角色 ================
    if(ManageAuthUtils.isAuth(ManageAuthCode.dramaVoiceEmotionPages)){
      roleList.add(ManageAuthMenuModel(
        name: "人声情绪",
        subtitle: "管理 8 维情绪向量、多语言名称、建议语速与启用状态",
        authCode: ManageAuthCode.dramaVoiceEmotionPages,
        route: Routes.MANAGE_VOCAL_EMOTIONS,
      ));
    }
    
    if(ManageAuthUtils.isAuth(ManageAuthCode.dramaVoiceTimbreColorList)){
      roleList.add(ManageAuthMenuModel(
        name: "人声音色",
        subtitle: "管理音色维度、参考音频、角色定位标签与可用性",
        authCode: ManageAuthCode.dramaVoiceTimbreColorList,
        route: Routes.MANAGE_VOCAL_TIMBRE,
      ));
    }

    if(ManageAuthUtils.isAuth(ManageAuthCode.dramaPersonaPages)){
      roleList.add(ManageAuthMenuModel(
        name: "角色",
        subtitle: "按 Persona 管理角色本体，并向下管理 PersonaVariant 与 core 图",
        authCode: ManageAuthCode.dramaPersonaPages,
        route: Routes.MANAGE_PERSONA,
      ));
    }

    // ============ 剧本 ================

    if(ManageAuthUtils.isAuth(ManageAuthCode.dramaScriptThemeList)){
      scriptList.add(ManageAuthMenuModel(
        name: "剧本主题",
        subtitle: "管理 script_themes：分类、多语言名称描述、推荐角色",
        authCode: ManageAuthCode.dramaScriptThemeList,
        route: Routes.MANAGE_SCRIPT_THEME,
      ));
    }

    if(ManageAuthUtils.isAuth(ManageAuthCode.dramaScriptGenreList)){
      scriptList.add(ManageAuthMenuModel(
        name: "剧本题材",
        subtitle: "管理 script_genres：体裁、多语言描述、提示词与音频特征",
        authCode: ManageAuthCode.dramaScriptGenreList,
        route: Routes.MANAGE_SCRIPT_GENRE,
      ));
    }

    if(ManageAuthUtils.isAuth(ManageAuthCode.dramaScriptGroupPages)){
      scriptList.add(ManageAuthMenuModel(
        name: "剧本分组",
        subtitle: "管理 script_groups：多语言名称描述、分类与排序，用于教研灵活归组",
        authCode: ManageAuthCode.dramaScriptGroupPages,
        route: Routes.MANAGE_SCRIPT_GROUPING,
      ));
    }

    if(ManageAuthUtils.isAuth(ManageAuthCode.dramaScriptPages)){
      scriptList.add(ManageAuthMenuModel(
        name: "单元剧本",
        subtitle: "按课程单元生成与管理剧本概要，并进入 scene / dialogue 详情编辑",
        authCode: ManageAuthCode.dramaScriptPages,
        route: Routes.MANAGE_UNIT_SCRIPT,
      ));
    }

    if(ManageAuthUtils.isAuth(ManageAuthCode.dramaScriptPages)){
      scriptList.add(ManageAuthMenuModel(
        name: "词汇剧本",
        subtitle: "按知识点生成与管理词汇剧本，保留核心知识点入口",
        authCode: ManageAuthCode.dramaScriptPages,
        route: Routes.MANAGE_VOCABULARY_SCRIPT,
      ));
    }

    // ============ 项目 ================
    if(ManageAuthUtils.isAuth(ManageAuthCode.dramaAudioProjectPages)){
      projectList.add(ManageAuthMenuModel(
        name: "音频项目",
        subtitle: "管理剧本转音频、配音、音效和音频交付状态",
        authCode: ManageAuthCode.dramaAudioProjectPages,
        route: Routes.MANAGE_AUDIO_PROJECT,
      ));
    }
    
    if(ManageAuthUtils.isAuth(ManageAuthCode.dramaVisualProjectPages)){
      projectList.add(ManageAuthMenuModel(
        name: "视觉项目",
        subtitle: "管理分镜、设定图、字幕、视频成片与审核状态",
        authCode: ManageAuthCode.dramaVisualProjectPages,
        route: Routes.MANAGE_VISUAL_PROJECT,
      ));
    }

    
  }


  /// 跳转到课程列表
  void toPage(ManageAuthMenuModel data){
    if(data.route.isEmpty) return;
    ManagePageRegistry.jumpTo(data.route);
  }

  @override
  void onClose() {
    // TODO: 清理逻辑
    super.onClose();
  }
}
