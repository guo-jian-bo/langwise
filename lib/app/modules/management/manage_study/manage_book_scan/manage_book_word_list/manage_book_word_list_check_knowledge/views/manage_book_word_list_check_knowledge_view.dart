import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/entities/knowledge.dart';
import '../../../../../common/commons.dart';
import '../bindings/manage_book_word_list_check_knowledge_binding.dart';
import '../controllers/manage_book_word_list_check_knowledge_controller.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'manage_book_word_list_check_knowledge_cell.dart';

class ManageBookWordListCheckKnowledgeView
    extends GetView<ManageBookWordListCheckKnowledgeController> {
  final String tagText;
  const ManageBookWordListCheckKnowledgeView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_WORD_LIST_CHECK_KNOWLEDGE}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageBookWordListCheckKnowledgeView(tagText: tag),
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
        body: GetBuilder<ManageBookWordListCheckKnowledgeController>(
          tag: tagText,
          builder: (controller) {
            return _contentWidget(context);
          },
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
            color: const Color(0xFF2C2D2F),
            strokeWidth: 2.0.wMin,
            dashPattern: const [5, 3],
            borderType: BorderType.RRect,
            radius: Radius.circular(8.0.wMin),
            child: Padding(
              padding: EdgeInsets.all(10.0.wMin),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      controller.onAddKnowledge(context);
                    },
                    child: Container(
                      width: cellWidth,
                      height: cellHeight,
                      decoration: BoxDecoration(
                        color: const Color(0xFF18191A),
                        borderRadius: BorderRadius.circular(8.0.wMin),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/svg/public/icon_add.svg',
                            width: 50.wMin,
                            height: 50.wMin,
                            colorFilter: const ColorFilter.mode(
                              Color(0xffACB4C0),
                              BlendMode.srcIn,
                            ),
                          ),
                          Gaps.getWidth(8.ww),
                          Text(
                            '添加新知识点',
                            style: TextStyle(
                              fontSize: 20.wMin,
                              color: const Color(0xFFFDFDFD),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10.wMin,
                  ),
                  Expanded(
                    child: SizedBox(
                      height: cellHeight,
                      child: ManagerWordListTopScrollWidget(
                        key: const ValueKey('top_scroll_widget'),
                        topList: controller.topList,
                        scrollController: controller.topScrollController,
                        onDragStarted: controller.startDrag,
                        onItemDropped: controller.moveToTop,
                      ),
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
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.unitsList.length,
              itemBuilder: (context, index) {
                List<Knowledge> unitList = controller.unitsList[index];
                return Container(
                  width: cellWidth * 3 + gridSpacing * 2 + 5.wMin,
                  margin: const EdgeInsets.only(right: 40),
                  child: ManagerWordListUnitScrollWidget(
                    key: ValueKey('unit_scroll_widget_$index'),
                    unitList: unitList,
                    unitIndex: index,
                    scrollController:
                        controller.unitScrollControllerList[index],
                    modifyUnitName: controller.modifyUnitName,
                    onDragStarted: controller.startDrag,
                    onItemDropped: controller.moveToUnit,
                    tag: tagText,
                  ),
                );
              },
            ),
          ),
        ),
        //_bottomWidget(),
      ],
    );
  }
}

//top滚动widget
class ManagerWordListTopScrollWidget extends StatefulWidget {
  final List<Knowledge> topList;
  final ScrollController scrollController;
  final Function({int? unitIndex, int? itemIndex, bool fromTop}) onDragStarted;
  final Function(Knowledge, int) onItemDropped;

  const ManagerWordListTopScrollWidget({
    super.key,
    required this.topList,
    required this.scrollController,
    required this.onDragStarted,
    required this.onItemDropped,
  });

  @override
  State<ManagerWordListTopScrollWidget> createState() =>
      _ManagerWordListTopScrollWidgetState();
}

