import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:themed/themed.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../utils/utils.dart';
import '../../common/elements_public_widgets.dart';
import '../../common/elements_sentence_analysis_folding_view_widget.dart';
import '../../common/elements_sentence_analysis_grid_view_widget.dart';
import '../controllers/elements_sentence_detils_controller.dart';

class ElementsStructureWidget extends GetView<ElementsSentenceDetilsController> {
  final String tagText;
  /// 结构分析
  const ElementsStructureWidget({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedSize(
                alignment: Alignment.topCenter,
                duration: const Duration(milliseconds: 300),
                child: Obx((){
                  if(controller.structureTabControllerIndex.value == 1) return Container();
                  return _buildGridOrFoldTagWidget();
                }),
              ),
              _buildStructureTableWidget(),
              SizedBox(height: 24.wMin),
              _buildStructureDetailWidget(),
              SizedBox(height: 24.wMin),
            ],
          ),
          
        ],
      ),
    );
  }



  /// 结构详情模块
  Widget _buildStructureDetailWidget(){

    return Obx((){
      List<CardSentencesDetilsEntityClauses?>? clauses = controller.sentencesDetils.value.clauses;
      if(clauses == null || clauses.isEmpty) return Container();
      if(clauses.length < controller.sentenceStructureTableSelectIndex.value) return Container();
      CardSentencesDetilsEntityClauses? clause = clauses[controller.sentenceStructureTableSelectIndex.value];
      if(clause == null) return Container();

      var colorConfigs = Get.find<ConfigController>().colorConfigs.value;

      List<CardSentencesDetilsEntityClausesGrammaticalFeatures?> grammaticalFeatures = clause.grammaticalFeatures??[];
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "结构详情",
            style: TextStyle(
              fontSize: 28.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextPrimary,
            ),
          ),
          SizedBox(height: 16.wMin),
          Wrap(
            spacing: 12.wMin,
            runSpacing: 12.wMin,
            children: List.generate(grammaticalFeatures.length, (index){
              return StatusSentenceGrammaticalFeaturesTagWidget(
                categoryName: grammaticalFeatures[index]?.categoryName??[], 
                feature: grammaticalFeatures[index]?.feature??"",
                featureName: grammaticalFeatures[index]?.featureName??[],
                colorConfigs: colorConfigs.grammaticalFeatures,
              );
            }),
          ),

          
          SizedBox(height: 16.wMin),
          Obx((){
            if(controller.structureTabControllerIndex.value == 0){
              return _buildStructureBlockDetailWidget(clause);
            }else{
              return _buildStructureComponentDetailWidget(clause);
            }
          }),
          

        ],
      );
    });
  }

  /// 语块分析 结构详情
  Widget _buildStructureBlockDetailWidget(CardSentencesDetilsEntityClauses? clause){
    List<CardSentencesDetilsEntityClausesConjunctions?> conjunctions = clause?.conjunctions??[];
    /// 语块分析
    List<CardSentencesDetilsEntityClausesChunking?> chunking = clause?.chunking??[];

    return Column(
      children: [
        Visibility(
          visible: conjunctions.isNotEmpty,
          child: Container(
            margin: EdgeInsets.only(bottom: 16.wMin),
            child: Column(
              spacing: 16.wMin,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(conjunctions.length, (index){
                return _buildStructureDetailItemWidget(
                  autoIndex: index + 2, 
                  isDivider: false,
                  isConjunction: true,
                  tag: conjunctions[index]?.type,
                  tagText: "链接词",
                  title: conjunctions[index]?.text,
                  content: conjunctions[index]?.descriptions,
                );
              }),
            ),
          ),
        ),

        Column(
          spacing: 16.wMin,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(chunking.length, (index){
            return _buildStructureDetailItemWidget(
              autoIndex: index + conjunctions.length + 2, 
              isDivider: false,
              tag: chunking[index]?.type,
              tagText: chunking[index]?.type,
              content: chunking[index]?.descriptions,
            );
          }),
        ),
      ],
    );
  }

  /// 成分分析 结构详情
  Widget _buildStructureComponentDetailWidget(CardSentencesDetilsEntityClauses? clause){
    List<CardSentencesDetilsEntityClausesConjunctions?> conjunctions = clause?.conjunctions??[];
    /// 成分分析
    CardSentencesDetilsEntityClausesSvoca? svoca = clause?.svoca;
    if(svoca == null) return Container();
    
    return Column(
      spacing: 16.wMin,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: conjunctions.isNotEmpty,
          child: Container(
            margin: EdgeInsets.only(bottom: 16.wMin),
            child: Column(
              spacing: 16.wMin,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(conjunctions.length, (index){
                return _buildStructureDetailItemWidget(
                  autoIndex: index + 2, 
                  isDivider: false,
                  isConjunction: true,
                  tag: conjunctions[index]?.type,
                  tagText: "链接词",
                  title: conjunctions[index]?.text,
                  content: conjunctions[index]?.descriptions,
                );
              }),
            ),
          ),
        ),
        _buildStructureDetailItemWidget(
          autoIndex: -2, 
          isDivider: false,
          tag: svoca.patternCode,
          tagText: svoca.patternCode,
          content: svoca.descriptions,
        ),
        IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 1.wMin,
                color: AppTheme.cBorderSecondary,
              ),
              Expanded(
                child: Column(
                  spacing: 16.wMin,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(svoca.elements?.length??0, (index){
                    return _buildStructureDetailItemWidget(
                      autoIndex: index + conjunctions.length + 2, 
                      isDivider: true,
                      tag: svoca.elements?[index]?.type,
                      tagText: svoca.elements?[index]?.type,
                      content: svoca.elements?[index]?.descriptions,
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 结构详情模块item
  Widget _buildStructureDetailItemWidget({
    required int autoIndex, 
    bool isDivider = true,
    bool isConjunction = false,
    String? tag,
    String? tagText,
    String? title,
    String? subTitle,
    List<LanguageText?>? content,
  }){

    ConfigController configController = Get.find<ConfigController>();

    var colorConfigs = configController.colorConfigs.value;

    LanguageConfigColorModel? configColor;
    if(isConjunction){
      configColor = StatusUtils.getConfigColor(colorConfigs.structuralLevels, tag);
    }else{
      if(controller.structureTabControllerIndex.value == 0){
        configColor = StatusUtils.getConfigColor(colorConfigs.upos, tag);
      }else{
        configColor = StatusUtils.getConfigColor(colorConfigs.grammar, tag);
      }
    }

    return Row(
      children: [
        Visibility(
          visible: isDivider,
          child: Container(
            width: 7.wMin,
            height: 1.wMin,
            color: AppTheme.cBorderSecondary,
            margin: EdgeInsets.only(right: 8.wMin),
          ),
        ),
        Expanded(
          child: AutoScrollTag(
            key: ValueKey(autoIndex),
            controller: controller.autoScrollController,
            index: autoIndex,
            child: TapScaleWidget(
              onTap: () {
                controller.sentenceStructureDetailSelectIndex(autoIndex - 2);
              },
              sclae: 1,
              child: AnimatedContainer(
                width: double.infinity,
                duration: const Duration(milliseconds: 100),
                padding: EdgeInsets.all(12.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.wMin),
                  color: AppTheme.cBgTertiary,
                  border: Border.all(
                    width: 1.wMin, 
                    color: AppTheme.cBorderBrand.withValues(
                      alpha: controller.sentenceStructureDetailSelectIndex.value == autoIndex - 2 ? 1 : 0,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
                          decoration: BoxDecoration(
                            color: configColor?.color?.bgColor??AppTheme.cBgBrand.addOpacity(0.1),
                            borderRadius: BorderRadius.circular(4.wMin),
                          ),
                          child: Text(
                            tagText??"",
                            style: TextStyle(
                              fontSize: 24.wMin,
                              fontWeight: FontWeight.w400,
                              color: configColor?.color?.textColor??AppTheme.cBgBrand,
                            ),
                          ),
                        ),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 100),
                          opacity: controller.sentenceStructureDetailSelectIndex.value == autoIndex - 2 ? 1 : 0,
                          child: Container(
                            margin: EdgeInsets.only(left: 8.wMin),
                            padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
                            decoration: BoxDecoration(
                              color: AppTheme.cFeedbackDefaultBackground,
                              borderRadius: BorderRadius.circular(4.wMin),
                            ),
                            child: Text(
                              "已选中",
                              style: TextStyle(
                                fontSize: 24.wMin,
                                fontWeight: FontWeight.w400,
                                color: AppTheme.cFeedbackDefaultText,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Visibility(
                      visible: title != null && subTitle != null, 
                      child: Container(
                        margin: EdgeInsets.only(top: 6.wMin),
                        child: Row(
                          spacing: 7.wMin,
                          children: [
                            Text(
                              title??"",
                              style: TextStyle(
                                fontSize: 24.wMin,
                                fontWeight: FontWeight.w600,
                                color: configColor?.color?.textColor,
                              ),
                            ),
                            Text(
                              subTitle??"",
                              style: TextStyle(
                                fontSize: 20.wMin,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.cTextTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 2.wMin),
                    Obx((){
                      
                      List<LanguageText> glossList = LearningLangUtils.getShowLBList(content);
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(glossList.length, (index){
                          if(index == 0){
                            return Text(
                              glossList[index].text??"",
                              style: TextStyle(
                                fontSize: 24.wMin,
                                fontWeight: FontWeight.w400,
                                color: AppTheme.cTextSecondary,
                                height: 1.2,
                              ),
                            );
                          }
                          return Container(
                            margin: EdgeInsets.only(top: 2.wMin),
                            child: Text(
                              glossList[index].text??"",
                              style: TextStyle(
                                fontSize: 20.wMin,
                                fontWeight: FontWeight.w400,
                                color: AppTheme.cTextSecondary,
                              ),
                            ),
                          );
                        }),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }


  /// 句子结构表格
  Widget _buildStructureTableWidget(){
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        color: AppTheme.cSurfacePrimary,
      ),
      child: Obx((){
        var colorConfigs = Get.find<ConfigController>().colorConfigs.value;
        if(controller.gridOrFoldTagIndex.value == 0){//网格视图
          return ElementsSentenceAnalysisGridViewWidget(
            structureTabControllerIndex: controller.structureTabControllerIndex.value,
            sentenceText: controller.sentencesDetils.value.content,
            clauses: controller.sentencesDetils.value.clauses,
            selectIndex: controller.sentenceStructureTableSelectIndex.value,
            clausesColorConfigs: colorConfigs.clauses,
            colorConfigs: controller.structureTabControllerIndex.value == 0 ? colorConfigs.upos : colorConfigs.grammar,
            onSerialNumber: controller.changeSentenceStructureTableSelectIndex,
            onWord: (int sentenceIndex, int wordsIndex, int wordIndex, TextReference? textReference, bool isConjunction) {
              controller.sentenceStructureTableSelectIndex.value = sentenceIndex;
              // 点击单词时切换到句子结构详情
              controller.toSentenceStructureDetailSelectIndex(wordsIndex);
            },
          );
        }
        // 折叠视图
        return ElementsSentenceAnalysisFoldingViewWidget(
          sentenceText: controller.sentencesDetils.value.content,
          clause: controller.sentencesDetils.value.clauses?[controller.sentenceStructureTableSelectIndex.value],
          colorConfigs: colorConfigs.upos,
          onDetil: (int index) {
            int? length = controller.sentencesDetils.value.clauses?[controller.sentenceStructureTableSelectIndex.value]?.conjunctions?.length;
            controller.toSentenceStructureDetailSelectIndex(index + (length??0));
          },
        );
        
      }),
    );
  }


  /// 网格视图/折叠视图tag
  Widget _buildGridOrFoldTagWidget(){
    return Container(
      margin: EdgeInsets.only(bottom: 24.wMin),
      alignment: Alignment.centerLeft,
      child: Obx((){
        return ElementsTagTap1Widget(
          tabs: const ["网格视图", "折叠视图"],
          currentIndex: controller.gridOrFoldTagIndex.value,
          onTap: controller.changeGridOrFoldTagIndex,
        );
      }),
    );
  }

  
}