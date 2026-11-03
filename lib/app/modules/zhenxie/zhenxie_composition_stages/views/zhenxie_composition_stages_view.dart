import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/values/app_font_value.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../management/common/commons.dart';
import '../../../../../utils/utils.dart';
import '../bindings/zhenxie_composition_stages_binding.dart';
import '../controllers/zhenxie_composition_stages_controller.dart';
import '../models/zhenxie_composition_stages_models.dart';
import 'zhenxie_composition_shelf_widget.dart';
import 'zhenxie_composition_stage_card_widget.dart';
import 'zhenxie_composition_user_strip_widget.dart';

class ZhenxieCompositionStagesView extends GetView<ZhenxieCompositionStagesController> {
  final String tagText;

  const ZhenxieCompositionStagesView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> toManage<T>({dynamic arguments}) async {
    final tag = '${Routes.ZHENXIE_COMPOSITION_STAGES}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ZhenxieCompositionStagesView(tagText: tag),
      binding: ZhenxieCompositionStagesBinding(tagText: tag),
      routeName: Routes.ZHENXIE_COMPOSITION_STAGES,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      ZhenxieCompositionStagesView(tagText: tag),
      binding: ZhenxieCompositionStagesBinding(tagText: tag),
      routeName: Routes.ZHENXIE_COMPOSITION_STAGES,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      backgroundColor: AppTheme.cBgPrimary,
      onRefresh: controller.initData,
      body: Column(
        children: [
          _buildBreadcrumbWidget(),
          SizedBox(height: 12.wMin),
          Expanded(
            child: Obx(() {
              // 书架吃本端书架数据，不跟远端阶梯列表的加载态绑定
              if (controller.currentView.value == 'shelf') {
                return Padding(
                  padding: EdgeInsets.only(left: 90.wMin, right: 90.wMin, top: 16.wMin, bottom: 120.wMin),
                  child: ZhenxieCompositionShelfWidget(controller: controller),
                );
              }
              if (controller.isLoading.value && controller.stageList.isEmpty) {
                return const Center();
              }
              if (controller.filteredStageList.isEmpty) {
                return NotDataWidget(message: "暂无匹配的写作阶梯");
              }
              return controller.currentView.value == 'map' ? _buildMapContent(context) : _buildListContent(context);
            }),
          ),
        ],
      ),
      floatingActionButton: _buildBottomBarWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /// 面包屑：用户端右侧带当前视图的汇总文案（如「45 张蓝图 · 六道大关」）
  Widget _buildBreadcrumbWidget() {
    return Obx(() {
      final String description = controller.discourseHome.value?.card?.description ?? '';
      final String summaryText = controller.getSummaryText();
      return BreadcrumbWidget(
        isCompatibleManage: controller.isManagement,
        actionWidget: description.isEmpty && summaryText.isEmpty
            ? null
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (description.isNotEmpty)
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 420.wMin),
                      child: Text(
                        description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.wMin,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.cZhenxieFontTertiary.color,
                        ),
                      ),
                    ),
                  if (description.isNotEmpty && summaryText.isNotEmpty) SizedBox(width: 16.wMin),
                  if (summaryText.isNotEmpty)
                    Text(
                      summaryText,
                      style: TextStyle(
                        fontSize: 13.wMin,
                        fontFamily: AppFontValue.robotoMono,
                        color: AppTheme.cZhenxieFontSecondary.color,
                      ),
                    ),
                ],
              ),
      );
    });
  }

  /// 底栏整体按端切换，管理端走筛选条，用户端走书架/地图条
  Widget _buildBottomBarWidget() {
    if (!controller.isManagement) {
      return ZhenxieCompositionUserStripWidget(controller: controller);
    }
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 90.wMin),
      child: Obx(() {
        return Row(
          children: [
            Expanded(
              child: FilterStripWidget(
                startText: '当前 ${controller.stageTotalCount.value} 阶',
                sorts: controller.currentView.value == 'list' ? {...controller.filterSorts} : null,
                conditions: {...controller.filterConditions},
                searchs: controller.filterSearchs,
                searchSingleWidth: 420.wMin,
                onSorts: controller.onSortsChanged,
                onConditions: controller.onConditionsChanged,
                onReset: controller.onResetFilters,
                onSearch: controller.onSearch,
                onSingleClearSearch: controller.onSearch,
              ),
            ),
            SizedBox(width: 16.wMin),
            _buildViewSwitchWidget(),
          ],
        );
      }),
    );
  }

  Widget _buildViewSwitchWidget() {
    return Obx(() {
      return Container(
        padding: EdgeInsets.all(4.wMin),
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceLayerBase.color,
          borderRadius: BorderRadius.circular(999.wMin),
          border: Border.all(
            color: AppTheme.cBorderThin.color,
            width: 1.wMin,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildViewSwitchItem('map', '地图'),
            SizedBox(width: 4.wMin),
            _buildViewSwitchItem('list', '列表'),
          ],
        ),
      );
    });
  }

  Widget _buildViewSwitchItem(String value, String text) {
    final bool selected = controller.currentView.value == value;
    return GestureDetector(
      onTap: () {
        controller.switchView(value);
      },
      child: Container(
        width: 92.wMin,
        height: 48.wMin,
        decoration: BoxDecoration(
          color: selected ? AppTheme.cTextBrand.color : Colors.transparent,
          borderRadius: BorderRadius.circular(999.wMin),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 20.wMin,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : AppTheme.cTextSecondary.color,
          ),
        ),
      ),
    );
  }

  Widget _buildMapContent(BuildContext context) {
    const double laneLabelWidth = 200;
    const double topReserve = 64;
    const double bottomReserve = 100;
    const double milestoneTopInset = 8;
    const double stageNodeVerticalPadding = 8;
    const double stageNodeHorizontalGap = 16;
    const double stageNodeTitleGap = 8;
    const double stageNodeTitleHeight = 22;

    final List<CompositionStageMilestoneGroupModel> groups = controller.buildMilestoneGroups();
    final List<CompositionStageMapColumnModel> columns = controller.mapColumns.toList();
    final int laneCount = controller.laneGenreNidList.length;

    if (laneCount == 0) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double viewportHeight = constraints.maxHeight;
        final double laneAreaHeight = math.max(0, viewportHeight - topReserve.wMin - bottomReserve.wMin);
        final double laneHeight = laneAreaHeight / laneCount;
        final double columnWidth = math.max(
          0,
          laneHeight -
              stageNodeVerticalPadding.wMin * 2 -
              stageNodeTitleGap.wMin -
              stageNodeTitleHeight.wMin +
              stageNodeHorizontalGap.wMin,
        );
        final double contentViewportWidth = math.max(0, constraints.maxWidth - laneLabelWidth.wMin);

        return Row(
          children: [
            SizedBox(
              width: laneLabelWidth.wMin,
              height: viewportHeight,
              child: Stack(
                children: List.generate(laneCount, (index) {
                  final double top = topReserve.wMin + index * laneHeight;
                  return Positioned(
                    left: 0,
                    right: 0,
                    top: top,
                    height: laneHeight,
                    child: _buildLaneBackground(index, showLabel: true, drawLeftBorder: true),
                  );
                }),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _buildMapLaneOverlay(
                      laneCount: laneCount,
                      topReserve: topReserve.wMin,
                      bottomReserve: bottomReserve.wMin,
                      laneHeight: laneHeight,
                    ),
                  ),
                  Positioned.fill(
                    child: ListView.builder(
                      controller: controller.mapScrollController,
                      scrollDirection: Axis.horizontal,
                      itemExtent: columnWidth,
                      itemCount: columns.length,
                      itemBuilder: (context, index) {
                        return _buildMapColumn(
                          context,
                          column: columns[index],
                          laneCount: laneCount,
                          viewportHeight: viewportHeight,
                          topReserve: topReserve.wMin,
                          laneHeight: laneHeight,
                        );
                      },
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: topReserve.wMin,
                    bottom: bottomReserve.wMin,
                    child: Container(
                      width: 1.wMin,
                      color: AppTheme.cBorderTranslucentSubtle.color,
                    ),
                  ),
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: controller.mapScrollController,
                      builder: (context, _) {
                        return _buildMilestoneOverlay(
                          groups: groups,
                          columnWidth: columnWidth,
                          viewportWidth: contentViewportWidth,
                          viewportHeight: viewportHeight,
                          topInset: milestoneTopInset.wMin,
                          bottomReserve: bottomReserve.wMin,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLaneBackground(int laneIndex, {required bool showLabel, required bool drawLeftBorder}) {
    final Color? laneColor = controller.getLaneGenreColor(laneIndex);
    return Container(
      padding: EdgeInsets.fromLTRB(12.wMin, 40.wMin, 12.wMin, 40.wMin),
      decoration: BoxDecoration(
          color: showLabel ? AppTheme.cSurfaceTranslucentBase.color : AppTheme.cSurfaceTranslucentElevated.color,
          border: Border(
            top: BorderSide(
              color: laneIndex == 0 ? AppTheme.cBorderTranslucentSubtle.color : Colors.transparent,
              width: 1.wMin,
            ),
            bottom: BorderSide(
              color: AppTheme.cBorderTranslucentSubtle.color,
              width: 1.wMin,
            ),
            left: BorderSide(
              color: drawLeftBorder ? AppTheme.cBorderTranslucentSubtle.color : Colors.transparent,
              width: 1.wMin,
            ),
          )),
      child: showLabel
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.getLaneTitle(laneIndex),
                  style: TextStyle(
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w500,
                    fontFamily: AppFontValue.sourceHanSerifCN,
                    color: laneColor,
                  ),
                ),
                SizedBox(height: 8.wMin),
                Text(
                  controller.getLaneSubtitle(laneIndex),
                  style: TextStyle(
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w400,
                    fontFamily: AppFontValue.robotoMono,
                    color: AppTheme.cTextSecondary.color,
                  ),
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildMapColumn(
    BuildContext context, {
    required CompositionStageMapColumnModel column,
    required int laneCount,
    required double viewportHeight,
    required double topReserve,
    required double laneHeight,
  }) {
    return SizedBox(
      height: viewportHeight,
      child: Stack(
        children: [
          if (column.laneIndex != null)
            Positioned(
              left: 0,
              right: 0,
              top: topReserve + column.laneIndex! * laneHeight,
              height: laneHeight,
              child: _buildStageNode(context, column.stage),
            ),
        ],
      ),
    );
  }

  Widget _buildMapLaneOverlay({
    required int laneCount,
    required double topReserve,
    required double bottomReserve,
    required double laneHeight,
  }) {
    return Stack(
      children: List.generate(laneCount, (laneIndex) {
        final double top = topReserve + laneIndex * laneHeight;
        return Positioned(
          left: 0,
          right: 0,
          top: top,
          height: laneHeight,
          child: _buildLaneBackground(
            laneIndex,
            showLabel: false,
            drawLeftBorder: false,
          ),
        );
      }),
    );
  }

  Widget _buildMilestoneOverlay({
    required List<CompositionStageMilestoneGroupModel> groups,
    required double columnWidth,
    required double viewportWidth,
    required double viewportHeight,
    required double topInset,
    required double bottomReserve,
  }) {
    final double scrollOffset = controller.mapScrollController.hasClients ? controller.mapScrollController.offset : 0;
    return IgnorePointer(
      child: Stack(
        children: groups.map((group) {
          final double left = group.startIndex * columnWidth - scrollOffset;
          final double width = (group.endIndex - group.startIndex + 1) * columnWidth;
            final List<String> milestoneLabels = group.milestoneList
                .map((item) => controller.getLangText(item.name, 'zh'))
                .where((text) => text.isNotEmpty)
                .toList();
          if (left + width <= 0 || left >= viewportWidth) {
            return const SizedBox.shrink();
          }
          return Positioned(
            left: left,
            top: topInset,
            width: width,
            height: viewportHeight - bottomReserve - topInset,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.wMin),
                      color: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.12),
                      border: Border.all(
                        color: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.55),
                        width: 1.wMin,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 10.wMin,
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4.wMin,
                      runSpacing: 4.wMin,
                      children: [
                        Icon(Icons.lock, size: 20.wMin, color: AppTheme.cTextPrimary.color),
                        if (milestoneLabels.isNotEmpty)
                          Text(
                            milestoneLabels.first,
                            style: TextStyle(
                              fontSize: 24.wMin,
                              fontWeight: FontWeight.w500,
                              fontFamily: AppFontValue.sourceHanSerifCN,
                              color: AppTheme.cTextPrimary.color,
                              height: 1.0,
                            ),
                          ),
                        ...milestoneLabels.skip(1).map((label) {
                          return Container(
                            padding: EdgeInsets.all(4.wMin),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2),
                                width: 1.wMin,
                              ),
                              borderRadius: BorderRadius.circular(4.wMin),
                              color: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.12),
                            ),
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 20.wMin,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.cSurfaceWarning.color,
                                height: 1.0,
                              ),
                            ),
                          );
                        }),
                      ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStageNode(BuildContext context, CompositionStageModel stage) {
    const double stageNodeVerticalPadding = 8;
    const double stageNodeHorizontalGap = 12;
    const double stageNodeTitleGap = 8;
    const double stageNodeTitleHeight = 22;
    final String title = controller.getLangText(stage.name, 'zh');

    return GestureDetector(
        onTap: () {
          _showStageDialog(context, stage);
        },
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: stageNodeHorizontalGap.wMin / 2,
            vertical: stageNodeVerticalPadding.wMin,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.wMin),
                    child: CachedImageWidget(
                      controller.getStageCoverUrl(stage),
                      alignment: Alignment.topCenter,
                      fit: BoxFit.cover,
                      errorWidget: buildEmptyWidget(fit: BoxFit.cover),
                      placeholder: buildEmptyWidget(fit: BoxFit.cover),
                    )),
              ),
              SizedBox(height: stageNodeTitleGap.wMin),
              SizedBox(
                height: stageNodeTitleHeight.wMin,
                child: Center(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.wMin,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }

  Widget _buildListContent(BuildContext context) {
    return GridView.builder(
      controller: controller.listScrollController,
      padding: EdgeInsets.only(left: 90.wMin, right: 90.wMin, top: 6.wMin, bottom: 180.wMin),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 20.wMin,
        mainAxisSpacing: 20.wMin,
        mainAxisExtent: 464.wMin,
      ),
      itemCount: controller.filteredStageList.length,
      itemBuilder: (context, index) {
        final CompositionStageModel stage = controller.filteredStageList[index];
        return _buildStageCardWidget(stage);
      },
    );
  }

  Future<void> _showStageDialog(BuildContext context, CompositionStageModel stage) async {
    // await showCupertinoDialog<Map<String, dynamic>?>(
    //   context: context,
    //   builder: (context) =>

    //   Material(
    //   color: AppTheme.cOverlayBackground,
    //   child: Center(
    //     child: Stack(
    //       children: [
    //         Container(
    //                    color: AppTheme.cBgSecondary.color,
    //           width: 640.wMin,
    //           child:   _buildStageCardWidget(
    //           stage,
    //           showClose: true,
    //           onClose: () {
    //             Navigator.of(context).pop();
    //           },
    //         ) ),
    //         Positioned(
    //           top: 18.wMin,
    //           right: 18.wMin,
    //           child: GestureDetector(
    //             onTap: () => Get.back(),
    //             child: Container(
    //               width: 48.wMin,
    //               height: 48.wMin,
    //               decoration: BoxDecoration(
    //                 color: AppTheme.cBgTertiary.withValues(alpha: 0.85),
    //                 shape: BoxShape.circle,
    //               ),
    //               child: Icon(
    //                 Icons.close_rounded,
    //                 size: 24.wMin,
    //                 color: AppTheme.cTextSecondary,
    //               ),
    //             ),
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // )
    // );
    await showCupertinoDialog<void>(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: AppTheme.cBgSecondary.color,
          child: Stack(
            children: [
              SizedBox(
                width: 640.wMin,
                child: _buildStageCardWidget(
                  stage,
                  showClose: true,
                  onClose: () {
                    Get.back();
                  },
                ),
              ),
              Positioned(
                top: 18.wMin,
                right: 18.wMin,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 48.wMin,
                    height: 48.wMin,
                    decoration: BoxDecoration(
                      color: AppTheme.cBgTertiary.withValues(alpha: 0.85),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 24.wMin,
                      color: AppTheme.cTextSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStageCardWidget(CompositionStageModel stage, {bool showClose = false, VoidCallback? onClose}) {
    final String minDifficultyLabel = DifficultieUtils.getLanguageDifficultieLevel1('en', stage.difficulty?.min)?.name?.text ?? '';
    final String maxDifficultyLabel = DifficultieUtils.getLanguageDifficultieLevel1('en', stage.difficulty?.max)?.name?.text ?? '';
    final String difficultyLabel = minDifficultyLabel.isEmpty || maxDifficultyLabel.isEmpty
        ? ''
        : minDifficultyLabel == maxDifficultyLabel
            ? minDifficultyLabel
            : '$minDifficultyLabel-$maxDifficultyLabel';
    return ZhenxieCompositionStageCardWidget(
      stage: stage,
      genre: controller.findGenre(stage.genreNid),
      beatMap: controller.beatMap,
      beatOrderList: controller.beatNidOrderList.toList(),
      difficultyLabel: difficultyLabel,
      milestoneLabel: controller.getMilestoneLabel(stage),
      coverUrl: controller.getStageCoverUrl(stage),
      genreColor: controller.getGenreColor(stage.genreNid),
      isManagement: controller.isManagement,
      showClose: showClose,
      onClose: onClose,
      onAction: (actionText) {
        if (actionText == '编辑') {
          if (showClose && onClose != null) {
            onClose();
            Future<void>.delayed(Duration.zero, () {
              controller.openEditPage(stage);
            });
            return;
          }
          controller.openEditPage(stage);
          return;
        }
        if (actionText == '蓝图') {
          if (showClose && onClose != null) {
            onClose();
            Future<void>.delayed(Duration.zero, () {
              controller.openBlueprintPage(stage);
            });
            return;
          }
          controller.openBlueprintPage(stage);
          return;
        }
        if (actionText == '任务') {
          if (showClose && onClose != null) {
            onClose();
            Future<void>.delayed(Duration.zero, () {
              controller.openTaskPage(stage);
            });
            return;
          }
          controller.openTaskPage(stage);
          return;
        }
        if (actionText == '范文') {
          if (showClose && onClose != null) {
            onClose();
            Future<void>.delayed(Duration.zero, () {
              controller.openExemplarPage(stage);
            });
            return;
          }
          controller.openExemplarPage(stage);
          return;
        }
        controller.showPlaceholderAction(actionText);
      },
      langTextGetter: controller.getLangText,
      beatNameGetter: controller.getBeatName,
      fillLabelGetter: controller.getFillLabel,
      headLabelGetter: controller.getHeadLabel,
      tailLabelGetter: controller.getTailLabel,
      hasHeadGetter: controller.hasHead,
      hasTailGetter: controller.hasTail,
    );
  }
}

Widget buildModuleCoverTextTag(String text) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 6.wMin),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(6.wMin),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.15),
        width: 1.wMin,
      ),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 12.wMin,
        color: AppTheme.cStaticWhite.color,
        fontWeight: FontWeight.w500,
        height: 1.0,
      ),
    ),
  );
}
