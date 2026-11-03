import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../routes/routes.dart';
import '../../../../routes/routes_breadcrumb_utils.dart';

class ElementsPhraseDetilsController extends GetxController
    with RoutesBreadcrumbMixin {
  final String tagText;

  ElementsPhraseDetilsController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.EN_PHRASE_DETAIL;

  @override
  String get breadcrumbTitle => "语境词典详情";

  int? contentId;
  String? jumpType;
  int? semanticId;
  List<int?>? semanticIds;

  final ConfigController configController = Get.find<ConfigController>();

  final Rx<CardPhraseSemanticDetilsEntity> cardDetils =
      CardPhraseSemanticDetilsEntity().obs;
  final RxList<CardPhraseSemanticItem> semanticItems =
      <CardPhraseSemanticItem>[].obs;
  final Rx<CardPhraseSemantic> currentSemantic = CardPhraseSemantic().obs;
  final RxInt currentSemanticId = 0.obs;

  final RxBool isLoading = true.obs;
  final RxBool isSemanticSwitching = false.obs;

  final Map<int, CardPhraseSemanticDetilsEntity> cachedDetils =
      <int, CardPhraseSemanticDetilsEntity>{};

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    if (Get.arguments != null) {
      contentId = Get.arguments['contentId'];
      jumpType = Get.arguments['jumpType'];
      semanticId = Get.arguments['semanticId'];
      semanticIds = Get.arguments['semanticIds']?.cast<int?>();
      initData();
    }
  }

  Future<void> initData() async {
    try {
      ToastUtils.showLoading();
      isLoading.value = true;
      await configController.ensureStyleReady();
      await Future.wait([
        getRightCount(),
        getDetils(),
      ]);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> getRightCount() async {
    final RightCountDetailsEntity? rightCountDetailsEntity =
        await UserRequest.getCardRightCount();
    if (rightCountDetailsEntity == null) return;
    final int extendCard = rightCountDetailsEntity.extendCard ?? 0;
    if (extendCard == 0) return;
    ToastUtils.showToast(text: '您还有$extendCard次探索卡片', type: ToastType.warning);
  }

  Future<void> getDetils() async {
    if (contentId == null) return;
    final int? initSemanticId =
        semanticId ?? (semanticIds?.isNotEmpty == true ? semanticIds!.first : null);
    final CardPhraseSemanticDetilsEntity? detils =
        await ElementsRequest.getPhraseSemanticDetils(
      contentId!,
      semanticId: initSemanticId,
      style: configController.currentStyleForRequest,
      mediaMode: configController.currentMediaMode,
    );
    if (detils == null) {
      isLoading.value = false;
      return;
    }
    if (detils.semanticId != null) {
      cachedDetils[detils.semanticId!] = detils;
    }
    _applyDetils(detils);
    _updateDetailBreadcrumbTitle(detils);
    isLoading.value = false;
  }

  Future<void> switchSemantic(int newSemanticId) async {
    if (contentId == null) return;
    if (isSemanticSwitching.value) return;
    if (newSemanticId == currentSemanticId.value) return;
    try {
      isSemanticSwitching.value = true;
      CardPhraseSemanticDetilsEntity? detils = cachedDetils[newSemanticId];
      if (detils == null) {
        detils = await ElementsRequest.getPhraseSemanticDetils(
          contentId!,
          semanticId: newSemanticId,
          style: configController.currentStyleForRequest,
          mediaMode: configController.currentMediaMode,
        );
        if (detils != null && detils.semanticId != null) {
          cachedDetils[detils.semanticId!] = detils;
        }
      }
      if (detils == null) return;
      _applyDetils(detils);
      _updateDetailBreadcrumbTitle(detils);
    } finally {
      isSemanticSwitching.value = false;
    }
  }

  void _updateDetailBreadcrumbTitle(CardPhraseSemanticDetilsEntity detils) {
    final String title = (detils.content ?? '').trim();
    if (title.isEmpty) return;
    updateBreadcrumbTitle(title);
  }

  Future<void> reloadForStyleChange() async {
    try {
      ToastUtils.showLoading();
      isLoading.value = true;
      cachedDetils.clear();
      await getDetils();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  void _applyDetils(CardPhraseSemanticDetilsEntity detils) {
    cardDetils.value = detils;
    semanticItems.value =
        detils.semanticItems?.whereType<CardPhraseSemanticItem>().toList() ??
            <CardPhraseSemanticItem>[];
    currentSemantic.value = detils.semantic ?? CardPhraseSemantic();
    currentSemanticId.value = detils.semanticId ?? 0;
  }

  bool isCurrentSemanticFavorited() {
    return cardDetils.value.favorited ?? false;
  }

  void setCurrentSemanticFavorited(bool favorited) {
    final CardPhraseSemanticDetilsEntity detils = cardDetils.value;
    detils.favorited = favorited;
    final int semanticId = currentSemanticId.value;
    if (semanticId > 0) {
      cachedDetils[semanticId]?.favorited = favorited;
    }
    cardDetils.refresh();
  }

  CardPhraseSemanticItem? findCurrentSemanticItem() {
    for (final CardPhraseSemanticItem item in semanticItems) {
      if (item.semanticId == currentSemanticId.value) {
        return item;
      }
    }
    return null;
  }
}