class _ManagerWordListTopScrollWidgetState
    extends State<ManagerWordListTopScrollWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    double cellWidth = 180.0.wMin;
    double cellHeight = 260.0.wMin;
    double gridSpacing = 10.0.wMin;

    return DragTarget<Knowledge>(
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
              return DragTarget<Knowledge>(
                onAcceptWithDetails: (details) {
                  widget.onItemDropped(details.data, index);
                },
                builder: (context, candidateData, rejectedData) {
                  Knowledge wordModel = widget.topList[index];

                  return LongPressDraggable<Knowledge>(
                    data: wordModel,
                    onDragStarted: () {
                      widget.onDragStarted(
                        itemIndex: index,
                        fromTop: true,
                      );
                    },
                    feedback: ManageBookWordListCheckKnowledgeCell(
                      wordModel: wordModel,
                      isDragging: true,
                    ),
                    child: Container(
                      decoration:
                          _createCellDecoration(candidateData.isNotEmpty),
                      child: ManageBookWordListCheckKnowledgeCell(
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
class ManagerWordListUnitScrollWidget extends StatefulWidget {
  final List<Knowledge> unitList;
  final int unitIndex;
  final ScrollController scrollController;
  final Function(int) modifyUnitName;
  final Function({int? unitIndex, int? itemIndex, bool fromTop}) onDragStarted;
  final Function(Knowledge, int, int) onItemDropped;
  final String? tag;

  const ManagerWordListUnitScrollWidget({
    super.key,
    required this.unitList,
    required this.unitIndex,
    required this.scrollController,
    required this.modifyUnitName,
    required this.onDragStarted,
    required this.onItemDropped,
    this.tag,
  });

  @override
  State<ManagerWordListUnitScrollWidget> createState() =>
      _ManagerWordListUnitScrollWidgetState();
}

class _ManagerWordListUnitScrollWidgetState
    extends State<ManagerWordListUnitScrollWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    double cellWidth = 180.0.wMin;
    double cellHeight = 260.0.wMin;
    double gridSpacing = 10.0.wMin;

    super.build(context);
    return DragTarget<Knowledge>(
      onAcceptWithDetails: (details) {
        widget.onItemDropped(
            details.data, widget.unitIndex, widget.unitList.length);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          decoration: _createScrollViewDecoration(
              const Color(0xFF18191A), candidateData.isNotEmpty),
          child: Column(
            children: [
              Padding(
                  padding: EdgeInsets.all(8.wMin),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          widget.modifyUnitName(widget.unitIndex);
                        },
                        child: Row(
                          children: [
                            GetBuilder<ManageBookWordListCheckKnowledgeController>(
                              tag: widget.tag,
                              builder: (controller) {
                                return Text(
                                  controller.unitNameList[widget.unitIndex]!,
                                  style: TextStyle(
                                    fontSize: 32.wMin,
                                    color: const Color(0xFFFDFDFD),
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
                      GetBuilder<ManageBookWordListCheckKnowledgeController>(
                        tag: widget.tag,
                        builder: (controller) {
                          return Text(
                            '单元ID:${controller.responseEntity?.unitList?[widget.unitIndex].unitId.toString() ?? ''}',
                            style: TextStyle(
                              fontSize: 32.wMin,
                              color: const Color(0xFFFDFDFD),
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                    ],
                  )),
              Divider(
                height: 1.wMin,
                thickness: 1.wMin, // 线条厚度
                color: const Color(0xFF2C2D2F),
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
                    return DragTarget<Knowledge>(
                      onAcceptWithDetails: (details) {
                        widget.onItemDropped(
                            details.data, widget.unitIndex, index);
                      },
                      builder: (context, candidateData, rejectedData) {
                        Knowledge wordModel = widget.unitList[index];

                        return LongPressDraggable<Knowledge>(
                          data: wordModel,
                          onDragStarted: () {
                            widget.onDragStarted(
                              unitIndex: widget.unitIndex,
                              itemIndex: index,
                              fromTop: false,
                            );
                          },
                          feedback: ManageBookWordListCheckKnowledgeCell(
                            wordModel: wordModel,
                            isDragging: true,
                          ),
                          child: Container(
                            decoration:
                                _createCellDecoration(candidateData.isNotEmpty),
                            child: ManageBookWordListCheckKnowledgeCell(
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
            color: const Color(0xFF38BDF8),
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
            color: const Color(0xFF38BDF8),
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
