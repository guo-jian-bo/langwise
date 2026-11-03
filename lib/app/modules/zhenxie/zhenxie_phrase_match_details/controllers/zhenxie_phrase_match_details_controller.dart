import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/mixins/mixins.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../utils/utils.dart';
import '../../../../routes/tag_routes.dart';

class ZhenxiePhraseMatchDetailsController extends GetxController with DualBreadcrumbMixin, PageRefreshAwareMixin {
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
      PhraseMatchEntity? detail;
      if (isManagement) {
        detail = await LanguageConsoleRequest.getWritePhraseMatchDetail(
          parameters: {"nid": nid},
        );
      } else {
        detail = await LanguageUtil.getWritePhraseMatchDetail(
            parameters: {
              "nid": nid,
            },
        );
      }
      if(detail == null) return;
      detailData.value = detail;
    } finally{
      isLoading.value = false;
      if(showLoading) {
        ToastUtils.hideLoading();
      }
    }
  }

  Future<void> toExtras() async {
    if ((nid ?? '').isEmpty) return;
    if ((detailData.value.extrasCount ?? 0) < 1) return;
    TagRoutes.toNamed(
      Routes.ZHENXIE_PHRASE_MATCH_EXTRAS,
      arguments: {
        "nid": nid,
        "isManagement": isManagement,
      },
    );
  }
}
