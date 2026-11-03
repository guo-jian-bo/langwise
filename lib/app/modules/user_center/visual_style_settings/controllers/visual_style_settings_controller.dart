import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/user_center/common/member_update_comfirmation_dialog.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/stores/user.dart';
import '../../common/activation_style_confirmation_dialog.dart';
import '../../model/visual_style_model.dart';



class VisualStyleSettingsController extends GetxController {
  final UserStore userStore = UserStore.to;

  /// 当前会员
  final RxString currentMemberLevel = "".obs;

  /// 剩余视觉风格激活券
  final RxInt activationCoupon = 0.obs;

  /// 数据
  final RxList<VisualStyleModel> imageStyles = <VisualStyleModel>[].obs;

  /// 选中 id
  final RxList<int> selectIds = <int>[].obs;


  @override
  void onInit() {
    super.onInit();
    initData();
  }

  Future<void> initData() async{
    try{
      ToastUtils.showLoading();
      await userStore.getUserInfo();
      await getVisualStyleList();
    } finally{
      ToastUtils.hideLoading();
    }
  }


  /// 获取图片风格列表
  Future<void> getVisualStyleList() async{
    ToastUtils.showLoading();
    VisualStyleEntity? entity = await UserRequest.getVisualStyleList();
    ToastUtils.hideLoading();
    if(entity == null) return;
    currentMemberLevel.value = entity.vipType??"";
    activationCoupon.value = entity.stylCouponCount??0;

    if(entity.imageStyles == null) return;

    imageStyles.clear();

    final Map<String, List<VisualStyleEntityImageStyles>> grouped = {};
    for (final style in entity.imageStyles!) {
      if(style == null) continue;
      if(style.locale == null || style.locale!.isEmpty) continue;
      grouped.putIfAbsent(style.locale!, () => []).add(style);
    }

    grouped.forEach((locale, list) {
      String localeTitle = list.first.localeTitle??"";

      List<String> iconUrls = [];
      if(list.first.iconUrls != null){
        for (final icon in list.first.iconUrls!) {
          if(icon == null) continue;
          iconUrls.add(icon);
        }
      }    

      list.sort((a, b) {
        if(a.vipType == null || b.vipType == null) return 0;
        /// Free -> Plus -> Pro -> Max
        UserInfoEntityVipConfigs? aMember = getMemberInfo(a.vipType);
        UserInfoEntityVipConfigs? bMember = getMemberInfo(b.vipType);
        if(aMember == null || bMember == null) return 0;
        if(aMember.index == null || bMember.index == null) return 0;
        if(aMember.index! > bMember.index!) return 1;
        if(aMember.index! < bMember.index!) return -1;
        return 0;
      });

      imageStyles.add(VisualStyleModel(
        localeTitle: localeTitle,
        locale: locale,
        iconUrls: iconUrls,
        list: list,
      ));
    });
    

  }

  /// 根据会员获取会员颜色
  UserInfoEntityVipConfigs? getMemberInfo(String? member){
    if(userStore.userInfo.value.vipConfigs == null) return null;
    for (final element in userStore.userInfo.value.vipConfigs!) {
      if(element == null) continue;
      if(element.vipType == member){
        return element;
      }
    }
    return null;
  }

  /// 查看系列图片
  void showSeriesOfPictures(BuildContext context, VisualStyleModel data, int index){
    Get.toNamed(
      Routes.SERIES_OF_PICTURES,
      arguments: {
        "styleData": data,
        "showIndex": index,
      },
    );
  }

  /// 选择风格
  Future<void> selectStyle(VisualStyleEntityImageStyles data, String localeTitle, BuildContext context) async{
    if(data.uid == null) return;

    if(data.vipType != currentMemberLevel.value){
      UserInfoEntity userInfo = userStore.userInfo.value;
      // 去升级会员
      MemberLevelColor currentColors = StatusUtils.getMemberColorsByVipConfigs(userInfo.vipConfigs, currentMemberLevel.value);
      MemberLevelColor needColors = StatusUtils.getMemberColorsByVipConfigs(userInfo.vipConfigs, data.vipType);
      bool updateRes = await MemberUpdateComfirmationDialog.show(
        context: context, 
        currentLevel: currentMemberLevel.value, 
        needLevel: data.vipType??"",
        currentColor: currentColors.deep,
        needColor: needColors.deep,
      );
      if(!updateRes) return;
      dynamic res = await Get.toNamed(Routes.MEMBER_CENTER);
      if(res == null) return;
      initData();
      return;
    }

    if(activationCoupon.value <= 0){
      return ToastUtils.showToast(text: "视觉风格激活券不足！");
    }

    if(!data.isActivation){
      // 未激活
      bool comARes = await SctivationStyleConfirmationDialog.show(
        context: context,
        localeTitle: localeTitle,
        data: data,
      );
      if(!comARes) return;
      activationCoupon.value --;
      // data.isActivation = true;
      selectIds.add(data.uid!);
      return;
    }

    if(selectIds.contains(data.uid)){
      selectIds.remove(data.uid);
    }else{
      selectIds.add(data.uid!);
    }
    
  }


  /// 确定
  Future<void> confirm(BuildContext context) async{
    
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
