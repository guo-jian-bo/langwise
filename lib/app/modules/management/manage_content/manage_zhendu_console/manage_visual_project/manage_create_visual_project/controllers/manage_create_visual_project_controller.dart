import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../../common/entities/entities.dart';
import '../../../../../../../../common/https/https.dart';
import '../../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../../utils/utils.dart';
import '../../../../../../../routes/routes.dart';
import '../../../../../utils/utils.dart';
import '../../../enums/manage_audio_project_status_enum.dart';

class ManageCreateVisualProjectController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageCreateVisualProjectController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_CREATE_VISUAL_PROJECT;

  @override
  String get breadcrumbTitle => '新建视觉项目';

  /// 音频项目搜索 
  final TextEditingController keywordSearchInput = TextEditingController();
  /// 音频项目搜索 
  final TextEditingController uidSearchInput = TextEditingController();
  /// 音频项目搜索 
  final TextEditingController titleSearchInput = TextEditingController();

  final ScrollController audioScrollController = ScrollController();
  int totalCount = 0;
  int offset = 0;
  int limit = 20;
  bool isLoading = true;
  final RxList<ManageAudioProjectEntity> audioList = <ManageAudioProjectEntity>[].obs;
  /// 选择的音频项目
  final Rx<ManageAudioProjectEntity?> selectAudioData = Rx(null);

  /// 所有风格列表
  final RxList<StyleImageEntity> styleList = <StyleImageEntity>[].obs;

  /// 选择的styleId
  final RxInt selectStyleId = (-1).obs;


  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    // TODO: 初始化逻辑
    listenScroll();
    initData();
  }

  Future<void> initData() async{
    try {
      ToastUtils.showLoading();
      await refreshAudioListData(showLoading: false);
      await getStyleList();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 监听列表滚动进行分页加载
  void listenScroll(){
    audioScrollController.addListener(() {
      if(audioScrollController.position.pixels >= audioScrollController.position.maxScrollExtent - 200 && !audioScrollController.position.outOfRange){
        if(!isLoading && audioList.length < totalCount){
          offset += limit;
          getAudioDataList();
        }
      }
    });
  }

  /// 刷新列表数据
  Future<void> refreshAudioListData({bool showLoading = true}) async{
    totalCount = 0;
    offset = 0;
    audioList.clear();
    await getAudioDataList(showLoading: false);
  }

  Future<void> getAudioDataList({bool showLoading = true}) async{
    try {
      isLoading = true;
      if(showLoading) ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "offset": offset,
        "limit": limit,
        "order": "-uid",
      };
      
      Map<String, dynamic> reqData = {
        "status": ManageAudioProjectStatusEnum.checked.value,
      };

      if(keywordSearchInput.text.isNotEmpty){
        reqData['keyword'] = keywordSearchInput.text;
      }

      List<int>? uids = FilterDialog.stringToIntList(uidSearchInput.text);
      if(uids != null){
        reqData['uids'] = uids;
      }
      if(titleSearchInput.text.isNotEmpty){
        reqData['title'] = titleSearchInput.text;
      }

      ListResponseEntity<ManageAudioProjectEntity>? res = await LanguageConsoleDramaRequest.getAudioProjectList(parameters: parameters, data: reqData);
      if(res == null) return;
      totalCount = res.count??0;
      List<ManageAudioProjectEntity> list = res.datas??[];
      audioList.addAll(list);
    } finally{
      isLoading = false;
      if(showLoading) ToastUtils.hideLoading();
    }
  }

  /// 选择音频项目
  Future<void> selectAudioProject(ManageAudioProjectEntity data) async{
    selectAudioData.value = data;
  }


  /// 获取风格列表
  Future<void> getStyleList() async{
    try {
      Map<String, dynamic> parameters = {
        "language": "en",
      };
      List<StyleImageEntity>? res = await LanguageUtil.getStyleListLanguage(parameters: parameters);
      if(res == null) return;
      styleList.value = res;
    } finally{}
  }


  /// 选择风格
  void selectStyle(StyleImageEntity data){
    if(data.uid == null) return;
    selectStyleId.value = data.uid!;
  }

  /// 创建视觉项目
  Future<void> createVisualProject() async{
    if(selectAudioData.value == null) return ToastUtils.showToast(text: "请选择音频项目");
    if(selectStyleId.value == -1) return ToastUtils.showToast(text: "请选择视觉风格");
    try {
      ToastUtils.showLoading();

      Map<String, dynamic> reqData = {
        "audioProjectId": selectAudioData.value?.uid,
        "styleId": selectStyleId.value,
      };

      String? res = await LanguageConsoleDramaRequest.createVisualProject(data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: res, type: ToastType.success);
      Get.back(result: true);

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
