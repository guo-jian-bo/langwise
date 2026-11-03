import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/https/https.dart';
import '../../../routes/routes.dart';
import '../../../routes/tag_routes.dart';
import '../common/user_style_activation_dialog.dart';

class UserVisualStyleController extends GetxController{
  final String tagText;
  UserVisualStyleController({required this.tagText});

  final Rx<TeamStyleEntity> teamStyleData = TeamStyleEntity().obs;

  /// 风格列表
  final RxList<TeamStyleEntityStyleItems> styleList = <TeamStyleEntityStyleItems>[].obs;

  /// 当前设置的资源类型
  final Rx<ResourceTypeEnum> resourceType = ResourceTypeEnum.image.obs;

  /// 当前生效的风格列表code
  final RxList<String> takeEffectCodeList = <String>[].obs;

  /// 拥有的风格列表
  final RxList<TeamStyleEntityStyleItems> ownStyleList = <TeamStyleEntityStyleItems>[].obs;


  @override
  void onInit() {
    super.onInit();
  }


  /// 获取视觉风格
  Future<void> getStyleList() async{
    try {

      await Get.find<ConfigController>().getUserStyleList();
      teamStyleData.value = Get.find<ConfigController>().originalStyleData.value;

      resourceType.value = teamStyleData.value.mediaModeUse == 1 ? ResourceTypeEnum.video : ResourceTypeEnum.image;

      List<TeamStyleEntityStyleItems?> styleItems = teamStyleData.value.styleItems??[];
      List<String?> imageStyleUses = teamStyleData.value.imageStyleUses??[];

      takeEffectCodeList.clear();
      styleList.clear();
      ownStyleList.clear();

      for(int i = 0; i < imageStyleUses.length; i++){
        if(imageStyleUses[i] == null) return;
        takeEffectCodeList.add(imageStyleUses[i]!);
      }

      for(int i = 0; i < styleItems.length; i++){
        if(styleItems[i] == null) continue;

        if(styleItems[i]?.imageRights == 1 || styleItems[i]?.videoRights == 1){
          ownStyleList.add(styleItems[i]!);
        }

        styleList.add(styleItems[i]!);
      }

    } catch (_) {}
  }

  /// 切换模式
  Future<void> switchMode(ResourceTypeEnum type) async{
    if(type == resourceType.value) return;
    
    Set<String> validCodeList = styleList.where((item){
      if(type == ResourceTypeEnum.video){
        return item.videoRights == 1;
      }
      return item.imageRights == 1;
    }).map((item) => item.style).whereType<String>().toSet();

    takeEffectCodeList.removeWhere((code) => !validCodeList.contains(code));
    resourceType.value = type;
    await confirmUsage();
  }

  /// 选择/取消生效风格
  Future<void> selectStyle(TeamStyleEntityStyleItems data) async{
    if(data.style == null) return;
    bool hasRights = resourceType.value == ResourceTypeEnum.video ? data.videoRights == 1 : data.imageRights == 1;
    if(!hasRights) return ToastUtils.showToast(text: "请先订阅该风格");
    if(takeEffectCodeList.contains(data.style??"")){
      if(takeEffectCodeList.length == 1) return ToastUtils.showToast(text: "至少保留一个风格");
      takeEffectCodeList.remove(data.style??"");
    }else{
      takeEffectCodeList.add(data.style??"");
    }
    await confirmUsage();
  }

  /// 获取生效中的风格列表
  List<TeamStyleEntityStyleItems> getEffectiveStyleList(){
    return ownStyleList.toList().where((element) => takeEffectCodeList.contains(element.style??"")).toList();
  }


  /// 弹出激活弹窗
  Future<void> styleActivation(BuildContext context, TeamStyleEntityStyleItems data) async{
    if(data.imageForbidUnsubscribed == true && data.imageForbidUnsubscribed == true){
      return ToastUtils.showToast(text: "当前风格为默认订阅");
    }
    
    if(resourceType.value == ResourceTypeEnum.image){
      if(data.imageSubRights?.isLock??false) return ToastUtils.showToast(text: "未到开放日期");
      if(data.imageSubRights?.isNoRights??false){
        bool askRes = await AskDialog.showUserAsk(
          context: context,
          title: "温馨提示",
          content: "需要升级会员才能使用视觉风格",
          define: "去升级",
        );
        if(!askRes) return;
        TagRoutes.toNamed(Routes.MEMBER_CENTER);
        return;
      }
    }else{
      if(data.videoSubRights?.isNoRights??false){
        if(data.videoSubRights?.isLock??false) return ToastUtils.showToast(text: "未到开放日期");
        bool askRes = await AskDialog.showUserAsk(
          context: context,
          title: "温馨提示",
          content: "需要升级会员才能使用视觉风格",
          define: "去升级",
        );
        if(!askRes) return;
        TagRoutes.toNamed(Routes.MEMBER_CENTER);
        return;
      }
    }

    bool res = await UserStyleActivationDialog.showSubscribe(
      context: context,
      resource: resourceType.value,
      data: data,
    );
    if(!res) return;
    getStyleList();

    // bool res = await UserStyleActivationDialog.subscriptionPay(
    //   context: context,
    //   resource: resourceType.value,
    //   styleCode: data.style??"",
    //   styles: styleList.toList(),
    // );
    // if(!res) return;
    // getStyleList();
  }

    /// 确认使用
  Future<void> confirmUsage() async{
    if(takeEffectCodeList.isEmpty) return ToastUtils.showToast(text: "请选择风格");

    try {
      Map<String, dynamic> reqData = {
        "imageStyleUses": takeEffectCodeList.toList(),
        "mediaModeUse": resourceType.value == ResourceTypeEnum.image ? 0 : 1,
      };
      bool res = await AccountUtil.teamConfigStyleEdit(reqData);
      if(!res) return;
      await getStyleList();
      Get.find<ConfigController>().initUserStyleList();
    } finally{}

  }

  @override
  void onClose() {
    super.onClose();

  }



}
