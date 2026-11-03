import 'package:get/get.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../utils/utils.dart';
import '../../../../routes/routes.dart';
import '../../common/elements_bottom_menu_widget.dart';

class ElementsPhraseDetilsController extends GetxController {

  // 传进来的参数
  int? contentId;
  /// * 外部传进来的参数，用来定位滚动视图
  /// * [ElementsJumpModuleType]
  String? jumpType;
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
  /// 模块列表（右侧浮动列表数据源）
  final RxList<CardWordSemanticModuleItem> moduleItems = <CardWordSemanticModuleItem>[].obs;
  /// 当前释义ID
  final RxInt currentSemanticId = 0.obs;

  /// 左边卡片图片
  final RxString leftCardImage = ''.obs;

  /// 收藏状态缓存
  final RxMap<String, bool> semanticFavoritedStatus = <String, bool>{}.obs;
  final RxBool isMemoryStatusLoading = false.obs;

  final RxBool isLoading = true.obs;
  final RxBool isSemanticSwitching = false.obs;

  // 缓存已加载的释义详情
  final Map<int, CardWordSemanticDetilsEntity> cachedDetils = <int, CardWordSemanticDetilsEntity>{};

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      contentId = Get.arguments['contentId'];
      jumpType = Get.arguments['jumpType'];
      semanticIds = Get.arguments['semanticIds'];
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

  /// 获取权益数量
  Future<void> getRightCount() async {
    final RightCountDetailsEntity? rightCountDetailsEntity =
        await UserRequest.getCardRightCount();
    if (rightCountDetailsEntity == null) return;
    final int extendCard = rightCountDetailsEntity.extendCard ?? 0;
    if (extendCard == 0) return;
    ToastUtils.showToast(text: '您还有$extendCard次探索卡片', type: ToastType.warning);
  }

  /// 获取短语详细信息（使用新接口）
  Future<void> getDetils() async {
    if (contentId == null) return;
    final int? initSemanticId =
        semanticIds?.isNotEmpty == true ? semanticIds!.first : null;
    final CardWordSemanticDetilsEntity? detils =
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
    refreshCurrentSemanticFavorited();
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
      await refreshCurrentSemanticFavorited();
    } finally {
      isSemanticSwitching.value = false;
    }
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
    moduleItems.value =
        detils.moduleItems?.whereType<CardWordSemanticModuleItem>().toList() ?? <CardWordSemanticModuleItem>[];
    currentSemanticId.value = detils.semanticId ?? 0;
    leftCardImage.value = detils.semantic?.imageUrl ?? '';
  }

  String _buildFavKey(int? cId, String? cType, int? sId) =>
      '${cId ?? 0}_${cType ?? ''}_${sId ?? 0}';

  bool isCurrentSemanticFavorited() {
    final String key = _buildFavKey(
      cardDetils.value.contentId,
      cardDetils.value.contentType,
      currentSemanticId.value,
    );
    return semanticFavoritedStatus[key] ?? false;
  }

  void setCurrentSemanticFavorited(bool favorited) {
    final String key = _buildFavKey(
      cardDetils.value.contentId,
      cardDetils.value.contentType,
      currentSemanticId.value,
    );
    semanticFavoritedStatus[key] = favorited;
  }

  /// 通过旧语义列表接口获取当前释义的记忆状态
  Future<void> refreshCurrentSemanticFavorited() async {
    final int? cId = cardDetils.value.contentId;
    final String? cType = cardDetils.value.contentType;
    final int semId = currentSemanticId.value;
    if (cId == null || (cType ?? '').isEmpty || semId <= 0) {
      setCurrentSemanticFavorited(false);
      return;
    }
    final String key = _buildFavKey(cId, cType, semId);
    try {
      isMemoryStatusLoading.value = true;
      final List<ElementsCardEntityDatas>? groups =
          await ListenAndReadRequest.getKnowledgeSemantics(<String, dynamic>{
        'contents': <Map<String, dynamic>>[
          <String, dynamic>{'uid': cId, 'type': cType},
        ],
      });
      if (groups == null || groups.isEmpty) {
        semanticFavoritedStatus[key] = false;
        return;
      }
      // favorited 在 contentList 子列表（semantic 级别）中
      for (final ElementsCardEntityDatas group in groups) {
        final List<ElementsCardEntityDatas?> children = group.contentList ?? [];
        final ElementsCardEntityDatas? match = children.firstWhereOrNull(
          (ElementsCardEntityDatas? item) => item?.semanticId == semId,
        );
        if (match != null) {
          semanticFavoritedStatus[key] = match.isFavorited;
          return;
        }
      }
      semanticFavoritedStatus[key] = false;
    } finally {
      isMemoryStatusLoading.value = false;
    }
  }

  /// 更新左边图片
  void updateLeftImage(String imageUrl) {
    if (leftCardImage.value == imageUrl) return;
    leftCardImage.value = imageUrl;
  }

  Future<void> bottomMenuTypeFun(ElementsBottomMenuType type) async {
    if (type == ElementsBottomMenuType.upgradeCard) {
      await Get.toNamed(
        Routes.ELEMENTS_UPGRADE_CARD,
        arguments: <String, dynamic>{'knowledge': 'a boy'},
      );
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
