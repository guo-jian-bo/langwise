
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../controllers/open_member_settlement_controller.dart';

class OpenMemberSettlementStudentWidget extends StatelessWidget {
  final OpenMemberSettlementController controller;
  const OpenMemberSettlementStudentWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBuySeatDurationWidget(),

        _buildStudentCountWidget(),

      ],
    );
  }

  /// 学员数量
  Widget _buildStudentCountWidget() {
    if(controller.traineeId != null) return const SizedBox.shrink();

    return Obx((){
      if(controller.extraPurchases.isEmpty) return Container();
      return Container(
        margin: EdgeInsets.only(top: 48.wMin),
        child: Column(
          spacing: 24.wMin,
          children: List.generate(controller.extraPurchases.length, (index){
            if(controller.servicePackage.value.isVipRenewal){
              return _buildSelectStudentListWidget(controller.extraPurchases[index], index);
            }else{
              return _buildAddStudentModelWidget(controller.extraPurchases[index], index);
            }
            
          }),
        ),
      );
    });
  }

  /// 增加学员数量
  Widget _buildAddStudentModelWidget(ExtraPurchaseModel data, int index){

    // String durationTitle = data.data.servicePackage?.durationTitle??"";

    List<PackageShopDetailEntityServicePackageRightsServicePackagePublicity?> publicity = data.data.servicePackage?.publicity??[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Row(
          children: [
            _buildTextTitleWidget(data.data.title??""),
            SizedBox(width: 4.wMin),
            Text(
              data.data.describe??"",
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextSecondary,
              ),
            ),
          ],
        ),
        
        SizedBox(height: 10.wMin),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 440.wMin,
              height: 160.wMin,
              padding: EdgeInsets.all(16.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.wMin),
                color: AppTheme.cBgQuaternary.color,
                border: Border.all(width: 0.5.wMin, color: AppTheme.cBorderPrimary),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    bottom: -16.wMin,
                    right: 0,
                    child: SvgPicture.asset(
                      "assets/svg/user_center/bg_crown.svg",
                      height: 100.wMin,
                      colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                // 调整角度以匹配289deg (CSS的289deg相当于Flutter中的-71deg)
                                transform: GradientRotation(-71 * (pi / 180)),
                                colors: [
                                  Color(0xFF0284C7), // --Color-brand-600
                                  Color(0xFF38BDF8), // --Color-brand-400
                                ],
                                stops: [0.0087, 0.9884], // 0.87%和98.84%转换为0-1范围
                              ).createShader(bounds);
                            },
                            child: Obx((){
                              return Text(
                                "副卡x${data.buyQuantity}",
                                style: TextStyle(
                                  fontSize: 36.wMin,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.cTextPrimary.color,
                                ),
                              );
                            }),
                          ),
                          const Spacer(),
                          Text(
                            publicity.isNotEmpty ? publicity.last?.text??"" : "",
                            style: TextStyle(
                              fontSize: 18.wMin,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.cTextPrimary.color,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "${data.buyQuantity}个宝宝学习",
                        style: TextStyle(
                          fontSize: 20.wMin,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.cTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IgnorePointer(
                  ignoring: data.data.disable == true,
                  child: Row(
                    children: [
                      Opacity(
                        opacity: data.data.disable == true ? 0.6 : 1,
                        child: TapScaleWidget(
                          sclae: 1.05,
                          child: _buildASIconWidget(false),
                          onTap: () {
                            controller.reduceStudentCount(index);
                          },
                        ),
                      ),
                      Container(
                        width: 156.wMin,
                        alignment: Alignment.center,
                        child: Text(
                          "${data.buyQuantity}",
                          style: TextStyle(
                            fontSize: 36.wMin,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.cTextPrimary,
                          ),
                        ),
                      ),
                      Opacity(
                        opacity: data.data.disable == true ? 0.6 : 1,
                        child: TapScaleWidget(
                          sclae: 1.05,
                          child: _buildASIconWidget(true),
                          onTap: () {
                            controller.addStudentCount(index);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 22.wMin),
                Obx((){
                  if(data.buyQuantity.value == data.freeQuantity){
                    return Text(
                      publicity.isNotEmpty ? publicity.first?.text??"" : "",
                      style: publicity.isNotEmpty ? StyleUtils.getTextStyle(
                        publicity.first?.textStyles,
                        defaultColor: AppTheme.cTextPrimary,
                        defaultSize: 20.wMin,
                      ) : null,
                    );
                  }

                  int studentCount = data.buyQuantity.value - data.freeQuantity;
                  String price = NumberUtils.formatNumberWithCommas(data.price * studentCount / 100);

                  int buyQuantity = data.buyQuantity.value;
                  String showPrice = NumberUtils.formatNumberWithCommas(data.priceOriginal / 100);
                  String result = NumberUtils.formatNumberWithCommas(data.priceOriginal * buyQuantity / 100);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "$price 乃币",
                        style: TextStyle(
                          fontSize: 28.wMin,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.cFeedbackErrorText,
                        ),
                      ),
                      Visibility(
                        visible: price != result,
                        child: Text(
                          "$showPrice×$buyQuantity=$result",
                          style: TextStyle(
                            fontSize: 20.wMin,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.cTextSecondary,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: AppTheme.cTextSecondary,
                          ),
                        ),
                      ),
                    ],
                  );
                }),

              ],
            ),
          ],
        ),
      ],
    );
  }

  /// 购买席位的时长选择
  Widget _buildBuySeatDurationWidget(){
    if(controller.servicePackage.value.isVipRenewal) return Container();
    if(!controller.isBuySeat) return Container();
    return Obx((){
      List<BuySeatPackageEntityList?> buySeatPackageList = controller.buySeatPackageList;
      if(buySeatPackageList.isEmpty) return Container();
      int selectBuySeatPackageId = controller.selectBuySeatPackageId.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 32.wMin),
          Text(
            "选择时长",
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          SizedBox(height: 8.wMin),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 16.wMin,
              children: List.generate(buySeatPackageList.length, (index){

                String priceOriginal = NumberUtils.formatNumberWithCommas((buySeatPackageList[index]?.price??0) / 100);
                return TapScaleWidget(
                  onTap: () {
                    controller.selectBuySeatPackage(buySeatPackageList[index]);
                  },
                  sclae: 1,
                  child: Container(
                    width: 348.wMin,
                    height: 124.wMin,
                    padding: EdgeInsets.all(16.wMin),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.wMin),
                      color: AppTheme.cSurfaceTertiary.color,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                buySeatPackageList[index]?.name??"",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 28.wMin,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.cTextPrimary.color,
                                ),
                              ),
                            ),
                            SvgPicture.asset(
                              selectBuySeatPackageId == buySeatPackageList[index]?.uid
                              ? "assets/svg/public/icon_radio.svg"
                              : "assets/svg/public/icon_radio_un.svg",
                              width: 32.wMin,
                            ),
                          ],
                        ),
                        SizedBox(height: 8.wMin),
                        Text(
                          "$priceOriginal乃币",
                          style: TextStyle(
                            fontSize: 20.wMin,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.cTextTertiary.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      );
    });
  }

  /// 选择学员
  Widget _buildSelectStudentListWidget(ExtraPurchaseModel data, int packIndex){
    if(!controller.servicePackage.value.isVipRenewal) return Container();
    if(controller.traineeId != null) return Container();

    List<PackageShopDetailEntityServicePackageSubExtendTrainees?> trainees = data.data.subExtend?.trainees??[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildTextTitleWidget(data.data.title??""),
            SizedBox(width: 4.wMin),
            Text(
              data.data.describe??"",
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextSecondary,
              ),
            ),
          ],
        ),
        
        SizedBox(height: 10.wMin),
        
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12.wMin,
          children: List.generate(trainees.length, (index){
            return _buildSelectStudentListItemWidget(trainees[index], packIndex, index);
          }),
        ),

      ],
    );
  }

  Widget _buildSelectStudentListItemWidget(PackageShopDetailEntityServicePackageSubExtendTrainees? trainee, int packIndex, int index){
    String expired = DateFormatUtil.formatStrtoStr(trainee?.expired?.end);
    bool isExpired = trainee?.isExpired??false;

    String nameText = trainee?.nickname??"";
    if((trainee?.traineeId??0) == 0){
      nameText = "新席位";
    }else if(trainee?.memberUserId == null){
      nameText = "待分配学员";
    }

    return TapScaleWidget(
      onTap: () {
        if(trainee?.traineeId == null) return;
        controller.selectTrainee(trainee!.traineeId!, packIndex, index);
      },
      sclae: 1,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 12.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.wMin),
          border: Border.all(width: 1.wMin, color: AppTheme.cBorderSecondary.color),
          color: Colors.transparent,
        ),
        child: Row(
          children: [

            ClipOval(
              child: SizedBox(
                width: 64.wMin,
                height: 64.wMin,
                child: CachedImageWidget(
                  trainee?.avatarUrl??"",
                  placeholder: SvgPicture.asset(
                    "assets/svg/public/icon_user.svg",
                    height: 80.wMin,
                    width: 80.wMin,
                  ),
                  errorWidget: SvgPicture.asset(
                    "assets/svg/public/icon_user.svg",
                    height: 80.wMin,
                    width: 80.wMin,
                  ),
                ),
              ),
            ),

            SizedBox(width: 12.wMin),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nameText,
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Visibility(
                  visible: expired.isNotEmpty,
                  child: Row(
                    children: [
                      Text(
                        "到期时间：$expired",
                        style: TextStyle(
                          fontSize: 18.wMin,
                          color: isExpired ? AppTheme.cSurfaceError.color : AppTheme.cTextSecondary.color,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Visibility(
                        visible: isExpired,
                        child: Text(
                          "（已过期）",
                          style: TextStyle(
                            fontSize: 18.wMin,
                            color: AppTheme.cSurfaceError.color,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
              ],
            ),

            const Spacer(),

            Obx((){
              bool isSelected = controller.selectTraineeIndexes.contains(index);

              return SvgPicture.asset(
                isSelected ? "assets/svg/public/icon_check_b.svg" : "assets/svg/public/icon_uncheck_box.svg", //icon_uncheck_box.svg
                width: 32.wMin,
              );
            }),

          ],
        ),
      ),
    );
  }




  Widget _buildASIconWidget(bool isAdd){
    String svg = "assets/svg/user_center/icon_ninus.svg";
    Color buttonColor = AppTheme.cBgTertiary.color;
    Color textColor = AppTheme.cTextPrimary.color;
    if(isAdd){
      svg = "assets/svg/user_center/icon_plus.svg";
      buttonColor = AppTheme.cBgBrand.color;
      textColor = AppTheme.cStaticWhite.color;
    }
    return Container(
      width: 55.wMin,
      height: 55.wMin,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: buttonColor,
        shape: BoxShape.circle,
      ),
      child: SvgPicture.asset(
        svg,
        width: 36.wMin,
        height: 36.wMin,
        colorFilter: ColorFilter.mode(
          textColor,
          BlendMode.srcIn,
        ),
      ),
    );
  }

  Widget _buildTextTitleWidget(String text){
    return Text(
      text,
      style: TextStyle(
        fontSize: 24.wMin,
        fontWeight: FontWeight.w500,
        color: AppTheme.cTextPrimary,
      ),
    );
  }






}