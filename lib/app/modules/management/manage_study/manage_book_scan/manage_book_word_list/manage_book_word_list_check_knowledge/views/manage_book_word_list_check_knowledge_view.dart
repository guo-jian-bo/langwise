import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/entities/knowledge.dart';
import 'package:langwise/common/widgets/custom_button/LWCircularButton.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/commons.dart';
import '../bindings/manage_book_word_list_check_knowledge_binding.dart';
import '../controllers/manage_book_word_list_check_knowledge_controller.dart';
import 'manage_book_word_list_check_knowledge_cell.dart';

class ManageBookWordListCheckKnowledgeView
    extends GetView<ManageBookWordListCheckKnowledgeController> {
  final String tagText;

  const ManageBookWordListCheckKnowledgeView({
    super.key,
    required this.tagText,
  });

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments}) async {
    final tag =
        '${Routes.MANAGE_WORD_LIST_CHECK_KNOWLEDGE}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      () => ManageBookWordListCheckKnowledgeView(tagText: tag),
      binding: ManageBookWordListCheckKnowledgeBinding(tag: tag),
      routeName: Routes.MANAGE_WORD_LIST_CHECK_KNOWLEDGE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: ManageScaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xFF0E0F0F),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                _buildBody(constraints),
                Positioned(
                  left: 90.wMin,
                  right: 90.wMin,
                  bottom: 45.wMin,
                  child: _BottomBar(controller: controller),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BoxConstraints constraints) {
    final double panelSpacing = 18.wMin;
    final double rightPanelWidth =
        math.min(420.wMin, constraints.maxWidth * 0.3);
    final double bottomSafeSpace = constraints.maxHeight * 0.55;
    final double storageBottomInset = 145.wMin;

    return Padding(
      padding: EdgeInsets.fromLTRB(90.wMin, 16.wMin, 90.wMin, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _UnitWorkspace(
              controller: controller,
              bottomSafeSpace: bottomSafeSpace,
            ),
          ),
          SizedBox(width: panelSpacing),
          SizedBox(
            width: rightPanelWidth,
            child: Padding(
              padding: EdgeInsets.only(bottom: storageBottomInset),
              child: _StagingWorkspace(
                controller: controller,
                bottomSafeSpace: bottomSafeSpace,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitWorkspace extends StatelessWidget {
  final ManageBookWordListCheckKnowledgeController controller;
  final double bottomSafeSpace;

  const _UnitWorkspace({
    required this.controller,
    required this.bottomSafeSpace,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ManageBookWordListCheckKnowledgeController>(
      tag: controller.tag,
      builder: (_) {
        final unitInfos = controller.responseEntity?.unitList ?? <dynamic>[];
        if (unitInfos.isEmpty) {
          return _buildEmptyPanel(
            title: '暂无单元',
            subtitle: '请先添加知识点或返回上一页检查单元数据。',
          );
        }

        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
            controller: controller.unitWorkspaceScrollController,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: EdgeInsets.only(bottom: bottomSafeSpace),
            child: Column(
              children: List.generate(unitInfos.length, (index) {
                final unitInfo = unitInfos[index];
                final unitId = unitInfo.unitId as int?;
                final unitList = controller.unitsList.length > index
                    ? controller.unitsList[index]
                    : <Knowledge>[];
                final unitName = controller.unitNameList.length > index
                    ? (controller.unitNameList[index] ?? '')
                    : '';

                return Padding(
                  key: unitId == null
                      ? ValueKey('unit_section_$index')
                      : controller.unitSectionKeys.putIfAbsent(
                          unitId,
                          GlobalKey.new,
                        ),
                  padding: EdgeInsets.only(
                    bottom: index == unitInfos.length - 1 ? 0 : 24.wMin,
                  ),
                  child: _UnitSection(
                    controller: controller,
                    unitIndex: index,
                    unitId: unitId,
                    unitName: unitName,
                    unitList: unitList,
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}

class _UnitSection extends StatelessWidget {
  final ManageBookWordListCheckKnowledgeController controller;
  final int unitIndex;
  final int? unitId;
  final String unitName;
  final List<Knowledge> unitList;

  const _UnitSection({
    required this.controller,
    required this.unitIndex,
    required this.unitId,
    required this.unitName,
    required this.unitList,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<Knowledge>(
      onAcceptWithDetails: (details) {
        controller.moveToUnit(details.data, unitIndex, unitList.length);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          decoration: _buildPanelDecoration(
            isHighlighted: candidateData.isNotEmpty,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                key: unitId == null
                    ? null
                    : controller.getUnitHeaderKey(unitId!),
                height: 60.wMin,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    20.wMin,
                    12.wMin,
                    20.wMin,
                    8.wMin,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          controller.modifyUnitName(unitIndex);
                        },
                        child: Row(
                          children: [
                            Text(
                              unitName.isNotEmpty
                                  ? unitName
                                  : 'Unit ${unitIndex + 1}',
                              style: TextStyle(
                                fontSize: 28.wMin,
                                color: AppTheme.cTextPrimary.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 8.wMin),
                            SvgPicture.asset(
                              'assets/svg/custom_course/icon_course_modify.svg',
                              width: 24.wMin,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Unit ID: ${unitId ?? ''}',
                        style: TextStyle(
                          fontSize: 18.wMin,
                          color: AppTheme.cTextSecondary.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 1.wMin,
                color: const Color(0xFF2C2D2F),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  const double cellWidth = 180;
                  const double cellHeight = 260;
                  final double gridSpacing = 10.wMin;
                  final int crossAxisCount = math.max(
                    1,
                    (constraints.maxWidth / (cellWidth.wMin + gridSpacing))
                        .floor(),
                  );

                  if (unitList.isEmpty) {
                    return SizedBox(
                      height: 180.wMin,
                      child: _buildEmptyState(
                        icon: Icons.grid_view_rounded,
                        title: '当前单元暂无知识点',
                        subtitle: '可从右侧暂存区拖拽知识点到这里。',
                      ),
                    );
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.all(16.wMin),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: cellWidth / cellHeight,
                      crossAxisSpacing: gridSpacing,
                      mainAxisSpacing: gridSpacing,
                    ),
                    itemCount: unitList.length,
                    itemBuilder: (context, index) {
                      final wordModel = unitList[index];
                      return DragTarget<Knowledge>(
                        onAcceptWithDetails: (details) {
                          controller.moveToUnit(details.data, unitIndex, index);
                        },
                        builder: (context, candidateData, rejectedData) {
                          return _KnowledgeDragCard(
                            key: ValueKey('unit_${unitIndex}_${wordModel.uid}'),
                            item: wordModel,
                            isHighlighted: candidateData.isNotEmpty,
                            onDragStarted: () {
                              controller.startDrag(
                                unitIndex: unitIndex,
                                itemIndex: index,
                                fromTop: false,
                              );
                            },
                            onDragFinished: controller.clearDragState,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StagingWorkspace extends StatelessWidget {
  final ManageBookWordListCheckKnowledgeController controller;
  final double bottomSafeSpace;

  const _StagingWorkspace({
    required this.controller,
    required this.bottomSafeSpace,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ManageBookWordListCheckKnowledgeController>(
      tag: controller.tag,
      builder: (_) {
        return DragTarget<Knowledge>(
          onAcceptWithDetails: (details) {
            controller.moveToTop(details.data, controller.topList.length);
          },
          builder: (context, candidateData, rejectedData) {
            return Container(
              decoration: _buildPanelDecoration(
                backgroundColor: const Color(0xFF18191A),
                isHighlighted: candidateData.isNotEmpty,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      16.wMin,
                      18.wMin,
                      16.wMin,
                      0,
                    ),
                    child: Text(
                      '知识点暂存区',
                      style: TextStyle(
                        fontSize: 24.wMin,
                        color: AppTheme.cTextPrimary.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      16.wMin,
                      8.wMin,
                      16.wMin,
                      0,
                    ),
                    child: Text(
                      '拖到这里后，可再分配到任意单元。',
                      style: TextStyle(
                        fontSize: 18.wMin,
                        color: AppTheme.cTextSecondary.color,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      16.wMin,
                      16.wMin,
                      16.wMin,
                      12.wMin,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        controller.onAddKnowledge(context);
                      },
                      child: Container(
                        width: double.infinity,
                        height: 44.wh,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2388FF),
                          borderRadius: BorderRadius.circular(8.wMin),
                        ),
                        child: Text(
                          '添加知识点',
                          style: TextStyle(
                            fontSize: 18.wMin,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        const double cellWidth = 180;
                        const double cellHeight = 260;
                        final double gridSpacing = 10.wMin;
                        final int crossAxisCount = math.max(
                          1,
                          (constraints.maxWidth /
                                  (cellWidth.wMin + gridSpacing))
                              .floor(),
                        );

                        if (controller.topList.isEmpty) {
                          return _buildEmptyState(
                            icon: Icons.inbox_outlined,
                            title: '暂存区为空',
                            subtitle: '点击上方按钮添加知识点，或从左侧单元拖拽到这里。',
                          );
                        }

                        return GridView.builder(
                          key: const PageStorageKey('top_scroll_grid'),
                          controller: controller.topScrollController,
                          padding: EdgeInsets.fromLTRB(
                            16.wMin,
                            0,
                            16.wMin,
                            bottomSafeSpace,
                          ),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: cellWidth / cellHeight,
                            crossAxisSpacing: gridSpacing,
                            mainAxisSpacing: gridSpacing,
                          ),
                          itemCount: controller.topList.length,
                          itemBuilder: (context, index) {
                            final wordModel = controller.topList[index];
                            return DragTarget<Knowledge>(
                              onAcceptWithDetails: (details) {
                                controller.moveToTop(details.data, index);
                              },
                              builder: (context, candidateData, rejectedData) {
                                return _KnowledgeDragCard(
                                  key: ValueKey('top_${wordModel.uid}'),
                                  item: wordModel,
                                  isHighlighted: candidateData.isNotEmpty,
                                  onDragStarted: () {
                                    controller.startDrag(
                                      itemIndex: index,
                                      fromTop: true,
                                    );
                                  },
                                  onDragFinished: controller.clearDragState,
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _BottomBar extends StatelessWidget {
  final ManageBookWordListCheckKnowledgeController controller;

  const _BottomBar({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final actionButton = _buildFinishManageButton();
    return GetBuilder<ManageBookWordListCheckKnowledgeController>(
      tag: controller.tag,
      id: 'bottomBar',
      builder: (_) {
        final unitInfos = controller.responseEntity?.unitList ?? <dynamic>[];
        return Row(
          children: [
            IgnorePointer(
              child: Opacity(
                opacity: 0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    actionButton,
                    SizedBox(width: 16.wMin),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: unitInfos.isEmpty
                    ? const SizedBox.shrink()
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(999.wMin),
                        child: PlatformBackdropFilterWidget(
                          sigmaX: 4.wMin,
                          sigmaY: 4.wMin,
                          child: Container(
                            height: 80.wMin,
                            padding: EdgeInsets.symmetric(horizontal: 12.wMin),
                            decoration: BoxDecoration(
                              color: AppTheme.cSurfaceSearchBackground.color,
                              borderRadius: BorderRadius.circular(999.wMin),
                              border: Border.all(
                                color: AppTheme.cBorderDark.color,
                                width: 1.wMin,
                              ),
                            ),
                            child: ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context)
                                  .copyWith(scrollbars: false),
                              child: SingleChildScrollView(
                                key: controller.unitTabViewportKey,
                                controller: controller.unitTabScrollController,
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children:
                                      List.generate(unitInfos.length, (index) {
                                    final item = unitInfos[index];
                                    final int? unitId = item.unitId;
                                    final String text =
                                        controller.unitNameList.length >
                                                    index &&
                                                (controller.unitNameList[index]
                                                        ?.isNotEmpty ==
                                                    true)
                                            ? controller.unitNameList[index]!
                                            : 'Unit ${index + 1}';
                                    final bool isActive =
                                        unitId == controller.activeUnitId.value;
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        right: index == unitInfos.length - 1
                                            ? 0
                                            : 12.wMin,
                                      ),
                                      child: LWCircularButtonWidget(
                                        key: unitId == null
                                            ? null
                                            : controller.getUnitTabKey(unitId),
                                        text: text,
                                        isAction: isActive,
                                        color: const Color(0xFF2388FF),
                                        onTap: () {
                                          if (unitId == null) {
                                            controller.selectUnit(index);
                                            return;
                                          }
                                          controller.scrollToUnit(unitId);
                                        },
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 16.wMin),
                actionButton,
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildFinishManageButton() {
    final color = const Color(0xFF2388FF);
    return TapScaleWidget(
      sclae: 1.05,
      onTap: controller.onComplete,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: PlatformBackdropFilterWidget(
          sigmaX: 10.wMin,
          sigmaY: 10.wMin,
          child: Container(
            height: 64.wMin,
            padding: EdgeInsets.symmetric(horizontal: 18.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: color.withValues(alpha: 0.15),
              border: Border.all(
                color: color.withValues(alpha: 0.2),
                width: 1.wMin,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '完成管理',
              style: TextStyle(
                color: color,
                fontSize: 24.wMin,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _KnowledgeDragCard extends StatelessWidget {
  final Knowledge item;
  final bool isHighlighted;
  final VoidCallback onDragStarted;
  final VoidCallback onDragFinished;

  const _KnowledgeDragCard({
    super.key,
    required this.item,
    required this.isHighlighted,
    required this.onDragStarted,
    required this.onDragFinished,
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      decoration: _buildCellDecoration(isHighlighted),
      child: ManageBookWordListCheckKnowledgeCell(
        wordModel: item,
      ),
    );

    return LongPressDraggable<Knowledge>(
      data: item,
      onDragStarted: onDragStarted,
      onDragEnd: (_) => onDragFinished(),
      onDraggableCanceled: (_, __) => onDragFinished(),
      feedback: Material(
        color: Colors.transparent,
        child: ManageBookWordListCheckKnowledgeCell(
          wordModel: item,
          isDragging: true,
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0,
        child: child,
      ),
      child: child,
    );
  }
}

Widget _buildEmptyPanel({
  required String title,
  required String subtitle,
}) {
  return Container(
    decoration: _buildPanelDecoration(),
    child: _buildEmptyState(
      icon: Icons.layers_outlined,
      title: title,
      subtitle: subtitle,
    ),
  );
}

Widget _buildEmptyState({
  required IconData icon,
  required String title,
  required String subtitle,
}) {
  return Center(
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.wMin),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 44.wMin,
            color: AppTheme.cTextTertiary.color,
          ),
          SizedBox(height: 12.wMin),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.wMin),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.wMin,
              color: AppTheme.cTextSecondary.color,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ],
      ),
    ),
  );
}

BoxDecoration _buildPanelDecoration({
  Color? backgroundColor,
  bool isHighlighted = false,
}) {
  return BoxDecoration(
    color: backgroundColor ?? const Color(0xFF111213),
    borderRadius: BorderRadius.circular(20.wMin),
    border: Border.all(
      color: isHighlighted ? const Color(0xFF38BDF8) : const Color(0xFF2C2D2F),
      width: 1.5.wMin,
    ),
  );
}

BoxDecoration _buildCellDecoration(bool isHighlighted) {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(8.wMin),
    border: Border.all(
      color: isHighlighted ? const Color(0xFF38BDF8) : Colors.transparent,
      width: 1.5.wMin,
    ),
  );
}
