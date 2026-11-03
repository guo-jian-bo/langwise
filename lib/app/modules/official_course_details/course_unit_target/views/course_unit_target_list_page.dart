import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:animated_reorderable_list/animated_reorderable_list.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../utils/utils.dart';
import '../../../elements/common/elements_cards/elements_public_card.dart';
import '../controllers/course_unit_target_controller.dart';
import 'course_unit_target_grammar_card_widget.dart';
import 'course_unit_target_writing_card_widget.dart';

class CourseUnitTargetListPage extends StatelessWidget {
  final CourseUnitTargetController controller;
  const CourseUnitTargetListPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSyntaxTitleWidget(),
        Expanded(
          child: Obx(() {
            if (controller.currentKnowledgeType.value == CourseUnitTargetEnum.syntax) {
              if (controller.syntaxTab.value != 0) {
                return _buildSyntaxListWidget();
              }
            }
            final bool isSortingMode = controller.isManagement && controller.manageKnowledgeController.isSortingMode.value;
            final knowledgeList = isSortingMode ? _getCurrentSortKnowledgeList() : _getCurrentKnowledgeList();
            if (knowledgeList.isEmpty) {
              return NotDataWidget(message: "暂无数据");
            }
            return _buildListWidget(knowledgeList, context);
          }),
        ),
      ],
    );
  }

  /// 语法标题组件
  Widget _buildSyntaxTitleWidget() {
    return Obx(() {
      if (controller.currentKnowledgeType.value != CourseUnitTargetEnum.syntax) return SizedBox.shrink();
      int sentenceCount = controller.knowledgeController.allSyntaxKnowledgeList.length;
      int groupCount = controller.syntaxController.syntaxStatistics.value?.realizationSetCount??0;
      int grammarCount = controller.syntaxController.syntaxStatistics.value?.pointCount??0;
      String sentenceTone = controller.syntaxController.syntaxStatistics.value?.summary??"";
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 90.wMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSize(
              duration: Duration(milliseconds: 200),
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: double.infinity,
                child: Visibility(
                  visible: sentenceTone.isNotEmpty,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4.wMin),
                      Text(
                        "语法基调",
                        style: TextStyle(
                          fontSize: 20.wMin,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.cTextSecondary.color,
                        ),
                      ),
                      SizedBox(height: 4.wMin),
                      Text(
                        sentenceTone,
                        style: TextStyle(
                          fontSize: 24.wMin,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.cTextPrimary.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.wMin),
            Row(
              spacing: 12.wMin,
              children: [
                _buildSyntaxTabItemWidget(
                  index: 0,
                  text: "句子 $sentenceCount",
                ),
                _buildSyntaxTabItemWidget(
                  index: 1,
                  text: "句组 $groupCount",
                ),
                _buildSyntaxTabItemWidget(
                  index: 2,
                  text: "语法 $grammarCount",
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSyntaxTabItemWidget({
    required int index,
    required String text,
  }) {
    return Obx(() {
      bool isSelected = controller.syntaxTab.value == index;
      return TapScaleWidget(
        onTap: () {
          controller.switchSyntaxType(index);
        },
        sclae: 1.03,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 8.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            color: isSelected ? AppTheme.cSurfaceWarning.color.withValues(alpha: 0.12) : AppTheme.cSurfaceLayerElevated.color,
            border: Border.all(
              color: isSelected ? AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2) : AppTheme.cSurfaceTranslucentThin.color,
              width: 0.8.wMin,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w500,
              color: isSelected ? AppTheme.cSurfaceWarning.color : AppTheme.cTextSecondary.color,
            ),
          ),
        ),
      );
    });
  }

  /// 获取当前选中分类下的知识点列表。
  List<KnowledgeCommonEntityList> _getCurrentKnowledgeList() {
    final CourseUnitTargetEnum knowledgeType = controller.currentKnowledgeType.value;
    final knowledgeController = controller.knowledgeController;
    if (knowledgeType == CourseUnitTargetEnum.vocabulary) return knowledgeController.vocabularyKnowledgeList;
    if (knowledgeType == CourseUnitTargetEnum.syntax) return knowledgeController.syntaxKnowledgeList;
    if (knowledgeType == CourseUnitTargetEnum.listening) return knowledgeController.listeningKnowledgeList;
    if (knowledgeType == CourseUnitTargetEnum.reading) return knowledgeController.readingKnowledgeList;
    if (knowledgeType == CourseUnitTargetEnum.writing) return knowledgeController.writingKnowledgeList;
    if (knowledgeType == CourseUnitTargetEnum.comprehensive) return knowledgeController.comprehensiveKnowledgeList;
    return knowledgeController.allKnowledgeList.toList();
  }

  /// 获取当前选中分类下用于排序的原始知识点列表。
  List<KnowledgeCommonEntityList> _getCurrentSortKnowledgeList() {
    final CourseUnitTargetEnum knowledgeType = controller.currentKnowledgeType.value;
    final knowledgeController = controller.knowledgeController;
    if (knowledgeType == CourseUnitTargetEnum.vocabulary) return knowledgeController.allVocabularyKnowledgeList;
    if (knowledgeType == CourseUnitTargetEnum.syntax) return knowledgeController.allSyntaxKnowledgeList;
    if (knowledgeType == CourseUnitTargetEnum.listening) return knowledgeController.allListeningKnowledgeList;
    if (knowledgeType == CourseUnitTargetEnum.reading) return knowledgeController.allReadingKnowledgeList;
    if (knowledgeType == CourseUnitTargetEnum.writing) return knowledgeController.allWritingKnowledgeList;
    if (knowledgeType == CourseUnitTargetEnum.comprehensive) return knowledgeController.allComprehensiveKnowledgeList;
    return knowledgeController.allKnowledgeList.toList();
  }

  /// 构建知识点网格列表，排序模式下切换为可拖拽排序组件。
  Widget _buildListWidget(List<KnowledgeCommonEntityList> list, BuildContext context) {
    final CourseUnitTargetEnum knowledgeType = controller.currentKnowledgeType.value;
    final manageController = controller.manageKnowledgeController;
    final bool isSortingMode = controller.isManagement && manageController.isSortingMode.value;
    int crossAxisCount = 4;
    if (knowledgeType == CourseUnitTargetEnum.vocabulary || knowledgeType == CourseUnitTargetEnum.syntax) {
      crossAxisCount = 5;
    } else if (knowledgeType == CourseUnitTargetEnum.writing) {
      crossAxisCount = 3;
    }

    Widget listWidget = Container();

    double? mainAxisExtent;
    double childAspectRatio = 1.0;
    if (knowledgeType == CourseUnitTargetEnum.writing) {
      childAspectRatio = 580 / 410;
      if(controller.isManagement){
        mainAxisExtent = 510.wMin; //510
      }else{
        mainAxisExtent = 460.wMin;
      }
    } else {
      if (knowledgeType == CourseUnitTargetEnum.syntax) {
        childAspectRatio = 417 / 750;
      } else {
        childAspectRatio = controller.isManagement ? 420 / 670 : 420 / 652;
      }
    }

    if (isSortingMode) {
      listWidget = AnimatedReorderableGridView<KnowledgeCommonEntityList>(
        key: ValueKey("${knowledgeType.rawValue}_${list.length}_sort"),
        items: list,
        padding: EdgeInsets.only(
          bottom: 220.wMin + MediaQuery.of(context).padding.bottom,
          left: 90.wMin,
          right: 90.wMin,
        ),
        dragStartDelay: const Duration(milliseconds: 200),
        sliverGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 24.wMin,
          crossAxisSpacing: 24.wMin,
          childAspectRatio: childAspectRatio,
          mainAxisExtent: mainAxisExtent,
        ),
        isSameItem: _isSameKnowledgeItem,
        itemBuilder: (context, index) {
          final KnowledgeCommonEntityList item = list[index];
          return KeyedSubtree(
            key: ValueKey("${item.contentType}_${item.contentId}"),
            child: _buildItemWidget(context, item),
          );
        },
        onReorder: (int oldIndex, int newIndex) async {
          await manageController.onSortKnowledge(oldIndex, newIndex);
        },
      );
    } else {
      listWidget = GridView.builder(
        key: ValueKey(knowledgeType),
        itemCount: list.length,
        padding: EdgeInsets.only(
          bottom: 220.wMin + MediaQuery.of(context).padding.bottom,
          left: 90.wMin,
          right: 90.wMin,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 24.wMin,
          crossAxisSpacing: 24.wMin,
          childAspectRatio: childAspectRatio,
          mainAxisExtent: mainAxisExtent,
        ),
        itemBuilder: (context, index) {
          return _buildItemWidget(context, list[index]);
        },
      );
    }

    return Container(
      margin: EdgeInsets.only(top: 16.wMin),
      child: listWidget,
    );
  }

  /// 判断两个知识点是否是同一个排序项。
  bool _isSameKnowledgeItem(KnowledgeCommonEntityList a, KnowledgeCommonEntityList b) {
    return a.contentType == b.contentType && a.contentId == b.contentId;
  }

  Widget _buildItemWidget(BuildContext context, KnowledgeCommonEntityList data) {
    final CourseUnitTargetEnum knowledgeType = controller.currentKnowledgeType.value;

    if (knowledgeType == CourseUnitTargetEnum.writing) {
      return CourseUnitTargetWritingCardWidget(
        isManagement: controller.isManagement,
        unitId: controller.unitId,
        data: data,
        onShelf: !controller.isManagement ? null : () async {
          await controller.manageKnowledgeController.toggleWritingTaskAccess(data);
        },
      );
    } else if (knowledgeType == CourseUnitTargetEnum.vocabulary || knowledgeType == CourseUnitTargetEnum.syntax) {
      return ElementsDictReadCard(
        onTap: () async{
          if(data.jump == null) return;
          bool lock = await LockUtils.checkLock(
            data.rights, 
            context,
            contentType: data.content?.type??'',
          );
          if(lock) return;
          await JumpPageUtils.jumpUserPages(data.jump);
          controller.getUnitTarget(showLoading: false, shouldResetKnowledgeType: false);
        },
        data: data,
        isManagement: controller.isManagement,
        bottomWidget: Visibility(
          visible: controller.isManagement,
          child: ElementsCardManageButtonsWidget(
            data: data,
            unitId: controller.unitKnowledgePoints.value.unitId,
            moduleId: controller.unitKnowledgePoints.value.moduleId,
            onRefresh: () {
              controller.getUnitTarget(showLoading: false, shouldResetKnowledgeType: false);
            },
          ),
        ),
        imageButtonWidget: Visibility(
          visible: controller.isManagement,
          child: ElementsCardManageEditButtonsWidget(
            data: data,
            unitId: controller.unitKnowledgePoints.value.unitId,
            onRefresh: () {
              controller.getUnitTarget(showLoading: false, shouldResetKnowledgeType: false);
            },
          ),
        ),
      );
    }
    return KnowledgeCardWidget(
      knowledgeData: data,
      isManagement: controller.isManagement,
      bottomWidget: Visibility(
        visible: controller.isManagement,
        child: ElementsCardManageButtonsWidget(
          data: data,
          unitId: controller.unitKnowledgePoints.value.unitId,
          onRefresh: () {
            controller.getUnitTarget(showLoading: false, shouldResetKnowledgeType: false);
          },
        ),
      ),
      imageButtonWidget: Visibility(
        visible: controller.isManagement,
        child: ElementsCardManageEditButtonsWidget(
          data: data,
          unitId: controller.unitKnowledgePoints.value.unitId,
          onRefresh: () {
            controller.getUnitTarget(showLoading: false, shouldResetKnowledgeType: false);
          },
        ),
      ),
    );
  }

  /// 句法相关列表
  Widget _buildSyntaxListWidget() {
    if (controller.syntaxTab.value == 1) {
      return _buildSentenceGrammarGroupListWidget();
    } else if (controller.syntaxTab.value == 2) {
      return _buildSentenceGrammarListWidget();
    }
    return Container();
  }

  /// 句组列表
  Widget _buildSentenceGrammarGroupListWidget() {
    return Obx(() {
      return SentenceGrammarGroupListWidget(
        controller: controller.syntaxController.scrollController,
        list: controller.syntaxController.groupList.toList(),
        isManagement: controller.isManagement,
        unitId: controller.unitId,
        isToDetailBindRealizationSetId: true,
      );
    });
  }

  /// 句子语法列表
  Widget _buildSentenceGrammarListWidget() {
    return Obx(() {
      final knowledgeController = controller.knowledgeController;
      final list = knowledgeController.sentenceGrammarList;
      if (list.isEmpty) {
        return NotDataWidget(message: "暂无数据");
      }
      return ListView.separated(
        itemCount: list.length,
        padding: EdgeInsets.only(bottom: 220.wMin, left: 90.wMin, right: 90.wMin, top: 16.wMin),
        separatorBuilder: (context, index) => SizedBox(height: 24.wMin),
        itemBuilder: (context, index) {
          return CourseUnitTargetGrammarCardWidget(
            data: list[index],
            onTap: (CourseUnitTargetSentenceGrammarTargetEntity? target) {
              controller.jumpToGrammarDetail(target);
            },
          );
        },
      );
    });
  }
}
