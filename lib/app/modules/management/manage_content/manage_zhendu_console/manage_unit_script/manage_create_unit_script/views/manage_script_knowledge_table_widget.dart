
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../../common/entities/entities.dart';
import '../../../../../../../../common/widgets/widgets.dart';

class ManageScriptKnowledgeTableWidget extends StatefulWidget {
  final List<UnitKnowledgePointsEntityKnowledgeList> knowledgeList;
  final Set<int>? selectknowledgeIds;
  final void Function(UnitKnowledgePointsEntityKnowledgeList data)? onCheck;
  const ManageScriptKnowledgeTableWidget({super.key, required this.knowledgeList, this.onCheck, this.selectknowledgeIds});

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
          Container(
            constraints: BoxConstraints(
              maxHeight: 400.wMin,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(widget.knowledgeList.length, (index){
                  return _buildTableWidget(index, widget.knowledgeList[index]);
                }),
              ),
            ),
          ),
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
          _buildTitleItemWidget(45, "知识点"),
          _buildTitleItemWidget(10, "词性"),
          _buildTitleItemWidget(10, "难度"),
          _buildTitleItemWidget(10, "语义"),
          _buildTitleItemWidget(5, "类型"),
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

  Widget _buildTableWidget(int index, UnitKnowledgePointsEntityKnowledgeList data){

    

    return TapScaleWidget(
      onTap: () {
        widget.onCheck?.call(data);
      },
      sclae: 1,
      backColor: AppTheme.cSurfaceSecondary.color,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: EdgeInsets.symmetric(vertical: 10.wMin),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(top: BorderSide(width: 1.wMin, color: AppTheme.cBorderPrimary.color)),
        ),
        child: Row(
          children: [
            _buildTableCheckboxWidget(data),
            _buildTableTextWidget(10, data.uid?.toString()??""),
            _buildTableContentWidget(data),
            _buildTableTextWidget(10, data.posTitle??""),
            _buildDifficultyWidget(data),
            _buildTableTextWidget(10, data.semanticId?.toString()??""),
            _buildTableTextWidget(5, data.cardType.name),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCheckboxWidget(UnitKnowledgePointsEntityKnowledgeList data){
    return Expanded(
      flex: 5,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.wMin),
        child: SvgPicture.asset(
          (widget.selectknowledgeIds?.contains(data.uid)??false) ? "assets/svg/public/icon_check_box.svg" : "assets/svg/public/icon_uncheck_box.svg",
          width: 24.wMin,
        ),
      ),
    );
  }

  Widget _buildTableContentWidget(UnitKnowledgePointsEntityKnowledgeList data){
    return Expanded(
      flex: 45,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.wMin),
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SelectableText(
              data.content??"",
              style: TextStyle(
                fontSize: 18.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w400,
              ),
            ),
            SelectableText(
              data.gloss?.map((e) => e?.text??'').join("\n")??"",
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

  Widget _buildDifficultyWidget(UnitKnowledgePointsEntityKnowledgeList data) {
    if (data.difficulty?.min == data.difficulty?.max) {
      return Expanded(
        flex: 10,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.wMin),
          alignment: Alignment.centerLeft,
          child: StatusTagDifficultyWidget(
            difficulty: data.difficulty?.min,
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
              difficulty: data.difficulty?.min,
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
              difficulty: data.difficulty?.max,
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