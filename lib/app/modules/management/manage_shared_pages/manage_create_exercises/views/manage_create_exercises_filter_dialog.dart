import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_button.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../common/enum/enum.dart';
import '../../../../../../common/https/https.dart';
import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../../theme/theme.dart';

class ManageCreateExercisesFilterResult {
  List<ManageCreateExercisesFilterModel>? lessonTemplateTypes;
  List<ManageCreateExercisesFilterModel>? lessonTemplates;
  List<ManageCreateExercisesFilterModel>? quizTypes;

  ManageCreateExercisesFilterResult({
    this.lessonTemplateTypes,
    this.lessonTemplates,
    this.quizTypes,
  });
}

class ManageCreateExercisesFilterModel {
  String name;
  dynamic value;

  ManageCreateExercisesFilterModel({
    required this.name,
    required this.value,
  });
}

class ManageCreateExercisesFilterDialog {
  static Future<ManageCreateExercisesFilterResult?> show({
    required BuildContext context,
    ManageCreateExercisesFilterResult? initialData,
    String? contentType,
    int? contentId,
    int? semanticId,
    List<LessonTypeEnum>? forceLessonTemplateTypes,
  }) async {
    return await showCupertinoDialog<ManageCreateExercisesFilterResult?>(
      context: context,
      builder: (context) {
        return ManageCreateExercisesFilterDialogWidget(
          initialData: initialData,
          contentType: contentType,
          contentId: contentId,
          semanticId: semanticId,
          forceLessonTemplateTypes: forceLessonTemplateTypes,
        );
      },
    );
  }
}

class ManageCreateExercisesFilterDialogWidget extends StatefulWidget {
  final ManageCreateExercisesFilterResult? initialData;
  final String? contentType;
  final int? contentId;
  final int? semanticId;
  final List<LessonTypeEnum>? forceLessonTemplateTypes;
  const ManageCreateExercisesFilterDialogWidget({
    super.key,
    this.initialData,
    this.contentType,
    this.contentId,
    this.semanticId,
    this.forceLessonTemplateTypes,
  });

  @override
  State<ManageCreateExercisesFilterDialogWidget> createState() => _ManageCreateExercisesFilterDialogWidgetState();
}

class _ManageCreateExercisesFilterDialogWidgetState extends State<ManageCreateExercisesFilterDialogWidget> {
  List<LessonTypeEnum> lessonTypes = LessonTypeEnum.values;
  List<ManageCreateExercisesFilterModel> lessonTemplateTypes = [];

  List<ManageLessonTemplateEntityDatas> lessonTemplateList = [];
  List<ManageCreateExercisesFilterModel> lessonTemplates = [];

  List<ExerciseTypeListEntity> quizTypeList = [];
  List<ManageCreateExercisesFilterModel> selectedQuizTypes = [];

  @override
  void initState() {
    super.initState();
    if (widget.forceLessonTemplateTypes != null) {
      lessonTypes = (widget.forceLessonTemplateTypes ?? []).toList();
    }
    if (widget.initialData != null) {
      lessonTemplateTypes = (widget.initialData?.lessonTemplateTypes ?? []).toList();
      lessonTemplates = (widget.initialData?.lessonTemplates ?? []).toList();
      selectedQuizTypes = (widget.initialData?.quizTypes ?? []).toList();
    }

    getLessonTemplates();
  }

  Future<void> getLessonTemplates() async {
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "offset": 0,
        "limit": 10000,
        "order": "-order",
      };

      List types = lessonTemplateTypes.map((e) => e.value).toList();

      Map<String, dynamic> reqData = {
        "types": types.isEmpty ? null : types,
        "contentType": widget.contentType,
      };
      ManageLessonTemplateEntity? template = await ManageLessonTemplateRequest.getLessonTemplateData(reqData, parameters);
      if (template == null) return;
      List<ManageLessonTemplateEntityDatas?> datas = template.datas ?? [];

      lessonTemplateList.clear();
      for (var data in datas) {
        if (data == null) continue;
        lessonTemplateList.add(data);
      }

      if (mounted) setState(() {});

