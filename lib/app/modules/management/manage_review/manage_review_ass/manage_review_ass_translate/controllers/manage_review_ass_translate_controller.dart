import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../utils/karaoke_subtitles_utils.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../utils/utils.dart';
import '../models/manage_ass_sentence_model.dart';

class ManageReviewAssTranslateController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageReviewAssTranslateController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_REVIEW_ASS_TRANSLATE;

  @override
  String get breadcrumbTitle => '编辑翻译';
  
  /// 页面参数
  int? assTaskId;
  /// 页面参数 如果不为null 则此页面为编辑字幕
  int? assId;

  /// 当前任务详情。
  final Rx<AssTaskEntityList> assData = AssTaskEntityList().obs;

  /// 解析的ass
  final RxList<ManageAssSentenceModel> assList = <ManageAssSentenceModel>[].obs;

  /// 当前正在编辑的下标
  final RxInt currentEditIndex = (-1).obs;

  /// 输入框是否有修改的
  final RxBool allInputIsChange = false.obs;

  
  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    if (Get.arguments != null) {
      assTaskId = Get.arguments['assTaskId'];
      assId = Get.arguments['assId'];
      getDataDetils();
      
    }
  }

  /// 获取任务详情，并在成功后解析当前任务的 ASS 数据。
  Future<void> getDataDetils() async {
    if (assTaskId == null && assId == null) return;
    try {
      ToastUtils.showLoading();
      AssTaskEntityList? res;

      if(assId != null){ // 不为null为编辑字幕 需要请求管理端接口
        final Map<String, dynamic> reqData = <String, dynamic>{
          "assId": assId,
        };
        res = await LanguageConsoleRequest.getAssDatils(data: reqData);
      }else{
        final Map<String, dynamic> reqData = <String, dynamic>{
          "assTaskId": assTaskId,
        };
        res = await LanguageUtil.getAssDatils(data: reqData);
      }
      if (res == null) return;
      assData.value = res;
      parseAssData();
    } finally {
      ToastUtils.hideLoading();
    }
  }


  /// 解析ass
  void parseAssData(){

    String textAss = assData.value.ass??"";

    String translation = assData.value.translate?.firstWhereOrNull((e) => e?.lang == "zh")?.text??"";

    // translation = "Dialogue: 0,0:00:01.26,0:00:01.95,Default,,0,0,0,,啊～真舒服。\nDialogue: 0,0:00:02.05,0:00:02.06,Default,,0,0,0,,。\nDialogue: 0,0:00:02.09,0:00:02.10,Default,,0,0,0,,。\nDialogue: 0,0:00:02.12,0:00:02.91,Default,,0,0,0,,真清爽。";

    assList.clear();
    
    List<SubtitlesSentenceModel> sentencesSubs = KaraokeSubtitlesUtils.parseAssSentenceByDialogue(textAss);
    
    List<AssSubtitle> translationSubs = KaraokeSubtitlesUtils.parseAssTranslateDialogue(translation);

    List<AssSubtitle> superfluousTranslationSubs = [];

    if(translationSubs.length > sentencesSubs.length){
      superfluousTranslationSubs = translationSubs.sublist(sentencesSubs.length, translationSubs.length);
    }

    try {
      for(int i = 0; i < sentencesSubs.length; i++){

        AssSubtitle? translationAss;
        if(i < translationSubs.length){
          translationAss = translationSubs[i];
        }

        assList.add(ManageAssSentenceModel(
          sentence: sentencesSubs[i],
          translation: translationAss??AssSubtitle(startTime: -1, endTime: -1, text: ""),
          translationInput: TextEditingController(text: translationAss?.text),
          focusNode: FocusNode(),
        ));
      }


      if(superfluousTranslationSubs.isNotEmpty){
        for(int i = 0; i < superfluousTranslationSubs.length; i++){
          assList.add(ManageAssSentenceModel(
            sentence: SubtitlesSentenceModel(words: []),
            translation: superfluousTranslationSubs[i], 
            translationInput: TextEditingController(text: superfluousTranslationSubs[i].text), 
            focusNode: FocusNode(),
            isSuperfluous: true,
          ));
        }
      }

      listenerInputFocus();
    } catch (_) {}

  }


  /// 监听输入框焦点
  void listenerInputFocus(){
    for(int i = 0; i < assList.length; i++){
      assList[i].focusNode.addListener(() => _onFocusChange(i));
    }
  }

  void _onFocusChange(int index){
    if(!assList[index].isSuperfluous && assList[index].focusNode.hasFocus){
      currentEditIndex.value = index;
    }else{
      currentEditIndex.value = -1;
    }
  }

  /// 判断输入框是否发生了改变
  void inputIsChange(ManageAssSentenceModel data){
    data.inputChange = data.translationInput.text != data.translation?.text && data.translationInput.text.trim().isNotEmpty;

    allInputIsChange.value = assList.where((e) => e.inputChange).isNotEmpty;

    assList.refresh();
  }

  /// 删除多余翻译
  void deleteSuperfluous(){
    bool isSuperfluousEmpty = assList.map((e) => e.isSuperfluous).toList().isEmpty;
    if(isSuperfluousEmpty){
      ToastUtils.showToast(text: "暂无多余翻译");
      return;
    }

    assList.removeWhere((e) => e.isSuperfluous);

    allInputIsChange.value = true;
    saveEditAssAll();
  }


  /// 保存字幕编辑 - 单句
  Future<void> saveEditAss(ManageAssSentenceModel data, int index) async{

    if(assData.value.assId == null && assData.value.frameAssId == null) return;

    String translateAssText = "";

    try {
      for(int i = 0; i < assList.length; i++){
        String text = assList[i].translation?.text??"";
        if(index == i){ // 单句保存 只保存这一句
          text = assList[i].translationInput.text;
        }

        String dialogueText = assList[i].sentence.dialogueText??"";
        if(dialogueText.isEmpty) return ToastUtils.showToast(text: "保存错误，缺少Dialogue");
        if(dialogueText.length < 10) return ToastUtils.showToast(text: "保存错误，Dialogue信息不完整");
        List<String> parts = dialogueText.split(',');
        String startDialogua = parts.sublist(0, 9).join(",") + ",";
        translateAssText += "\n$startDialogua$text";
      }
    } catch (e) {
      return ToastUtils.showToast(text: "保存错误，合并时出错");
    }

    bool res = await saveEditAssReq(translateAssText);
    if(!res) return;
    data.translation?.text = data.translationInput.text;
    inputIsChange(data);
  }

  /// 保存字幕 - 全部
  Future<void> saveEditAssAll() async{

    if(!allInputIsChange.value) {
      return ToastUtils.showToast(text: "没有可保存的翻译");
    }

    if(assData.value.assId == null && assData.value.frameAssId == null) return;

    String translateAssText = "";

    try {
      for(int i = 0; i < assList.length; i++){
        String text = assList[i].translationInput.text;
        if(text.trim().isEmpty) return ToastUtils.showToast(text: "还有未翻译的句子");
        String dialogueText = assList[i].sentence.dialogueText??"";
        if(dialogueText.isEmpty) return ToastUtils.showToast(text: "保存错误，缺少Dialogue");
        if(dialogueText.length < 10) return ToastUtils.showToast(text: "保存错误，Dialogue信息不完整");
        List<String> parts = dialogueText.split(',');
        String startDialogua = parts.sublist(0, 9).join(",") + ",";
        translateAssText += "\n$startDialogua$text";
      }
    } catch (e) {
      return ToastUtils.showToast(text: "保存错误，合并时出错");
    }

    bool res = await saveEditAssReq(translateAssText);
    if(!res) return;
    
    for(int i = 0; i < assList.length; i++){
      assList[i].translation?.text = assList[i].translationInput.text;;
      assList[i].inputChange = false;
    }

    assList.refresh();

  }

  /// 保存字幕请求
  Future<bool> saveEditAssReq(String translateAssText) async{
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "assId": assData.value.assId,
        "frameAssId": assData.value.frameAssId,
        "translate": {
          "lang": "zh",
          "text": translateAssText,
        },
      };
      bool res = await LanguageUtil.assReviewAssEdit(data: reqData);
      if(!res) return false;
      ToastUtils.showToast(text: "保存成功", type: ToastType.success);
      return true;
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 删除并新建
  Future<void> assReviewDeleteCreateTranslate(BuildContext context) async{

    bool ask = await AskDialog.showUserAsk(
      context: context,
      title: "删除并新建",
      content: "确定删除此任务并重新创建吗？",
    );
    if(!ask) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "assTaskId": assData.value.taskId,
      };
      String? res = await LanguageConsoleRequest.assReviewCreateTranslate(data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: res, type: ToastType.success);
      Get.back(result: true);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 删除任务
  Future<void> deleteTask(BuildContext context) async{
    bool ask = await AskDialog.showUserAsk(
      context: context,
      title: "删除任务",
      content: "确定删除此任务吗？",
    );
    if(!ask) return;
    try {
      ToastUtils.showLoading();

      Map<String, dynamic> reqDtaa = {
        "assTaskId": assData.value.taskId,
      };
      bool res = await LanguageConsoleRequest.assReviewDeleteTask(data: reqDtaa);
      if(!res) return;
      ToastUtils.showToast(text: "删除成功", type: ToastType.success);
      Get.back(result: true);

    } finally{
      ToastUtils.hideLoading();
    }
  }


  /// 放弃任务
  Future<void> assReviewAbandon(BuildContext context) async{
    bool ask = await AskDialog.showUserAsk(
      context: context,
      title: "删除任务",
      content: "确定放弃此任务吗？",
    );
    if(!ask) return;
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "assTaskId": assData.value.taskId,
      };
      bool res = await LanguageUtil.assReviewAbandon(data: reqData);
      if(!res) return;
      ToastUtils.showToast(text: "放弃成功", type: ToastType.success);
      Get.back(result: true);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 审核通过
  Future<void> assReviewAssApprove(BuildContext context) async{

    if(assData.value.hasAssApprove == true){
      bool ask = await AskDialog.showUserAsk(
        context: context,
        title: "温馨提示",
        content: "当前知识点已有审核通过的翻译，是否替换？",
      );
      if(!ask) return;
    }

    for(int i = 0; i < assList.length; i++){
      String text = assList[i].translationInput.text;
      if(text.trim().isEmpty) return ToastUtils.showToast(text: "请输入完整翻译");
      if(assList[i].inputChange) return ToastUtils.showToast(text: "还有未保存的翻译");
    }

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "assTaskId": assData.value.taskId,
      };
      bool res = await LanguageUtil.assReviewAssTranslateApprove(data: reqData);
      if(!res) return;
      ToastUtils.showToast(text: "审核成功", type: ToastType.success);
      Get.back(result: true);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  @override
  void onClose() {
    // TODO: 清理逻辑
    for(int i = 0; i < assList.length; i++){
      assList[i].focusNode.dispose();
    }
    super.onClose();
  }
}
