import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../routes/routes.dart';
import '../../../../routes/routes_breadcrumb_utils.dart';

class AssessmentHistoryTimeMachineController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  AssessmentHistoryTimeMachineController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.ASSESSMENT_HISTORY_TIME_MACHINE;

  @override
  String get breadcrumbTitle => "历史评测";

  final RxList<AssessmentHistoryItemEntity> items = <AssessmentHistoryItemEntity>[].obs;
  final RxInt totalCount = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final Rx<AiAssessmentResultDetailEntity?> cards = Rx<AiAssessmentResultDetailEntity?>(null);

  final int limit = 30;

  late final PageController pageController;
  final RxDouble _page = 0.0.obs;

  double get page => _page.value;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    pageController = PageController(viewportFraction: 0.9);
    pageController.addListener(_onPage);
    loadInitial();
  }

  void _onPage() {
    final p = pageController.page;
    if (p == null) return;
    _page.value = p;

    if (items.isNotEmpty && (items.length - 1 - p) < 6) {
      loadMore();
    }
  }

  Future<void> loadInitial() async {
    if (isLoading.value) return;
    try {
      isLoading.value = true;
      items.clear();
      totalCount.value = 0;
      final resp = await PracticeQuestionsReqest.getAssessmentHistory(0, limit);
      if (resp == null) return;
      totalCount.value = resp.count ?? 0;
      items.addAll(resp.datas);
      getCurrent(items.first.assessmentId ?? 0);
    } finally {
      isLoading.value = false;
    }
  }

  getCurrent(int assessmentId) async {
    AiAssessmentResultDetailEntity? detail = await PracticeQuestionsReqest.getAiAssessmentResultDetail(assessmentId);
    if (detail != null) {
      cards.value = detail;
    }
  }

  bool get hasMore {
    final count = totalCount.value;
    if (count <= 0) return true;
    return items.length < count;
  }

  Future<void> loadMore() async {
    if (!hasMore) return;
    if (isLoadingMore.value) return;
    if (isLoading.value) return;
    try {
      isLoadingMore.value = true;
      final resp = await PracticeQuestionsReqest.getAssessmentHistory(items.length, limit);
      if (resp == null) return;
      totalCount.value = resp.count ?? totalCount.value;
      if (resp.datas.isEmpty) return;
      items.addAll(resp.datas);
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> jumpToIndex(int index) async {
    if (!pageController.hasClients) return;
    await pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
    getCurrent(items[index].assessmentId??0);
  }

  @override
  void onClose() {
    pageController.removeListener(_onPage);
    pageController.dispose();
    super.onClose();
  }
}
