import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/common/widgets/guide_engine/guide_engine.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:resource_cache_package/resource_cache_package.dart';
import 'package:video_player/video_player.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/https/https.dart';
import '../../../../common/stores/stores.dart';
import '../../../routes/routes.dart';
import '../../../routes/tag_routes.dart';
import '../common/user_management_style_dialog.dart';
import '../common/user_style_activation_dialog.dart';

class UserVisualStyleController extends GetxController{
  final String tagText;
  UserVisualStyleController({required this.tagText});

  final Rx<TeamStyleEntity> teamStyleData = TeamStyleEntity().obs;

  /// 风格列表
  final RxList<UserVisualStyleModel> styleList = <UserVisualStyleModel>[].obs;

  /// 当前设置的资源类型
  final Rx<ResourceTypeEnum> resourceType = ResourceTypeEnum.image.obs;

  /// 当前生效的风格列表code
  final RxList<String> takeEffectCodeList = <String>[].obs;

  /// 当前生效的风格列表
  final RxList<TeamStyleEntityStyleItems> takeEffectList = <TeamStyleEntityStyleItems>[].obs;

  /// 正在播放的视频id
  final RxInt videoPlayId = (-1).obs;
  /// 是否正在播放
  final RxBool videoPlaying = false.obs;
  Player player = Player();
  late final VideoController videoController;

  StreamSubscription<bool>? _playingSub;
  StreamSubscription<bool>? _completedSub;

  @override
  void onInit() {
    super.onInit();
    videoController = VideoController(player);
    listenVideo();
  }

