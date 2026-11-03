import 'dart:async';

import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';
import 'package:video_player/video_player.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../routes/routes.dart';
import '../../../../utils/utils.dart';

class ManageReviewAssDetilsController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageReviewAssDetilsController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_REVIEW_ASS_DETILS;

  @override
  String get breadcrumbTitle => '编辑字幕';

  /// 页面参数
  int? assTaskId;

  /// 当前任务详情。
  final Rx<AssTaskEntityList> assData = AssTaskEntityList().obs;

  /// 媒体播放器。
  final Player player = Player();

  


  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    if (Get.arguments != null) {
      assTaskId = Get.arguments['assTaskId'];
      getDataDetils();
      
    }
  }

  /// 获取任务详情，并在成功后解析当前任务的 ASS 数据。
  Future<void> getDataDetils() async {
    if (assTaskId == null) return;
    try {
      ToastUtils.showLoading();
      final Map<String, dynamic> reqData = <String, dynamic>{
        "assTaskId": assTaskId,
      };
      final AssTaskEntityList? res = await LanguageUtil.getAssDatils(data: reqData);
      if (res == null) return;
      assData.value = res;
    } finally {
      ToastUtils.hideLoading();
    }
  }


  @override
  void onClose() {
    unawaited(player.dispose());
    super.onClose();
  }
}
