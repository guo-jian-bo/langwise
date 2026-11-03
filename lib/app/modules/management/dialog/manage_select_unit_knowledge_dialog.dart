import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/https/https.dart';
import '../../../../common/widgets/widgets.dart';
import '../common/commons.dart';

/// 选择单元知识点
class ManageSelectUnitKnowledgeDialog{

  static Future<List<UnitKnowledgePointsEntityKnowledgeList>?> show({
    required BuildContext context,
    List<UnitKnowledgePointsEntityKnowledgeList>? initSelect,
    required int unitId,
  }) async {
    return await showCupertinoDialog<List<UnitKnowledgePointsEntityKnowledgeList>?>(
      context: context,
      builder: (context) {
        return ManageSelectUnitKnowledgeDialogWidget(
          unitId: unitId,
          initSelect: initSelect,
        );
      },
    );
  }

}

class ManageSelectUnitKnowledgeDialogWidget extends StatefulWidget {
  final int unitId;
  final List<UnitKnowledgePointsEntityKnowledgeList>? initSelect;
  const ManageSelectUnitKnowledgeDialogWidget({super.key, required this.unitId, this.initSelect});

  @override
  State<ManageSelectUnitKnowledgeDialogWidget> createState() => _ManageSelectUnitKnowledgeDialogWidgetState();
}

class _ManageSelectUnitKnowledgeDialogWidgetState extends State<ManageSelectUnitKnowledgeDialogWidget> {

  List<UnitKnowledgePointsEntityKnowledgeList> orgKnowledgeList = <UnitKnowledgePointsEntityKnowledgeList>[];

  List<UnitKnowledgePointsEntityKnowledgeList> knowledgeList = <UnitKnowledgePointsEntityKnowledgeList>[];

  /// 已经选择的单元知识点ids
  Set<int> initSelectIds = <int>{};

  /// 选择的单元知识点ids
  Set<int> selectknowledgeIds = <int>{};

  @override
  void initState() {
    super.initState();
    if(widget.initSelect != null){
      for (int i = 0; i < widget.initSelect!.length; i++) {
        UnitKnowledgePointsEntityKnowledgeList item = widget.initSelect![i];
        if (item.uid == null) continue;
        selectknowledgeIds.add(item.uid!);
      }
    }
    getKnowledgeList();
  }

  // 获取知识点列表
  Future<void> getKnowledgeList() async {

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "contentTypes": [
          ElementsCardType.word.value,
          ElementsCardType.phrase.value,
          ElementsCardType.sentence.value,
          ElementsCardType.text.value,
        ],
      };
      UnitKnowledgePointsEntity? entity = await OfficialCourseDetailsRequest.getAdminUnitTarget(widget.unitId, data: reqData);
      if (entity == null) {
        return;
      }
      List<UnitKnowledgePointsEntityKnowledgeList?>? list = entity.knowledgeList ?? [];
      for (int i = 0; i < list.length; i++) {
        UnitKnowledgePointsEntityKnowledgeList? item = list[i];
        if (item == null) continue;
        if (item.isSong) continue;
        orgKnowledgeList.add(item);
        knowledgeList.add(item);
      }
      if(mounted) setState(() {});
      
    } finally{
      ToastUtils.hideLoading();
    }
  }


  /// 实时筛选搜索搜索知识点
  void filterKnowledgeList(String value){
    knowledgeList.clear();
    if(value.isEmpty){
      knowledgeList.addAll(orgKnowledgeList);
      if(mounted) setState(() {});
      return;
    }
    
    for (int i = 0; i < orgKnowledgeList.length; i++) {
      UnitKnowledgePointsEntityKnowledgeList item = orgKnowledgeList[i];
      if (item.content?.contains(value) == true || item.title?.contains(value) == true) {
        knowledgeList.add(item);
      }
    }
    if(mounted) setState(() {});
  }


  /// 选择单元知识点
  void selectUnitKnowledge(UnitKnowledgePointsEntityKnowledgeList data){
    if(data.uid == null) return;
    if(selectknowledgeIds.contains(data.uid)){
      selectknowledgeIds.remove(data.uid);
    }else{
      selectknowledgeIds.add(data.uid!);
    }
    if(mounted) setState(() {});
  }

  /// 确认选择
  void confirmSelect(){

    if(selectknowledgeIds.isEmpty){
      ToastUtils.showToast(text: "请选择知识点");
      return;
    }
    List<UnitKnowledgePointsEntityKnowledgeList> resp = [];

    for (int i = 0; i < knowledgeList.length; i++) {
      UnitKnowledgePointsEntityKnowledgeList item = knowledgeList[i];
      if (selectknowledgeIds.contains(item.uid)) {
        resp.add(item);
      }
    }

    Get.back(result: resp);
  }
  
  @override
  Widget build(BuildContext context) {
    return ManageDialogBoxWidget(
      title: "选择单元知识点",
      width: 1500.wMin,
      onCancel: () => Get.back(),
      onConfirm: (){
        confirmSelect();
      },
      confirmText: "已选择 ${selectknowledgeIds.length} 个知识点",
      child: Container(
        padding: EdgeInsets.only(bottom: 10.wMin, left: 24.wMin, right: 24.wMin),
        height: 900.wMin,
        child: Column(
          children: [
            _buildTitleWidget(),
            SizedBox(height: 10.wMin),
            Expanded(
              child: ManageSelectUnitKnowledgeDialogTableWidget(
                knowledgeList: knowledgeList.toList(),
                selectknowledgeIds: selectknowledgeIds.toSet(),
                onCheck: (data) {
                  selectUnitKnowledge(data);
                },
              ),
            ),
          ],
        ),
        
      ),
    );
  }


  Widget _buildTitleWidget(){
    return CardInputWidget(
      hintText: "搜索知识点",
      height: 48.wMin,
      hintStyle: TextStyle(
        fontSize: 18.wMin,
        color: AppTheme.cTextTertiary.color,
      ),
      valueStyle: TextStyle(
        fontSize: 18.wMin,
        color: AppTheme.cTextPrimary.color,
      ),
      onChanged: (value) {
        filterKnowledgeList(value);
      },
    );
  }

}


class ManageSelectUnitKnowledgeDialogTableWidget extends StatefulWidget {
  final List<UnitKnowledgePointsEntityKnowledgeList> knowledgeList;
  final Set<int>? selectknowledgeIds;
  final void Function(UnitKnowledgePointsEntityKnowledgeList data)? onCheck;
  const ManageSelectUnitKnowledgeDialogTableWidget({super.key, required this.knowledgeList, this.onCheck, this.selectknowledgeIds});

  @override
  State<ManageSelectUnitKnowledgeDialogTableWidget> createState() => _ManageSelectUnitKnowledgeDialogTableWidgetState();
}

class _ManageSelectUnitKnowledgeDialogTableWidgetState extends State<ManageSelectUnitKnowledgeDialogTableWidget> {

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
          Expanded(
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
      backColor: AppTheme.cSurfaceTertiary.color,
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

    String title = data.content??"";
    String gloss = data.gloss?.map((e) => e?.text??'').join("\n")??"";
    if(data.isText || data.isSong){
      title = data.title??"";
      gloss = data.content??"";
    }

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
              title,
              style: TextStyle(
                fontSize: 18.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w400,
              ),
            ),
            SelectableText(
              gloss,
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