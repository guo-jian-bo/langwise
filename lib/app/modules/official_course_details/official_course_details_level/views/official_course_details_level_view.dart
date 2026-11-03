import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../utils/utils.dart';
import '../controllers/official_course_details_level_controller.dart';

class OfficialCourseDetailsLevelView extends GetView<OfficialCourseDetailsLevelController> {
  const OfficialCourseDetailsLevelView({super.key});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        backgroundColor: AppTheme.cEditBookBackground,
        body: Column(
          children: [
            _buildTitleWidget(context),
            Expanded(
              child: Center(
                heightFactor: 0.8,
                child: SizedBox(
                  height: 900.wMin,
                  child: Obx(() {
                    if (controller.courseLevelList.isEmpty) {
                      // if (controller.isFromCustomCourse == true) {
                        return NotDataWidget(
                          message: "开始打造你的专属教材库",
                          buttonText: '立即添加教材',
                          onButton: () {
                            controller.editCourse(context);
                          },
                        );
                      // } else {
                        // return const SizedBox.shrink();
                      // }
                    }

                    return AnimationLimiter(
                      child: ListView.separated(
                        clipBehavior: Clip.none,
                        itemCount: controller.courseLevelList.length,
                        controller: controller.scrollController,
                        scrollDirection: Axis.horizontal,
                        physics: const ClampingScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 100.wMin, vertical: 10.wMin),
                        separatorBuilder: (context, index) => SizedBox(width: 32.wMin),
                        itemBuilder: (context, index) {
                          return buildListItem(context, controller.courseLevelList[index], index);
                        },
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTitleWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 24.wMin, left: 80.wMin, right: 40.wMin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() {
            return BackWidget(title: controller.courseLevel.value.name ?? "");
          }),
          Row(
            children: [
              _buildColorInfoItemWidget("舒适区", StudyZoneEnum.comfort),
              SizedBox(width: 20.wMin),
              _buildColorInfoItemWidget("学习区", StudyZoneEnum.study),
              SizedBox(width: 20.wMin),
              _buildColorInfoItemWidget("困难区", StudyZoneEnum.panic),
              SizedBox(width: 20.wMin),
              _buildColorInfoItemWidget("未定级", null),
            ],
          ),
          if (controller.isFromCustomCourse == true)
            GestureDetector(
              onTap: () {
                controller.editCourse(context);
              },
              child: Container(
                width: 176.wMin,
                height: 60.wMin,
                decoration: BoxDecoration(
                  color: AppTheme.cTextBrand,
                  borderRadius: BorderRadius.circular(30.wMin),
                ),
                child: Center(
                  child: Text(
                    "编辑教材",
                    style: TextStyle(
                      fontSize: 28.wMin,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildColorInfoItemWidget(String title, String? studyZoneEnum) {
    Color? color = StatusUtils.getStudyZoneColor(studyZoneEnum) ?? AppTheme.cTextPrimary.color;
    return Row(
      spacing: 4.wMin,
      children: [
        Container(
          width: 10.wMin,
          height: 10.wMin,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 24.wMin,
            color: color,
            fontWeight: FontWeight.w400,
          ),
        )
      ],
    );
  }

  Widget buildListItem(BuildContext context, CourseLevelEntityLevelList data, int index) {
    List<CourseLevelEntityLevelListModuleList?> moduleList = data.moduleList ?? [];
    if (moduleList.isEmpty) {
      return const SizedBox.shrink();
    }

    Color? cefrColor;
    if (UserStore.to.userInfo.value.assessmentTier == null) {
      cefrColor = StatusUtils.getCefrBackgroundColor(data.cefr).color2;
    } else {
      cefrColor = StatusUtils.getStudyZoneColor(data.studyZone) ?? AppTheme.cTextPrimary.color;
    }

    double nameWidth = 330.wMin;

    return ListAnimationWidget(
      index: index + 1,
      horizontalOffset: 50,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 32.wMin, vertical: 16.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32.wMin),
              color: AppTheme.cEditBookGradeBackground,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 8.wMin, right: 8.wMin),
                      decoration: BoxDecoration(
                        color: cefrColor,
                        borderRadius: BorderRadius.circular(8.0.wMin),
                      ),
                      child: Text(
                        data.cefr ?? "",
                        style: TextStyle(
                          fontSize: 26.wMin,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.wMin),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: nameWidth),
                      child: Text(
                        data.name ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 48.wMin,
                          color: StatusUtils.getStudyZoneColor(data.studyZone) ?? AppTheme.cTextPrimary,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.wMin),
                Row(
                  spacing: 40.wMin,
                  children: List.generate(moduleList.length, (index) {
                    return buildListItemModule(context, moduleList[index], data);
                  }),
                ),
                Visibility(
                  visible: moduleList.isEmpty,
                  child: TapScaleWidget(
                    onTap: () {
                      
                    },
                    sclae: 1.01,
                    child: Container(
                      width: 442.wMin,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24.wMin),
                        color: AppTheme.cBlackAlpha10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Visibility(
            visible: data.studyZone == StudyZoneEnum.study && controller.showRecommend,
            child: Positioned(
              top: -45.wMin,
              child: SizedBox(
                height: 96.wMin,
                child: Stack(
                  children: [
                    SvgPicture.asset(
                      "assets/svg/public/icon_tag_flag.svg",
                      height: 96.wMin,
                    ),
                    Positioned(
                      top: 18.wMin,
                      left: 8.wMin,
                      child: Transform.rotate(
                        angle: -0.13,
                        child: Text(
                          "推荐起点",
                          style: TextStyle(
                            fontSize: 24.wMin,
                            color: AppTheme.cStaticWhite.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildListItemModule(BuildContext context, CourseLevelEntityLevelListModuleList? data, CourseLevelEntityLevelList? level) {
    return SizedBox(
      width: 442.wMin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TapScaleWidget(
            onTap: OptimizeUtils.noneThrottle(() {
              controller.checkLevelImage(context, data, level);
            }, 500),
            sclae: 1.01,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.wMin),
              child: SizedBox(
                width: 442.wMin,
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 442 / 626,
                      child: Container(
                        color: AppTheme.cBlackAlpha10,
                        child: CachedImageWidget(
                          data?.coverUrl ?? "",
                          fit: BoxFit.cover,
                          errorWidget: buildEmptyWidget(),
                          placeholder: buildLoadingWidget(fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    // Visibility(
                    //   visible: !(data?.completed ?? true),
                    //   child: AspectRatio(
                    //     aspectRatio: 442 / 626,
                    //     child: Container(
                    //       alignment: Alignment.center,
                    //       color: AppTheme.cOverlayBackground,
                    //       child: Column(
                    //         mainAxisSize: MainAxisSize.min,
                    //         children: [
                    //           Text(
                    //             "正在生成中",
                    //             style: TextStyle(
                    //               fontSize: 40.wMin,
                    //               color: AppTheme.cStaticWhite,
                    //               fontWeight: FontWeight.w600,
                    //             ),
                    //           ),
                    //           SizedBox(height: 10.wMin),
                    //           GestureDetector(
                    //             onTap: () {},
                    //             child: Text(
                    //               "查看进度 >",
                    //               style: TextStyle(
                    //                 fontSize: 20.wMin,
                    //                 color: Colors.blue[400],
                    //                 fontWeight: FontWeight.w600,
                    //               ),
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    Container(
                      padding: EdgeInsets.all(24.wMin),
                      child: Wrap(
                        spacing: 10.wMin,
                        runSpacing: 10.wMin,
                        children: List.generate(data?.tierMappings?.length ?? 0, (index) {
                          ThemeTextEntity? themeTextEntity = data?.tierMappings?[index];

                          ThemeTextStyleEntity? style = StyleUtils.getCurrentThemeText(themeTextEntity?.style);
                          Color? bgColor = ColorUtils.parseColor(style?.backgroundColor);

                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.wMin),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.wMin),
                              color: bgColor,
                            ),
                            child: StyleUtils.getText(themeTextEntity),
                          );
                        }),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      width: 442.wMin,
                      child: Visibility(
                        visible: (data?.knowledgeCounts?.length ?? 0) != 0,
                        child: Container(
                          padding: EdgeInsets.all(16.wMin),
                          color: AppTheme.cBlackAlpha20,
                          child: Column(
                            spacing: 10.wMin,
                            children: List.generate(data?.knowledgeCounts?.length ?? 0, (index) {
                              return _buildTextRowWidget(data?.knowledgeCounts?[index]);
                            }),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 24.wMin),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if(data?.newAdd??false)Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.wMin),
                  color: AppTheme.cFeedbackSuccessBackground,
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.wMin,vertical: 6.wMin),
                margin: EdgeInsets.only(right: 8.wMin),
                child: Text('新添加',style: TextStyle(fontSize: 28.wMin,color: AppTheme.cFeedbackSuccessText)),
              ),
              Expanded(
                child: Text(
                  data?.name ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 32.wMin,
                    color: AppTheme.cTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Text(
            data?.description ?? "",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 28.wMin,
              color: AppTheme.cTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextRowWidget(CourseLevelEntityLevelListModuleListKnowledgeCounts? knowledgeCount) {
    List<LanguageText?>? names = knowledgeCount?.name;
    if (names == null) return Container();
    String name = "";
    for (int i = 0; i < names.length; i++) {
      if (names[i] == null) continue;
      if (names[i]?.lang == "zh") {
        name = names[i]?.text ?? "";
        break;
      }
    }
    return Row(
      spacing: 12.wMin,
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 24.wMin,
            color: AppTheme.cStaticWhite,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          knowledgeCount?.count?.toString() ?? '',
          style: TextStyle(
            fontSize: 28.wMin,
            color: AppTheme.cStaticWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
