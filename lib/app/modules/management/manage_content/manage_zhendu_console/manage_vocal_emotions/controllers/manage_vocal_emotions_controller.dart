import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../routes/routes.dart';
import '../../../../utils/utils.dart';
import '../models/manage_vocal_emotions_model.dart';
import '../views/manage_vocal_emotions_audition_dialog.dart';

class ManageVocalEmotionsController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageVocalEmotionsController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_VOCAL_EMOTIONS;

  @override
  String get breadcrumbTitle => '人声情绪';

  final ScrollController leftScrollController = ScrollController();


  /// 搜索输入框
  final TextEditingController searchInput = TextEditingController();


  int limit = 20;
  int offset = 0;
  int total = 0;
  bool isLoading = true;
  /// 列表数据
  final RxList<ManageVocalEmotionsModel> listData = <ManageVocalEmotionsModel>[].obs;

  /// 当前选中的下标
  final RxInt currentIndex = 0.obs;


  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    listenScroll();
    refreshListData();
  }

  /// 监听列表滚动进行分页加载
  void listenScroll(){
    leftScrollController.addListener(() {
      if(leftScrollController.position.pixels >= leftScrollController.position.maxScrollExtent - 200 && !leftScrollController.position.outOfRange){
        if(!isLoading && listData.length < total){
          offset += limit;
          getListData();
        }
      }
    });
  }

  /// 刷新列表数据
  Future<void> refreshListData() async{
    currentIndex.value = 0;
    total = 0;
    offset = 0;
    listData.clear();
    await getListData();
  }

  /// 获取列表数据
  Future<void> getListData() async{
    try {
      isLoading = true;
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "limit": limit,
        "offset": offset,
        "order": "-uid",
      };
      Map<String, dynamic> reqData = {};
      if(searchInput.text.isNotEmpty){
        reqData["keyword"] = searchInput.text;
      }
      ListResponseEntity<ManageVocalEmotionsEntity>? res = await LanguageConsoleDramaRequest.getVocalEmotionsList(parameters: parameters, data: reqData);
      if(res == null) return;
      total = res.count ?? 0;
      List<ManageVocalEmotionsEntity> list = res.datas??[];
      for(ManageVocalEmotionsEntity item in list){
        listData.add(setModel(item));
      }
    } finally{
      isLoading = false;
      ToastUtils.hideLoading();
    }
    
  }

  /// set模型数据到本地model
  ManageVocalEmotionsModel setModel(ManageVocalEmotionsEntity item){
    List<LanguageText?> nameList = item.name??[];
    String enName = nameList.firstWhereOrNull((element) => element?.lang == "en")?.text??"";
    String zhName = nameList.firstWhereOrNull((element) => element?.lang == "zh")?.text??"";
    List<LanguageText?> descriptionList = item.description??[];
    String enDesc = descriptionList.firstWhere((element) => element?.lang == "en")?.text??"";
    String zhDesc = descriptionList.firstWhere((element) => element?.lang == "zh")?.text??"";
    List<double?> vector = item.vector??[];
    return ManageVocalEmotionsModel(
      data: item,
      nidInput: TextEditingController(text: item.nid),
      suggestedSpeedInput: TextEditingController(text: item.suggestedSpeed?.toString()),
      enNameInput: TextEditingController(text: enName),
      zhNameInput: TextEditingController(text: zhName),
      enDescInput: TextEditingController(text: enDesc),
      zhDescInput: TextEditingController(text: zhDesc),
      happySlider: vector.isNotEmpty ? vector[0]??0 : 0,
      angrySlider: vector.length >= 2 ? vector[1]??0 : 0,
      sadSlider: vector.length >= 3 ? vector[2]??0 : 0,
      afraidSlider: vector.length >= 4 ? vector[3]??0 : 0,
      disgustedSlider: vector.length >= 5 ? vector[4]??0 : 0,
      melancholicSlider: vector.length >= 6 ? vector[5]??0 : 0,
      surprisedSlider: vector.length >= 7 ? vector[6]??0 : 0,
      calmSlider: vector.length >= 8 ? vector[7]??0 : 0,
    );
  }


  /// 判断当前选中项是否有未保存的改变
  bool _hasChanges(ManageVocalEmotionsModel model) {
    final data = model.data;
    if (data == null) return false;
    List<LanguageText?> nameList = data.name ?? [];
    String enName = nameList.firstWhereOrNull((e) => e?.lang == "en")?.text ?? "";
    String zhName = nameList.firstWhereOrNull((e) => e?.lang == "zh")?.text ?? "";
    List<LanguageText?> descList = data.description ?? [];
    String enDesc = descList.firstWhereOrNull((e) => e?.lang == "en")?.text ?? "";
    String zhDesc = descList.firstWhereOrNull((e) => e?.lang == "zh")?.text ?? "";
    List<double?> vector = data.vector ?? [];
    if (model.nidInput.text != (data.nid ?? "")) return true;
    if (model.suggestedSpeedInput.text != (data.suggestedSpeed?.toString() ?? "")) return true;
    if (model.enNameInput.text != enName) return true;
    if (model.zhNameInput.text != zhName) return true;
    if (model.enDescInput.text != enDesc) return true;
    if (model.zhDescInput.text != zhDesc) return true;
    if (model.happySlider != (vector.isNotEmpty ? vector[0] ?? 0 : 0)) return true;
    if (model.angrySlider != (vector.length >= 2 ? vector[1] ?? 0 : 0)) return true;
    if (model.sadSlider != (vector.length >= 3 ? vector[2] ?? 0 : 0)) return true;
    if (model.afraidSlider != (vector.length >= 4 ? vector[3] ?? 0 : 0)) return true;
    if (model.disgustedSlider != (vector.length >= 5 ? vector[4] ?? 0 : 0)) return true;
    if (model.melancholicSlider != (vector.length >= 6 ? vector[5] ?? 0 : 0)) return true;
    if (model.surprisedSlider != (vector.length >= 7 ? vector[6] ?? 0 : 0)) return true;
    if (model.calmSlider != (vector.length >= 8 ? vector[7] ?? 0 : 0)) return true;
    return false;
  }

  /// 重置模型到原始数据
  void _resetToOriginal(ManageVocalEmotionsModel model) {
    final data = model.data;
    if (data == null) return;
    List<LanguageText?> nameList = data.name ?? [];
    String enName = nameList.firstWhereOrNull((e) => e?.lang == "en")?.text ?? "";
    String zhName = nameList.firstWhereOrNull((e) => e?.lang == "zh")?.text ?? "";
    List<LanguageText?> descList = data.description ?? [];
    String enDesc = descList.firstWhereOrNull((e) => e?.lang == "en")?.text ?? "";
    String zhDesc = descList.firstWhereOrNull((e) => e?.lang == "zh")?.text ?? "";
    List<double?> vector = data.vector ?? [];
    model.nidInput.text = data.nid ?? "";
    model.suggestedSpeedInput.text = data.suggestedSpeed?.toString() ?? "";
    model.enNameInput.text = enName;
    model.zhNameInput.text = zhName;
    model.enDescInput.text = enDesc;
    model.zhDescInput.text = zhDesc;
    model.happySlider = vector.isNotEmpty ? vector[0] ?? 0 : 0;
    model.angrySlider = vector.length >= 2 ? vector[1] ?? 0 : 0;
    model.sadSlider = vector.length >= 3 ? vector[2] ?? 0 : 0;
    model.afraidSlider = vector.length >= 4 ? vector[3] ?? 0 : 0;
    model.disgustedSlider = vector.length >= 5 ? vector[4] ?? 0 : 0;
    model.melancholicSlider = vector.length >= 6 ? vector[5] ?? 0 : 0;
    model.surprisedSlider = vector.length >= 7 ? vector[6] ?? 0 : 0;
    model.calmSlider = vector.length >= 8 ? vector[7] ?? 0 : 0;
    listData.refresh();
  }

  /// 选择情绪
  Future<void> selectLeftEmotions(BuildContext context, int index) async {
    if (index == currentIndex.value) return;
    final currentModel = listData[currentIndex.value];
    if (_hasChanges(currentModel)) {
      bool? askRes = await AskDialog.showUserCancelAsk(
        context: context,
        title: "提示",
        content: "当前数据已修改，是否保存？",
        cancel: "不保存",
        define: "保存",
      );
      if (askRes == null) return;
      if (askRes) {
        await editEmotions(context);
      } else {
        _resetToOriginal(currentModel);
      }
    }
    currentIndex.value = index;
  }


  /// 新增情绪
  Future<void> addEmotions() async{
    searchInput.clear();

    ManageVocalEmotionsModel addModel = ManageVocalEmotionsModel(
      nidInput: TextEditingController(text: "new-emotion-${listData.length + 1}-${DateTime.now().millisecondsSinceEpoch}"),
      suggestedSpeedInput: TextEditingController(text: "1"),
      enNameInput: TextEditingController(),
      zhNameInput: TextEditingController(),
      enDescInput: TextEditingController(),
      zhDescInput: TextEditingController(),
    );

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "nid": addModel.nidInput.text,
        "suggested_speed": addModel.suggestedSpeedInput.text,
        "name": [
          {
            "lang": "en",
            "text": addModel.enNameInput.text,
          },
          {
            "lang": "zh",
            "text": addModel.zhNameInput.text,
          },
        ],
        "description": [
          {
            "lang": "en",
            "text": addModel.enDescInput.text,
          },
          {
            "lang": "zh",
            "text": addModel.zhDescInput.text,
          },
        ],
        "vector": [
          addModel.happySlider,
          addModel.angrySlider,
          addModel.sadSlider,
          addModel.afraidSlider,
          addModel.disgustedSlider,
          addModel.melancholicSlider,
          addModel.surprisedSlider,
          addModel.calmSlider,
        ],
        "enabled": false,
      };
      ManageVocalEmotionsEntity? res = await LanguageConsoleDramaRequest.addVocalEmotions(data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: "新增成功", type: ToastType.success);
      listData.insert(0, setModel(res));
      currentIndex.value = 0;
      if(!leftScrollController.hasClients) return;
      leftScrollController.animateTo(0, duration: const Duration(milliseconds: 200), curve: Curves.linear);

    } finally{
      ToastUtils.hideLoading();
    }
  }


  /// 删除情绪
  Future<void> deleteEmotions(BuildContext context) async{
    if(listData[currentIndex.value].data?.uid == null) return;
    bool askRes = await DeleteDialog.show(
      context: context, 
      title: "删除",
      content: "您确定要删除此条情绪数据吗？",
    );
    if(!askRes) return;

    try {
      ToastUtils.showLoading();
      bool res = await LanguageConsoleDramaRequest.deleteVocalEmotions(listData[currentIndex.value].data!.uid!);
      if(!res) return;
      ToastUtils.showToast(text: "删除成功", type: ToastType.success);
      listData.removeAt(currentIndex.value);
      if(currentIndex.value != 0) {
        currentIndex.value --;
      }
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 试听
  Future<void> audition(BuildContext context, ManageVocalEmotionsModel data) async{
    if(listData[currentIndex.value].data?.uid == null) return;
    ManageVocalEmotionsAuditionDialog.show(
      context: context,
      emotionNid: data.data?.nid??"",
    );
  }



  /// 启用/停用
  Future<void> editEnabled(BuildContext context) async{
    if(listData[currentIndex.value].data?.uid == null) return;
     bool enabled = listData[currentIndex.value].data?.enabled??false;

    bool askRes = await AskDialog.showUserAsk(
      context: context, 
      title: enabled ? "停用" : "启用",
      content: "您确定要${enabled ? "停用" : "启用"}此条情绪吗？",
    );
    if(!askRes) return;

    try {
      ToastUtils.showLoading();
     
      Map<String, dynamic> reqData = {
        "enabled": !enabled,
      };
      ManageVocalEmotionsEntity? res = await LanguageConsoleDramaRequest.editVocalEmotions(listData[currentIndex.value].data!.uid!, data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: enabled ? "停用成功" : "启用成功", type: ToastType.success);
      listData[currentIndex.value].data!.enabled = !enabled;
      listData.refresh();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 保存编辑
  Future<void> editEmotions(BuildContext context) async{
    if(listData[currentIndex.value].data?.uid == null) return;
    ManageVocalEmotionsModel editModel = listData[currentIndex.value];

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "nid": editModel.nidInput.text,
        "suggested_speed": editModel.suggestedSpeedInput.text,
        "name": [
          {
            "lang": "en",
            "text": editModel.enNameInput.text,
          },
          {
            "lang": "zh",
            "text": editModel.zhNameInput.text,
          },
        ],
        "description": [
          {
            "lang": "en",
            "text": editModel.enDescInput.text,
          },
          {
            "lang": "zh",
            "text": editModel.zhDescInput.text,
          },
        ],
        "vector": [
          editModel.happySlider,
          editModel.angrySlider,
          editModel.sadSlider,
          editModel.afraidSlider,
          editModel.disgustedSlider,
          editModel.melancholicSlider,
          editModel.surprisedSlider,
          editModel.calmSlider,
        ],
      };
      ManageVocalEmotionsEntity? res = await LanguageConsoleDramaRequest.editVocalEmotions(editModel.data!.uid!, data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: "编辑成功", type: ToastType.success);
      editModel.data = res;
      listData.refresh();

    } finally{
      ToastUtils.hideLoading();
    }
  }


  @override
  void onClose() {
    // TODO: 清理逻辑
    super.onClose();
  }
}
