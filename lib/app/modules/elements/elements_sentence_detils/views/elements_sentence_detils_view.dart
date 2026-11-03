import 'package:flutter/material.dart';
import 'package:langwise/utils/utils.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../theme/theme.dart';
import '../../common/elements_public_widgets.dart';
import '../../elements_detils/controllers/elements_detils_controller.dart';
import '../controllers/elements_sentence_detils_controller.dart';
import '../../../../../common/widgets/widgets.dart';
import 'elements_sentence_pronunciation_widget.dart';
import 'elements_structure_widget.dart';
import 'elements_syntactic_analysis_widget.dart';

class ElementsSentenceDetilsView extends GetView<ElementsSentenceDetilsController> {
  final String tagText;
  const ElementsSentenceDetilsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  @override
  Widget build(BuildContext context) {
    return Obx((){
      return LockOverlayWidget(
        rights: controller.sentencesDetils.value.rights,
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
                  const BackWidget(title: "句子卡片"),
                  Expanded(
                    child: Obx((){
                      if(controller.isLoading.value) return Container();
                      return Row(
                        spacing: 40.wMin,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElementsLeftInfoWidget(
                            value: controller.sentencesDetils.value.content ?? "",
                            imageUrl: controller.sentencesDetils.value.imageUrl,
                            stat: controller.sentencesDetils.value.stat,
                            fontSize: 24.wMin,
                            fontWeight: FontWeight.w500,
                            pronunciations: controller.sentencesDetils.value.pronunciations,
                          ),
                          Expanded(child: _buildInfoWidget(context)),
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

  /// 记句子按钮
  Widget _buildMemberButtonWidget(BuildContext context){
    return Obx((){
      if(controller.sentencesDetils.value.content == null) return Container();
      return SimpleDictionaryMemoryButton(
        buttonText: "记句子",
        content: controller.sentencesDetils.value.content,
        directCollect: true,
        parameter: [
          SimpleDictionaryAddCardParm(
            uid: controller.sentencesDetils.value.contentId,
            type: controller.sentencesDetils.value.contentType,
            semanticId: controller.sentencesDetils.value.semanticId,
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

  Widget _buildInfoWidget(BuildContext context){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ElementsTagTapWidget(
              tabs: controller.tagList,
              currentIndex: controller.tagTabbarIndex.value,
              onTap: (index) {
                int jump = controller.tagList[index].index??0;
                // controller.tagTabbarIndex.value = index;
                controller.changeTagTabbarIndex(jump);
              },
            ),
            ),
            const DisplayLanguageFilteringIconWidget(),
          ],
        ),
        SizedBox(height: 14.wMin),
        Expanded(
          child: ListViewObserver(
            triggerOnObserveType: ObserverTriggerOnObserveType.directly,
            onObserve: (result) {
              if(result.firstChild == null) return;
              int firstChildIndex = result.firstChild!.index;
              int jumpIndex = firstChildIndex;
              if(firstChildIndex > 1){
                jumpIndex = 1;
              }
              controller.tagTabbarIndex.value = jumpIndex;
              
            },
            child: Obx((){
              return ListView(
                controller: controller.autoScrollController,
                physics: controller.isHoveringGraph.value ? const NeverScrollableScrollPhysics() : const ClampingScrollPhysics(),
                padding: EdgeInsets.only(
                  bottom: 100.wMin + MediaQuery.of(context).padding.bottom,
                ),
                children: [
                  _buildSentencePronunciationWidget(),
                  _buildDetilsTitle(),
                  SizedBox(height: 32.wMin),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.wMin),
                      border: Border.all(width: 1.wMin, color: AppTheme.cBorderSecondary),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStructuralSyntaxTabWidget(),
                        Obx((){
                          if(controller.structuralSyntaxTabbarIndex.value == 0){
                            return ElementsStructureWidget(tagText: tagText);
                          }else{
                            return ElementsSyntacticAnalysisWidget(tagText: tagText);
                          }
                        }),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.wMin),
                ],
              );
            }),
          ),
        ),
        
      ],
    );
   
  }

  /// 结构/句法分析tab
  Widget _buildStructuralSyntaxTabWidget(){

    final List<String> tabs = ["结构分析(Structure Analysis)", "句法分析(Syntactic Analysis)"];

    Widget _buildTab(int index){
      return Expanded(
        child: TapScaleWidget(
          onTap: (){
            controller.changeStructuralSyntaxTabbarIndex(index);
          },
          sclae: 1.01,
          child: Container(
            height: 104.wMin,
            alignment: Alignment.center,
            color: Colors.transparent,
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 100),
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w600,
                color: controller.structuralSyntaxTabbarIndex.value == index ? AppTheme.cTextPrimary : AppTheme.cTextTertiary,
              ),
              child: Text(tabs[index]),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1.wMin, color: AppTheme.cBorderSecondary),
        ),
      ),
      child: Row(
        children: [
          _buildTab(0),
          Container(width: 1.wMin, height: 56.wMin, color: AppTheme.cBorderSecondary),
          _buildTab(1),
        ],
      ),
    );
  }

  /// 句子发音
  Widget _buildSentencePronunciationWidget(){
    return AutoScrollTag(
      key: const ValueKey(0),
      controller: controller.autoScrollController,
      index: 0,
      child: Container(
        margin: EdgeInsets.only(top: 10.wMin),
        child: ElementsSentencePronunciationWidget(
          pronunciations: controller.sentencesDetils.value.pronunciations,
          contentType: controller.sentencesDetils.value.contentType,
          contentId: controller.sentencesDetils.value.contentId,
          content: controller.sentencesDetils.value.content,
          onTap: (index){
            controller.englishAmericanType.value = index;
          },
          englishAmericanType: controller.englishAmericanType.value,
        ),
      ),
    );
  }
  


  /// 详情标题(句子释义)
  Widget _buildDetilsTitle(){
    CardSentencesDetilsEntity detils = controller.sentencesDetils.value;
    ConfigController configController = Get.find<ConfigController>();
    return AutoScrollTag(
      key: const ValueKey(1),
      controller: controller.autoScrollController,
      index: 1,
      child: Column(
        children: [
          SizedBox(height: 40.wMin),
          const ElementsDashedLineWidget(),
          SizedBox(height: 40.wMin),
          ElemenetsTitleH1Widget(
            showDot: true,
            dotColor: const Color(0xffEC4899),
            titles: [
              LanguageText(text: "Definition", lang: "en"),
              LanguageText(text: "句子释义", lang: "zh"),
            ],
          ),
          SizedBox(height: 32.wMin),
          Container(
            margin: EdgeInsets.only(left: 16.wMin),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Visibility(
                  visible: controller.sentencesDetils.value.difficulty != null,
                  child: Container(
                    margin: EdgeInsets.only(right: 8.wMin),
                    child: StatusTagDifficultyWidget(
                      difficulty: controller.sentencesDetils.value.difficulty,
                      language: configController.userSetting.value.learningLang,
                      fontSize: 24.wMin,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.sentencesDetils.value.content??"",
                        style: TextStyle(
                          fontSize: 28.wMin,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.cTextPrimary,
                          height: 1.1,
                        ),
                      ),
                      Visibility(
                        visible: configController.userSetting.value.expandLang != LangPreference.original && configController.userSetting.value.expandLang != LangPreference.none,
                        child: Container(
                          margin: EdgeInsets.only(top: 6.wMin),
                          child: Text(
                            controller.sentencesDetils.value.definition ?? "",
                            style: TextStyle(
                              fontSize: 24.wMin,
                              fontWeight: FontWeight.w400,
                              color: AppTheme.cTextSecondary,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.wMin),
                      Row(
                        spacing: 8.wMin,
                        children: [
                          _buildTagWidget(detils.sentenceTypeBasic, detils.sentenceTypeBasicName, 0),//基本类型
                          _buildTagWidget(detils.sentenceTypeFunctional, detils.sentenceTypeFunctionalName, 1),//功能类型
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagWidget(String? tag, List<LanguageText?>? texts, int index){
    LanguageConfigColorModel? colorConfig;

    List<LanguageConfigColorEntityInfo?>? basicLevels = Get.find<ConfigController>().colorConfigs.value.basicLevels;
    List<LanguageConfigColorEntityInfo?>? functionalLevels = Get.find<ConfigController>().colorConfigs.value.functionalLevels;


    if(index == 0){
      colorConfig = StatusUtils.getConfigColor(basicLevels, tag);
    }else if(index == 1){
      colorConfig = StatusUtils.getConfigColor(functionalLevels, tag);
    }
    if((tag??"").isEmpty && (texts??[]).isEmpty) return Container();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.wMin),
        color: colorConfig?.color?.bgColor,
        border: Border.all(width: 1.wMin, color: colorConfig?.color?.borderColor??Colors.transparent),
      ),
      child: Obx((){
        List<LanguageText> glossList = LearningLangUtils.getShowLBList(texts);
        return Text(
          glossList.map((e) => e.text).join(" "),
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w400,
            color: colorConfig?.color?.textColor,
          ),
        );
      }),
    );
  }

}
