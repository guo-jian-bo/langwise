import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../routes/routes.dart';
import '../../../../routes/routes_breadcrumb_utils.dart';

class ElementsWordDetilsController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  ElementsWordDetilsController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.EN_WORD_DETAIL;

  @override
  String get breadcrumbTitle => "语境词典详情";

  // 传进来的参数
  int? contentId;
  /// * 外部传进来的参数，用来定位滚动视图
  /// * [ElementsJumpModuleType]
  String? jumpType;
  int? semanticId;
  /// 传进来的初始语义id
  List<int?>? semanticIds;

  final ConfigController configController = Get.find<ConfigController>();

  /// 新接口详情数据
  final Rx<CardWordSemanticDetilsEntity> cardDetils = CardWordSemanticDetilsEntity().obs;
  /// 释义简写列表（底部浮动列表数据源）
  final RxList<CardWordSemanticItem> semanticItems = <CardWordSemanticItem>[].obs;
  /// 当前选中释义详情
  final Rx<CardWordDetilsEntityPosListSemantics> currentSemantic =
      CardWordDetilsEntityPosListSemantics().obs;
  /// 当前释义ID
  final RxInt currentSemanticId = 0.obs;

  final RxBool isLoading = true.obs;
  final RxBool isSemanticSwitching = false.obs;

  // 缓存已加载的释义详情
  final Map<int, CardWordSemanticDetilsEntity> cachedDetils = <int, CardWordSemanticDetilsEntity>{};

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
      // 并发请求权益数量和详情数据
      await Future.wait([
        getRightCount(),
        getDetils(),
      ]);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 获取权益数量
  Future<void> getRightCount() async {
    final RightCountDetailsEntity? rightCountDetailsEntity =
        await UserRequest.getCardRightCount();
    if (rightCountDetailsEntity == null) return;
    final int extendCard = rightCountDetailsEntity.extendCard ?? 0;
    if (extendCard == 0) return;
    ToastUtils.showToast(text: '您还有$extendCard次探索卡片', type: ToastType.warning);
  }

  /// 获取单词详细信息（使用新接口）
  Future<void> getDetils() async {
    if (contentId == null) return;
    final int? initSemanticId =
        semanticId ?? (semanticIds?.isNotEmpty == true ? semanticIds!.first : null);
    final CardWordSemanticDetilsEntity? detils =
        await ElementsRequest.getWordSemanticDetils(
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


  /// 切换释义（调用新接口获取指定释义详情）
  Future<void> switchSemantic(int newSemanticId) async {
    if (contentId == null) return;
    if (isSemanticSwitching.value) return;
    if (newSemanticId == currentSemanticId.value) return;
    try {
      isSemanticSwitching.value = true;
      CardWordSemanticDetilsEntity? detils = cachedDetils[newSemanticId];
      if (detils == null) {
        detils = await ElementsRequest.getWordSemanticDetils(
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

  void _updateDetailBreadcrumbTitle(CardWordSemanticDetilsEntity detils) {
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

  void _applyDetils(CardWordSemanticDetilsEntity detils) {
    cardDetils.value = detils;
    semanticItems.value =
        detils.semanticItems?.whereType<CardWordSemanticItem>().toList() ?? <CardWordSemanticItem>[];
    currentSemantic.value =
        detils.semantic ?? CardWordDetilsEntityPosListSemantics();
    currentSemanticId.value = detils.semanticId ?? 0;
  }

  bool isCurrentSemanticFavorited() {
    return cardDetils.value.favorited ?? false;
  }

  void setCurrentSemanticFavorited(bool favorited) {
    final CardWordSemanticDetilsEntity detils = cardDetils.value;
    detils.favorited = favorited;
    final int semanticId = currentSemanticId.value;
    if (semanticId > 0) {
      cachedDetils[semanticId]?.favorited = favorited;
    }
    cardDetils.refresh();
  }

  CardWordSemanticItem? findCurrentSemanticItem() {
    for (final CardWordSemanticItem item in semanticItems) {
      if (item.semanticId == currentSemanticId.value) {
        return item;
      }
    }
    return null;
  }
}
