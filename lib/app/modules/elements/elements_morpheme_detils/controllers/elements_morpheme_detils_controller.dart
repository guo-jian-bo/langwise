
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'package:langwise/common/https/https.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../utils/utils.dart';
import '../../../../routes/tag_routes.dart';
import '../../dialog/elements_affix_dialog.dart';
import '../../dialog/elements_word_card_dialog.dart';
import '../../../../../common/enum/elements_card_type.dart';
import '../../model/elements_detils_data_model.dart';
import '../../model/elements_jump_module_type.dart';
import '../../../../routes/routes.dart';
import '../../../../routes/routes_breadcrumb_utils.dart';

class ElementsMorphemeDetilsController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  ElementsMorphemeDetilsController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.EN_MORPHEME_DETAIL;

  @override
  String get breadcrumbTitle => "词素卡片";

  // 传进来的参数
  String? content;
  String? pos;
  String? type;

  final List<IconDropdownCheckData> gridMenuList = [
    IconDropdownCheckData(title: "星云视图", iconSvg: "assets/svg/elements/icon_nebula.svg"),
    IconDropdownCheckData(title: "网格视图", iconSvg: "assets/svg/elements/icon_grid.svg"),
  ];

  final List<IconDropdownCheckData> posMenuList = [
    IconDropdownCheckData(title: "全部词性"),
  ];

  /// 网格/星云视图
  final RxInt gridMenuIndex = 0.obs;

  /// 词性分类
  final RxInt posMenuIndex = 0.obs;

  /// 详情
  final Rx<CardMorphemeDetilsEntity> morphemeDetils = CardMorphemeDetilsEntity().obs;
  /// 星云视图数据
  final RxList<OrbitData> nebulaData = <OrbitData>[].obs;

  /// 网格视图offset
  int gridOffset = 0;
  /// 网格视图limit
  final int gridLimit = 40;
  int gridCount = 0;
  /// 网格视图数据
  final RxList<CardMorphemeWordEntityDatas> gridDatas = <CardMorphemeWordEntityDatas>[].obs;
  /// 网格视图
  final ScrollController gridScrollController = ScrollController();

  /// 网格视图加载中
  final RxBool gridLoading = true.obs;
  
  
  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    if(Get.arguments != null){
      content = Get.arguments['content'];
      pos = Get.arguments['pos'];
      type = Get.arguments['type'];
      initData();
    }

    gridScrollController.addListener(() {
      if (gridScrollController.position.pixels >= gridScrollController.position.maxScrollExtent - 100 && !gridScrollController.position.outOfRange) {
        if((gridOffset + gridLimit) < gridCount && !gridLoading.value) {
          gridLoading.value = true;
          gridOffset += gridLimit;
          getWordList();
        }
      }
    });
  }

  Future<void> initData() async{
    try {
      ToastUtils.showLoading();
      await getRightCount();
      await getDetils();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 获取权益数量
  Future<void> getRightCount() async{
    RightCountDetailsEntity? rightCountDetailsEntity = await UserRequest.getCardRightCount();
    if(rightCountDetailsEntity == null) return;
    int extendCard = rightCountDetailsEntity.extendCard??0;
    if(extendCard == 0) return;
    ToastUtils.showToast(text: "您还有$extendCard次探索卡片", type: ToastType.warning);
  }


  /// 获取详情
  Future<void> getDetils() async{
    if(content == null) return;
    Map<String, dynamic> parameters = {
      "content": content,
      "pos": pos,
      "type": type,
    };
    CardMorphemeDetilsEntity? res = await ElementsRequest.getMorphemeDetils(parameters);
    if(res == null) return;
    morphemeDetils.value = res;
    _assembleNebulaData();
  }

  /// 获取单词列表
  Future<void> getWordList() async{
    if(content == null) return;

    Map<String, dynamic> parameters = {
      "content": content,
      "pos": posMenuIndex.value == 0 ? null : posMenuList[posMenuIndex.value].value,
      "type": type,
      "offset": gridOffset,
      "limit": gridLimit,
    };
    ToastUtils.showLoading();
    CardMorphemeWordEntity? res = await ElementsRequest.getMorphemeWordList(parameters);
    ToastUtils.hideLoading();
    if(res == null) return;
    List<CardMorphemeWordEntityDatas?> datas = res.datas??[];
    for(int i = 0; i < datas.length; i++){
      if(datas[i] == null) continue;
      gridDatas.add(datas[i]!);
    }
    gridCount = res.count??0;
    gridLoading.value = false;
  }

  /// 组装星云视图数据
  void _assembleNebulaData(){
    Map<String, List<PlanetData>> orbitMap = {};
    List<CardMorphemeDetilsEntityContentList?> contentList = morphemeDetils.value.contentList??[];
    
    for(int i = 0; i < contentList.length; i++){
      if(contentList[i] == null) continue;
      if(morphemeDetils.value.type?.toUpperCase() == "ROOT") {
        if(contentList[i]!.content == content) continue;
      }
      String? pos = contentList[i]!.pos;
      String? posTitle = contentList[i]!.posTitle;

      if(pos == null || pos.isEmpty) continue;
      orbitMap[pos] ??= [];
      if(orbitMap[pos]!.length >= 10) continue;//一圈最优10个 如果是10个 最后排 
      orbitMap[pos]!.add(PlanetData(
        word: contentList[i]!.content??"",
        // translation: contentList[i]!.definition,
        gloss: contentList[i]!.gloss,
        pos: pos,
        posTitle: posTitle??"",
        data: contentList[i],
      ));
    }

    String? selectPos = posMenuList[posMenuIndex.value].value;

    posMenuList.clear();
    nebulaData.clear();
    posMenuList.add(IconDropdownCheckData<String>(
      title: "全部词性",
    ));

    
    // 定好最小3圈 最多8圈 
    // 如果只有一个词性 那么分为3个轨道
    // 如果有两个词性 分为4个轨道 

    orbitMap.forEach((key, value) {
      if(selectPos == null || selectPos == key){
        nebulaData.add(OrbitData(
          pos: key,
          posTitle: value.first.posTitle,
          planets: value,
        ));
      }
      
      posMenuList.add(IconDropdownCheckData<String>(
        title: value.first.posTitle??"",
        value: key,
      ));
    });

    if(nebulaData.length == 1){
      // 如果只有一个词性，分为3个轨道
      OrbitData originalOrbit = nebulaData.first;
      int wordLen = originalOrbit.planets.length;
      if (wordLen > 3) {
        // 计算每个轨道应该分配的行星数量
        int planetsPerOrbit = (wordLen / 3).ceil();
        
        // 创建3个轨道
        List<PlanetData> allPlanets = List.from(originalOrbit.planets);
        nebulaData.clear();
        
        for (int i = 0; i < 3 && allPlanets.isNotEmpty; i++) {
          // 为每个轨道分配行星
          int endIndex = math.min(planetsPerOrbit, allPlanets.length);
          List<PlanetData> orbitPlanets = allPlanets.sublist(0, endIndex);
          allPlanets.removeRange(0, endIndex);
          
          // 添加轨道
          nebulaData.add(OrbitData(
            pos: originalOrbit.pos,
            posTitle: originalOrbit.posTitle,
            planets: orbitPlanets,
          ));
        }
      }
      nebulaData.sort((a, b) => b.planets.length.compareTo(a.planets.length)); // 先尝试少的放最外圈
    }else if(nebulaData.length == 2){
      // 如果有两个词性，分为4个轨道
      List<OrbitData> originalOrbits = List.from(nebulaData);
      nebulaData.clear();
      
      for (OrbitData orbit in originalOrbits) {
        int wordLen = orbit.planets.length;
        if (wordLen > 2) {
          // 计算每个轨道应该分配的行星数量
          int planetsPerOrbit = (wordLen / 2).ceil();
          
          // 创建2个轨道
          List<PlanetData> allPlanets = List.from(orbit.planets);
          
          for (int i = 0; i < 2 && allPlanets.isNotEmpty; i++) {
            // 为每个轨道分配行星
            int endIndex = math.min(planetsPerOrbit, allPlanets.length);
            List<PlanetData> orbitPlanets = allPlanets.sublist(0, endIndex);
            allPlanets.removeRange(0, endIndex);
            
            // 添加轨道
            nebulaData.add(OrbitData(
              pos: orbit.pos,
              posTitle: orbit.posTitle,
              planets: orbitPlanets,
            ));
          }
        } else {
          // 如果行星数量很少，保持原样
          nebulaData.add(orbit);
        }
      }
    }else{
      nebulaData.sort((a, b) => b.planets.length.compareTo(a.planets.length)); // 先尝试少的放最外圈
    }

    
   
  }

  /// 切换词性
  void switchPos(int index){
    posMenuIndex.value = index;
    _assembleNebulaData();
    if(gridMenuIndex.value == 1){
      gridOffset = 0;
      gridDatas.clear();
      gridLoading.value = true;
      getWordList();
    }
    
  }

  /// 切换视图
  Future<void> switchView(int index) async{
    
    if(index == 1){
      gridOffset = 0;
      gridDatas.clear();
      gridLoading.value = true;
      await getWordList();
    }
    
    gridMenuIndex.value = index;
  }

  /// 显示前后缀弹窗
  Future<void> showAffixDialog(BuildContext context) async{
    if(morphemeDetils.value.type?.toUpperCase() == "ROOT"){
      ElementsCardEntityDatas? rootContent = morphemeDetils.value.rootContent;
      if(rootContent == null) return;
      await ElementsWordCardDialog.show(
        context: context,
        data: ElementsDetilsDataModel(
          type: ElementsCardType.fromRawValue(rootContent.contentType??""),
          data: rootContent,
        ),
      );
    }else{
      await ElementsAffixDialog.show(
        context: context,
        data: morphemeDetils.value,
      );
    }
    
  }

  /// 点击行星
  Future<void> onTapWord(BuildContext context, PlanetData data) async{
    CardMorphemeDetilsEntityContentList? wordData = data.data;
    if(wordData == null) return;
    final List<int?>? semanticIds = wordData.semanticIds?.whereType<int>().toList();
    
    TagRoutes.toNamed(
      Routes.EN_WORD_DETAIL,
      arguments: {
        "contentId": wordData.contentId,
        "semanticIds": semanticIds,
        "jumpType": ElementsJumpModuleType.ETYMOLOGY,
      },
    );
  }

  /// 网格视图 点击图片
  Future<void> toWordDetils(BuildContext context, CardMorphemeWordEntityDatas? data) async{
    final List<int?>? semanticIds = data?.semanticIds?.whereType<int>().toList();

    TagRoutes.toNamed(
      Routes.EN_WORD_DETAIL,
      arguments: {
        "contentId": data?.contentId,
        "semanticIds": semanticIds,
        "jumpType": ElementsJumpModuleType.ETYMOLOGY,
      },
    );

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
