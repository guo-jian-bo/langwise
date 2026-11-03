import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/stores/stores.dart';
import '../../../../../../../common/widgets/date_time_picker_widget.dart';
import '../../../../../../routes/routes.dart';
import '../../../../utils/manage_breadcrumb_utils.dart';

class ManageReviewExercisesStatisticsController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageReviewExercisesStatisticsController({required this.tag});

  
  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);

  /// 重新审核的题目下标
  final RxInt reReviewIndex = (-1).obs;

  /// 自己/全部
  final RxInt selfOrAll = 0.obs;

  /// 统计
  final Rx<ExerciseReviewStatisticsEntity> statistics = ExerciseReviewStatisticsEntity().obs;

  final RxList<ExerciseReviewStatisticsEntityAuditorStats> rankingList = <ExerciseReviewStatisticsEntityAuditorStats>[].obs;


  @override
  String get breadcrumbRoute => Routes.MANAGE_REVIEW_EXERCISES_STATISTICS;
  
  @override
  String get breadcrumbTitle => '审核统计';

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);

    DateTime now = DateTime.now();
    startDate.value = DateTime(now.year, now.month, now.day, 0, 0, 0).subtract(const Duration(days: 6));
    endDate.value = DateTime(now.year, now.month, now.day, 23, 59, 59);
    
    getStatistics();

  }



  /// 获取统计
  Future<void> getStatistics() async {
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {};

      if(startDate.value != null && endDate.value != null){
        reqData['startDate'] = DateFormatUtil.formatStr(startDate.value!, newPattern: "yyyy-MM-dd HH:mm:ss");
        reqData['endDate'] = DateFormatUtil.formatStr(endDate.value!, newPattern: "yyyy-MM-dd HH:mm:ss");
      }
      if(selfOrAll.value == 0){
        reqData['userId'] = UserStore.to.userInfo.value.userId;
      }

      ExerciseReviewStatisticsEntity? res = await ExerciseReviewRequest.getExerciseReviewStatistics(reqData);
      if(res == null) return;
      statistics.value = res;
      List<ExerciseReviewStatisticsEntityAuditorStats?> auditorStats = res.auditorStats??[];
      rankingList.clear();
      for(int i = 0; i < auditorStats.length; i++){
        if(auditorStats[i] == null) continue;
        rankingList.add(auditorStats[i]!);
      }


    } finally{
      ToastUtils.hideLoading();
    }
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
        getStatistics();
      },
    );
  }


  /// 清空筛选时间
  void clearFilterTime() {
    startDate.value = null;
    endDate.value = null;
    getStatistics();
  }

  /// 切换自己/全部
  void switchSelfOrAll(int type) {
    selfOrAll.value = type;
    getStatistics();
  }



  /// 点击每一行
  void onTapRankingItem(ExerciseReviewStatisticsEntityAuditorStats item) {
    if(item.userId == null) return;
    Get.back(result: item.userId);
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
