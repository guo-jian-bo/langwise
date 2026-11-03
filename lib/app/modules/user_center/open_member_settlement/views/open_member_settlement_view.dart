

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/common/stores/stores.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../utils/utils.dart';
import '../../../../routes/routes.dart';
import '../bindings/open_member_settlement_binding.dart';
import '../controllers/open_member_settlement_controller.dart';
import 'open_member_settlement_student_widget.dart';

class OpenMemberSettlementView extends GetView<OpenMemberSettlementController> {
  final String tagText;
  const OpenMemberSettlementView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      () => OpenMemberSettlementView(tagText: tag),
      binding: OpenMemberSettlementBinding(tagText: tag),
      routeName: Routes.OPEN_MEMBER_SETTLEMENT,
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
            child: Container(
              alignment: Alignment.topCenter,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 24.wMin,
              ),
              child: SizedBox(
                width: 1680.wMin,
                child: Obx((){
                  if(controller.packageShopDetail.value.servicePackage == null) return Container();
                  return Row(
                    spacing: 16.wMin,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMemberInfoWidget(context),
                      Expanded(child: _buildOrderSummaryWidget(context)),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberInfoWidget(BuildContext context){
    return Container(
      width: 1112.wMin,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.wMin),
        color: AppTheme.cBgSecondary,
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.wMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMemberChangeModelWidget(),

            OpenMemberSettlementStudentWidget(controller: controller),
            
            _buildCouponModelWidget(),
            
            SizedBox(height: 32.wMin),
            _buildUpgradeCalculateWidget(),
          ],
        ),
      ),
    );
  }

