import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/widgets/widgets.dart';
import 'manage_select_knowledge_dialog.dart';
import '../common/manage_quiz_public_widget.dart';

class ManageQuizClassifyChallengeManualDialog{
  static Future<List<QuizClassifyChallengRespData>?> show({
    required BuildContext context,
    required int unitId,
    List<String?>? contentScope,
    required List<ManageUnitKnowledgeEntity> unitKnowledgeList,
    int minClass = 1,
    int maxClass = 4,
    String? language,
  }) async{
    return await showCupertinoDialog<List<QuizClassifyChallengRespData>?>(
      context: context, 
      builder: (context) {
        return ManageQuizClassifyChallengeManualDialogWidget(
          unitKnowledgeList: unitKnowledgeList,
          minClass: minClass,
          maxClass: maxClass,
          unitId: unitId,
          contentScope: contentScope,
          language: language,
        );
      },
    );
  }
}

class ManageQuizClassifyChallengeManualDialogWidget extends StatefulWidget {
  final List<ManageUnitKnowledgeEntity> unitKnowledgeList;
  final int minClass;
  final int maxClass;
  final int unitId;
  final List<String?>? contentScope;
  final String? language;
  const ManageQuizClassifyChallengeManualDialogWidget({
    super.key, 
    required this.unitKnowledgeList, 
    this.minClass = 2, 
    this.maxClass = 4, 
    required this.unitId, 
    this.contentScope, 
    this.language,
  });

  @override
  State<ManageQuizClassifyChallengeManualDialogWidget> createState() => _ManageQuizClassifyChallengeManualDialogWidgetState();
}

class _ManageQuizClassifyChallengeManualDialogWidgetState extends State<ManageQuizClassifyChallengeManualDialogWidget> {
  final GlobalKey dialogKey = GlobalKey();

  /// 当前选择下标
  final List<int> selectKnowledgeIndexs = [];
  /// 储存已经选择的下标
  final List<int> selectUnIndexs = [];

