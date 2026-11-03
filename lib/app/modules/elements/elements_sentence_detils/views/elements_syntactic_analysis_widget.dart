import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../../../../../common/entities/entities.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../../common/elements_constituency_tree.dart';
import '../../common/elements_word_analysis_table.dart';
import '../controllers/elements_sentence_detils_controller.dart';


class ElementsSyntacticAnalysisWidget extends GetView<ElementsSentenceDetilsController> {
  final String tagText;
  /// 句法分析
  const ElementsSyntacticAnalysisWidget({super.key, required this.tagText});

  @override
  String? get tag => tagText;


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 16.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChartWidget(),
          SizedBox(height: 24.wMin),
          Text(
            "词语分析表",
            style: TextStyle(
              fontSize: 28.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary,
            ),
          ),
          SizedBox(height: 16.wMin),
          Obx((){
            if(controller.sentencesDetils.value.structs == null){
              return Container();
            }
            return ElementsWordAnalysisTable(
              hideTranslation: controller.hideTranslation.value,
              controller: controller.autoScrollController,
              autoToIndex: controller.graphAutoToIndex.value,
              datas: controller.sentencesDetils.value.structs,
              colorConfigs: Get.find<ConfigController>().colorConfigs.value.upos,
            );
          }),
        ],
      ),
    );
  }

  

  Widget _buildChartWidget(){

    return Obx((){
      if(controller.sentencesDetils.value.constituency == null) return Container();
      return Container(
        margin: EdgeInsets.only(top: 16.wMin),
        child: MouseRegion(
          cursor: SystemMouseCursors.grab,
          onEnter: (event) {
            controller.isHoveringGraph.value = true;
          },
          onExit: (event) {
            controller.isHoveringGraph.value = false;
          },
          child: Container(
            height: 500.wMin,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.wMin),
              color: AppTheme.cSurfacePrimary,
            ),
            child: Obx((){
              return Stack(
                children: [
                  ElementsConstituencyTree(
                    constituency: controller.sentencesDetils.value.constituency!,
                    graphShowDetils: controller.graphShowDetils.value,
                    colorConfigs: Get.find<ConfigController>().colorConfigs.value.upos,
                    onWord: (word) {
                      controller.toSentenceGraphTableIndex(word);
                    },
                  ),
                  Positioned(
                    right: 20.wMin,
                    top: 20.wMin,
                    child: ButtonWidget(
                      text: controller.graphShowDetils.value ? "隐藏详情" : "显示更多",
                      color: AppTheme.cBgActive,
                      borderRadius: 4.wMin,
                      fontColor: AppTheme.cTextPrimary,
                      fontSize: 20.wMin,
                      fontWeight: FontWeight.w400,
                      padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 2.wMin),
                      sclae: 1.05,
                      onTap: () {
                        controller.graphShowDetils.value = !controller.graphShowDetils.value;
                      },
                    ),
                  ),
                  Visibility(
                    visible: controller.graphShowDetils.value,
                    child: Positioned(
                      top: 60.wMin,
                      right: 20.wMin,
                      child: _buildTreeColorExampleWidget(),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      );
    });
  }

  Widget _buildTreeColorExampleWidget(){
    return ListAnimationWidget(
      child: Container(
        padding: EdgeInsets.only(
          top: 12.wMin,
          left: 12.wMin,
          right: 12.wMin,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.wMin),
          color: AppTheme.cBlackAlpha20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "节点类型图例",
              style: TextStyle(
                fontSize: 18.wMin,
                color: AppTheme.cTextPrimary,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 6.wMin),
            // _buildTreeColorExampleItemWidget("句子/名词", ["S", "NP", "NN"]),
            // _buildTreeColorExampleItemWidget("动词", ["VP", "VB"]),
            // _buildTreeColorExampleItemWidget("形容词", ["ADJP", "JJ"]),
            // _buildTreeColorExampleItemWidget("副词", ["ADVP", "RB"]),
            // _buildTreeColorExampleItemWidget("介词", ["PP", "IN"]),
            // _buildTreeColorExampleItemWidget("代词/功能词", ["PRP", "DT"]),
            // _buildTreeColorExampleItemWidget("连词", ["CC"]),
            Container(
              constraints: BoxConstraints(
                maxHeight: 350.wMin,
                maxWidth: 400.wMin,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(controller.sentencesDetils.value.structs?.length??0, (index){
                    CardSentencesDetilsEntityStructs? data = controller.sentencesDetils.value.structs?[index];
                    if(data == null) return Container();
                    return _buildTreeColorExampleItemWidget(data.posTitle??[], [data.pos??""]);
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTreeColorExampleItemWidget(List<LanguageText?> value, List<String> types){
    var colorConfigs = Get.find<ConfigController>().colorConfigs.value;
    LanguageConfigColorModel? colorConfig = StatusUtils.getConfigColor(colorConfigs.upos, types.first);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6.wMin,
      children: [
        Container(
          width: 12.wMin,
          height: 12.wMin,
          margin: EdgeInsets.only(top: 8.wMin),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorConfig?.color?.textColor,
          ),
        ),
        Expanded(
          child: Obx((){

            List<LanguageText> gloss = LearningLangUtils.getShowLBList(value);
          
            return Text(
              "${gloss.map((e) => e.text).join(", ")} (${types.join(", ")})",
              style: TextStyle(
                fontSize: 18.wMin,
                color: AppTheme.cTextPrimary,
                fontWeight: FontWeight.w400,
              ),
            );
          }),
        ),
      ],
    );
  }

}