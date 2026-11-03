import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../routes/routes.dart';
import '../../../../routes/routes_breadcrumb_utils.dart';
import '../../model/elements_jump_module_type.dart';

class ElementsSentenceDetilsV2Controller extends GetxController
    with RoutesBreadcrumbMixin {
  final String tagText;
  ElementsSentenceDetilsV2Controller({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.EN_SENTENCE_DETAIL;

  @override
  String get breadcrumbTitle => "语境词典详情";

  /// 页面路由入参：句子主键
  int? contentId;

  /// 页面路由入参：旧版模块跳转语义，V2 只在白名单范围内透传给 module
  String? jumpType;

  /// 页面路由入参：保留旧链路带过来的 semanticIds，当前 V2 先只保存不消费
  List<int?>? semanticIds;

  /// 页面当前分析层，优先使用显式传参，其次由 jumpType 映射
  final RxString analysisLayer = 'chunks'.obs;

  /// 左侧发音区域当前选中的音标类型，继续复用旧交互
  final RxInt englishAmericanType = 0.obs;

  /// V2 句子详情原始数据
  final Rx<EnSentenceDetailV2Entity> sentenceDetils = EnSentenceDetailV2Entity().obs;

  final RxBool isLoading = true.obs;
  final RxBool hasLoaded = false.obs;
  final RxBool isFavorited = false.obs;
  final RxBool isMemoryStatusLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    _initArguments();
    if (contentId != null) {
      initData();
    }
  }

  void _initArguments() {
    final dynamic arguments = Get.arguments;
    if (arguments == null) return;
    contentId = arguments['contentId'];
    jumpType = arguments['jumpType'];
    semanticIds = arguments['semanticIds']?.cast<int?>();
    analysisLayer.value = _resolveLayer(
      explicitLayer: arguments['layer']?.toString(),
      module: jumpType,
    );
  }

  Future<void> initData() async {
    try {
      ToastUtils.showLoading();
      isLoading.value = true;
      await Get.find<ConfigController>().ensureStyleReady();
      await getDetilsV2();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> reloadData({String? layer}) async {
    if ((layer ?? '').isNotEmpty) {
      analysisLayer.value = layer!;
    }
    await initData();
  }

  Future<void> getDetilsV2() async {
    if (contentId == null) {
      isLoading.value = false;
      return;
    }
    final EnSentenceDetailV2Entity? detils = await ElementsRequest.getSentencesDetilsV2(
      contentId!,
      module: _resolveRequestModule(jumpType),
      layer: analysisLayer.value,
    );
    if (detils == null) {
      isLoading.value = false;
      return;
    }
    sentenceDetils.value = detils;
    hasLoaded.value = true;
    if ((detils.layer ?? '').isNotEmpty) {
      analysisLayer.value = detils.layer!;
    }
    _updateDetailBreadcrumbTitle(detils);
    await refreshFavoritedStatus();
    isLoading.value = false;
  }

  /// 沿用旧版语义级记忆态回查；V2 详情当前优先使用路由透传的 semanticIds。
  Future<void> refreshFavoritedStatus() async {
    final EnSentenceDetailV2Entity detils = sentenceDetils.value;
    final int? semanticId = resolveCurrentSemanticId();
    if (detils.contentId == null ||
        (detils.contentType ?? '').isEmpty ||
        semanticId == null ||
        semanticId <= 0) {
      isFavorited.value = false;
      return;
    }
    try {
      isMemoryStatusLoading.value = true;
      final List<ElementsCardEntityDatas>? groups =
          await ListenAndReadRequest.getKnowledgeSemantics(<String, dynamic>{
        'contents': <Map<String, dynamic>>[
          <String, dynamic>{
            'uid': detils.contentId,
            'type': detils.contentType,
          },
        ],
      });
      if (groups == null || groups.isEmpty) {
        isFavorited.value = false;
        return;
      }
      for (final ElementsCardEntityDatas group in groups) {
        final List<ElementsCardEntityDatas?> children = group.contentList ?? [];
        final ElementsCardEntityDatas? match = children.firstWhereOrNull(
          (ElementsCardEntityDatas? item) => item?.semanticId == semanticId,
        );
        if (match != null) {
          isFavorited.value = match.isFavorited;
          return;
        }
      }
      isFavorited.value = false;
    } finally {
      isMemoryStatusLoading.value = false;
    }
  }

  Future<void> reloadForStyleChange() async {
    try {
      ToastUtils.showLoading();
      isLoading.value = true;
      await getDetilsV2();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  void _updateDetailBreadcrumbTitle(EnSentenceDetailV2Entity detils) {
    final String title = (detils.content ?? '').trim();
    if (title.isEmpty) return;
    updateBreadcrumbTitle(
      title.length > 30 ? '${title.substring(0, 30)}...' : title,
    );
  }

  int? resolveCurrentSemanticId() {
    for (final int? semanticId in semanticIds ?? <int?>[]) {
      if ((semanticId ?? 0) > 0) {
        return semanticId;
      }
    }
    return null;
  }

  String _resolveLayer({
    String? explicitLayer,
    String? module,
  }) {
    if ((explicitLayer ?? '').isNotEmpty) {
      return explicitLayer!;
    }
    if (module == ElementsJumpModuleType.SYNTACTIC_ANALYSIS) {
      return 'syntax';
    }
    if (module == ElementsJumpModuleType.COMPONENT_ANALYSIS) {
      return 'svoca';
    }
    if (module == ElementsJumpModuleType.CHUNK_ANALYSIS ||
        module == ElementsJumpModuleType.GRID_VIEW ||
        module == ElementsJumpModuleType.COLLAPSE_VIEW ||
        module == ElementsJumpModuleType.STRUCTURE_ANALYSIS) {
      return 'chunks';
    }
    return 'chunks';
  }

  String? _resolveRequestModule(String? module) {
    if (module == ElementsJumpModuleType.PRONUNCIATION_MEANING ||
        module == ElementsJumpModuleType.CORE_COMPONENTS ||
        module == ElementsJumpModuleType.VIEW_LEVEL ||
        module == ElementsJumpModuleType.MEMORIZE_SENTENCE) {
      return module;
    }
    return null;
  }
}
