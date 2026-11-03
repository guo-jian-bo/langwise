import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/widgets/widgets.dart';
import '../controllers/elements_morpheme_detils_controller.dart';
import 'elements_morpheme_detils_grid_view_widget.dart';

class ElementsMorphemeDetilsView extends GetView<ElementsMorphemeDetilsController> {
  final String tagText;
  const ElementsMorphemeDetilsView({super.key, required this.tagText});

  @override
  // String? get tag => Get.arguments['contentId']?.toString();
  // String? get tag => StorageUtil().getString("ElementsMorphemeDetilsDuplicatePagesId");
  String? get tag => tagText;

  @override
  Widget build(BuildContext context) {
    
    return Obx((){
      return LockOverlayWidget(
        rights: controller.morphemeDetils.value.rights,
        child: Scaffold(
          backgroundColor: AppTheme.cSurfacePrimary,
          body: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                StarrySkyBackgroundWidget(
                  starCount: 11,
                  minStarSize: 1.wMin,
                  maxStarSize: 3.wMin,
                  minTwinkleSpeed: 0.5,
                  maxTwinkleSpeed: 0.6,
                  minBrightness: 0.1,
                  maxBrightness: 0.2,
                  child: Obx((){
                    Widget body = Container();
                    if(controller.gridMenuIndex.value == 0){
                      if(controller.morphemeDetils.value.content == null) return Container();
                      body = NebulaViewWidget(
                        key: ValueKey(controller.posMenuIndex.value),
                        colorConfigs: Get.find<ConfigController>().colorConfigs.value.pos,
                        content: controller.morphemeDetils.value.content,
                        type: controller.morphemeDetils.value.type,
                        orbits: controller.nebulaData,
                        onTapCenter: () {
                          controller.showAffixDialog(context);
                        },
                        onTapWord: (data) {
                          controller.onTapWord(context, data);
                        },
                      );
                    }else{
                      body = ElementsMorphemeDetilsGridViewWidget(
                        tagText: tagText,
                        key: const ValueKey(1),
                      );
                    }
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: body,
                    );
                  }),
                ),
                _buildTitleButtonsWidget(context),
        
              ],
            ),
          ),
          floatingActionButton: _buildViewSwitchWidget(),
        ),
      );
    });
  }

  Widget _buildViewSwitchWidget(){
    return Container(
      width: 241.wMin,
      height: 152.wMin,
      padding: EdgeInsets.symmetric(vertical: 8.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cBgSecondary,
        border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary),
      ),
      child: Stack(
        children: [
          Obx((){
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              alignment: controller.gridMenuIndex.value == 0 ? Alignment.topCenter : Alignment.bottomCenter,
              child: Container(
                width: 225.wMin,
                height: 60.wMin,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.wMin),
                  color: AppTheme.cBorderPrimary,
                ),
              ),
            );
          }),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildViewSwitchItem("星云视图", "assets/svg/elements/icon_nebula.svg", 0),
              _buildViewSwitchItem("网格视图", "assets/svg/elements/icon_grid.svg", 1),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViewSwitchItem(String title, String svg, int index){
    return TapScaleWidget(
      onTap: () {
        controller.switchView(index);
      },
      sclae: 1,
      child: Container(
        height: 60.wMin,
        color: Colors.transparent,
        child: Row(
          spacing: 4.wMin,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(svg, width: 32.wMin),
            Text(
              title,
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildTitleButtonsWidget(BuildContext context){
    return Container(
      padding: EdgeInsets.only(
        top: 24.wMin + MediaQuery.of(context).padding.top,
        left: 48.wMin,
        right: 48.wMin,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            children: [
              const BackWidget(title: ""),
              const Spacer(),
              SizedBox(width: 48.wMin),
              Obx((){
                if(controller.posMenuList.length <= controller.posMenuIndex.value) return Container();
                return IconDropdownCheckWidget(
                  items: controller.posMenuList,
                  fontSize: 28.wMin,
                  width: 260.wMin,
                  selectIndex: controller.posMenuIndex.value,
                  sclae: 1.01,
                  child: _buildDrapBoyWidget(controller.posMenuList[controller.posMenuIndex.value].title),
                  onTap: (data, index) {
                    controller.switchPos(index);
                  },
                );
              }),
              SizedBox(width: 48.wMin),
              const DisplayLanguageFilteringIconWidget(),
              SizedBox(width: 24.wMin),
            ],
          ),
          Text(
            "相关单词",
            style: TextStyle(
              fontSize: 28.wMin,
              fontWeight: FontWeight.w600,
              color: AppTheme.cTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrapBoyWidget(String title){
    return Container(
      color: Colors.transparent,
      child: Row(
        spacing: 8.wMin,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 28.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary,
            ),
          ),
          SvgPicture.asset(
            "assets/svg/public/icon_arrow_down.svg",
            width: 36.wMin,
            colorFilter: const ColorFilter.mode(AppTheme.cTextPrimary, BlendMode.srcIn),
          ),
        ],
      ),
    );
  }

}
