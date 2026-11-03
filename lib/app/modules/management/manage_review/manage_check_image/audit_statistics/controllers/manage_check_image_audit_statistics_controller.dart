import 'package:get/get.dart';
import 'package:langwise/common/entities/content_review_image_entities.dart';
import 'package:langwise/common/https/content_review_image.dart';
import 'package:langwise/common/stores/stores.dart';

import '../../../../../../routes/routes.dart';
import '../../../../utils/manage_breadcrumb_utils.dart';

class ManageCheckImageAuditStatisticsController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageCheckImageAuditStatisticsController({required this.tag});

  final RxBool isLoading = true.obs;
  final Rxn<ContentReviewImageAuditStatisticsResponseData> statistics = Rxn<ContentReviewImageAuditStatisticsResponseData>();

  final Rxn<DateTime> startDate = Rxn<DateTime>();
  final Rxn<DateTime> endDate = Rxn<DateTime>();
  final RxBool onlyMe = true.obs;

  @override
  String get breadcrumbRoute => Routes.MANAGE_CHECK_IMAGE_AUDIT_STATISTICS;
  
  @override
  String get breadcrumbTitle => '审核统计';

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    
    var now = DateTime.now();
    var startDay = now.subtract(Duration(days: 6));
    startDate.value = DateTime(startDay.year, startDay.month, startDay.day, 0, 0, 0);
    endDate.value = DateTime(now.year, now.month, now.day, 23, 59, 59);
    fetchStatistics();
  }

  void setDate({DateTime? mStartDate, DateTime? mEndDate}) {
    startDate.value = mStartDate;
    endDate.value = mEndDate;
    fetchStatistics();
  }

  void clearDateRange() {
    startDate.value = null;
    endDate.value = null;
    fetchStatistics();
  }

  void toggleOnlyMe() {
    onlyMe.value = !onlyMe.value;
    fetchStatistics();
  }

  String formatDateLabel(DateTime? value) {
    if (value == null) return '选择日期';
    return _formatDate(value);
  }

  String _formatDate(DateTime value) {
    final y = value.year.toString().padLeft(4, '0');
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _formatDateFull(DateTime? value) {
    if (value == null) return '';
    final y = value.year.toString().padLeft(4, '0');
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    final hh = value.hour.toString().padLeft(2, '0');
    final mm = value.minute.toString().padLeft(2, '0');
    final ss = value.second.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm:$ss';
  }

  Future<void> fetchStatistics() async {
    isLoading.value = true;
    final int? uid = int.tryParse(UserStore.to.userId);
    final res = await ContentReviewImageUtil.auditStatistics(
      startDate: _formatDateFull(startDate.value),
      endDate: _formatDateFull(endDate.value),
      userId: onlyMe.value ? uid : null,
    );
    if (res != null) {
      statistics.value = res.data;
    }
    isLoading.value = false;
  }

  @override
  void onClose() {
    super.onClose();
  }

}
