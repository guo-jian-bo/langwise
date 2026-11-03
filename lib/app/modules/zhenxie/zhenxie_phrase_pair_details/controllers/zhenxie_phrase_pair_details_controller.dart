import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/mixins/mixins.dart';
import '../../../../../utils/utils.dart';

class ZhenxiePhrasePairDetailsController extends GetxController with DualBreadcrumbMixin {
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

  /// 获取详情
  Future<void> getDetails() async{
    if(nid == null) return;
    try {
      ToastUtils.showLoading();
      PhrasePairEntity? detail;
      if (isManagement) {
        detail = await LanguageConsoleRequest.getWritePhrasePairDetail(
          parameters: {"nid": nid},
        );
      } else {
        detail = await ElementsRequest.getPhrasePairDetils(nid!);
      }
      if(detail == null) return;
      detailData.value = detail;
    } finally{
      ToastUtils.hideLoading();
    }
  }
}
