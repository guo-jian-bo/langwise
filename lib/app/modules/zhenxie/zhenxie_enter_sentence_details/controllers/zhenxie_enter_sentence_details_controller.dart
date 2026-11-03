import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/mixins/mixins.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../utils/utils.dart';

class ZhenxieEnterSentenceDetailsController extends GetxController with DualBreadcrumbMixin, PageRefreshAwareMixin {
  final String tagText;
  ZhenxieEnterSentenceDetailsController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.ZHENXIE_ENTER_SENTENCE_DETAILS;

  @override
  String get breadcrumbTitle => "入句画像详情";

  // 传进来的参数
  /// 短语id
  int? phraseId;
  /// 是否管理端
  bool isManagement = false;

  final Rx<EnterSentenceEntity> detailData = EnterSentenceEntity().obs;

  /// tab
  final RxList<EnterSentenceEntityProfileTabs> profileTabs = <EnterSentenceEntityProfileTabs>[].obs;

  /// tab内容列表
  final RxList<EnterSentenceEntityProfiles> profileContents = <EnterSentenceEntityProfiles>[].obs;

  /// 当前选择的tab下标
  final RxInt currentTabIndex = 0.obs;
  final RxBool isLoading = false.obs;
  final ConfigController configController = Get.find<ConfigController>();

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    if(Get.arguments != null){
      phraseId = Get.arguments['phraseId'];
      isManagement = Get.arguments['isManagement']??false;
      getDetails();
    } 
  }

  @override
  Future<void> onReturnPageRefresh(String? key) async{
    await getDetails(showLoading: false);
  }

  /// 获取详情
  Future<void> getDetails({bool showLoading = true}) async{
    if(phraseId == null) return;
    try {
      
      if(showLoading) {
        isLoading.value = true;
        ToastUtils.showLoading();
      }
      EnterSentenceEntity? detail;
      if (isManagement) {
        detail = await LanguageConsoleRequest.getWriteEnterSentenceDetail(
          parameters: {"phraseId": phraseId},
        );
      } else {
        detail = await LanguageUtil.getWriteEnterSentenceDetail(
            parameters: {
              "phraseId": phraseId,
            },
        );
      }
      if(detail == null) return;
      detailData.value = detail;
        currentTabIndex.value = 0;

     final tabs = detail.profileTabs??[];
    
      profileTabs.clear();
      for(var tab in tabs){
        if(tab == null) continue;
        profileTabs.add(tab);
      }

      List<EnterSentenceEntityProfiles?> profiles = detail.profiles??[];
      profileContents.clear();
      for(var profile in profiles){
        if(profile == null) continue;
        profileContents.add(profile);
      }

    } finally{
      
      if(showLoading) {
        isLoading.value = false;
        ToastUtils.hideLoading();
      }
    }
  }

  /// 切换tab
  void switchTab(int index){
    currentTabIndex.value = index;
  }
}
