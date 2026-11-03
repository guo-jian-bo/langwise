import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/content_review_image_entities.dart';
import 'package:langwise/common/https/content_review_image.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/utils/toast_utils.dart';

import '../../../utils/manage_breadcrumb_utils.dart';
import '../../../utils/manage_page_registry.dart';

class ManageCheckImageController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageCheckImageController({required this.tag});

  List<String> tabList = ['全部', '单词', '短语', '句子', '文章', '歌曲', '专栏'];
  List<String> difficultyList = ['Pre A1', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
  List<int>? taskIds;
  String? content;
  Map<String, dynamic>? subContent;

  /// 搜索
  final TextEditingController searchInput = TextEditingController();

  /// 是否点击了输入框 如果点击了那么禁用页面收起键盘350毫秒 350毫秒之后再允许点击
  final RxBool isSearchClick = false.obs;
  final RxInt tabIndex = 0.obs;
  RxBool isLoading = true.obs;
  RxList<ContentReviewImageTaskItem> checkList = RxList<ContentReviewImageTaskItem>();
  final RxList<ContentReviewImageTaskItem> allCheckList = <ContentReviewImageTaskItem>[].obs;
  final RxString searchKeyword = ''.obs;

  final RxMap<int, int> selectedImageIndexByTaskId = <int, int>{}.obs;
  final RxMap<int, int> hoveredImageIndexByTaskId = <int, int>{}.obs;
  final RxMap<int, bool> promptLoadingByTaskId = <int, bool>{}.obs;
  final Map<int, TextEditingController> promptControllersByTaskId = {};

  @override
  String get breadcrumbRoute => Routes.MANAGE_CHECK_IMAGE;
  
  @override
  String get breadcrumbTitle => '审核图片';

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);

    if (Get.arguments != null) {
      taskIds = Get.arguments['taskIds'];
      content = Get.arguments['content'];
      subContent = Map<String, dynamic>.from(Get.arguments['subContent']??{});
      searchInput.text = content??'';
    }

    initCheckList();
  }

  void showAll() {
    taskIds?.clear();
    searchInput.clear();
    initCheckList();
  }

  void initCheckList() async {
    isLoading.value = true;
    ToastUtils.showLoading();
    var response = await ContentReviewImageUtil.reviewedList(content: '', taskIds: taskIds, subContent: subContent);
    if (response != null) {
      final list = response.data?.list ?? <ContentReviewImageTaskItem>[];
      allCheckList
        ..clear()
        ..addAll(list);

      checkList.value = List<ContentReviewImageTaskItem>.from(allCheckList);
      for (final item in checkList) {
        _ensureTaskState(item);
      }

      onSearchChanged(searchInput.text);
    }
    isLoading.value = false;
    ToastUtils.hideLoading();
  }

  void onSearchChanged(String value) {
    searchKeyword.value = value;
    final keyword = value.trim();
    if (keyword.isEmpty) {
      checkList.value = List<ContentReviewImageTaskItem>.from(allCheckList);
    } else {
      final k = keyword.toLowerCase();
      checkList.value = allCheckList.where((e) => (e.content ?? '').toLowerCase().contains(k)).toList();
    }
    for (final item in checkList) {
      _ensureTaskState(item);
    }
    checkList.refresh();
  }

  int getSelectedImageIndex(ContentReviewImageTaskItem taskItem) {
    final int taskId = taskItem.taskId ?? 0;
    if (taskId <= 0) return -1;
    final int selected = selectedImageIndexByTaskId[taskId] ?? -1;

    final int len = (taskItem.images?.length ?? taskItem.imageIds?.length ?? 0);
    if (len <= 0) return -1;
    if (selected < 0) return -1;
    if (selected >= len) return -1;
    return selected;
  }

  void setSelectedImageIndex(ContentReviewImageTaskItem taskItem, int index) {
    final int taskId = taskItem.taskId ?? 0;
    if (taskId <= 0) return;
    if (selectedImageIndexByTaskId[taskId] == index) {
      selectedImageIndexByTaskId[taskId] = -1;
    } else {
      selectedImageIndexByTaskId[taskId] = index;
    }
    selectedImageIndexByTaskId.refresh();
  }

  int? getHoveredImageIndex(ContentReviewImageTaskItem taskItem) {
    final int taskId = taskItem.taskId ?? 0;
    if (taskId <= 0) return null;
    return hoveredImageIndexByTaskId[taskId];
  }

  void setHoveredImageIndex(ContentReviewImageTaskItem taskItem, int? index) {
    final int taskId = taskItem.taskId ?? 0;
    if (taskId <= 0) return;
    if (index == null) {
      hoveredImageIndexByTaskId.remove(taskId);
    } else {
      hoveredImageIndexByTaskId[taskId] = index;
    }
    hoveredImageIndexByTaskId.refresh();
  }

  TextEditingController getPromptController(ContentReviewImageTaskItem taskItem) {
    final int taskId = taskItem.taskId ?? 0;
    if (taskId <= 0) {
      return TextEditingController(text: taskItem.prompt ?? '');
    }

    final existing = promptControllersByTaskId[taskId];
    if (existing != null) return existing;

    final controller = TextEditingController(text: taskItem.prompt ?? '');
    promptControllersByTaskId[taskId] = controller;
    return controller;
  }

  String getPromptText(ContentReviewImageTaskItem taskItem) {
    return getPromptController(taskItem).text;
  }

  void _ensureTaskState(ContentReviewImageTaskItem taskItem) {
    final int taskId = taskItem.taskId ?? 0;
    if (taskId <= 0) return;
    selectedImageIndexByTaskId.putIfAbsent(taskId, () {
      final imgs = taskItem.images;
      if (imgs == null || imgs.isEmpty) return -1;
      final index = imgs.indexWhere((e) => e.option == true);
      return index >= 0 ? index : -1;
    });
    promptControllersByTaskId.putIfAbsent(taskId, () => TextEditingController(text: taskItem.prompt ?? ''));
    promptLoadingByTaskId.putIfAbsent(taskId, () => false);
  }

  void _disposeTaskState(ContentReviewImageTaskItem taskItem) {
    final int taskId = taskItem.taskId ?? 0;
    if (taskId <= 0) return;
    _disposeTaskStateByTaskId(taskId);
  }

  void _disposeTaskStateByTaskId(int taskId) {
    if (taskId <= 0) return;
    selectedImageIndexByTaskId.remove(taskId);
    hoveredImageIndexByTaskId.remove(taskId);
    promptLoadingByTaskId.remove(taskId);
    final controller = promptControllersByTaskId.remove(taskId);
    controller?.dispose();
  }

  bool isPromptLoading(ContentReviewImageTaskItem taskItem) {
    final int taskId = taskItem.taskId ?? 0;
    if (taskId <= 0) return false;
    return promptLoadingByTaskId[taskId] ?? false;
  }

  ///重新生成promt和图片
  void reGenerateImage(ContentReviewImageTaskItem taskItem) async {
    try {
      ToastUtils.showLoading();
      final taskId = taskItem.taskId ?? 0;
      if (taskId <= 0) return;

      var res = await ContentReviewImageUtil.createImage(taskId: taskId);
      if (res != null) {
        ToastUtils.showToast(text: '已提交重新生成', type: ToastType.success);
        _disposeTaskState(taskItem);
        allCheckList.remove(taskItem);
        checkList.value = List<ContentReviewImageTaskItem>.from(allCheckList);
        checkList.refresh();
        // initCheckList();
      }
    } finally{
      ToastUtils.hideLoading();
    }
  }

  ///删除任务
  Future<void> deleteTask(ContentReviewImageTaskItem taskItem) async {
    try {
      ToastUtils.showLoading();
      final int taskId = taskItem.taskId ?? 0;
      if (taskId <= 0) return;

      final res = await ContentReviewImageUtil.delete(taskId: taskId);
      final bool ok = (res?.code == 200);
      ToastUtils.showToast(text: ok ? '已删除' : '删除失败', type: ok ? ToastType.success : ToastType.error);
      if (ok) {
        _disposeTaskState(taskItem);
        allCheckList.remove(taskItem);
        checkList.value = List<ContentReviewImageTaskItem>.from(allCheckList);
        checkList.refresh();
      }
    } finally{
      ToastUtils.hideLoading();
    }
  }

  ///放弃任务
  Future<void> abandonTask(ContentReviewImageTaskItem taskItem) async {
    try {
      ToastUtils.showLoading();
      final int taskId = taskItem.taskId ?? 0;
      if (taskId <= 0) return;

      final res = await ContentReviewImageUtil.abandon(taskId: taskId);
      final bool ok = (res?.code == 200);
      ToastUtils.showToast(text: ok ? '已放弃' : '放弃失败', type: ok ? ToastType.success : ToastType.error);
      if (ok) {
        _disposeTaskState(taskItem);
        allCheckList.remove(taskItem);
        checkList.value = List<ContentReviewImageTaskItem>.from(allCheckList);
        checkList.refresh();
        // initCheckList();
      }
    } finally{
      ToastUtils.hideLoading();
    }
  }

  ///审核通过
  void auditPass(ContentReviewImageTaskItem taskItem) async {
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

    final String selectedImageUrl = taskItem.images != null && taskItem.images!.length > index ? (taskItem.images![index].imageUrl ?? '') : '';
    final approvedRes = await ContentReviewImageUtil.approvedList(taskId);
    final approvedImages = approvedRes?.data ?? const <ContentReviewApprovedImage>[];
    if (approvedImages.isEmpty) {
      try {
        ToastUtils.showLoading();
        var res = await ContentReviewImageUtil.approve(
          relationUid: taskItem.promptId ?? 0,
          imageId: imageId,
          taskId: taskId,
        );
        if (res != null) {
          confirmed = true;
        }
      } finally{
        ToastUtils.hideLoading();
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
        },
      ) ?? false;
    }

    if (confirmed) {
      ToastUtils.showToast(text: "审核通过", type: ToastType.success);
      _disposeTaskState(taskItem);
      allCheckList.remove(taskItem);
      checkList.value = List<ContentReviewImageTaskItem>.from(allCheckList);
      checkList.refresh();
      // initCheckList();
    }
  }

  ///重新生成prompt
  void reGeneratePrompt(ContentReviewImageTaskItem taskItem) async {
    try {
      ToastUtils.showLoading();
      final int relationUid = taskItem.promptId ?? 0;
      final int promptId = taskItem.promptId ?? 0;
      final int taskId = taskItem.taskId ?? 0;
      if (relationUid <= 0 || promptId <= 0) return;

      // if (taskId > 0) {
      //   promptLoadingByTaskId[taskId] = true;
      //   promptLoadingByTaskId.refresh();
      // }

      final prompt = getPromptText(taskItem);

      var res = await ContentReviewImageUtil.regenerateV2(taskId: taskId, prompt: prompt);
      if (res != null) {
        ToastUtils.showToast(text: '已提交重新生成', type: ToastType.success);
        _disposeTaskState(taskItem);
        allCheckList.remove(taskItem);
        checkList.value = List<ContentReviewImageTaskItem>.from(allCheckList);
        checkList.refresh();
      }


      // if (taskId > 0) {
      //   promptLoadingByTaskId[taskId] = false;
      //   promptLoadingByTaskId.refresh();
      // }

      // if (res != null) {
      //   final newPrompt = res.data?.prompt;
      //   if (newPrompt != null) {
      //     final controller = promptControllersByTaskId[taskId];
      //     if (controller == null) return;
      //     controller.text = newPrompt;
      //   }
      // }
    } finally{
      ToastUtils.hideLoading();
    }
  }

  ///查看审核历史
  void showAuditHistory({bool isAdmin = false}) {
    ManagePageRegistry.jumpTo(Routes.MANAGE_CHECK_IMAGE_AUDIT_HISTORY, arguments: {"fromAdmin": isAdmin});
  }

  ///再审核一批
  Future<void> auditMore() async {
    isLoading.value = true;
    ToastUtils.showLoading();
    var res = await ContentReviewImageUtil.distributeTask();
    if (res != null) {
      searchInput.text = '';

      final list = res.data?.list ?? <ContentReviewImageTaskItem>[];
      allCheckList
        ..clear()
        ..addAll(list);

      checkList.value = List<ContentReviewImageTaskItem>.from(allCheckList);
      for (final item in checkList) {
        _ensureTaskState(item);
      }

      onSearchChanged(searchInput.text);
    }
    isLoading.value = false;
    ToastUtils.hideLoading();
  }

  @override
  void onClose() {
    
    for (final controller in promptControllersByTaskId.values) {
      controller.dispose();
    }
    promptControllersByTaskId.clear();
    selectedImageIndexByTaskId.clear();
    hoveredImageIndexByTaskId.clear();
    promptLoadingByTaskId.clear();
    super.onClose();
  }
}
