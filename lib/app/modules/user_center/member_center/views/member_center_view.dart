import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../../../../routes/routes.dart';
import '../bindings/member_center_binding.dart';
import '../controllers/member_center_controller.dart';

class MemberCenterView extends GetView<MemberCenterController> {
  final String tagText;
  const MemberCenterView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      () => MemberCenterView(tagText: tag),
      binding: MemberCenterBinding(tagText: tag),
      routeName: Routes.MEMBER_CENTER,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary,
      body: Column(
        children: [
          const BreadcrumbWidget(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 20.wMin,
              ),
              child: Column(
                children: [
                  const SizedBox(width: double.infinity),
                  SizedBox(height: 28.wMin),
                  _buildTabbarWidget(),
                  SizedBox(height: 29.wMin),
                  SingleChildScrollView(
                    controller: controller.scrollController,
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 205.wMin, vertical: 20.wMin),
                    child: Obx(() {
                      if (controller.memberPackageList.isEmpty) return Container();
                      MemberPackageEntityList packages = controller.memberPackageList[controller.selectTabbarIndex.value];
                      List<MemberPackageEntityListList?> list = packages.list ?? [];
                      if (list.isEmpty) return Container();
                      return IgnorePointer(
                        ignoring: controller.selectMemberPackageIndex.value == -1,
                        child: Row(
                          spacing: 24.wMin,
                          children: List.generate(list.length, (index) {
                            return _buildMemberItemWidget(list[index], index, context);
                          }),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberItemWidget(MemberPackageEntityListList? data, int index, BuildContext context) {
    if (data == null) return Container();

    MemberLevelColor colors = StatusUtils.getMemberColorsByVipConfigs(UserStore.to.userInfo.value.vipConfigs, data.name);

    List<MemberPackageEntityListListPublicityItems?> publicityItems = data.publicityItems ?? [];

    MemberPackageEntityListCorners? corner = data.corners?.first;

    ThemeColorEntity? cornerBgColorData = StyleUtils.getCurrentThemeColors(corner?.bgColors);
    Color? cornerBgColor = ColorUtils.parseColor(cornerBgColorData?.color);
    ThemeTextStyleEntity? cornerTextStyleData = StyleUtils.getCurrentThemeText(corner?.textStyles);
    FontWeight? cornerFontWeight = StyleUtils.getFontWeight(cornerTextStyleData?.weight);
    Color cornerTextColor = ColorUtils.parseColor(cornerTextStyleData?.color) ?? AppTheme.cStaticWhite;
    double cornerFontSize = (cornerTextStyleData?.fontsize ?? 24).wMin;

    List<MemberPackageEntityListListBenefits?> benefits = data.benefits ?? [];

    return TapScaleWidget(
      onTap: () {
        controller.changeMemberPackage(index, data);
      },
      sclae: 1.02,
      child: Obx(() {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: 580.wMin,
          height: 680.wMin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32.wMin),
            color: AppTheme.cSurfacePrimary,
            border: Border.all(
              width: 2.wMin,
              color: controller.selectMemberPackageIndex.value == index ? colors.deep : AppTheme.cBorderPrimary,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32.wMin),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned(
                  top: -34.wMin,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 100.wMin, sigmaY: 100.wMin),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      width: 300.wMin,
                      height: 519.wMin,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(600.wMin)),
                        boxShadow: [
                          BoxShadow(
                            color: colors.deep.withValues(alpha: controller.selectMemberPackageIndex.value == index ? 0.3 : 0),
                            offset: const Offset(0, 0),
                            blurRadius: 100.wMin,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  padding: EdgeInsets.all(32.wMin),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.name ?? "",
                        style: TextStyle(
                          fontSize: 36.wMin,
                          color: AppTheme.cTextPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        data.describe ?? "",
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: AppTheme.cTextSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 24.wMin),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "${NumberUtils.formatNumberWithCommas((data.price ?? 0) / 100)}乃币",
                            style: TextStyle(
                              fontSize: 48.wMin,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.cTextPrimary,
                              height: 1,
                            ),
                          ),
                          // Visibility(
                          //   visible: data.durationTypeTitle != null,
                          //   child: Text(
                          //     "/${data.durationTypeTitle??''}",
                          //     style: TextStyle(
                          //       fontSize: 20.wMin,
                          //       fontWeight: FontWeight.w500,
                          //       color: AppTheme.cTextSecondary,
                          //     ),
                          //   ),
                          // ),

                          SizedBox(width: 16.wMin),
                          Visibility(
                            visible: data.originalPrice != null,
                            child: Text(
                              // "${NumberUtils.formatNumberWithCommas((data.originalPrice??0) / 100)}乃币/${data.durationTypeTitle??''}",
                              "${NumberUtils.formatNumberWithCommas((data.originalPrice ?? 0) / 100)}乃币",
                              style: TextStyle(
                                fontSize: 20.wMin,
                                fontWeight: FontWeight.w400,
                                color: AppTheme.cTextTertiary,
                                decoration: TextDecoration.lineThrough,
                                decorationColor: AppTheme.cTextTertiary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(publicityItems.length, (index) {
                          MemberPackageEntityListListPublicityItems? text = publicityItems[index];
                          if (text == null) return Container();

                          ThemeTextStyleEntity? style = StyleUtils.getCurrentThemeText(text.textStyles);
                          Color? textColor = ColorUtils.parseColor(style?.color);

                          FontWeight fontWeight = StyleUtils.getFontWeight(style?.weight);

                          ThemeColorEntity? colors = StyleUtils.getCurrentThemeColors(text.bgColors);
                          Color? bgColor = ColorUtils.parseColor(colors?.color);

                          return Container(
                            margin: EdgeInsets.only(top: 8.wMin),
                            padding: EdgeInsets.symmetric(horizontal: 7.wMin),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(4.wMin),
                            ),
                            child: Text(
                              text.text ?? "",
                              style: TextStyle(
                                fontSize: (style?.fontsize ?? 20).wMin,
                                fontWeight: fontWeight,
                                color: textColor ?? AppTheme.cTextSecondary,
                                fontStyle: (style?.italic ?? false) ? FontStyle.italic : FontStyle.normal,
                              ),
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: 24.wMin),
                      Container(
                        height: 1.wMin,
                        color: AppTheme.cBorderSecondary,
                      ),
                      SizedBox(height: 24.wMin),
                      Column(
                        spacing: 24.wMin,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(benefits.length, (index) {
                          return _buildMemberLiWidget(benefits[index]);
                        }),
                      ),
                      SizedBox(height: 120.wMin),
                    ],
                  ),
                ),
                Positioned(
                  right: -60.wMin,
                  top: 25.wMin,
                  child: Visibility(
                    visible: corner?.text != null,
                    child: Transform.rotate(
                      angle: 0.7,
                      child: Container(
                        width: 200.wMin,
                        height: 34.wMin,
                        color: cornerBgColor,
                        alignment: Alignment.center,
                        child: Text(
                          corner?.text ?? "",
                          style: TextStyle(
                            fontSize: cornerFontSize,
                            fontWeight: cornerFontWeight,
                            color: cornerTextColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  height: 120.wMin,
                  width: 580.wMin,
                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: 80.wMin),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: AppTheme.cBorderPrimary.color,
                              width: 1.wMin,
                            ),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppTheme.cStaticBlack.color.withValues(alpha: 0.02),
                              AppTheme.cStaticBlack.color.withValues(alpha: 0.16),
                            ],
                          ),
                        ),
                        child: TapScaleWidget(
                          onTap: data.disable ?? false ? null : () {
                            controller.toOpenMemberSettlement(data, context);
                          },
                          sclae: 1.03,
                          child: Container(
                            width: double.infinity,
                            height: 64.wMin,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.wMin),
                              border: Border.all(width: 0.5.wMin, color: colors.deep),
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  colors.pale,
                                  colors.deep,
                                ],
                              ),
                            ),
                            child: Text(
                              data.buyButton?.text ?? "",
                              style: TextStyle(
                                fontSize: 24.wMin,
                                color: AppTheme.cStaticWhite,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMemberLiWidget(MemberPackageEntityListListBenefits? data) {
    List<String?> items = data?.items ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data?.category ?? "",
          style: TextStyle(
            fontSize: 20.wMin,
            color: AppTheme.cTextPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Visibility(
          visible: items.isNotEmpty,
          child: Container(
            margin: EdgeInsets.only(top: 8.wMin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(items.length, (index) {
                if (items[index] == null) return Container();
                return Container(
                  margin: EdgeInsets.only(top: 2.wMin),
                  child: Row(
                    spacing: 4.wMin,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 30.wMin,
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          "assets/svg/public/icon_check_min.svg",
                          width: 18.wMin,
                          height: 18.wMin,
                          colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          items[index] ?? "",
                          style: TextStyle(
                            fontSize: 20.wMin,
                            color: AppTheme.cTextTertiary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabbarWidget() {
    return Container(
      padding: EdgeInsets.all(8.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cBgSecondary.color,
      ),
      child: Obx(() {
        return Row(
          spacing: 16.wMin,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(controller.memberPackageList.length, (index) {
            return _buildTabbarItemWidget(controller.memberPackageList[index], index);
          }),
        );
      }),
    );
  }

  Widget _buildTabbarItemWidget(MemberPackageEntityList data, int index) {
    MemberPackageEntityListCorners? corner = data.corners?.first;
    ThemeColorEntity? colors = StyleUtils.getCurrentThemeColors(corner?.bgColors);
    LinearGradient? gradient = StyleUtils.parseCssLinearGradient(colors?.color);

    return TapScaleWidget(
      onTap: () {
        controller.changeTabbar(index);
      },
      sclae: 1.03,
      child: Obx(() {
        return Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 80),
              width: 230.wMin,
              height: 104.wMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.wMin),
                color: AppTheme.cTextSecondary.withValues(alpha: controller.selectTabbarIndex.value == index ? 1 : 0),
              ),
            ),
            Container(
              width: 230.wMin,
              height: 104.wMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.wMin),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        data.title ?? "",
                        style: TextStyle(
                          fontSize: 36.wMin,
                          color: controller.selectTabbarIndex.value == index ? AppTheme.cBgPrimary : AppTheme.cTextPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Visibility(
                        visible: corner != null,
                        child: Container(
                          margin: EdgeInsets.only(left: 8.wMin),
                          padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999.wMin),
                            gradient: gradient,
                          ),
                          child: Text(
                            corner?.text ?? "",
                            style: TextStyle(
                              fontSize: 18.wMin,
                              color: AppTheme.cStaticWhite.color,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Visibility(
                    visible: data.describe != null,
                    child: Text(
                      data.describe ?? "",
                      style: TextStyle(
                        fontSize: 24.wMin,
                        color: AppTheme.cSurfaceError.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