  /// 订单概括
  Widget _buildOrderSummaryWidget(BuildContext context){
    return Obx((){
      PackageShopDetailEntityServicePackage? servicePackage = controller.servicePackage.value;
      MemberLevelColor memberColors = StatusUtils.getMemberColorsByVipConfigs(UserStore.to.userInfo.value.vipConfigs, servicePackage.title);

      String priceOriginal = NumberUtils.formatNumberWithCommas((servicePackage.priceOriginal??0) / 100);
      String price = NumberUtils.formatNumberWithCommas((servicePackage.price??0) / 100);

      // String member = controller.servicePackage.value.title??"";
      // String changeName = controller.servicePackage.value.changeName??"";
      String? durationEnd = DateFormatUtil.formatStrtoStr(controller.servicePackage.value.durationEnd);


      /// 使用优惠券情况
      List<PackageShopDetailEntityServicePackageCouponEffects> couponEffects = controller.couponEffects;

      int packagePriceOriginal = servicePackage.priceOriginal??0;
      int allPrice = controller.payTotalPrice.value;
      int extraPriceOriginal = 0;
      for(int i = 0; i < controller.extraPurchases.length; i++){
        extraPriceOriginal += controller.extraPurchases[i].totalPriceOriginal.value;
      }
      int extraPriceInt = packagePriceOriginal + extraPriceOriginal - allPrice;
      String payReducePriceStr = NumberUtils.formatNumberWithCommas(extraPriceInt / 100);

      return Container(
        padding: EdgeInsets.all(16.wMin),
        alignment: Alignment.topCenter,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.wMin),
          color: AppTheme.cBgSecondary,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 16.wMin),
              _buildTextTitleWidget("订单概括"),
              Visibility(
                visible: !controller.isBuySeat,
                child: Container(
                  margin: EdgeInsets.only(top: 32.wMin),
                  child: Text(
                    "${servicePackage.title??''} ${servicePackage.describe??""}",
                    style: TextStyle(
                      fontSize: 24.wMin,
                      fontWeight: FontWeight.w600,
                      color: memberColors.pale,
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: !controller.isBuySeat,
                child: Container(
                  margin: EdgeInsets.only(top: 32.wMin),
                  child: Row(
                    children: [
                      Text(
                        "${servicePackage.durationTitle??''}付",
                        style: TextStyle(
                          fontSize: 18.wMin,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.cTextSecondary,
                        ),
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Visibility(
                            visible: servicePackage.originalPrice != null && priceOriginal != price,
                            child: Text(
                              "$priceOriginal 乃币",
                              style: TextStyle(
                                fontSize: 18.wMin,
                                fontWeight: FontWeight.w400,
                                color: AppTheme.cTextSecondary,
                                decoration: TextDecoration.lineThrough,
                                decorationColor: AppTheme.cTextSecondary,
                              ),
                            ),
                          ),
                          Text(
                            "$price 乃币",
                            style: TextStyle(
                              fontSize: 18.wMin,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.cTextPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
                
              Visibility(
                visible: couponEffects.isNotEmpty,
                child: Container(
                  margin: EdgeInsets.only(top: 16.wMin),
                  padding: EdgeInsets.all(6.wMin),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.wMin),
                    color: AppTheme.cFeedbackErrorBackground,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "使用优惠券后：",
                        style: TextStyle(
                          fontSize: 16.wMin,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.cFeedbackErrorText,
                        ),
                      ),
                      SizedBox(height: 4.wMin),
                      Column(
                        children: List.generate(couponEffects.length, (index){
                          return Row(
                            children: [
                              Text(
                                couponEffects[index].title??"",
                                style: TextStyle(
                                  fontSize: 18.wMin,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.cTextPrimary,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                couponEffects[index].describe??"",
                                style: TextStyle(
                                  fontSize: 18.wMin,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.cFeedbackErrorText,
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              
              _buildExtraPurchasesWidget(),
                
              Visibility(
                visible: extraPriceInt > 0 && !controller.isBuySeat,
                child: Column(
                  children: [
                    SizedBox(height: 16.wMin),
                    Container(height: 0.5.wMin, color: AppTheme.cBorderPrimary),
                    SizedBox(height: 16.wMin),
                    Row(
                      children: [
                        Text(
                          "节省金额",
                          style: TextStyle(
                            fontSize: 18.wMin,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.cFeedbackSuccessText,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "$payReducePriceStr 乃币",
                          style: TextStyle(
                            fontSize: 18.wMin,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.cFeedbackSuccessText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.wMin),
              Container(height: 0.5.wMin, color: AppTheme.cBorderPrimary),
              SizedBox(height: 16.wMin),
                
                
              Visibility(
                visible: controller.selectCouponIds.isNotEmpty,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "优惠券",
                          style: TextStyle(
                            fontSize: 18.wMin,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.cFeedbackErrorText,
                          ),
                        ),
                        SizedBox(width: 10.wMin),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(controller.selectCouponIds.length, (index){
                              int id = controller.selectCouponIds[index];
                              PackageShopDetailEntityCoupons? selectData;
                              for(int i = 0; i < controller.couponList.length; i++){
                                if(controller.couponList[i].couponId == id){
                                  selectData = controller.couponList[i];
                                  break;
                                }
                              }
                              if(selectData == null) return Container();
                              Color couponColor = StatusUtils.getCouponColor(selectData.type);
                              return Text(
                                selectData.title??"",
                                style: TextStyle(
                                  fontSize: 18.wMin,
                                  fontWeight: FontWeight.w600,
                                  color: couponColor,
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.wMin),
                    Container(height: 0.5.wMin, color: AppTheme.cBorderPrimary),
                  ],
                ),
              ),
                
                
              
              SizedBox(height: 16.wMin),
              Row(
                children: [
                  Text(
                    "总计",
                    style: TextStyle(
                      fontSize: 24.wMin,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.cTextPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text( 
                    "${NumberUtils.formatNumberWithCommas(controller.payTotalPrice.value / 100)} 乃币",
                    style: TextStyle(
                      fontSize: 24.wMin,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.cTextPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.wMin),

              Text.rich(TextSpan(
                style: TextStyle(
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextTertiary,
                ),
                children: [
                  TextSpan(
                    text: controller.isBuySeat ? "席位到期时间为 " : "会员到期时间为",
                  ),
                  TextSpan(
                    text: durationEnd,
                    style: const TextStyle(
                      color: AppTheme.cFeedbackErrorText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ]
              )),

              SizedBox(height: 10.wMin),
              _buildBalanceWidget(context),
              SizedBox(height: 36.wMin),

              Obx((){
                // 总金额
                int payTotalPrice = controller.payTotalPrice.value;
                // 用户余额
                int credit = UserStore.to.userInfo.value.credit??0;
                
                // 是否余额不足
                bool isBalanceNotEnough = payTotalPrice > credit;

                return ButtonWidget(
                  text: isBalanceNotEnough ? "余额不足，去充值" : "继续结算",
                  color: isBalanceNotEnough ? AppTheme.cSurfaceError : AppTheme.cBgBrand,
                  width: double.infinity,
                  height: 64.wMin,
                  fontColor: AppTheme.cStaticWhite,
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w500,
                  borderRadius: 8.wMin,
                  sclae: 1.02,
                  onTap: () {
                    if(isBalanceNotEnough){
                      controller.toRecharge(context, isContinue: true);
                    }else{
                      controller.settlement(context);
                    }
                    
                  },
                );
              }),

              _buildPrivateWidget(),
                
              
            ],
          ),
        ),
      );
    });
  }
  

  /// 额外购买
  Widget _buildExtraPurchasesWidget(){

    int duration = controller.packageShopDetail.value.servicePackage?.duration??0;
    String durationTypeTitle = controller.packageShopDetail.value.servicePackage?.durationTypeTitle??"";

    return Column(
      children: List.generate(controller.extraPurchases.length, (index){

        ExtraPurchaseModel data = controller.extraPurchases[index];
        PackageShopDetailEntityServicePackageRights dataInfo = controller.extraPurchases[index].data;

        String totalPrice = NumberUtils.formatNumberWithCommas(data.totalPrice.value / 100);
        
        String result = NumberUtils.formatNumberWithCommas(data.totalPriceOriginal.value / 100);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.wMin),
            Text(
              dataInfo.title??"",
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cTextPrimary,
              ),
            ),
            SizedBox(height: 4.wMin),
            Row(
              children: [
                Text(
                  "$duration$durationTypeTitle付×${data.buyQuantity.value}",
                  style: TextStyle(
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextSecondary,
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Visibility(
                      visible: result != totalPrice,
                      child: Text(
                        "$result 乃币",
                        style: TextStyle(
                          fontSize: 18.wMin,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.cTextSecondary,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: AppTheme.cTextSecondary,
                        ),
                      ),
                    ),
                    Text(
                      data.totalPrice.value == 0 ? "免费" : "$totalPrice 乃币",
                      style: TextStyle(
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.cTextPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      }),
    );

  }

  Widget _buildBalanceWidget(BuildContext context){
    return Row(
      children: [
        Text(
          "乃币余额",
          style: TextStyle(
            fontSize: 20.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextPrimary,
          ),
        ),
        SizedBox(width: 12.wMin),
        Obx((){
          int credit = UserStore.to.userInfo.value.credit??0;
          String creditStr = NumberUtils.formatNumberWithCommas(credit / 100);
          return Text(
            creditStr,
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w600,
              color: AppTheme.cFeedbackErrorText,
            ),
          );
        }),
        const Spacer(),
        ButtonWidget(
          text: "充值",
          padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 4.wMin),
          borderRadius: 8.wMin,
          border: Border.all(width: 1.wMin, color: AppTheme.cFeedbackErrorBorder),
          fontSize: 24.wMin,
          fontColor: AppTheme.cFeedbackErrorText,
          color: Colors.transparent,
          sclae: 1.05,
          onTap: () {
            controller.toRecharge(context);
          },
        ),
      ],
    );
  }

  Widget _buildPrivateWidget(){
    return Container(
      alignment: Alignment.center,
      child: TapScaleWidget(
        onTap: () {
          controller.agreementProtocol.value = !controller.agreementProtocol.value;
        },
        sclae: 1,
        child: Container(
          color: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: 24.wMin),
          child: Row(
            spacing: 8.wMin,
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx((){
                return AnimatedSwitcher(
                duration: const Duration(milliseconds: 100),
                  child: SvgPicture.asset(
                    controller.agreementProtocol.value ? "assets/svg/public/icon_radio.svg" : "assets/svg/public/icon_radio_un.svg",
                    key: ValueKey(controller.agreementProtocol.value),
                    width: 24.wMin,
                    height: 24.wMin,
                  ),
                );
              }),
              Text.rich(TextSpan(
                style: TextStyle(
                  color: AppTheme.cTextSecondary,
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                  height: 1,
                ),
                children: [
                  const TextSpan(text: '阅读并同意'),
                  TextSpan(
                    text: '《会员服务协议》',
                    style: const TextStyle(color: AppTheme.cTextBrand),
                    recognizer: TapGestureRecognizer()..onTap = () {
                      controller.toMemberProtocol();
                    },
                  ),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }

  /// 升级计算方法
  Widget _buildUpgradeCalculateWidget(){
    if(controller.isBuySeat) return Container();
    return Obx((){
      PackageShopDetailEntityPriceBreakdown? priceBreakdown = controller.servicePackage.value.priceBreakdown;
      if(priceBreakdown == null) return Container();
      List<PackageShopDetailEntityPriceBreakdownSteps?> steps = priceBreakdown.steps??[];
      PackageShopDetailEntityPriceBreakdownConclusion? conclusion = priceBreakdown.conclusion;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextTitleWidget("升级计算"),
          SizedBox(height: 16.wMin),
          Container(
            padding: EdgeInsets.all(24.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.wMin),
              color: AppTheme.cBgTertiary,
              border: Border.all(width: 0.5.wMin, color: AppTheme.cBorderPrimary),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  priceBreakdown.title??"",
                  style: TextStyle(
                    fontSize: 28.wMin,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.cFeedbackWarningText,
                  ),
                ),
                SizedBox(height: 8.wMin),

                Column(
                  spacing: 4.wMin,
                  children: List.generate(steps.length, (index){
                    if(steps[index] == null) return Container();
                    return _buildRowTextWidget(steps[index]?.title??"", [steps[index]?.value]);
                  }),
                ),
                SizedBox(height: 24.wMin),
                Container(height: 1.wMin, color: AppTheme.cBorderPrimary),
                SizedBox(height: 24.wMin),
                Row(
                  children: [
                    Text(
                      conclusion?.title??"",
                      style: TextStyle(
                        fontSize: 20.wMin,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.cFeedbackWarningText,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      conclusion?.value??"",
                      style: TextStyle(
                        fontSize: 20.wMin,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.cFeedbackWarningText,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.wMin),
                Text(
                  priceBreakdown.describe??"",
                  style: TextStyle(
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  /// 使用优惠券
  Widget _buildCouponModelWidget(){

    return Obx((){
      if(controller.couponList.isEmpty) return Container();
      return Container(
        margin: EdgeInsets.only(top: 32.wMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextTitleWidget("使用优惠券"),
            SizedBox(height: 16.wMin),
            Column(
              spacing: 10.wMin,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(controller.couponList.length, (index){
                return _buildCouponModelItem(controller.couponList[index]);
              }),
            ),
          ],
        ),
      );
    });

  }

  /// 优惠券item
  Widget _buildCouponModelItem(PackageShopDetailEntityCoupons data){
    int couponId = data.couponId??0;

    Color couponColor = StatusUtils.getCouponColor(data.type);

    List<PackageShopDetailEntityCouponsBenefits?> benefits = data.benefits??[];

    DateTime? date = DateFormatUtil.tryParseDate(data.expired);
    String expiredText = "";
    if(date != null){
      expiredText = DateFormatUtil.formatLocale(date, locale: Get.locale);
    }

    return TapScaleWidget(
      onTap: (){
        controller.selectCoupon(couponId);
      },
      sclae: 1,
      child: Container(
        padding: EdgeInsets.all(24.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cBgTertiary,
          border: Border.all(width: 0.5.wMin, color: AppTheme.cBorderPrimary),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  data.title??"",
                  style: TextStyle(
                    fontSize: 28.wMin,
                    fontWeight: FontWeight.w600,
                    color: couponColor, // 应该是动态颜色
                  ),
                ),
                Obx((){
                  return SvgPicture.asset(
                    controller.selectCouponIds.contains(couponId) ? "assets/svg/public/icon_radio.svg" : "assets/svg/public/icon_radio_un.svg",
                    width: 24.wMin,
                    height: 24.wMin,
                  );
                }),
              ],
            ),
            SizedBox(height: 4.wMin),
            Text(
              data.describe??"",
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextSecondary,
              ),
            ),
            Visibility(
              visible: data.expired?.isNotEmpty??false,
              child: Text(
                "$expiredText 到期",
                style: TextStyle(
                  fontSize: 16.wMin,
                  color: AppTheme.cTextTertiary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            
            Obx((){
              if(!controller.selectCouponIds.contains(couponId)) return Container();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.wMin),
                  Container(height: 0.5.wMin, color: AppTheme.cBorderPrimary),
                  Container(
                    padding: EdgeInsets.all(12.wMin),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "优惠详情",
                          style: TextStyle(
                            fontSize: 18.wMin,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.cTextSecondary,
                          ),
                        ),
                        SizedBox(height: 4.wMin),
                        Column(
                          children: List.generate(benefits.length, (index){
                            return _buildRowTextWidget(benefits[index]?.category??"", benefits[index]?.items??[]);
                          }),
                        ),
                        SizedBox(height: 6.wMin),
                        Text(
                          data.tip??"",
                          style: TextStyle(
                            fontSize: 16.wMin,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.cTextTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
  /// 会员变更
  Widget _buildMemberChangeModelWidget(){
    return Obx((){
      PackageShopDetailEntityServicePackage? servicePackage = controller.servicePackage.value;
      PackageShopDetailEntityServicePackageCurrentService? currentService = servicePackage.currentService;
      // List<PackageShopDetailEntityServicePackagePublicity?>? publicity = servicePackage.publicity;
      List<PackageShopDetailEntityServicePackagePublicity?>? currentPublicity = currentService?.publicity;

      List<PackageShopDetailEntityServicePackageCorners?> corners = servicePackage.corners??[];

      String durationEnd = servicePackage.durationEnd??"";
      DateTime? endDate = DateFormatUtil.tryParseDate(durationEnd);
      String? endDateStr = DateFormatUtil.formatStrtoStr(durationEnd, locale: Get.locale);
      DateTime nowDate = DateTime.now();
      int days = endDate?.difference(nowDate).inDays??0;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.wMin),
          _buildTextTitleWidget(controller.isCompletionPrice?"会员补齐":"会员变更"),
          SizedBox(height: 16.wMin),
          IntrinsicHeight(
            child: Row(
              children: [
                _buildMemberCardWidget(
                  currentService?.title??"", 
                  currentService?.describe??"", 
                  List.generate(currentPublicity?.length??0, (index){
                    return currentPublicity?[index]?.text??"";
                  }),
                ),
                const Spacer(),
                Visibility(
                  visible: !controller.isBuySeat,
                  child: Column(
                    spacing: 12.wMin,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 36.wMin,
                        height: 36.wMin,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.cFeedbackDefaultBackground,
                        ),
                        child: SvgPicture.asset(
                          "assets/svg/user_center/icon_arrow_right.svg",
                          width: 28.wMin,
                          height: 28.wMin,
                        ),
                      ),
                      Text(
                        servicePackage.changeName??"",
                        style: TextStyle(
                          fontSize: 16.wMin,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.cTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Visibility(
                  visible: !controller.isBuySeat,
                  child: _buildMemberCardWidget(
                    servicePackage.title??"", 
                    servicePackage.describe??"", 
                    [
                      "到期时间：$endDateStr", 
                      "剩余天数：$days 天",
                    ],
                    corners: corners,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }


  

  Widget _buildMemberCardWidget(
    String member, 
    String subName, 
    List<String> texts, {
      List<PackageShopDetailEntityServicePackageCorners?>? corners,
    }){
    MemberLevelColor memberColors = StatusUtils.getMemberColorsByVipConfigs(UserStore.to.userInfo.value.vipConfigs, member);

    return Container(
      width: 440.wMin,
      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 14.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        gradient: LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            memberColors.deep,
            memberColors.pale,
          ],
        ),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                member,
                style: TextStyle(
                  fontSize: 36.wMin,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.cStaticWhite,
                  height: 1.2,
                ),
              ),
              Text(
                subName,
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.cStaticWhite,
                ),
              ),
              SizedBox(height: 16.wMin),
              Visibility(
                visible: texts.isNotEmpty,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(texts.length, (index){
                    return Text(
                      texts[index],
                      style: TextStyle(
                        fontSize: 14.wMin,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.cStaticWhite,
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),

          Positioned(
            right: 0,
            top: 0,
            child: Column(
              children: List.generate(corners?.length??0, (index){
                PackageShopDetailEntityServicePackageCorners? corner = corners?[index];
                if(corner == null) return Container();
                ThemeColorEntity? themeColor = StyleUtils.getCurrentThemeColors(corner.bgColors);
                Color? bgColor = ColorUtils.parseColor(themeColor?.color);

                return Transform.rotate(
                  angle: 0.1,
                  child: Container(
                    margin: EdgeInsets.only(top: 4.wMin),
                    padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(4.wMin),
                    ),
                    child: Text(
                      corner.text??"",
                      style: StyleUtils.getTextStyle(
                        corner.textStyles,
                        defaultColor: AppTheme.cStaticWhite.color,
                        defaultSize: 12,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

        ],
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

  Widget _buildRowTextWidget(String name, List<String?> values){
    List<String> texts = [];
    for(String? value in values){
      if(value != null){
        texts.add(value);
      }
    }
    return Row(
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextSecondary,
          ),
        ),
        const Spacer(),
        Text(
          texts.join("、"),
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextSecondary,
          ),
        ),
      ],
    );
  }


}
