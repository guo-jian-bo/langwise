import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../../common/entities/entities.dart';
import '../../../../../../../../common/enum/enum.dart';
import '../../../../../../../../common/https/https.dart';
import '../../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../../utils/utils.dart';
import '../../../../../../../routes/routes.dart';
import '../../../../../utils/utils.dart';

class ManageCreateAudioProjectController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageCreateAudioProjectController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_CREATE_AUDIO_PROJECT;

  @override
  String get breadcrumbTitle => '新建音频项目';

  /// 剧本uid 搜索框
  final TextEditingController uidController = TextEditingController();
  /// 剧本标题 搜索框
  final TextEditingController titleController = TextEditingController();
  /// 剧本主题 搜索框
  final TextEditingController themeController = TextEditingController();
  /// 剧本题材 搜索框
  final TextEditingController genreController = TextEditingController();

  final ScrollController scriptScrollController = ScrollController();
  int totalCount = 0;
  int offset = 0;
  int limit = 20;
  bool isLoading = true;
  /// 剧本列表
  final RxList<ManageScriptEntity> scriptList = <ManageScriptEntity>[].obs;
  /// 剧本类型 0=全部 1=单元剧本 2=词汇剧本
  final RxInt scriptType = 0.obs;

  /// 选择的剧本
  final Rx<ManageScriptEntity?> selectScriptData = Rx(null);

  /// 生成音频数量
  final RxInt audioNumber = 1.obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    // TODO: 初始化逻辑
    listenScroll();
    refreshScriptListData();
  }

  /// 监听列表滚动进行分页加载
  void listenScroll(){
    scriptScrollController.addListener(() {
      if(scriptScrollController.position.pixels >= scriptScrollController.position.maxScrollExtent - 200 && !scriptScrollController.position.outOfRange){
        if(!isLoading && scriptList.length < totalCount){
          offset += limit;
          getScriptDataList();
        }
      }
    });
  }

  /// 刷新列表数据
  Future<void> refreshScriptListData() async{
    totalCount = 0;
    offset = 0;
    scriptList.clear();
    await getScriptDataList();
  }

  Future<void> getScriptDataList() async{
    try {
      isLoading = true;
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "offset": offset,
        "limit": limit,
        "order": "-uid",
      };

      ScriptTypeEnum? scriptTypeEnum;
      if(scriptType.value == 1){
        scriptTypeEnum = ScriptTypeEnum.unit;
      }else if(scriptType.value == 2){
        scriptTypeEnum = ScriptTypeEnum.vocabulary;
      }
      
      Map<String, dynamic> reqData = {
        "scriptType": scriptTypeEnum?.value,
      };

      List<int>? uids = FilterDialog.stringToIntList(uidController.text);
      if(uids != null){
        reqData['uids'] = uids;
      }
      if(titleController.text.isNotEmpty){
        reqData['title'] = titleController.text;
      }
      if(themeController.text.isNotEmpty){
        reqData['theme_nid'] = themeController.text;
      }
      if(genreController.text.isNotEmpty){
        reqData['genre_nid'] = genreController.text;
      }

      ListResponseEntity<ManageScriptEntity>? res = await LanguageConsoleDramaRequest.getScriptList(parameters: parameters, data: reqData);
      if(res == null) return;
      totalCount = res.count??0;
      List<ManageScriptEntity> list = res.datas??[];
      scriptList.addAll(list);
    } finally{
      isLoading = false;
      ToastUtils.hideLoading();
    }
  }

  /// 核心知识点
  Future<void> coreKnowledge(ManageScriptEntity data) async{
    if((data.usedKnowledgePoints?.length??0) == 0) return ToastUtils.showToast(text: "暂无核心知识点");
    ManagePageRegistry.jumpTo(
      Routes.MANAGE_CORE_KNOWLEDGE,
      arguments: {
        "uid": data.uid,
        "type": KnowledgeTypeEnum.SCRIPT.value,
      },
    );
  }

  /// 关联课程
  Future<void> relatedCourses(ManageScriptEntity data) async{
    if(data.courseInfo == null) return;
    Get.toNamed(
      Routes.OFFICIAL_COURSE_DETAILS_TARGET,
      arguments: {
        "courseId": data.courseInfo?.courseId,
        "moduleId": data.courseInfo?.courseModuleId,
        "unitId": data.courseInfo?.courseUnitId,
        "isAdminPage": true,
        "language": data.lang,
      },
    );
  }


  /// 选择剧本
  Future<void> selectScript(ManageScriptEntity data) async{
    selectScriptData.value = data;
  }

  /// 创建音频项目
  Future<void> createAudioProject() async{
    if(selectScriptData.value == null) return ToastUtils.showToast(text: "请选择剧本");
    try {
      ToastUtils.showLoading();

      Map<String, dynamic> reqData = {
        "scriptId": selectScriptData.value?.uid,
        "numberOfVoices": audioNumber.value,
      };

      String? res = await LanguageConsoleDramaRequest.createAudioProject(data: reqData);
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
