import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../routes/routes.dart';
import '../../../../routes/routes_breadcrumb_utils.dart';
import '../../model/elements_jump_module_type.dart';

class ElementsSentenceAnalysisController extends GetxController
    with RoutesBreadcrumbMixin {
  final String tagText;
  ElementsSentenceAnalysisController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.EN_SENTENCE_ANALYSIS;

  @override
  String get breadcrumbTitle => "语句分析";

  /// 页面路由入参：句子主键
  int? contentId;

  /// 页面路由入参：分析层
  String? layer;

  /// 页面路由入参：旧版模块语义
  String? module;

  /// 分析页当前分析层
  final RxString analysisLayer = 'chunks'.obs;

  /// 分析页结构详情原始数据
  final Rx<EnSentenceStructureDetailEntity> sentenceDetils = EnSentenceStructureDetailEntity().obs;

  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    _initArguments();
    if (contentId != null) {
      initData();
    } else {
      isLoading.value = false;
    }
  }

  void _initArguments() {
    final dynamic arguments = Get.arguments;
    if (arguments == null) return;
    contentId = arguments['contentId'];
    layer = arguments['layer']?.toString();
    module = arguments['module']?.toString();
    analysisLayer.value = _resolveLayer(
      explicitLayer: layer,
      module: module,
    );
  }

  Future<void> initData() async {
    try {
      ToastUtils.showLoading();
      isLoading.value = true;
      await getDetilsV2();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> getDetilsV2() async {
    if (contentId == null) {
      isLoading.value = false;
      return;
    }
    final EnSentenceStructureDetailEntity? detils =
        await ElementsRequest.getSentenceStructureDetils(contentId!);
    if (detils == null) {
      isLoading.value = false;
      return;
    }
    sentenceDetils.value = detils;
    isLoading.value = false;
  }

  void changeAnalysisLayer(String layer) {
    if ((layer).isEmpty || analysisLayer.value == layer) return;
    analysisLayer.value = layer;
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
}
