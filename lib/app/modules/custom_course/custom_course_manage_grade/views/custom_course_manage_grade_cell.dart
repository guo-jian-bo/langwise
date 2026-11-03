import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/common/entities/course_level_entity.dart';
import 'package:langwise/common/entities/theme_style_entity.dart';
import 'package:langwise/common/widgets/build_image.dart';
import 'package:langwise/utils/color_utils.dart';
import 'package:langwise/utils/style_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../controllers/custom_course_manage_grade_controller.dart';

class CustomCourseManageGradeCell extends StatelessWidget {
  //final List<ThemeTextEntity?>? tierMappings;
  final CourseLevelEntityLevelListModuleList? wordModel;
  final bool isTop;
  final bool isDragging;
  final int? courseId;
  final bool readOnly;

  const CustomCourseManageGradeCell({super.key, required this.wordModel, required this.isTop, this.readOnly = false, this.isDragging = false, this.courseId});

  @override
  Widget build(BuildContext context) {
    double width = isDragging ? 200.wMin : 380.wMin;
    double height = isDragging ? 200.wMin * 10 / 7 : 380.wMin * 10 / 7;

    return SizedBox(
      width: width,
      height: height,
      child: Container(
        padding: EdgeInsets.all(20.wMin),
        decoration: BoxDecoration(
          color: AppTheme.cEditBookCellBackground,
          borderRadius: BorderRadius.circular(12.wMin),
        ),
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Get.offNamedUntil(
                    Routes.OFFICIAL_COURSE_DETAILS,
                    ModalRoute.withName(Routes.APPLICATION),
                    arguments: {
                      "courseId": courseId,
                      "levelId": wordModel?.levelId,
                      "moduleId": wordModel?.moduleId,
                      "isNew":wordModel?.newAdd,
                      "isSwitchCourse": true,
                      "goCustomCourseProgress": false,
                    },
                  );
                },
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.wMin),
                      child: wordModel?.coverUrl != null
                          ? CachedImageWidget(
                              wordModel!.coverUrl!,
                              fit: BoxFit.fill,
                              width: double.infinity,
                              height: double.infinity,
                            )
                          : buildEmptyWidget(),
                    ),
                    // Visibility(
                    //   visible: !(wordModel?.completed ?? false) && !isDragging,
                    //   child: ClipRRect(
                    //     borderRadius: BorderRadius.circular(12.wMin),
                    //     child: Container(
                    //       alignment: Alignment.center,
                    //       color: AppTheme.cOverlayBackground,
                    //       child: Column(
                    //         mainAxisSize: MainAxisSize.min,
                    //         children: [
                    //           Visibility(visible: !isTop, child: SizedBox(height: 40.wMin)),
                    //           Text(
                    //             "正在生成中",
                    //             style: TextStyle(
                    //               fontSize: isTop ? 20.wMin : 30.wMin,
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
                    //                 fontSize: isTop ? 15.wMin : 20.wMin,
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
                    Visibility(
                      visible: !isTop,
                      child: Container(
                        padding: EdgeInsets.all(24.wMin),
                        child: Wrap(
                          spacing: 10.wMin,
                          runSpacing: 10.wMin,
                          children: List.generate(wordModel?.tierMappings?.length ?? 0, (index) {
                            ThemeTextEntity? themeTextEntity = wordModel?.tierMappings?[index];

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
                    ),
                    if (!readOnly)
                      Positioned(
                        top: 10.wMin,
                        right: 10.wMin,
                        child: GestureDetector(
                          onTap: () {
                            Get.find<CustomCourseManageGradeController>().deleteModule(wordModel);
                          },
                          child: ClipOval(
                            child: Container(
                              color: const Color.fromRGBO(0, 0, 0, 0.5),
                              width: 36.wMin,
                              height: 36.wMin,
                              child: Center(
                                child: SvgPicture.asset(
                                  "assets/svg/public/icon_delete.svg",
                                  width: 26.wMin,
                                  colorFilter: const ColorFilter.mode(
                                    Color(0xFFBEC8D0),
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (!readOnly)
                      Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              Get.find<CustomCourseManageGradeController>().modifyModuleCover(wordModel);
                            },
                            child: Container(
                              color: const Color.fromRGBO(0, 0, 0, 0.3), //4D000000
                              padding: EdgeInsets.symmetric(vertical: 8.wMin),
                              child: Center(
                                child: Text(
                                  '修改封面',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 18.wMin,
                                    color: AppTheme.cTextPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ))
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.wMin),
            InkWell(
              onTap: () {
                if (readOnly) return;
                Get.find<CustomCourseManageGradeController>().modifyModuleName(wordModel);
              },
              child: Row(
                children: [
                  if (wordModel?.newAdd ?? false)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.wMin),
                        color: AppTheme.cFeedbackSuccessBackground,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
                      margin: EdgeInsets.only(right: 8.wMin),
                      child: Text('新添加', style: TextStyle(fontSize: 14.wMin, color: AppTheme.cFeedbackSuccessText)),
                    ),
                  Expanded(
                    child: GetBuilder<CustomCourseManageGradeController>(
                      builder: (controller) {
                        return Text(
                          wordModel?.name ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 20.wMin,
                            color: AppTheme.cTextPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ),
                  if (!readOnly)
                    Padding(
                      padding: EdgeInsets.only(left: 10.wMin),
                      child: SvgPicture.asset(
                        "assets/svg/custom_course/icon_course_modify.svg",
                        width: 20.wMin,
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
}
