import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

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
      body: Container(
        padding: EdgeInsets.only(
          top: 20.wh,
          bottom: 80.wh + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            if (!controller.isHideHeader) SizedBox(height: 40.wh),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    left: -400.ww,
                    child: Obx(() {
                      if (controller.levelTabList.isEmpty) return Container();
                      if (controller.tabController == null) return Container();
                      return TabBarView(
                        controller: controller.tabController,
                        viewportFraction: 0.6,
                        children: List.generate(controller.levelTabList.length, (index) {
                          final LevelResponseEntity responseEntity = controller.levelTabList[index];
                          return _buildTabView(context, index, responseEntity);
                        }),
                      );
                    }),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    if (controller.isHideHeader) {
      return const SizedBox();
    }
    return Row(
      children: [
        SizedBox(width: 4.ww),
        Expanded(
          child: _buildTabBar(context),
        ),
        SizedBox(width: 50.ww),
       ManageAuthBoxWidget(
          authCodes: const [
            ManageAuthCode.courseRelationLevel,
            ManageAuthCode.courseLevelCopy,
            ManageAuthCode.courseLevelCreate,
          ],
          isAny: true,
          child: TapScaleWidget(
            sclae: 1.1,
            onTap: () => controller.toAddLevel(context),
            child: Container(
              color: Colors.transparent,
              padding: EdgeInsets.symmetric(vertical: 5.wh),
              child: Row(
                children: [
                  SvgPicture.asset(
                    "assets/svg/manage/icon_add.svg",
                    height: 22.ww,
                  ),
                  Text(
                    "新增级别",
                    style: TextStyle(
                      fontSize: 16.wMin,
                      color: const Color(0xffEAECFF),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 50.ww),
        ManageAuthBoxWidget(
          authCodes: const [ManageAuthCode.courseEdit],
          child: TapScaleWidget(
            onTap: () => controller.showSort(context),
            key: controller.sortGlobalKey,
            child: Container(
              padding: EdgeInsets.all(5.ww),
              color: Colors.transparent,
              child: Icon(
                Icons.more_horiz,
                color: const Color(0xffEDF0F4),
                size: 20.wMin,
              ),
            ),
          ),
        ),
        SizedBox(width: 24.ww),
      ],
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        scrollbars: false, // 隐藏滚动条
      ),
      child: Obx(() {
        if (controller.levelTabList.isEmpty) return Container();
        return TabBar(
          controller: controller.tabController,
          indicatorPadding: EdgeInsets.only(bottom: -10.wh),
          indicator: UnderlineTabIndicator(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(width: 5.wMin, color: const Color(0xff2388FF)),
          ),
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          dividerHeight: 0,
          labelPadding: EdgeInsets.symmetric(horizontal: 20.ww),
          labelStyle: TextStyle(
            fontSize: 22.wMin,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 22.wMin,
            color: const Color(0xffACB4C0),
            fontWeight: FontWeight.w500,
          ),
          tabs: List.generate(controller.levelTabList.length, (index) {
            final LevelResponseEntity responseEntity = controller.levelTabList[index];
            return Text(responseEntity.name ?? '');
          }),
        );
      }),
    );
  }

  Widget _buildTabViewCardItem(BuildContext context, int index, ModuleResponseEntity moduleEntity, {required LevelResponseEntity levelEntity}) {
    return TapScaleWidget(
      onTap: () {
        controller.toModuleDetils(moduleEntity.uid, moduleEntity.name, levelEntity: levelEntity);
      },
      sclae: 1.05,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.ww, vertical: 8.wh),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          color: const Color(0xff19213D).withValues(alpha: 0.5),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.wMin),
              child: Stack(
                children: [
                  SizedBox(
                    width: 105.ww,
                    child: CachedImageWidget(
                      moduleEntity.coverUrl ?? '',
                      width: 105.ww,
                      height: double.infinity,
                      fit: BoxFit.contain,
                      errorWidget: _buildEmptyWidget(),
                    ),
                  ),
                  Positioned(
                    left: 10.wMin,
                    top: 10.wMin,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.ww),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3.wMin),
                        color: moduleEntity.isAccess ? const Color(0xff44AF5C) : const Color(0xff465070),
                      ),
                      child: Text(
                        moduleEntity.newAccess,
                        style: TextStyle(
                          fontSize: 12.wMin,
                          color: const Color(0xffEBEFF5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Gaps.getWidth(10.ww),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    moduleEntity.name ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.wMin,
                      color: const Color(0xffEBEFF5),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 5.wMin),
                  Text(
                    moduleEntity.description ?? '',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 4,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 14.wMin,
                      color: const Color(0xffACB4C0),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 5.wMin),
                  Row(
                    children: [
                      StatusTagDifficultyWidget(
                        difficulty: moduleEntity.minDifficulty,
                        language: moduleEntity.language,
                      ),
                      SizedBox(width: 5.wMin),
                      Text(
                        "-",
                        style: TextStyle(
                          fontSize: 18.wMin,
                          color: const Color(0xff697179),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(width: 5.wMin),
                      StatusTagDifficultyWidget(
                        difficulty: moduleEntity.maxDifficulty,
                        language: moduleEntity.language,
                      ),
                    ],
                  ),
                  SizedBox(height: 5.wMin),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '模块ID: ${moduleEntity.uid}',
                        style: TextStyle(
                          fontSize: 14.wMin,
                          color: const Color(0xffACB4C0),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        '书籍ID: ${moduleEntity.bookId ?? ''}',
                        style: TextStyle(
                          fontSize: 14.wMin,
                          color: const Color(0xffACB4C0),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.wMin),
                  Text(
                    '扫描次数: ${moduleEntity.useCount ?? ''}',
                    style: TextStyle(
                      fontSize: 14.wMin,
                      color: const Color(0xffACB4C0),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ManageAuthBoxWidget(
                  authCodes: const [ManageAuthCode.courseModuleEdit],
                  child: TapScaleWidget(
                    onTap: () {
                      controller.onEditModule(context, index, moduleEntity, levelEntity: levelEntity);
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.wMin),
                      color: Colors.transparent,
                      child: SvgPicture.asset("assets/svg/manage/icon_edit.svg", width: 16.wMin),
                    ),
                  ),
                ),
                ManageAuthBoxWidget(
                  authCodes: const [ManageAuthCode.courseLevelEdit],
                  child: TapScaleWidget(
                    onTap: () {
                      controller.onDeleteModule(context, index, moduleEntity, levelEntity: levelEntity);
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.wMin),
                      color: Colors.transparent,
                      child: Icon(Icons.more_horiz, size: 16.wMin, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabView(BuildContext context, int levelIndex, LevelResponseEntity levelEntity) {
    final List moduleDTOList = levelEntity.moduleDTOList ?? [];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.ww),
      alignment: Alignment.center,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.ww, vertical: 24.wh),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.wMin),
          color: const Color(0xff141828).withValues(alpha: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text.rich(TextSpan(
                    style: TextStyle(
                      fontSize: 28.wMin,
                      color: const Color(0xffEBEFF5),
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(text: levelEntity.name ?? ''),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Container(
                          margin: EdgeInsets.only(left: 16.ww),
                          padding: EdgeInsets.symmetric(horizontal: 12.ww, vertical: 4.wh),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.wMin),
                            color: levelEntity.isAccess ? const Color(0xff44AF5C) : const Color(0xff465070),
                          ),
                          child: Text(
                            levelEntity.newAccess,
                            style: TextStyle(
                              fontSize: 14.wMin,
                              color: const Color(0xffEBEFF5),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
                ),
                SizedBox(width: 10.ww),
                ManageAuthBoxWidget(
                  authCodes: const [ManageAuthCode.courseLevelEdit],
                  child: TapScaleWidget(
                    onTap: () {
                      controller.onEditLevel(levelIndex, levelEntity);
                    },
                    child: Container(
                      padding: EdgeInsets.all(5.wMin),
                      child: SvgPicture.asset("assets/svg/manage/icon_edit.svg"),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 17.wh),
            Text(
              levelEntity.description ?? '',
              style: TextStyle(
                fontSize: 18.wMin,
                color: const Color(0xffACB4C0),
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 10.wh),
            Expanded(
              child: GridView.builder(
                itemCount: moduleDTOList.length + 1,
                padding: EdgeInsets.only(top: 7.wh),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 17.ww,
                  crossAxisSpacing: 17.ww,
                  childAspectRatio: 1.94,
                ),
                itemBuilder: (context, index) {
                  if (index == moduleDTOList.length) {
                    return _buildTabViewAdd(context, moduleDTOList, levelEntity: levelEntity);
                  }
                  return _buildTabViewCardItem(context, index, moduleDTOList[index], levelEntity: levelEntity);
                },
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
          radius: Radius.circular(8.wMin),
          borderType: BorderType.RRect,
          padding: EdgeInsets.zero,
          color: const Color(0xff444B5F),
          dashPattern: const [1, 2],
          strokeWidth: 1.wMin,
          child: Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  "assets/svg/manage/icon_add.svg",
                  height: 22.ww,
                ),
                Text(
                  "添加模块",
                  style: TextStyle(
                    fontSize: 16.wMin,
                    color: const Color(0xffEAECFF),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Container(
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
