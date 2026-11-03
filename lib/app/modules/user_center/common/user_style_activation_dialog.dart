
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/https/https.dart';
import '../../../../common/stores/stores.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/utils.dart';
import '../../../routes/routes.dart';

class UserStyleActivationModel{
  TeamStyleEntityStyleItems style;
  ResourceTypeEnum resource;

  UserStyleActivationModel({
    required this.style,
    required this.resource,
  });
}

/// 激活视觉风格弹窗
class UserStyleActivationDialog{

  /// * [resource] 要订阅的风格类型
  /// * [style] 要订阅的风格
  /// * [styles] 全部的风格数据
  static Future<bool> subscriptionPay({
    required BuildContext context,
    ResourceTypeEnum? resource,
    String? styleCode,
    required List<TeamStyleEntityStyleItems> styles,
    bool isRetry = false,
  }) async{
    bool? res = await showCupertinoDialog<bool?>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return UserStyleActivationPayDialog(
          resource: resource,
          styleCode: styleCode,
          styles: styles,
          isRetry: isRetry,
        );
      },
    );

    return res??false;
  }

}



class UserStyleActivationPayDialog extends StatefulWidget {
  final ResourceTypeEnum? resource;
  final String? styleCode;
  final List<TeamStyleEntityStyleItems> styles;
  final bool isRetry;
  const UserStyleActivationPayDialog({
    super.key, 
    this.resource, 
    this.styleCode, 
    required this.styles,
    this.isRetry = false,
  });

  @override
  State<UserStyleActivationPayDialog> createState() => _UserStyleActivationPayDialogState();
}

class _UserStyleActivationPayDialogState extends State<UserStyleActivationPayDialog> {

  List<ResourceTypeEnum> resourceTypeList = [];

  VisualStylePayInfoEntity? payInfo;

  /// 当前的风格列表
  List<UserStyleActivationModel> styleList = [];

  ResourceTypeEnum? resource;
  

  @override
  void initState() {
    super.initState();
    if(widget.resource != null){
      resource = widget.resource!;
    }
    if(widget.isRetry){
      getRetryPayInfo();
    }else{
      getPayInfo();
    }
  }

  /// 获取订阅支付信息
  Future<void> getPayInfo() async{

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "imageStyleUses": [widget.styleCode],
        "mediaModeUse": resource == ResourceTypeEnum.image ? 0 : 1,
      };
      VisualStylePayInfoEntity? res = await AccountUtil.getVisualStylePayInfo(data: reqData);
      if(res == null) return;
      payInfo = res;
      styleList.clear();
      
      for(int i = 0; i < widget.styles.length; i++){
        if(widget.styleCode == widget.styles[i].style){
          styleList.add(UserStyleActivationModel(
            resource: resource ?? ResourceTypeEnum.image,
            style: widget.styles[i],
          ));
        }
      }

      if(styleList.isNotEmpty){
        if(styleList.first.style.imageStatus == 1 && styleList.first.style.videoStatus == 1){
          resourceTypeList = [
            ResourceTypeEnum.image,
            ResourceTypeEnum.video,
          ];
        }
      }


