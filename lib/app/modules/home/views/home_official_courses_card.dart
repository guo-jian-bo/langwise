


import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../utils/utils.dart';
import '../controllers/home_controller.dart';
import '../model/home_card_official_model.dart';
import 'home_common_widget.dart';

class HomeOfficialCoursesCard extends GetView<HomeController> {
  /// 官方课程 卡片
  const HomeOfficialCoursesCard({super.key});

  @override
  Widget build(BuildContext context) {

    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Obx((){
            if(!controller.fistCardTabInit.value) return Container();

            ThemeColorEntity? cardColor = StyleUtils.getCurrentThemeColors(controller.homeOfficialCardData.value.bgColor);
            LinearGradient? linearGradient = StyleUtils.parseCssLinearGradient(cardColor?.color);

            return TapScaleWidget(
              sclae: 1,
              onTap: () {
                controller.checkOfficialCourseCard(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.wMin),
                  border: Border.all(
                    width: 1.wMin,
                    color: ColorUtils.parseColor(cardColor?.borderColor)??Colors.transparent,
                  ),
                  gradient: linearGradient,
                ),
                child: buildOfficialList(constraints),
              ),
            );
          });
        }
      ),
    );
  }

  Widget buildOfficialList(BoxConstraints constraints){
      return ClipRRect(
        borderRadius: BorderRadius.circular(15.wMin),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 32.wMin),
                Row(
                  children: [
                    Expanded(
                      child: HomeCardTabbarWidget(
                        padding: EdgeInsets.symmetric(horizontal: 24.wMin),
                        selectIndex: controller.officialCoursesTabIndex.value,
                        tabs: controller.officialCoursesTab.map((e) => e.title).toList(),
                        onTap: (p0) {
                          controller.officialCoursesTabIndex.value = p0;
                          controller.officialCoursesTabController?.animateTo(p0);
                        },
                      ),
                    ),
                    HelpIVideoIconWidget(
                      padding: EdgeInsets.symmetric(horizontal: 20.wMin),
                      helpVideoUrl: controller.homeOfficialCardData.value.helpVideoUrl,
                    ), 
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: controller.officialCoursesTabController,
                    // physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(controller.officialCoursesTab.length, (index){
                      return HomeOfficialCoursesCardTabViewWidget(
                        data: controller.officialCoursesTab[index],
                        constraints: constraints,
                      );
                    }),
                  ),
                ),
                SizedBox(height: 50.wMin),
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
}

class HomeOfficialCoursesCardTabViewWidget extends StatefulWidget {
  final BoxConstraints constraints;
  final HomeCardOfficialModel data;
  const HomeOfficialCoursesCardTabViewWidget({super.key, required this.data, required this.constraints});

  @override
  State<HomeOfficialCoursesCardTabViewWidget> createState() => _HomeOfficialCoursesCardTabViewWidgetState();
}

class _HomeOfficialCoursesCardTabViewWidgetState extends State<HomeOfficialCoursesCardTabViewWidget> {
  final HomeController controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    List<HomeCardOfficialDataModuleInfoModel?>? moduleInfoList = widget.data.data?.moduleInfoList;
    if(moduleInfoList == null) return Container();

    double width = widget.constraints.maxWidth;
    double height = widget.constraints.maxHeight;
 
    double viewportFraction = 0.29;

    if(width > 600.wMin && height > 500.wMin){
      viewportFraction = 0.42;
    }else if(width > 600.wMin){
      viewportFraction = 0.15;
    }

    return Container(
      margin: EdgeInsets.only(top: 30.wMin),
      padding: EdgeInsets.symmetric(vertical: 8.wMin),
      child: CarouselSlider(
        options: CarouselOptions(
          autoPlay: true,
          viewportFraction: viewportFraction,
          aspectRatio: 3,
          autoPlayAnimationDuration: const Duration(seconds: 3),
          autoPlayInterval: const Duration(seconds: 3),
          autoPlayCurve: Curves.linear,
          pageSnapping: false,
          clipBehavior: Clip.none,
        ),
        items: List.generate(moduleInfoList.length, (index){
          return AspectRatio(
            aspectRatio: 0.7,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6.wMin),
              child: CachedImageWidget(
                moduleInfoList[index]?.moduleCoverUrl??"",
                errorWidget: buildEmptyWidget(),
                placeholder: buildLoadingWidget(fit: BoxFit.cover),
              ),
            ),
          );
        }),
      ),
    );
  }
}


