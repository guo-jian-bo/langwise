import 'dart:ui';

import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/enum/enum.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../routes/routes.dart';
import '../../../management/common/commons.dart';
import '../../../management/utils/utils.dart';
import '../bindings/official_course_details_target_binding.dart';
import '../controllers/official_course_details_target_controller.dart';
import '../models/course_details_target_content_type_model.dart';
import '../../common/official_course_details_target_widgets.dart';

class OfficialCourseDetailsTargetView extends GetView<OfficialCourseDetailsTargetController> {
  final String tagText;
  const OfficialCourseDetailsTargetView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      () => OfficialCourseDetailsTargetView(tagText: tag),
      binding: OfficialCourseDetailsTargetBinding(tagText: tag),
      routeName: Routes.OFFICIAL_COURSE_DETAILS_TARGET,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        controller.checkSearchText();
      },
      child: LayoutBuilder(builder: (context, constraints) {
        return Scaffold(
          backgroundColor: AppTheme.cSurfacePrimary.color,
          extendBody: true,
          body: Column(
            children: [
              buildTitle(context),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(40.wMin)),
                        color: AppTheme.cBgPrimary.color,
                      ),
                      child: _buildListWidget(context),
                    ),
                    Obx(() {
                      return AnimatedPositioned(
                        duration: const Duration(milliseconds: 200),
                        right: controller.isScrolling.value ? -70.wMin : 24.wMin,
                        bottom: 100.wMin + MediaQuery.of(context).padding.bottom,
                        child: _buildFloatButton(context),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: _buildKnowledgeTypeButtonsWidget(context),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        );
      }),
    );
  }

  Widget _buildKnowledgeTypeButtonsWidget(BuildContext context) {
    

    return Obx(() {
      if (controller.isSortMode.value) return Container(height: 0);
      if (controller.knowledgeTypeList.isEmpty) return Container(height: 0);

      return ListAnimationWidget(
        child: Container(
          height: 104.wMin,
          margin: EdgeInsets.only(bottom: 24.wMin),
          alignment: Alignment.center,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.wMin, sigmaY: 10.wMin),
              child: Container(
                height: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 24.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: AppTheme.cBlackAlpha20.color,
                  border: Border.all(
                    color: AppTheme.cBorderPrimary.color,
                    width: 1.wMin,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.cBlackAlpha10.color,
                      blurRadius: 8.wMin,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 24.wMin,
                  children: [

                    Visibility(
                      visible: controller.isAdminPage,
                      child: Obx((){
                        return FilterStripWidget(
                          width: 800.wMin,
                          conditions: {...controller.filterConditions},
                          onConditions: (datas) {
                            controller.onChangeFilter(datas);
                          },
                        );
                      }),
                    ),

                    ...List.generate(controller.knowledgeTypeList.length, (index) {
                      return _buildKnowledgeTypeItemWidget(index);
                    }),
                    _buildSearchButtonWidget(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildKnowledgeTypeItemWidget(int index) {
    return TapScaleWidget(
      onTap: OptimizeUtils.noneThrottle(() {
        controller.switchKnowledgeType(index);
      }, 300),
      sclae: 1.01,
      child: Obx(() {
        bool isSelected = controller.selectedKnowledgeTypeIndex.value == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          height: 56.wMin,
          width: 104.wMin,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: isSelected ? AppTheme.cSurfaceBrand.color : AppTheme.cSurfaceTertiary.color,
          ),
          child: Text(
            controller.knowledgeTypeList[index].title,
            style: TextStyle(
              color: isSelected ? AppTheme.cInverseTextLight.color : AppTheme.cTextTertiary.color,
              fontSize: 28.wMin,
              fontWeight: FontWeight.w400,
            ),
          ),
        );
      }),
    );
  }

  /// 搜索按钮
  Widget _buildSearchButtonWidget(BuildContext context) {
    bool isExpanded = controller.isSearchExpanded.value;
    return TapScaleWidget(
      onTap: () {
        controller.expandSearch();
      },
      sclae: isExpanded ? 1 : 1.01,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 56.wMin,
        width: isExpanded ? 341.wMin : 104.wMin,
        padding: EdgeInsets.only(left: isExpanded ? 24.wMin : (104.wMin - 32.wMin) / 2),
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceQuaternary.color,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            SvgPicture.asset(
              'assets/svg/public/icon_search.svg',
              colorFilter: ColorFilter.mode(AppTheme.cTextTertiary.color, BlendMode.srcIn),
              width: 32.wMin,
            ),
            Visibility(
              visible: isExpanded,
              child: FutureBuilder(
                initialData: false,
                future: Future.delayed(const Duration(milliseconds: 300), () => true),
                builder: (context, snapshot) {
                  return AnimatedOpacity(
                    opacity: snapshot.data ?? false ? 1 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      height: 56.wMin,
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(left: 44.wMin, right: 24.wMin),
                      child: TextField(
                        focusNode: controller.searchFocusNode,
                        controller: controller.searchController,
                        style: TextStyle(
                          color: AppTheme.cTextPrimary.color,
                          fontSize: 24.wMin,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: '搜索知识点',
                          hintStyle: TextStyle(
                            color: AppTheme.cTextTertiary.color,
                            fontSize: 24.wMin,
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (value) {
                          controller.realTimeSearch(value);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatButton(BuildContext context) {
    if (controller.knowledgeTypeList.isEmpty) return Container();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Visibility(
          visible: controller.isAdminPage,
          child: Container(
            margin: EdgeInsets.only(bottom: 200.wMin),
            child: ManageListToolButtonWidget(
              onSubmit: (){
                controller.getUnitTarget();
              },
            ),
          ),
        ),

        Visibility(
          visible: !controller.isAdminPage,
          child: Container(
            margin: EdgeInsets.only(bottom: 16.wMin),
            child: CardLearningStyleButtonWidget(
              onSubmit: () {
                controller.getUnitTarget();
              },
            ),
          ),
        ),

        Visibility(
          visible: !controller.isAdminPage,
          child: CardLearningButtonsWidget(
            onPreview: () {
              controller.previewCourse(context);
            },
            onFlash: () {
              controller.flashCardCourse(context);
            },
            onDictation: () {
              controller.dictationCourse(context);
            },
            onDownload: () {
              controller.downloadAudio(context);
            },
          ),
        ),
      ],
    );
  }
  

  Widget buildTitle(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BreadcrumbWidget(
            actionWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Visibility(
                  visible: controller.isAdminPage,
                  child: ManageAuthBoxWidget(
                    authCodes: const [ManageAuthCode.unitKnowledgeAdd],
                    child: ButtonWidget(
                      text: "添加知识点",
                      padding: EdgeInsets.symmetric(horizontal: 24.wMax),
                      height: 40.wMin,
                      borderRadius: 8.wMin,
                      color: AppTheme.cSurfaceInfo.color,
                      fontColor: AppTheme.cInverseTextLight.color,
                      fontWeight: FontWeight.w400,
                      fontSize: 16.wMin,
                      sclae: 1.03,
                      onTap: () {
                        controller.adminAddKnowledgeFunction(context);
                      },
                    ),
                  ),
                ),
                SizedBox(width: 32.wMin),
                const DisplayLanguageFilteringIconWidget(isIosAwait: true),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 72.wMin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() {
                  return Text(
                    controller.unitKnowledgePoints.value.description ?? "",
                    style: TextStyle(
                      fontSize: 28.wMin,
                      color: AppTheme.cTextPrimary.color,
                      fontWeight: FontWeight.w400,
                    ),
                  );
                }),
                Obx(() {
                  int? unitIndex = controller.unitKnowledgePoints.value.unitIndex;

                  return Visibility(
                    visible: unitIndex != null,
                    child: Text(
                      "第$unitIndex单元",
                      style: TextStyle(
                        fontSize: 28.wMin,
                        color: AppTheme.cTextTertiary.color,
                        fontWeight: FontWeight.w400,
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
  }

  Widget _buildListWidget(BuildContext context) {
    return Obx(() {
      if (controller.isSortMode.value) {
        ElementsCardType sortType = controller.sortKnowledgeType.value;
        CourseDetailsTargetContentTypeModel? sortModel = controller.knowledgeTypeList.firstWhereOrNull((element) => element.type == sortType);
        if (sortModel == null) return const SizedBox.shrink();
        return _buildKnowledgeListSortListWidget(context, sortModel);
      }

      return ListViewObserver(
        controller: controller.scrollObserverController,
        triggerOnObserveType: ObserverTriggerOnObserveType.directly,
        onObserve: (result) {
          controller.handleScroll();
          if (result.firstChild == null) return;
          int index = result.firstChild!.index;
          controller.switchShowListType(index);
        },
        child: Obx(() {
          return AnimatedOpacity(
            opacity: controller.knowledgeTypeList.isNotEmpty ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: ListView.builder(
              controller: controller.scrollController,
              padding: EdgeInsets.only(
                left: 70.wMin,
                right: 70.wMin,
                top: 40.wMin - 24.wMin,
                bottom: MediaQuery.of(context).padding.bottom + 200.wMin,
              ),
              itemCount: controller.knowledgeTypeList.length,
              itemBuilder: (context, index) {
                return _buildKnowledgeListWidget(context, controller.knowledgeTypeList[index]);
              },
            ),
          );
        }),
      );
    });
  }

  Widget _buildKnowledgeListWidget(BuildContext context, CourseDetailsTargetContentTypeModel model) {
    if (model.knowledges.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(top: 24.wMin),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                model.title,
                style: TextStyle(
                  fontSize: 28.wMin,
                  color: AppTheme.cTextPrimary.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Visibility(
                visible: controller.isAdminPage && !controller.isFilter(),
                child: ManageAuthBoxWidget(
                  authCodes: const [ManageAuthCode.unitKnowledgeOrder],
                  child: ButtonWidget(
                    text: "进入${model.title}排序模式",
                    padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 4.wMin),
                    borderRadius: 6.wMin,
                    fontSize: 18.wMin,
                    sclae: 1.05,
                    onTap: () {
                      controller.enterSortingMode(model.type);
                    },
                  ),
                ),
              ),
              SizedBox(width: 10.wMin),
              Text(
                "共 ${model.knowledges.length} 个",
                style: TextStyle(
                  fontSize: 18.wMin,
                  color: AppTheme.cTextTertiary.color,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.wMin),
          GridView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: model.columnCount,
              mainAxisSpacing: 16.wMin,
              crossAxisSpacing: 16.wMin,
              mainAxisExtent: 220.wMin,
            ),
            itemCount: model.knowledges.length,
            itemBuilder: (context, index) {
              return KnowledgeCardItemWidget(
                unitId: controller.unitId,
                knowledge: model.knowledges[index].knowledge,
                moduleTopic: controller.unitKnowledgePoints.value.moduleTopic,
                allKnowledge: controller.allKnowledgeList.toList(),
                isAdminPage: controller.isAdminPage,
                onEditTap: (type, knowledge) {
                  controller.adminEditFunction(context, type, knowledge);
                },
                onDeleteKnowledgeTap: (knowledge) {
                  controller.adminDeleteKnowledgeTap(context, knowledge, 1);
                },
                onDeleteKnowledgeFromLibraryTap: (knowledge) {
                  controller.adminDeleteKnowledgeTap(context, knowledge, 0);
                },
                onRefresh: (knowledge) {
                  controller.getUnitTarget(showLoading: false);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  /// 排序模式的列表
  Widget _buildKnowledgeListSortListWidget(BuildContext context, CourseDetailsTargetContentTypeModel model) {
    if (model.knowledges.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: EdgeInsets.only(top: 24.wMin),
      padding: EdgeInsets.only(
        left: 70.wMin,
        right: 70.wMin,
        top: 40.wMin - 24.wMin,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                model.title,
                style: TextStyle(
                  fontSize: 28.wMin,
                  color: AppTheme.cTextPrimary.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              ButtonWidget(
                text: "退出${model.title}排序模式",
                padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 4.wMin),
                borderRadius: 6.wMin,
                fontSize: 18.wMin,
                sclae: 1.05,
                onTap: () {
                  controller.isSortMode.value = false;
                  controller.sortKnowledgeType.value = ElementsCardType.none;
                },
              ),
              SizedBox(width: 10.wMin),
              Text(
                "共 ${model.knowledges.length} 个",
                style: TextStyle(
                  fontSize: 18.wMin,
                  color: AppTheme.cTextTertiary.color,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.wMin),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return AnimatedReorderableGridView(
                  key: ValueKey("${model.type.value}_${model.knowledges.length}"),
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 24.wMin,
                  ),
                  dragStartDelay: const Duration(milliseconds: 200),
                  isSameItem: (a, b) => a.knowledge.uid == b.knowledge.uid,
                  sliverGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: model.columnCount,
                    mainAxisSpacing: 16.wMin,
                    crossAxisSpacing: 16.wMin,
                    mainAxisExtent: 220.wMin,
                  ),
                  items: model.knowledges,
                  proxyDecorator: (child, index, animation) {
                    return Material(
                      color: Colors.transparent,
                      child: Transform.scale(
                        scale: 0.8,
                        child: child,
                      ),
                    );
                  },
                  itemBuilder: (context, index) {
                    return _buildKnowledgeListSortItemWidget(
                      context,
                      model.knowledges[index],
                      index,
                      model.columnCount,
                      model.knowledges.length,
                    );
                  },
                  onReorder: (oldIndex, newIndex) {
                    controller.onSortKnowledge(oldIndex, newIndex);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKnowledgeListSortItemWidget(
    BuildContext context,
    CourseDetailsTargetContentTypeKnowledgeModel knowledge,
    int index,
    int columnCount,
    int datasLength,
  ) {
    return KnowledgeCardItemWidget(
      key: ValueKey("${knowledge.knowledge.uid}_$index"),
      knowledge: knowledge.knowledge,
      moduleTopic: controller.unitKnowledgePoints.value.moduleTopic,
      allKnowledge: controller.allKnowledgeList.toList(),
      isAdminPage: controller.isAdminPage,
      onEditTap: (type, knowledge) {
        controller.adminEditFunction(context, type, knowledge);
      },
      onDeleteKnowledgeTap: (knowledge) {
        controller.adminDeleteKnowledgeTap(context, knowledge, 1);
      },
      onDeleteKnowledgeFromLibraryTap: (knowledge) {
        controller.adminDeleteKnowledgeTap(context, knowledge, 0);
      },
    );
  }
}
