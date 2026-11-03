import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/widgets/widgets.dart';
import '../controllers/series_of_pictures_controller.dart';

class SeriesOfPicturesView extends GetView<SeriesOfPicturesController> {
  const SeriesOfPicturesView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cOverlayBackground,
      body: Container(
        margin: EdgeInsets.only(top: 120.wMin + MediaQuery.of(context).padding.top),
        child: PageView(
          controller: controller.pageController,
          children: List.generate(controller.styleData?.list.length??0, (index){
            return _buildImageListWidget(controller.styleData!.list[index], index, context);
          }),
        ),
      ),
    );
  }

  Widget _buildImageListWidget(VisualStyleEntityImageStyles data, int index, BuildContext context){
    return Obx((){
      double difference = (controller.currentPageIndex.value - index).abs();
      double opacity = 1.0;
      if (difference == 0) {
        opacity = 1.0;
      } else if (difference <= 1) {
        opacity = 1.0 - difference;
      } else {
        opacity = 0.0;
      }

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12.wMin),
        child: Hero(
          tag: "seriesOfPictures${controller.styleData?.locale}$index",
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              padding: EdgeInsets.only(left: 56.wMin, right: 56.wMin, top: 40.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.wMin)),
                color: AppTheme.cSurfaceTertiary,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Opacity(
                        opacity: opacity,
                        child: IgnorePointer(
                          ignoring: controller.currentPageIndex.value != index,
                          child: TapScaleWidget(
                            onTap: () => Get.back(),
                            child: ClipOval(
                              child: Container(
                                width: 40.wMin,
                                height: 40.wMin,
                                color: AppTheme.cWhiteAlpha20,
                                alignment: Alignment.center,
                                child: SvgPicture.asset(
                                  "assets/svg/public/x.svg",
                                  width: 32.wMin,
                                  height: 32.wMin,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          // child: Text(
                          //   "${data.localeTitle??''} ${data.styleTitle} 系列图片",
                          //   maxLines: 1,
                          //   overflow: TextOverflow.ellipsis,
                          //   style: TextStyle(
                          //     fontSize: 36.wMin,
                          //     color: AppTheme.cTextPrimary,
                          //     fontWeight: FontWeight.w600,
                          //   ),
                          // ),
                          child: Text.rich(
                            TextSpan(
                              style: TextStyle(
                                fontSize: 36.wMin,
                                color: AppTheme.cTextPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              children: [
                                TextSpan(text: data.localeTitle),
                                ...List.generate(data.iconUrls?.length??0, (index){
                                  return WidgetSpan(
                                    child: Container(
                                      height: 40.wMin,
                                      margin: EdgeInsets.symmetric(horizontal: 4.wMin),
                                      child: Image.network(
                                        data.iconUrls?[index]??"",
                                        errorBuilder: (context, error, stackTrace) => Container(),
                                      ),
                                    ),
                                  );
                                }),
                                TextSpan(text: " ${data.styleTitle} 系列图片"),
                              ]
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      SizedBox(width: 40.wMin),
                    ],
                  ),
                  SizedBox(height: 20.wMin),
                  Expanded(
                    child: GridView.builder(
                      itemCount: data.imageUrl?.length??0,
                      padding: EdgeInsets.only(
                        top: 20.wMin,
                        bottom: 20.wMin + MediaQuery.of(context).padding.bottom,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 32.wMin,
                        crossAxisSpacing: 32.wMin,
                      ),
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12.wMin),
                          child: Container(
                            color: AppTheme.cWhiteAlpha10,
                            child: CachedImageWidget(
                              data.imageUrl?[index]??"",
                              fadeInDuration: Duration.zero,
                              errorWidget: buildEmptyWidget(),
                              placeholder: buildLoadingWidget(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
