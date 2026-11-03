import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/mixins/mixins.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../utils/utils.dart';

class ZhenxiePhrasePairDetailsController extends GetxController with DualBreadcrumbMixin, PageRefreshAwareMixin {
  final String tagText;
  ZhenxiePhrasePairDetailsController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.ZHENXIE_PHRASE_PAIR_DETAILS;

  @override
  String get breadcrumbTitle => "短语配对详情";

  // 传进来的参数
  /// 是否是管理端
  bool isManagement = false;

  /// 短语nid
  String? nid;

  final Rx<PhrasePairEntity> detailData = PhrasePairEntity().obs;
  final RxBool isLoading = false.obs;
  final ConfigController configController = Get.find<ConfigController>();

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    if(Get.arguments != null){
      isManagement = Get.arguments["isManagement"] ?? false;
      nid = Get.arguments["nid"];
      getDetails();
    }
  }

  @override
  Future<void> onReturnPageRefresh(String? key) async{
    await getDetails(showLoading: false);
  }

  /// 获取详情
  Future<void> getDetails({bool showLoading = true}) async{
    if(nid == null) return;
    try {
      if(showLoading) {
        isLoading.value = true;
        ToastUtils.showLoading();
      }
      PhrasePairEntity? detail;
      if (isManagement) {
        detail = await LanguageConsoleRequest.getWritePhrasePairDetail(
          parameters: {"nid": nid},
        );
      } else {
        detail = await LanguageUtil.getWritePhrasePairDetail(
            parameters: {
              "nid": nid,
            },
        );
      }
      if(detail == null) return;
      detailData.value = detail;
    } finally{
      isLoading.value = false;
      if(showLoading) ToastUtils.hideLoading();
    }
  }
}
