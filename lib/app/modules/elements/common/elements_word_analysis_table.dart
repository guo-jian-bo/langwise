import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/public_controller/config_controller.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/utils.dart';


class ElementsWordAnalysisTable extends StatefulWidget {
  final AutoScrollController controller;
  final bool hideTranslation;
  final int autoToIndex;
  final List<CardSentencesDetilsEntityStructs?>? datas;
  final List<LanguageConfigColorEntityInfo?>? colorConfigs;
  /// 词语分析表格
  const ElementsWordAnalysisTable({
    super.key, 
    this.hideTranslation = false, 
    required this.controller, 
    this.autoToIndex = -1,
    this.datas,
    this.colorConfigs,
  });

  @override
  State<ElementsWordAnalysisTable> createState() => _ElementsWordAnalysisTableState();
}

class _ElementsWordAnalysisTableState extends State<ElementsWordAnalysisTable> {
  final List<_ElementsWordAnalysisTableModel> _titleList = [
    _ElementsWordAnalysisTableModel("ID", 6),
    _ElementsWordAnalysisTableModel("单词", 17),
    _ElementsWordAnalysisTableModel("原形", 17),
    _ElementsWordAnalysisTableModel("释义", 30),
    _ElementsWordAnalysisTableModel("词性", 30),
  ];
  final ConfigController configController = Get.find<ConfigController>();

  int hoverIndex = -1;

  @override
  Widget build(BuildContext context) {
    if(widget.datas == null){
      return Container();
    }
    return Column(
      children: [
        _buildTitleWidget(),
        Column(
          children: List.generate(widget.datas!.length, (index){
            return AutoScrollTag(
              key: ValueKey(index + 2), 
              controller: widget.controller, 
              index: index + 2,
              child: _buildRowWidget(index, widget.datas![index]),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildRowWidget(int index, CardSentencesDetilsEntityStructs? data){
    if(data == null){
      return Container();
    }

    List<LanguageText> gloss = LearningLangUtils.getShowLBList(data.gloss);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      color: AppTheme.cBgQuaternary.withValues(alpha: widget.autoToIndex == index ? 1 : 0),
      child: MouseRegion(
        onEnter: (event){
          hoverIndex = index;
          if(mounted) setState(() {});
        },
        onExit: (event){
          hoverIndex = -1;
          if(mounted) setState(() {});
        },
        child: GestureDetector(
          onTap: (){
            hoverIndex = index;
            if(mounted) setState(() {});
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            padding: EdgeInsets.symmetric(vertical: 16.wMin),
            decoration: BoxDecoration(
              color: AppTheme.cBgTertiary.withValues(alpha: hoverIndex == index ? 1 : 0),
              border: index == 0 ? null : Border(
                top: BorderSide(width: 1.wMin, color: AppTheme.cBorderSecondary),
              ),
            ),
            child: Row(
              children: [
                _buildRowTextWidget(data.id.toString(), _titleList[0].fix),
                _buildRowTextWidget(data.content??"", _titleList[1].fix),
                _buildRowTextWidget(data.lemma??"", _titleList[2].fix),
                _buildRowTextWidget(
                  gloss.map((e) => e.text).join("\n"),
                  _titleList[3].fix,
                ),
                _buildRowPartOfSpeechWidget(data, _titleList[4].fix),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRowPartOfSpeechWidget(CardSentencesDetilsEntityStructs data, int flex){

    LanguageConfigColorModel? colorConfig = StatusUtils.getConfigColor(widget.colorConfigs, data.pos);

    return Expanded(
      flex: flex,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
            decoration: BoxDecoration(
              color: colorConfig?.color?.bgColor,
              borderRadius: BorderRadius.circular(4.wMin),
            ),
            child: Text(
              data.pos??"",
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: colorConfig?.color?.textColor,
              ),
            ),
          ),
          Obx((){

            List<LanguageText> gloss = LearningLangUtils.getShowLBList(data.posTitle);
          
            return Text(
              gloss.map((e) => e.text).join("\n"),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cTextSecondary,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRowTextWidget(String text, int flex){
    return Expanded(
      flex: flex,
      child: Container(
        alignment: Alignment.center,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w600,
            color: AppTheme.cTextSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildTitleWidget(){
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.wMin)),
        color: AppTheme.cBgQuaternary,
      ),
      child: Row(
        children: List.generate(_titleList.length, (index){
          return Expanded(
            flex: _titleList[index].fix,
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 8.wMin),
              child: Text(
                _titleList[index].name,
                style: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextPrimary,
                ),
              ),
            ),
          );
        }),
      ),
    );

  }
}

class _ElementsWordAnalysisTableModel{
  String name;
  int fix;
  _ElementsWordAnalysisTableModel(this.name, this.fix);
}