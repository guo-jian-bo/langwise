
import 'package:api/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_title_input_widget.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../app/modules/management/common/manage_dropdown_widget.dart';
import '../entities/entities.dart';
import '../enum/enum.dart';
import '../https/https.dart';
import '../static/static_data.dart';


/// 添加课时模版 弹窗
class AddLessonTemplateDialog{

  static Future<int?> show({
    required BuildContext context,
    bool isEdit = false,
    int? uid,
    String? templateName,
    String? templateDesc,
    String? languageValue,
    String? lessonTypeValue,
    String? assessmentDirectionValue,
    int? minDifficulty,
    int? maxDifficulty,
  }) async{
    return await showCupertinoDialog<int?>(
      context: context, 
      builder: (context) {
        return AddLessonTemplateDialogWidget(
          isEdit: isEdit,
          uid: uid,
          templateName: templateName,
          templateDesc: templateDesc,
          lessonTypeValue: lessonTypeValue,
          languageValue: languageValue,
          assessmentDirectionValue: assessmentDirectionValue,
          minDifficulty: minDifficulty,
          maxDifficulty: maxDifficulty,
        );
      },
    );
  }

} 

class AddLessonTemplateDialogWidget extends StatefulWidget {
  final bool isEdit;
  final int? uid;
  final String? templateName;
  final String? templateDesc;
  final String? languageValue;
  final String? lessonTypeValue;
  final String? assessmentDirectionValue;
  final int? minDifficulty;
  final int? maxDifficulty;
  const AddLessonTemplateDialogWidget({
    super.key, 
    required this.isEdit, 
    this.uid,
    this.templateName, 
    this.templateDesc, 
    this.languageValue, 
    this.lessonTypeValue, 
    this.assessmentDirectionValue, 
    this.minDifficulty, 
    this.maxDifficulty,
  });

  @override
  State<AddLessonTemplateDialogWidget> createState() => _AddLessonTemplateDialogWidgetState();
}

class _AddLessonTemplateDialogWidgetState extends State<AddLessonTemplateDialogWidget> {

  /// 难度等级数据
  List<DifficultieEntity> difficultieList = [];

  /// 考核方向
  List<ConfigEntityAbilities> abilitiesList = [];

  /// 课时类型数据
  List<LessonTypeEnum> lessonTypes = LessonTypeEnum.values;
  /// 课时类型
  int selectLessonTypeIndex = -1;
  bool selectLessonTypeErr = false;

  /// 名字
  final TextEditingController templateName = TextEditingController();
  bool templateNameErr = false;
  /// 描述
  final TextEditingController templateDesc = TextEditingController();
  bool templateDescErr = false;
  /// 语言
  int selectLanguageIndex = 0;
  /// 考核方向
  int selectAssessmentDirectionIndex = -1;
  bool selectAssessmentDirectionErr = false;

  /// 难度等级
  int selectDifficultyMinIndex = -1;
  /// 难度等级
  int selectDifficultyMaxIndex = -1;
  bool selectMinDifficultyErr = false;
  bool selectMaxDifficultyErr = false;

