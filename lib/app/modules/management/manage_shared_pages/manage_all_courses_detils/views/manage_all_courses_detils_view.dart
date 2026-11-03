import 'dart:math' as math;

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/color_utils.dart';
import 'package:langwise/utils/style_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../official_course_details/official_course_details_level/views/widgets/cards/course_module_card_shell.dart';
import '../../../../../../common/enum/enum.dart';
import '../../../../../routes/routes.dart';
import '../../../common/commons.dart';
import '../../../utils/utils.dart';
import '../bindings/manage_all_courses_detils_binding.dart';
import '../controllers/manage_all_courses_detils_controller.dart';

class ManageAllCoursesDetilsView extends GetView<ManageAllCoursesDetilsController> {
  final String tagText;
  const ManageAllCoursesDetilsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_ALL_COURSES_DETILS}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageAllCoursesDetilsView(tagText: tag),
      binding: ManageAllCoursesDetilsBinding(tag: tag),
      routeName: Routes.MANAGE_ALL_COURSES_DETILS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(top: 20.wh),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Obx(() {
                    if (controller.levelTabList.isEmpty) return Container();
                    if (controller.isManageMode.value) {
                      return _buildManageModeBody(context);
                    }
                    return _buildBrowseModeBody(context);
                  }),
                ),
              ],
            ),
          ),
          if (!controller.isHideHeader) _buildBottomOverlayBar(context),
        ],
      ),
    );
  }

  Widget _buildBottomOverlayBar(BuildContext context) {
    return Obx(() {
      if (controller.levelTabList.isEmpty) return const SizedBox.shrink();
      final showTrailingAction = true;
      return Positioned(
        bottom: 45.wMin,
        left: 90.wMin,
        right: 90.wMin,
        child: Row(
          children: [
            // if (showTrailingAction)
            //   IgnorePointer(
            //     child: Opacity(
            //       opacity: 0,
            //       child: Row(
            //         mainAxisSize: MainAxisSize.min,
            //         children: [
            //           _buildBottomActionButtons(context, isPlaceholder: true),
            //           SizedBox(width: 16.wMin),
            //         ],
            //       ),
            //     ),
            //   ),
            Expanded(
              child: Center(
                child: _buildBottomLevelTabs(context),
              ),
            ),
            if (showTrailingAction)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 16.wMin),
                  _buildBottomActionButtons(context),
                ],
              ),
          ],
        ),
      );
    });
  }

  Widget _buildBottomLevelTabs(BuildContext context) {
    return FilterStripWidget(
      searchs: {
        'keyword': FilterSearchsData(
          controller: controller.moduleKeywordSearchController,
          title: '关键字',
          hintText: '模块ID / 书籍ID / 模块名 / 模块详情',
        ),
        'moduleId': FilterSearchsData(
          controller: controller.moduleIdSearchController,
          title: '模块ID',
          hintText: '支持逗号分隔',
          isCommaSeparated: true,
        ),
        'bookId': FilterSearchsData(
          controller: controller.bookIdSearchController,
          title: '书籍ID',
          hintText: '支持逗号分隔',
          isCommaSeparated: true,
        ),
        'moduleName': FilterSearchsData(
          controller: controller.moduleNameSearchController,
          title: '模块名',
          hintText: '模糊搜索',
        ),
        'moduleDesc': FilterSearchsData(
          controller: controller.moduleDescSearchController,
          title: '模块详情',
          hintText: '模糊搜索',
        ),
      },
      locates: List.generate(controller.levelTabList.length, (index) {
        final item = controller.levelTabList[index];
        return FilterLocateData(
          name: item.name ?? 'Level ${index + 1}',
          key: controller.getLevelTabKey(index),
          value: item.uid,
        );
      }),
      locateIndex: controller.tabCurrentIndex.value,
      locateMinWidth: 500.wMin,
      onSearch: controller.onModuleSearch,
      onLocate: (locate, index) {
        controller.scrollToLevel(index);
      },
    );
  }

  Widget _buildBottomActionButtons(BuildContext context, {bool isPlaceholder = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ManageAuthBoxWidget(
          authCodes: const [ManageAuthCode.courseEdit],
          child: _buildBottomActionButton(
            key: isPlaceholder ? null : controller.sortGlobalKey,
            title: controller.isManageMode.value ? "退出管理" : "管理课程",
            color: controller.isManageMode.value ? const Color(0xFFF59E0B) : AppTheme.cTextBrand.color,
            onTap: () {
              if (controller.isManageMode.value) {
                controller.exitManageMode(context);
                return;
              }
              controller.enterManageMode();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBrowseModeBody(BuildContext context) {
    return CustomScrollView(
      controller: controller.levelScrollController,
      slivers: [
        ...List.generate(controller.levelTabList.length, (levelIndex) {
          final LevelResponseEntity levelEntity = controller.levelTabList[levelIndex];
          final List moduleDTOList = levelEntity.moduleDTOList ?? [];
          final List<ModuleResponseEntity> modules = controller.getFilteredModules(levelEntity);
          final bool isSearching = controller.isModuleSearching;
          if (isSearching && modules.isEmpty) return const <Widget>[];

          return [
            SliverToBoxAdapter(
              child: _buildLevelHeader(context, levelIndex, levelEntity),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.ww),
                child: _buildModuleGrid(
                  context,
                  moduleDTOList,
                  modules,
                  levelEntity: levelEntity,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: 30.wh),
            ),
          ];
        }).expand((e) => e),
        SliverToBoxAdapter(
          child: SizedBox(height: 180.wMin),
        ),
      ],
    );
  }

  Widget _buildManageModeBody(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.ww),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double moduleSpacing = 18.wMin;
          final double panelSpacing = 18.wMin;
          final double itemWidth = (constraints.maxWidth - moduleSpacing - panelSpacing) / 3;
          final double levelWorkspaceWidth = (itemWidth * 2) + moduleSpacing;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: levelWorkspaceWidth,
                child: _buildManageLevelWorkspace(
                  context,
                  levelWorkspaceWidth,
                  cardWidth: itemWidth,
                ),
              ),
              SizedBox(width: panelSpacing),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 145.wMin),
                  child: _buildManageStorageWorkspace(
                    context,
                    dragCardWidth: itemWidth,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomActionButton({
    Key? key,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return TapScaleWidget(
      key: key,
      sclae: 1.05,
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: PlatformBackdropFilterWidget(
          sigmaX: 10.wMin,
          sigmaY: 10.wMin,
          child: Container(
            height: 64.wMin,
            padding: EdgeInsets.symmetric(horizontal: 18.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: color.withValues(alpha: 0.15),
              border: Border.all(
                color: color.withValues(alpha: 0.2),
                width: 1.wMin,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 24.wMin,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildManageLevelWorkspace(
    BuildContext context,
    double workspaceWidth, {
    required double cardWidth,
  }) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        controller: controller.levelScrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: EdgeInsets.only(bottom: 180.wMin),
        child: Column(
          children: List.generate(controller.levelTabList.length, (levelIndex) {
            final LevelResponseEntity levelEntity = controller.levelTabList[levelIndex];
            return Padding(
              padding: EdgeInsets.only(
                bottom: levelIndex == controller.levelTabList.length - 1 ? 0 : 30.wh,
              ),
              child: _buildManageLevelSection(
                context,
                levelIndex,
                levelEntity,
                cardWidth: cardWidth,
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildManageLevelSection(
    BuildContext context,
    int levelIndex,
    LevelResponseEntity levelEntity, {
    required double cardWidth,
  }) {
    final List<ModuleResponseEntity> allModules = controller.getLevelModules(levelEntity);
    final List<ModuleResponseEntity> modules = controller.getFilteredModules(levelEntity);
    final int totalCount = modules.length + 1;
    final int rowCount = math.max(1, (totalCount / 2).ceil());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLevelHeader(context, levelIndex, levelEntity),
        SizedBox(height: 12.wMin),
        Column(
          children: List.generate(rowCount, (rowIndex) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: rowIndex == rowCount - 1 ? 0 : 18.wMin,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(3, (slotIndex) {
                  if (slotIndex == 1) {
                    return SizedBox(width: 18.wMin);
                  }
                  final int columnIndex = slotIndex ~/ 2;
                  final int itemIndex = rowIndex * 2 + columnIndex;
                  if (itemIndex >= totalCount) {
                    return SizedBox(width: cardWidth);
                  }
                  if (itemIndex == modules.length) {
                    return SizedBox(
                      width: cardWidth,
                      child: _buildManageAddModuleCard(
                        context,
                        levelEntity,
                        insertIndex: allModules.length,
                      ),
                    );
                  }
                  final ModuleResponseEntity moduleEntity = modules[itemIndex];
                  final int actualModuleIndex = allModules.indexWhere((item) => item.uid == moduleEntity.uid);
                  if (actualModuleIndex < 0) {
                    return SizedBox(width: cardWidth);
                  }
                  return SizedBox(
                    width: cardWidth,
                    child: _buildManageModuleDragTarget(
                      context: context,
                      levelIndex: levelIndex,
                      moduleIndex: actualModuleIndex,
                      levelEntity: levelEntity,
                      dragCardWidth: cardWidth,
                      moduleEntity: moduleEntity,
                    ),
                  );
                }),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildManageModuleDragTarget({
    required BuildContext context,
    required int levelIndex,
    required int moduleIndex,
    required LevelResponseEntity levelEntity,
    required double dragCardWidth,
    required ModuleResponseEntity moduleEntity,
  }) {
    return DragTarget<ModuleResponseEntity>(
      onAcceptWithDetails: (details) {
        controller.moveManageModuleToLevel(
          item: details.data,
          targetLevelIndex: levelIndex,
          targetIndex: moduleIndex,
        );
      },
      builder: (context, candidateData, rejectedData) {
        final bool isDragging = controller.isManageDraggingItem(
          levelIndex: levelIndex,
          itemIndex: moduleIndex,
          fromTop: false,
        );
        return DottedBorder(
          color: candidateData.isNotEmpty ? const Color(0xFFF59E0B) : Colors.transparent,
          strokeWidth: candidateData.isNotEmpty ? 2.wMin : 0,
          dashPattern: const [5, 3],
          borderType: BorderType.RRect,
          radius: Radius.circular(20.wMin),
          child: Opacity(
            opacity: isDragging ? 0 : 1,
            child: LongPressDraggable<ModuleResponseEntity>(
              data: moduleEntity,
              delay: const Duration(milliseconds: 350),
              onDragStarted: () {
                controller.startManageDrag(
                  levelIndex: levelIndex,
                  itemIndex: moduleIndex,
                  fromTop: false,
                );
              },
              onDragEnd: (_) => controller.clearManageDragState(),
              onDraggableCanceled: (_, __) => controller.clearManageDragState(),
              feedback: Material(
                color: Colors.transparent,
                child: SizedBox(
                  width: dragCardWidth,
                  child: _buildManageModuleCard(
                    context,
                    moduleIndex,
                    moduleEntity,
                    levelEntity: levelEntity,
                  ),
                ),
              ),
              childWhenDragging: Opacity(
                opacity: 0,
                child: _buildManageModuleCard(
                  context,
                  moduleIndex,
                  moduleEntity,
                  levelEntity: levelEntity,
                ),
              ),
              child: _buildManageModuleCard(
                context,
                moduleIndex,
                moduleEntity,
                levelEntity: levelEntity,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildManageStorageWorkspace(
    BuildContext context, {
    required double dragCardWidth,
  }) {
    return Container(
      padding: EdgeInsets.all(20.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cEditBookGradeBackground,
        borderRadius: BorderRadius.circular(20.wMin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '模块排序暂存区',
            style: TextStyle(
              fontSize: 30.wMin,
              color: AppTheme.cTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10.wMin),
          Text(
            '拖进来暂存后，可再拖回任意 Level 的任意位置。',
            style: TextStyle(
              fontSize: 20.wMin,
              color: AppTheme.cTextSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 16.wMin),
          Row(
            children: [
              Expanded(
                child: _buildStorageActionButton(
                  title: '级别排序',
                  onTap: () {
                    controller.showSort(context);
                  },
                ),
              ),
              SizedBox(width: 12.wMin),
              Expanded(
                child: _buildStorageActionButton(
                  title: '新增级别',
                  onTap: () {
                    controller.toAddLevel(context);
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16.wMin),
          Expanded(
            child: DragTarget<ModuleResponseEntity>(
              onAcceptWithDetails: (details) {
                controller.moveManageModuleToTop(details.data, controller.manageTopModuleList.length);
              },
              builder: (context, candidateData, rejectedData) {
                return SizedBox.expand(
                  child: DottedBorder(
                    color: candidateData.isNotEmpty ? const Color(0xFFF59E0B) : Colors.transparent,
                    strokeWidth: candidateData.isNotEmpty ? 2.wMin : 0,
                    dashPattern: const [5, 3],
                    borderType: BorderType.RRect,
                    radius: Radius.circular(16.wMin),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      padding: EdgeInsets.all(16.wMin),
                      child: controller.manageTopModuleList.isEmpty
                          ? _buildManageStorageEmptyState()
                          : LayoutBuilder(
                              builder: (context, constraints) {
                                final double spacing = 16.wMin;
                                final double tileWidth = (constraints.maxWidth - spacing) / 2;
                                return ScrollConfiguration(
                                  behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                                  child: SingleChildScrollView(
                                    controller: controller.manageStorageScrollController,
                                    padding: EdgeInsets.only(bottom: 180.wMin),
                                    child: Wrap(
                                      spacing: spacing,
                                      runSpacing: spacing,
                                      children: List.generate(
                                        controller.manageTopModuleList.length,
                                        (index) => SizedBox(
                                          width: tileWidth,
                                          child: _buildManageStorageDragTarget(
                                            moduleEntity: controller.manageTopModuleList[index],
                                            moduleIndex: index,
                                            tileWidth: tileWidth,
                                            dragCardWidth: dragCardWidth,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageActionButton({
    required String title,
    required VoidCallback onTap,
  }) {
    return TapScaleWidget(
      sclae: 1.02,
      onTap: onTap,
      child: Container(
        height: 52.wMin,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceLayerBase.color,
          borderRadius: BorderRadius.circular(12.wMin),
          border: Border.all(
            color: AppTheme.cBorderSecondary.color.withValues(alpha: 0.2),
            width: 1.wMin,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 22.wMin,
            color: AppTheme.cTextPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildManageStorageDragTarget({
    required ModuleResponseEntity moduleEntity,
    required int moduleIndex,
    required double tileWidth,
    required double dragCardWidth,
  }) {
    return DragTarget<ModuleResponseEntity>(
      onAcceptWithDetails: (details) {
        controller.moveManageModuleToTop(details.data, moduleIndex);
      },
      builder: (context, candidateData, rejectedData) {
        final bool isDragging = controller.isManageDraggingItem(
          levelIndex: null,
          itemIndex: moduleIndex,
          fromTop: true,
        );
        return DottedBorder(
          color: candidateData.isNotEmpty ? const Color(0xFFF59E0B) : Colors.transparent,
          strokeWidth: candidateData.isNotEmpty ? 2.wMin : 0,
          dashPattern: const [5, 3],
          borderType: BorderType.RRect,
          radius: Radius.circular(20.wMin),
          child: Opacity(
            opacity: isDragging ? 0 : 1,
            child: LongPressDraggable<ModuleResponseEntity>(
              data: moduleEntity,
              delay: const Duration(milliseconds: 350),
              onDragStarted: () {
                controller.startManageDrag(
                  itemIndex: moduleIndex,
                  fromTop: true,
                );
              },
              onDragEnd: (_) => controller.clearManageDragState(),
              onDraggableCanceled: (_, __) => controller.clearManageDragState(),
              feedback: Material(
                color: Colors.transparent,
                child: SizedBox(
                  width: dragCardWidth,
                  child: _buildManageModuleCard(
                    context,
                    moduleIndex,
                    moduleEntity,
                    levelEntity: controller.getManageSourceLevelEntity(moduleEntity),
                  ),
                ),
              ),
              childWhenDragging: Opacity(
                opacity: 0,
                child: _buildManageStorageCard(moduleEntity, width: tileWidth),
              ),
              child: _buildManageStorageCard(moduleEntity, width: tileWidth),
            ),
          ),
        );
      },
    );
  }

  Widget _buildManageStorageEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '把左侧模块拖进来暂存',
            style: TextStyle(
              fontSize: 28.wMin,
              color: AppTheme.cTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.wMin),
          Text(
            '暂存区内的模块不会响应其它点击，只用于排序管理。',
            style: TextStyle(
              fontSize: 20.wMin,
              color: AppTheme.cTextSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManageModuleCard(
    BuildContext context,
    int index,
    ModuleResponseEntity moduleEntity, {
    required LevelResponseEntity? levelEntity,
  }) {
    return _buildModuleItem(
      context,
      index,
      moduleEntity,
      isExpanded: false,
      isLoading: false,
      levelEntity: levelEntity,
      showExpandAction: false,
      dragHandle: _buildManageDragHandleTag(),
      onCardTap: null,
    );
  }

  Widget _buildManageStorageCard(
    ModuleResponseEntity moduleEntity, {
    required double width,
  }) {
    final double tileWidth = math.min(220.wMin, width);
    final double tileHeight = tileWidth * 246 / 220;
    return Center(
      child: SizedBox(
        width: tileWidth,
        height: tileHeight,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.wMin),
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: AppTheme.cSurfaceLayerBase.color,
              borderRadius: BorderRadius.circular(20.wMin),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: (moduleEntity.coverUrl ?? '').isNotEmpty
                      ? CachedImageWidget(
                          moduleEntity.coverUrl ?? '',
                          fit: BoxFit.cover,
                          placeholder: buildLoadingWidget(),
                          errorWidget: _buildEmptyWidget(),
                        )
                      : _buildEmptyWidget(),
                ),
                Positioned(
                  left: 12.wMin,
                  top: 12.wMin,
                  child: _buildManageDragHandleTag(),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(14.wMin, 12.wMin, 14.wMin, 12.wMin),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.72),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Text(
                      moduleEntity.name ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18.wMin,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildManageDragHandleTag() {
    return Container(
      padding: EdgeInsets.all(6.wMin),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8.wMin),
        boxShadow: [
          BoxShadow(
            color: AppTheme.cBlackAlpha20,
            blurRadius: 8.wMin,
            offset: Offset(0, 4.wMin),
          ),
        ],
      ),
      child: Icon(
        Icons.drag_indicator_rounded,
        size: 16.wMin,
        color: AppTheme.cTextPrimary.color,
      ),
    );
  }

  Widget _buildManageAddModuleCard(
    BuildContext context,
    LevelResponseEntity levelEntity, {
    required int insertIndex,
  }) {
    return DragTarget<ModuleResponseEntity>(
      onAcceptWithDetails: (details) {
        controller.moveManageModuleToLevel(
          item: details.data,
          targetLevelIndex: controller.levelTabList.indexWhere((item) => item.uid == levelEntity.uid),
          targetIndex: insertIndex,
        );
      },
      builder: (context, candidateData, rejectedData) {
        return DottedBorder(
          radius: Radius.circular(20.wMin),
          borderType: BorderType.RRect,
          padding: EdgeInsets.zero,
          color: candidateData.isNotEmpty ? const Color(0xFFF59E0B) : Colors.transparent,
          dashPattern: const [6, 4],
          strokeWidth: candidateData.isNotEmpty ? 2.wMin : 0,
          child: _buildTabViewAdd(
            context,
            controller.getLevelModules(levelEntity),
            levelEntity: levelEntity,
          ),
        );
      },
    );
  }

  Widget _buildLevelHeader(BuildContext context, int levelIndex, LevelResponseEntity levelEntity) {
    return Container(
      key: levelEntity.globalKey,
      padding: EdgeInsets.only(left: 24.ww, right: 24.ww, top: 12.wh, bottom: 12.wh),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontSize: 30.wMin,
                      color: const Color(0xffEBEFF5),
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(text: levelEntity.name ?? ''),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Container(
                          margin: EdgeInsets.only(left: 12.ww),
                          padding: EdgeInsets.only(left: 12.ww, right: 12.ww, top: 4.wh, bottom: 4.wh),
                          decoration: BoxDecoration(
                            color: levelEntity.isAccess ? const Color(0xff44AF5C) : const Color(0xff465070),
                            borderRadius: BorderRadius.circular(4.wMin),
                          ),
                          child: Text(
                            levelEntity.newAccess,
                            style: TextStyle(
                              fontSize: 22.wMin,
                              color: const Color(0xffEBEFF5),
                              fontWeight: FontWeight.w400,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!controller.isManageMode.value) ...[
                SizedBox(width: 12.ww),
                ManageAuthBoxWidget(
                  authCodes: const [ManageAuthCode.courseLevelEdit],
                  child: TapScaleWidget(
                    sclae: 1.05,
                    onTap: () {
                      controller.onEditLevel(levelIndex, levelEntity);
                    },
                    child: Container(
                      width: 50.wMin,
                      height: 40.wMin,
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        "assets/svg/manage/icon_edit.svg",
                        width: 30.wMin,
                        colorFilter: const ColorFilter.mode(Color(0xff9BA5B5), BlendMode.srcIn),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          if ((levelEntity.description ?? '').isNotEmpty) ...[
            SizedBox(height: 6.wh),
            Text(
              levelEntity.description ?? '',
              style: TextStyle(
                fontSize: 22.wMin,
                color: const Color(0xff9BA5B5),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModuleGrid(
    BuildContext context,
    List moduleDTOList,
    List<ModuleResponseEntity> modules, {
    required LevelResponseEntity levelEntity,
  }) {
    const int crossAxisCount = 3;
    final int totalCount = modules.length;
    final int rowCount = (totalCount / crossAxisCount).ceil();
    final double horizontalSpacing = 18.wMin;
    final double verticalSpacing = 18.wMin;

    return Obx(() {
      final int? currentExpandedModuleId = controller.expandedModuleId.value;
      return LayoutBuilder(
        builder: (context, constraints) {
          final double cardWidth = (constraints.maxWidth - (crossAxisCount - 1) * horizontalSpacing) / crossAxisCount;
          return Column(
            children: List.generate(rowCount, (rowIndex) {
              final int start = rowIndex * crossAxisCount;
              final int end = math.min(start + crossAxisCount, totalCount);
              int expandedColumnIndex = -1;
              ModuleResponseEntity? expandedModule;

              for (int itemIndex = start; itemIndex < end; itemIndex++) {
                if (itemIndex >= modules.length) continue;
                final ModuleResponseEntity moduleEntity = modules[itemIndex];
                if (currentExpandedModuleId == moduleEntity.uid) {
                  expandedColumnIndex = itemIndex - start;
                  expandedModule = moduleEntity;
                  break;
                }
              }

              return Padding(
                padding: EdgeInsets.only(bottom: rowIndex == rowCount - 1 ? 0 : verticalSpacing),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(crossAxisCount * 2 - 1, (index) {
                        if (index.isOdd) {
                          return SizedBox(width: horizontalSpacing);
                        }
                        final int columnIndex = index ~/ 2;
                        final int itemIndex = start + columnIndex;
                        if (itemIndex >= end) {
                          return SizedBox(width: cardWidth);
                        }
                        return SizedBox(
                          width: cardWidth,
                          child: _buildModuleItem(
                            context,
                            itemIndex,
                            modules[itemIndex],
                            isExpanded: currentExpandedModuleId == modules[itemIndex].uid,
                            isLoading: controller.moduleSimpleUnitLoadingMap[modules[itemIndex].uid] == true,
                            levelEntity: levelEntity,
                            onCardTap: () {
                              controller.onExpandUnit(modules[itemIndex]);
                            },
                          ),
                        );
                      }),
                    ),
                    if (expandedModule != null) ...[
                      SizedBox(height: 14.wMin),
                      _buildExpandedUnitPanel(
                        context,
                        expandedModule,
                        levelEntity,
                        expandedColumnIndex: expandedColumnIndex,
                        cardWidth: cardWidth,
                        horizontalSpacing: horizontalSpacing,
                      ),
                    ],
                  ],
                ),
              );
            }),
          );
        },
      );
    });
  }

  Widget _buildModuleItem(
    BuildContext context,
    int index,
    ModuleResponseEntity moduleEntity, {
    required bool isExpanded,
    required bool isLoading,
    required LevelResponseEntity? levelEntity,
    bool showExpandAction = true,
    Widget? dragHandle,
    VoidCallback? onCardTap,
  }) {
    return TapScaleWidget(
      onTap: onCardTap,
      sclae: 1.0,
      child: CourseModuleCardShell(
        height: 408.wMin,
        mainContentHeight: 246.wMin,
        borderSide: BorderSide(
          color: isExpanded ? const Color(0xff44AF5C) : AppTheme.cBorderSecondary,
          width: 1.wMin,
        ),
        dividerColor: AppTheme.cBorderSecondary.color.withValues(alpha: 0.7),
        mainContent: _buildModuleMainContent(
          moduleEntity,
          dragHandle: dragHandle,
        ),
        footer: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ..._buildModuleMetricWidgets(moduleEntity),
                Spacer(),
                Opacity(
                  opacity: showExpandAction ? 1 : 0,
                  child: IgnorePointer(
                    child: ManageAuthBoxWidget(
                      authCodes: const [ManageAuthCode.courseModuleUnitSimpleList],
                      child: _buildExpandUnitButton(
                        isExpanded: isExpanded,
                        isLoading: isLoading,
                        onTap: () {
                          if (isLoading) return;
                          // controller.onExpandUnit(moduleEntity);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.wMin),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ManageAuthBoxWidget(
                  authCodes: const [ManageAuthCode.courseModuleEdit],
                  child: _buildActionButton(
                    title: "编辑",
                    textColor: AppTheme.cTextPrimary,
                    backgroundColor: AppTheme.cSurfaceLayerBase2.color,
                    borderColor: AppTheme.cBorderTranslucentSubtle.color,
                    onTap: () {
                      if (levelEntity == null) return;
                      final int moduleIndex = (levelEntity.moduleDTOList ?? const []).indexWhere((e) {
                        if (e is ModuleResponseEntity) return e.uid == moduleEntity.uid;
                        return false;
                      });
                      if (moduleIndex < 0) return;
                      controller.onEditModule(context, moduleIndex, moduleEntity, levelEntity: levelEntity);
                    },
                  ),
                ),
                SizedBox(width: 6.wMin),
                ManageAuthBoxWidget(
                  authCodes: const [ManageAuthCode.courseModuleEdit],
                  child: _buildActionButton(
                    title: moduleEntity.isAccess ? "下架" : "上架",
                    textColor: moduleEntity.isAccess ? AppTheme.cFeedbackWarningText : AppTheme.cFeedbackSuccessText,
                    backgroundColor: moduleEntity.isAccess ? AppTheme.cFeedbackWarningBackground : AppTheme.cFeedbackSuccessBackground.color,
                    onTap: () {
                      if (levelEntity == null) return;
                      final int moduleIndex = (levelEntity.moduleDTOList ?? const []).indexWhere((e) {
                        if (e is ModuleResponseEntity) return e.uid == moduleEntity.uid;
                        return false;
                      });
                      if (moduleIndex < 0) return;
                      controller.onToggleModuleAccess(context, moduleIndex, moduleEntity, levelEntity: levelEntity);
                    },
                  ),
                ),
                SizedBox(width: 6.wMin),
                ManageAuthBoxWidget(
                  authCodes: const [ManageAuthCode.courseLevelEdit],
                  child: _buildActionButton(
                    title: "删除",
                    textColor: AppTheme.cFeedbackErrorText,
                    backgroundColor: AppTheme.cFeedbackErrorBackground,
                    onTap: () {
                      if (levelEntity == null) return;
                      final int moduleIndex = (levelEntity.moduleDTOList ?? const []).indexWhere((e) {
                        if (e is ModuleResponseEntity) return e.uid == moduleEntity.uid;
                        return false;
                      });
                      if (moduleIndex < 0) return;
                      controller.onDeleteModule(context, moduleIndex, moduleEntity, levelEntity: levelEntity);
                    },
                  ),
                ),
                Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildModuleBookInfoText("出版社", moduleEntity.publisher ?? ""),
                   
                    _buildModuleBookInfoText("ISBN", moduleEntity.isbn ?? ""),
                  ],
                ),
              ],
            ),
         
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedUnitPanel(
    BuildContext context,
    ModuleResponseEntity moduleEntity,
    LevelResponseEntity levelEntity, {
    required int expandedColumnIndex,
    required double cardWidth,
    required double horizontalSpacing,
  }) {
    final double pointerCenterX = (expandedColumnIndex * (cardWidth + horizontalSpacing)) + (cardWidth / 2);
    final double notchWidth = 72.wMin;
    final double notchHeight = 18.wMin;
    final double panelRadius = 20.wMin;
    final double innerPadding = 14.wMin;
    return CustomPaint(
      painter: _TopNotchedPanelPainter(
        color: AppTheme.cSurfaceLayerElevated,
        borderColor: const Color(0xff44AF5C),
        radius: panelRadius,
        notchCenterX: pointerCenterX,
        notchWidth: notchWidth,
        notchHeight: notchHeight,
        borderWidth: 1.5.wMin,
        shadowColor: Colors.black.withValues(alpha: 0.08),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(innerPadding, innerPadding + notchHeight, innerPadding, innerPadding),
        child: _buildExpandedUnitContent(context, moduleEntity, levelEntity),
      ),
    );
  }

  Widget _buildExpandedUnitContent(
    BuildContext context,
    ModuleResponseEntity moduleEntity,
    LevelResponseEntity levelEntity,
  ) {
    return Obx(() {
      final bool isLoading = controller.moduleSimpleUnitLoadingMap[moduleEntity.uid] == true;
      final List<ManageCourseSimpleUnitInfo> units =
          controller.moduleSimpleUnitMap[moduleEntity.uid] ?? const <ManageCourseSimpleUnitInfo>[];
      if (isLoading) {
        return SizedBox(
          height: 380.wMin,
          child: Center(child: buildLoadingWidget()),
        );
      }
      if (units.isEmpty) {
        return SizedBox(
          height: 180.wMin,
          child: Center(
            child: Text(
              '暂无 Unit',
              style: TextStyle(
                fontSize: 22.wMin,
                color: AppTheme.cTextSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        );
      }
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 18.wMin,
          mainAxisSpacing: 18.wMin,
          childAspectRatio: 0.78,
        ),
        itemCount: units.length,
        itemBuilder: (context, index) {
          final ManageCourseSimpleUnitInfo unit = units[index];
          final String unitTitle = _normalizeUnitText(unit.name);
          return _buildExpandedUnitCard(
            context,
            moduleEntity,
            levelEntity,
            unit,
            unitTitle: unitTitle,
          );
        },
      );
    });
  }

  Widget _buildExpandedUnitCard(
    BuildContext context,
    ModuleResponseEntity moduleEntity,
    LevelResponseEntity levelEntity,
    ManageCourseSimpleUnitInfo unit, {
    required String unitTitle,
  }) {
    final imageInfo = unit.image;
    final List<int>? imageTaskIds = unit.imageTaskIds;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: TapScaleWidget(
            onTap: () {
              controller.onUnitTap(moduleEntity, levelEntity, unit);
            },
            sclae: 1.01,
            child: Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.wMin),
              ),
              foregroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.wMin),
                border: Border.all(
                  color: AppTheme.cBorderSecondary,
                  width: 1.2.wMin,
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if ((imageInfo?.imageUrl ?? '').isNotEmpty)
                    _LazyVisibilityImage(
                      visibilityKey: 'manage_unit_${unit.uid}_${imageInfo?.imageUrl ?? ''}',
                      imageBuilder: () => CachedImageWidget(
                        imageInfo?.imageUrl ?? '',
                        fadeInDuration: Duration.zero,
                        placeholder: buildLoadingWidget(),
                        errorWidget: _buildEmptyWidget(),
                      ),
                      placeholder: buildLoadingWidget(),
                    )
                  else
                    _buildEmptyWidget(),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.center,
                        colors: [
                          Colors.black.withValues(alpha: 0.55),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8.wMin,
                    top: 8.wMin,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (imageInfo?.imageId != null) _buildModuleCoverTextTag("uid:${imageInfo!.imageId}"),
                        if ((imageInfo?.styleTitle ?? '').isNotEmpty) ...[
                          SizedBox(height: 4.wMin),
                          _buildModuleCoverTextTag(imageInfo!.styleTitle!),
                        ],
                        if ((imageInfo?.localeTitle ?? '').isNotEmpty) ...[
                          SizedBox(height: 4.wMin),
                          _buildModuleCoverTextTag(imageInfo!.localeTitle!),
                        ],
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8.wMin,
                    right: 8.wMin,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (imageInfo?.imageId != null)
                              ManageAuthBoxWidget(
                                authCodes: const [ManageAuthCode.adminContentReviewImageCrop],
                                child: _buildModuleCoverIconTag(
                                  icon: Icons.crop,
                                  onTap: () {
                                    _onTapUnitImageCrop(moduleEntity, unit);
                                  },
                                ),
                              ),
                            if (imageInfo?.imageId != null) SizedBox(width: 4.wMin),
                            ManageAuthBoxWidget(
                              authCodes: const [ManageAuthCode.contentReviewImageCreateInfo],
                              child: _buildModuleCoverIconTag(
                                icon: Icons.edit_outlined,
                                onTap: () {
                                  _onTapUnitImageEdit(moduleEntity, unit);
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.wMin),
                        _buildModuleCoverTextTag(
                          (imageTaskIds == null || imageTaskIds.isEmpty) ? "无待审核" : "待审核",
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 10.wMin,
                    right: 10.wMin,
                    bottom: 10.wMin,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          unitTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 23.wMin,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          height: 32.wMin,
                          child: Text(
                            unit.description ?? "",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              height: 1.2,
                              fontSize: 14.wMin,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 6.wMin),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ManageAuthBoxWidget(
              authCodes: const [ManageAuthCode.courseUnitEdit],
              child: _buildActionButton(
                title: "编辑",
                textColor: AppTheme.cTextPrimary,
                backgroundColor: AppTheme.cSurfaceLayerBase2.color,
                borderColor: AppTheme.cBorderTranslucentSubtle.color,
                onTap: () {
                  controller.onEditSimpleUnit(context, moduleEntity, unit);
                },
              ),
            ),
            SizedBox(width: 6.wMin),
            ManageAuthBoxWidget(
              authCodes: const [ManageAuthCode.courseUnitEdit],
              child: _buildActionButton(
                title: unit.isAccess ? "下架" : "上架",
                textColor: unit.isAccess ? AppTheme.cFeedbackWarningText : AppTheme.cFeedbackSuccessText,
                backgroundColor: unit.isAccess ? AppTheme.cFeedbackWarningBackground.color : AppTheme.cFeedbackSuccessBackground.color,
                onTap: () {
                  controller.onToggleSimpleUnitAccess(moduleEntity, unit);
                },
              ),
            ),
            SizedBox(width: 6.wMin),
            ManageAuthBoxWidget(
              authCodes: const [ManageAuthCode.courseModuleEdit],
              child: _buildActionButton(
                title: "删除",
                textColor: AppTheme.cFeedbackErrorText,
                backgroundColor: AppTheme.cFeedbackErrorBackground.color,
                onTap: () {
                  controller.onRemoveSimpleUnitFromModule(context, moduleEntity, levelEntity, unit);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _onTapUnitImageCrop(
    ModuleResponseEntity moduleEntity,
    ManageCourseSimpleUnitInfo unitEntity,
  ) async {
    final imageInfo = unitEntity.image;
    if (unitEntity.uid == null || imageInfo?.imageId == null) return;
    final dynamic res = await ManagePageRegistry.jumpTo(
      Routes.MANAGE_UNIFIED_IMAGE_CROP,
      arguments: {
        "uid": unitEntity.uid,
        "type": imageInfo?.type ?? "COURSE_UNIT",
        "semanticId": imageInfo?.semanticId,
        "imageIds": [imageInfo!.imageId!],
        "styleId": imageInfo.styleId,
      },
    );
    if (res != true) return;
    controller.refreshModuleSimpleUnits(moduleEntity);
  }

  Future<void> _onTapUnitImageEdit(
    ModuleResponseEntity moduleEntity,
    ManageCourseSimpleUnitInfo unitEntity,
  ) async {
    final imageInfo = unitEntity.image;
    if (unitEntity.uid == null) return;
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_UNIFIED_IMAGE_CREATE,
      arguments: {
        "jumpCode": AppManageRoutesCode.moduleDetails,
        "params": {
          "moduleId": moduleEntity.uid,
          "moduleName": moduleEntity.name,
          "language": controller.language,
          "unitUid": unitEntity.uid,
          "unitId": unitEntity.uid?.toString(),
          "unitName": unitEntity.name,
        },
        "uid": unitEntity.uid,
        "type": imageInfo?.type ?? "COURSE_UNIT",
        "semanticId": imageInfo?.semanticId,
        "imageIds": imageInfo?.imageId == null ? null : [imageInfo!.imageId!],
        "styleId": imageInfo?.styleId,
      },
    );
    controller.refreshModuleSimpleUnits(moduleEntity);
  }

  Widget _buildModuleCover(
    ModuleResponseEntity moduleEntity, {
    bool enableImageActions = true,
    Widget? dragHandle,
  }) {
    const double coverHeight = 246;
    final double coverWidth = coverHeight.wMin * 3 / 4;
    final ModuleImageInfoEntity? imageInfo = moduleEntity.image;
    final List<int>? imageTaskIds = moduleEntity.imageTaskIds;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.wMin),
      child: Container(
        clipBehavior: Clip.hardEdge,
        width: coverWidth,
        height: coverHeight.wMin,
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceLayerBase,
          border: Border.all(color: AppTheme.cBorderSecondary.color),
          borderRadius: BorderRadius.circular(20.wMin),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: _LazyVisibilityImage(
                visibilityKey: 'manage_module_${moduleEntity.uid}_${moduleEntity.coverUrl ?? ''}',
                imageBuilder: () => CachedImageWidget(
                  moduleEntity.coverUrl ?? '',
                  placeholder: buildLoadingWidget(),
                  errorWidget: _buildEmptyWidget(),
                ),
                placeholder: buildEmptyWidget(),
              ),
            ),
            Positioned(
              left: 8.wMin,
              top: 8.wMin,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (dragHandle != null) ...[
                    dragHandle,
                    SizedBox(height: 4.wMin),
                  ],
                  if (imageInfo?.imageId != null) _buildModuleCoverTextTag("uid:${imageInfo!.imageId}"),
                  if ((imageInfo?.styleTitle ?? '').isNotEmpty) ...[
                    SizedBox(height: 4.wMin),
                    _buildModuleCoverTextTag(imageInfo!.styleTitle!),
                  ],
                  if ((imageInfo?.localeTitle ?? '').isNotEmpty) ...[
                    SizedBox(height: 4.wMin),
                    _buildModuleCoverTextTag(imageInfo!.localeTitle!),
                  ],
                ],
              ),
            ),
            Positioned(
              top: 8.wMin,
              right: 8.wMin,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (enableImageActions && imageInfo?.imageId != null)
                        ManageAuthBoxWidget(
                          authCodes: const [ManageAuthCode.adminContentReviewImageCrop],
                          child: _buildModuleCoverIconTag(
                            icon: Icons.crop,
                            onTap: () {
                              _onTapModuleImageCrop(moduleEntity, imageInfo);
                            },
                          ),
                        ),
                      if (enableImageActions && imageInfo?.imageId != null) SizedBox(width: 4.wMin),
                      if (enableImageActions)
                        ManageAuthBoxWidget(
                          authCodes: const [ManageAuthCode.contentReviewImageCreateInfo],
                          child: _buildModuleCoverIconTag(
                            icon: Icons.edit_outlined,
                            onTap: () {
                              _onTapModuleImageEdit(moduleEntity, imageInfo);
                            },
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4.wMin),
                  _buildModuleCoverTextTag(
                    (imageTaskIds == null || imageTaskIds.isEmpty) ? "无待审核" : "待审核",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onTapModuleImageCrop(
    ModuleResponseEntity moduleEntity,
    ModuleImageInfoEntity? imageInfo,
  ) async {
    if (imageInfo?.imageId == null) return;
    final dynamic res = await ManagePageRegistry.jumpTo(
      Routes.MANAGE_UNIFIED_IMAGE_CROP,
      arguments: {
        "uid": moduleEntity.uid,
        "type": imageInfo?.type ?? "COURSE_MODULE",
        "semanticId": imageInfo?.semanticId,
        "imageIds": [imageInfo!.imageId!],
        "styleId": imageInfo.styleId,
      },
    );
    if (res != true) return;
    controller.onRefreshModuleImages();
  }

  Future<void> _onTapModuleImageEdit(
    ModuleResponseEntity moduleEntity,
    ModuleImageInfoEntity? imageInfo,
  ) async {
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_UNIFIED_IMAGE_CREATE,
      arguments: {
        "jumpCode": AppManageRoutesCode.moduleDetails,
        "params": {
          "moduleId": moduleEntity.uid,
          "moduleName": moduleEntity.name,
          "language": controller.language,
        },
        "uid": moduleEntity.uid,
        "type": imageInfo?.type ?? "COURSE_MODULE",
        "semanticId": imageInfo?.semanticId,
        "imageIds": imageInfo?.imageId == null ? null : [imageInfo!.imageId!],
        "styleId": imageInfo?.styleId,
      },
    );
    controller.onRefreshModuleImages();
  }

  Widget _buildModuleCoverIconTag({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.0,
      child: Container(
        padding: EdgeInsets.all(6.wMin),
        decoration: _buildModuleCoverTagDecoration(),
        child: Icon(
          icon,
          size: 12.wMin,
          color: AppTheme.cStaticWhite,
        ),
      ),
    );
  }

  Widget _buildModuleCoverTextTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 6.wMin),
      decoration: _buildModuleCoverTagDecoration(),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.wMin,
          color: AppTheme.cStaticWhite,
          fontWeight: FontWeight.w500,
          height: 1.0,
        ),
      ),
    );
  }

  BoxDecoration _buildModuleCoverTagDecoration() {
    return BoxDecoration(
      color: Colors.black.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(6.wMin),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.15),
        width: 1.wMin,
      ),
    );
  }

  String _formatLearnerCount(int? count) {
    final int value = count ?? 0;
    if (value >= 10000) {
      final String formatted = (value / 10000).toStringAsFixed(1).replaceFirst(RegExp(r'\.0$'), '');
      return '$formatted 万';
    }
    if (value >= 1000) {
      final String formatted = (value / 1000).toStringAsFixed(1).replaceFirst(RegExp(r'\.0$'), '');
      return '${formatted}k';
    }
    return value.toString();
  }

  Widget _buildModuleMainContent(
    ModuleResponseEntity moduleEntity, {
    bool enableImageActions = true,
    Widget? dragHandle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildModuleCover(
          moduleEntity,
          enableImageActions: enableImageActions,
          dragHandle: dragHandle,
        ),
        SizedBox(width: 16.wMin),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                moduleEntity.name ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 32.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  CopyTagWidget(
                    name: '模块',
                    value: "${moduleEntity.uid}",
                    isDisabled: true,
                  ),
                  SizedBox(width: 8.wMin),
                  WordInflectionInfoTagWidget(
                    "学习人数${_formatLearnerCount(moduleEntity.useCount)}",
                  ),
                ],
              ),
              SizedBox(height: 12.wMin),
              _buildModuleInfoTags(moduleEntity),
              SizedBox(height: 10.wMin),
              Expanded(
                child: Text(
                  moduleEntity.description ?? '',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18.wMin,
                    color: AppTheme.cTextSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModuleInfoTags(ModuleResponseEntity moduleEntity) {
    final List<Widget> tags = (moduleEntity.tierMappings ?? const <ThemeTextEntity?>[])
        .whereType<ThemeTextEntity>()
        .map(_buildModuleTierTag)
        .toList();
    if (tags.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 6.wMin,
      runSpacing: 6.wMin,
      children: tags,
    );
  }

  Widget _buildModuleAccessTag(ModuleResponseEntity moduleEntity) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.wMin),
      decoration: BoxDecoration(
        color: moduleEntity.isAccess ? const Color(0xff44AF5C) : const Color(0xff465070),
        borderRadius: BorderRadius.circular(4.wMin),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 1),
            blurRadius: 2,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SizedBox(
        height: 26.wMin,
        child: Align(
          alignment: Alignment.center,
          widthFactor: 1.0,
          child: Text(
            moduleEntity.newAccess,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xffEBEFF5),
              fontSize: 14.wMin,
              fontWeight: FontWeight.w400,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterText(String title, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "$title ",
          style: TextStyle(
            fontSize: 18.wMin,
            color: AppTheme.cTextSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18.wMin,
            color: AppTheme.cTextPrimary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildModuleMetricWidgets(ModuleResponseEntity moduleEntity) {
    final List<Widget> children = <Widget>[];
    final List<CourseLevelEntityLevelListModuleListKnowledgeCounts> knowledgeCounts =
        (moduleEntity.knowledgeCounts ?? const <CourseLevelEntityLevelListModuleListKnowledgeCounts?>[])
            .whereType<CourseLevelEntityLevelListModuleListKnowledgeCounts>()
            .toList();
    for (int i = 0; i < knowledgeCounts.length; i++) {
      final CourseLevelEntityLevelListModuleListKnowledgeCounts item = knowledgeCounts[i];
      final String title = _getZhLanguageText(item.name);
      if (title.isEmpty) continue;
      if (children.isNotEmpty) {
        children.add(_buildFooterDivider());
      }
      children.add(_buildFooterText(title, "${item.count ?? 0}"));
    }
    if (children.isNotEmpty) {
      children.add(_buildFooterDivider());
    }
    children.add(_buildFooterText("", "${moduleEntity.unitTotal ?? 0}个单元"));
    return children;
  }

  Widget _buildModuleTierTag(ThemeTextEntity tag) {
    final ThemeTextStyleEntity? themeText = StyleUtils.getCurrentThemeText(tag.style);
    final TextStyle textStyle = StyleUtils.getTextStyle(
          tag.style,
          defaultColor: AppTheme.cTextPrimary.color,
          defaultSize: 16,
        ) ??
        TextStyle(
          fontSize: 16.wMin,
          color: AppTheme.cTextPrimary.color,
          fontWeight: FontWeight.w400,
        );
    final Color backgroundColor = ColorUtils.parseColor(themeText?.backgroundColor) ?? Colors.transparent;
    final Color borderColor = ColorUtils.parseColor(themeText?.borderColor) ?? Colors.transparent;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 2.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.wMin),
        color: backgroundColor,
        border: Border.all(
          color: borderColor,
          width: 1.wMin,
        ),
      ),
      child: Text(
        tag.text ?? "",
        style: textStyle,
      ),
    );
  }

  String _getZhLanguageText(List<LanguageText?>? items) {
    if (items == null) return "";
    for (int i = 0; i < items.length; i++) {
      final LanguageText? item = items[i];
      if (item?.lang == "zh") {
        return item?.text ?? "";
      }
    }
    return "";
  }

  Widget _buildModuleBookInfoText(String title, String value) {
    return Visibility(
      visible: value.isNotEmpty,
      maintainState: true,
      maintainAnimation: true,
      maintainSize: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.wMin,
              color: AppTheme.cTextSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(width: 8.wMin),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.wMin,
              color: AppTheme.cTextPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterDivider() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.wMin),
      width: 1,
      height: 28.wMin,
      color: AppTheme.cTextPrimary.withValues(alpha: 0.1),
    );
  }

  Widget _buildActionButton({
    required String title,
    required Color textColor,
    Color? backgroundColor,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    return TapScaleWidget(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.wMin),
        height: 40.wMin,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppTheme.cSurfaceLayerBase.color,
          borderRadius: BorderRadius.circular(8.wMin),
          border: borderColor == null ? null : Border.all(color: borderColor, width: 1.wMin),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18.wMin,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandUnitButton({
    required bool isExpanded,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return TapScaleWidget(
      sclae: 1.0,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.wMin),
        height: 40.wMin,
        decoration: BoxDecoration(
          color: AppTheme.cFeedbackInfoText.color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8.wMin),
          border: Border.all(
            color: AppTheme.cFeedbackDefaultBackground,
            width: 1.wMin,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isExpanded ? "收起Unit" : "展开Unit",
              style: TextStyle(
                fontSize: 18.wMin,
                color: AppTheme.cFeedbackInfoText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _normalizeUnitText(String? value) {
    final String text = value ?? '';
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  Widget _buildTabViewAdd(BuildContext context, List moduleDTOList, {required LevelResponseEntity levelEntity}) {
    return ManageAuthBoxWidget(
      authCodes: controller.courseInfo?.specialty == SpecialtyEnum.EN_PHONICS
          ? [
              ManageAuthCode.courseModuleCreate,
            ]
          : const [
              ManageAuthCode.courseModuleCreate,
              ManageAuthCode.courseModuleCopy,
              ManageAuthCode.courseLevelRelationModule,
            ],
      isAny: true,
      child: TapScaleWidget(
        onTap: () {
          controller.toAddModule(context, moduleDTOList, levelEntity: levelEntity);
        },
        sclae: 1.03,
        child: DottedBorder(
          radius: Radius.circular(20.wMin),
          borderType: BorderType.RRect,
          padding: EdgeInsets.zero,
          color: Colors.transparent,
          dashPattern: const [6, 4],
          strokeWidth: 0,
          child: Container(
            height: 406.wMin,
            padding: EdgeInsets.all(16.wMin),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.cSurfaceLayerBase2,
              border: Border.all(
                color: AppTheme.cBorderSecondary.color,
                width: 1.wMin,
              ),
              borderRadius: BorderRadius.circular(20.wMin),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 92.wMin,
                  height: 92.wMin,
                  decoration: BoxDecoration(
                    color: AppTheme.cTextBrand.color.withValues(alpha: 0.12),
                    border: Border.all(
                      color: AppTheme.cTextBrand.color.withValues(alpha: 0.20),
                    ),
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(22.wMin),
                  child: SvgPicture.asset(
                    "assets/svg/manage/icon_add.svg",
                    colorFilter: ColorFilter.mode(
                      AppTheme.cTextBrand,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                SizedBox(height: 12.wMin),
                Text(
                  "添加模块",
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cTextBrand,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyWidget({double? width, double? height}) {
    return Container(
      width: width,
      height: height,
      color: const Color(0xff19213D),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: const Color(0xff444B5F),
          size: 40.wMin,
        ),
      ),
    );
  }
}

class _TopNotchedPanelPainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  final double radius;
  final double notchCenterX;
  final double notchWidth;
  final double notchHeight;
  final double borderWidth;
  final Color shadowColor;

  const _TopNotchedPanelPainter({
    required this.color,
    required this.borderColor,
    required this.radius,
    required this.notchCenterX,
    required this.notchWidth,
    required this.notchHeight,
    required this.borderWidth,
    required this.shadowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildPath(size);
    canvas.drawShadow(path, shadowColor, 12, false);

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawPath(path, borderPaint);
  }

  Path _buildPath(Size size) {
    final left = borderWidth / 2;
    final top = notchHeight + (borderWidth / 2);
    final right = size.width - (borderWidth / 2);
    final bottom = size.height - (borderWidth / 2);
    final safeRadius = math.min(radius, math.min((right - left) / 2, (bottom - top) / 2));
    final notchHalf = notchWidth / 2;
    final minNotchLeft = left + safeRadius + 12.wMin;
    final maxNotchLeft = right - safeRadius - notchWidth - 12.wMin;
    final notchLeft = (notchCenterX - notchHalf).clamp(minNotchLeft, maxNotchLeft);
    final notchRight = notchLeft + notchWidth;
    final notchShoulder = notchWidth * 0.22;
    final apexX = (notchLeft + notchRight) / 2;
    final apexY = borderWidth / 2;

    return Path()
      ..moveTo(left + safeRadius, top)
      ..lineTo(notchLeft, top)
      ..lineTo(notchLeft + notchShoulder, top)
      ..quadraticBezierTo(apexX - notchShoulder, top, apexX, apexY)
      ..quadraticBezierTo(apexX + notchShoulder, top, notchRight - notchShoulder, top)
      ..lineTo(notchRight, top)
      ..lineTo(right - safeRadius, top)
      ..arcToPoint(
        Offset(right, top + safeRadius),
        radius: Radius.circular(safeRadius),
      )
      ..lineTo(right, bottom - safeRadius)
      ..arcToPoint(
        Offset(right - safeRadius, bottom),
        radius: Radius.circular(safeRadius),
      )
      ..lineTo(left + safeRadius, bottom)
      ..arcToPoint(
        Offset(left, bottom - safeRadius),
        radius: Radius.circular(safeRadius),
      )
      ..lineTo(left, top + safeRadius)
      ..arcToPoint(
        Offset(left + safeRadius, top),
        radius: Radius.circular(safeRadius),
      )
      ..close();
  }

  @override
  bool shouldRepaint(covariant _TopNotchedPanelPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.radius != radius ||
        oldDelegate.notchCenterX != notchCenterX ||
        oldDelegate.notchWidth != notchWidth ||
        oldDelegate.notchHeight != notchHeight ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.shadowColor != shadowColor;
  }
}

class _LazyVisibilityImage extends StatefulWidget {
  final String visibilityKey;
  final Widget Function() imageBuilder;
  final Widget placeholder;

  const _LazyVisibilityImage({
    required this.visibilityKey,
    required this.imageBuilder,
    required this.placeholder,
  });

  @override
  State<_LazyVisibilityImage> createState() => _LazyVisibilityImageState();
}

class _LazyVisibilityImageState extends State<_LazyVisibilityImage> {
  bool _shouldLoad = false;
  late final String _instanceVisibilityKey;

  @override
  void initState() {
    super.initState();
    _instanceVisibilityKey = '${widget.visibilityKey}_${identityHashCode(this)}';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _shouldLoad) return;
      _tryLoadIfInViewport();
    });
  }

  void _tryLoadIfInViewport() {
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.attached || !renderObject.hasSize) {
      return;
    }
    final Offset topLeft = renderObject.localToGlobal(Offset.zero);
    final Rect widgetRect = topLeft & renderObject.size;
    final Rect viewportRect = Offset.zero & MediaQuery.sizeOf(context);
    if (!widgetRect.overlaps(viewportRect)) return;
    setState(() {
      _shouldLoad = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ValueKey(_instanceVisibilityKey),
      onVisibilityChanged: (info) {
        if (_shouldLoad || info.visibleFraction <= 0) return;
        if (!mounted) return;
        setState(() {
          _shouldLoad = true;
        });
      },
      child: _shouldLoad ? widget.imageBuilder() : widget.placeholder,
    );
  }
}