      getQuizTypeList();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> getQuizTypeList() async {
    List lessonTemplateIds = lessonTemplates.map((e) => e.value).toList();

    Map<String, dynamic> parameters = {};

    if (lessonTemplateIds.isNotEmpty) {
      parameters["lessonTemplateIds"] = lessonTemplateIds;
    }

    List types = lessonTemplateTypes.map((e) => e.value).toList();
    if (types.isNotEmpty) {
      parameters["lessonTemplateTypes"] = types;
    }

    Map<String, dynamic> reqData = {
      "uid": widget.contentId,
      "type": widget.contentType,
      "semanticId": widget.semanticId,
    };

    try {
      ToastUtils.showLoading();
      List<ExerciseTypeListEntity>? list = await ManageExerciseRequest.getExerciseTypeList(reqData, parameters: parameters);
      if (list == null) return;
      quizTypeList.clear();
      quizTypeList.addAll(list);
      if (mounted) setState(() {});
    } finally {
      ToastUtils.hideLoading();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Stack(
          children: [
            Container(
              width: 1200.wMin,
              height: 800.wMin,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.wMin),
                color: const Color(0xff1D2021).withValues(alpha: 0.95),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(24.wMin),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 24.wMin,
                        children: [
                          _buildLessonTypeWidget(),
                          _buildLessonWidget(),
                          _buildQuizTypeWidget(),
                        ],
                      ),
                    ),
                  ),
                  _buildButtonsWidget(),
                ],
              ),
            ),
            Positioned(
              right: 16.wMin,
              top: 16.wMin,
              child: TapScaleWidget(
                sclae: 1.05,
                onTap: () => Get.back(),
                child: Container(
                  width: 42.wMin,
                  height: 42.wMin,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.cSurfaceTertiary.color,
                  ),
                  child: SvgPicture.asset(
                    "assets/svg/public/x.svg",
                    width: 24.wMin,
                    height: 24.wMin,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonTypeWidget() {
    return Column(
      spacing: 8.wMin,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleTextWidget("课时类型"),
        Row(
          spacing: 12.wMin,
          children: List.generate(lessonTypes.length, (index) {
            bool selected = lessonTemplateTypes.where((type) => type.value == lessonTypes[index].value).isNotEmpty;

            return Expanded(
              child: TapScaleWidget(
                onTap: () {
                  if (selected) {
                    if (widget.forceLessonTemplateTypes != null) {
                      if (widget.forceLessonTemplateTypes!.contains(lessonTypes[index])) {
                        return;
                      }
                    }

                    lessonTemplateTypes.removeWhere((type) => type.value == lessonTypes[index].value);
                    if (lessonTemplateTypes.isEmpty) {
                      lessonTemplates.clear();
                    }
                  } else {
                    lessonTemplateTypes.add(ManageCreateExercisesFilterModel(
                      value: lessonTypes[index].value,
                      name: lessonTypes[index].name,
                    ));
                  }
                  if (mounted) setState(() {});
                  getLessonTemplates();
                },
                sclae: 1,
                child: _buildFilterItemWidget(
                  value: lessonTypes[index].name,
                  isSelected: selected,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildLessonWidget() {
    if (lessonTemplateList.isEmpty) return Container();
    return Column(
      spacing: 8.wMin,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleTextWidget("课时模版"),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: lessonTemplateList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12.wMin,
            crossAxisSpacing: 12.wMin,
            mainAxisExtent: 64.wMin,
          ),
          itemBuilder: (context, index) {
            bool selected = lessonTemplates.where((template) => template.value == lessonTemplateList[index].uid).isNotEmpty;

            return TapScaleWidget(
              sclae: 1,
              onTap: () {
                if (selected) {
                  lessonTemplates.removeWhere((template) => template.value == lessonTemplateList[index].uid);
                } else {
                  lessonTemplates.add(ManageCreateExercisesFilterModel(
                    value: lessonTemplateList[index].uid,
                    name: lessonTemplateList[index].name ?? "",
                  ));
                }
                getQuizTypeList();
                if (mounted) setState(() {});
              },
              child: _buildFilterItemWidget(
                value: lessonTemplateList[index].name ?? "",
                isSelected: selected,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuizTypeWidget() {
    if (quizTypeList.isEmpty) return Container();
    return Column(
      spacing: 8.wMin,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleTextWidget("题目类型"),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: quizTypeList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12.wMin,
            crossAxisSpacing: 12.wMin,
            mainAxisExtent: 64.wMin,
          ),
          itemBuilder: (context, index) {
            bool selected = selectedQuizTypes.where((type) => type.value == quizTypeList[index].type).isNotEmpty;

            return TapScaleWidget(
              sclae: 1,
              onTap: () {
                if (selected) {
                  selectedQuizTypes.removeWhere((type) => type.value == quizTypeList[index].type);
                } else {
                  selectedQuizTypes.add(ManageCreateExercisesFilterModel(
                    value: quizTypeList[index].type,
                    name: quizTypeList[index].name ?? "",
                  ));
                }
                if (mounted) setState(() {});
              },
              child: _buildFilterItemWidget(
                value: quizTypeList[index].name ?? "",
                isSelected: selected,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFilterItemWidget({required String value, bool isSelected = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      height: 64.wMin,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: Colors.white.withValues(alpha: isSelected ? 0.3 : 0.08),
      ),
      child: Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 24.wMin,
          color: const Color(0xffE8EDF4),
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildTitleTextWidget(String value) {
    return Text(
      value,
      style: TextStyle(
        fontSize: 24.wMin,
        color: const Color(0xffE8EDF4),
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildButtonsWidget() {
    return Container(
      padding: EdgeInsets.all(24.wMin),
      child: Row(
        spacing: 12.wMin,
        children: [
          ManageButton(
            text: "重置",
            width: 350.wMin,
            height: 72.wMin,
            radius: 12.wMin,
            color: const Color(0xff46494C),
            borderColor: Colors.transparent,
            sclae: 1.02,
            style: TextStyle(
              fontSize: 28.wMin,
              color: const Color(0xffBEC8D0),
              fontWeight: FontWeight.w400,
            ),
            onTap: () {
              lessonTemplates.clear();
              lessonTemplateTypes.clear();
              selectedQuizTypes.clear();

              if (lessonTemplateTypes.isEmpty) {
                lessonTemplateList.clear();
              } else {
                getLessonTemplates();
              }
              if (mounted) setState(() {});
            },
          ),
          Expanded(
            child: ManageButton(
              text: "确定",
              height: 72.wMin,
              radius: 12.wMin,
              color: const Color(0xff38BDF8),
              borderColor: Colors.transparent,
              sclae: 1.005,
              style: TextStyle(
                fontSize: 28.wMin,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
              onTap: () {
                ManageCreateExercisesFilterResult result = ManageCreateExercisesFilterResult(
                  lessonTemplateTypes: lessonTemplateTypes,
                  lessonTemplates: lessonTemplates,
                  quizTypes: selectedQuizTypes,
                );
                Get.back(result: result);
              },
            ),
          ),
        ],
      ),
    );
  }
}
