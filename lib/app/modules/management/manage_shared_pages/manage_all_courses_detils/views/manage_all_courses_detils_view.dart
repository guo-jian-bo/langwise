import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../official_course_details/official_course_details_level/views/widgets/cards/course_module_card_main_content.dart';
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
                            SliverPadding(
                              padding: EdgeInsets.symmetric(horizontal: 24.ww),
                              sliver: SliverGrid(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 18.wMin,
                                  mainAxisSpacing: 18.wMin,
                                  mainAxisExtent: 354.wMin,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    if (index == modules.length) {
                                      return _buildTabViewAdd(context, moduleDTOList, levelEntity: levelEntity);
                                    }
                                    return _buildModuleItem(
                                      context,
                                      index,
                                      modules[index],
                                      levelEntity: levelEntity,
                                    );
                                  },
                                  childCount: modules.length + 1,
                                  addAutomaticKeepAlives: false,
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
          authCodes: const [
            ManageAuthCode.courseRelationLevel,
            ManageAuthCode.courseLevelCopy,
            ManageAuthCode.courseLevelCreate,
          ],
          isAny: true,
          child: _buildBottomActionButton(
            title: "新增级别",
            color: AppTheme.cTextBrand.color,
            onTap: () {
              controller.toAddLevel(context);
            },
          ),
        ),
        SizedBox(width: 16.wMin),
        ManageAuthBoxWidget(
          authCodes: const [ManageAuthCode.courseEdit],
          child: _buildBottomActionButton(
            key: isPlaceholder ? null : controller.sortGlobalKey,
            title: "排序",
            color: AppTheme.cTextPrimary.color,
            onTap: () {
              controller.showSort(context);
            },
          ),
        ),
      ],
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

  Widget _buildModuleItem(BuildContext context, int index, ModuleResponseEntity moduleEntity, {required LevelResponseEntity levelEntity}) {
    return TapScaleWidget(
      onTap: () {
        controller.toModuleDetils(moduleEntity.uid, moduleEntity.name, levelEntity: levelEntity);
      },
      sclae: 1.0,
      child: CourseModuleCardShell(
        height: 354.wMin,
        mainContentHeight: 246.wMin,
        dividerColor: AppTheme.cBorderSecondary.color.withValues(alpha: 0.7),
        mainContent: CourseModuleCardMainContent(
          cover: _buildModuleCover(moduleEntity),
          title: moduleEntity.name ?? '',
          description: moduleEntity.description ?? '',
          tierMappings: null,
        ),
        footer: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFooterText("模块ID", "${moduleEntity.uid}"),
                    _buildFooterDivider(),
                    _buildFooterText("书籍ID", "${moduleEntity.bookId ?? '-'}"),
                    _buildFooterDivider(),
                    _buildFooterText("扫描次数", "${moduleEntity.useCount ?? 0}"),
                  ],
                ),
              ),
            ),
            SizedBox(width: 16.wMin),
            ManageAuthBoxWidget(
              authCodes: const [ManageAuthCode.courseModuleEdit],
              child: _buildActionButton(
                title: "编辑",
                textColor: const Color(0xff2388FF),
                onTap: () {
                  final int moduleIndex = (levelEntity.moduleDTOList ?? const []).indexWhere((e) {
                    if (e is ModuleResponseEntity) return e.uid == moduleEntity.uid;
                    return false;
                  });
                  if (moduleIndex < 0) return;
                  controller.onEditModule(context, moduleIndex, moduleEntity, levelEntity: levelEntity);
                },
              ),
            ),
            SizedBox(width: 12.wMin),
            ManageAuthBoxWidget(
              authCodes: const [ManageAuthCode.courseLevelEdit],
              child: _buildActionButton(
                title: "删除",
                textColor: const Color(0xffEC4899),
                onTap: () {
                  final int moduleIndex = (levelEntity.moduleDTOList ?? const []).indexWhere((e) {
                    if (e is ModuleResponseEntity) return e.uid == moduleEntity.uid;
                    return false;
                  });
                  if (moduleIndex < 0) return;
                  controller.onDeleteModule(context, moduleIndex, moduleEntity, levelEntity: levelEntity);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCover(ModuleResponseEntity moduleEntity) {
    const double coverHeight = 246;
    final double coverWidth = coverHeight.wMin * 3 / 4;
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
              child: (moduleEntity.coverUrl ?? '').isNotEmpty
                  ? _LazyVisibilityImage(
                      visibilityKey: 'manage_module_${moduleEntity.uid}_${moduleEntity.coverUrl ?? ''}',
                      imageBuilder: () => CachedImageWidget(
                        moduleEntity.coverUrl ?? '',
                        fit: BoxFit.cover,
                        placeholder: buildLoadingWidget(),
                        errorWidget: _buildEmptyWidget(),
                      ),
                      placeholder: buildLoadingWidget(),
                    )
                  : _buildEmptyWidget(),
            ),
            Positioned(
              left: 12.wMin,
              top: 12.wMin,
              child: Container(
                alignment: Alignment.center,
                height: 24.wMin,
                padding: EdgeInsets.only(left: 12.wMin, right: 12.wMin),
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
                child: Text(
                  moduleEntity.newAccess,
                  style: TextStyle(
                    fontSize: 14.wMin,
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

  Widget _buildFooterDivider() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.wMin),
      width: 1,
      height: 28.wMin,
      color: AppTheme.cTextPrimary.withValues(alpha: 0.1),
    );
  }

  Widget _buildActionButton({
    required String title,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return TapScaleWidget(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.wMin),
        height: 40.wMin,
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceLayerBase.color,
          borderRadius: BorderRadius.circular(8.wMin),
          border: Border.all(
            color: AppTheme.cSurfaceLayerElevated.color,
            width: 1.wMin,
          ),
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

  Widget _buildTabViewAdd(BuildContext context, List moduleDTOList, {required LevelResponseEntity levelEntity}) {
    return ManageAuthBoxWidget(
      authCodes: controller.courseInfo?.specialty == SpecialtyEnum.EN_PHONICS ? [
        ManageAuthCode.courseModuleCreate,
      ] : const [
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
            height: 354.wMin,
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
