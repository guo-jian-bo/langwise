import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/mixins/mixins.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../utils/utils.dart';

class ZhenxiePhraseStructureDetailsController extends GetxController with DualBreadcrumbMixin, PageRefreshAwareMixin {
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
  final RxBool isLoading = false.obs;
  /// 当前高亮的结构词块 uid，空表示未选中
  final RxnInt selectedPhraseItemUid = RxnInt();
  /// 页面主滚动控制器，用于滚动到高亮词卡。
  final ScrollController mainScrollController = ScrollController();
  /// 页面主滚动区域 key，用于计算词卡是否在当前视口中。
  final GlobalKey mainScrollViewKey = GlobalKey();
  /// 内容卡片锚点，用于点击词块后滚动到对应卡片。
  final Map<int, GlobalKey> contentCardKeys = <int, GlobalKey>{};
  final ConfigController configController = Get.find<ConfigController>();

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

  @override
  Future<void> onReturnPageRefresh(String? key) async{
    await getDetails(showLoading: false);
  }

  @override
  void onClose() {
    mainScrollController.dispose();
    super.onClose();
  }

  /// 切换结构词块高亮，重复点击时取消选中。
  void toggleSelectedPhraseItem(PhraseStructureEntityItems? item) {
    final int? itemUid = item?.uid;
    if (itemUid == null) return;
    if (selectedPhraseItemUid.value == itemUid) {
      selectedPhraseItemUid.value = null;
      return;
    }
    selectedPhraseItemUid.value = itemUid;
  }

  /// 当前词块是否处于高亮状态。
  bool isPhraseItemSelected(PhraseStructureEntityItems? item) {
    final int? itemUid = item?.uid;
    if (itemUid == null) return false;
    return selectedPhraseItemUid.value == itemUid;
  }

  /// 获取当前选中的结构词块。
  PhraseStructureEntityItems? getSelectedPhraseItem() {
    final int? selectedItemUid = selectedPhraseItemUid.value;
    if (selectedItemUid == null) return null;
    final List<PhraseStructureEntityItems?> items = detailData.value.items ?? [];
    for (final item in items) {
      if (item?.uid == selectedItemUid) return item;
    }
    return null;
  }

  /// 当前内容卡片是否与已选中的结构词块匹配。
  bool isContentCardSelected(KnowledgeCommonEntityList? card) {
    if (card == null) return false;
    final PhraseStructureEntityItems? selectedItem = getSelectedPhraseItem();
    if (selectedItem == null) return false;

    final List<int?> selectedSemanticIds = selectedItem.semanticIds ?? [];
    final int? cardSemanticId = card.content?.semanticId;
    final bool hasMatchedSemanticId = cardSemanticId != null && selectedSemanticIds.contains(cardSemanticId);
    if (selectedItem.wordId != null && card.contentId == selectedItem.wordId) {
      if (selectedSemanticIds.isEmpty || cardSemanticId == null) return true;
      return hasMatchedSemanticId;
    }
    return hasMatchedSemanticId;
  }

  /// 获取当前需要滚动到的高亮卡片索引。
  int? getSelectedContentCardIndex() {
    final List<KnowledgeCommonEntityList?> contentCards = detailData.value.contentCards ?? [];
    for (int index = 0; index < contentCards.length; index++) {
      if (isContentCardSelected(contentCards[index])) return index;
    }
    return null;
  }

  /// 获取内容卡片的锚点 key。
  GlobalKey getContentCardKey(int index) {
    return contentCardKeys.putIfAbsent(index, () => GlobalKey());
  }

  /// 获取详情
  Future<void> getDetails({bool showLoading = true}) async{
    try {
      
      if(showLoading) {
        isLoading.value = true;
        ToastUtils.showLoading();
      }
      PhraseStructureEntity? detail;
      if (isManagement) {
        if (phraseId == null) return;
        detail = await LanguageConsoleRequest.getWritePhraseStructureDetail(
          parameters: {"phraseId": phraseId},
        );
      } else {
        if (phraseId == null && contentId == null) return;
        detail = await LanguageUtil.getWritePhraseStructureDetail(
          parameters: {
            if (phraseId != null) "phraseId": phraseId,
            if (contentId != null) "contentId": contentId,
          },
        );
      }
      if(detail == null) return;
      contentCardKeys.clear();
      selectedPhraseItemUid.value = null;
      detailData.value = detail;
    } finally{
      isLoading.value = false;
      if(showLoading) {
        ToastUtils.hideLoading();
      }
    }
  }
}
