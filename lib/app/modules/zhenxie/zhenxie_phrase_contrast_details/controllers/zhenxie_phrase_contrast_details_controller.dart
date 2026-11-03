import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/mixins/mixins.dart';
import '../../../../routes/tag_routes.dart';

class ZhenxiePhraseContrastDetailsController extends GetxController with DualBreadcrumbMixin {
  final String tagText;
  ZhenxiePhraseContrastDetailsController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.ZHENXIE_PHRASE_CONTRAST_DETAILS;

  @override
  String get breadcrumbTitle => "短语对照详情";

  // 传进来的参数
  /// 是否是管理端
  bool isManagement = false;

  /// 短语nid
  String? nid;

  final Rx<PhraseParadigmEntity> detailData = PhraseParadigmEntity().obs;

  @override
  void onInit() {
    super.onInit();
    if(Get.arguments != null){
      isManagement = Get.arguments["isManagement"] ?? false;
      nid = Get.arguments["nid"];
      getDetails();
    }
    initBreadcrumb(tagText);
  }

  /// 获取详情
  Future<void> getDetails() async{
    if(nid == null) return;
    try {
      ToastUtils.showLoading();
      PhraseParadigmEntity? detail;
      if (isManagement) {
        detail = await LanguageConsoleRequest.getWritePhraseParadigmDetail(
          parameters: {"nid": nid},
        );
      } else {
        detail = await ElementsRequest.getPhraseParadigmDetils(nid!);
      }
      if(detail == null) return;
      detailData.value = detail;
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 跳转至短语详情
  Future<void> navigateToPhraseDetails() async {
    await TagRoutes.toNamed(Routes.ETYMOLOGY_MEMORY); // test
  }
}
