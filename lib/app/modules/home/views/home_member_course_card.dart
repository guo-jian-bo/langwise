import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/utils.dart';
import '../controllers/home_controller.dart';
import '../model/home_card_member_course_model.dart';
import 'home_common_widget.dart';

class HomeMemberCourseCard extends GetView<HomeController> {
  const HomeMemberCourseCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          double aspectRatio = (constraints.maxWidth) / (constraints.maxHeight);

          return Obx((){
            if(!controller.initMemberCourse.value) return Container();

            ThemeColorEntity? cardColor = StyleUtils.getCurrentThemeColors(controller.memberCourseData.value.bgColor);
            LinearGradient? linearGradient = StyleUtils.parseCssLinearGradient(cardColor?.color);

            return TapScaleWidget(
              onTap: () {
                HomeCardMemberCourseModel data = controller.memberCourseList[controller.memberCourseTabIndex.value];
                controller.toCoursesDetil(
                  context,
                  data.data?.courseId, 
                  data.data?.moduleId, 
                  data.data?.levelId,
                  controller.memberCourseData.value.rights,
                );
              },
              sclae: 1,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.wMin),
                  border: Border.all(
                    width: 1.wMin,
                    color: ColorUtils.parseColor(cardColor?.borderColor)??Colors.transparent,
                  ),
                  gradient: linearGradient,
                ),
                child: buildJoinCourse(aspectRatio, context),
              ),
            );
          });
        }
      ),
    );
  }

  /// 已经加入课程
  Widget buildJoinCourse(double aspectRatio, BuildContext context){
    return ClipRRect(
      borderRadius: BorderRadius.circular(15.wMin),
      child: Stack(
        children: [
          Column(
            key: const ValueKey(1),
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 32.wMin),
              Row(
                children: [
                  Expanded(
                    child: HomeCardTabbarWidget(
                      padding: EdgeInsets.symmetric(horizontal: 24.wMin),
                      tabs: controller.memberCourseList.map((e) => e.title).toList(),
                      selectIndex: controller.memberCourseTabIndex.value,
                      onTap: (index) {
                        controller.memberCourseCarouselController.animateToPage(index);
                      },
                    ),
                  ),
                  HelpIVideoIconWidget(
                    padding: EdgeInsets.symmetric(horizontal: 20.wMin),
                    helpVideoUrl: controller.memberCourseData.value.helpVideoUrl,
                  ), 
                ],
              ),
              Expanded(
                child: CarouselSlider(
                  carouselController: controller.memberCourseCarouselController,
                  options: CarouselOptions(
                    autoPlay: controller.memberCourseList.length > 1,
                    enableInfiniteScroll: controller.memberCourseList.length > 1,
                    viewportFraction: 1,
                    aspectRatio: 2.2 + aspectRatio,
                    onPageChanged: (index, reason) {
                      controller.memberCourseTabIndex.value = index;
                    },
                  ),
                  items: List.generate(controller.memberCourseList.length, (index){
                    return buildTabView(index, controller.memberCourseList[index], context);
                  }),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: -55.wMin,
            right: -55.wMin,
            child: SvgPicture.asset(
              "assets/svg/public/icon_home_free.svg",
              width: 146.wMin,
              height: 146.wMin,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTabView(int index, HomeCardMemberCourseModel data, BuildContext context){
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 24.wMin),
      child: Row(
        children: [
          SizedBox(
            height: double.infinity,
            child: AspectRatio(
              aspectRatio: 0.7,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.wMin),
                child: CachedImageWidget(
                  data.data?.moduleCoverUrl??"",
                  errorWidget: Image.asset(
                    "assets/images/custom_course/module_default.png",
                    fit: BoxFit.cover,
                  ),
                  placeholder: buildLoadingWidget(),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(width: 16.wMin),
          Expanded(
            child: SizedBox(
              height: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        data.data?.levelName??"",
                        maxLines: 1,
                        minFontSize: 6,
                        style: TextStyle(
                          fontSize: 20.wMin,
                          color: AppTheme.cTextSecondary,
                          fontWeight: FontWeight.w500,
                          height: 1.08,
                        ),
                      ),
                      SizedBox(height: 4.wMin),
                      AutoSizeText(
                        data.data?.moduleName??"",
                        minFontSize: 6,
                        maxLines: 3,
                        style: TextStyle(
                          fontSize: 28.wMin,
                          color: AppTheme.cTextPrimary,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    data.data?.unitName??"",
                    style: TextStyle(
                      fontSize: 20.wMin,
                      color: AppTheme.cTextSecondary,
                      fontWeight: FontWeight.w400,
                      height: 1.05,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  
}