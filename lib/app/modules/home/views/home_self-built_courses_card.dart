import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/home/controllers/home_controller.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/widgets/guide_engine/guide_engine.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/utils.dart';
import '../model/home_card_self_built_model.dart';
import 'home_card_default_widget.dart';
import 'home_common_widget.dart';

class HomeSelfbuiltCoursesCard extends GetView<HomeController> {
  /// 自建课程 卡片
  const HomeSelfbuiltCoursesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      HomeCardEntityItems data = controller.selfbuiltCoursesData.value;
      if(!controller.initSelfbuiltCoursesTab.value){
        return HomeCardDefaultWidget(data: data);
      }

      if(data.list == null || (data.list?.isEmpty??true)){
        return HomeCardDefaultWidget(data: data);
      }

      ThemeColorEntity? colors = StyleUtils.getCurrentThemeColors(data.bgColor);
      Color? borderColor = ColorUtils.parseColor(colors?.borderColor);
      LinearGradient? linearGradient = StyleUtils.parseCssLinearGradient(colors?.color);

      return Expanded(
        child: LayoutBuilder(
          builder: (context, constraints) {
            
            return GuideStepWidget(
              id: GuideWidgetIds.homeCustomCourseCard,
              onTap: () async{
                HomeCardSelfBuiltModel seData = controller.selfbuiltCoursesList[controller.selfbuiltCoursesTabIndex.value];
                controller.toSelfbuiltCoursesCreate(seData.data, context);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.wMin),
                  border: borderColor == null ? null : Border.all(
                    width: 1.wMin, 
                    color: borderColor,
                  ),
                  gradient: linearGradient,
                ),
                child: buildHaveWidget(context),
              ),
            );
          }
        ),
      );
    });
  }

  Widget buildHaveWidget(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 32.wMin),
        Obx((){
          return Row(
            children: [
              Expanded(
                child: HomeCardTabbarWidget(
                  padding: EdgeInsets.symmetric(horizontal: 24.wMin),
                  tabs: controller.selfbuiltCoursesList.map((e) => e.title).toList(),
                  selectIndex: controller.selfbuiltCoursesTabIndex.value,
                  onTap: (p0) {
                    controller.selfbuiltCoursesTabIndex.value = p0;
                    controller.selfbuiltCoursesTabController?.animateTo(p0);
                  },
                ),
              ),
              HelpIVideoIconWidget(
                padding: EdgeInsets.symmetric(horizontal: 20.wMin),
                helpVideoUrl: controller.selfbuiltCoursesData.value.helpVideoUrl,
              ), 
            ],
          );
        }),
        Expanded(
          child: TabBarView(
            controller: controller.selfbuiltCoursesTabController,
            children: List.generate(controller.selfbuiltCoursesList.length, (index) {
              return buildTabView(controller.selfbuiltCoursesList[index], context);
            }),
          ),
        ),
      ],
    );
  }

  Widget buildTabView(HomeCardSelfBuiltModel data, BuildContext context) {
    String unitText = data.data?.unitName??"";

    bool showCourse = data.data?.moduleId == null && data.data?.courseId != null;

    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 24.wMin),
      child: Row(
        children: [
          SizedBox(
            height: double.infinity,
            child: AspectRatio(
              aspectRatio: showCourse ? 1 : 0.7,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.wMin),
                child: CachedImageWidget(
                  showCourse ? data.data?.courseCoverUrl??"" : data.data?.moduleCoverUrl??"",
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
                        showCourse ? data.data?.courseName??"" : data.data?.moduleName??"",
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
                    unitText,
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
