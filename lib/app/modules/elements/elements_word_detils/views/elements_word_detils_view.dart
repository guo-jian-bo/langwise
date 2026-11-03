import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../utils/utils.dart';
import '../../common/elements_public_widgets.dart';
import '../../elements_detils/controllers/elements_detils_controller.dart';
import '../../model/elements_card_detils_tab_model.dart';
import '../../model/elements_jump_module_type.dart';
import '../../model/elements_tabview_tag_model.dart';
import '../controllers/elements_word_detils_controller.dart';

class ElementsWordDetilsView extends GetView<ElementsWordDetilsController> {
  final String tagText;
  const ElementsWordDetilsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  @override
  Widget build(BuildContext context) {
    
    return Obx((){
      return LockOverlayWidget(
        rights: controller.cardWordDetils.value.rights,
        child: Scaffold(
          backgroundColor: AppTheme.cBgPrimary,
          body: Container(
            alignment: Alignment.topCenter,
            child: Container(
              padding: EdgeInsets.only(
                top: 24.wMin + MediaQuery.of(context).padding.top,
                left: 40.wMin,
                right: 40.wMin,
              ),
              child: Column(
                children: [
                  const BackWidget(title: "单词卡片"),
                  Expanded(
                    child: Obx((){
                      if(controller.isLoading.value) return Container();
                      return Row(
                        spacing: 36.wMin,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElementsLeftInfoWidget(
                            maxLines: 1,
                            value: controller.cardWordDetils.value.content??"",
                            imageUrl: controller.leftCardImage.value,
                            star: controller.cardPosList[controller.currentTabIndex.value].cardStar,
                            stat: controller.cardPosList[controller.currentTabIndex.value].stat,
                            pronunciations: controller.cardPosList[controller.currentTabIndex.value].pronunciations,
                          ),
                          Expanded(child: _buildInfoWidget()),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: _buildMemberButtonWidget(context),
        ),
      );
    });

  }

  Widget _buildInfoWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx((){
          
          return SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                Row(
                  spacing: 10.wMin,
                  children: [
                    Expanded(
                      child: ElementsTabBarWidget(
                        controller: controller.tabController,
                        tabList: controller.tabListData.map((e) => e.potTitle).toList(),
                      ),
                    ),
                    const DisplayLanguageFilteringIconWidget(),
                  ],
                ),
                Container(
                  height: 1.wMin,
                  color: AppTheme.cBgTertiary,
                ),
              ],
            ),
          );
        }),
        SizedBox(height: 16.wMin),
        Expanded(
          child: TabBarView(
            controller: controller.tabController,
            children: List.generate(controller.tabListData.length, (index){
              return ElementsTabViewWidget(tagText: tagText, tabData: controller.tabListData[index], tabIndex: index);
            }),
          ),
        ),
      ],
    );
  }



  /// 记单词按钮
  Widget _buildMemberButtonWidget(BuildContext context){
    return Obx((){
      if(controller.cardPosList.isEmpty) return Container();
      return SimpleDictionaryMemoryButton(
        buttonText: "记单词",
        content: controller.cardWordDetils.value.content,
        parameter: [
          SimpleDictionaryAddCardParm(
            uid: controller.cardPosList[controller.currentTabIndex.value].contentId,
            type: controller.cardPosList[controller.currentTabIndex.value].contentType,
          ),
        ],
        onSuccess: () {
          if(Get.isRegistered<ElementsDetilsController>()){ 
            ElementsDetilsController controller = Get.find<ElementsDetilsController>();
            controller.refreshStudyListData();
          }
        },
      );
    });

  }

}





class ElementsTabViewWidget extends StatefulWidget {
  final String tagText;
  final ElementsCardDetilsTabModel tabData;
  final int tabIndex;
  const ElementsTabViewWidget({super.key, required this.tagText, required this.tabData, required this.tabIndex});

  @override
  State<ElementsTabViewWidget> createState() => _ElementsTabViewWidgetState();
}

class _ElementsTabViewWidgetState extends State<ElementsTabViewWidget> with AutomaticKeepAliveClientMixin{
  late ElementsWordDetilsController controller;
  List<ElementsTabViewTagModel> tagList = [];

  /// 发音
  List<PronunciationsEntity?> pronunciations = [];
  /// 释义
  List<CardWordDetilsEntityPosListSemantics?> semantics = [];
  /// 语法特性
  List<CardWordDetilsEntityPosListGrammatical?> grammatical = [];
  /// 单词来源
  CardWordDetilsEntityPosListStory? story;
  /// 词源分析
  CardWordDetilsEntityPosListMorphology? morphology;
  /// 记忆提示
  CardWordDetilsEntityPosListMemory? memory;
  /// 短语
  List<ElementsCardEntityDatas?> phrases = [];
  /// 短语习语
  List<ElementsCardEntityDatas?> phraseIdioms = [];

  @override
  void initState() {
    super.initState();
    controller = Get.find<ElementsWordDetilsController>(tag: widget.tagText);
    initData();
  }

  void initData(){
    tagList.clear();
    if (widget.tabIndex >= 0 && widget.tabIndex < controller.cardPosList.length) {
    CardWordDetilsEntityPosList posList = controller.cardPosList[widget.tabIndex];
    pronunciations = posList.pronunciations??[];
    semantics = posList.semantics??[];
    grammatical = posList.grammatical??[];
    story = posList.story;
    morphology = posList.morphology;
    memory = posList.memory;
    phrases = posList.phrases??[];
    phraseIdioms = posList.phraseIdioms??[];
    if(pronunciations.isNotEmpty){
      tagList.add(ElementsTabViewTagModel(
        index: tagList.length, 
        type: ElementsJumpModuleType.PRONUNCIATION, 
        title: "单词发音",
        color: const Color(0xff38BDF8),
      ));
    }
    if(semantics.isNotEmpty){
      tagList.add(ElementsTabViewTagModel(
        index: tagList.length, 
        type: ElementsJumpModuleType.SEMANTICS, 
        title: "单词释义",
        color: const Color(0xffEC4899),
      ));
    }
    if(grammatical.isNotEmpty){
      tagList.add(ElementsTabViewTagModel(
        index: tagList.length, 
        type: ElementsJumpModuleType.GRAMMAR_FEATURES, 
        title: "语法特性",
        color: const Color(0xffA78BFA),
      ));
    }
    if(morphology != null){
      tagList.add(ElementsTabViewTagModel(
        index: tagList.length, 
        type: ElementsJumpModuleType.ETYMOLOGY, 
        title: "词根词缀",
        color: const Color(0xff00D492),
      ));
    }
    if(story != null){
      tagList.add(ElementsTabViewTagModel(
        index: tagList.length, 
        type: ElementsJumpModuleType.BACKSTORY, 
        title: "来源故事",
        color: const Color(0xffFB7185),
      ));
    }
    if(memory != null){
      tagList.add(ElementsTabViewTagModel(
        index: tagList.length, 
        type: ElementsJumpModuleType.MNEMONICS, 
        title: "记忆提示",
        color: const Color(0xffFB923C),
      ));
    }
    if(phrases.isNotEmpty || phraseIdioms.isNotEmpty){
      tagList.add(ElementsTabViewTagModel(
        index: tagList.length, 
        type: ElementsJumpModuleType.PHRASES_IDIOMS, 
        title: "短语习语",
        color: const Color(0xffE879F9),
      ));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      jumpTo();
    });
    }
  }

  void jumpTo(){

    // 先判断模块的跳转定位
    String? module = controller.cardWordDetils.value.module;
    if((module??"").isNotEmpty && module != ElementsJumpModuleType.PRONUNCIATION){
      ElementsTabViewTagModel? tagModel;
      for(int i = 0; i < tagList.length; i++){
        if(tagList[i].type == module){
          tagModel = tagList[i];
          break;
        }
      }
      if(tagModel == null) return;
      Future.delayed(const Duration(seconds: 1), () {
        int jumpIndex = (tagModel!.index??0) + semantics.length - 1;
        if(tagModel.index == 0) jumpIndex = 0;
        widget.tabData.tagTabbarIndex.value = (tagModel.index??0);
        controller.changeTagTabbarIndex(widget.tabIndex, jumpIndex);
      });
    }

    if(module != ElementsJumpModuleType.PRONUNCIATION) return;
     
    // 然后判断释义id
    int? jumpSemanticId = controller.cardWordDetils.value.semanticId;
    if(jumpSemanticId != null) {
      Future.delayed(const Duration(seconds: 1), (){
        for(int i = 0; i < semantics.length; i++){
          if(semantics[i]?.uid == jumpSemanticId){
            controller.changeTagTabbarIndex(widget.tabIndex, i + 1);
            break;
          }
        }
      });
    }
    
  }



  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    List<Widget> widgetList = [];

    if(pronunciations.isNotEmpty){
      widgetList.add(ElementsPronunciationModuleWidget(
        pronunciations: pronunciations, 
        content: controller.cardWordDetils.value.content??"",
        contentType: controller.cardWordDetils.value.contentType,
        contentId: widget.tabData.contentId,
      ));
    }

      if(semantics.isNotEmpty){
        for(int i = 0; i < semantics.length; i++){
          widgetList.add(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Visibility(
                visible: i == 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ElementsDashedLineWidget(),
                    SizedBox(height: 40.wMin),
                    ElemenetsTitleH1Widget(
                      showDot: true,
                      dotColor: const Color(0xffEC4899),
                      titles: [
                        LanguageText(text: "Definition", lang: "en"),
                        LanguageText(text: "单词释义", lang: "zh"),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 16.wMin),
                child: ElementsInterpretationModuleItemWidget(
                  semantics: semantics,
                  index: i,
                  onVisibilityChanged: (index, visibleFraction) {
                    controller.changeLeftImage(widget.tabIndex, index);
                  },
                ),
              ),
            ],
          ));
        }
        
      }
      
