import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/zhenxie/common/zhenxie_write_catalog_card_data.dart';
import 'package:langwise/app/modules/zhenxie/common/zhenxie_beat_utils.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/mixins/mixins.dart';
import 'package:langwise/common/widgets/ask_dialog.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../routes/routes.dart';

class ManageUnitWritingTaskListController extends GetxController with DualBreadcrumbMixin {
  final String tagText;
  ManageUnitWritingTaskListController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.MANAGE_UNIT_WRITING_TASK_LIST;

  @override
  String get breadcrumbTitle => '单元写作任务';

  int? unitId;
  bool isManagement = true;

  final ScrollController scrollController = ScrollController();
  final RxBool isLoading = false.obs;
  final Rxn<CourseUnitWritingTaskListEntity> detailData = Rxn<CourseUnitWritingTaskListEntity>();
  final RxList<String> beatNidOrderList = <String>[].obs;
  final Map<String, ParagraphRhetoricalEntityList> beatMap = <String, ParagraphRhetoricalEntityList>{};

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    final Map args = Get.arguments is Map ? Get.arguments : const {};
    unitId = _parseInt(args['unitId']);
    final dynamic isManagementValue = args['isManagement'];
    if (isManagementValue != null) {
      isManagement = isManagementValue == true || isManagementValue.toString() == 'true';
    }
    fetchData();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  Future<void> fetchData({bool showLoading = true}) async {
    if (unitId == null) {
      ToastUtils.showManageToast(text: '单元ID为空');
      return;
    }
    if (showLoading) {
      ToastUtils.showLoading();
    }
    try {
      isLoading.value = true;
      await ensureZhenxieBeatData();
      final CourseUnitWritingTaskListEntity? response = await CourseConsoleRequest.getUnitWritingTaskList(
        unitId!,
        isManagement: isManagement,
      );
      if (response == null) {
        if (isManagement) {
          ToastUtils.showManageToast(text: '写作任务加载失败');
        } else {
          ToastUtils.showToast(text: '写作任务加载失败');
        }
        return;
      }
      detailData.value = response;
    } finally {
      isLoading.value = false;
      if (showLoading) {
        ToastUtils.hideLoading();
      }
    }
  }

  Future<void> removeTask(BuildContext context, ContentCardData item) async {
    if (unitId == null || item.taskId == null) {
      ToastUtils.showManageToast(text: '任务信息为空');
      return;
    }
    final bool askRes = await AskDialog.showUserAsk(
      context: context,
      title: '删除任务',
      content: _buildRemoveTaskContent(item),
      titleColor: AppTheme.cSurfaceError.color,
      defineColor: AppTheme.cSurfaceError.color,
    );
    if (!askRes) return;
    try {
      ToastUtils.showLoading();
      final bool response = await CourseConsoleRequest.removeUnitWritingTask(unitId!, item.taskId!);
      if (!response) return;
      ToastUtils.showManageToast(text: '删除成功');
      await fetchData(showLoading: false);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  String _getTaskName(ContentCardData item) {
    final String nameText = getLangText(item.name, 'zh').trim();
    if (nameText.isNotEmpty) return nameText;
    final String titleText = getLangText(item.title, 'zh').trim();
    if (titleText.isNotEmpty) return titleText;
    return '';
  }

  String _buildRemoveTaskContent(ContentCardData item) {
    final List<String> names = <String>[
      if (item.compositionId != null) '范文 #${item.compositionId}',
      if (item.givenCompositionId != null) '给拍范文 #${item.givenCompositionId}',
    ];
    final String detachedExemplars = names.isEmpty ? '' : '，${names.join('、')} 跟着一起从这一课拿掉';
    return '只解除本单元的挂载$detachedExemplars。任务和范文都留在目录里，别的课不受影响。';
  }

  String getLangText(List<LanguageText>? values, String lang) {
    if (values == null || values.isEmpty) return '';
    for (int i = 0; i < values.length; i++) {
      if (values[i].lang == lang) {
        return values[i].text ?? '';
      }
    }
    return '';
  }

  String getDifficultyLabel(CardContentDifficulty? difficulty) {
    final String minDifficultyLabel = DifficultieUtils.getLanguageDifficultieLevel1('en', difficulty?.min)?.name?.text ?? '';
    final String maxDifficultyLabel = DifficultieUtils.getLanguageDifficultieLevel1('en', difficulty?.max)?.name?.text ?? '';
    if (minDifficultyLabel.isEmpty || maxDifficultyLabel.isEmpty) return '';
    return minDifficultyLabel == maxDifficultyLabel ? minDifficultyLabel : '$minDifficultyLabel-$maxDifficultyLabel';
  }

  String getGenreLabel(String? genreNid) {
    if (genreNid == 'narrative') return '记叙文';
    if (genreNid == 'expository') return '说明文';
    if (genreNid == 'argumentative') return '议论文';
    if (genreNid == 'practical') return '应用文';
    return genreNid ?? '';
  }

  Color getGenreColor(String? genreNid) {
    if (genreNid == 'narrative') return AppTheme.cSurfaceWarning.color;
    if (genreNid == 'expository') return AppTheme.cSurfaceSuccess.color;
    if (genreNid == 'argumentative') return AppTheme.cSurfaceInfo.color;
    if (genreNid == 'practical') return AppTheme.cTextBrand.color;
    return AppTheme.cTextSecondary.color;
  }

    String getAnswerTypeText(String? answerKind) {
      if (answerKind == 'text') return '文字';
      if (answerKind == 'image') return '图片';
      if (answerKind == 'audio') return '音频';
      if (answerKind == 'video') return '视频';
      return '';
  }

    String getAnswerDetailText(StageCardData? stage) {
      if (stage == null || stage.answerKind == null || stage.answerKind == 'text') return '';
      final int? answerMinCount = stage.answerMinCount;
      final int? answerMaxCount = stage.answerMaxCount;
    if (answerMinCount != null && answerMaxCount != null) {
        if (answerMinCount == answerMaxCount) return '$answerMinCount份';
      return '$answerMinCount-$answerMaxCount份';
    }
      if (answerMinCount != null) return '$answerMinCount份';
      if (answerMaxCount != null) return '$answerMaxCount份';
      return '';
  }

    String getBeatName(String? beatNid) {
      if (beatNid == 'head') return '文首';
      if (beatNid == 'tail') return '文末';
      final ParagraphRhetoricalEntityList? beat = beatMap[beatNid];
      return getLangText((beat?.name ?? const <LanguageText?>[]).whereType<LanguageText>().toList(), 'zh');
  }

  String getActionText(ContentCardData item) {
    return item.compositionId == null ? '写范文' : '范文';
  }
}
