import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/mixins/mixins.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../common/etymology_canvas_widgets/etymology_canvas_widget.dart';

class EtymologyMemoryController extends GetxController with DualBreadcrumbMixin, PageRefreshAwareMixin {
  final String tagText;
  EtymologyMemoryController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.ETYMOLOGY_MEMORY;

  @override
  String get breadcrumbTitle => "词源记忆树";

  String? contentType;
  int? contentId;
  int? semanticId;
  bool isManagement = false;

  final GlobalKey canvasViewportKey = GlobalKey();
  final GlobalKey treeSwitchKey = GlobalKey();
  final GlobalKey semanticBottomBarKey = GlobalKey();
  final EtymologyCanvasController canvasController = EtymologyCanvasController();
  final Rx<CardContentEtymologyDetailEntity> detailData = CardContentEtymologyDetailEntity().obs;
  final RxList<CardContentEtymologySemanticItem> semanticItems = <CardContentEtymologySemanticItem>[].obs;
  final RxInt currentContentId = 0.obs;
  final RxInt currentSemanticId = 0.obs;
  final RxInt currentTreeUid = 0.obs;
  final RxString currentNodeId = ''.obs;
  final Rxn<CardContentEtymologyTree> currentTree = Rxn<CardContentEtymologyTree>();
  final RxBool isLoading = true.obs;
  final RxBool shouldFitCanvas = false.obs;
  final RxBool shouldFocusCanvas = false.obs;
  final RxBool isContentExpanded = true.obs;
  final ConfigController configController = Get.find<ConfigController>();
  bool hasCompletedInitialCanvasFit = false;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      final dynamic isManagementValue = Get.arguments['isManagement'];
      isManagement = isManagementValue == true || isManagementValue?.toString() == 'true';
      contentType = Get.arguments['contentType']?.toString();
      contentId = Get.arguments['contentId'];
      semanticId = Get.arguments['semanticId'];
    }
    initBreadcrumb(tagText);
    initData();
  }

  @override
  Future<void> onReturnPageRefresh(String? key) async{
    await initData(showLoading: false);
  }

  Future<void> initData({bool showLoading = true}) async {
    final String requestContentType = (contentType ?? '').trim();
    if (requestContentType.isEmpty || contentId == null) {
      isLoading.value = false;
      ToastUtils.showToast(text: '缺少词源参数');
      return;
    }
    try {
      if (showLoading) {
        ToastUtils.showLoading();
        isLoading.value = true;
      }
      await getDetils();
    } finally {
      if (showLoading) ToastUtils.hideLoading();
    }
  }

  Future<void> getDetils() async {
    final String requestContentType = (contentType ?? '').trim();
    if (requestContentType.isEmpty || contentId == null) return;
    final CardContentEtymologyDetailEntity? detils =
        await ElementsRequest.getContentEtymologyDetail(
      contentType: requestContentType,
      contentId: contentId!,
      semanticId: semanticId,
    );
    if (detils == null) {
      isLoading.value = false;
      return;
    }
    _applyDetils(detils);
    isLoading.value = false;
  }

  void _applyDetils(CardContentEtymologyDetailEntity detils) {
    detailData.value = detils;
    isContentExpanded.value = true;
    hasCompletedInitialCanvasFit = false;
    semanticItems.value = detils.semanticItems
            ?.whereType<CardContentEtymologySemanticItem>()
            .toList() ??
        <CardContentEtymologySemanticItem>[];
    final CardContentEtymologySemanticItem? selectedItem =
        _findInitialSemanticItem(detils);
    final CardContentEtymologyTree? tree =
        _findTreeBySemanticItem(selectedItem) ?? _findTreeByUid(detils.activeTreeUid);
    _applyCurrentSelection(
      tree: tree,
      contentId: selectedItem?.contentId ?? 0,
      semanticId: selectedItem?.semanticId ?? 0,
      nodeId: _findNodeIdBySemanticItem(tree, selectedItem) ?? '',
      shouldFit: true,
    );
  }

  List<CardContentEtymologyTree> treeList() {
    return detailData.value.trees?.whereType<CardContentEtymologyTree>().toList() ??
        <CardContentEtymologyTree>[];
  }

  Future<void> switchTree(int treeUid) async {
    final CardContentEtymologyTree? tree = _findTreeByUid(treeUid);
    if (tree == null) return;
    collapseContentWidget();
    final CardContentEtymologySemanticItem? selectedItem =
        _findSelectedSemanticItemInTree(tree);
    _applyCurrentSelection(
      tree: tree,
      contentId: selectedItem?.contentId ?? 0,
      semanticId: selectedItem?.semanticId ?? 0,
      nodeId: _findNodeIdBySemanticItem(tree, selectedItem) ?? '',
      shouldFit: true,
    );
  }

  Future<void> switchSemantic(int semanticId) async {
    if (semanticId <= 0) return;
    final CardContentEtymologySemanticItem? selectedItem =
        _findSemanticItemById(semanticId);
    if (selectedItem == null) return;
    final CardContentEtymologyTree? tree = _findTreeBySemanticItem(selectedItem);
    if (tree == null) {
      ToastUtils.showToast(text: '该义项暂未入树');
      return;
    }
    collapseContentWidget();
    _applyCurrentSelection(
      tree: tree,
      contentId: selectedItem.contentId ?? 0,
      semanticId: selectedItem.semanticId ?? 0,
      nodeId: _findNodeIdBySemanticItem(tree, selectedItem) ?? '',
      shouldFit: false,
    );
    if (currentNodeId.value.isNotEmpty) shouldFocusCanvas.value = true;
  }

  void _applyCurrentSelection({
    required CardContentEtymologyTree? tree,
    required int contentId,
    required int semanticId,
    required String nodeId,
    required bool shouldFit,
  }) {
    currentTree.value = tree;
    currentTreeUid.value = tree?.uid ?? 0;
    currentContentId.value = contentId;
    currentSemanticId.value = semanticId;
    currentNodeId.value = nodeId;
    shouldFitCanvas.value = shouldFit;
  }

  void consumeCanvasFitRequest() {
    shouldFitCanvas.value = false;
  }

  void consumeCanvasFocusRequest() {
    shouldFocusCanvas.value = false;
  }

  void markInitialCanvasFitCompleted() {
    hasCompletedInitialCanvasFit = true;
  }

  void collapseContentWidget() {
    if (!isContentExpanded.value) return;
    isContentExpanded.value = false;
  }

  void toggleContentExpanded() {
    isContentExpanded.value = !isContentExpanded.value;
  }

  CardContentEtymologyTree? _findTreeByUid(int? treeUid) {
    if (treeUid == null || treeUid <= 0) return null;
    for (final CardContentEtymologyTree tree in treeList()) {
      if (tree.uid == treeUid) return tree;
    }
    return null;
  }

  CardContentEtymologyTree? _findTreeBySemanticItem(
    CardContentEtymologySemanticItem? semanticItem,
  ) {
    if (semanticItem == null) return null;
    for (final CardContentEtymologyTree tree in treeList()) {
      if (_findNodeIdBySemanticItem(tree, semanticItem)?.isNotEmpty == true) return tree;
    }
    return null;
  }

  CardContentEtymologySemanticItem? _findInitialSemanticItem(
    CardContentEtymologyDetailEntity detils,
  ) {
    final int? targetContentId = detils.contentId;
    if (targetContentId == null) return null;
    final List<CardContentEtymologySemanticItem> matchedItems = semanticItems
        .where((item) => item.contentId == targetContentId)
        .toList();
    if (matchedItems.isEmpty) return null;
    final int? targetSemanticId = detils.semanticId;
    if (targetSemanticId != null) {
      for (final CardContentEtymologySemanticItem item in matchedItems) {
        if (item.semanticId == targetSemanticId) return item;
      }
    }
    if (matchedItems.length == 1) return matchedItems.first;
    return null;
  }

  CardContentEtymologySemanticItem? _findSemanticItemById(int semanticId) {
    for (final CardContentEtymologySemanticItem item in semanticItems) {
      if (item.semanticId == semanticId) return item;
    }
    return null;
  }

  CardContentEtymologySemanticItem? _findSelectedSemanticItemInTree(
    CardContentEtymologyTree tree,
  ) {
    final CardContentEtymologySemanticItem? currentItem =
        _findSemanticItemByContentAndSemantic(
      currentContentId.value,
      currentSemanticId.value,
    );
    if (_findNodeIdBySemanticItem(tree, currentItem)?.isNotEmpty == true) {
      return currentItem;
    }
    final int targetContentId = detailData.value.contentId ?? 0;
    if (targetContentId > 0) {
      for (final CardContentEtymologySemanticItem item in semanticItems) {
        if (item.contentId != targetContentId) continue;
        if (_findNodeIdBySemanticItem(tree, item)?.isNotEmpty == true) return item;
      }
    }
    return null;
  }

  CardContentEtymologySemanticItem? _findSemanticItemByContentAndSemantic(
    int contentId,
    int semanticId,
  ) {
    if (contentId <= 0 || semanticId <= 0) return null;
    for (final CardContentEtymologySemanticItem item in semanticItems) {
      if (item.contentId == contentId && item.semanticId == semanticId) return item;
    }
    return null;
  }

  String? _findNodeIdBySemanticItem(
    CardContentEtymologyTree? tree,
    CardContentEtymologySemanticItem? semanticItem,
  ) {
    if (tree == null || semanticItem == null) return null;
    final int? targetContentId = semanticItem.contentId;
    final int? targetSemanticId = semanticItem.semanticId;
    if (targetContentId == null || targetSemanticId == null) return null;
    final List<CardContentEtymologyNode> nodes =
        tree.nodes?.whereType<CardContentEtymologyNode>().toList() ?? <CardContentEtymologyNode>[];
    for (final CardContentEtymologyNode node in nodes) {
      final List<CardContentEtymologyBinding> bindings =
          node.bindings?.whereType<CardContentEtymologyBinding>().toList() ??
              <CardContentEtymologyBinding>[];
      for (final CardContentEtymologyBinding binding in bindings) {
        final List<int> semanticIds = binding.semanticIds?.whereType<int>().toList() ?? <int>[];
        if (binding.contentId == targetContentId && semanticIds.contains(targetSemanticId)) {
          return node.nodeId;
        }
      }
    }
    return null;
  }
}
