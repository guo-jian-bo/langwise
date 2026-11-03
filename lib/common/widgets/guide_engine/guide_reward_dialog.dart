import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../utils/utils.dart';
import '../../entities/entities.dart';
import '../../enum/enum.dart';
import '../widgets.dart';

class GuideRewardDialog{

  static Future<bool> show({
    required BuildContext context,
    required List<NewbieGuideEntityQuestsRewards?> rewards,
    required int rewardStatus,
    required int status,
    String? finished,
  }) async{
    if(rewards.isEmpty) return false;
    bool? res = await showCupertinoDialog<bool?>(
      context: context,
      builder: (context) {
        return GuideRewardDialogWidget(
          rewards: rewards,
          rewardStatus: rewardStatus,
          status: status,
          finished: finished,
        );
      },
    );
    return res ?? false;
  }

  /// 领取奖励弹窗
  static Future<bool> showClaimRewardDialog({
    required BuildContext context,
    required List<NewbieGuideEntityQuestsRewards?> rewards,
  }) async{
    if(rewards.isEmpty) return false;
    bool? res = await showCupertinoDialog<bool?>(
      context: context,
      builder: (context) {
        return GuideClaimRewardDialogWidget(
          rewards: rewards,
        );
      },
    );
    return res ?? false;
  }

}

class GuideRewardDialogWidget extends StatefulWidget {
  final List<NewbieGuideEntityQuestsRewards?> rewards;
  final int rewardStatus;
  final int status;
  final String? finished;
  const GuideRewardDialogWidget({super.key, required this.rewards, required this.rewardStatus, required this.status, this.finished});

  @override
  State<GuideRewardDialogWidget> createState() => _GuideRewardDialogWidgetState();
}

