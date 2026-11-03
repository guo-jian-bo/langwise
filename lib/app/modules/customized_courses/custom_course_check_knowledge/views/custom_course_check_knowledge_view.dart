import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/customized_courses/custom_course_check_knowledge/controllers/custom_course_check_knowledge_controller.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../../../../theme/theme.dart';
import '../models/custom_course_check_knowledge_word_model.dart';
import 'custom_course_check_knowledge_cell.dart';
import 'package:ui_essentials/ui_essentials.dart';

class CustomCourseCheckKnowledgeView
    extends GetView<CustomCourseCheckKnowledgeController> {
  const CustomCourseCheckKnowledgeView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppTheme.cBgPrimary,
        body: Stack(
          children: [
            _contentWidget(context),
            Obx(
              () => Visibility(
                visible: !controller.isShowTip.value,
                child: Positioned(
                  top: 20.wMin,
                  right: 20.wMin,
                  child: Container(
                    width: 240.wMin,
                    decoration: BoxDecoration(
                      color: AppTheme.cBgQuaternary,
                      borderRadius: BorderRadius.circular(10.wMin),
                    ),
                    child: Padding(
                        padding: EdgeInsets.all(15.0.wMin),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '长按卡片，将其拖拽到上方的“暂存区”，即可为知识点重新分配单元。',
                              style: TextStyle(
                                fontSize: 20.wMin,
                                fontWeight: FontWeight.w400,
                                color: AppTheme.cTextPrimary,
                              ),
                            ),
                            SizedBox(height: 20.wMin),
                            TapScaleWidget(
                              onTap: () {
                                controller.isShowTip.value = true;
                              },
                              sclae: 1.1,
                              child: Text(
                                '知道了',
                                style: TextStyle(
                                  fontSize: 20.wMin,
                                  color: AppTheme.cTextBrand,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        )),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contentWidget(BuildContext context) {
    double cellWidth = 180.0.wMin;
    double cellHeight = 260.0.wMin;
    double gridSpacing = 10.0.wMin;

    return Column(
      children: [
        SizedBox(
          height: 20.wMin,
        ),
        FractionallySizedBox(
          widthFactor: 0.8,
          child: DottedBorder(
            color: AppTheme.cBorderPrimary,
            strokeWidth: 2.0.wMin,
            dashPattern: const [5, 3],
            borderType: BorderType.RRect,
            radius: Radius.circular(8.0.wMin),
            child: Padding(
              padding: EdgeInsets.all(10.0.wMin),
              child: Row(
                children: [
                  Container(
                    width: cellWidth,
                    height: cellHeight,
                    decoration: BoxDecoration(
                      color: AppTheme.cBgSecondary,
                      borderRadius: BorderRadius.circular(8.0.wMin),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '知识点\n暂存区',
                      style: TextStyle(
                        fontSize: 20.wMin,
                        color: AppTheme.cTextPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10.wMin,
                  ),
                  Expanded(
                    child: SizedBox(
                      height: cellHeight,
                      child: Obx(() {
                        if (controller.unitsList.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return TopScrollWidget(
                          key: const ValueKey('top_scroll_widget'),
                          topList: controller.topList,
                          scrollController: controller.topScrollController,
                          onDragStarted: controller.startDrag,
                          onItemDropped: controller.moveToTop,
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: 20.wMin,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Obx(
              () => ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.unitsList.length,
                itemBuilder: (context, index) {
                  List<CustomCourseCheckKnowledgeWordModel> unitList =
                      controller.unitsList[index];
                  return Container(
                    width: cellWidth * 3 + gridSpacing * 2 + 5.wMin,
                    margin: const EdgeInsets.only(right: 40),
                    child: UnitScrollWidget(
                      key: ValueKey('unit_scroll_widget_$index'),
                      unitList: unitList,
                      unitIndex: index,
                      scrollController:
                          controller.unitScrollControllerList[index],
                      modifyUnitName: controller.modifyUnitName,
                      onDragStarted: controller.startDrag,
                      onItemDropped: controller.moveToUnit,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        _bottomWidget(),
      ],
    );
  }

  Widget _bottomWidget() {
    return Container(
      width: double.infinity,
      height: 120.wMin,
      color: AppTheme.cBgPrimary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TapScaleWidget(
            onTap: () {
              controller.saveExit();
            },
            sclae: 1.1,
            child: Container(
              width: 176.wMin,
              height: 72.wMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.cBgQuaternary,
                borderRadius: BorderRadius.circular(12.wMin),
              ),
              child: Text(
                '保存退出',
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 15.wMin,
          ),
          TapScaleWidget(
            onTap: () {
              controller.startGenerate();
            },
            sclae: 1.1,
            child: Container(
              width: 200.wMin,
              height: 72.wMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.cTextBrand,
                borderRadius: BorderRadius.circular(12.wMin),
              ),
              child: Text(
                '生成课程',
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 20.wMin,
          ),
        ],
      ),
    );
  }
}

//top滚动widget
class TopScrollWidget extends StatefulWidget {
  final List<CustomCourseCheckKnowledgeWordModel> topList;
  final ScrollController scrollController;
  final Function({int? unitIndex, int? itemIndex, bool fromTop}) onDragStarted;
  final Function(CustomCourseCheckKnowledgeWordModel, int) onItemDropped;

  const TopScrollWidget({
    super.key,
    required this.topList,
    required this.scrollController,
    required this.onDragStarted,
    required this.onItemDropped,
  });

  @override
  State<TopScrollWidget> createState() => _TopScrollWidgetState();
}

class _TopScrollWidgetState extends State<TopScrollWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    double cellWidth = 180.0.wMin;
    double cellHeight = 260.0.wMin;
    double gridSpacing = 10.0.wMin;

    return DragTarget<CustomCourseCheckKnowledgeWordModel>(
      onAcceptWithDetails: (details) {
        widget.onItemDropped(details.data, widget.topList.length);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          decoration: _createScrollViewDecoration(
              Colors.transparent, candidateData.isNotEmpty),
          child: GridView.builder(
            key: const PageStorageKey('top_scroll_grid'),
            controller: widget.scrollController,
            scrollDirection: Axis.horizontal,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              childAspectRatio: cellHeight / cellWidth,
              mainAxisSpacing: gridSpacing,
            ),
            itemCount: widget.topList.length,
            itemBuilder: (context, index) {
              return DragTarget<CustomCourseCheckKnowledgeWordModel>(
                onAcceptWithDetails: (details) {
                  widget.onItemDropped(details.data, index);
                },
                builder: (context, candidateData, rejectedData) {
                  CustomCourseCheckKnowledgeWordModel wordModel =
                      widget.topList[index];

                  return LongPressDraggable<
                      CustomCourseCheckKnowledgeWordModel>(
                    data: wordModel,
                    onDragStarted: () {
                      widget.onDragStarted(
                        itemIndex: index,
                        fromTop: true,
                      );
                    },
                    feedback: CustomCourseCheckKnowledgeCell(
                      wordModel: wordModel,
                      isDragging: true,
                    ),
                    child: Container(
                      decoration:
                          _createCellDecoration(candidateData.isNotEmpty),
                      child: CustomCourseCheckKnowledgeCell(
                        key: ValueKey('unit_cell_${wordModel.uid}'),
                        wordModel: wordModel,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

//unit滚动widget
class UnitScrollWidget extends StatefulWidget {
  final List<CustomCourseCheckKnowledgeWordModel> unitList;
  final int unitIndex;
  final ScrollController scrollController;
  final Function(int) modifyUnitName;
  final Function({int? unitIndex, int? itemIndex, bool fromTop}) onDragStarted;
  final Function(CustomCourseCheckKnowledgeWordModel, int, int) onItemDropped;

  const UnitScrollWidget({
    super.key,
    required this.unitList,
    required this.unitIndex,
    required this.scrollController,
    required this.modifyUnitName,
    required this.onDragStarted,
    required this.onItemDropped,
  });

  @override
  State<UnitScrollWidget> createState() => _UnitScrollWidgetState();
}

class _UnitScrollWidgetState extends State<UnitScrollWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    double cellWidth = 180.0.wMin;
    double cellHeight = 260.0.wMin;
    double gridSpacing = 10.0.wMin;

    super.build(context);
    return DragTarget<CustomCourseCheckKnowledgeWordModel>(
      onAcceptWithDetails: (details) {
        widget.onItemDropped(
            details.data, widget.unitIndex, widget.unitList.length);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          decoration: _createScrollViewDecoration(
              AppTheme.cBgSecondary, candidateData.isNotEmpty),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(8.wMin),
                child: GestureDetector(
                  onTap: () {
                    widget.modifyUnitName(widget.unitIndex);
                  },
                  child: Row(
                    children: [
                      GetBuilder<CustomCourseCheckKnowledgeController>(
                        builder: (controller) {
                          return Text(
                            controller.unitNameList[widget.unitIndex]!,
                            style: TextStyle(
                              fontSize: 32.wMin,
                              color: AppTheme.cTextPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                      SizedBox(
                        width: 10.wMin,
                      ),
                      SvgPicture.asset(
                        "assets/svg/custom_course/icon_course_modify.svg",
                        width: 30.wMin,
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                height: 1.wMin,
                thickness: 1.wMin, // 线条厚度
                color: AppTheme.cBorderPrimary,
              ),
              SizedBox(
                height: 20.wMin,
              ),
              Expanded(
                child: GridView.builder(
                  key: PageStorageKey('unit_scroll_grid_${widget.unitIndex}'),
                  controller: widget.scrollController,
                  scrollDirection: Axis.vertical,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: cellWidth / cellHeight,
                    crossAxisSpacing: gridSpacing,
                    mainAxisSpacing: gridSpacing,
                  ),
                  itemCount: widget.unitList.length,
                  itemBuilder: (context, index) {
                    return DragTarget<CustomCourseCheckKnowledgeWordModel>(
                      onAcceptWithDetails: (details) {
                        widget.onItemDropped(
                            details.data, widget.unitIndex, index);
                      },
                      builder: (context, candidateData, rejectedData) {
                        CustomCourseCheckKnowledgeWordModel wordModel =
                            widget.unitList[index];

                        return LongPressDraggable<
                            CustomCourseCheckKnowledgeWordModel>(
                          data: wordModel,
                          onDragStarted: () {
                            widget.onDragStarted(
                              unitIndex: widget.unitIndex,
                              itemIndex: index,
                              fromTop: false,
                            );
                          },
                          feedback: CustomCourseCheckKnowledgeCell(
                            wordModel: wordModel,
                            isDragging: true,
                          ),
                          child: Container(
                            decoration:
                                _createCellDecoration(candidateData.isNotEmpty),
                            child: CustomCourseCheckKnowledgeCell(
                              key: ValueKey('unit_cell_${wordModel.uid}'),
                              wordModel: wordModel,
                            ),
                          ),
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
  }
}

//将被移入的单元滚动组件----添加视觉效果
BoxDecoration? _createScrollViewDecoration(Color color, bool hasCandidate) {
  return hasCandidate
      ? BoxDecoration(
          color: color,
          border: Border.all(
            color: AppTheme.cBorderBrand,
            width: 2.wMin,
          ),
        )
      : BoxDecoration(
          color: color,
          border: Border.all(
            color: Colors.transparent,
            width: 2.wMin,
          ),
        );
}

//将被插入替换的cell组件----添加视觉效果
BoxDecoration? _createCellDecoration(bool hasCandidate) {
  return hasCandidate
      ? BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.cBorderBrand,
            width: 2.wMin,
          ),
        )
      : BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.transparent,
            width: 2.wMin,
          ),
        );
}
