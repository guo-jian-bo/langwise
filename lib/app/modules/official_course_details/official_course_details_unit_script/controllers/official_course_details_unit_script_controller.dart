import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/enum/enum.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/stores/stores.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../routes/app_pages.dart';
import '../../../../routes/tag_routes.dart';

class OfficialCourseDetailsUnitScriptController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  OfficialCourseDetailsUnitScriptController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.OFFICIAL_COURSE_DETAILS_UNIT_SCRIPT_LIST;

  @override
  String get breadcrumbTitle => "单元剧场";

  int? courseId;
  int? levelId;
  int? moduleId;
  int? unitId;
  String? specialty;
  bool isManageCourse = false;

  String courseName = '';
  String moduleName = '';
  String unitName = '';

  final RxInt loadStatus = (-1).obs;
  final RxList<ZhenduScriptEntity> items = <ZhenduScriptEntity>[].obs;

  @override
  void onInit() {
    super.onInit();
    
    final arguments = Get.arguments;
    if (arguments is Map) {
      courseId = arguments['courseId'];
      levelId = arguments['levelId'];
      moduleId = arguments['moduleId'];
      unitId = arguments['unitId'];
      specialty = arguments['specialty']?.toString();
      isManageCourse = arguments['isManageCourse'] == true;
      courseName = arguments['courseName']?.toString() ?? '';
      moduleName = arguments['moduleName']?.toString() ?? '';
      unitName = arguments['unitName']?.toString() ?? '';
    }
    initBreadcrumb(tagText, title: unitName);
    fetchList();
  }

  Future<void> fetchList() async {
    if (courseId == null || moduleId == null || unitId == null) {
      loadStatus.value = 1;
      return;
    }
    try {
      loadStatus.value = -1;
      ToastUtils.showLoading();
      final resp = await OfficialCourseDetailsRequest.getUnitScriptList(
        courseId!,
        moduleId!,
        unitId!,
      );
      items.assignAll(resp);
      loadStatus.value = resp.isEmpty ? 4 : 0;
    } catch (_) {
      loadStatus.value = 1;
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> openScriptDetail(ZhenduScriptEntity item) async {
    final context = Get.context;
    final scriptId = item.uid;
    if (context == null || scriptId == null) return;
    final rights = item.cardRights;
    if (rights != null) {
      final locked = await LockUtils.checkLock(rights, context);
      if (locked) return;
    }
    UserStore.to.getUserInfo();
    await TagRoutes.toNamed(
      Routes.ZHENDU_SHOW_DETAIL,
      arguments: {
        'contentId': scriptId,
        'locate': item.locate,
        'styleId': item.styleId,
        'dialect': item.dialect,
      },
    );
    await fetchList();
  }

  Future<void> toCourseListPage() async {
    if (courseId == null) return;
    if (specialty == SpecialtyEnum.EN_PHONICS) {
      await TagRoutes.offAndToNamed(
        Routes.PHONICS_COURSE,
        arguments: {
          "courseId": courseId,
          "isSelectModule": true,
        },
      );
      return;
    }
    const targetRoute = Routes.OFFICIAL_COURSE_DETAILS_LEVEL;
    if (AppPages.history.contains(targetRoute)) {
      Get.until((route) => route.settings.name == targetRoute);
      return;
    }
    await TagRoutes.offNamed(
      Routes.OFFICIAL_COURSE_DETAILS_LEVEL,
      arguments: {
        "courseId": courseId,
        "levelId": levelId,
        "moduleId": moduleId,
        "isFromCustomCourse": isManageCourse,
        "isSelectModule": true,
        "scrollToLevelId": levelId,
        "showRecommend": true,
        "scrollToStudyZoneEnum": StudyZoneEnum.study,
      },
    );
  }

  Future<void> toCourseDetailsPage() async {
    if (AppPages.history.contains(Routes.OFFICIAL_COURSE_DETAILS)) {
      Get.until((route) => route.settings.name == Routes.OFFICIAL_COURSE_DETAILS);
      return;
    }
    if (courseId == null || levelId == null || moduleId == null) return;
    await TagRoutes.offNamed(
      Routes.OFFICIAL_COURSE_DETAILS,
      arguments: {
        "courseId": courseId,
        "levelId": levelId,
        "moduleId": moduleId,
        "unitId": unitId,
      },
    );
  }

  String getDisplayTitle(ZhenduScriptEntity item) {
    final learning = LearningLangUtils.getLearningLang(item.title)?.text;
    if (learning != null && learning.trim().isNotEmpty) return learning.trim();
    final local = LearningLangUtils.getLocalLang(item.title)?.text;
    if (local != null && local.trim().isNotEmpty) return local.trim();
    return '';
  }

  String getDisplaySubtitle(ZhenduScriptEntity item) {
    final local = LearningLangUtils.getLocalLang(item.title)?.text;
    final learning = LearningLangUtils.getLearningLang(item.title)?.text;
    if (local != null &&
        local.trim().isNotEmpty &&
        local.trim() != learning?.trim()) {
      return local.trim();
    }
    final sourceName = item.source?.name?.trim() ?? '';
    if (sourceName.isNotEmpty) return sourceName;
    return '';
  }

  String getDurationLabel(ZhenduScriptEntity item) {
    final seconds = _durationWeight(item);
    final minutes = seconds ~/ 60;
    final remain = seconds % 60;
    return '$minutes:${remain.toString().padLeft(2, '0')}';
  }

  String getSourceLine(ZhenduScriptEntity item) {
    final sourceName = item.source?.name?.trim() ?? '';
    if (sourceName.isNotEmpty) return sourceName;
    return 'LangWise Official Course';
  }

  String getResolvedCoverUrl(ZhenduScriptEntity item) {
    final coverUrl = item.coverUrl?.trim() ?? '';
    if (coverUrl.isNotEmpty) return coverUrl;
    final imageUrls = _readImageUrls(item);
    if (imageUrls.isNotEmpty) return imageUrls.first;
    return '';
  }

  String getTagText(ZhenduTagEntity tag) {
    final local = LearningLangUtils.getLocalLang(tag.gloss)?.text;
    if (local != null && local.trim().isNotEmpty) return local.trim();
    final learning = LearningLangUtils.getLearningLang(tag.gloss)?.text;
    if (learning != null && learning.trim().isNotEmpty) return learning.trim();
    return '';
  }

  List<String> getMetaLabels(ZhenduScriptEntity item) {
    final labels = <String>[
      _pickLocaleText(item.locateTitle),
      _pickLocaleText(item.styleTitle),
      _pickLocaleText(item.dialectTitle),
    ];
    return labels.where((e) => e.trim().isNotEmpty).toList();
  }

  String _pickLocaleText(List<LanguageText>? list) {
    if (list == null || list.isEmpty) return '';
    String? chineseText;
    for (final item in list) {
      final code = (item.lang ?? '').trim().toLowerCase();
      final text = (item.text ?? '').trim();
      if (text.isEmpty) continue;
      if (code == 'zh') return text;
      if (chineseText == null &&
          (code.startsWith('zh-') || code.startsWith('zh_'))) {
        chineseText = text;
      }
    }
    if (chineseText != null) return chineseText;
    for (final item in list) {
      final text = (item.text ?? '').trim();
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  List<String> _readImageUrls(ZhenduScriptEntity item) {
    final raw = item.source?.data?['imageUrls'];
    if (raw is! List) return const <String>[];
    return raw
        .map((e) => e?.toString().trim() ?? '')
        .where((e) => e.isNotEmpty)
        .toList();
  }

  int _durationWeight(ZhenduScriptEntity item) {
    if (item.duration != null && item.duration! > 0) {
      return item.duration!.round();
    }
    final sceneCount = item.sceneCount ?? 1;
    return sceneCount * 35;
  }
}