      if(mounted) setState(() {});
    } finally{
      ToastUtils.hideLoading();
    }

  }

  /// 获取重试支付信息
  Future<void> getRetryPayInfo() async{
    try {
      ToastUtils.showLoading();
      VisualStylePayInfoEntity? res = await AccountUtil.getVisualStylePayRetryInfo();
      if(res == null) return;
      payInfo = res;
      List<String?> imageCodes = res.imageCodes??[];
      List<String?> videoCodes = res.videoCodes??[];

      styleList.clear();

      for(int i = 0; i < widget.styles.length; i++){
        if(imageCodes.contains(widget.styles[i].style) && widget.styles[i].imageStatus == 1){
          styleList.add(UserStyleActivationModel(
            resource: ResourceTypeEnum.image,
            style: widget.styles[i],
          ));
        }

        if(videoCodes.contains(widget.styles[i].style) && widget.styles[i].videoStatus == 1){
          styleList.add(UserStyleActivationModel(
            resource: ResourceTypeEnum.video,
            style: widget.styles[i],
          ));
        }
      }

      if(mounted) setState(() {});
    } finally{
      ToastUtils.hideLoading();
    }
  }


  /// 去充值
  Future<void> toRecharge() async{
    dynamic result = await Get.toNamed(
      Routes.RECHARGE_NAIBI,
      arguments: {
        "pageType": 1,
      },
    );
    if (result == null) return;
    if (result != true) return;
    ToastUtils.showToast(text: "充值成功", type: ToastType.success);
    if(widget.isRetry){
      getRetryPayInfo();
    }else{
      getPayInfo();
    }

  }

  /// 确认订阅支付
  Future<void> confirmPayment() async{
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "imageStyleUses": [widget.styleCode],
        "mediaModeUse": resource == ResourceTypeEnum.image ? 0 : 1,
      };
      bool res = await AccountUtil.teamStylePay(data: reqData);
      if(!res) return;
      ToastUtils.showToast(text: "订阅成功", type: ToastType.success);
      Get.back(result: true);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 重试支付
  Future<void> confirmPaymentRetry() async{
    try {
      ToastUtils.showLoading();
      bool res = await AccountUtil.teamStylePayRetry();
      if(!res) return;
      ToastUtils.showToast(text: "订阅成功", type: ToastType.success);
      Get.back(result: true);
    } finally{
      ToastUtils.hideLoading();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cOverlayBackground.color,
      child: Center(
        child: Container(
          width: 960.wMin,
          padding: EdgeInsets.symmetric(horizontal: 40.wMin, vertical: 20.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.wMin),
            color: AppTheme.cSurfaceSecondary.color,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTitleWidget(),
              Container(
                constraints: BoxConstraints(
                  maxHeight: 900.wMin,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildAssetBalanceWidget(),
                      _buildUnitPriceWidget(),
                      _buildActivateContentWidget(),
                      Container(
                        height: 1.wMin,
                        color: AppTheme.cBorderTertiary.color,
                      ),
                      _buildPayMethodInfoWidget(),
                      _buildInstructionsWidget(),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16.wMin),
              _buildButtonsWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleWidget(){
    return Container(
      alignment: Alignment.center,
      child: Text(
        "确认订阅详情",
        style: TextStyle(
          fontSize: 32.wMin,
          color: AppTheme.cTextPrimary.color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 资产余额
  Widget _buildAssetBalanceWidget(){
    int points = payInfo?.userPoints??0;
    String pointsStr = NumberUtils.formatNumberWithCommas(points.toDouble());
    int credit = payInfo?.userCredit??0;
    String creditStr = NumberUtils.formatNumberWithCommas(credit / 100);

    return Container(
      margin: EdgeInsets.only(top: 20.wMin),
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

  /// 单价
  Widget _buildUnitPriceWidget(){

    String imageUnitPrice = NumberUtils.formatNumberWithCommas((payInfo?.imageUnitPrice??0).toDouble());
    String videoUnitPrice = NumberUtils.formatNumberWithCommas((payInfo?.videoUnitPrice??0).toDouble());

    return Container(
      margin: EdgeInsets.only(top: 16.wMin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Text(
            "图片单价：",
            style: TextStyle(
              fontSize: 22.wMin,
              color: AppTheme.cTextSecondary.color,
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            "$imageUnitPrice学点 / 天",
            style: TextStyle(
              fontSize: 22.wMin,
              color: ResourceTypeEnum.image.color,
              fontWeight: FontWeight.w400,
            ),
          ),
          
          SizedBox(width: 60.wMin),

          Text(
            "视频单价：",
            style: TextStyle(
              fontSize: 22.wMin,
              color: AppTheme.cTextSecondary.color,
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            "$videoUnitPrice学点 / 天",
            style: TextStyle(
              fontSize: 22.wMin,
              color: ResourceTypeEnum.video.color,
              fontWeight: FontWeight.w400,
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


  /// 激活内容
  Widget _buildActivateContentWidget(){

    String requiredCredits = NumberUtils.formatNumberWithCommas((payInfo?.requiredCredits??0).toDouble());
    String alreadyPaidCredits = NumberUtils.formatNumberWithCommas((payInfo?.alreadyPaidCredits??0).toDouble());
    String diffCredits = NumberUtils.formatNumberWithCommas((payInfo?.diffCredits??0).toDouble());

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 16.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "价格明细",
            style: TextStyle(
              fontSize: 24.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w600,
            ),
          ),

          // TTOD: 切换风格
          _buildModeWidget(),

          _buildStyleListWidget(),

          SizedBox(height: 12.wMin),

          _buildRowColorTextWidget(
            "订阅天数",
            "${payInfo?.expiredDay??0} 天",
            AppTheme.cTextPrimary.color,
          ),

          SizedBox(height: 10.wMin),

          _buildRowColorTextWidget(
            "总需学点",
            "$requiredCredits 学点",
            AppTheme.cTextPrimary.color,
          ),

          Visibility(
            visible: (payInfo?.alreadyPaidCredits??0) > 0,
            child: Container(
              margin: EdgeInsets.only(top: 10.wMin),
              child: Column(
                children: [

                  _buildRowColorTextWidget(
                    "已支付学点",
                    "$alreadyPaidCredits 学点",
                    AppTheme.cTextPrimary.color,
                  ),
                  SizedBox(height: 10.wMin),

                  _buildRowColorTextWidget(
                    "实际支付",
                    "$diffCredits 学点",
                    AppTheme.cTextPrimary.color,
                  ),

                ],
              ),
            ),
          ),
          

          SizedBox(height: 10.wMin),

          _buildRowColorTextWidget(
            "下个账单日期",
            payInfo?.billingDate??"",
            AppTheme.cTextPrimary.color,
          ),

          SizedBox(height: 16.wMin),

        ],
      ),
    );
  }


  /// 切换资源
  Widget _buildModeWidget(){
    if(widget.isRetry) return Container();
    return Container(
      margin: EdgeInsets.only(top: 10.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 8.wMin,
            children: List.generate(resourceTypeList.length, (index){

              bool selected = resourceTypeList[index] == resource;

              return Expanded(
                child: TapScaleWidget(
                  onTap: () {
                    resource = resourceTypeList[index];
                    getPayInfo();
                  },
                  sclae: 1,
                  child: Container(
                    height: 64.wMin,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.wMin),
                      color: selected ? resourceTypeList[index].color.withValues(alpha: 0.2) : AppTheme.cSurfaceTertiary.color,
                      border: Border.all(
                        width: 1.wMin,
                        color: selected ? resourceTypeList[index].color : AppTheme.cSurfaceTertiary.color,
                      ),
                    ),
                    child: Row(
                      spacing: 8.wMin,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          resourceTypeList[index].svg,
                          width: 28.wMin,
                          colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                        ),
                        Text(
                          resourceTypeList[index].name,
                          style: TextStyle(
                            fontSize: 24.wMin,
                            color: AppTheme.cTextPrimary.color,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );

            }),
          ),
        ],
      ),
    );
  }

  


  /// 风格列表
  Widget _buildStyleListWidget(){
    return Container(
      margin: EdgeInsets.only(top: 10.wMin),
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        color: AppTheme.cSurfaceTertiary.color,
      ),
      child: Column(
        children: List.generate(styleList.length, (index){

          LanguageText? localText = LearningLangUtils.getLocalLang(styleList[index].style.styleTitle??[]);

          String price = NumberUtils.formatNumberWithCommas((payInfo?.imageUnitPrice??0).toDouble());
          if(styleList[index].resource == ResourceTypeEnum.video){
            price = NumberUtils.formatNumberWithCommas((payInfo?.videoUnitPrice??0).toDouble());
          }

          return Row(
            spacing: 24.wMin,
            children: [

              Text(
                "${styleList[index].resource.name}模式 - ${localText?.text??''}",
                style: TextStyle(
                  color: styleList[index].resource.color,
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const Spacer(),

              Text(
                "$price学点 / 天",
                style: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cLearnSomethingPrimary.color,
                ),
              ),
            ],
          );

        }),
      ),
    );
  }

  /// 支付方式
  Widget _buildPayMethodInfoWidget(){
    String pointsStr = NumberUtils.formatNumberWithCommas((payInfo?.orderPoints??0).toDouble());
    String creditStr = NumberUtils.formatNumberWithCommas((payInfo?.orderCredit??0) / 100);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.wMin),
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
          visible: (payInfo?.orderCredit??0) != 0,
          child: _buildRowColorTextWidget(
            "乃币支付",
            "$creditStr 乃币",
            payInfo?.affordable == true ? AppTheme.cNsCoinBgPrimary.color : AppTheme.cFeedbackErrorText.color,
          ),
        ),
        Visibility(
          visible: payInfo?.affordable != true,
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

   Widget _buildRowColorTextWidget(String name, String value, Color textColor){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 24.wMin,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 24.wMin,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),

      ],
    );
  }


  /// 说明
  Widget _buildInstructionsWidget(){
    if(payInfo?.hint == null) return Container();
    List<String?> items = payInfo?.hint?.items??[];

    List<Color> colors = [];
    if(resource == null){

      if((payInfo?.imageCodes??[]).isNotEmpty && (payInfo?.videoCodes??[]).isNotEmpty){
        colors = [
          ResourceTypeEnum.image.color,
          ResourceTypeEnum.video.color,
        ];
      }else if((payInfo?.imageCodes??[]).isNotEmpty){
        colors = [
          ResourceTypeEnum.image.color,
          ResourceTypeEnum.image.color,
        ];
      }else if((payInfo?.videoCodes??[]).isNotEmpty){
        colors = [
          ResourceTypeEnum.video.color,
          ResourceTypeEnum.video.color,
        ];
      }else{
        colors = [
          ResourceTypeEnum.image.color,
          ResourceTypeEnum.video.color,
        ];
      }
      
    }else{
      colors = [
        resource!.color,
        resource!.color,
      ];
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 16.wMin),
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: colors.map((e) => e.withValues(alpha: 0.2)).toList(),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: payInfo?.hint?.title != null,
            child: Text(
              payInfo?.hint?.title??"",
              style: TextStyle(
                fontSize: 24.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10.wMin),
            child: Column(
              spacing: 6.wMin,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(items.length, (index){
            
                return Row(
                  spacing: 8.wMin,
                  children: [
            
                    Container(
                      width: 8.wMin,
                      height: 8.wMin,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: colors,
                        ),
                      ),
                    ),
            
                    Expanded(
                      child: Text(
                        items[index]??"",
                        style: TextStyle(
                          fontSize: 22.wMin,
                          color: AppTheme.cTextPrimary.color.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
            
            
                  ],
                );
            
              })
              ,
            ),
          ),

        ],
      ),
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
            onTap: () => Get.back(),
          ),
        ),
        SizedBox(width: 12.wMin),
        Expanded(
          child: ButtonWidget(
            text: payInfo?.affordable == true ? "确认支付" : "去充值",
            borderRadius: 12.wMin,
            height: 72.wMin,
            width: double.infinity,
            color: AppTheme.cSurfaceInfo.color,
            fontColor: AppTheme.cInverseTextLight.color,
            fontSize: 28.wMin,
            fontWeight: FontWeight.w500,
            sclae: 1.01,
            onTap: () {
              if(payInfo?.affordable == true){
                if(widget.isRetry){
                  confirmPaymentRetry();
                }else{
                  confirmPayment();
                }
              }else{
                toRecharge();
              }
            },
          ),
        ),
      ],
    );
  }




}