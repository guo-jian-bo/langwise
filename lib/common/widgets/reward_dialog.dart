
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../enum/enum.dart';
import 'widgets.dart';

/// 奖励弹窗 （学点 乃币 会员）
class RewardDialog {
  
  /// * 显示奖励弹窗
  /// * assetType: 奖励类型
  /// * memberType: 会员类型（可选，仅当 assetType 为 membership 时需要）
  /// * memberCardText: 会员卡号（可选，仅当 assetType 为 membership 时需要）
  /// * rewardStatus: 领取状态
  /// * pendingClaimText: 待领取文本 (可选，仅领取状态为待领取时需要)
  static Future<bool> show({
    required BuildContext context,
    required ReferralAwardTypeEnum assetType,
    required ReferralAwardStatusEnum statusEnum,
    String? memberCardText,
    String pendingClaimText = "领取奖励",
    required String? title,
    String? subTitle,
    List<RewardData>? infos,
  }) async{
   

    bool? res = await showCupertinoDialog<bool?>(
      context: context,
      builder: (context) {
        return RewardDialogWidget(
          assetType: assetType,
          statusEnum: statusEnum,
          memberCardText: memberCardText,
          pendingClaimText: pendingClaimText,
          title: title,
          subTitle: subTitle,
          infos: infos,
        );
      },
    );
    return res ?? false;
  }

}

class RewardData{
  String name;
  List<RewardDataItem>? values;
  
  RewardData({
    required this.name,
    this.values,
  });
}

class RewardDataItem{
  String value;
  Color? valueFontColor;
  
  RewardDataItem({
    required this.value,
    this.valueFontColor,
  });
}


class RewardDialogWidget extends StatefulWidget {
  final ReferralAwardTypeEnum assetType;
  final ReferralAwardStatusEnum statusEnum;
  final String? memberCardText;
  final String pendingClaimText;
  final String? title;
  final String? subTitle;
  final List<RewardData>? infos;
  
  const RewardDialogWidget({
    super.key,
    required this.assetType,
    required this.statusEnum,
    this.memberCardText,
    required this.pendingClaimText,
    this.title,
    this.subTitle,
    this.infos,
  });

  @override
  State<RewardDialogWidget> createState() => _RewardDialogWidgetState();
}

class _RewardDialogWidgetState extends State<RewardDialogWidget> {


  @override
  Widget build(BuildContext context) {

    Color primaryColor = StatusUtils.getRewardColor(widget.assetType);

    return GestureDetector(
      onTap: () => Get.back(),
      child: Material(
        color: AppTheme.cOverlayBackground.color,
        child: Center(
          child: GestureDetector(
            onTap: (){},
            child: Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 640.wMin,
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
                      SizedBox(height: 20.wMin),
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
        ),
      ),
    );
  }


  Widget _buildTitleGradientWidget(){
    Color primaryColor = StatusUtils.getRewardColor(widget.assetType);

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
    return Column(
      children: [
        Text(
          widget.title??"",
          style: TextStyle(
            fontSize: 40.wMin,
            fontWeight: FontWeight.w600,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
        Visibility(
          visible: widget.subTitle != null,
          child: Text(
            widget.subTitle ??"",
              style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w600,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentWidget(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceTertiary.color,
        borderRadius: BorderRadius.circular(24.wMin),
      ),
      child: ListView.builder(
        itemCount: widget.infos?.length ?? 0,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 10.wMin),
        itemBuilder: (context, index) {
          List<RewardDataItem> values = widget.infos?[index].values??[];
          return Container(
            padding: EdgeInsets.symmetric(vertical: 10.wMin),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.infos?[index].name ?? "",
                  style: TextStyle(
                    fontSize: 22.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextTertiary.color,
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(values.length, (itemIndex){

                    return Text(
                      values[itemIndex].value,
                      style: TextStyle(
                        fontSize: 24.wMin,
                        fontWeight: FontWeight.w400,
                        color: (values[itemIndex].valueFontColor) ??AppTheme.cTextPrimary.color,
                      ),
                    );
                  }),
                ),


                
            
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomWidget(){

    Color color = StatusUtils.getRewardColor(widget.assetType);
    Color textColor = AppTheme.cInverseTextLight.color;
    String text = widget.pendingClaimText;
    if(widget.statusEnum == ReferralAwardStatusEnum.CLAIMED || widget.statusEnum == ReferralAwardStatusEnum.ISSUED){
      text = widget.statusEnum.name;
      color = color.withValues(alpha: 0.2);
      textColor = StatusUtils.getRewardColor(widget.assetType);
    }else if(widget.statusEnum == ReferralAwardStatusEnum.PENDING){
      text = widget.statusEnum.name;
      color = AppTheme.cSurfaceTertiary.color;
      textColor = AppTheme.cTextTertiary.color;
    } else{
      // text = widget.statusEnum.name;
      color = color.withValues(alpha: 0.2);
      textColor = StatusUtils.getRewardColor(widget.assetType);
    }


    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40.wMin),
      child: TapScaleWidget(
        onTap: OptimizeUtils.noneThrottle(() {
          if(widget.statusEnum == ReferralAwardStatusEnum.CLAIMABLE){
            Get.back(result: true);
          }else{
            Get.back(result: false);
          }
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
    if(widget.assetType == ReferralAwardTypeEnum.COUPON){
      return Image.asset("assets/images/public/gift_pack_big.png", height: 260.wMin);
    } else if(widget.assetType == ReferralAwardTypeEnum.POINTS){
      return Image.asset("assets/images/public/learn_point_big.webp", height: 260.wMin);
    } else if(widget.assetType == ReferralAwardTypeEnum.CREDIT){
      return Image.asset("assets/images/public/nai_coin_big.webp", height: 260.wMin);
    } else if(widget.assetType == ReferralAwardTypeEnum.GIFT){
      return Image.asset("assets/images/public/gift_pack_big.png", height: 260.wMin);
    }else if(widget.assetType == ReferralAwardTypeEnum.PRO_VIP){
      return _buildMemberCardWidget();
    }else if(widget.assetType == ReferralAwardTypeEnum.MAX_VIP){
      return _buildMemberCardWidget();
    }else if(widget.assetType == ReferralAwardTypeEnum.PLUS_VIP){
      return _buildMemberCardWidget();
    }else{
      return Image.asset("assets/images/public/gift_pack_big.png", height: 260.wMin);
    }
  }

  Widget _buildMemberCardWidget(){

    String imagePath = "";
    if(widget.assetType == ReferralAwardTypeEnum.PLUS_VIP){
      imagePath = "assets/images/public/plus_card.webp";
    }else if(widget.assetType == ReferralAwardTypeEnum.PRO_VIP){
      imagePath = "assets/images/public/pro_card.webp";
    }else if(widget.assetType == ReferralAwardTypeEnum.MAX_VIP){
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
              widget.memberCardText ?? "",
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