import 'package:flutter/material.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../../theme/theme.dart';
import '../../../../../routes/routes.dart';
import '../../../common/commons.dart';
import '../bindings/manage_select_quzi_knowledge_binding.dart';
import '../controllers/manage_select_quzi_knowledge_controller.dart';

class ManageSelectQuziKnowledgeView extends GetView<ManageSelectQuziKnowledgeController> {
  final String tagText;
  const ManageSelectQuziKnowledgeView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_SELECT_QUZI_KNOWLEDGE}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageSelectQuziKnowledgeView(tagText: tag),
      binding: ManageSelectQuziKnowledgeBinding(tag: tag),
      routeName: Routes.MANAGE_SELECT_QUZI_KNOWLEDGE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      onRefresh: () {
        controller.getReviewQuizCount();
        controller.getQuizData();
        controller.getKnowledgeList();
      },
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: EdgeInsets.only(
          top: 10.wMin,
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                spacing: 24.wMin,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuizListWidget(),
                  Expanded(child: _buildKnowledgeWidget()),
                ],
              ),
            ),
            _buildBottomWidget(context),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizListWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.wMin),
          child: Text(
            "选择题目模版",
            style: TextStyle(
              fontSize: 22.wMin,
              color: const Color(0xffEBEFF5),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        SizedBox(height: 10.wMin),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 24.wMin),
          child: SizedBox(
            height: 450.wMin,
            child: Obx(() {
              return Row(
                spacing: 24.wMin,
                children: List.generate(controller.quizList.length, (index) {
                  return ManageQuizTemplateWidget(
                    data: controller.quizList[index],
                    selected: controller.selectTemplateIndex.value == index,
                    onTap: () => controller.selectTemplate(index),
                  );
                }),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildKnowledgeItem(int index, ManageUnitKnowledgeEntity data) {
    return Obx(() {
      bool fore = controller.isKnowledgeFore(data);
      return ManagePublicKnowledeRowItemWidget(
        onTap: () => controller.selectKnowledge(data),
        isSingle: controller.knowledgeSingle.value,
        selected: controller.selectKnowledgeUids.contains(data.uid),
        isFore: fore,
        content: data.isEnText ? data.title : data.content,
        imageUrl: data.imageUrl,
        language: controller.language,
        difficulty: data.difficulty?.min,
        audioUrl: data.audioUrl,
        definition: data.isEnText ? data.content : data.definition,
      );
    });
  }

  Widget _buildKnowledgeWidget() {
    Widget tabTextWidget(String text, int index) {
      return TapScaleWidget(
        onTap: () => controller.changeKnowledgeTabIndex(index),
        sclae: 1.1,
        child: Obx(() {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 2.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.wMin),
              color: controller.knowledgeTabIndex.value == index ? const Color(0xff22293C) : Colors.transparent,
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16.wMin,
                color: controller.knowledgeTabIndex.value == index ? const Color(0xffF2F4F9) : const Color(0xffACB4C0),
                fontWeight: FontWeight.w400,
              ),
            ),
          );
        }),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.wMin),
          child: Row(
            spacing: 24.wMin,
            children: [
              Text(
                "选择知识点",
                style: TextStyle(
                  fontSize: 22.wMin,
                  color: const Color(0xffEBEFF5),
                  fontWeight: FontWeight.w400,
                ),
              ),
              Row(
                children: [
                  tabTextWidget("全部", 0),
                  tabTextWidget("单词", 1),
                  tabTextWidget("短语", 2),
                  tabTextWidget("句子", 3),
                  tabTextWidget("文章", 4),
                ],
              ),
              const Spacer(),
              ManageTitleInputWidget(
                height: 40.wMin,
                width: 250.wMin,
                hintText: "搜索知识点",
                controller: controller.searchKnowledginput,
                onSubmitted: (text) {
                  controller.searchKnowledg();
                },
              ),
            ],
          ),
        ),
        SizedBox(height: 10.wMin),
        Expanded(
          child: Obx(() {
            return GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 6.wMin),
              itemCount: controller.showKnowledgeList.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 9,
                mainAxisSpacing: 24.wMin,
                crossAxisSpacing: 24.wMin,
                childAspectRatio: 180 / 295,
              ),
              itemBuilder: (context, index) {
                return _buildKnowledgeItem(index, controller.showKnowledgeList[index]);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildBottomWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 48.wMin,
        right: 48.wMin,
        bottom: 24.wMin,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Visibility(
            visible: UserStore.to.rolePermissions.value.userIsExerciseReviewer,
            child: Obx((){
              return ButtonWidget(
                text: "待审核 (${controller.reviewQuizCount.value})",
                borderRadius: 6.wMin,
                color: Colors.transparent,
                fontSize: 14.wMin,
                fontColor: controller.reviewQuizCount.value == 0 ? const Color(0xffEBEEF3) : AppTheme.cSurfaceBrand.color,
                padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 10.wMin),
                border: Border.all(
                  width: 1.wMin, 
                  color: controller.reviewQuizCount.value == 0 ? const Color(0xffEBEEF3) : AppTheme.cSurfaceBrand.color,
                ),
                onTap: () => controller.toReviewQuiz(),
              );
            }),
          ),
          SizedBox(width: 13.wMin),
          ButtonWidget(
            text: "取消",
            borderRadius: 6.wMin,
            color: Colors.transparent,
            fontSize: 14.wMin,
            fontColor: const Color(0xffEBEEF3),
            padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 10.wMin),
            border: Border.all(width: 1.wMin, color: const Color(0xff767E95)),
            onTap: () => controller.onCancel(),
          ),
          SizedBox(width: 13.wMin),
          ButtonWidget(
            text: "下一步",
            borderRadius: 6.wMin,
            color: const Color(0xff353E5C),
            fontSize: 14.wMin,
            fontColor: const Color(0xffEBEEF3),
            padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 10.wMin),
            border: Border.all(width: 1.wMin, color: const Color(0xff353E5C)),
            onTap: () {
              controller.nextButton(context);
            },
          ),
        ],
      ),
    );
  }
}
