import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/mixins/mixins.dart';
import '../../../../../utils/utils.dart';

class ZhenxiePhraseStructureDetailsController extends GetxController with DualBreadcrumbMixin {
  final String tagText;
  ZhenxiePhraseStructureDetailsController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.ZHENXIE_PHRASE_STRUCTURE_DETAILS;

  @override
  String get breadcrumbTitle => "短语结构详情";

  // 传进来的参数
  /// 短语id
  int? phraseId;
  /// 用户端内容id
  int? contentId;
  /// 是否管理端
  bool isManagement = false;

  final Rx<PhraseStructureEntity> detailData = PhraseStructureEntity().obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    if(Get.arguments != null){
      phraseId = Get.arguments['phraseId'];
      contentId = Get.arguments['contentId'];
      isManagement = Get.arguments['isManagement']??false;
      getDetails();
    } 
  }

  /// 获取详情
  Future<void> getDetails() async{
    try {
      ToastUtils.showLoading();
      PhraseStructureEntity? detail;
      if (isManagement) {
        if (phraseId == null) return;
        detail = await LanguageConsoleRequest.getWritePhraseStructureDetail(
          parameters: {"phraseId": phraseId},
        );
      } else {
        if (contentId == null) return;
        detail = await ElementsRequest.getPhraseStructureDetils(contentId!);
      }
      if(detail == null) return;
      detailData.value = detail;
    } finally{
      ToastUtils.hideLoading();
    }
  }
}
