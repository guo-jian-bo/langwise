import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/stores/stores.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../controllers/recharge_point_controller.dart';

class RechargePointView extends GetView<RechargePointController> {
  const RechargePointView({super.key});

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
              const BackWidget(title: "充值学点"),
              Expanded(
                child: SizedBox(
                  width: 1300.wMin,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 10.wMin),
                    child: Column(
                      children: [
                        Obx((){
                          int points = UserStore.to.userInfo.value.points??0;
                          int credit = UserStore.to.userInfo.value.credit??0;
                          String creditStr = NumberUtils.formatNumberWithCommas(credit / 100);
                          return Row(
                            spacing: 24.wMin,
                            children: [
                              _buildBalanceWidget(
                                backColor: AppTheme.cLearnSomethingPrimary,
                                title: "学点余额",
                                value: points.toString(),
                                type: 1,
                              ),
                              _buildBalanceWidget(
                                backColor: AppTheme.cNsCoinBgPrimary,
                                title: "乃币余额",
                                value: creditStr,
                                type: 2,
                              ),
                            ],
                          );
                        }),
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
        width: 1300.wMin,
        child: Row(
          spacing: 24.wMin,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 4,
              child: ButtonWidget(
                text: "去充值乃币",
                height: 72.wMin,
                fontSize: 28.wMin,
                color: AppTheme.cBgQuaternary,
                fontWeight: FontWeight.w600,
                fontColor: AppTheme.cTextPrimary,
                borderRadius: 8.wMin,
                sclae: 1.01,
                onTap: () {
                  controller.toRechargeNaibi();
                },
              ),
            ),

            Expanded(
              flex: 6,
              child: Obx((){
                int select = controller.selectedProductIndex.value;
                String priceStr = "";
                if(select != -1) {
                  int price = controller.productInfoList[select].price??0;
                  priceStr = "(${NumberUtils.formatNumberWithCommas((price) / 100)}乃币)";
                }
                return ButtonWidget(
                  text: "确认充值$priceStr",
                  height: 72.wMin,
                  fontSize: 28.wMin,
                  color: AppTheme.cSurfaceBrand,
                  fontWeight: FontWeight.w600,
                  fontColor: AppTheme.cStaticWhite,
                  borderRadius: 8.wMin,
                  sclae: 1.005,
                  onTap: () {
                    controller.pay(context);
                  },
                );
              }),
            ),
          ],
        ),
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

  Widget _buildDescribItem(ProductPointsEntityDescribes data){
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
        itemCount: controller.productInfoList.length,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 46.wMin,
          crossAxisSpacing: 24.wMin,
          childAspectRatio:  369 / 159,
        ),
        itemBuilder: (context, index) {
          return _buildProductItem(controller.productInfoList[index], index);
        },
      );
    });
  }

  Widget _buildProductItem(ProductPointsEntityList data, int index){
    int? price = data.price;
    String priceStr = "";
    if(price != null) {
      priceStr = "${NumberUtils.formatNumberWithCommas((price) / 100)}乃币";
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
                data.describe??"",
                style: TextStyle(
                  fontSize: 40.wMin,
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
  Widget _buildBalanceWidget({
    required Color backColor,
    required String title,
    required String value,
    required int type,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.wMin),
        decoration: BoxDecoration(
          color: backColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.wMin),
        ),
        child: Column(
          children: [
            UserBalanceIcon(type: type),
            Text(
              value,
              style: TextStyle(
                fontSize: 40.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cTextPrimary,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 20.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }



}
