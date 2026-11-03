import 'package:auto_size_text/auto_size_text.dart';
import 'package:bubble_box/bubble_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/values/values.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../../../../routes/routes.dart';
import '../common/phonics_course_image_widget.dart';
import '../bindings/phonics_course_binding.dart';
import '../controllers/phonics_course_controller.dart';

class PhonicsCourseView extends GetView<PhonicsCourseController> {
  final String? controllerTag;
  final bool showBackButton;
  final bool showBreadcrumb;
  final String tagText;

  const PhonicsCourseView({
    super.key,
    this.tagText = '',
    this.controllerTag,
    this.showBackButton = true,
    this.showBreadcrumb = false,
  });

  @override
  String? get tag => controllerTag ?? (tagText.isEmpty ? null : tagText);

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    final bool asPrimaryPage =
        arguments is Map<String, dynamic> && arguments['asPrimaryPage'] == true;
    return await Get.to<T>(
      () => PhonicsCourseView(
        tagText: tag,
        showBackButton: !asPrimaryPage,
        showBreadcrumb: asPrimaryPage,
      ),
      binding: PhonicsCourseBinding(tagText: tag),
      routeName: Routes.PHONICS_COURSE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary,
      body: Column(
        children: [
          Obx(() {
            final bool hasLock =
                controller.courseData.value.rights?.isLock == true ||
                controller.courseData.value.rights?.isNoRights == true;
            return BreadcrumbWidget(
              actionWidget: IgnorePointer(
                ignoring: hasLock,
                child: _buildRefreshButtonWidget(),
              ),
            );
          }),
          Expanded(
            child: ClipRRect(
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(40.wMin)),
              child: Obx(() {
                return LockOverlayWidget(
                  rights: controller.courseData.value.rights,
                  showBack: false,
                  child: Container(
                    // color: AppTheme.cSurfaceSecondary.color,
                    child: _buildListWidget(context),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
  /// 悬浮按钮 刷新按钮
  Widget _buildRefreshButtonWidget() {
    if (controller.createStudyPlan) {
      return const SizedBox.shrink();
    }
    return ButtonWidget(
      text: "换一批单词",
      width: 168.wMin,
      height: 56.wMin,
      borderRadius: 14.wMin,
      color: AppTheme.cTransparentBrand1.color,
      fontColor: AppTheme.cTextBrand.color,
      fontSize: 24.wMin,
      fontWeight: FontWeight.w400,
      sclae: 1.03,
      onTap: () {
        controller.getLevelDatas();
      },
    );
  }

  Widget _buildListWidget(BuildContext context) {
    double lastBottomPadding = MediaQuery.of(context).padding.bottom + 124.wMin;

    return Obx(() {
      return CustomScrollView(
        controller: controller.scrollController,
        slivers: List.generate(controller.levelDatas.length, (index) {
          List<PhonicsCourseLevelListModuleList?> moduleList =
              controller.levelDatas[index].moduleList ?? [];

          return SliverStickyHeader.builder(
            builder: (context, state) {
              return _buildTitleWidget(controller.levelDatas[index]);
            },
            sliver: SliverPadding(
              padding: EdgeInsets.only(
                left: 96.wMin,
                right: 96.wMin,
                bottom: index == controller.levelDatas.length - 1
                    ? lastBottomPadding
                    : 56.wMin,
                top: 10.wMin,
              ),
              sliver: SliverGrid.builder(
                itemCount: moduleList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 24.wMin,
                  crossAxisSpacing: 24.wMin,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, itemIndex) {
                  return SizedBox(
                    key: index == 0 && itemIndex == 0
                        ? controller.firstModuleKey
                        : null,
                    child: _buildItemWidget(
                      context,
                      controller.levelDatas[index],
                      moduleList[itemIndex],
                    ),
                  );
                },
              ),
            ),
          );
        }),
      );
    });
  }

  Widget _buildTitleWidget(PhonicsCourseLevelList levelData) {
    return Container(
      height: 90.wMin,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(vertical: 10.wMin, horizontal: 96.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cBgPrimary,
        // color: Colors.yellow.withValues(alpha: 0.1),
      ),
      child: Text(
        levelData.name ?? "",
        style: TextStyle(
          fontSize: 40.wMin,
          color: AppTheme.cTextPrimary.color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildItemWidget(
    BuildContext context,
    PhonicsCourseLevelList levelData,
    PhonicsCourseLevelListModuleList? moduleData,
  ) {
    List<PronunciationsEntity?> pronunciations =
        moduleData?.contentInfo?.pronunciations ?? [];
    return TapScaleWidget(
      onTap: () {
        controller.toModulePage(context, levelData, moduleData);
      },
      sclae: 1.02,
      child: Container(
        decoration:
            moduleData?.current != true || !controller.isSelectThisModule
                ? null
                : BoxDecoration(
                    borderRadius: BorderRadius.circular(18.wMin),
                    border: Border.all(
                      color: AppTheme.cSurfaceWarning.color,
                      width: 2.wMin,
                    ),
                  ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16.wMin),
              child: PhonicsCourseImageWidget(
                imagePath: moduleData?.coverUrl ?? "",
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      width: double.infinity,
                      color: AppTheme.cBlackAlpha50.color,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          controller.createStudyPlan
                              ? Container(
                                  color: Colors.transparent,
                                  child: AutoSizeText(
                                    "/${moduleData?.topic ?? ''}/",
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 60.wMin,
                                      color: AppTheme.cInverseTextLight.color,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: "AndikaRegular",
                                    ),
                                  ),
                                )
                              : PronunciationsPlayIpaTextWidget(
                                  ipa: moduleData?.topic,
                                  pronunciations: pronunciations,
                                  national: LanguageServiceCode.US,
                                  style: TextStyle(
                                    fontSize: 60.wMin,
                                    color: AppTheme.cInverseTextLight.color,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: "AndikaRegular",
                                  ),
                                ),
                          _buildKnowledgeColorWidget(moduleData),
                          SizedBox(height: 20.wMin),
                        ],
                      ),
                    ),
                    controller.createStudyPlan
                        ? const SizedBox.shrink()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children:
                                List.generate(pronunciations.length, (index) {
                              return PlayLottieIconWidget(
                                size: 40.wMin,
                                audioUrl: pronunciations[index]?.audioUrl,
                                national: pronunciations[index]?.national,
                                backgroundImageUrl:
                                    pronunciations[index]?.nationalIconUrl,
                              );
                            }),
                          ),
             
                  ],
                ),
              ),
            ),
            Visibility(
              visible:
                  moduleData?.current == true && controller.isSelectThisModule,
              child: Positioned(
                bottom: -24.wMin,
                child: SizedBox(
                  width: 128.wMin,
                  height: 54.wMin,
                  child: BubbleBox(
                    backgroundColor: AppTheme.cFeedbackWarningBorder.color,
                    margin: EdgeInsets.zero,
                    padding: EdgeInsets.all(2.wMin),
                    shape: BubbleShapeBorder(
                      direction: BubbleDirection.top,
                      arrowQuadraticBezierLength: 4,
                      radius: BorderRadius.circular(10.wMin),
                      arrowHeight: 8.wMin,
                      arrowAngle: 8.wMin,
                      smooth: 0,
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppTheme.cSurfaceSecondary.color,
                        borderRadius: BorderRadius.circular(6.5.wMin),
                      ),
                      child: Text(
                        "当前位置",
                        style: TextStyle(
                          fontSize: 20.wMin,
                          color: AppTheme.cFeedbackWarningText.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 知识点着色
  Widget _buildKnowledgeColorWidget(
      PhonicsCourseLevelListModuleList? moduleData) {
    String? topic = moduleData?.topic;
    String? content = moduleData?.contentInfo?.content;
    List<PronunciationsEntity?> pronunciations =
        moduleData?.contentInfo?.pronunciations ?? [];

    return PronunciationsColorWidget(
      content: content,
      ipa: topic,
      pronunciations: pronunciations,
      national: LanguageServiceCode.US,
      showArrow: true,
      style: TextStyle(
        fontSize: 40.wMin,
        color: AppTheme.cInverseTextLight.color,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
