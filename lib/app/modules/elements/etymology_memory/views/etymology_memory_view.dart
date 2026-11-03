import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../management/common/commons.dart';
import '../../common/elements_public_widgets.dart';
import '../../common/etymology_canvas_widgets/etymology_canvas_widget.dart';
import '../bindings/etymology_memory_binding.dart';
import '../controllers/etymology_memory_controller.dart';

class EtymologyMemoryView extends GetView<EtymologyMemoryController> {
  final String tagText;
  const EtymologyMemoryView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      EtymologyMemoryView(tagText: tag),
      binding: EtymologyMemoryBinding(tagText: tag),
      routeName: Routes.ETYMOLOGY_MEMORY,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      backgroundColor: AppTheme.cBgPrimary,
      body: Obx(
        () {
          _consumeCanvasInteractionRequests();
          return Column(
            children: [
              BreadcrumbWidget(
                isCompatibleManage: controller.isManagement,
                actionWidget: GeneralSettingButtonWidget(
                  isManagement: controller.isManagement,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 90.wMin),
                  child: _buildCanvasWidget(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _consumeCanvasInteractionRequests() {
    if (controller.shouldFitCanvas.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!controller.shouldFitCanvas.value) return;
        controller.consumeCanvasFitRequest();
        controller.canvasController.fitToCanvas(
          insets: _buildCanvasFitInsets(),
        );
        if (controller.hasCompletedInitialCanvasFit) {
          controller.collapseContentWidget();
          return;
        }
        controller.markInitialCanvasFitCompleted();
      });
      return;
    }
    if (controller.shouldFocusCanvas.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!controller.shouldFocusCanvas.value) return;
        controller.consumeCanvasFocusRequest();
        controller.canvasController.focusToNode(
          controller.currentNodeId.value,
          contentId: controller.currentContentId.value,
          semanticId: controller.currentSemanticId.value,
          insets: _buildCanvasFitInsets(),
        );
      });
    }
  }

