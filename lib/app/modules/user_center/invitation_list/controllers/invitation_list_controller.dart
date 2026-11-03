import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import 'package:langwise/common/enum/enum.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/stores/stores.dart';
import '../../../../../common/widgets/guide_engine/guide_engine.dart';
import '../../../../../common/widgets/invitation_dialogs/invitation_dialogs.dart';
import '../../../../routes/routes.dart';
import '../../../../routes/routes_breadcrumb_utils.dart';
import '../../common/exchange_coupons_dialog.dart';
import '../../common/invitation_rules_dialog.dart';
import '../../controllers/user_center_controller.dart';
import '../models/invitation_list_model.dart';

class InvitationListController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  InvitationListController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.INVITATION_LIST;

  @override
  String get breadcrumbTitle => "邀请有礼";



  final Rx<ReferralAwardEntity> referralAwardEntity = ReferralAwardEntity().obs;
  
  /// 邀请注册列表
  final RxList<InvitationListModel> invitationRegisterList = RxList<InvitationListModel>([]);

  /// 注册列表根键
  final GlobalKey registerRootKey = GlobalKey();
  
  /// 用于触发 CustomPaint 重绘的 ScrollController
  final ScrollController registerScrollController = ScrollController();

  /// 邀请转化列表
  final RxList<InvitationListModel> invitationConversionList = RxList<InvitationListModel>([]);
  
  /// 转化列表根键
  final GlobalKey conversionRootKey = GlobalKey();
  
  /// 用于触发 CustomPaint 重绘的 ScrollController
  final ScrollController conversionScrollController = ScrollController();

  /// 是否达到邀请上限
  final RxBool isInvitationMax = false.obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);

    getReferralAwardList(isScrollToPendingReward: true, isInit: true);
    UserStore.to.getUserInfo();

  }


  /// 获取邀请列表
  Future<void> getReferralAwardList({bool isScrollToPendingReward = false, bool isInit = false}) async{
    if(isInit){
      if(!UserStore.to.rolePermissions.value.userIsReferrer){
        // 下一帧执行
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) async{
          TagRoutes.offAndToNamed(Routes.BECOME_INVITER);
        });
        return;
      }
    }

    try {
      ToastUtils.showLoading();
      ReferralAwardEntity? res = await ActivitiesRequest.getReferralAwardList();
      if(res == null) return;
      referralAwardEntity.value = res;

      List<ReferralAwardEntityNodes?> referralNodes = res.referralNodes??[];
      invitationRegisterList.clear();
      invitationRegisterList.add(InvitationListModel(
        key: GlobalKey(), 
        data: ReferralAwardEntityNodes(
          status: ReferralAwardStatusEnum.START.value,
        ),
        awardTypeEnum: ReferralAwardListTypeEnum.REFERRAL,
      ));
      for (var element in referralNodes) {
        if(element == null) continue;
        // element.status = ReferralAwardStatusEnum.ISSUED.value;
        invitationRegisterList.add(InvitationListModel(
          key: GlobalKey(), 
          data: element,
          isActive: element.statusEnum != ReferralAwardStatusEnum.INACTIVE,
          awardTypeEnum: ReferralAwardListTypeEnum.REFERRAL,
        ));

      }

      if(invitationRegisterList.isNotEmpty){
        isInvitationMax.value = invitationRegisterList.last.data.refereeId != null;
      }

      invitationConversionList.clear();
      invitationConversionList.add(InvitationListModel(
        key: GlobalKey(), 
        data: ReferralAwardEntityNodes(
          status: ReferralAwardStatusEnum.START.value,
        ),
        awardTypeEnum: ReferralAwardListTypeEnum.VIP,
      ));
      List<ReferralAwardEntityNodes?> vipNodes = res.vipNodes??[];
      for (var element in vipNodes) {
        if(element == null) continue;
        invitationConversionList.add(InvitationListModel(
          key: GlobalKey(), 
          data: element,
          isActive: element.statusEnum != ReferralAwardStatusEnum.INACTIVE,
          awardTypeEnum: ReferralAwardListTypeEnum.VIP,
        ));
      }

      if(isScrollToPendingReward){
        scrollToPendingReward();
      }

    } finally {
      ToastUtils.hideLoading();
    }
  }


  /// 定位到待领取
  void scrollToPendingReward() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      
      for(int i = 0; i < invitationRegisterList.length; i++){
        if(invitationRegisterList[i].key.currentContext == null) continue;

        // 定位到第一个未激活
        if(invitationRegisterList[i].data.statusEnum == ReferralAwardStatusEnum.INACTIVE){
          Scrollable.ensureVisible(invitationRegisterList[i].key.currentContext!, alignment: 0.5);
          break;
        }

      }

      for(int i = 0; i < invitationConversionList.length; i++){
        if(invitationConversionList[i].key.currentContext == null) continue;
        if(invitationConversionList[i].data.statusEnum == ReferralAwardStatusEnum.CLAIMABLE){
          Scrollable.ensureVisible(invitationConversionList[i].key.currentContext!, alignment: 0.5);
          break;
        }

        // 如果没有待领取，定位到第一个未激活
        if(invitationConversionList[i].data.statusEnum == ReferralAwardStatusEnum.INACTIVE){
          Scrollable.ensureVisible(invitationConversionList[i].key.currentContext!, alignment: 0.5);
          break;
        }
      }


    });
  }


  /// 邀请奖励规则
  Future<void> showInvitationRules(BuildContext context) async{
    await InvitationRulesDialog.show(context: context);
    GuideTaskController.to.continueGuide(AppRoutesCode.invitationList, GuideWidgetIds.invitationListRulesButton);
  }


  /// 邀请好友
  Future<void> inviteFriends(BuildContext context) async{
    if(isInvitationMax.value){
      GuideTaskController.to.stop();
      return ToastUtils.showToast(text: "已到达邀请上限");
    }
    String? wechatShareLink = referralAwardEntity.value.wechatShareLink;

    bool res = await InvitationDialogs.showMethodDialog(
      context: context,
      data: InvitationDialogsData(
        title: "邀请好友",
        desc: "${wechatShareLink != null ? "三种方式任选，" : ""}好友立得超值礼包",
        inviteRewardTip: referralAwardEntity.value.inviteRewardTip,
        wechatShareTip: referralAwardEntity.value.wechatShareTip,
        wechatShareLink: wechatShareLink,
        appIconUrl: referralAwardEntity.value.appIconUrl,
        scanData: InvitationDialogsScanData(
          brandTitle: referralAwardEntity.value.scanRewardDTO?.brandTitle,
          title: referralAwardEntity.value.scanRewardDTO?.title,
          subTitle: referralAwardEntity.value.scanRewardDTO?.subTitle,
          benefitList: referralAwardEntity.value.scanRewardDTO?.benefitList??[],
          scanTip: referralAwardEntity.value.scanRewardDTO?.scanTip,
          actionText: referralAwardEntity.value.scanRewardDTO?.actionText,
        ),
      ),
    );
    // return;

    // bool res = await InviteFriendsDialog.show(context: context); 
    GuideTaskController.to.continueGuide(AppRoutesCode.invitationList, GuideWidgetIds.invitationListInviteButton);
    if(!res) return;
    // 刷新列表
    getReferralAwardList();
    Future.delayed(const Duration(seconds: 1), (){
      if(isClosed) return;
      UserStore.to.getUserInfo();
    });

  }


  /// 显示奖励弹窗
  Future<void> showRewardDialog(BuildContext context, InvitationListModel data) async{

    List<ReferralAwardEntityNodesPrize?> taskPrizes = data.data.taskPrizes??[];
    if(taskPrizes.isEmpty) return;
    String title = "";

    if(taskPrizes.length == 1){
      title = taskPrizes.first?.title??(taskPrizes.first?.awardName??"");
    }else{
      title = "礼包奖励";
    }

    String referralTime = DateFormatUtil.formatStrtoStr(data.data.referralTime);
    String claimTime = DateFormatUtil.formatStrtoStr(data.data.claimTime);
    String giveTime = DateFormatUtil.formatStrtoStr(data.data.giveTime);
    String vipActivated = DateFormatUtil.formatStrtoStr(data.data.refereeOrderTime);

    List<RewardData> infos = [
      RewardData(
        name: "奖励内容", 
        values: List.generate(taskPrizes.length, (index){
          return RewardDataItem(
            value: taskPrizes[index]?.title??(taskPrizes[index]?.awardName??""),
            valueFontColor: StatusUtils.getRewardColor(data.data.showPrizeTypeEnum),
          );
        }),
      ),
      RewardData(name: "手机号", values: [RewardDataItem(value: data.data.phoneNumber??"")]),

      RewardData(name: "邀请时间", values: [RewardDataItem(value: referralTime)]),
    ];

    if(data.awardTypeEnum == ReferralAwardListTypeEnum.VIP){
      infos.add(RewardData(name: "购买时间", values: [RewardDataItem(value: vipActivated)]));
      infos.add(RewardData(name: "购买类型", values: [RewardDataItem(value: data.data.refereeOrderTitle??"")]));
    }
    
    if(data.data.statusEnum == ReferralAwardStatusEnum.PENDING){
      infos.add(RewardData(name: "预计发放", values: [RewardDataItem(value: giveTime)]));
    }else if(data.data.statusEnum == ReferralAwardStatusEnum.CLAIMED){
      // infos.add(RewardData(name: "发放时间", values: [RewardDataItem(value: giveTime)]));
      infos.add(RewardData(name: "领取时间", values: [RewardDataItem(value: claimTime)]));
    }


    bool res = await RewardDialog.show(
      context: context, 
      assetType: data.data.showPrizeTypeEnum,
      // memberCardText: "会员卡",
      statusEnum: data.data.statusEnum,
      title: title,
      infos: infos,
    );
    if(!res) return;

    if(data.data.statusEnum != ReferralAwardStatusEnum.CLAIMABLE) return;

    if(data.awardTypeEnum == ReferralAwardListTypeEnum.REFERRAL){
      claimInvitationReward(data);
    }else if(data.awardTypeEnum == ReferralAwardListTypeEnum.VIP){
      claimVipReward(Get.context ?? context, data);
    }

  }


  /// 领取邀请奖励
  Future<void> claimInvitationReward(InvitationListModel data) async{
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {

      };
      bool res = await ActivitiesRequest.claimInvitationReward(reqData: reqData);
      if(!res) return;
      ToastUtils.showToast(text: "领取成功", type: ToastType.success);
      getReferralAwardList();
      UserCenterController? userCenterController = TagRoutes.findLast<UserCenterController>(Routes.USER_CENTER);
      if(userCenterController != null){
        userCenterController.initServiceData();
      }
    } finally{
      ToastUtils.hideLoading();
    }
  }


  /// 领取VIP奖励
  Future<void> claimVipReward(BuildContext context, InvitationListModel data) async{
    List<int>? traineeIds = await selectTrainees(context, data);
    if(traineeIds == null) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "traineeIds": traineeIds,
      };
      bool res = await ActivitiesRequest.claimVipReward(reqData: reqData);
      if(!res) return;
      ToastUtils.showToast(text: "领取成功", type: ToastType.success);
      getReferralAwardList();
      UserCenterController? userCenterController = TagRoutes.findLast<UserCenterController>(Routes.USER_CENTER);
      if(userCenterController != null){
        userCenterController.initServiceData();
      }
      
    } finally{
      ToastUtils.hideLoading();
    }
  }


  /// 选择学员 返回null说明取消选择 返回空数组继续领取逻辑
  Future<List<int>?> selectTrainees(BuildContext context, InvitationListModel data) async{
    try {
      ToastUtils.showLoading();
      int traineeCount = data.data.traineeCount??0;
      if(traineeCount <= 0) return []; // 0说明不需要选择学员

      RedemptionCodeInfoEntity? entity = await ActivitiesRequest.getTeamUsableTraineeList();
      if(entity == null) return [];
      List<RedemptionCodeInfoEntityTraineeList?> traineeList = entity.traineeList??[];
      if(traineeList.isEmpty) return [];

      entity.activateTraineesSize = traineeCount; // 最多选择的学员数量
      List<RedemptionCodeInfoEntityTraineeList>? selectedTrainees = await ExchangeCouponsDialog.showSelectStudentDialog(
        context: Get.context ?? context, 
        infoEntity: entity,
        buttonText: "确认选择",
      );
      if(selectedTrainees == null) return null;
      if(selectedTrainees.isEmpty) return [];
      List<int> traineeIds = [];
      for(var item in selectedTrainees){
        if(item.traineeId == null) continue;
        traineeIds.add(item.traineeId!);
      }
      return traineeIds;
    } finally{
      ToastUtils.hideLoading();
    }

  }



  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    registerScrollController.dispose();
    conversionScrollController.dispose();
    super.onClose();
  }
}
