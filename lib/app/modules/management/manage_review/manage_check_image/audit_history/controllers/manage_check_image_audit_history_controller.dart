import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/content_review_image.dart';
import 'package:langwise/utils/toast_utils.dart';

import '../../../../utils/manage_breadcrumb_utils.dart';
import '../../../../utils/manage_page_registry.dart';

class ManageCheckImageAuditHistoryController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageCheckImageAuditHistoryController({required this.tag});

  static ManageCheckImageAuditHistoryController get to => Get.find();

  List<String> difficultyList = ['Pre A1', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
  List<String> tabList = ['全部', '单词', '短语', '句子', '文章', '歌曲', '专栏'];
  final RxInt tabIndex = 0.obs;
  final TextEditingController searchInput = TextEditingController();

  final RxMap<int, bool> editingByTaskId = <int, bool>{}.obs;
  final RxMap<int, int> selectedImageIndexByTaskId = <int, int>{}.obs;
  final RxMap<int, int> hoveredImageIndexByTaskId = <int, int>{}.obs;
  final RxMap<int, bool> promptLoadingByTaskId = <int, bool>{}.obs;
  final Map<int, TextEditingController> promptControllersByTaskId = {};

  final Rxn<DateTime> startDate = Rxn<DateTime>();
  final Rxn<DateTime> endDate = Rxn<DateTime>();

  final RxList<ContentReviewImageAuditHistoryItem> list = <ContentReviewImageAuditHistoryItem>[].obs;

  final RxInt pageSize = 10.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalCount = 0.obs;
  final TextEditingController pageJumpController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxList<ContentReviewReviewerEntity> reviewers = <ContentReviewReviewerEntity>[].obs;
  final RxnInt selectedReviewerUserId = RxnInt(-1);
  bool fromAdmin =false;

  @override
  String get breadcrumbRoute => Routes.MANAGE_CHECK_IMAGE_AUDIT_HISTORY;
  
  @override
  String get breadcrumbTitle => '审核历史';

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    fromAdmin = Get.arguments['fromAdmin']??false;
    pageJumpController.text = '1';
    var now = DateTime.now();
    var start = now.subtract(const Duration(days: 6));
    startDate.value = DateTime(start.year, start.month, start.day, 0, 0, 0);
    endDate.value = DateTime(now.year, now.month, now.day, 23, 59, 59);
    fetchReviewers();
    fetchList();
  }

  Future<void> fetchReviewers() async {
    if(!fromAdmin){
      return;
    }
    final res = await ContentReviewImageUtil.reviewerList();
    final raw = res?.data ?? const <ContentReviewReviewerEntity>[];
    final list = <ContentReviewReviewerEntity>[
      ContentReviewReviewerEntity(uid: -1, userId: -1, userName: '全部审核员'),
      ...raw,
    ];
    reviewers.assignAll(list);
    reviewers.refresh();
  }

  void setReviewerUserId(int? userId) {
    selectedReviewerUserId.value = userId;
    currentPage.value = 1;
    pageJumpController.text = '1';
    fetchList();
  }

  void showAuditStatistics() {
    ManagePageRegistry.jumpTo(Routes.MANAGE_CHECK_IMAGE_AUDIT_STATISTICS).then((v){
      if(v == null) return;
      setReviewerUserId(v);
    });
  }

  int get totalPages {
    if (pageSize.value <= 0) return 1;
    if (totalCount.value <= 0) return 1;
    return ((totalCount.value - 1) ~/ pageSize.value) + 1;
  }

  void changePageSize(int size) {
    if (size <= 0) return;
    pageSize.value = size;
    currentPage.value = 1;
    pageJumpController.text = '1';
    fetchList();
  }

  void goToPage(int page) {
    if (page < 1) page = 1;
    if (totalPages > 0 && page > totalPages) page = totalPages;
    pageJumpController.text = page.toString();
    if (page == currentPage.value) return;
    currentPage.value = page;
    fetchList();
  }

  void goPrevPage() {
    if (currentPage.value <= 1) return;
    goToPage(currentPage.value - 1);
  }

  void goNextPage() {
    if (currentPage.value >= totalPages) return;
    goToPage(currentPage.value + 1);
  }

  List<int> buildVisiblePages() {
    final int total = totalPages;
    if (total <= 7) {
      return List<int>.generate(total, (i) => i + 1);
    }

    final int current = currentPage.value;
    final List<int> pages = [1];

    int start = current - 1;
    int end = current + 1;

    if (start <= 2) {
      start = 2;
      end = 4;
    } else if (end >= total - 1) {
      end = total - 1;
      start = total - 3;
    }

    for (int i = start; i <= end; i++) {
      pages.add(i);
    }

    if (!pages.contains(total)) {
      pages.add(total);
    }

    return pages.toSet().toList()..sort();
  }

  Future<void> fetchList() async {

    int? userId;

    if(fromAdmin){
      userId = selectedReviewerUserId.value;
    }
    if(isLoading.value) return;
    isLoading.value = true;
    ToastUtils.showLoading();

    ResponseEntity<ContentReviewImageAuditHistoryResponseData>? res;
    if(fromAdmin){
      res = await ContentReviewImageUtil.adminAuditHistory(
        content: searchInput.text,
        startDate: _formatDateFull(startDate.value),
        endDate: _formatDateFull(endDate.value),
        userId: userId,
        offset: (currentPage.value - 1) * pageSize.value,
        limit: pageSize.value,
      );
    }else{
      res = await ContentReviewImageUtil.auditHistory(
        content: searchInput.text,
        startDate: _formatDateFull(startDate.value),
        endDate: _formatDateFull(endDate.value),
        userId: userId,
        offset: (currentPage.value - 1) * pageSize.value,
        limit: pageSize.value,
      );
    }

    

    if (res == null) return;

    final newItems = res.data?.datas ?? const <ContentReviewImageAuditHistoryItem>[];
    final total = res.data?.count ?? 0;
    totalCount.value = total;
    list.assignAll(newItems);
    list.refresh();
    editingByTaskId.clear();
    for (final item in newItems) {
      _ensureTaskState(item);
    }
    isLoading.value = false;
    ToastUtils.hideLoading();
  }

  bool isEditing(ContentReviewImageAuditHistoryItem taskItem) {
    final taskId = taskItem.taskId ?? 0;
    if (taskId <= 0) return false;
    return editingByTaskId[taskId] ?? false;
  }

  void enterEditMode(ContentReviewImageAuditHistoryItem taskItem) {
    final taskId = taskItem.taskId ?? 0;
    if (taskId <= 0) return;
    _ensureTaskState(taskItem);
    editingByTaskId[taskId] = true;
    editingByTaskId.refresh();
  }

  int getSelectedImageIndex(ContentReviewImageAuditHistoryItem taskItem) {
    final taskId = taskItem.taskId ?? 0;
    if (taskId <= 0) return 0;
    final selected = selectedImageIndexByTaskId[taskId] ?? 0;
    final len = (taskItem.images?.length ?? taskItem.imageIds?.length ?? 0);
    if (len <= 0) return 0;
    if (selected >= len) return 0;
    return selected;
  }

  void setSelectedImageIndex(ContentReviewImageAuditHistoryItem taskItem, int index) {
    final taskId = taskItem.taskId ?? 0;
    if (taskId <= 0) return;
    selectedImageIndexByTaskId[taskId] = index;
    selectedImageIndexByTaskId.refresh();
  }

  int? getHoveredImageIndex(ContentReviewImageAuditHistoryItem taskItem) {
    final int taskId = taskItem.taskId ?? 0;
    if (taskId <= 0) return null;
    return hoveredImageIndexByTaskId[taskId];
  }

  void setHoveredImageIndex(ContentReviewImageAuditHistoryItem taskItem, int? index) {
    final int taskId = taskItem.taskId ?? 0;
    if (taskId <= 0) return;
    if (index == null) {
      hoveredImageIndexByTaskId.remove(taskId);
    } else {
      hoveredImageIndexByTaskId[taskId] = index;
    }
    hoveredImageIndexByTaskId.refresh();
  }

  TextEditingController getPromptController(ContentReviewImageAuditHistoryItem taskItem) {
    final taskId = taskItem.taskId ?? 0;
    if (taskId <= 0) {
      return TextEditingController(text: taskItem.prompt ?? '');
    }

    final existing = promptControllersByTaskId[taskId];
    if (existing != null) return existing;

    final controller = TextEditingController(text: taskItem.prompt ?? '');
    promptControllersByTaskId[taskId] = controller;
    return controller;
  }

  String getPromptText(ContentReviewImageAuditHistoryItem taskItem) {
    return getPromptController(taskItem).text;
  }

  void _ensureTaskState(ContentReviewImageAuditHistoryItem taskItem) {
    final taskId = taskItem.taskId ?? 0;
    if (taskId <= 0) return;

    editingByTaskId.putIfAbsent(taskId, () => false);
    promptControllersByTaskId.putIfAbsent(taskId, () => TextEditingController(text: taskItem.prompt ?? ''));

    selectedImageIndexByTaskId.putIfAbsent(taskId, () {
      final imgs = taskItem.images;
      if (imgs == null || imgs.isEmpty) return 0;
      final index = imgs.indexWhere((e) => e.option == true);
      return index >= 0 ? index : 0;
    });

    promptLoadingByTaskId.putIfAbsent(taskId, () => false);
  }

  // void _disposeTaskState(ContentReviewImageAuditHistoryItem taskItem) {
  //   final int taskId = taskItem.taskId ?? 0;
  //   if (taskId <= 0) return;
  //   editingByTaskId.remove(taskId);
  //   selectedImageIndexByTaskId.remove(taskId);
  //   hoveredImageIndexByTaskId.remove(taskId);
  //   promptLoadingByTaskId.remove(taskId);
  //   final c = promptControllersByTaskId.remove(taskId);
  //   c?.dispose();
  // }

  bool isPromptLoading(ContentReviewImageAuditHistoryItem taskItem) {
    final int taskId = taskItem.taskId ?? 0;
    if (taskId <= 0) return false;
    return promptLoadingByTaskId[taskId] ?? false;
  }

  ///重新生成图片（编辑模式）
  Future<void> reGenerateImage(ContentReviewImageAuditHistoryItem taskItem) async {
    final taskId = taskItem.taskId ?? 0;
    if (taskId <= 0) return;
    final prompt = getPromptText(taskItem);

    final res = await ContentReviewImageUtil.regenerateV2(taskId: taskId, prompt: prompt);
    if (res != null) {
      ToastUtils.showToast(text: '已提交重新生成', type: ToastType.success);
      // currentPage.value = 1;
      // pageJumpController.text = '1';
      await fetchList();
    }
  }

  ///审核通过（编辑模式）
  Future<void> auditPass(ContentReviewImageAuditHistoryItem taskItem) async {
    final int index = getSelectedImageIndex(taskItem);
    final int taskId = taskItem.taskId ?? 0;
    bool confirmed = false;
    if (taskId <= 0) return;

    if (index < 0) {
      ToastUtils.showToast(text: '请先选择一张图片', type: ToastType.warning);
      return;
    }

    final int imageId = taskItem.images != null && taskItem.images!.length > index
        ? (taskItem.images![index].imageId ?? 0)
        : (taskItem.imageIds != null && taskItem.imageIds!.length > index ? taskItem.imageIds![index] : 0);

    final String selectedImageUrl = taskItem.images != null && taskItem.images!.length > index
        ? (taskItem.images![index].imageUrl ?? '')
        : '';
    final approvedRes = await ContentReviewImageUtil.approvedList(taskId);
    final approvedImages = approvedRes?.data ?? const <ContentReviewApprovedImage>[];
    if (approvedImages.isEmpty) {
      var res = await ContentReviewImageUtil.approve(
        relationUid: taskItem.promptId ?? 0,
        imageId: imageId,
        taskId: taskId,
      );
      if (res != null) {
        confirmed = true;
      }
    } else {
      confirmed = await ManagePageRegistry.jumpTo<bool>(
          Routes.APPROVED_IMAGES_CONFIRM,
          arguments: {
            'images': approvedImages,
            'relationUid': taskItem.promptId ?? 0,
            'imageId': imageId,
            'taskId': taskId,
            'selectedImageId': imageId,
            'selectedImageUrl': selectedImageUrl,
          }) ?? false;
    }

    if (confirmed) {
      ToastUtils.showToast(text: '审核通过', type: ToastType.success);
      // currentPage.value = 1;
      // pageJumpController.text = '1';
      await fetchList();
    }
  }

  ///重新生成prompt（编辑模式）
  Future<void> reGeneratePrompt(ContentReviewImageAuditHistoryItem taskItem) async {
    final int relationUid = taskItem.promptId ?? 0;
    final int promptId = taskItem.promptId ?? 0;
    final int taskId = taskItem.taskId ?? 0;
    if (relationUid <= 0 || promptId <= 0) return;

    if (taskId > 0) {
      promptLoadingByTaskId[taskId] = true;
      promptLoadingByTaskId.refresh();
    }

    final res = await ContentReviewImageUtil.loadPromptV3(relationUid: relationUid, promptId: promptId);

    if (taskId > 0) {
      promptLoadingByTaskId[taskId] = false;
      promptLoadingByTaskId.refresh();
    }

    if (res != null) {
      final newPrompt = res.data?.prompt;
      if (newPrompt != null) {
        final c = promptControllersByTaskId[taskId];
        if (c == null) return;
        c.text = newPrompt;
      }
    }
  }

  void setDate({DateTime? mStartDate, DateTime? mEndDate}) {
    startDate.value = mStartDate;
    endDate.value = mEndDate;
    currentPage.value = 1;
    pageJumpController.text = '1';
    fetchList();
  }

  void clearDateRange() {
    startDate.value = null;
    endDate.value = null;
    currentPage.value = 1;
    pageJumpController.text = '1';
    fetchList();
  }

  String formatDateLabel(DateTime? value) {
    if (value == null) return '选择日期';
    return _formatDate(value);
  }

  String _formatDate(DateTime? value) {
    if (value == null) return '';
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
    final h = value.hour.toString().padLeft(2,'0');
    final min = value.minute.toString().padLeft(2,'0');
    final s = value.second.toString().padLeft(2,'0');
    return '$y-$m-$d $h:$min:$s';
  }

  @override
  void onClose() {
    searchInput.dispose();
    pageJumpController.dispose();
    for (final c in promptControllersByTaskId.values) {
      c.dispose();
    }
    promptControllersByTaskId.clear();
    editingByTaskId.clear();
    selectedImageIndexByTaskId.clear();
    hoveredImageIndexByTaskId.clear();
    promptLoadingByTaskId.clear();
    super.onClose();
  }
}
