import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'package:get/get.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../routes/routes.dart';
import '../bindings/dream_building_team_binding.dart';
import '../controllers/dream_building_team_controller.dart';

class DreamBuildingTeamView extends GetView<DreamBuildingTeamController> {
  final String tagText;
  const DreamBuildingTeamView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      () => DreamBuildingTeamView(tagText: tag),
      binding: DreamBuildingTeamBinding(tagText: tag),
      routeName: Routes.DREAM_BUILDING_TEAM,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0F0F),
      body: Column(
        children: [
          const BreadcrumbWidget(),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 100.wMin),
              alignment: Alignment.topCenter,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/user_center/bg_building_dream.webp"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 60.wMin),
                child: Obx((){
                  return CustomScrollView(
                    slivers: List.generate(controller.dataList.length, (index){
                      List<DreamBuildingTeamEntityList?> list = controller.dataList[index].list??[];
                      return SliverStickyHeader.builder(
                        builder: (context, state) {
                          return Container(
                            alignment: Alignment.center,
                            height: 100.wMin,
                            margin: EdgeInsets.only(
                              top: 56.wMin,
                              bottom: 24.wMin,
                            ),
                            child: CachedImageWidget(
                              controller.dataList[index].badgeUrl??"",
                              fit: BoxFit.fitHeight,
                            ),
                          );
                        },
                        sliver: SliverGrid.builder(
                          itemCount: list.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 64.wMin,
                            mainAxisSpacing: 12.wMin,
                            mainAxisExtent: 120.wMin,
                          ),
                          itemBuilder: (context, itemIndex) {
                            return _buildItemWidget(list[itemIndex]);
                          },
                        ),
                      );
                    }),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildItemWidget(DreamBuildingTeamEntityList? data){
    return Row(
      children: [
        Container(
          width: 100.wMin,
          height: 100.wMin,
          padding: EdgeInsets.all(6.wMin),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(width: 3.wMin, color: AppTheme.cBorderBrand.color),
          ),
          child: ClipOval(
            child: CachedImageWidget(
              data?.avatarUrl??"",
              fit: BoxFit.cover,
              placeholder: SvgPicture.asset(
                "assets/svg/public/icon_user.svg",
              ),
              errorWidget: SvgPicture.asset(
                "assets/svg/public/icon_user.svg",
              ),
            ),
          ),
        ),
        SizedBox(width: 4.wMin),
        Expanded(
          child: Container(
            height: 100.wMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(width: 2.wMin, color: AppTheme.cBorderPrimary.color)),
            ),
            child: Text(
              data?.nickname??"",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 28.wMin,
                color: AppTheme.cStaticWhite.color,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }

}