      if(grammatical.isNotEmpty){
        widgetList.add(ElementsGrammarCharacteristicsModuleWidget(
          grammatical: grammatical,
          pos: widget.tabData.pos,
          colorConfig: Get.find<ConfigController>().colorConfigs.value.pos,
          word: controller.cardWordDetils.value.content,
          onVisibilityChanged: (visibleFraction) {
            controller.setLeftImageForGrammaticale(widget.tabIndex);
          },
        ));
      }
      
      if(morphology != null){
        widgetList.add(ElementsEtymologicalAnalysisModuleWidget(
          morphology: morphology,
          colorConfig: Get.find<ConfigController>().colorConfigs.value.pos,
          onTap: (morpheme) {
            controller.toMorphemeDetils(context, morpheme, widget.tabData.pos);
          },
        ));
      }
      if(story != null){
        widgetList.add(ElementsSourceStoryWidget(
          data: ElementsPhraseOriginModel(
            imageUrl: story?.imageUrl,
            descriptions: story?.descriptions??[],
          ),
        ));
      }
      if(memory != null){
        widgetList.add(ElementsMemoryTipWidget(
          memory: memory,  
        ));
        // widgetList.add(Container());
      }
      if(phrases.isNotEmpty || phraseIdioms.isNotEmpty){
        widgetList.add(ElementsPhraseModuleWidget(
          phrases: phrases,
          phraseIdioms: phraseIdioms,
        ));
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx((){
            return ElementsTagTapWidget(
              tabs: tagList,
              currentIndex: widget.tabData.tagTabbarIndex.value,
              onTap: (index) {
                int jump = tagList[index].index??0;
                int jumpIndex = jump;
                if(index >= 2){
                  jumpIndex = jump + semantics.length - 1;
                }
                if(index == 0) jumpIndex = 0;
                widget.tabData.tagTabbarIndex.value = index;
                controller.changeTagTabbarIndex(widget.tabIndex, jumpIndex);
              },
            );
          }),
          SizedBox(height: 16.wMin),
          Expanded(
            child: ListViewObserver(
              controller: widget.tabData.observerController,
              triggerOnObserveType: ObserverTriggerOnObserveType.directly,
              onObserve: (result) {
                if(result.firstChild == null) return;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  try {
                    int firstChildIndex = result.firstChild!.index;
                    if(firstChildIndex != 0){
                      if(firstChildIndex <= semantics.length && firstChildIndex != 0){
                        firstChildIndex = 1;
                      }else{
                        firstChildIndex = firstChildIndex - semantics.length + 1;
                      }
                    }
                    
                    widget.tabData.tagTabbarIndex.value = firstChildIndex;
                    double scrollOffset = result.scrollOffset;
                    double maxScrollExtent = widget.tabData.scrollController.position.maxScrollExtent;
                    if(scrollOffset >= maxScrollExtent - 200.wMin){
                      widget.tabData.tagTabbarIndex.value = tagList.length - 1;
                    }
                  } catch (e) {
                    // 忽略错误，防止在组件大小未确定时进行操作
                  }
                });
                
              },
              child: ListView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom,
                ),
                physics: const ClampingScrollPhysics(),
                controller: widget.tabData.scrollController,
                children: widgetList,
              ),
            ),
          ),
        ],
      );
  }



}
