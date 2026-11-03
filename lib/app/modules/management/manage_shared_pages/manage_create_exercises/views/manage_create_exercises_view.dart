import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/enum/enum.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../routes/routes.dart';
import 'package:langwise/app/modules/management/models/manage_knowledge_table_model.dart';
import '../../../common/commons.dart';
import '../bindings/manage_create_exercises_binding.dart';
import '../controllers/manage_create_exercises_controller.dart';
import 'manage_create_exercises_filter_dialog.dart';

class ManageCreateExercisesView extends GetView<ManageCreateExercisesController> {
  final String tagText;
  const ManageCreateExercisesView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_CREATE_EXERCISES}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageCreateExercisesView(tagText: tag),
      binding: ManageCreateExercisesBinding(tag: tag),
      routeName: Routes.MANAGE_CREATE_EXERCISES,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.wMin),
                _buildQuizTypeWidget(context),
                SizedBox(height: 10.wMin),
                _buildQuizTemplateListWidget(),
                SizedBox(height: 10.wMin),
                _buildSelectKnowledgeListWidget(context),
                SizedBox(height: 120.wMin),
              ],
            ),
          ),
          Positioned(
            right: 24.wMin,
            bottom: 24.wMin,
            child: _buildBottomWidget(context),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildFloatWidget(context),
    );
  }

  Widget _buildFloatWidget(BuildContext context) {
    return SizedBox(
      child: Obx(() {
        List<FilterButtonCondition> filters = [];

        List<ManageCreateExercisesFilterModel> lessonTemplateTypes =
            controller.filterData.value.lessonTemplateTypes ?? [];
        List<ManageCreateExercisesFilterModel> lessonTemplates =
            controller.filterData.value.lessonTemplates ?? [];
        List<ManageCreateExercisesFilterModel> quizTypes = controller.filterData.value.quizTypes ?? [];

        for (int i = 0; i < lessonTemplateTypes.length; i++) {
          filters.add(FilterButtonCondition(
            name: lessonTemplateTypes[i].name,
            color: const Color(0xff818CF8),
            isClose: true,
            onClear: () {
              controller.removeFilterLessonTemplateTypes(lessonTemplateTypes[i]);
            },
          ));
        }

        for (int i = 0; i < lessonTemplates.length; i++) {
          filters.add(FilterButtonCondition(
            name: lessonTemplates[i].name,
            color: const Color(0xffF97316),
            isClose: true,
            onClear: () {
              controller.removeFilterLessonTemplatelds(lessonTemplates[i]);
            },
          ));
        }

        for (int i = 0; i < quizTypes.length; i++) {
          filters.add(FilterButtonCondition(
            name: quizTypes[i].name,
            color: const Color(0xffBEC8D0),
            isClose: true,
            onClear: () {
              controller.removeFilterQuizTypes(quizTypes[i]);
            },
          ));
        }

        return FilterButtonWidget(
          filters: filters,
          onTap: () {
            controller.selectFilter(context);
          },
        );
      }),
    );
  }

  Widget _buildBottomWidget(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.wMin),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.wMin),
        padding: EdgeInsets.all(20.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          border: Border.all(width: 1.wMin, color: const Color(0xff353E5C)),
          color: const Color(0xff141828),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ButtonWidget(
              text: "取消",
              fontColor: const Color(0xffEBEFF5),
              color: Colors.transparent,
              border: Border.all(width: 2.wMin, color: const Color(0xff353E5C)),
              fontSize: 18.wMin,
              width: 100.wMin,
              height: 45.wMin,
              borderRadius: 4.wMin,
              sclae: 1.05,
              padding: EdgeInsets.symmetric(horizontal: 16.wMin),
              onTap: () {
                Get.back();
              },
            ),
            SizedBox(width: 12.wMin),
            ButtonWidget(
              text: "新建",
              fontColor: const Color(0xffEBEFF5),
              fontSize: 18.wMin,
              color: const Color(0xff2388FF),
              width: 100.wMin,
              height: 45.wMin,
              borderRadius: 4.wMin,
              sclae: 1.05,
              padding: EdgeInsets.symmetric(horizontal: 16.wMin),
              onTap: () {
                controller.onNext(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizTypeWidget(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(width: 24.wMin),
        Text(
          "选择题目模版",
          style: TextStyle(
            fontSize: 22.wMin,
            color: const Color(0xffEBEFF5),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildQuizTemplateListWidget() {
    return SizedBox(
      height: 480.wMin,
      child: Obx(() {
        return ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 24.wMin),
          scrollDirection: Axis.horizontal,
          itemCount: controller.exerciseTemplates.length,
          separatorBuilder: (context, index) => SizedBox(width: 16.wMin),
          itemBuilder: (context, index) {
            ManageLessonQuizTemplateEntity template = controller.exerciseTemplates[index];
            return Obx(() {
              bool selected =
                  controller.selectedExerciseTemplate.value?.config?.uid == template.config?.uid;
              return ManageQuizTemplateWidget(
                data: template,
                selected: selected,
                showIsExistExercise: true,
                onTap: () {
                  controller.selectExerciseTemplate(template);
                },
              );
            });
          },
        );
      }),
    );
  }

  Widget _buildSelectKnowledgeListWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(left: 24.wMin),
          child: Text(
            "选择知识点",
            style: TextStyle(
              fontSize: 22.wMin,
              color: const Color(0xffEBEFF5),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        SizedBox(height: 6.wMin),
        Row(
          children: [
            SizedBox(width: 24.wMin),
            Text(
              "已选择知识点",
              style: TextStyle(
                fontSize: 18.wMin,
                color: const Color(0xffBAC0CC),
                fontWeight: FontWeight.w400,
              ),
            ),
            const Spacer(),
            Obx(() {
              int minSelect = controller.selectedExerciseTemplate.value?.template?.contentsLen?.min ?? 1;
              int maxSelect = controller.selectedExerciseTemplate.value?.template?.contentsLen?.max ?? 4;
              int minRemaining = minSelect - controller.selectedKnowledge.length;
              int maxRemaining = maxSelect - controller.selectedKnowledge.length;
              List<ManageUnitKnowledgeEntity> selectedKnowledge = controller.getSelect();
              if(selectedKnowledge.isNotEmpty){
                ElementsCardType type = ElementsCardType.fromRawValue(selectedKnowledge.first.contentType ?? "");
                if (type == ElementsCardType.text || type == ElementsCardType.reveal || type == ElementsCardType.song || type == ElementsCardType.script) return Container();
              }
              
              return Text.rich(TextSpan(
                style: TextStyle(
                  fontSize: 18.wMin,
                  color: const Color(0xff767E95),
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  const TextSpan(text: "已选"),
                  TextSpan(
                      text: "${controller.selectedKnowledge.length}",
                      style: const TextStyle(color: Color(0xffFFFFFF))),
                  const TextSpan(text: "个，"),
                  TextSpan(
                    text: "最${minRemaining > 0 ? '少' : '多'}还可以选择${minRemaining > 0 ? minRemaining : maxRemaining}个",
                    style: const TextStyle(color: Color(0xff63DE77)),
                  ),
                ],
              ));
            }),
            SizedBox(width: 24.wMin),
          ],
        ),
        SizedBox(height: 10.wMin),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 24.wMin),
          child: Obx(() {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10.wMin,
              children: [
                ...List.generate(controller.selectedKnowledge.length, (index) {
                  return _buildSelectKnowledgeListItemWidget(controller.selectedKnowledge[index], index);
                }),
                _buildAddOtherWidget(context),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSelectKnowledgeListItemWidget(ManageKnowledgeTableModel model, int index) {
    String? content;
    String? imageUrl;
    String? audioUrl;
    String? definition;
    int? difficulty;
    if (model.type == ElementsCardType.word) {
      content = model.word?.content;
      imageUrl = model.word?.imageUrl;
      audioUrl = model.word?.audioUrl;
      definition = model.word?.definition;
      if (model.word?.difficulty is Map) {
        difficulty = model.word?.difficulty['min'];
      } else {
        difficulty = model.word?.difficulty;
      }
    } else if (model.type == ElementsCardType.phrase) {
      content = model.phrase?.content;
      imageUrl = model.phrase?.imageUrl;
      audioUrl = model.phrase?.audioUrl;
      definition = model.phrase?.definition;
      if (model.phrase?.difficulty is Map) {
        difficulty = model.phrase?.difficulty['min'];
      } else {
        difficulty = model.phrase?.difficulty;
      }
    } else if (model.type == ElementsCardType.sentence) {
      content = model.sentence?.content;
      imageUrl = model.sentence?.semantics?.first.imageUrl;
      audioUrl = model.sentence?.audioUrl;
      definition = model.sentence?.definition;
      if (model.sentence?.difficulty is Map) {
        difficulty = model.sentence?.difficulty['min'];
      } else {
        difficulty = model.sentence?.difficulty;
      }
    } else if (model.type == ElementsCardType.text) {
      content = model.text?.title;
      definition = model.text?.content;
      imageUrl = model.text?.imageUrl;
      audioUrl = model.text?.audioUrl;
      if (model.text?.difficulty is Map) {
        difficulty = model.text?.difficulty['min'];
      } else {
        difficulty = model.text?.difficulty;
      }
    } else if (model.type == ElementsCardType.reveal) {
      content = model.reveal?.title;
      definition = model.reveal?.content;
      imageUrl = model.reveal?.imageUrl;
      audioUrl = model.reveal?.audioUrl;
      if (model.reveal?.difficulty is Map) {
        difficulty = model.reveal?.difficulty['min'];
      } else {
        difficulty = model.reveal?.difficulty;
      }
    } else if (model.type == ElementsCardType.script) {
      content = model.script?.title?.firstWhereOrNull((element) => element?.lang == "zh")?.text;
      difficulty = model.script?.difficulty?.min;
    }



    return Obx(() {
      bool isSingle = controller.selectedExerciseTemplate.value?.template?.isKnowledgeSingle ?? false;
      return SizedBox(
        height: 290.wMin,
        width: 180.wMin,
        child: ManagePublicKnowledeRowItemWidget(
          isSingle: isSingle,
          content: content,
          imageUrl: imageUrl,
          language: "en",
          difficulty: difficulty,
          audioUrl: audioUrl,
          definition: definition,
          showTR: index != 0,
          svg: "assets/svg/manage/icon_bg_delete.svg",
          onTR: () {
            controller.removeSelectedKnowledge(model, index);
          },
        ),
      );
    });
  }

  Widget _buildAddOtherWidget(BuildContext context) {
    if (controller.knowledgeMaxSelect.value <= controller.selectedKnowledge.length) {
      return const SizedBox.shrink();
    }

    return TapScaleWidget(
      onTap: () {
        controller.showSelectKnowledgeDialog(context);
      },
      sclae: 1.01,
      child: Container(
        width: 180.wMin,
        height: 180.wMin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: const Color(0xffBEC8D0).withValues(alpha: 0.1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              "assets/svg/manage/icon_add.svg",
              width: 40.wMin,
            ),
            Text(
              "添加额外知识点",
              style: TextStyle(
                fontSize: 18.wMin,
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}
