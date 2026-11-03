import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'package:get/get.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/widgets/widgets.dart';
import '../controllers/dream_building_team_controller.dart';

class DreamBuildingTeamView extends GetView<DreamBuildingTeamController> {
  const DreamBuildingTeamView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0F0F),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 100.wMin),
        alignment: Alignment.topCenter,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/user_center/bg_building_dream.webp"),
            fit: BoxFit.cover,
          ),
        ),

        child: Stack(
          children: [
            Container(
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
                            top: MediaQuery.of(context).padding.top + 56.wMin,
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

            Positioned(
              top: MediaQuery.of(context).padding.top + 40.wMin,
              child: const BackWidget(),
            ),
          ],
        ),

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
