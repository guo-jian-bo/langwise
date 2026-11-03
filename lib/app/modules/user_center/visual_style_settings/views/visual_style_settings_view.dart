import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../theme/theme.dart';
import '../../model/visual_style_model.dart';
import '../controllers/visual_style_settings_controller.dart';

class VisualStyleSettingsView extends GetView<VisualStyleSettingsController> {
  const VisualStyleSettingsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 296.wMin,
          right: 296.wMin,
          top: 80.wMin + MediaQuery.of(context).padding.top,
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleWidget(),
            SizedBox(height: 32.wMin),
            _buildCurrentLevelWidget(),
            SizedBox(height: 8.wMin),
            Obx((){
              return ListView.separated(
                itemCount: controller.imageStyles.length,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(vertical: 24.wMin),
                separatorBuilder: (context, index) {
                  return Container(
                    height: 1.wMin,
                    color: AppTheme.cWhiteAlpha10,
                    margin: EdgeInsets.only(top: 8.wMin, bottom: 32.wMin),
                  );
                },
                itemBuilder: (context, index) {
                  return _buildStyeListWidget(controller.imageStyles[index], context);
                },
              );
            }),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 152.wMin + MediaQuery.of(context).padding.bottom,
        color: AppTheme.cSurfaceSecondary,
        padding: EdgeInsets.only(left: 96.wMin, right: 96.wMin, top: 24.wMin),
        alignment: Alignment.topCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ButtonWidget(
              text: "取消",
              sclae: 1.05,
              width: 176.wMin,
              height: 64.wMin,
              color: AppTheme.cBgQuaternary,
              fontColor: AppTheme.cTextBrand,
              borderRadius: 12.wMin,
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              onTap: () => Get.back(),
            ),
            Obx((){
              return ButtonWidget(
                text: controller.selectIds.isEmpty ? "请至少选择一种视觉风格" : "确定",
                sclae: 1.02,
                height: 64.wMin,
                width: 310.wMin,
                color: AppTheme.cSurfaceBrand,
                fontColor: AppTheme.cStaticWhite,
                borderRadius: 12.wMin,
                fontSize: 24.wMin,
                fontWeight: FontWeight.w500,
                onTap: () => controller.confirm(context),
              );
            }),
          ],
        ),
      ),
    );
  }


  Widget _buildStyeListWidget(VisualStyleModel data, BuildContext context){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              data.localeTitle,
              style: TextStyle(
                fontSize: 28.wMin,
                color: AppTheme.cTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Visibility(
              visible: data.iconUrls.isNotEmpty,
              child: Container(
                margin: EdgeInsets.only(left: 8.wMin),
                child: Row(
                  spacing: 8.wMin,
                  children: List.generate(data.iconUrls.length, (index){
                    return SizedBox(
                      height: 40.wMin,
                      child: Image.network(
                        data.iconUrls[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(vertical: 24.wMin),
          child: Row(
            spacing: 32.wMin,
            children: List.generate(data.list.length, (index){
              return Hero(
                tag: "seriesOfPictures${data.locale}$index",
                child: _buildStyeListItemWidget(data.list[index], data, index, context),
                placeholderBuilder: (context, heroSize, child) {
                  return _buildStyeListItemWidget(data.list[index], data, index, context);
                },
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildStyeListItemWidget(VisualStyleEntityImageStyles data, VisualStyleModel info, int index, BuildContext context){
    
    return Material(
      type: MaterialType.transparency,
      child: TapScaleWidget(
        onTap: () => controller.selectStyle(data, info.localeTitle, context),
        sclae: 1.02,
        child: Obx((){
          String imageUrl = "";
          if(data.imageUrl?.isNotEmpty ?? false){
            imageUrl = data.imageUrl!.first??"";
          }
          return AnimatedContainer(
            duration: const Duration(milliseconds: 20),
            width: 240.wMin,
            height: 300.wMin,
            decoration: BoxDecoration(
              color: AppTheme.cBorderPrimary,
              borderRadius: BorderRadius.circular(12.wMin),
              border: !controller.selectIds.contains(data.uid) ? null : Border.all(
                width: 2.wMin,
                color: AppTheme.cSurfaceBrand,
              ),
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12.wMin)),
                      child: Container(
                        width: 240.wMin,
                        height: 240.wMin,
                        color: AppTheme.cWhiteAlpha10,
                        child: CachedImageWidget(
                          imageUrl,
                          errorWidget: buildEmptyWidget(),
                          placeholder: buildLoadingWidget(),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: data.isActivation,
                      child: Positioned(
                        left: 8.wMin,
                        bottom: 8.wMin,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.wMin),
                            color: AppTheme.cVisualStyleActivation,
                          ),
                          child: Text(
                            "已激活",
                            style: TextStyle(
                              fontSize: 24.wMin,
                              color: AppTheme.cStaticWhite,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 8.wMin,
                      top: 8.wMin,
                      child: StatusMembersOnlyWidget(
                        member: data.vipType,
                        vipConfigs: controller.userStore.userInfo.value.vipConfigs,
                      ),
                    ),
                    Visibility(
                      visible: data.isActivation,
                      child: Positioned(
                        left: 8.wMin,
                        bottom: 8.wMin,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.wMin),
                            color: const Color(0xff22C55E),
                          ),
                          child: Text(
                            "已激活",
                            style: TextStyle(
                              fontSize: 24.wMin,
                              color: AppTheme.cStaticWhite,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Row(
                    children: [
                      SizedBox(width: 16.wMin),
                      Expanded(
                        child: Text(
                          data.styleTitle??"",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 20.wMin,
                            color: AppTheme.cTextPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: data.vipType != controller.currentMemberLevel.value,
                        child: Container(
                          width: 24.wMin,
                          height: 24.wMin,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.cWhiteAlpha10,
                          ),
                          child: SvgPicture.asset(
                            "assets/svg/user_center/icon_crown.svg",
                            width: 18.wMin,
                            height: 18.wMin,
                          ),
                        ),
                      ),
                      SizedBox(width: 16.wMin),
                      TapScaleWidget(
                        onTap: (){
                          controller.showSeriesOfPictures(context, info, index);
                        },
                        sclae: 1.1,
                        child: Container(
                          color: Colors.transparent,
                          padding: EdgeInsets.symmetric(horizontal: 8.wMin),
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            "assets/svg/user_center/icon_more_horizontal.svg",
                            width: 24.wMin,
                            height: 24.wMin,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  /// 当前会员等级
  Widget _buildCurrentLevelWidget(){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx((){
              return Text(
                "当前会员等级: ${controller.currentMemberLevel.value}",
                style: TextStyle(
                  fontSize: 28.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              );
            }),
            Text(
              "不同会员等级可使用不同的视觉风格",
              style: TextStyle(
                fontSize: 20.wMin,
                color: AppTheme.cTextSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.only(left: 24.wMin, right: 8.wMin, top: 8.wMin, bottom: 8.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50.wMin),
            color: AppTheme.cSurfaceTertiary,
          ),
          child: Row(
            children: [
              Text(
                "剩余视觉风格激活券:",
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15.wMin, vertical: 8.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999.wMin),
                  color: AppTheme.cBorderPrimary,
                ),
                child: Obx((){
                  return Text(
                    "${controller.activationCoupon.value}",
                    style: TextStyle(
                      fontSize: 18.wMin,
                      color: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }),
              ),
              SizedBox(width: 16.wMin),
              TapScaleWidget(
                onTap: (){},
                sclae: 1.03,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 8.wMin),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999.wMin),
                    color: AppTheme.cSurfaceBrand,
                  ),
                  child: Row(
                    children: [
                      Text(
                        "去购买",
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: AppTheme.cStaticWhite,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SvgPicture.asset(
                        "assets/svg/public/icon_w_arrow_right.svg",
                        width: 24.wMin,
                        height: 24.wMin,
                      )
                    ],
                  ),
                ),
              ),
              
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitleWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "视觉风格设置",
          style: TextStyle(
            fontSize: 36.wMin,
            color: AppTheme.cTextPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          "自定义学习视觉风格",
          style: TextStyle(
            fontSize: 20.wMin,
            color: AppTheme.cTextSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

}
