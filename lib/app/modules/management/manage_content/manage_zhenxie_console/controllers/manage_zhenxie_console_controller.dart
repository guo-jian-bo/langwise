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

  /// 句子功能列表
  final RxList<ManageAuthMenuModel> sentenceMenuList = <ManageAuthMenuModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    initAuth();
  }

  void initAuth(){

    // ============ 句子 ================
    sentenceMenuList.add(ManageAuthMenuModel(
      name: "句型蓝图",
      subtitle: "一句怎样成立：着色模板、受控槽、谓语 Profile、代表句；可生长句型在此展开金字塔",
      authCode: "",
      route: Routes.MANAGE_PATTERN_BLUEPRINT,
    ));

    sentenceMenuList.add(ManageAuthMenuModel(
      name: "生长金字塔",
      subtitle: "蓝图能力入口：进入句型蓝图，并默认只看 supportsPyramid 的可生长句型",
      authCode: "",
      route: Routes.MANAGE_PATTERN_BLUEPRINT,
      params: {"supportsPyramid": true},
    ));

    sentenceMenuList.add(ManageAuthMenuModel(
      name: "句型对照",
      subtitle: "跨壳单轴对照：肯否 / 问法 / 语态 / 引导词 / 近义说法……一次只拧一个开关",
      authCode: "",
      route: Routes.MANAGE_SENTENCE_PATTERN_COMPARE,
    ));

    sentenceMenuList.add(ManageAuthMenuModel(
      name: "句间配链",
      subtitle: "出句型、进句间：问答、因果、举例、转折等配对与纵向推进",
      authCode: "",
      route: Routes.MANAGE_SENTENCE_PAIR,
    ));

    sentenceMenuList.add(ManageAuthMenuModel(
      name: "语法全景",
      subtitle: "另一维度：二维及以上正交坐标；时 × 体与对比焦点（非单轴换壳）",
      authCode: "",
      route: Routes.MANAGE_GRAMMAR_PANORAMA,
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
