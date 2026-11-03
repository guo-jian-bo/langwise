import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../../../common/widgets/widgets.dart';
import '../../../../../routes/routes.dart';
import '../../../utils/utils.dart';
import 'lesson_card_widget.dart';
import '../../../common/commons.dart';
import '../../../common/manage_list_tool_button_widget.dart';
import '../bindings/manage_module_detils_binding.dart';
import '../controllers/manage_module_detils_controller.dart';

class ManageModuleDetilsView extends GetView<ManageModuleDetilsController> {
  final String tagText;
  const ManageModuleDetilsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_MODULE_DETILS}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageModuleDetilsView(tagText: tag),
      binding: ManageModuleDetilsBinding(tag: tag),
      routeName: Routes.MANAGE_MODULE_DETILS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      onRefresh: () => controller.onFetchData(),
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
                      if (controller.unitTabList.isEmpty) {
                        return Container();
                      }
                      return TabBarView(
                        controller: controller.tabController,
                        viewportFraction: 0.6,
                        children: List.generate(controller.unitTabList.length, (index) {
                          final NewUnitResponseEntity responseEntity = controller.unitTabList[index];
                          return _buildTabView(context, index, responseEntity);
                        }),
                      );
                    }),
                  ),
                  Positioned(
                    right: 24.ww,
                    bottom: 24.wh,
                    child: ManageListToolButtonWidget(
                      onSubmit: () {
                        controller.onFetchData(isRefresh: true);
                      },
                    ),
                  ),
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

        Obx((){
          return Visibility(
            visible: controller.moduleResponseEntity.value?.coverUrl != null,
            child: TapScaleWidget(
              sclae: 1.1,
              onTap: () {
                if(controller.moduleResponseEntity.value?.coverUrl == null) return;
                ShowBigResourceDialog.showImage(
                  context: context, 
                  imageUrls: [controller.moduleResponseEntity.value!.coverUrl!],
                );
              },
              child: Text(
                "当前模块封面",
                style: TextStyle(
                  fontSize: 16.wMin,
                  color: const Color(0xffEAECFF),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          );
        }),
        SizedBox(width: 16.wMin),
        ManageAuthBoxWidget(
          authCodes: const [ManageAuthCode.contentReviewImageCreate, ManageAuthCode.contentReviewImageCreateByPrompt],
          child: TapScaleWidget(
            sclae: 1.1,
            onTap: () {
              controller.createModuleImage(context, "COURSE_MODULE", controller.moduleId);
            },
            child: Text(
              "新建模块封面",
              style: TextStyle(
                fontSize: 16.wMin,
                color: const Color(0xffEAECFF),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        SizedBox(width: 16.wMin),
        Visibility(
          visible: UserStore.to.rolePermissions.value.userIsImageReviewer || UserStore.to.rolePermissions.value.userIsImageSuperReviewer,
          child: TapScaleWidget(
            sclae: 1.1,
            onTap: () {
              controller.toReviewPage("COURSE_MODULE", controller.moduleId, controller.moduleReviewImageCount.value);
            },
            child: Obx((){
              return Text(
                "待审核图片(${controller.moduleReviewImageCount.value})",
                style: TextStyle(
                  fontSize: 16.wMin,
                  color: const Color(0xffEAECFF),
                  fontWeight: FontWeight.w400,
                ),
              );
            }),
          ),
        ),
        SizedBox(width: 16.wMin),

        ManageAuthBoxWidget(
          authCodes: const [ManageAuthCode.courseModuleGenerateAudio],
          child: TapScaleWidget(
            sclae: 1.1,
            onTap: () {
              controller.generateAudio();
            },
            child: Text(
              "音频生成",
              style: TextStyle(
                fontSize: 16.wMin,
                color: const Color(0xffEAECFF),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        SizedBox(width: 16.wMin),
        ManageAuthBoxWidget(
          authCodes: const [ManageAuthCode.courseUnitCreate],
          child: TapScaleWidget(
            sclae: 1.1,
            onTap: () => controller.toAddUnit(context),
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
                    "新增单元",
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
        SizedBox(width: 30.ww),
        ManageAuthBoxWidget(
          authCodes: const [ManageAuthCode.courseModuleEdit],
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
        if (controller.unitTabList.isEmpty) return Container();
        return TabBar(
          controller: controller.tabController,
          onTap: (value) {
            
          },
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
          tabs: List.generate(controller.unitTabList.length, (index) {
            return Text("${controller.unitTabList[index].name}");
          }),
        );
      }),
    );
  }

  Widget _buildTabView(BuildContext context, int unitIndex, NewUnitResponseEntity unitEntity) {
    final List lessonDTOList = unitEntity.lessonDTOList ?? [];
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = (screenWidth / 800.wMin).floor();

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatusTagDifficultyWidget(
                  difficulty: unitEntity.difficulty?.min,
                  language: unitEntity.language,
                ),
                Gaps.getWidth(16.ww),
                Expanded(
                  child: Text.rich(TextSpan(
                    style: TextStyle(
                      fontSize: 28.wMin,
                      color: const Color(0xffEBEFF5),
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(text: unitEntity.name ?? ''),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Container(
                          margin: EdgeInsets.only(left: 16.ww),
                          padding: EdgeInsets.symmetric(horizontal: 12.ww, vertical: 4.wh),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.wMin),
                            color: unitEntity.isAccess ? const Color(0xff44AF5C) : const Color(0xff465070),
                          ),
                          child: Text(
                            unitEntity.newAccess,
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
                SizedBox(width: 10.wMin),
                Visibility(
                  visible: unitEntity.coverUrl != null,
                  child: TapScaleWidget(
                    sclae: 1.1,
                    onTap: () {
                      if(unitEntity.coverUrl == null) return;
                      ShowBigResourceDialog.showImage(
                        context: context, 
                        imageUrls: [unitEntity.coverUrl!],
                      );
                    },
                    child: Text(
                      "当前单元封面",
                      style: TextStyle(
                        fontSize: 16.wMin,
                        color: const Color(0xffEAECFF),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.wMin),
                ManageAuthBoxWidget(
                  authCodes: const [ManageAuthCode.contentReviewImageCreate, ManageAuthCode.contentReviewImageCreateByPrompt],
                  child: TapScaleWidget(
                    sclae: 1.1,
                    onTap: () {
                      controller.createModuleImage(context, "COURSE_UNIT", unitEntity.uid);
                    },
                    child: Container(
                      padding: EdgeInsets.only(left: 12.ww, right: 12.ww, top: 8.wh, bottom: 8.wh),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.wMin),
                        border: Border.all(
                          width: 1.wMin,
                          color: const Color(0xff353E5C),
                        ),
                      ),
                      child: Text(
                        "新建单元封面",
                        style: TextStyle(
                          fontSize: 16.wMin,
                          color: const Color(0xffEBEFF5),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.wMin),
                Visibility(
                  visible: UserStore.to.rolePermissions.value.userIsImageReviewer || UserStore.to.rolePermissions.value.userIsImageSuperReviewer,
                  child: TapScaleWidget(
                    sclae: 1.1,
                    onTap: () {
                      controller.toReviewPage("COURSE_UNIT", unitEntity.uid, unitEntity.coverReviewImageCount);
                    },
                    child: Container(
                      padding: EdgeInsets.only(left: 12.ww, right: 12.ww, top: 8.wh, bottom: 8.wh),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.wMin),
                        border: Border.all(
                          width: 1.wMin,
                          color: const Color(0xff353E5C),
                        ),
                      ),
                      child: Text(
                        "待审核图片(${unitEntity.coverReviewImageCount})",
                        style: TextStyle(
                          fontSize: 16.wMin,
                          color: const Color(0xffEBEFF5),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.wMin),
                ManageAuthBoxWidget(
                  authCodes: const [ManageAuthCode.unitKnowledgeList],
                  child: TapScaleWidget(
                    onTap: () {
                      controller.onAddKnowledge(context, unitEntity);
                    },
                    child: Container(
                      padding: EdgeInsets.only(left: 12.ww, right: 12.ww, top: 8.wh, bottom: 8.wh),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.wMin),
                        border: Border.all(
                          width: 1.wMin,
                          color: const Color(0xff353E5C),
                        ),
                      ),
                      child: Text(
                        "管理知识点列表",
                        style: TextStyle(
                          fontSize: 16.wMin,
                          color: const Color(0xffEBEFF5),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.wMin),
                ManageAuthBoxWidget(
                  authCodes: const [ManageAuthCode.courseUnitEdit],
                  child: TapScaleWidget(
                    onTap: () {
                      controller.onEditUnit(unitIndex, unitEntity);
                    },
                    child: Container(
                      padding: EdgeInsets.only(left: 12.ww, right: 12.ww, top: 8.wh, bottom: 8.wh),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.wMin),
                        border: Border.all(
                          width: 1.wMin,
                          color: const Color(0xff353E5C),
                        ),
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            "assets/svg/manage/icon_edit.svg",
                            width: 16.ww,
                            height: 16.ww,
                          ),
                          Gaps.getWidth(8.ww),
                          Text(
                            "编辑",
                            style: TextStyle(
                              fontSize: 16.wMin,
                              color: const Color(0xffEBEFF5),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 17.wh),
            Text(
              unitEntity.description ?? '',
              style: TextStyle(
                fontSize: 18.wMin,
                color: const Color(0xffACB4C0),
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 10.wh),
            Expanded(
              child: AnimatedReorderableGridView(
                items: lessonDTOList.cast<LessonResponseEntity>(),
                padding: EdgeInsets.only(top: 7.wh),
                shrinkWrap: true,
                enterTransition: [SlideInDown()],
                exitTransition: [SlideInUp()],
                insertDuration: const Duration(milliseconds: 200),
                removeDuration: const Duration(milliseconds: 200),
                dragStartDelay: const Duration(milliseconds: 200),
                sliverGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 20.wMin,
                  crossAxisSpacing: 20.wMin,
                  childAspectRatio: 464.wMin / 208.wMin,
                ),
                proxyDecorator: _proxyDecorator,
                lockedItems: lessonDTOList.cast<LessonResponseEntity>().where((element) => element.isUnitTARGET || element.isUnitTEST || element.isAddButton).toList(),
                onReorder: (int oldIndex, int newIndex) {
                  controller.onReorderLesson(unitEntity, oldIndex, newIndex);
                },
                isSameItem: (a, b) => a.uniqueId == b.uniqueId,
                itemBuilder: (context, index) {
                  final item = lessonDTOList[index] as LessonResponseEntity;
                  if (index == lessonDTOList.length - 1) {
                    return _buildTabViewAdd(context, unitEntity);
                  }

                  return LessonCardWidget(
                    key: ValueKey(item.uniqueId),
                    unitId: unitEntity.uid,
                    planned: unitEntity.planned,
                    sentenceGenerated: unitEntity.sentenceGenerated,
                    index: index,
                    lessonEntity: item,
                    songGenerateType: unitEntity.songGenerateType ?? 0,
                    remixTextGenerateType: unitEntity.remixTextGenerateType ?? 0,
                    controller: controller,
                    onTap: (int i, LessonResponseEntity entity) {
                      controller.toUnitTarget(unitEntity, entity);
                    },
                    onActionTap: (BuildContext context, globalKey, entity, i) {
                      OptionMenuManager.showAtKey(
                        context: context,
                        key: globalKey,
                        items: [
                          if(ManageAuthUtils.isAuth(ManageAuthCode.courseLessonEdit)) OptionMenuItem(
                            title: "编辑",
                            onTap: () {
                              controller.toEditLesson(context, i, entity, unitEntity: unitEntity);
                            },
                          ),
                          if(ManageAuthUtils.isAuth(ManageAuthCode.courseUnitEdit)) OptionMenuItem(
                            title: "删除",
                            onTap: () {
                              controller.onDeleteLesson(context, i, entity, unitEntity: unitEntity);
                            },
                          ),
                        ],
                      );
                    },
                    onManageLessonTopicTap: (int i, LessonResponseEntity entity) {
                      controller.pushToCreateQuizPage(unitEntity, entity);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabViewAdd(BuildContext context, NewUnitResponseEntity<dynamic> unitEntity) {
    return ManageAuthBoxWidget(
      key: ValueKey('add_button_${unitEntity.uid}'),
      authCodes: const [ManageAuthCode.courseLessonCreate],
      child: TapScaleWidget(
        onTap: OptimizeUtils.noneThrottle(() {
          controller.createLesson(context, unitEntity);
        }, 350),
        sclae: 1.03,
        child: DottedBorder(
          radius: Radius.circular(12.wMin),
          borderType: BorderType.RRect,
          padding: EdgeInsets.zero,
          color: const Color(0xff444B5F),
          dashPattern: const [1, 2],
          strokeWidth: 2,
          child: Container(
            alignment: Alignment.center,
            height: 206.wMin,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  "assets/svg/manage/icon_add.svg",
                  height: 30.wMin,
                ),
                Text(
                  "添加Lesson",
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

  Widget _proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        return Material(
          elevation: 0,
          color: const Color(0xff23283D),
          borderRadius: BorderRadius.circular(6.wMin),
          child: child,
        );
      },
      child: child,
    );
  }
}