  List<ManageQuizClassifyChallengeData> classList = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> addOption() async{
    if(classList.length >= widget.maxClass) {
      ToastUtils.showManageToast(text: "最多可以添加${widget.maxClass}个分类", containerKey: dialogKey);
      return;
    }

    List<ManageUnitKnowledgeEntity>? resList = await ManageSelectKnowledgeDialog.show(
      context: context, 
      unitId: widget.unitId,
      knowledgeSingle: true,
      contentScope: widget.contentScope,
      language: widget.language,
      showHaveKnowledge: false,
      title: "选择分类名",
    );
    if(resList == null || resList.isEmpty) return;

    for(int i = 0; i < classList.length; i++){
      if(classList[i].classData.uid == resList.first.uid){
        ToastUtils.showManageToast(text: "分类已存在", containerKey: dialogKey);
        return;
      }
    }
    classList.insert(0, ManageQuizClassifyChallengeData(classData: resList.first));

    if(mounted) setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {

    Widget buildKnowledgeListWidget(){
      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.wMin),
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 24.wMin,
          children: List.generate(widget.unitKnowledgeList.length, (index){
            return SizedBox(
              height: 290.wMin,
              child: ManagePublicKnowledeRowItemWidget(
                onTap: () {
                  if(selectKnowledgeIndexs.contains(index)){
                    selectKnowledgeIndexs.remove(index);
                  }else{
                    selectKnowledgeIndexs.add(index);
                  }
                  if(mounted) setState(() {});
                },
                selected: selectKnowledgeIndexs.contains(index),
                isFore: !selectUnIndexs.contains(index),
                content: widget.unitKnowledgeList[index].content,
                imageUrl:  widget.unitKnowledgeList[index].imageUrl,
                language: widget.language,
                difficulty: widget.unitKnowledgeList[index].difficulty?.min,
                audioUrl: widget.unitKnowledgeList[index].audioUrl,
                definition: widget.unitKnowledgeList[index].definition,
              ),
            );
          }),
        ),
      );
    }

    Widget buildClassListWidget(int index){
      return Container(
        padding: EdgeInsets.all(12.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          color: const Color(0xff141828).withValues(alpha: 0.4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TapScaleWidget(
              onTap: (){
                for(int i = 0; i < classList[index].selectIndex.length; i++){
                  selectUnIndexs.remove(classList[index].selectIndex[i]);
                }
                classList.removeAt(index);
                if(mounted) setState(() {});
              },
              child: Container(
                color: Colors.transparent,
                child: SvgPicture.asset(
                  "assets/svg/manage/icon_close.svg",
                  width: 24.wMin,
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DottedBorder(
                  radius: Radius.circular(8.wMin),
                  borderType: BorderType.RRect,
                  padding: EdgeInsets.zero,
                  color: const Color(0xff444B5F),
                  dashPattern: const [3, 2],
                  child: Container(
                    padding: EdgeInsets.only(left: 12.wMin, right: 12.wMin, bottom: 12.wMin),
                    width: 180.wMin,
                    height: 265.wMin,
                    child: Stack(
                      children: [
                        Column(
                          spacing: 16.wMin,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  classList[index].classData.content??"",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 24.wMin,
                                    color: const Color(0xffEBEEF3),
                                    fontWeight: FontWeight.w400,
                                    height: 1,
                                  ),
                                ),
                              ),
                            ),
                            ButtonWidget(
                              text: "添加到当前分类",
                              sclae: 1.03,
                              borderRadius: 6.wMin,
                              color: const Color(0xff353E5C),
                              fontSize: 14.wMin,
                              height: 40.wMin,
                              fontColor: const Color(0xffACB4C0),
                              onTap: (){
                                if(selectKnowledgeIndexs.isEmpty){
                                  ToastUtils.showManageToast(text: "请先选择知识点", containerKey: dialogKey);
                                  return;
                                }
                                selectUnIndexs.addAll(selectKnowledgeIndexs);
                                classList[index].selectIndex.addAll(selectKnowledgeIndexs);
                                selectKnowledgeIndexs.clear();
                                if(mounted) setState(() {});
                              },
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 24.wMin,
                      children: List.generate(classList[index].selectIndex.length, (index1){
                        int selectIndex = classList[index].selectIndex[index1];
                        return SizedBox(
                          height: 290.wMin,
                          child: ManagePublicKnowledeRowItemWidget(
                            onTR: () {
                              selectUnIndexs.remove(selectIndex);
                              classList[index].selectIndex.removeAt(index1);
                              if(mounted) setState(() {});
                            },
                            svg: "assets/svg/manage/icon_bg_delete.svg",
                            content: widget.unitKnowledgeList[selectIndex].content,
                            definition: widget.unitKnowledgeList[selectIndex].definition,
                            imageUrl:  widget.unitKnowledgeList[selectIndex].imageUrl,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }


    return DialogBoxWidget(
      title: "手动创建",
      width: 1080.wMin,
      onCancel: () => Get.back(),
      define: "下一步",
      onDefine: () {
        if(classList.length < widget.minClass){
          return ToastUtils.showManageToast(text: "最少需要${widget.minClass}个分类", containerKey: dialogKey);
        }

        List<QuizClassifyChallengRespData> respList = [];

        for(int i = 0; i < classList.length; i++){
          List<ManageUnitKnowledgeEntity> classKnowList = [];

          List<int> selectIndexs = classList[i].selectIndex;
          for(int j = 0; j < selectIndexs.length; j++){
            classKnowList.add(widget.unitKnowledgeList[selectIndexs[j]]);
          }
          if(classKnowList.isEmpty) {
            return ToastUtils.showManageToast(text: "清添加知识点到分类", containerKey: dialogKey);
          }
          respList.add(QuizClassifyChallengRespData(
            clessData: classList[i].classData,
            classKnowList: classKnowList,
          ));
        }
        Get.back(result: respList);
      },
      child: Container( 
        key: dialogKey,
        height: 800.wMin,
        margin: EdgeInsets.symmetric(horizontal: 24.wMin),
        padding: EdgeInsets.only(top: 16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          color: const Color(0xff22293C),
        ),
        child: Column(
          spacing: 16.wMin,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildKnowledgeListWidget(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(right: 16.wMin, left: 16.wMin, bottom: 16.wMin),
                child: Column(
                  spacing: 16.wMin,
                  children: [
                    ...List.generate(classList.length, (index){
                      return buildClassListWidget(index);
                    }),
                    TapScaleWidget(
                      onTap: () {
                        addOption();
                      },
                      sclae: 1.01,
                      child: DottedBorder(
                        radius: Radius.circular(8.wMin),
                        borderType: BorderType.RRect,
                        padding: EdgeInsets.zero,
                        color: const Color(0xff444B5F),
                        dashPattern: const [3, 2],
                        strokeWidth: 1.wMin,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 20.wMin),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                "assets/svg/manage/icon_add.svg",
                                height: 22.ww,
                              ),
                              Text(
                                "添加分类",
                                style: TextStyle(
                                  fontSize: 16.wMin,
                                  color: const Color(0xffEAECFF),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
            

          ],
        ),
      ),
    );
  }
}

class ManageQuizClassifyChallengeData{
  ManageUnitKnowledgeEntity classData;
  List<int> selectIndex = [];
  ManageQuizClassifyChallengeData({
    required this.classData,
  });
}

class QuizClassifyChallengRespData{
  ManageUnitKnowledgeEntity clessData;
  List<ManageUnitKnowledgeEntity> classKnowList;
  QuizClassifyChallengRespData({
    required this.clessData,
    required this.classKnowList,
  });
}