class _GuideRewardDialogWidgetState extends State<GuideRewardDialogWidget> {
  @override
  Widget build(BuildContext context) {

    Color primaryColor = StatusUtils.getRewardColor(widget.rewards.first?.rewardType);

    return Material(
      color: AppTheme.cOverlayBackground.color,
      child: Center(
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 700.wMin,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.wMin),
                border: Border(
                  top: BorderSide(color: primaryColor, width: 4.wMin),
                ),
                color: AppTheme.cSurfaceSecondary.color
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTitleGradientWidget(),
                  _buildTitleTextWidget(),
                  _buildContentWidget(),
                  SizedBox(height: 24.wMin),
                  _buildBottomWidget(),
                  SizedBox(height: 40.wMin),
                ],
              ),
            ),
            
            Positioned(
              top: -100.wMin,
              child: _buildTitleImageWidget(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleGradientWidget(){
    Color primaryColor = StatusUtils.getRewardColor(widget.rewards.first?.rewardType);

    return Container(
      height:  170.wMin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.wMin),
          topRight: Radius.circular(24.wMin),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primaryColor.withValues(alpha: 0.25),
            primaryColor.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleTextWidget(){

    String title = "新人专属奖励";
    if(widget.rewards.length > 1){
      title = "新人专属奖励${widget.rewards.length}个";
    }else{
      title = widget.rewards.first?.displayName ?? "新人专属奖励";
    }

    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 40.wMin,
            fontWeight: FontWeight.w600,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
        Text(
          "",
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w600,
            color: AppTheme.cTextTertiary.color,
          ),
        ),
      ],
    );
  }

  Widget _buildContentWidget(){

    return Column(
      spacing: 24.wMin,
      children: List.generate(widget.rewards.length, (index){
        Color fontColor = StatusUtils.getRewardColor(widget.rewards[index]?.rewardType);

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 40.wMin),
          padding: EdgeInsets.symmetric(horizontal: 16.wMin),
          decoration: BoxDecoration(
            color: AppTheme.cSurfaceTertiary.color,
            borderRadius: BorderRadius.circular(10.wMin),
          ),
          child: Column(
            children: [
              _buildContentRowWidget("奖励", [widget.rewards[index]?.displayName ?? ""], fontColor: fontColor),
              _buildContentRowCouponWidget(widget.rewards[index]),
              SizedBox(height: 20.wMin),
            ],
          ),
        );

      }),
    );
  }

  Widget _buildContentRowWidget(String name, List<String?> values, {Color? fontColor}){
    
    return Container(
      margin: EdgeInsets.only(top: 20.wMin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 28.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
      
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(values.length, (itemIndex){
              return Text(
                values[itemIndex]??"",
                style: TextStyle(
                  fontSize: 28.wMin,
                  fontWeight: FontWeight.w400,
                  color: fontColor ?? AppTheme.cTextPrimary.color,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildContentRowCouponWidget(NewbieGuideEntityQuestsRewards? rewards){
    if(widget.rewardStatus != 1) return Container();
    if(rewards == null) return Container();
    Color fontColor = StatusUtils.getRewardColor(rewards.rewardType);
    List<String?> values = rewards.values ?? [];
    if(values.isEmpty) return Container();

    return Container(
      margin: EdgeInsets.only(top: 20.wMin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "兑换码",
            style: TextStyle(
              fontSize: 28.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
      
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 8.wMin,
            children: List.generate(values.length, (itemIndex){
              return TapScaleWidget(
                onTap: () async{
                  await Clipboard.setData(ClipboardData(text: values[itemIndex]??""));
                  ToastUtils.showToast(text: "复制成功", type: ToastType.success);
                },
                sclae: 1.02,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 4.wMin),
                  decoration: BoxDecoration(
                    color: AppTheme.cSurfacePrimary.color,
                    borderRadius: BorderRadius.circular(6.wMin),
                  ),
                  child: Row(
                    spacing: 8.wMin,
                    children: [
                      Text(
                        values[itemIndex]??"",
                        style: TextStyle(
                          fontSize: 28.wMin,
                          fontWeight: FontWeight.w400,
                          color: fontColor,
                        ),
                      ),
                      Text(
                        "复制兑换码",
                        style: TextStyle(
                          fontSize: 24.wMin,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.cSurfaceError.color,
                        ),
                      ),
                
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomWidget(){
    ReferralAwardTypeEnum? assetType = widget.rewards.first?.rewardType;
    Color color = AppTheme.cSurfaceTertiary.color;
    Color textColor = AppTheme.cTextTertiary.color;
    String text = "未完成";

    if(widget.status == 1){
      if(widget.rewardStatus == 1){
        text = "已发放";
        color = StatusUtils.getRewardColor(assetType).withValues(alpha: 0.2);
        textColor = StatusUtils.getRewardColor(assetType);
      }else{
        text = "待发放";
        color = StatusUtils.getRewardColor(assetType).withValues(alpha: 0.2);
        textColor = StatusUtils.getRewardColor(assetType);
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40.wMin),
      child: TapScaleWidget(
        onTap: OptimizeUtils.noneThrottle(() {

          Get.back(result: true);

        }, 300),
        sclae: 1.01,
        child: Container(
          width: double.infinity,
          height: 72.wMin,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: color,
            boxShadow: [
              BoxShadow(
                color: color,
                offset: Offset(0, 2.wMin),
                blurRadius: 10.wMin,
              ),
            ],
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 28.wMin,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildTitleImageWidget(){
    
    if(widget.rewards.length > 1){
      return Image.asset("assets/images/public/gift_pack_big.png", height: 260.wMin);
    }

    ReferralAwardTypeEnum? assetType = widget.rewards.first?.rewardType;

    if(assetType == ReferralAwardTypeEnum.COUPON){
      return Image.asset("assets/images/public/gift_pack_big.png", height: 260.wMin);
    } else if(assetType == ReferralAwardTypeEnum.POINTS){
      return Image.asset("assets/images/public/learn_point_big.webp", height: 260.wMin);
    } else if(assetType == ReferralAwardTypeEnum.CREDIT){
      return Image.asset("assets/images/public/nai_coin_big.webp", height: 260.wMin);
    } else if(assetType == ReferralAwardTypeEnum.GIFT){
      return Image.asset("assets/images/public/gift_pack_big.png", height: 260.wMin);
    }else if(assetType == ReferralAwardTypeEnum.PRO_VIP){
      return _buildMemberCardWidget(assetType);
    }else if(assetType == ReferralAwardTypeEnum.MAX_VIP){
      return _buildMemberCardWidget(assetType);
    }else if(assetType == ReferralAwardTypeEnum.PLUS_VIP){
      return _buildMemberCardWidget(assetType);
    }else{
      return Image.asset("assets/images/public/gift_pack_big.png", height: 260.wMin);
    }
  }

  Widget _buildMemberCardWidget(ReferralAwardTypeEnum? assetType){

    String imagePath = "";
    if(assetType == ReferralAwardTypeEnum.PLUS_VIP){
      imagePath = "assets/images/public/plus_card.webp";
    }else if(assetType == ReferralAwardTypeEnum.PRO_VIP){
      imagePath = "assets/images/public/pro_card.webp";
    }else if(assetType == ReferralAwardTypeEnum.MAX_VIP){
      imagePath = "assets/images/public/max_card.webp";
    }

    return SizedBox(
      height: 260.wMin,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 260.wMin,
            child: Image.asset(
              imagePath, 
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container();
              },
            ),
          ),
          Positioned(
            bottom: 20.wMin,
            left: 26.wMin,
            child: Text(
              "",
              style: TextStyle(
                fontSize: 28.wMin,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }




}


class GuideClaimRewardDialogWidget extends StatefulWidget {
  final List<NewbieGuideEntityQuestsRewards?> rewards;
  const GuideClaimRewardDialogWidget({super.key, required this.rewards});

  @override
  State<GuideClaimRewardDialogWidget> createState() => _GuideClaimRewardDialogWidgetState();
}

class _GuideClaimRewardDialogWidgetState extends State<GuideClaimRewardDialogWidget> {

  List<NewbieGuideEntityQuestsRewards> rewards = [];

  @override
  void initState() {
    super.initState();
    List<NewbieGuideEntityQuestsRewards?>? list = widget.rewards;
    for(NewbieGuideEntityQuestsRewards? item in list){
      if(item == null) continue;
      rewards.add(item);
    }

  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = StatusUtils.getRewardColor(rewards.first.rewardType);

    return Material(
      color: AppTheme.cOverlayBackground.color,
      child: Center(
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 700.wMin,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.wMin),
                border: Border(
                  top: BorderSide(color: primaryColor, width: 4.wMin),
                ),
                color: AppTheme.cSurfaceSecondary.color
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTitleGradientWidget(),
                  _buildTitleTextWidget(),
                  _buildContentWidget(),
                  SizedBox(height: 24.wMin),
                  _buildBottomWidget(),
                  SizedBox(height: 40.wMin),
                ],
              ),
            ),
            
            Positioned(
              top: -100.wMin,
              child: _buildTitleImageWidget(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomWidget(){
    ReferralAwardTypeEnum? assetType = rewards.first.rewardType;
    Color textColor = StatusUtils.getRewardColor(assetType);

    // 奖励中是否包含优惠券
    bool hasCoupon = rewards.any((element) => element.rewardType == ReferralAwardTypeEnum.COUPON);

    String text = "我知道了";

    if(hasCoupon){
      text = "复制兑换码";
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40.wMin),
      child: TapScaleWidget(
        onTap: OptimizeUtils.noneThrottle(() {
          if(hasCoupon){
            String valuesText = "";
            for(NewbieGuideEntityQuestsRewards item in rewards){
              if(item.values == null || item.values!.isEmpty) continue;
              valuesText += item.values!.join("\n");
              valuesText += "\n";
            }
            // 复制优惠券
            Clipboard.setData(ClipboardData(text: valuesText));
            ToastUtils.showToast(text: "复制成功", type: ToastType.success);
          }

          Get.back(result: true);

        }, 300),
        sclae: 1.01,
        child: Container(
          width: double.infinity,
          height: 72.wMin,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: Colors.white,
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 28.wMin,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentWidget(){

    return Column(
      spacing: 24.wMin,
      children: List.generate(rewards.length, (index){
        Color fontColor = StatusUtils.getRewardColor(rewards[index].rewardType);

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 40.wMin),
          padding: EdgeInsets.symmetric(horizontal: 16.wMin),
          decoration: BoxDecoration(
            color: AppTheme.cSurfaceTertiary.color,
            borderRadius: BorderRadius.circular(10.wMin),
          ),
          child: Column(
            children: [
              _buildContentRowWidget("奖励", [rewards[index].displayName ?? ""], fontColor: fontColor),
              _buildContentRowCouponWidget(rewards[index]),
              SizedBox(height: 20.wMin),
            ],
          ),
        );

      }),
    );
  }

  Widget _buildContentRowWidget(String name, List<String?> values, {Color? fontColor}){
    
    return Container(
      margin: EdgeInsets.only(top: 20.wMin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 28.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
      
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(values.length, (itemIndex){
              return Text(
                values[itemIndex]??"",
                style: TextStyle(
                  fontSize: 28.wMin,
                  fontWeight: FontWeight.w400,
                  color: fontColor ?? AppTheme.cTextPrimary.color,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildContentRowCouponWidget(NewbieGuideEntityQuestsRewards? rewards){
    if(rewards == null) return Container();
    Color fontColor = StatusUtils.getRewardColor(rewards.rewardType);
    List<String?> values = rewards.values ?? [];
    if(values.isEmpty) return Container();

    return Container(
      margin: EdgeInsets.only(top: 20.wMin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "兑换码",
            style: TextStyle(
              fontSize: 28.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
      
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 8.wMin,
            children: List.generate(values.length, (itemIndex){
              return TapScaleWidget(
                onTap: () async{
                  await Clipboard.setData(ClipboardData(text: values[itemIndex]??""));
                  ToastUtils.showToast(text: "复制成功", type: ToastType.success);
                },
                sclae: 1.02,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 4.wMin),
                  decoration: BoxDecoration(
                    color: AppTheme.cSurfacePrimary.color,
                    borderRadius: BorderRadius.circular(6.wMin),
                  ),
                  child: Row(
                    spacing: 8.wMin,
                    children: [
                      Text(
                        values[itemIndex]??"",
                        style: TextStyle(
                          fontSize: 28.wMin,
                          fontWeight: FontWeight.w400,
                          color: fontColor,
                        ),
                      ),
                      Text(
                        "复制兑换码",
                        style: TextStyle(
                          fontSize: 24.wMin,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.cSurfaceError.color,
                        ),
                      ),
                
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }


  Widget _buildTitleTextWidget(){

    String title = "新人专属奖励";
    if(rewards.length > 1){
      title = "新人专属奖励${rewards.length}个";
    }else{
      title = rewards.first.displayName ?? "新人专属奖励";
    }

    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 40.wMin,
            fontWeight: FontWeight.w600,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
        Text(
          "",
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w600,
            color: AppTheme.cTextTertiary.color,
          ),
        ),
      ],
    );
  }

  Widget _buildTitleGradientWidget(){
    Color primaryColor = StatusUtils.getRewardColor(rewards.first.rewardType);

    return Container(
      height:  170.wMin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.wMin),
          topRight: Radius.circular(24.wMin),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primaryColor.withValues(alpha: 0.25),
            primaryColor.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }


  Widget _buildTitleImageWidget(){
    
    if(rewards.length > 1){
      return Image.asset("assets/images/public/gift_pack_big.png", height: 260.wMin);
    }

    ReferralAwardTypeEnum? assetType = rewards.first.rewardType;

    if(assetType == ReferralAwardTypeEnum.COUPON){
      return Image.asset("assets/images/public/gift_pack_big.png", height: 260.wMin);
    } else if(assetType == ReferralAwardTypeEnum.POINTS){
      return Image.asset("assets/images/public/learn_point_big.webp", height: 260.wMin);
    } else if(assetType == ReferralAwardTypeEnum.CREDIT){
      return Image.asset("assets/images/public/nai_coin_big.webp", height: 260.wMin);
    } else if(assetType == ReferralAwardTypeEnum.GIFT){
      return Image.asset("assets/images/public/gift_pack_big.png", height: 260.wMin);
    }else if(assetType == ReferralAwardTypeEnum.PRO_VIP){
      return _buildMemberCardWidget(assetType);
    }else if(assetType == ReferralAwardTypeEnum.MAX_VIP){
      return _buildMemberCardWidget(assetType);
    }else if(assetType == ReferralAwardTypeEnum.PLUS_VIP){
      return _buildMemberCardWidget(assetType);
    }else{
      return Image.asset("assets/images/public/gift_pack_big.png", height: 260.wMin);
    }
  }

  Widget _buildMemberCardWidget(ReferralAwardTypeEnum? assetType){

    String imagePath = "";
    if(assetType == ReferralAwardTypeEnum.PLUS_VIP){
      imagePath = "assets/images/public/plus_card.webp";
    }else if(assetType == ReferralAwardTypeEnum.PRO_VIP){
      imagePath = "assets/images/public/pro_card.webp";
    }else if(assetType == ReferralAwardTypeEnum.MAX_VIP){
      imagePath = "assets/images/public/max_card.webp";
    }

    return SizedBox(
      height: 260.wMin,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 260.wMin,
            child: Image.asset(
              imagePath, 
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container();
              },
            ),
          ),
          Positioned(
            bottom: 20.wMin,
            left: 26.wMin,
            child: Text(
              "",
              style: TextStyle(
                fontSize: 28.wMin,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }



}