
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../../common/entities/entities.dart';
import '../../../../../../../../common/widgets/widgets.dart';
import '../controllers/manage_create_vocabulary_script_controller.dart';

class ManageScriptKnowledgeTableWidget extends StatefulWidget {
  final ManageCreateVocabularyScriptController controller;
  const ManageScriptKnowledgeTableWidget({super.key, required this.controller});

  @override
  State<ManageScriptKnowledgeTableWidget> createState() => _ManageScriptKnowledgeTableWidgetState();
}

class _ManageScriptKnowledgeTableWidgetState extends State<ManageScriptKnowledgeTableWidget> {

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
        borderRadius: BorderRadius.circular(12.wMin),
      ),
      child: Column(
        children: [
          _buildTitleWidget(),
          Obx((){
            return Container(
              constraints: BoxConstraints(
                maxHeight: 400.wMin,
              ),
              child: ListView.builder(
                controller: widget.controller.knowledgeScrollController,
                itemCount: widget.controller.knowledgeList.length,
                itemBuilder: (context, index){
                  return _buildTableWidget(widget.controller.knowledgeList[index]);
                },
              ),
            );
          }),
        ],
      ),
    );
  }


  Widget _buildTitleWidget(){
    return Container(
      height: 44.wMin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.wMin)),
        color: AppTheme.cSurfaceSecondary.color,
      ),
      child: Row(
        children: [
          _buildTitleItemWidget(5, ""),
          _buildTitleItemWidget(10, "UID"),
          _buildTitleItemWidget(40, "知识点"),
          _buildTitleItemWidget(10, "词性"),
          _buildTitleItemWidget(10, "难度"),
          _buildTitleItemWidget(15, "选择的语义"),
        ],
      ),
    );
  }

  Widget _buildTitleItemWidget(int flex, String text){
    return Expanded(
      flex: flex,
      child: Container(
        height: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 10.wMin),
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18.wMin,
            color: AppTheme.cTextSecondary.color,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  /// 获取语义列展示文本
  String getSemanticDisplayText(EnKnowledgeEntity data){
    final List<EnKnowledgeEntitySemantics>? selected = data.selectedSemantics;
    if(selected != null && selected.isNotEmpty){
      List<String> ids = selected.map((e) => e.definition?.toString() ?? "").where((e) => e.isNotEmpty).toList();
      return ids.join("；");
    }
    return "";
  }

  Widget _buildTableWidget(EnKnowledgeEntity data){
    return TapScaleWidget(
      onTap: () async{
        await widget.controller.onTapKnowledge(context, data);
      },
      sclae: 1,
      backColor: AppTheme.cSurfaceSecondary.color,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.wMin),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(top: BorderSide(width: 1.wMin, color: AppTheme.cBorderPrimary.color)),
        ),
        child: Row(
          children: [
            _buildTableCheckboxWidget(data),
            _buildTableTextWidget(10, data.uid?.toString() ?? ""),
            _buildTableContentWidget(data),
            _buildTableTextWidget(10, data.posTitle ?? ""),
            _buildDifficultyWidget(data),
            _buildTableTextWidget(15, getSemanticDisplayText(data)),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCheckboxWidget(EnKnowledgeEntity data){
    return Expanded(
      flex: 5,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.wMin),
        child: Obx((){
          return SvgPicture.asset(
            widget.controller.isKnowledgeSelected(data) ? "assets/svg/public/icon_check_box.svg" : "assets/svg/public/icon_uncheck_box.svg",
            width: 24.wMin,
          );
        }),
      ),
    );
  }

  Widget _buildTableContentWidget(EnKnowledgeEntity data){
    return Expanded(
      flex: 40,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.wMin),
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SelectableText(
              data.content ?? "",
              style: TextStyle(
                fontSize: 18.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w400,
              ),
            ),
            SelectableText(
              data.definition ?? "",
              style: TextStyle(
                fontSize: 16.wMin,
                color: AppTheme.cTextSecondary.color,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyWidget(EnKnowledgeEntity data) {
    final int? min = data.difficulty?.min ?? data.minDifficulty;
    final int? max = data.difficulty?.max ?? data.maxDifficulty;

    if (min == null && max == null) {
      return _buildTableTextWidget(10, "");
    }

    if (min == max) {
      return Expanded(
        flex: 10,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.wMin),
          alignment: Alignment.centerLeft,
          child: StatusTagDifficultyWidget(
            difficulty: min,
            language: "en",
            padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
            height: 24.wMin,
          ),
        ),
      );
    }

    return Expanded(
      flex: 10,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.wMin),
        child: Row(
          children: [
            StatusTagDifficultyWidget(
              difficulty: min,
              language: "en",
              padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
              height: 24.wMin,
            ),
            Text(
              "-",
              style: TextStyle(
                fontSize: 18.wMin,
                color: AppTheme.cTextSecondary.color,
                fontWeight: FontWeight.w400,
              ),
            ),
            StatusTagDifficultyWidget(
              difficulty: max,
              language: "en",
              padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
              height: 24.wMin,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableTextWidget(int flex, String text){
    return Expanded(
      flex: flex,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.wMin),
        alignment: Alignment.centerLeft,
        child: SelectableText(
          text,
          style: TextStyle(
            fontSize: 18.wMin,
            color: AppTheme.cTextPrimary.color,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

}
