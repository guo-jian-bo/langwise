import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../common/entities/entities.dart';
import '../../common/stores/stores.dart';
import '../../common/widgets/widgets.dart';
import '../utils.dart';

enum CourseDetailsTargetDownloadPayDialogAction{
  /// 确认支付
  confirmPay,
  /// 取消
  cancel,
  /// 去充值
  goToRecharge,
}

/// 下载支付确认信息
class CourseDetailsTargetDownloadPayDialog{

  static Future<CourseDetailsTargetDownloadPayDialogAction> show({
    required BuildContext context,
    required KnowledgeDownloadInfoEntity entity,
  }) async{
    CourseDetailsTargetDownloadPayDialogAction? res = await showDialog<CourseDetailsTargetDownloadPayDialogAction?>(
      context: context,
      builder: (context){
        return CourseDetailsTargetDownloadPayDialogWidget(
          entity: entity,
        );
      },
    );
    return res??CourseDetailsTargetDownloadPayDialogAction.cancel;
  }

}

class CourseDetailsTargetDownloadPayDialogWidget extends StatefulWidget {
  final KnowledgeDownloadInfoEntity entity;
  const CourseDetailsTargetDownloadPayDialogWidget({super.key, required this.entity});

  @override
  State<CourseDetailsTargetDownloadPayDialogWidget> createState() => _CourseDetailsTargetDownloadPayDialogWidgetState();
}

