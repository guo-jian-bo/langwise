import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/stores/stores.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../../../../routes/routes.dart';
import '../bindings/recharge_naibi_binding.dart';
import '../controllers/recharge_naibi_controller.dart';
import 'package:ui_essentials/ui_essentials.dart';

class RechargeNaibiView extends GetView<RechargeNaibiController> {
  final String tagText;
  const RechargeNaibiView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      RechargeNaibiView(tagText: tag),
      binding: RechargeNaibiBinding(tagText: tag),
      routeName: Routes.RECHARGE_NAIBI,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary,
      body: Container(
        alignment: Alignment.topCenter,
        child: Container(
          width: 1680.wMin,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 40.wMin,
          ),
          child: Column(
            children: [
              const BackWidget(title: "充值乃币"),
              Expanded(
                child: SizedBox(
                  width: 1220.wMin,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 10.wMin),
                    child: Column(
                      children: [
                        _buildBalanceWidget(),
                        SizedBox(height: 48.wMin),
                        _buildProductWidget(context),
                        SizedBox(height: 24.wMin),
                        _buildDescribeWidget(),
                        SizedBox(height: MediaQuery.of(context).padding.bottom + 24.wMin),
                      ],
                    ),
                  ),
                ),
              ), 
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildPayTypeWidget(context),
    );
  }

  Widget _buildPayTypeWidget(BuildContext context){
    
    return Container(
      color: AppTheme.cBgSecondary,
      width: double.infinity,
      height: 110.wMin + MediaQuery.of(context).padding.bottom,
      alignment: Alignment.center,
      padding: EdgeInsets.only(
        top: 16.wMin,
        bottom: MediaQuery.of(context).padding.bottom + 16.wMin,
      ),
      child: SizedBox(
        width: 1680.wMin,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              spacing: 24.wMin,
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildPayButtonList(context),
            ),
            // SizedBox(height: 8.wMin),
            // TapScaleWidget(
            //   onTap: () {
            //     controller.isChecked.value = !controller.isChecked.value;
            //   },
            //   sclae: 1,
            //   child: Container(
            //     padding: EdgeInsets.symmetric(vertical: 16.wMin),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       spacing: 16.wMin,
            //       children: [
            //         Obx((){
            //           return AnimatedSwitcher(
            //           duration: const Duration(milliseconds: 100),
            //             child: SvgPicture.asset(
            //               controller.isChecked.value ? "assets/svg/public/icon_radio.svg" : "assets/svg/public/icon_radio_un.svg",
            //               key: ValueKey(controller.isChecked.value),
            //               width: 24.wMin,
            //               height: 24.wMin,
            //             ),
            //           );
            //         }),
            //         Text.rich(TextSpan(
            //           style: TextStyle(
            //             color: AppTheme.cTextSecondary,
            //             fontSize: 24.wMin,
            //             fontWeight: FontWeight.w400,
            //             height: 1,
            //           ),
            //           children: [
            //             const TextSpan(text: '阅读并同意'),
            //             TextSpan(
            //               text: '《会员服务协议》',
            //               style: const TextStyle(color: AppTheme.cTextBrand),
            //               recognizer: TapGestureRecognizer()..onTap = () {
            //                 controller.jumpToMemberProtocol();
            //               },
            //             ),
            //             const TextSpan(text: '，开通前需要确认账号，权益到账后无法更改'),
            //           ],
            //         )),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPayButtonList(BuildContext context){
    List<Widget> list = [];
    if(Platform.isIOS) {
      list.add(Expanded(// 苹果支付
        child: TapScaleWidget(
          onTap: () {
            controller.callPay(context, 3);
          },
          sclae: 1.01,
          child: _buildPayTypeButtonWidget(
            Text(
              "支付",
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cStaticBlack,
              ),
            ),
            AppTheme.cStaticWhite,
          ),
        ),
      ));
    }
    if(UserStore.to.userInfo.value.review == 1 && Platform.isIOS) return list;

    if(!Platform.isIOS){
      list.add(Expanded( //支付宝支付
        child: TapScaleWidget(
          onTap: () {
            controller.callPay(context, 1);
          },
          sclae: 1.01,
          child: _buildPayTypeButtonWidget(
            SvgPicture.asset("assets/svg/user_center/icon_ali_pay.svg", height: 38.wMin),
            AppTheme.cStaticWhite,
          ),
        ),
      ));
    }

    // list.add(Expanded( //微信支付
    //   child: TapScaleWidget(
    //     onTap: () {
    //       controller.callPay(context, 2);
    //     },
    //     sclae: 1.01,
    //     child: _buildPayTypeButtonWidget(
    //       SvgPicture.asset("assets/svg/user_center/icon_wx_pay.svg", height: 38.wMin),
    //       AppTheme.cStaticWhite,
    //     ),
    //   ),
    // ));

    list.add(Expanded( //兑换乃币卡
      child: TapScaleWidget(
        onTap: () {
          controller.getExchangeCard(context);
        },
        sclae: 1.01,
        child: _buildPayTypeButtonWidget(
          Text(
            "兑换乃币卡",
            style: TextStyle(
              fontSize: 28.wMin,
              fontWeight: FontWeight.w600,
              color: AppTheme.cStaticBlack,
            ),
          ),
          AppTheme.cStaticWhite,
        ),
      ),
    ));

    return list;
  }

  Widget _buildPayTypeButtonWidget(Widget body, Color bgColor){
    return TapScaleWidget(
      child: Container(
        width: 384.wMin,
        height: 72.wMin,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.wMin),
          color: bgColor,
          border: Border.all(width: 1.wMin, color: AppTheme.cBorderDisabled),
        ),
        child: body,
      ),
    );
  }

  Widget _buildDescribeWidget(){
    return SizedBox(
      width: double.infinity,
      child: Obx((){
        if(controller.describeList.isEmpty) return Container();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.productInfo.value.title??"",
              style: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextPrimary,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(controller.describeList.length, (index){
                return _buildDescribItem(controller.describeList[index]);
              }),
            ),
          ],  
        );
      }),
    );
  }

  Widget _buildDescribItem(ProductInfoEntityDescribes data){
    return Text(
      data.text??"",
      style: TextStyle(
        fontSize: 24.wMin,
        fontWeight: FontWeight.w400,
        color: AppTheme.cTextSecondary,
      ),
    );
  }

  Widget _buildProductWidget(BuildContext context) {

    return Obx((){
      return GridView.builder(
        itemCount: controller.productList.length,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 46.wMin,
          crossAxisSpacing: 24.wMin,
          childAspectRatio:  369 / 159,
        ),
        itemBuilder: (context, index) {
          // return _buildProductItem(ProductInfoEntityList(
          //   name: "乃币19.90",
          //   price: 1990,
          // ), index);
          return _buildProductItem(controller.productList[index], index);
        },
      );
    });
  }

  Widget _buildProductItem(ProductInfoEntityList data, int index){
    int? price = data.price;
    String priceStr = "";
    if(price != null) {
      priceStr = "${NumberUtils.formatNumberWithCommas((price) / 100)}元";
    }

    return TapScaleWidget(
      onTap: price == null ? null : () {
        controller.selectedProductIndex.value = index;
      },
      sclae: 1.01,
      child: Obx((){
        return AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(24.wMin),
            border: Border.all(
              color: controller.selectedProductIndex.value == index ? const Color(0xffEA580C) : AppTheme.cBorderPrimary,
              width: 2.wMin,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                data.name??"",
                style: TextStyle(
                  fontSize: 48.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextSecondary,
                ),
              ),
        
              Text(
                priceStr,
                style: TextStyle(
                  fontSize: 28.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextTertiary,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }


  /// 余额
  Widget _buildBalanceWidget() {

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8.wMin,
          children: [
            Obx((){
              int credit = UserStore.to.userInfo.value.credit??0;
              return Text(
                NumberUtils.formatNumberWithCommas(credit / 100),
                style: TextStyle(
                  fontSize: 64.wMin,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.cTextPrimary,
                ),
              );
            }),
            Text(
              "乃币",
              style: TextStyle(
                fontSize: 40.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cTextPrimary,
              ),
            ),
          ],
        ),
        Text(
          "乃币余额",
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cFeedbackInfoText,
          ),
        ),
      ],
    );
  }

}
