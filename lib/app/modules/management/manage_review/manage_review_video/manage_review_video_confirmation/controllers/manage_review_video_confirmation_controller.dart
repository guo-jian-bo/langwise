import 'package:get/get.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/stores/stores.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../utils/utils.dart';

class ManageReviewVideoConfirmationController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageReviewVideoConfirmationController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_REVIEW_VIDEO_CONFIRMATION;

  @override
  String get breadcrumbTitle => '审核确认';

  String? videoUrl;
  int? videoTaskId;
  int? videoIdSelected;
  bool isMute = false;
  int? startSeconds;
  int? endSeconds;
  int? realDuration;
  List<String>? lines;
  VideoTaskEntityListApprovedVideo? approvedVideo;


  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);

    if(Get.arguments != null){
      videoUrl = Get.arguments['videoUrl'];
      videoTaskId = Get.arguments['videoTaskId'];
      videoIdSelected = Get.arguments['videoIdSelected'];
      isMute = Get.arguments['isMute']??false;
      startSeconds = Get.arguments['startSeconds'];
      endSeconds = Get.arguments['endSeconds'];
      realDuration = Get.arguments['realDuration'];
      lines = Get.arguments['lines'];
      approvedVideo = VideoTaskEntityListApprovedVideo.fromJson(Get.arguments['approvedVideo']);
    }

  }


  /// 沿用已有视频
  Future<void> usingExistingVideos() async{
    bool isAuthDelete = ManageAuthUtils.isAuth(ManageAuthCode.adminVideoReviewTaskDelete);
    if(UserStore.to.rolePermissions.value.isOfficial && isAuthDelete){
      deleteTask();
    }else{
      giveUpTask();
    }
  }


  /// 删除任务
  Future<void> deleteTask() async{
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "videoTaskId": videoTaskId,
      };
      bool response = await LanguageConsoleRequest.deleteVideoTask(data: reqData);
      if(!response) return;
      Get.back(result: {"type": "remove"});
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 放弃任务
  Future<void> giveUpTask() async{

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "videoTaskId": videoTaskId,
      };
      bool response = await LanguageUtil.videoReviewGiveUp(data: reqData);
      if(!response) return;
      ToastUtils.showToast(text: '放弃成功', type: ToastType.success);
      Get.back(result: {"type": "remove"});
    } finally{
      ToastUtils.hideLoading();
    }
  }




  /// 审核通过
  Future<void> videoApprove() async{
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "videoTaskId": videoTaskId,
        "videoIdSelected": videoIdSelected,
        "isMute": isMute,
        "startSeconds": DateFormatUtil.millisecondsToSecondsWithDecimal(startSeconds!), 
        "endSeconds": DateFormatUtil.millisecondsToSecondsWithDecimal(endSeconds!),
        "realDuration": DateFormatUtil.millisecondsToSecondsWithDecimal(realDuration!),
        "lines": lines,
      };
      bool response = await LanguageUtil.videoApprove(data: reqData);
      if(!response) return;
      ToastUtils.showToast(text: '审核成功', type: ToastType.success);
      Get.back(result: {"type": "remove"});
    } finally{
      ToastUtils.hideLoading();
    }
  }

  @override
  void onClose() {
    // TODO: 清理逻辑
    super.onClose();
  }
}
