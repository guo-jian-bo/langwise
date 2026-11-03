

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:langwise/common/enum/enum.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../../../../routes/routes.dart';
import '../bindings/invitation_list_binding.dart';
import '../controllers/invitation_list_controller.dart';
import '../models/invitation_list_model.dart';
import 'invitation_list_line_paint.dart';

class InvitationListView extends GetView<InvitationListController> {
  final String tagText;
  const InvitationListView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      InvitationListView(tagText: tag),
      binding: InvitationListBinding(tagText: tag),
      routeName: Routes.INVITATION_LIST,
      arguments: arguments,
      preventDuplicates: false,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary.color,
      body: Column(
        children: [
          _buildTitleWidget(context),
          SizedBox(height: 20.wMin),
          Expanded(
            child: Column(
              spacing: 16.wMin,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildRegisterUserRewardWidget(context),
                _buildConversionUserRewardWidget(context),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomButtonWidget(context),
    );
  }


  Widget _buildTitleWidget(BuildContext context){
    return Container(
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).padding.left + 40.wMin,
        top: MediaQuery.of(context).padding.top + 10.wMin,
        right: MediaQuery.of(context).padding.right + 70.wMin,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromRGBO(56, 189, 248, 0.3),
            Color.fromRGBO(56, 189, 248, 0.0),
          ],
        ),
      ),
      child: Row(
        children: [
          const BackWidget(),
          const Spacer(),

          Obx((){
            return Row(
              children: [
                UserLearnPointsWidget(points: UserStore.to.userInfo.value.points??0),
                SizedBox(width: 16.wMin),
                UserMemberIconWidget(
                  member: UserStore.to.userInfo.value.vipType,
                  day: UserStore.to.userInfo.value.vipDay,
                ),
                SizedBox(width: 16.wMin),
                UserNaiCoinWidget(coins: UserStore.to.userInfo.value.credit??0),
                SizedBox(width: 16.wMin),
              ],
            );
          }),
          
          TapScaleWidget(
            sclae: 1.05,
            onTap: () {
              controller.showInvitationRules(context);
            },
            child: Container(
              padding: EdgeInsets.all(10.wMin),
              color: Colors.transparent,
              child: SvgPicture.asset(
                "assets/svg/user_center/icon_info.svg",
                width: 44.wMin,
                height: 44.wMin,
                colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
              ),
            ),
          ),

        ],
      ),
    );
  }

  /// 底部按钮
  Widget _buildBottomButtonWidget(BuildContext context){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.wMin),
      margin: EdgeInsets.only(
        top: 32.wMin,
        bottom: 22.wMin,
      ),
      child: Row(
        children: [
          const Spacer(),
           TapScaleWidget(
            onTap: OptimizeUtils.noneThrottle(() {
              controller.inviteFriends(context);
            }, 300),
            sclae: 1.01,
            child: Container(
              width: 240.wMin,
              height: 72.wMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14.wMin),
                border: Border.all(
                  color: const Color.fromRGBO(255, 255, 255, 0.20),
                  width: 2.wMin,
                ),
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: [0.0, 0.5, 1.0],
                  colors: [
                    Color(0xFFA78BFA),
                    Color(0xFF818CF8),
                    Color(0xFFD946EF),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFA78BFA),
                    offset: Offset(0, 2.wMin),
                    blurRadius: 20.wMin,
                  ),
                ],
              ),
              child: Text(
                "邀请好友",
                style: TextStyle(
                  fontSize: 28.wMin,
                  color: AppTheme.cInverseTextLight.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }




  /// 注册用户奖励
  Widget _buildRegisterUserRewardWidget(BuildContext context){
    return Container(
      width: double.infinity,
      height: 410.wMin,
      margin: EdgeInsets.only(
        left: MediaQuery.of(context).padding.left,
        right: MediaQuery.of(context).padding.right,
      ),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceSecondary.color,
        border: Border.all(width: 1.5.wMin, color: AppTheme.cBorderSecondary.color),
        borderRadius: BorderRadius.circular(24.wMin),
        image: const DecorationImage(
          alignment: Alignment.topCenter,
          image: AssetImage("assets/images/user_center/invite_gradient1.webp"),
          fit: BoxFit.fill,
        ),
      ),
      child: Obx((){
        int referralCount = controller.referralAwardEntity.value.referralCount??0;
        return Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 70.wMin),
              padding: EdgeInsets.symmetric(vertical: 30.wMin),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 1.wMin,
                    color: AppTheme.cWhiteAlpha20.color,
                  ),
                ),
              ),
              child: Row(
                children: [
                  _buildListTitleWidget("注册用户奖励", "每邀请一位用户注册即时获得学点奖励"),
                  const Spacer(),
                  _buildListUserCountWidget("已邀请", "$referralCount", const Color.fromRGBO(26, 189, 248, 1)),
                ],
              ),
            ),
            _buildListContentWidget(
              context,
              controller.invitationRegisterList.toList(), 
              controller.registerRootKey, 
              controller.registerScrollController,
            ),
          ],
        );
      }),
    );
  }

  /// 转化用户奖励
  Widget _buildConversionUserRewardWidget(BuildContext context){
    return Container(
      width: double.infinity,
      height: 410.wMin,
      margin: EdgeInsets.only(
        left: MediaQuery.of(context).padding.left,
        right: MediaQuery.of(context).padding.right,
      ),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceSecondary.color,
        border: Border.all(width: 1.5.wMin, color: AppTheme.cBorderSecondary.color),
        borderRadius: BorderRadius.circular(24.wMin),
        image: const DecorationImage(
          alignment: Alignment.topCenter,
          image: AssetImage("assets/images/user_center/invite_gradient2.webp"),
          fit: BoxFit.fill,
        ),
      ),
      child: Obx((){
        int vipCount = controller.referralAwardEntity.value.vipCount??0;
        return Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 70.wMin),
              padding: EdgeInsets.symmetric(vertical: 30.wMin),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 1.wMin,
                    color: AppTheme.cWhiteAlpha20.color,
                  ),
                ),
              ),
              child: Row(
                children: [
                  _buildListTitleWidget("推荐购买奖励", "被邀请者购买会员后，根据购买的会员等级和时长赠送会员，购买30天后可以领取"),
                  const Spacer(),
                  _buildListUserCountWidget("已购买", "$vipCount", const Color.fromRGBO(139, 92, 246, 1)),
                ],
              ),
            ),
            _buildListContentWidget(
              context,
              controller.invitationConversionList.toList(), 
              controller.conversionRootKey, 
              controller.conversionScrollController,
            ),
          ],
        );
      }),
    );
  }


  /// 列表内容
  Widget _buildListContentWidget(
    BuildContext context,
    List<InvitationListModel> list, 
    GlobalKey rootKey,
    ScrollController scrollController,
  ){
    return Expanded(
      child: ClipRRect(
        child: CustomPaint(
          painter: InvitationListLinePaint(
            rootKey: rootKey,
            invitationList: list.toList(),
            repaint: scrollController,
            defaultLneColor: AppTheme.cBorderTertiary.color,
            activeLneColor: AppTheme.cSurfaceBrand.color,
            lineWidth: 4.wMin,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            key: rootKey,
            controller: scrollController,
            padding: EdgeInsets.only(
              left: 28.wMin,
              right: 28.wMin
            ),
            child: IntrinsicHeight(
              child: Row(
                children: List.generate(list.length, (index){
                  return _buildListItemWidget(context, list[index], index);
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListItemWidget(BuildContext context, InvitationListModel data, int index){
    bool isMileStone = data.data.showPrize?.isMileStone??false;

    return Container(
      width: 200.wMin,
      height: double.infinity,
      alignment: Alignment.center,
      child: isMileStone ? _buildBigNodeWidget(context, data, index) : _buildNormalNodeWidget(context, data, index),
    );
  }

  

  /// 节点 - 大节点
  Widget _buildBigNodeWidget(BuildContext context, InvitationListModel data, int index){

    ReferralAwardStatusEnum statusEnum = data.data.statusEnum;

    Color nodeBackColor = AppTheme.cSurfacePrimary.color;
    Color borderColor = AppTheme.cBorderSecondary.color;

    if(statusEnum == ReferralAwardStatusEnum.ACTIVE){
      nodeBackColor = AppTheme.cFeedbackWarningBackground.color;
      borderColor = AppTheme.cFeedbackWarningBorder.color;
    }else if(statusEnum == ReferralAwardStatusEnum.CLAIMABLE){
      nodeBackColor = AppTheme.cFeedbackWarningBackground.color;
      borderColor = AppTheme.cFeedbackWarningBorder.color;
    } else if(statusEnum == ReferralAwardStatusEnum.PENDING){
      nodeBackColor = AppTheme.cFeedbackInfoBackground.color;
      borderColor = AppTheme.cBorderBrand.color;
    } else if(statusEnum == ReferralAwardStatusEnum.CLAIMED){
      nodeBackColor = AppTheme.cFeedbackSuccessBackground.color;
      borderColor = AppTheme.cFeedbackSuccessBorder.color;
    }


    return IgnorePointer(
      ignoring: statusEnum == ReferralAwardStatusEnum.START || statusEnum == ReferralAwardStatusEnum.INACTIVE || statusEnum == ReferralAwardStatusEnum.ACTIVE,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TapScaleWidget(
            onTap: OptimizeUtils.noneThrottle(() {
              print("待领取或待发放");
              controller.showRewardDialog(context, data);
            }, 300),
            sclae: 1.03,
            child: DottedBorder(
              color: borderColor,
              strokeWidth: 1.wMin,
              dashPattern: [2.wMin, 2.wMin],
              borderType: BorderType.RRect,
              radius: Radius.circular(24.0.wMin),
              padding: EdgeInsets.zero,
              child: Container(
                key: data.key,
                width: 120.wMin,
                height: 120.wMin,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: nodeBackColor,
                  borderRadius: BorderRadius.circular(24.wMin),
                ),
                child: _buildNodeRewardTypeIconWidget(data, index),
              ),
            ),
          ),
      
          TapScaleWidget(
            onTap: OptimizeUtils.noneThrottle(() {
              print("待领取或待发放");
              controller.showRewardDialog(context, data);
            }, 300),
            sclae: 1.03,
            child: _buildNodeRewardTextWidget(data),
          ),
        ],
      ),
    );
  }



  /// 节点 - 普通节点
  Widget _buildNormalNodeWidget(BuildContext context, InvitationListModel data, int index){

    ReferralAwardStatusEnum statusEnum = data.data.statusEnum;

    return IgnorePointer(
      ignoring: statusEnum == ReferralAwardStatusEnum.START || statusEnum == ReferralAwardStatusEnum.INACTIVE || statusEnum == ReferralAwardStatusEnum.ACTIVE,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
      
          Visibility(
            visible: statusEnum == ReferralAwardStatusEnum.START || statusEnum == ReferralAwardStatusEnum.INACTIVE, // 未解锁
            child: Container(
              width: 120.wMin,
              height: 120.wMin,
              alignment: Alignment.center,
              child: Container(
                key: data.key,
                width: 84.wMin,
                height: 84.wMin,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(width: 5.wMin, color: AppTheme.cBorderTertiary.color),
                ),
                child: Text(
                  data.data.nodeIndex?.toString()??"$index",
                  style: TextStyle(
                    fontSize: 32.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cTextPrimary.color,
                  ),
                ), 
              ),
            ),
          ),
      
          Visibility(
            visible: (statusEnum == ReferralAwardStatusEnum.ACTIVE || statusEnum == ReferralAwardStatusEnum.CLAIMABLE || statusEnum == ReferralAwardStatusEnum.PENDING), // 待领取或待发放
            child: TapScaleWidget(
              onTap: OptimizeUtils.noneThrottle(() {
                controller.showRewardDialog(context, data);
              }, 300),
              sclae: 1.05,
              child: _buildNodeRewardTypeIconWidget(data, index),
            ),
          ),
      
          Visibility(
            visible: statusEnum == ReferralAwardStatusEnum.CLAIMED || statusEnum == ReferralAwardStatusEnum.ISSUED, // 已领取
            child: TapScaleWidget(
              onTap: OptimizeUtils.noneThrottle(() {
                controller.showRewardDialog(context, data);
              }, 300),
              sclae: 1.05,
              child: Container(
                width: 120.wMin,
                height: 120.wMin,
                alignment: Alignment.center,
                child: Container(
                  width: 84.wMin,
                  height: 84.wMin,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.cSurfaceSuccess.color,
                  ),
                  child: SvgPicture.asset(
                    "assets/svg/public/icon_check_w.svg",
                    width: 56.wMin,
                    key: data.key,
                  ), 
                ),
              ),
            ),
          ),
      
          TapScaleWidget(
            onTap: OptimizeUtils.noneThrottle(() {
              controller.showRewardDialog(context, data);
            }, 300),
            sclae: 1.03,
            child: _buildNodeRewardTextWidget(data),
          ),
          
        ],
      ),
    );
  }

  // 获取节点奖励图标
  String? _getNodeRewardIcon(InvitationListModel data) {

    ReferralAwardTypeEnum? nodeRewardType = data.data.showPrize?.awardTypeEnum;

    if(nodeRewardType == ReferralAwardTypeEnum.POINTS){
      return "assets/images/public/icon_learn_point.png";
    }else if(nodeRewardType == ReferralAwardTypeEnum.CREDIT){
      return "assets/images/public/icon_nai_coin.png";
    } else if(nodeRewardType == ReferralAwardTypeEnum.PLUS_VIP){
      return "assets/images/public/icon_plus_s.png";
    } else if(nodeRewardType == ReferralAwardTypeEnum.PRO_VIP){
      return "assets/images/public/icon_pro_s.png";
    } else if(nodeRewardType == ReferralAwardTypeEnum.MAX_VIP){
      return "assets/images/public/icon_max_s.png";
    }
    return null;
  }


  /// 节点奖励的文字
  Widget _buildNodeRewardTextWidget(InvitationListModel data){

    ReferralAwardStatusEnum statusEnum = data.data.statusEnum;
    String rewardText = data.data.showPrize?.title??(data.data.showPrize?.awardName??"");
    String rewardUnit = statusEnum.name;
    Color rewardTextColor = AppTheme.cTextPrimary.color;

    if(statusEnum == ReferralAwardStatusEnum.START){
      rewardText = statusEnum.name;
      rewardUnit = "";
    }else if(statusEnum == ReferralAwardStatusEnum.INACTIVE){
      rewardUnit = "";
    }else if(statusEnum == ReferralAwardStatusEnum.ACTIVE){
      rewardText = statusEnum.name;
      rewardUnit = data.data.showPrize?.title??(data.data.showPrize?.awardName??"");
      rewardTextColor = AppTheme.cTextTertiary.color;
    }else if(statusEnum == ReferralAwardStatusEnum.CLAIMABLE){
      rewardText = statusEnum.name;
      rewardUnit = data.data.showPrize?.title??(data.data.showPrize?.awardName??"");
      rewardTextColor = AppTheme.cFeedbackWarningText.color;
    }else if(statusEnum == ReferralAwardStatusEnum.PENDING){
      rewardText = statusEnum.name;
      rewardUnit = data.data.showPrize?.title??(data.data.showPrize?.awardName??"");
      rewardTextColor = AppTheme.cSurfaceInfo.color;
    }else if(statusEnum == ReferralAwardStatusEnum.CLAIMED){
      rewardText = statusEnum.name;
      rewardUnit = data.data.showPrize?.title??(data.data.showPrize?.awardName??"");
      rewardTextColor = AppTheme.cTextPrimary.color;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          rewardText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w400,
            color: rewardTextColor,
          ),
        ),
        Text(
          rewardUnit,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextTertiary.color,
          ),
        ),
      ],
    );
  }


  /// 节点奖励类型图标
  Widget _buildNodeRewardTypeIconWidget(InvitationListModel data, int index){

    String? nodeIcon = _getNodeRewardIcon(data);

    Widget iconWidget = Container(
      width: 84.wMin,
      height: 84.wMin,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(width: 5.wMin, color: AppTheme.cBorderTertiary.color),
      ),
      child: Text(
        index.toString(),
        style: TextStyle(
          fontSize: 32.wMin,
          fontWeight: FontWeight.w500,
          color: AppTheme.cTextPrimary.color,
        ),
      ), 
    );

    if(nodeIcon != null){
      iconWidget = Image.asset(
        nodeIcon,
        width: 84.wMin,
        height: 84.wMin,
      );
    }

    bool isMileStone = data.data.showPrize?.isMileStone??false;

    return Container(
      width: 120.wMin,
      height: 120.wMin,
      alignment: Alignment.center,
      child: Container(
        width: 84.wMin,
        height: 84.wMin,
        key: !isMileStone ? data.key : null,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: nodeIcon != null ? null : Border.all(width: 5.wMin, color: AppTheme.cBorderTertiary.color),
        ),
          child: iconWidget,
      ),
    );
  }

  /// 邀请列表的标题
  Widget _buildListTitleWidget(String title, String subtitle){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          subtitle,
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextTertiary.color,
          ),
        ),
      ],
    );
  }


  /// 邀请列表的人数
  Widget _buildListUserCountWidget(String name, String value, Color color){
    return Container(
      height: 80.wMin,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: color.withValues(alpha: 0.2),
        border: Border.all(width: 1.wMin, color: color.withValues(alpha: 0.6)),
      ),
      child: Text.rich(TextSpan(
        style: TextStyle(
          fontSize: 24.wMin,
          fontWeight: FontWeight.w600,
          color: AppTheme.cTextSecondary.color,
        ),
        children: [
          TextSpan(text: name),
          TextSpan(
            text: value, 
            style: TextStyle(
              fontSize: 48.wMin, 
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          const TextSpan(text: "人"),
        ],
      )),
    );
  }



  

}
