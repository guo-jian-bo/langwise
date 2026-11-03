import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/https/https.dart';
import '../../../../../routes/routes.dart';
import '../../../utils/manage_breadcrumb_utils.dart';

class ManageQuizTemplateController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageQuizTemplateController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_QUIZ_TEMPLATE;

  @override
  String get breadcrumbTitle => '题目模版';

  final ScrollController gridViewController = ScrollController();

  final RxList<ManageQuizTemplateEntity> questionDataList = <ManageQuizTemplateEntity>[].obs;

  Map<String, int> deformationCount = <String, int>{};

  int allDeformationCount = 0;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    getQuizData();
  }

  Future<void> getQuizData() async {
    List<ManageQuizTemplateEntity>? res = await ManageQuizTemplateRequest.getQuizTemplateList();
    if (res == null) return;
    questionDataList.value = res;

    getQuizDeformationCount();
    getQuizDeformationCount(isStemOption: true);
  }

  void getQuizDeformationCount({bool isStemOption = false}) {
    if (questionDataList.isEmpty) return;

    allDeformationCount = 0;

    for (int i = 0; i < questionDataList.length; i++) {
      ManageQuizTemplateEntity data = questionDataList[i];
      if (data.template == null) continue;
      ManageQuizTemplateEntityTemplate template = data.template!;

      int all = 1;

      int displayModelScope = template.displayModelScope?.length ?? 0;
      if (displayModelScope != 0) {
        all *= displayModelScope;
      }

      int inputModeScope = template.inputModeScope?.length ?? 0;
      if (inputModeScope != 0) {
        all *= inputModeScope;
      }

      int breakdownLevel = template.breakdownLevel?.length ?? 0;
      if (breakdownLevel != 0) {
        all *= breakdownLevel;
      }

      int allowPreTeaching = template.allowPreTeaching?.length ?? 0;
      if (allowPreTeaching != 0) {
        all *= allowPreTeaching;
      }

      int allowFollowSentence = template.allowFollowSentence?.length ?? 0;
      if (allowFollowSentence != 0) {
        all *= allowFollowSentence;
      }

      int stemAudioScope = template.stemAudioScope?.length ?? 0;
      if (stemAudioScope != 0) {
        all *= stemAudioScope;
      }

      int optionAudioScope = template.optionAudioScope?.length ?? 0;
      if (optionAudioScope != 0) {
        all *= optionAudioScope;
      }

      int questionAudioScope = template.questionAudioScope?.length ?? 0;
      if (questionAudioScope != 0) {
        all *= questionAudioScope;
      }

      int hintsScope = template.hintsScope?.length ?? 0;
      if (hintsScope != 0) {
        all *= hintsScope;
        print("${template.type ?? ''}-${template.name ?? ''}");
      }

      int stemQuantityScope = 0;
      int optionQuantityScope = 0;

      if (isStemOption) {
        stemQuantityScope = template.stemQuantityScope?.length ?? 0;
        optionQuantityScope = template.optionQuantityScope?.length ?? 0;
        if (stemQuantityScope != 0) {
          all *= stemQuantityScope;
        }
        if (optionQuantityScope != 0) {
          all *= optionQuantityScope;
        }
      }

      allDeformationCount += all;

      deformationCount["${template.type ?? ''}-${template.name ?? ''}"] = all;
    }

  }

  Future<void> showDetilConfig(BuildContext context, ManageQuizTemplateEntity data) async {
    if (data.exercise == null) return;
    QuizConfigDialog.show(
      context: context,
      data: data,
      showCancel: false,
      title: "题型预览",
    );
  }
}
