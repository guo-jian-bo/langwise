import 'package:api/entities/entities.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/mixins/mixins.dart';
import '../../../../../utils/utils.dart';

class CourseUnitGrammarDetailsController extends GetxController with DualBreadcrumbMixin {
  final String tagText;
  CourseUnitGrammarDetailsController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.COURSE_UNIT_GRAMMAR_DETAILS;

  @override
  String get breadcrumbTitle => "语法";

  // 传进来的参数
  int? unitId;
  int? targetUid;
  bool isManagement = false;


  final Rx<ManageUnitGrammarTargetDetailEntity> targetDetail = ManageUnitGrammarTargetDetailEntity().obs;
  final RxList<CourseUnitTargetSentenceGrammarGroupEntity> dataList = <CourseUnitTargetSentenceGrammarGroupEntity>[].obs;
  /// 滚动控制器
  final ScrollController scrollController = ScrollController();
  /// 总条数
  int total = 0;
  /// offset
  int offset = 0;
  /// limit
  int limit = 20;
  /// 是否加载中
  final RxBool isLoading = false.obs;


  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    if(Get.arguments != null){
      unitId = Get.arguments['unitId'];
      targetUid = Get.arguments['targetUid'];
      isManagement = Get.arguments['isManagement'] ?? false;
    }
    refreshList();
  }

  /// 监听列表滚动进行分页加载
  void listenScroll(){
    scrollController.addListener(() {
      if(scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200 && !scrollController.position.outOfRange){
        if(!isLoading.value && dataList.length < total){
          offset += limit;
          getListData();
        }
      }
    });
  }

  /// 刷新列表
  Future<void> refreshList() async{
    dataList.clear();
    offset = 0;
    total = 0;
    gettargetDetails();
    getListData();
  }

  /// 获取target详情
  Future<void> gettargetDetails() async{
    try {
      
      ResponseEntity<ManageUnitGrammarTargetDetailEntity?>? responseEntity = await UnitUtil.unitGrammarTargetDetail(
        unitId: unitId.toString(),
        config: RequestConfig(
          requireToken: true,
          parameters: {
            'targetUid': targetUid,
            'isManagement': isManagement,
          },
        ),
      );
      if(responseEntity == null) return;
      ManageUnitGrammarTargetDetailEntity? entity = responseEntity.data;
      if(entity == null) return;
      targetDetail.value = entity;

    } catch (_) {}
  }

  Future<void> getListData() async{
    // Map<String, dynamic> params = {
    //   "offset": offset,
    //   "limit": limit,
    // };
    try {
      isLoading.value = true;
      ToastUtils.showLoading();

      // 请求数据
      
    //   dataList.addAll(page.contents ?? []);
    //   total = page.total ?? 0;
    } finally{
      isLoading.value = false;
      ToastUtils.hideLoading();
    }
  }



  @override
  void onClose() {
    super.onClose();
  }
}
