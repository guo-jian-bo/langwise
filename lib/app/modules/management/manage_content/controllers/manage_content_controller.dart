
import 'package:get/get.dart';

import '../../../../routes/routes.dart';
import '../../models/manage_auth_menu_model.dart';
import '../../utils/manage_auth_utils.dart';
import '../../utils/manage_breadcrumb_utils.dart';
import '../../utils/manage_page_registry.dart';


class ManageContentController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageContentController({required this.tag});

  final RxList<ManageAuthMenuModel> manageContentList = <ManageAuthMenuModel>[].obs;
  final RxList<ManageAuthMenuModel> manageResourceToolsList = <ManageAuthMenuModel>[].obs;


  final RxInt test = 0.obs;
  
  @override
  String get breadcrumbRoute => Routes.MANAGE_CONTENT;
  
  @override
  String get breadcrumbTitle => '内容';

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    initAuth();
  }

  void initAuth(){
    manageContentList.clear();

    

    if(ManageAuthUtils.isAuth(ManageAuthCode.enWordPages)){
      manageContentList.add(ManageAuthMenuModel(
        name: "单词",
        subtitle: "管理英语单词库，包含发音、语义、语法等信息",
        authCode: ManageAuthCode.enWordPages,
        route: Routes.MANAGE_WORD,
      ));
    }

    if(ManageAuthUtils.isAuth(ManageAuthCode.enPhrasePages)){
      manageContentList.add(ManageAuthMenuModel(
        name: "短语",
        subtitle: "管理英语短语库，包含搭配、用法、语义等信息",
        authCode: ManageAuthCode.enPhrasePages,
        route: Routes.MANAGE_PHRASE,
      ));
    }

    if(ManageAuthUtils.isAuth(ManageAuthCode.enSentencePages)){
      manageContentList.add(ManageAuthMenuModel(
        name: "句子",
        subtitle: "管理英语句子库，包含语法结构、语义分析等",
        authCode: ManageAuthCode.enSentencePages,
        route: Routes.MANAGE_SENTENCE,
      ));
    }

    if(ManageAuthUtils.isAuth(ManageAuthCode.enTextPages)){
      manageContentList.add(ManageAuthMenuModel(
        name: "文章",
        subtitle: "管理英语文章库，包含段落结构、难度分级等",
        authCode: ManageAuthCode.enTextPages,
        route: Routes.MANAGE_ARTICLE,
      ));
    }

    if(ManageAuthUtils.isAuth(ManageAuthCode.enSongPages)){
      manageContentList.add(ManageAuthMenuModel(
        name: "歌曲",
        subtitle: "管理英语歌曲库，查看歌词、体裁与主题等信息",
        authCode: ManageAuthCode.enSongPages,
        route: Routes.MANAGE_SONG,
      ));
    }

    if(ManageAuthUtils.isAuth(ManageAuthCode.enRevealsPages)){
      manageContentList.add(ManageAuthMenuModel(
        name: "甄听",
        subtitle: "甄选优质听力素材，包含精听、泛听与磨耳朵等资源",
        authCode: ManageAuthCode.enRevealsPages,
        route: Routes.MANAGE_SUBSCRIBE,
      ));
    }

    if(ManageAuthUtils.isAnyAuth([
      ManageAuthCode.dramaVoiceEmotionPages,
      ManageAuthCode.dramaVoiceTimbreColorList,
      ManageAuthCode.dramaPersonaPages,
      ManageAuthCode.dramaScriptThemeList,
      ManageAuthCode.dramaScriptGenreList,
      ManageAuthCode.dramaScriptGroupPages,
      ManageAuthCode.dramaScriptPages,
      ManageAuthCode.dramaAudioProjectPages,
      ManageAuthCode.dramaVisualProjectPages,
    ])){
      manageContentList.add(ManageAuthMenuModel(
        name: "甄读",
        subtitle: "甄选优质阅读素材，包含角色、剧本、项目的管理",
        authCode: "",
        route: Routes.MANAGE_ZHENDU_CONSOLE,
      ));
    }

    
    // ================= 资源工具 =======================
    if(ManageAuthUtils.isAuth(ManageAuthCode.audioCustomGenerate)){
      manageResourceToolsList.add(ManageAuthMenuModel(
        name: "音频生成",
        subtitle: "自由选择音色生成音频，支持文本/音标模式",
        authCode: ManageAuthCode.audioCustomGenerate,
        route: Routes.MANAGE_GENERATE_AUDIO,
      ));
    }

  }

  /// 跳转到课程列表
  void toPage(ManageAuthMenuModel data){
    if(data.route.isEmpty) return;
    ManagePageRegistry.jumpTo(data.route);
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

}