  final GlobalKey dialogKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    
    if(widget.isEdit){
      templateName.text = widget.templateName?? "";
      templateDesc.text = widget.templateDesc?? "";
      selectLanguageIndex = StaticData.getLanguageIndex(widget.languageValue)?? 0;
      selectLessonTypeIndex = lessonTypes.indexWhere((e) => e.value == widget.lessonTypeValue);
    }
    getConfig();
  }

  Future<void> getConfig() async{
    ConfigEntity configData = Get.find<ConfigController>().appConfig.value;
    String languageCode = StaticData.languageList[selectLanguageIndex].value;
    List<DifficultieEntity>? diffList = DifficultieUtils.getDifficultieList(configData, languageCode);
    if(diffList != null) {
      difficultieList = diffList;
    }

    List<ConfigEntityAbilities>? abilities = AbilitieUtils.getAbilitieList(configData);
    if(abilities != null) {
      abilitiesList = abilities;
    }

    if(widget.isEdit){
      if(difficultieList.isNotEmpty){
        selectDifficultyMinIndex = getDifficultyLevelIndex(widget.minDifficulty);
        selectDifficultyMaxIndex = getDifficultyLevelIndex(widget.maxDifficulty);
      }
      if(abilitiesList.isNotEmpty){
        selectAssessmentDirectionIndex = getAbilitieIndex(widget.assessmentDirectionValue??"");
      }
    }

    if(mounted) setState(() {});
  }

  ConfigEntityDifficultiesLanguages? getLanguageData(List<ConfigEntityDifficultiesLanguages?>? list, String? languageCode) {
    if(list == null || languageCode == null) return null;
    for(int i = 0; i < list.length; i++){
      if(list[i] == null) continue;
      if(list[i]!.lang == languageCode){
        return list[i];
      }
    }
    return null;
  }

  int getAbilitieIndex(String abilitieType){
    if(abilitiesList.isEmpty) return -1;
    for(int i = 0; i < abilitiesList.length; i++){
      ConfigEntityAbilities item = abilitiesList[i];
      if(item.direction == abilitieType){
        return i;
      }
    }
    return -1;
  }

  int getDifficultyLevelIndex(int? level){
    if(level == null) return -1;
    for(int i = 0; i < difficultieList.length; i++){
      DifficultieEntity item = difficultieList[i];
      if(item.level == level){
        return i;
      }
    }
    return -1;
  }


  bool verify(){
    
    if(templateName.text.isEmpty) {
      ToastUtils.showManageToast(text: "请输入课程模版名称", containerKey: dialogKey);
      templateNameErr = true;
      if(mounted) setState(() {});
      return false;
    }
    if(templateDesc.text.isEmpty) {
      ToastUtils.showManageToast(text: "请输入课时描述", containerKey: dialogKey);
      templateDescErr = true;
      if(mounted) setState(() {});
      return false;
    }
    if(selectAssessmentDirectionIndex == -1){
      ToastUtils.showManageToast(text: "请选择考核方向", containerKey: dialogKey);
      selectAssessmentDirectionErr = true;
      if(mounted) setState(() {});
      return false;
    }
    if(selectLessonTypeIndex == -1){
      ToastUtils.showManageToast(text: "请选择课时类型", containerKey: dialogKey);
      selectLessonTypeErr = true;
      if(mounted) setState(() {});
      return false;
    }
    if(selectDifficultyMinIndex == -1){
      ToastUtils.showManageToast(text: "请选择难度等级", containerKey: dialogKey);
      selectMinDifficultyErr = true;
      if(mounted) setState(() {}); 
      return false; 
    }
    if(selectDifficultyMaxIndex == -1){
      ToastUtils.showManageToast(text: "请选择难度等级", containerKey: dialogKey);
      selectMaxDifficultyErr = true;
      if(mounted) setState(() {});  
      return false;
    }
    int minLevel = difficultieList[selectDifficultyMinIndex].level??0;
    int maxLevel = difficultieList[selectDifficultyMaxIndex].level??0;
    if(minLevel > maxLevel){
      ToastUtils.showManageToast(text: "难度最大等级小于最小等级", containerKey: dialogKey);
      selectMinDifficultyErr = true;
      selectMaxDifficultyErr = true;
      if(mounted) setState(() {});
      return false;
    }
    return true;
  }

  /// 保存按钮
  Future<void> saveButton() async{
    if(!verify()) {
      Future.delayed(const Duration(milliseconds: 3000), () {
        templateNameErr = false;
        templateDescErr = false;
        selectAssessmentDirectionErr = false;
        selectMinDifficultyErr = false;
        selectMaxDifficultyErr = false;
        selectLessonTypeErr = false;
        if(mounted) setState(() {});
      });
      return;
    }
    Map<String, dynamic> reqData = {
      "name": templateName.text,
      "description": templateDesc.text,
      "language": StaticData.languageList[selectLanguageIndex].value,
      "direction": abilitiesList[selectAssessmentDirectionIndex].direction,
      "minDifficulty": difficultieList[selectDifficultyMinIndex].level,
      "maxDifficulty": difficultieList[selectDifficultyMaxIndex].level,
      "type": lessonTypes[selectLessonTypeIndex].value,
    };
    ToastUtils.showLoading();
    ResponseEntity? res;
    if(widget.isEdit){
      if(widget.uid == null) {
        ToastUtils.hideLoading();
        return; 
      }
      res = await ManageLessonTemplateRequest.editLessonTemplate(reqData, widget.uid!);
    }else{
      res = await ManageLessonTemplateRequest.createLessonTemplate(reqData);
    }

    ToastUtils.hideLoading();
    if(res == null) return;
    if(res.data == null) return;
    LessonTemplateResponseEntity model = LessonTemplateResponseEntity.fromJson(res.data);
    Get.back(result: model.uid);
  }

  @override
  Widget build(BuildContext context) {
    
    return DialogBoxWidget(
      width: 1080.wMin,
      title: widget.isEdit ? "编辑课时模版" : "添加课时模版",
      define: "确认",
      onCancel: () => Get.back(),
      onDefine: () {
        saveButton();
      },
      child: Container(
        key: dialogKey,
        margin: EdgeInsets.symmetric(horizontal: 24.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          color: const Color(0xff22293C),
        ),
        child: SizedBox(
          height: 580.wMin,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 24.wMin),
            child: FocusTraversalGroup(
              policy: OrderedTraversalPolicy(),
              child: Column(
                children: [
                  ManageTitleInputWidget(
                    error: templateNameErr,
                    focusOrder: 1,
                    controller: templateName,
                    title: "名字",
                    hintText: "请输入课时模版名称",
                  ),
                  SizedBox(height: 24.wMin),
                  ManageTitleInputWidget(
                    error: templateDescErr,
                    focusOrder: 2,
                    controller: templateDesc,
                    title: "描述",
                    hintText: "请输入课时描述",
                  ),
                  SizedBox(height: 24.wMin),
                  ManageDropdownWidget(
                    title: "语言",
                    disable: widget.isEdit,
                    values: StaticData.languageList.map((e) => e.name).toList(),
                    valueMainAxisAlignment: MainAxisAlignment.spaceBetween,
                    selectedIndex: selectLanguageIndex,
                    onChange: (index) {
                      selectLanguageIndex = index;
                      getConfig();
                      if(mounted) setState(() {});
                    },
                  ),
                  SizedBox(height: 24.wMin),
                  Visibility(
                    visible: abilitiesList.isNotEmpty,
                    child: ManageDropdownWidget(
                      title: "考核方向",
                      hintText: "请选择考核方向",
                      error: selectAssessmentDirectionErr,
                      values: abilitiesList.map((e) => e.title??"").toList(),
                      valueMainAxisAlignment: MainAxisAlignment.spaceBetween,
                      selectedIndex: selectAssessmentDirectionIndex,
                      onChange: (index) {
                        selectAssessmentDirectionIndex = index;
                        if(mounted) setState(() {});
                      },
                    ),
                  ),
                  SizedBox(height: 24.wMin),
                  ManageDropdownWidget(
                    title: "课时类型",
                    hintText: "请选择课时类型",
                    error: selectLessonTypeErr,
                    values: lessonTypes.map((e) => e.name).toList(),
                    valueMainAxisAlignment: MainAxisAlignment.spaceBetween,
                    selectedIndex: selectLessonTypeIndex,
                    onChange: (index) {
                      selectLessonTypeIndex = index;
                      if(mounted) setState(() {});
                    },
                  ),
                  SizedBox(height: 24.wMin),
                  Row(
                    children: [
                      Text(
                        "难度水平",
                        style: TextStyle(
                          fontSize: 16.wMin,
                          color: const Color(0xffACB4C0),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 0.5.wMin,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.wMin),
                  Visibility(
                    visible: difficultieList.isNotEmpty,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: ManageDropdownWidget(
                            name: "最小",
                            hintText: "请选择最小难度水平",
                            error: selectMinDifficultyErr,
                            values: difficultieList.map((e) => e.name?.text??"").toList(),
                            selectedIndex: selectDifficultyMinIndex,
                            onChange: (index) {
                              selectDifficultyMinIndex = index;
                              if(mounted) setState(() {});
                            },
                          ),
                        ),
                        SizedBox(width: 24.wMin),
                        Expanded(
                          child: ManageDropdownWidget(
                            name: "最大",
                            hintText: "请选择最大难度水平",
                            error: selectMaxDifficultyErr,
                            values: difficultieList.map((e) => e.name?.text??"").toList(),
                            selectedIndex: selectDifficultyMaxIndex,
                            onChange: (index) {
                              selectDifficultyMaxIndex = index;
                              if(mounted) setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
            
                ],
              ),
            ),
          ),
        ),
      ),
      // child: Text(
      //   "e",
      //   style: TextStyle(
      //     fontSize: 1000.wMin,
      //     color: Colors.white,
      //     fontWeight: FontWeight.w500,
      //   ),
      // ),
    );
  }


}

