import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/mixins/mixins.dart';
import '../../../../../utils/utils.dart';

class ZhenxiePhraseMatchDetailsController extends GetxController with DualBreadcrumbMixin {
  final String tagText;
  ZhenxiePhraseMatchDetailsController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.ZHENXIE_PHRASE_MATCH_DETAILS;

  @override
  String get breadcrumbTitle => "短语搭配组详情";
  
  // 传进来的参数
  /// 是否是管理端
  bool isManagement = false;

  /// 短语nid
  String? nid;

  final Rx<PhraseMatchEntity> detailData = PhraseMatchEntity().obs;

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
      PhraseMatchEntity? detail;
      if (isManagement) {
        detail = await LanguageConsoleRequest.getWritePhraseMatchDetail(
          parameters: {"nid": nid},
        );
      } else {
        detail = await ElementsRequest.getPhraseMatchDetils(nid!);
      }
      if(detail == null) return;
      detailData.value = detail;
    } finally{
      ToastUtils.hideLoading();
    }
  }
}
