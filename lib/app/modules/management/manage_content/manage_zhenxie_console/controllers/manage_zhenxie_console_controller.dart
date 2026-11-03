import 'package:get/get.dart';

import '../../../../../routes/routes.dart';
import '../../../models/models.dart';
import '../../../utils/utils.dart';

class ManageZhenxieConsoleController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageZhenxieConsoleController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_ZHENXIE_CONSOLE;

  @override
  String get breadcrumbTitle => '甄写管理台';

  /// 单词功能列表
  final RxList<ManageAuthMenuModel> wordMenuList = <ManageAuthMenuModel>[].obs;
  
  /// 短语功能列表
  final RxList<ManageAuthMenuModel> phraseMenuList = <ManageAuthMenuModel>[].obs;

  /// 句子功能列表
  final RxList<ManageAuthMenuModel> sentenceMenuList = <ManageAuthMenuModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    initAuth();
  }

  void initAuth(){

    // ============ 单词 ================
    wordMenuList.add(ManageAuthMenuModel(
      name: "Core Image / 多义",
      subtitle: "form → core image → semantic branch → semanticId 教学包装与高频多义管理",
      authCode: "",
      route: "",
    ));

    wordMenuList.add(ManageAuthMenuModel(
      name: "曲折变化",
      subtitle: "grammatical profiles / inflections：名词数量、形副等级、动词微场景换形",
      authCode: "",
      route: Routes.MANAGE_WORD_INFLECTION,
    ));

    wordMenuList.add(ManageAuthMenuModel(
      name: "构词 Morphology",
      subtitle: "可拆词素网络、morpheme types、不可拆 explanation 边界",
      authCode: "",
      route: Routes.MANAGE_WORD_MORPHOLOGY,
    ));

    wordMenuList.add(ManageAuthMenuModel(
      name: "单词交互预览",
      subtitle: "Core Image Lens / Number Board / Degree Ladder / Verb Scene Grid / Morphology Builder",
      authCode: "",
      route: "",
    ));

    // ============ 短语 ================
    phraseMenuList.add(ManageAuthMenuModel(
      name: "短语对照",
      subtitle: "en_phrase_paradigms：一轴一池，槽位按 valueNid 摊开教例和类比",
      authCode: "",
      route: Routes.ZHENXIE_PHRASE_CONTRAST,
      params: {"isManagement": true},
    ));

    phraseMenuList.add(ManageAuthMenuModel(
      name: "短语配对",
      subtitle: "en_phrase_pairs：一对一套；near_miss 并排放，纠偏正式在前、错式在后",
      authCode: "",
      route: Routes.ZHENXIE_PHRASE_PAIR,
      params: {"isManagement": true},
    ));

    phraseMenuList.add(ManageAuthMenuModel(
      name: "短语搭配组",
      subtitle: "en_phrase_clusters：一池整记；目录槽绑 memberNid，同功能加项不绑槽",
      authCode: "",
      route: Routes.ZHENXIE_PHRASE_MATCH,
      params: {"isManagement": true},
    ));

    phraseMenuList.add(ManageAuthMenuModel(
      name: "短语结构",
      subtitle: "en_phrase_structures / structure_items：块内怎么切（head / particle / 介词…），固定还是可换",
      authCode: "",
      route: Routes.ZHENXIE_PHRASE_STRUCTURE,
      params: {"isManagement": true},
    ));

    phraseMenuList.add(ManageAuthMenuModel(
      name: "入句画像",
      subtitle: "en_phrase_grammatical_profiles / types：整块入句形式；能放进哪个句槽、自己还要不要再接成分",
      authCode: "",
      route: Routes.ZHENXIE_ENTER_SENTENCE,
      params: {"isManagement": true},
    ));

    // ============ 句子 ================
    sentenceMenuList.add(ManageAuthMenuModel(
      name: "句型蓝图",
      subtitle: "一句怎样成立：着色模板、受控槽、谓语 Profile、代表句；可生长句型在此展开金字塔",
      authCode: "",
      route: Routes.ZHENXIE_PATTERN_BLUEPRINT,
      params: {"isManagement": true},
    ));

    sentenceMenuList.add(ManageAuthMenuModel(
      name: "生长金字塔",
      subtitle: "蓝图能力入口：进入句型蓝图，并默认只看 supportsPyramid 的可生长句型",
      authCode: "",
      route: Routes.ZHENXIE_PATTERN_BLUEPRINT,
      params: {"supportsPyramid": true, "isManagement": true},
    ));

    sentenceMenuList.add(ManageAuthMenuModel(
      name: "句型对照",
      subtitle: "跨壳单轴对照：肯否 / 问法 / 语态 / 引导词 / 近义说法……一次只拧一个开关",
      authCode: "",
      route: Routes.ZHENXIE_SENTENCE_PATTERN_COMPARE,
      params: {"isManagement": true},
    ));

    sentenceMenuList.add(ManageAuthMenuModel(
      name: "句间配链",
      subtitle: "出句型、进句间：问答、因果、举例、转折等配对与纵向推进",
      authCode: "",
      route: Routes.ZHENXIE_SENTENCE_PAIR,
      params: {"isManagement": true},
    ));

    sentenceMenuList.add(ManageAuthMenuModel(
      name: "语法全景",
      subtitle: "另一维度：二维及以上正交坐标；时 × 体与对比焦点（非单轴换壳）",
      authCode: "",
      route: Routes.ZHENXIE_GRAMMAR_PANORAMA,
      params: {"isManagement": true},
    ));
    
    
    
  }


  void toPage(ManageAuthMenuModel data){
    if(data.route.isEmpty) return;
    ManagePageRegistry.jumpTo(data.route, arguments: data.params);
  }

  @override
  void onClose() {
    // TODO: 清理逻辑
    super.onClose();
  }
}