class _CourseDetailsTargetDownloadPayDialogWidgetState extends State<CourseDetailsTargetDownloadPayDialogWidget> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cOverlayBackground.color,
      child: Center(
        child: Container(
          width: 680.wMin,
          padding: EdgeInsets.symmetric(horizontal: 40.wMin, vertical: 24.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.wMin),
            color: AppTheme.cSurfaceSecondary.color,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "确认下载详情",
                style: TextStyle(
                  fontSize: 32.wMin,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
              SizedBox(height: 10.wMin),
              _buildAssetBalanceWidget(),
              SizedBox(height: 10.wMin),
              _buildProductServiceWidget(),
              SizedBox(height: 10.wMin),
              _buildKnowledgePointWidget(),
              SizedBox(height: 10.wMin),
              _buildPriceInfoWidget(),
              SizedBox(height: 10.wMin),
              _buildTotalPointWidget(),
              SizedBox(height: 10.wMin),
              Container(
                height: 1.wMin,
                color: AppTheme.cBorderTertiary.color,
              ),
              SizedBox(height: 10.wMin),
              _buildPayMethodInfoWidget(),
              SizedBox(height: 24.wMin),

              _buildButtonsWidget(),
              




            ],
          ),
        ),
      ),
    );
  }

  /// 资产余额
  Widget _buildAssetBalanceWidget(){
    int points = widget.entity.userPoints??0;
    String pointsStr = NumberUtils.formatNumberWithCommas(points.toDouble());
    int credit = widget.entity.userCredit??0;
    String creditStr = NumberUtils.formatNumberWithCommas(credit / 100);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 12.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        color: AppTheme.cSurfaceTertiary.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4.wMin,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAssetBalanceItemWidget(
                1,
                "学点余额",
                pointsStr,
              ),
              SizedBox(width: 24.wMin),
              _buildAssetBalanceItemWidget(
                2,
                "乃币余额",
                creditStr,
              ),
            ],
          ),
          Text(
            "每月赠送 ${UserStore.to.userInfo.value.vipPointsStr} 学点",
            style: TextStyle(
              fontSize: 22.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cLearnSomethingPrimary.color,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildAssetBalanceItemWidget(int type, String name, String value){
    return Expanded(
      child: Row(
        children: [
          UserBalanceIcon(type: type, boxSize: 74.wMin, iconSize: 50.wMin),
          SizedBox(width: 12.wMin),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
              Text(
                name,
                style: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextTertiary.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 商品服务
  Widget _buildProductServiceWidget(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "商品/服务",
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w600,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
        Text(
          "学习内容",
          style: TextStyle(
            fontSize: 20.wMin,
            color: AppTheme.cTextPrimary.color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// 知识点数量
  Widget _buildKnowledgePointWidget(){
    List<KnowledgeDownloadInfoEntityKnowledgeCounts?> knowledgeCounts = widget.entity.knowledgeCounts??[];
    if(knowledgeCounts.isEmpty) return Container();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "知识点数量",
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w600,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
        SizedBox(height: 8.wMin),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 10.wMin),
          decoration: BoxDecoration(
            color: AppTheme.cSurfaceTertiary.color,
            borderRadius: BorderRadius.circular(12.wMin),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(knowledgeCounts.length, (index){
              if(knowledgeCounts[index] == null) return Container();
              return _buildRowTextWidget(
                knowledgeCounts[index]!.getContentTypeText,
                "${knowledgeCounts[index]!.quantity??0} 个",
              );
            }),
          ),
        ),
      ],
    );
  }


  /// 价格明细
  Widget _buildPriceInfoWidget(){
    List<KnowledgeDownloadInfoEntityContentServicePackages?> contentServicePackages = widget.entity.contentServicePackages??[];
    if(contentServicePackages.isEmpty) return Container();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "价格明细",
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w600,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
        SizedBox(height: 8.wMin),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 10.wMin),
          decoration: BoxDecoration(
            color: AppTheme.cSurfaceTertiary.color,
            borderRadius: BorderRadius.circular(12.wMin),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(contentServicePackages.length, (index){
              if(contentServicePackages[index] == null) return Container();
              KnowledgeDownloadInfoEntityContentServicePackages item = contentServicePackages[index]!;
              String pointsStr = NumberUtils.formatNumberWithCommas(item.price?.toDouble()??0);
          
              String totalPrice = NumberUtils.formatNumberWithCommas((item.totalPrice??0).toDouble());
          
              return _buildRowTextWidget(
                "${item.title??''}  $pointsStr 点/${item.durationTitle??'个'} x ${item.quantity??0}",
                "$totalPrice 点",
              );
            }),
          ),
        ),
      ],
    );
  }

  /// 合计学点
  Widget _buildTotalPointWidget(){

    List<KnowledgeDownloadInfoEntityContentServicePackages?> contentServicePackages = widget.entity.contentServicePackages??[];
    int totalPoints = contentServicePackages.fold(0, (prev, item) => prev + (item?.totalPrice??0));


    String pointsStr = NumberUtils.formatNumberWithCommas((totalPoints).toDouble());
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "合计学点",
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w600,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
        Text(
          "$pointsStr 点",
          style: TextStyle(
            fontSize: 20.wMin,
            color: AppTheme.cTextPrimary.color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// 支付方式
  Widget _buildPayMethodInfoWidget(){
    String pointsStr = NumberUtils.formatNumberWithCommas((widget.entity.orderPoints??0).toDouble());
    String creditStr = NumberUtils.formatNumberWithCommas((widget.entity.orderCredit??0) / 100);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "支付方式",
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w600,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
        SizedBox(height: 10.wMin),
        _buildRowColorTextWidget(
          "学点支付",
          "$pointsStr 点",
          AppTheme.cLearnSomethingPrimary.color,
        ),
        SizedBox(height: 8.wMin),
        Visibility(
          visible: (widget.entity.orderCredit??0) != 0,
          child: _buildRowColorTextWidget(
            "乃币支付",
            "$creditStr 乃币",
            widget.entity.affordable == true ? AppTheme.cNsCoinBgPrimary.color : AppTheme.cFeedbackErrorText.color,
          ),
        ),
        Visibility(
          visible: widget.entity.affordable != true,
          child: Container( 
            alignment: Alignment.centerRight,
            child: Text(
              "乃币余额不足",
              style: TextStyle(
                fontSize: 20.wMin,
                color: AppTheme.cFeedbackErrorText.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

      ],
    );
  }

  Widget _buildRowTextWidget(String name, String value){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 22.wMin,
            color: AppTheme.cTextTertiary.color,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 22.wMin,
            color: AppTheme.cTextPrimary.color,
            fontWeight: FontWeight.w500,
          ),
        ),

      ],
    );
  }

   Widget _buildRowColorTextWidget(String name, String value, Color textColor){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 20.wMin,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 20.wMin,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),

      ],
    );
  }


  Widget _buildButtonsWidget(){
    return Row(
      children: [
        Expanded(
          child: ButtonWidget(
            text: "取消",
            borderRadius: 12.wMin,
            height: 72.wMin,
            width: double.infinity,
            color: AppTheme.cSurfaceQuaternary.color,
            fontColor: AppTheme.cTextPrimary.color,
            fontSize: 28.wMin,
            fontWeight: FontWeight.w500,
            sclae: 1.01,
            onTap: () => Get.back(result: CourseDetailsTargetDownloadPayDialogAction.cancel),
          ),
        ),
        SizedBox(width: 12.wMin),
        Expanded(
          child: ButtonWidget(
            text: widget.entity.affordable == true ? "确认支付" : "去充值",
            borderRadius: 12.wMin,
            height: 72.wMin,
            width: double.infinity,
            color: AppTheme.cSurfaceInfo.color,
            fontColor: AppTheme.cInverseTextLight.color,
            fontSize: 28.wMin,
            fontWeight: FontWeight.w500,
            sclae: 1.01,
            onTap: () {
              if(widget.entity.affordable == true){
                Get.back(result: CourseDetailsTargetDownloadPayDialogAction.confirmPay);
              }else{
                Get.back(result: CourseDetailsTargetDownloadPayDialogAction.goToRecharge);
              }
            },
          ),
        ),
      ],
    );
  }


}