import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/widgets/date_time_picker_widget.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../utils/utils.dart';


class ManageReviewVideoHistoryController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageReviewVideoHistoryController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_REVIEW_VIDEO_HISTORY;

  @override
  String get breadcrumbTitle => '审核历史';

  /// 是否是管理员进入
  bool fromAdmin = false;
  
  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);

  /// 重新审核的题目的任务id
  final RxInt reReviewTaskIndex = (-1).obs;

  /// 审核员列表
  final RxList<ContentReviewReviewerEntity> auditorList = RxList<ContentReviewReviewerEntity>();

  final RxList<VideoTaskEntityList> videoReviewList = RxList<VideoTaskEntityList>();
  final RxInt totalCount = 0.obs;
  int offset = 0;
  int limit = 5;
  final PagerController pagerController = PagerController();

  /// 筛选的用户id
  final RxInt selectedUserId = (-1).obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);

    DateTime now = DateTime.now();
    startDate.value = DateTime(now.year, now.month, now.day, 0, 0, 0).subtract(const Duration(days: 6));
    endDate.value = DateTime(now.year, now.month, now.day, 23, 59, 59);

    if(Get.arguments != null){
      fromAdmin = Get.arguments['fromAdmin']??false;
    }

    getAuditorList();
    getReviewHistoryList();
  }

  /// 获取审核员列表
  Future<void> getAuditorList() async{
    if(!fromAdmin) return;
    List<ContentReviewReviewerEntity>? list = await LanguageUtil.getVideoAuditorList();
    if(list == null) return;
    auditorList.clear();
    auditorList.add(ContentReviewReviewerEntity(uid: -1, userId: -1, userName: "全部审核员"));
    auditorList.addAll(list);
  }

  /// 查询审核历史
  Future<void> getReviewHistoryList() async {
    reReviewTaskIndex.value = -1;
    try {
      ToastUtils.showLoading();

      Map<String, dynamic> params = {
        "offset": offset,
        "limit": limit,
      };
      Map<String, dynamic> reqData = {};

      if(startDate.value != null && endDate.value != null){
        reqData['startDate'] = DateFormatUtil.formatStr(startDate.value!, newPattern: "yyyy-MM-dd HH:mm:ss");
        reqData['endDate'] = DateFormatUtil.formatStr(endDate.value!, newPattern: "yyyy-MM-dd HH:mm:ss");
      }

      ListResponseEntity<VideoTaskEntityList>? response;

      if(fromAdmin){
        // null = 自己 -1 = 全部
        reqData['userId'] = selectedUserId.value;
        response = await LanguageConsoleRequest.getVideoReviewHistoryList(params, reqData);
      }else{
        response = await LanguageUtil.getVideoReviewHistoryList(params, reqData);
      }

      if(response == null) return;
      totalCount.value = response.count??0;
      videoReviewList.value = response.datas??[];

    } finally{
      ToastUtils.hideLoading();
    }
  }


  /// 分页器回调
  void pagerCallback(int page, int pageSize) {
    offset = (page - 1) * pageSize;
    limit = pageSize;
    getReviewHistoryList();
  }


  /// 筛选时间
  Future<void> filterTime(BuildContext context) async {
    DateTimePickerUtils.showStartEndCalender(
      context: context,
      minDate: DateTime(2024, 11, 18),
      maxDate: DateTime.now(),
      initialStartDate: startDate.value,
      initialEndDate: endDate.value,
      onTap: (startDate, endDate) {
        var _startDate = DateTime(startDate.year, startDate.month, startDate.day, 0, 0, 0);
        var _endDate = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        this.startDate.value = _startDate;
        this.endDate.value = _endDate;
        pagerController.jumpToPage(1);
      },
    );
  }

  /// 筛选审核员
  void filterAuditor(int? userId){
    if(userId == null) return;
    selectedUserId.value = userId;
    pagerController.jumpToPage(1);
  }

  /// 清空筛选时间
  void clearFilterTime() {
    startDate.value = null;
    endDate.value = null;
    pagerController.jumpToPage(1);
  }

  /// 跳转至视频详情
  Future<void> toVideoDetail(VideoTaskEntityList? item, {VideoTaskEntityListVideos? video}) async{
    if(item == null) return;

    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_REVIEW_VIDEO_DETILS, 
      arguments: {
        "videoTaskId": item.taskId,
        "currentVideoId": video?.videoId,
      },
    );
    await getReviewHistoryList();
  }

  /// 查看统计
  Future<void> toStatistics() async{
    dynamic result = await ManagePageRegistry.jumpTo(Routes.MANAGE_REVIEW_VIDEO_STATISTICS);
    if(result == null) return;
    selectedUserId.value = result;
    pagerController.jumpToPage(1);
  }

  @override
  void onClose() {
    // TODO: 清理逻辑
    super.onClose();
  }
}
