import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:quiz_play/utils/common_utils.dart';
import 'package:langwise/generated/assets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'controller.dart';

class UnitView extends GetView<UnitController> {
  const UnitView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: controller,
        id: "unit",
        builder: (_) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return Scaffold(
                  backgroundColor: AppTheme.cBgPrimary,
                  body: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (controller.hasUnGroupedList) Gaps.getHeight(32.wh),
                      buildKnowledgeStorage(context),
                      if (controller.hasUnGroupedList) Gaps.getHeight(32.wh),
                      Expanded(
                        child: Center(
                          child: controller.hasAppUnitList
                              ? Container(
                                  height: 636.wh,
                                  margin: EdgeInsets.only(left: 120.wMin, right: 120.wMin),
                                  child: AnimatedReorderableListView<AppUnitResponseEntity>(
                                      key: const PageStorageKey("unitsKey"),
                                      // 去掉默认的右边编辑按钮
                                      buildDefaultDragHandles: false,
                                      controller: controller.unitScrollController,
                                      enableSwap: false,
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      enterTransition: [SlideInDown()],
                                      exitTransition: [SlideInUp()],
                                      dragStartDelay: const Duration(milliseconds: 200),
                                      proxyDecorator: proxyDecorator,
                                      lockedItems: controller.lockUnitList.cast<AppUnitResponseEntity>(),
                                      // 预加载足够多的单元，避免拖拽过程中浮层消失
                                      cacheExtent: 30000,
                                      onReorder: (int oldIndex, int newIndex) {},
                                      items: controller.unitList.cast<AppUnitResponseEntity>(),
                                      itemBuilder: (context, index) {
                                        // 如果是最后一个索引，返回添加单元的部件
                                        final AppUnitResponseEntity unitEntity = controller.unitList[index];
                                        if (index == (controller.unitList.length - 1)) {
                                          return _buildAddUnitButtonWidget(context, unitEntity: unitEntity);
                                        }
                                        return AutoScrollTag(
                                          key: unitEntity.globalKey,
                                          controller: controller.unitScrollController,
                                          index: index,
                                          child: AppUnitWidget(
                                            unitEntity: unitEntity,
                                            index: index,
                                            onEdit: (AppUnitResponseEntity unit) {
                                              controller.onEditUnit(context, unitEntity: unitEntity);
                                            },
                                            contentBuilder: (BuildContext c, AppUnitResponseEntity unit) {
                                              if (unit.hasKnowledgeList) {
                                                return AnimatedReorderableGridView(
                                                  // 使用单元的uid作为容器的唯一标识，这对跨容器拖拽至关重要
                                                  containerId: unit.uid,
                                                  items: unit.knowledgeList!.cast<Knowledge>(),
                                                  shrinkWrap: true,
                                                  padding: EdgeInsets.zero,
                                                  // 允许接受外部item
                                                  canReceiveItem: true,
                                                  // 允许拖出内部item到其他容器
                                                  canDragOutItem: true,
                                                  cacheExtent: 30000,
                                                  enterTransition: [SlideInDown()],
                                                  exitTransition: [SlideInUp()],
                                                  dragStartDelay: const Duration(milliseconds: 200),
                                                  sliverGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 4,
                                                    mainAxisSpacing: 24.wMin,
                                                    // 列间距
                                                    crossAxisSpacing: 32.wMin,
                                                    childAspectRatio: 180.ww / 244.wh,
                                                  ),
                                                  proxyDecorator: proxyDecorator,
                                                  lockedItems: const <Knowledge>[],
                                                  isSameItem: (a, b) => a.uid == b.uid,
                                                  itemBuilder: (context, index) {
                                                    final Knowledge item = unit.knowledgeList![index];
                                                    return AppKnowledgeWidget(
                                                        key: ValueKey(item.uid.toString()),
                                                        index: index,
                                                        knowledge: item);
                                                  },
                                                  itemDataGetter: (int index) {
                                                    // 获取当前索引数据
                                                    return unit.knowledgeList![index];
                                                  },
                                                  onReorder: (int oldIndex, int newIndex) {
                                                    // 本容器内重新排序
                                                    controller.onReorderKnowledge(
                                                        unitEntity: unit, oldIndex: oldIndex, newIndex: newIndex);
                                                  },
                                                  onReorderEnd: (int index) {
                                                    // 拖拽结束/需要判断手势是否在本单元内, 在本单元外将拖拽单词加入到目标单元
                                                    // print("---拖拽结束的回调onReorderEnd, 放置到索引index: $index---");
                                                  },
                                                  onDragUpdate: (CrossContainerData containerData) {
                                                    // 拖拽更新数据

                                                    // 检查单元列表
                                                    if (!controller.hasAppUnitList) {
                                                      return;
                                                    }

                                                    if (controller.unitList.length < 2) {
                                                      return;
                                                    }

                                                    // 容器id为空,直接返回
                                                    if (containerData.fromContainerId == null) {
                                                      return;
                                                    }

                                                    // 变量用来记录当前可见的单元索引
                                                    final int currentVisibleIndex = controller.findHoveredCellIndex(
                                                        dragPosition: containerData.dragInfo.dragPosition);

                                                    // 如果没有找到可见单元，直接返回
                                                    if (currentVisibleIndex == -1) return;

                                                    // 手指按下时,在本单元内不滑动
                                                    if (containerData.fromContainerId ==
                                                        controller.unitList[currentVisibleIndex].uid) {
                                                      return;
                                                    }

                                                    // 最后一个添加单元, 直接返回
                                                    if (controller.unitList[currentVisibleIndex].isAddUnit) {
                                                      return;
                                                    }

                                                    // 获取当前单元的位置和尺寸信息
                                                    final currentUnit = controller.unitList[currentVisibleIndex];
                                                    final currentUnitRecord =
                                                        CommonUtils.getSizeAndPosition(currentUnit.globalKey);

                                                    // 计算单元视图宽度的1/3作为滚动基准
                                                    final unitWidth = currentUnitRecord.size.width;
                                                    final scrollThreshold = unitWidth / 3;

                                                    // 获取拖拽位置相对于单元左边缘的偏移量
                                                    final dragX = containerData.dragInfo.dragPosition.dx;
                                                    final unitLeftX = currentUnitRecord.globalPosition.dx;
                                                    final relativeX = dragX - unitLeftX;

                                                    // 打印拖拽位置信息，便于调试
                                                    if (kDebugMode) {
                                                      if (relativeX < scrollThreshold) {
                                                        print(
                                                            '📦[UnitView]【onDragUpdate】拖拽位置在单元左侧: $currentVisibleIndex');
                                                      } else if (relativeX < scrollThreshold * 2) {
                                                        print(
                                                            '📦[UnitView]【onDragUpdate】拖拽位置在单元中间: $currentVisibleIndex');
                                                      } else {
                                                        print(
                                                            '📦[UnitView]【onDragUpdate】拖拽位置在单元右侧: $currentVisibleIndex');
                                                      }
                                                    }

                                                    // 计算滚动偏移量
                                                    double offset;

                                                    // 获取当前可视区域的信息
                                                    final viewportWidth = MediaQuery.of(context).size.width - 240.ww;

                                                    // 将目标单元视图滚动到1/3处
                                                    // 计算目标偏移量：将单元左边缘对齐到视口的1/3处
                                                    final oneThirdViewportPosition = viewportWidth / 3;
                                                    offset = controller.unitScrollController.position.pixels +
                                                        (unitLeftX - oneThirdViewportPosition);

                                                    if (kDebugMode) {
                                                      print(
                                                          '📦[UnitView]【onDragUpdate】滚动单元到1/3处: $currentVisibleIndex');
                                                    }

                                                    // 确保偏移量在有效范围内
                                                    offset = offset.clamp(
                                                        0.0, controller.unitScrollController.position.maxScrollExtent);

                                                    // 执行滚动
                                                    controller.unitScrollController.animateTo(offset,
                                                        duration: const Duration(milliseconds: 300),
                                                        curve: Curves.easeInOut);

                                                    // controller.unitScrollController.scrollToIndex(currentVisibleIndex,
                                                    //     duration: const Duration(milliseconds: 300), preferPosition: AutoScrollPosition.middle);

                                                    if (kDebugMode) {
                                                      print('📦[UnitView]【onDragUpdate】滚动到单元: $currentVisibleIndex');
                                                    }
                                                  },
                                                  onDragEnd: (CrossContainerData containerData) {
                                                    // 容器拖拽结束/需要判断手势是否在本单元内
                                                    // print('---拖拽跨容器onDragEnd: $containerData');
                                                    // todo 是否返回本容器标识
                                                    if (!controller.hasAppUnitList) {
                                                      // 无单元数据,默认本容器
                                                      return true;
                                                    }

                                                    // 单元总数只有一个,默认本容器
                                                    if (controller.unitList.length < 2) {
                                                      return true;
                                                    }

                                                    if (containerData.fromContainerId != null &&
                                                        containerData.dragInfo.draggedItemData != null) {
                                                      // 变量用来记录当前可见的单元索引
                                                      final int currentVisibleIndex = controller.findHoveredCellIndex(
                                                          dragPosition: containerData.dragInfo.dragPosition);

                                                      // 如果没有找到目标单元,默认本容器
                                                      if (currentVisibleIndex == -1) {
                                                        return true;
                                                      }

                                                      // 将拖拽单词添加到目标单元
                                                      final AppUnitResponseEntity<Knowledge> targetAppUnitEntity =
                                                          controller.unitList[currentVisibleIndex];

                                                      // 最后一个添加单元,默认本容器
                                                      if (targetAppUnitEntity.isAddUnit) {
                                                        return true;
                                                      }

                                                      if (targetAppUnitEntity.uid == containerData.fromContainerId) {
                                                        // 如果浮层覆盖的单元id跟浮层透传出的容器id相等,判断是本容器
                                                        return true;
                                                      }

                                                      // 移除本容器旧数据/将拖拽视图数据添加到目标单元
                                                      controller.onRemoveUnitContainerItem(
                                                          containerData: containerData,
                                                          unitUid: containerData.fromContainerId,
                                                          oldIndex: containerData.fromIndex,
                                                          newIndex: 0);
                                                      return false;
                                                    }

                                                    // 不是本容器
                                                    return false;
                                                  },
                                                );
                                              }
                                              return const SizedBox();
                                            },
                                          ),
                                        );
                                      },
                                      isSameItem: (a, b) => a.uid == b.uid),
                                )
                              : _buildEmptyStatus(),
                        ),
                      ),
                      Row(
                        children: [
                          const Spacer(),
                          Container(
                            margin: EdgeInsets.only(
                              top: 10.wMin,
                              right: MediaQuery.of(context).padding.right + 40.wMin,
                              bottom: MediaQuery.of(context).padding.bottom + 24.wMin,
                            ),
                            child: ButtonWidget(
                              text: "生成课程",
                              width: 192.wMin,
                              height: 59.wMin,
                              fontColor: const Color(0xffF2F4F9),
                              borderRadius: 8.wMin,
                              fontSize: 32.wMin,
                              sclae: 1.05,
                              onTap: () => controller.emergentCurriculum(),
                            ),
                          )
                        ],
                      ),
                    ],
                  ));
            },
          );
        });
  }

  /// 知识点暂存区
  Widget buildKnowledgeStorage(BuildContext context) {
    if (!controller.hasUnGroupedList) {
      // 无数据
      return const SizedBox();
    }
    return DottedBorder(
      radius: Radius.circular(24.wMin),
      borderType: BorderType.RRect,
      padding: EdgeInsets.zero,
      color: AppTheme.cWhiteAlpha10,
      dashPattern: const [3],
      strokeWidth: 2.wMin,
      child: Container(
        alignment: Alignment.center,
        width: 1436.ww,
        height: 276.wh,
        padding: EdgeInsets.only(left: 16.wMin, right: 16.wMin, top: 16.wMin, bottom: 16.wMin),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24.wMin),
        ),
        child: AnimatedReorderableGridView<Knowledge>(
          key: const PageStorageKey("unGrouped"),
          enableSwap: false,
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          // 允许拖入到其他容器
          canDragOutItem: true,
          // 不接收外来元素
          canReceiveItem: false,
          // 横向
          scrollDirection: Axis.horizontal,
          enterTransition: [SlideInDown()],
          exitTransition: [SlideInUp()],
          dragStartDelay: const Duration(milliseconds: 200),
          proxyDecorator: proxyDecorator,
          lockedItems: controller.lockKnowledgeList.cast<Knowledge>(),
          // 预加载足够多的单元，避免拖拽过程中浮层消失
          cacheExtent: 30000,
          sliverGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            mainAxisSpacing: 32.wMin,
            childAspectRatio: 244.wh / 180.ww,
          ),
          items: controller.unGrouped.cast<Knowledge>(),
          itemBuilder: (context, index) {
            final Knowledge item = controller.unGrouped[index];
            if (index == 0) {
              return KnowledgePointCard(key: item.globalKey);
            }
            return AppKnowledgeWidget(key: item.globalKey, index: index, knowledge: item);
          },
          isSameItem: (a, b) => a.uid == b.uid,
          onReorder: (int oldIndex, int newIndex) {
            print("排序");
          },
          itemDataGetter: (int index) {
            // 获取当前索引数据
            return controller.unGrouped[index];
          },
          onDragUpdate: (CrossContainerData containerData) {
            // 拖拽更新数据

            // 检查单元列表
            if (!controller.hasAppUnitList) {
              return;
            }

            // 变量用来记录当前可见的单元索引
            final int currentVisibleIndex =
                controller.findHoveredCellIndex(dragPosition: containerData.dragInfo.dragPosition);

            // 如果没有找到可见单元，直接返回
            if (currentVisibleIndex == -1) return;

            // 最后一个添加单元, 直接返回
            if (controller.unitList[currentVisibleIndex].isAddUnit) {
              return;
            }

            // 获取当前单元的位置和尺寸信息
            final currentUnit = controller.unitList[currentVisibleIndex];
            final currentUnitRecord = CommonUtils.getSizeAndPosition(currentUnit.globalKey);

            // 计算单元视图宽度的1/3作为滚动基准
            // final unitWidth = currentUnitRecord.size.width;
            // final scrollThreshold = unitWidth / 3;

            // 获取拖拽位置相对于单元左边缘的偏移量
            // final dragX = containerData.dragInfo.dragPosition.dx;
            final unitLeftX = currentUnitRecord.globalPosition.dx;
            // final relativeX = dragX - unitLeftX;

            // 打印拖拽位置信息，便于调试
            // if (kDebugMode) {
            //   if (relativeX < scrollThreshold) {
            //     print('📦[UnitView]【onDragUpdate】拖拽位置在单元左侧: $currentVisibleIndex');
            //   } else if (relativeX < scrollThreshold * 2) {
            //     print('📦[UnitView]【onDragUpdate】拖拽位置在单元中间: $currentVisibleIndex');
            //   } else {
            //     print('📦[UnitView]【onDragUpdate】拖拽位置在单元右侧: $currentVisibleIndex');
            //   }
            // }

            // 计算滚动偏移量
            double offset;

            // 获取当前可视区域的信息
            final viewportWidth = MediaQuery.of(context).size.width - 240.ww;

            // 将目标单元视图滚动到1/3处
            // 计算目标偏移量：将单元左边缘对齐到视口的1/3处
            final oneThirdViewportPosition = viewportWidth / 3;
            offset = controller.unitScrollController.position.pixels + (unitLeftX - oneThirdViewportPosition);

            // if (kDebugMode) {
            //   print('📦[UnitView]【onDragUpdate】滚动单元到1/3处: $currentVisibleIndex');
            // }

            // 确保偏移量在有效范围内
            offset = offset.clamp(0.0, controller.unitScrollController.position.maxScrollExtent);

            // 执行滚动
            controller.unitScrollController
                .animateTo(offset, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);

            // controller.unitScrollController.scrollToIndex(currentVisibleIndex,
            //     duration: const Duration(milliseconds: 300), preferPosition: AutoScrollPosition.middle);

            // if (kDebugMode) {
            //   print('📦[UnitView]【onDragUpdate】滚动到单元: $currentVisibleIndex');
            // }
          },
          onDragEnd: (CrossContainerData containerData) {
            // 容器拖拽结束/需要判断手势是否在本单元内
            // print('---拖拽跨容器onDragEnd: $containerData');
            // todo 是否返回本容器标识
            if (!controller.hasAppUnitList) {
              // 无单元数据,默认本容器
              return true;
            }

            if (containerData.dragInfo.draggedItemData != null) {
              // 变量用来记录当前可见的单元索引
              final int currentVisibleIndex =
                  controller.findHoveredCellIndex(dragPosition: containerData.dragInfo.dragPosition);

              // 如果没有找到目标单元,默认本容器
              if (currentVisibleIndex == -1) {
                return true;
              }

              // 将拖拽单词添加到目标单元
              final AppUnitResponseEntity<Knowledge> targetAppUnitEntity = controller.unitList[currentVisibleIndex];

              // 最后一个添加单元,默认本容器
              if (targetAppUnitEntity.isAddUnit) {
                return true;
              }

              // 移除本容器旧数据/将拖拽视图数据添加到目标单元
              controller.onRemoveStorageContainerItem(
                  containerData: containerData,
                  unitUid: targetAppUnitEntity.uid,
                  oldIndex: containerData.fromIndex,
                  newIndex: 0);
              return false;
            }

            // 不是本容器
            return false;
          },
        ),
      ),
    );

    // return Container(
    //   width: 1436.ww,
    //   height: 276.wh,
    //   // color: Colors.grey,
    //   // padding: EdgeInsets.only(left: 16.wMin, right: 16.wMin, top: 16.wMin, bottom: 16.wMin),
    //   child: DottedBorder(
    //     radius: Radius.circular(24.wMin),
    //     borderType: BorderType.RRect,
    //     padding: EdgeInsets.zero,
    //     color: AppTheme.cWhiteAlpha10,
    //     dashPattern: const [3],
    //     strokeWidth: 2.wMin,
    //     child: Container(
    //       alignment: Alignment.center,
    //       width: 1436.ww,
    //       padding: EdgeInsets.only(left: 16.wMin, right: 16.wMin, top: 16.wMin, bottom: 16.wMin),
    //       decoration: BoxDecoration(
    //         color: AppTheme.cSurfaceTertiary,
    //         borderRadius: BorderRadius.circular(24.wMin),
    //       ),
    //       child: AnimatedReorderableListView<Knowledge>(
    //         key: const PageStorageKey("unGrouped"),
    //         // 去掉默认的右边编辑按钮
    //         buildDefaultDragHandles: false,
    //         enableSwap: false,
    //         padding: EdgeInsets.zero,
    //         shrinkWrap: true,
    //         scrollDirection: Axis.horizontal,
    //         enterTransition: [SlideInDown()],
    //         exitTransition: [SlideInUp()],
    //         dragStartDelay: const Duration(milliseconds: 200),
    //         proxyDecorator: proxyDecorator,
    //         lockedItems: const <Knowledge>[],
    //         // 预加载足够多的单元，避免拖拽过程中浮层消失
    //         cacheExtent: 30000,
    //         items: controller.unGrouped.cast<Knowledge>(),
    //         itemBuilder: (context, index) {
    //           final Knowledge item = controller.unGrouped[index];
    //           return AppKnowledgeWidget(key: ValueKey(item.uid.toString()), index: index, knowledge: item);
    //         },
    //         isSameItem: (a, b) => a.uid == b.uid,
    //         onReorder: (int oldIndex, int newIndex) {
    //           print("排序");
    //         },
    //       ),
    //     ),
    //   ),
    // );
  }

  // 添加单元虚线
  Widget _buildAddUnitButtonWidget(BuildContext context, {required AppUnitResponseEntity unitEntity}) {
    return TapScaleWidget(
      key: unitEntity.globalKey,
      onTap: OptimizeUtils.noneThrottle(() {
        controller.onCreateUnit(context, name: '');
      }, 350),
      sclae: 1.03,
      child: DottedBorder(
        radius: Radius.circular(24.wMin),
        borderType: BorderType.RRect,
        padding: EdgeInsets.zero,
        color: AppTheme.cWhiteAlpha10,
        dashPattern: const [3],
        strokeWidth: 2.wMin,
        child: Container(
          alignment: Alignment.center,
          width: 864.ww,
          height: 636.wh,
          decoration: BoxDecoration(
            color: AppTheme.cSurfaceTertiary,
            borderRadius: BorderRadius.circular(24.wMin),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                Assets.customCourseIconAddCirclePlus,
                height: 48.wMin,
              ),
              Gaps.getWidth(10.wMin),
              Text(
                "添加单元",
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: AppTheme.cTextTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyStatus() {
    return const SizedBox();
    // return Column(
    //   mainAxisAlignment: MainAxisAlignment.center,
    //   children: [
    //     SvgPicture.asset(Assets.customCourseIconBookOpen, width: 120.wMax),
    //     Gaps.getHeight(16.wMin),
    //     Row(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         Text(
    //           "当前没有书籍",
    //           style: TextStyle(
    //             fontSize: 24.wMin,
    //             color: AppTheme.cTextDisabled,
    //             fontWeight: FontWeight.w500,
    //           ),
    //         ),
    //         Gaps.getWidth(8.wMin),
    //         TapScaleWidget(
    //           onTap: () {
    //             // 去创建书籍
    //           },
    //           child: Text(
    //             "去创建",
    //             style: TextStyle(
    //               fontSize: 24.wMin,
    //               color: AppTheme.cStaticWhite,
    //               fontWeight: FontWeight.w500,
    //               decoration: TextDecoration.underline,
    //             ),
    //           ),
    //         )
    //       ],
    //     ),
    //   ],
    // );
  }

  Widget proxyDecorator(Widget child, int index, Animation<double> animation) {
    // 缓存动画值并防止NaN
    final double animationValue = animation.value.isNaN ? 1.0 : animation.value;
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        // 防止布局计算使用非法值
        return Material(
          elevation: 0,
          color: const Color(0xff23283D),
          // 使用防护机制确保值始终有效
          borderRadius: BorderRadius.circular(6.wMin * (animationValue.isNaN ? 1.0 : animationValue).clamp(0.0, 1.0)),
          // 添加额外封装来防止布局异常
          clipBehavior: Clip.antiAlias,
          child: child,
        );
      },
      child: child,
    );
  }
}

// class UnitView extends GetView<UnitController> {
//   const UnitView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder(
//         init: controller,
//         id: "unit",
//         builder: (_) {
//           return LayoutBuilder(
//             builder: (context, constraints) {
//               return Scaffold(
//                   backgroundColor: AppTheme.cBgPrimary,
//                   body: Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       const PageAppBarWidget(),
//                       Expanded(
//                         child: Center(
//                           child: controller.hasAppUnitList
//                               ? Container(
//                                   height: 636.wh,
//                                   margin: EdgeInsets.only(left: 120.wMin, right: 120.wMin),
//                                   child: ListView.separated(
//                                     itemCount: (controller.unitList!.length) + 1,
//                                     scrollDirection: Axis.horizontal,
//                                     padding: EdgeInsets.zero,
//                                     separatorBuilder: (context, index) => SizedBox(width: 32.wMin),
//                                     itemBuilder: (context, index) {
//                                       // 如果是最后一个索引，返回添加单元的部件
//                                       if (index == controller.unitList!.length) {
//                                         return _buildAddUnitButtonWidget(context);
//                                       }
//                                       final AppUnitResponseEntity unitEntity = controller.unitList![index];
//                                       return buildUnitItem(context, index: index, unitEntity: unitEntity);
//                                     },
//                                   ),
//                                 )
//                               : _buildEmptyStatus(),
//                         ),
//                       ),
//                       Container(
//                         margin: EdgeInsets.only(
//                           top: 10.wMin,
//                           right: MediaQuery.of(context).padding.right + 40.wMin,
//                           bottom: MediaQuery.of(context).padding.bottom + 24.wMin,
//                         ),
//                         child: ButtonWidget(
//                           text: "生成课程",
//                           width: 192.wMin,
//                           height: 59.wMin,
//                           fontColor: const Color(0xffF2F4F9),
//                           borderRadius: 8.wMin,
//                           fontSize: 32.wMin,
//                           sclae: 1.05,
//                           onTap: () => controller.emergentCurriculum(),
//                         ),
//                       ),
//                     ],
//                   ));
//             },
//           );
//         });
//   }
//
//   Widget buildUnitItem(BuildContext context, {required int index, required AppUnitResponseEntity unitEntity}) {
//     return Container(
//       key: ValueKey(unitEntity.uid.toString()),
//       width: 864.ww,
//       height: 636.wh,
//       padding: EdgeInsets.only(left: 24.wMin, top: 24.wMin, right: 24.wMin),
//       decoration: BoxDecoration(
//         color: const Color(0xff15171B).withValues(alpha: 0.9),
//         borderRadius: BorderRadius.circular(24.wMin),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             color: Colors.grey,
//             child: Row(
//               children: [
//                 Text(
//                   unitEntity.name ?? '',
//                   style: TextStyle(
//                     fontSize: 32.wMin,
//                     color: AppTheme.cTextPrimary,
//                     fontWeight: FontWeight.w600,
//                     height: 1,
//                   ),
//                 )
//               ],
//             ),
//           ),
//           Gaps.getHeight(16.wMin),
//           Container(height: 1.wMin, width: double.infinity, color: AppTheme.cWhiteAlpha10),
//           Gaps.getHeight(16.wMin),
//           if (unitEntity.hasKnowledgeList)
//             Expanded(
//                 child: AnimatedReorderableGridView(
//               items: unitEntity.knowledgeList!.cast<Knowledge>(),
//               shrinkWrap: true,
//               padding: EdgeInsets.zero,
//               enterTransition: [SlideInDown()],
//               exitTransition: [SlideInUp()],
//               insertDuration: const Duration(milliseconds: 200),
//               removeDuration: const Duration(milliseconds: 200),
//               dragStartDelay: const Duration(milliseconds: 200),
//               sliverGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 4,
//                 mainAxisSpacing: 24.wMin,
//                 // 列间距
//                 crossAxisSpacing: 32.wMin,
//                 childAspectRatio: 180.ww / 244.wh,
//               ),
//               proxyDecorator: proxyDecorator,
//               lockedItems: const <Knowledge>[],
//               onReorder: (int oldIndex, int newIndex) {},
//               isSameItem: (a, b) => a.uid == b.uid,
//               itemBuilder: (context, index) {
//                 final Knowledge item = unitEntity.knowledgeList![index];
//                 return AppKnowledgeWidget(key: ValueKey(item.uid.toString()), index: index, knowledge: item);
//               },
//             ))
//         ],
//       ),
//     );
//   }
//
//   // 添加单元虚线
//   Widget _buildAddUnitButtonWidget(BuildContext context) {
//     return TapScaleWidget(
//       key: const ValueKey('add_unit'),
//       onTap: OptimizeUtils.noneThrottle(() {}, 350),
//       sclae: 1.03,
//       child: DottedBorder(
//         radius: Radius.circular(24.wMin),
//         borderType: BorderType.RRect,
//         padding: EdgeInsets.zero,
//         color: AppTheme.cWhiteAlpha10,
//         dashPattern: const [3],
//         strokeWidth: 2.wMin,
//         child: Container(
//           alignment: Alignment.center,
//           width: 360.wMin,
//           decoration: BoxDecoration(
//             color: AppTheme.cSurfaceTertiary,
//             borderRadius: BorderRadius.circular(24.wMin),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               SvgPicture.asset(
//                 Assets.customCourseIconAddCirclePlus,
//                 height: 48.wMin,
//               ),
//               Gaps.getWidth(10.wMin),
//               Text(
//                 "添加单元",
//                 style: TextStyle(
//                   fontSize: 24.wMin,
//                   color: AppTheme.cTextTertiary,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildEmptyStatus() {
//     return const SizedBox();
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         SvgPicture.asset(Assets.customCourseIconBookOpen, width: 120.wMax),
//         Gaps.getHeight(16.wMin),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               "当前没有书籍",
//               style: TextStyle(
//                 fontSize: 24.wMin,
//                 color: AppTheme.cTextDisabled,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             Gaps.getWidth(8.wMin),
//             TapScaleWidget(
//               onTap: () {
//                 // 去创建书籍
//               },
//               child: Text(
//                 "去创建",
//                 style: TextStyle(
//                   fontSize: 24.wMin,
//                   color: AppTheme.cStaticWhite,
//                   fontWeight: FontWeight.w500,
//                   decoration: TextDecoration.underline,
//                 ),
//               ),
//             )
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget proxyDecorator(Widget child, int index, Animation<double> animation) {
//     return AnimatedBuilder(
//       animation: animation,
//       builder: (BuildContext context, Widget? child) {
//         return Material(
//           elevation: 0,
//           color: const Color(0xff23283D),
//           borderRadius: BorderRadius.circular(6.wMin),
//           child: child,
//         );
//       },
//       child: child,
//     );
//   }
// }
