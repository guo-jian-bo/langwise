import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../routes/routes.dart';
import '../../../../routes/routes_breadcrumb_utils.dart';
import '../../../../routes/tag_routes.dart';
import '../../common/confirm_upgrade_dialog.dart';
import '../../common/price_difference_dialog.dart';

class MemberCenterController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  MemberCenterController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.MEMBER_CENTER;

  @override
  String get breadcrumbTitle => "会员中心";
  
  /// 会员套餐列表
  final RxList<MemberPackageEntityList> memberPackageList = <MemberPackageEntityList>[].obs;

  final RxInt selectTabbarIndex = 0.obs;

  final RxInt selectMemberPackageIndex = (-1).obs;

  final ScrollController scrollController = ScrollController();
  

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    getMemberPackageList();
  }

  /// 获取会员套餐列表
  Future<void> getMemberPackageList({bool showLoading = true}) async{
    try {
       if(showLoading) ToastUtils.showLoading();
      MemberPackageEntity? memberPackageEntity = await PayRequest.getMemberPackageList();
      if(memberPackageEntity == null) return;
      List<MemberPackageEntityList?> list = memberPackageEntity.list??[];
      memberPackageList.clear();
      for(int i = 0; i < list.length; i++){
        if(list[i] == null) continue;
        memberPackageList.add(list[i]!);
      }
      scrollToCurrentMember();
    } finally{
      if(showLoading) ToastUtils.hideLoading();
    }
  }

  /// 滚动到当前会员的位置
  Future<void> scrollToCurrentMember() async{
    if(memberPackageList.isEmpty) return;

    String? vipType = UserStore.to.userInfo.value.vipType;
    if(vipType == null) return;

    MemberPackageEntityList memberPackage = memberPackageList[selectTabbarIndex.value];
    List<MemberPackageEntityListList?> list = memberPackage.list??[];
    if(list.isEmpty) return;
    
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async{
      await Future.delayed(const Duration(milliseconds: 300));
      int currentIndex = 0;
      for(int i = 0; i < list.length; i++){
        if(list[i] == null) continue;
        if(list[i]!.name == vipType){
          currentIndex = i;
          break;
        }
      }
      
      // 如果是第一个卡片，不需要滚动
      if(currentIndex == 0) {
        selectTabbarIndex.value = memberPackageList.length - 1;
        await Future.delayed(const Duration(milliseconds: 300));
        currentIndex = list.length - 1;
      }
      
      // 滚动视图的左边距
      double leftPadding = 205.wMin;
      
      // 计算目标卡片的位置
      double cardWidth = 580.wMin;
      double cardSpacing = 24.wMin;
      
      // 目标卡片在滚动内容中的左边缘位置（不包括边距）
      double targetCardLeft = currentIndex * (cardWidth + cardSpacing);
      
      // 目标卡片中心位置（不包括边距）
      double targetCardCenter = targetCardLeft + (cardWidth / 2);
      
      // 屏幕可视区域宽度的一半
      double screenCenterOffset = Get.width / 2;
      
      // 计算滚动位置：目标卡片中心 - (屏幕中心 - 左边距)
      double scrollPosition = targetCardCenter - (screenCenterOffset - leftPadding);
      
      try {
        // 确保滚动位置在有效范围内，防止超出边界
        double maxScrollExtent = scrollController.position.maxScrollExtent;
        double minScrollExtent = scrollController.position.minScrollExtent;
        
        scrollPosition = scrollPosition.clamp(minScrollExtent, maxScrollExtent);
      
        await scrollController.animateTo(
          scrollPosition,
          duration: const Duration(milliseconds: 200),
          curve: Curves.linear,
        );
        
        selectMemberPackageIndex.value = currentIndex;
      } catch (_) {}
    });
  }

  void changeTabbar(int index){
    selectTabbarIndex.value = index;
  }

  void changeMemberPackage(int index, MemberPackageEntityListList data){
    selectMemberPackageIndex.value = index;
  }

  /// 跳转至开通会员结算页面
  Future<void> toOpenMemberSettlement(MemberPackageEntityListList? data, BuildContext context) async{
    if(data == null) return;
    if(data.servicePackageId == null) return;

    bool isShowCompletionPrice = data.isShowCompletionPrice??false;

    PayRequest.getCompletionMemberInfo();
    
    // 是否是会员补齐
    bool isCompletionPrice = false;
    if(isShowCompletionPrice){
      // 需要补差价 显示差价提示弹窗
      bool isDifference = await PriceDifferenceDialog.getCompletionMemberInfo(context); //调接口
      if(!isDifference) return;
      isCompletionPrice = true;
    }else{
      // 不需要补差价 直接弹出升级提示
      MemberLevelColor memberLevelColor = StatusUtils.getMemberColorsByVipConfigs(
        UserStore.to.userInfo.value.vipConfigs, 
        data.name,
      );
      bool confirm = await ConfirmUpgradeDialog.show(
        context: context,
        needLevel: data.name,
        needDuration: "${data.duration??0}${data.durationTypeTitle??''}",
        needColor: memberLevelColor.deep,
      );

      if(!confirm) return;
    }

    

    bool isPwdRight = await ParentPasswordialog.show(context: context);
    if(!isPwdRight) return;


    dynamic res = await TagRoutes.toNamed(
      Routes.OPEN_MEMBER_SETTLEMENT,
      arguments: {
        "servicePackageId": data.servicePackageId,
        "servicePackageVersion": data.version,
        "isCompletionPrice": isCompletionPrice,
      },
    );
    if(res == null) return;
    if(res == true){
      getMemberPackageList();
      Get.back(result: true);
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

}