  Widget _buildContentWidget() {
    final CardContentEtymologyDetailEntity detailData = controller.detailData.value;
    final CardContentEtymologyTree? currentTree = controller.currentTree.value;
    final String content = detailData.content ?? '';
    final String treeTitle = _findLanguageText(currentTree?.title, 'zh');
    final String descriptions = _findLanguageText(currentTree?.descriptions, 'zh');
    final bool isExpanded = controller.isContentExpanded.value;
    return TapScaleWidget(
      sclae: 1.0,
      onTap: controller.toggleContentExpanded,
      child: PlatformBackdropFilterWidget(
        sigmaX: 4.wMin,
        sigmaY: 4.wMin,
        child: Container(
          padding: EdgeInsets.all(8.wMin),
          decoration: BoxDecoration(
            color: AppTheme.cSurfaceGhostBgSubtle,
            borderRadius: BorderRadius.circular(16.wMin),
            border: Border.all(
              color: AppTheme.cBorderSubtle.color,
              width: 1.wMin,
            ),
          ),
          width: 300.wMin,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      content,
                      style: TextStyle(
                        fontSize: 28.wMin,
                        color: AppTheme.cTextPrimary.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(width: 6.wMin),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_right_rounded,
                    size: 24.wMin,
                    color: AppTheme.cTextSecondary.color,
                  ),
                ],
              ),
              if (isExpanded) ...[
                SizedBox(height: 6.wMin),
                Text(
                  treeTitle,
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color: AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 6.wMin),
                Text(
                  descriptions,
                  style: TextStyle(
                    fontSize: 16.wMin,
                    color: AppTheme.cTextSecondary.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCanvasWidget() {
    final CardContentEtymologyTree? currentTree = controller.currentTree.value;
    final bool isLoading = controller.isLoading.value;
    return currentTree == null
        ? isLoading
            ? const SizedBox.shrink()
            : const NotDataWidget(message: '暂无词源数据')
        : Stack(
            children: [
              Container(
                key: controller.canvasViewportKey,
                child: EtymologyCanvasWidget(
                  controller: controller.canvasController,
                  tree: currentTree,
                  activeNodeId: controller.currentNodeId.value,
                  activeContentId: controller.currentContentId.value,
                  activeSemanticId: controller.currentSemanticId.value,
                  contentText: controller.detailData.value.content ?? '',
                  onInteractionStart: controller.collapseContentWidget,
                ),
              ),
              Positioned(
                top: 8.wMin,
                right: 8.wMin,
                child: _buildCanvasReResetWidget(),
              ),
              Positioned(
                top: 8.wMin,
                left: 8.wMin,
                child: _buildContentWidget(),
              ),
              if (controller.treeList().length > 1)
                Positioned(
                  top: 8.wMin,
                  left: 0,
                  right: 0,
                  child: _buildTreeSwitchWidget(),
                ),
              Positioned(
                bottom: 8.wMin,
                left: 0,
                right: 0,
                child: _buildSemanticBottomBar(),
              ),
            ],
          );
  }

  Widget _buildTreeSwitchWidget() {
    final List<CardContentEtymologyTree> trees = controller.treeList();
    final int currentTreeUid = controller.currentTreeUid.value;
    return Align(
      alignment: Alignment.topCenter,
      child: KeyedSubtree(
        key: controller.treeSwitchKey,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(99.wMin),
          child: PlatformBackdropFilterWidget(
            sigmaX: 4.wMin,
            sigmaY: 4.wMin,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 8.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: AppTheme.cSurfaceSearchBackground.color,
                border: Border.all(
                  color: AppTheme.cBorderDark.color,
                  width: 1.wMin,
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  height: 44.wMin,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List<Widget>.generate(trees.length, (int index) {
                      final CardContentEtymologyTree tree = trees[index];
                      final int? treeUid = tree.uid;
                      final bool isSelected = tree.uid == currentTreeUid;
                      return Padding(
                        padding: EdgeInsets.only(right: index == trees.length - 1 ? 0 : 12.wMin),
                        child: TapScaleWidget(
                          sclae: 1.02,
                          onTap: isSelected || treeUid == null ? null : () => controller.switchTree(treeUid),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 14.wMin, vertical: 8.wMin),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999.wMin),
                              color: isSelected ? AppTheme.cSurfaceWarning.color.withValues(alpha: 0.14) : null,
                              border: Border.all(
                                color: isSelected ? AppTheme.cSurfaceWarning.color : Colors.transparent,
                                width: 1.wMin,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _findLanguageText(tree.title, 'zh'),
                              style: TextStyle(
                                fontSize: 16.wMin,
                                color: isSelected ? AppTheme.cSurfaceWarning.color : AppTheme.cTextPrimary.color,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSemanticBottomBar() {
    final ConfigController configController = Get.find<ConfigController>();
    final List<LanguageConfigColorEntityInfo?>? posConfigs = configController.colorConfigs.value.pos;
    final List<SemanticChipData> chips = controller.semanticItems
        .where((item) => item.semanticId != null)
        .map((item) => SemanticChipData(
              id: item.semanticId!,
              text: item.translate ?? '',
              color: _resolveSemanticChipColor(posConfigs, item),
            ))
        .toList();
    if (chips.isEmpty) return const SizedBox.shrink();
    return Center(
      child: KeyedSubtree(
        key: controller.semanticBottomBarKey,
        child: ElementsSemanticBottomBar(
          items: chips,
          currentId: controller.currentSemanticId.value,
          onTapItem: (int id) => controller.switchSemantic(id),
        ),
      ),
    );
  }

  Color? _resolveSemanticChipColor(
    List<LanguageConfigColorEntityInfo?>? posConfigs,
    CardContentEtymologySemanticItem item,
  ) {
    final String posCode = (item.pos ?? '').trim();
    final LanguageConfigColorModel? colorConfig = StatusUtils.getConfigColor(posConfigs, posCode);
    return colorConfig?.color?.borderColor ?? colorConfig?.color?.textColor;
  }

  /// 重置
  Widget _buildCanvasReResetWidget() {
    return SizedBox(
      width: 200,
      child: Column(
        children: [
          PlatformBackdropFilterWidget(
              sigmaX: 4.wMin,
              sigmaY: 4.wMin,
              child: ButtonWidget(
                text: "适应画布",
                padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 6.wMin),
                color: AppTheme.cSurfaceGhostBgSubtle,
                border: Border.all(
                  color: AppTheme.cBorderSubtle,
                  width: 1.wMin,
                ),
                fontSize: 20.wMin,
                fontColor: AppTheme.cTextSecondary.color,
                fontWeight: FontWeight.w500,
                sclae: 1.03,
                onTap: () {
                  controller.collapseContentWidget();
                  controller.canvasController.fitToCanvas(
                    insets: _buildCanvasFitInsets(),
                  );
                },
              )),
          SizedBox(height: 12.wMin),
          Text(
            '可拖拽移动 · 捏合缩放',
            style: TextStyle(
              fontSize: 18.wMin,
              color: AppTheme.cTextSecondary.color,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  String _findLanguageText(List<LanguageText?>? values, String lang) {
    if (values == null) return '';
    for (final LanguageText? item in values) {
      if (item?.lang == lang) {
        return item?.text ?? '';
      }
    }
    return '';
  }

  EdgeInsets _buildCanvasFitInsets() {
    final Rect? canvasRect = _measureGlobalRect(controller.canvasViewportKey);
    if (canvasRect == null) return EdgeInsets.zero;
    final Rect? treeSwitchRect = _measureGlobalRect(controller.treeSwitchKey);
    final Rect? semanticBarRect = _measureGlobalRect(controller.semanticBottomBarKey);
    final double topInset = treeSwitchRect == null ? 0 : math.max(treeSwitchRect.bottom - canvasRect.top, 0);
    final double bottomInset = semanticBarRect == null ? 0 : math.max(canvasRect.bottom - semanticBarRect.top, 0);
    return EdgeInsets.only(top: topInset, bottom: bottomInset);
  }

  Rect? _measureGlobalRect(GlobalKey key) {
    final BuildContext? currentContext = key.currentContext;
    if (currentContext == null) return null;
    final RenderObject? renderObject = currentContext.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return null;
    final Offset offset = renderObject.localToGlobal(Offset.zero);
    return offset & renderObject.size;
  }
}