  /// 监听视频播放
  void listenVideo(){

    _playingSub = player.stream.playing.listen((e){
      videoPlaying.value = e;
    });

    _completedSub = player.stream.completed.listen((e){
      if(e){
        videoPlayId.value = -1;
      }
    });
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
      takeEffectList.clear();

      for(int i = 0; i < imageStyleUses.length; i++){
        if(imageStyleUses[i] == null) return;
        takeEffectCodeList.add(imageStyleUses[i]!);
      }

      for(int i = 0; i < styleItems.length; i++){
        if(styleItems[i] == null) continue;
        if(imageStyleUses.contains(styleItems[i]?.style)){
          takeEffectList.add(styleItems[i]!);
        }

        ResourceTypeEnum resource = resourceType.value;

        if(styleItems[i]!.videoStatus == 0){
          resource = ResourceTypeEnum.image;
        }else if(styleItems[i]!.imageStatus == 0){
          resource = ResourceTypeEnum.video;
        }
  
        styleList.add(UserVisualStyleModel(
          data: styleItems[i]!,
          showResource: resource,
        ));
      }

    } catch (_) {}
  }

  /// 切换图片/视频
  Future<void> switchResourceType(UserVisualStyleModel data, ResourceTypeEnum type) async{
    data.showResource = type;
    styleList.refresh();
    if(data.data.uid == videoPlayId.value){
      videoPlayId.value = -1;
      await player.pause();
      await player.seek(Duration.zero);
    }

  }

  /// 播放视频
  Future<void> playVideo(UserVisualStyleModel data) async{
    if(data.data.uid == null) return;
    if(data.data.video?.videoUrl == null) return;

    if(data.data.uid == videoPlayId.value){

      if(videoPlaying.value){
        await player.pause();
      }else{
        await player.play();
      }

      return;

    }
    videoPlayId.value = -1;
    await player.seek(Duration.zero);
    String? videoFile = await CacheManagerUtils.instance.getFile(data.data.video?.videoUrl, ResourceType.video);
    if(videoFile == null) return;

    Duration? start;
    Duration? end;
    if(data.data.video?.startSeconds != null){
      start = DateFormatUtil.secondsToDuration(data.data.video?.startSeconds??0);
    }
    if(data.data.video?.endSeconds != null){
      end = DateFormatUtil.secondsToDuration(data.data.video?.endSeconds??0);
    }
    if(data.data.video?.isMute == true){
      player.setVolume(0);
    }else{
      player.setVolume(100);
    }

    await player.open(Media(
      videoFile,
      start: start,
      end: end,
    ));
    videoPlayId.value = data.data.uid!;

  }


  /// 去充值
  Future<void> toRecharge() async{
    dynamic result = await TagRoutes.toNamed(
      Routes.RECHARGE_NAIBI,
      arguments: {
        "pageType": 1,
      },
    );
    if (result == null) return;
    if (result != true) return;
    ToastUtils.showToast(text: "充值乃币成功", type: ToastType.success);

    try {
      ToastUtils.showLoading();
      await getStyleList();
    } finally{
      ToastUtils.hideLoading();
    }

  }

  /// 管理风格
  Future<void> manageVisualStyle(BuildContext context) async{
    bool res = await UserManagementStyleDialog.show(
      context: context,
      teamStyeData: teamStyleData.value,
    );
    GuideTaskController.to.completeGuide(AppRoutesCode.userCenter, GuideWidgetIds.userCenterManageEffectiveStyleButton);
    if(!res) return;
    getStyleList();
    
  }

  /// 弹出激活弹窗
  Future<void> styleActivation(BuildContext context, UserVisualStyleModel data) async{
    
    if(data.showResource == ResourceTypeEnum.image){
      if(data.data.imageSubRights?.isLock??false) return ToastUtils.showToast(text: "未到开放日期");
      if(data.data.imageSubRights?.isNoRights??false){
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
      if(data.data.videoSubRights?.isNoRights??false){
        if(data.data.videoSubRights?.isLock??false) return ToastUtils.showToast(text: "未到开放日期");
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

    List<TeamStyleEntityStyleItems> styles = styleList.map((e) => e.data).toList();

    bool res = await UserStyleActivationDialog.subscriptionPay(
      context: context,
      resource: data.showResource,
      styleCode: data.data.style??"",
      styles: styles,
    );
    if(!res) return;
    getStyleList();
  }


  /// 取消订阅
  Future<void> unsubscribe(BuildContext context, UserVisualStyleModel data) async{
    if(data.showResource == ResourceTypeEnum.image){
      if(data.data.imageForbidUnsubscribed == true){
        return ToastUtils.showToast(text: "当前风格为默认订阅");
      }
    }else{
      if(data.data.videoForbidUnsubscribed == true){
        return ToastUtils.showToast(text: "当前风格为默认订阅");
      }
    }

    bool askRes = await AskDialog.showUserAsk(
      context: context,
      title: "温馨提示",
      content: "服务将持续至下个账单日(${teamStyleData.value.billingDate??''})，届时将不再扣费。您确定要取消订阅吗？",
    );
    if(!askRes) return;
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "imageStyleUses": [data.data.style],
      };
      bool res = await AccountUtil.teamStyleUnsubscribe(data: reqData);
      if(!res) return;
      ToastUtils.showToast(text: "取消成功", type: ToastType.success);
      getStyleList();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 重试
  Future<void> retry(BuildContext context) async{

    if(UserStore.to.userInfo.value.isFree) {
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

    List<TeamStyleEntityStyleItems> styles = styleList.map((e) => e.data).toList();

    bool res = await UserStyleActivationDialog.subscriptionPay(
      context: context,
      styles: styles,
      isRetry: true,
    );
    if(!res) return;
    getStyleList();

  }

  @override
  void onClose() {
    _playingSub?.cancel();
    _completedSub?.cancel();
    player.dispose();    
    super.onClose();

  }



}


class UserVisualStyleModel{

  TeamStyleEntityStyleItems data;

  /// 当前显示的类型
  ResourceTypeEnum showResource;

  UserVisualStyleModel({
    required this.data,
    this.showResource = ResourceTypeEnum.image,
  });

}
