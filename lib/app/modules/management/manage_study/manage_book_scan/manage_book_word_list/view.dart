import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/generated/assets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:langwise/common/values/values.dart';
import '../../../common/commons.dart';
import '../../../utils/utils.dart';
import 'bindings.dart';
import 'controller.dart';

class ManageBookWordListPage extends GetView<ManageBookWordListController> {
  final String tagText;
  const ManageBookWordListPage({Key? key, required this.tagText}) : super(key: key);

  @override
  String? get tag => tagText;

  /// 静态跳转方法
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_WORD_LIST}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageBookWordListPage(tagText: tag),
      binding: ManageBookWordListBinding(tag: tag),
      routeName: Routes.MANAGE_WORD_LIST,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ManageBookWordListController>(
      init: controller,
      id: 'manage_word_list',
      builder: (_) {
        return ManageScaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.transparent,
          body: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: PageBackWidget(
                  child: Container(
                margin: EdgeInsets.only(left: 24.ww, right: 24.ww),
                child: Column(
                  children: [
                    Gaps.getHeight(18.wh),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '教材ID: ${controller.bookId ?? ''}  书名: ${controller.bookName ?? ''}',
                          style: TextStyle(
                            color: const Color(0xffEBEEF3),
                            fontSize: 22.wMin,
                            fontWeight: FontWeight.w400,
                            height: 1.0,
                          ),
                        ),
                        const Spacer(),
                        // 返回按钮
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.ww, vertical: 6.wMax),
                            decoration: BoxDecoration(
                              color: const Color(0xff23283D),
                              borderRadius: BorderRadius.circular(8.ww),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.arrow_back,
                                  size: 24.wMin,
                                  color: AppTheme.cTextPrimary,
                                ),
                                SizedBox(width: 8.ww),
                                Text(
                                  '返回教材列表',
                                  style: TextStyle(
                                    color: AppTheme.cTextPrimary,
                                    fontSize: 18.wMin,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Gaps.getHeight(24.wh),
                    Expanded(
                        child: SyncDataTableWidget<UnitResponseEntity>(
                      header: _buildHeader(context),
                      dataRowHeight: 90.wh,
                      minWidth: 1920.ww,
                      showHeadingCheckBox: false,
                      showCheckboxColumn: true,
                      sourceCallback: (DessertDataSource source) {
                        controller.onSetDataSourceSync(source);
                      },
                      columns: _buildColumns(),
                      onSecondaryTap: (index, v1) {
                        controller.onSecondaryTap(index, v1);
                      },
                      dataDisableCallback: (UnitResponseEntity value) {
                        return controller.onDataDisableCallback(value);
                      },
                      onRowSelectChanged: (bool selected, int id, UnitResponseEntity value) {
                        controller.onRowSelectChanged(selected, id, value);
                      },
                      dataCellBuilder: (int index, dessert) {
                        return [
                          DataCell(DataGeneralColumnWidget(
                              margin: EdgeInsets.only(left: 24.ww, right: 24.ww, top: 2.wh, bottom: 2.wh),
                              child: Container(
                                alignment: Alignment.center,
                                color: Colors.transparent,
                                child: Stack(
                                  children: [
                                    CachedImageWidget(dessert.imageUrl ?? '',
                                        width: 90.wh,
                                        fit: BoxFit.contain,
                                        errorWidget: Container(
                                          color: const Color(0xffD9D9D9),
                                          width: 90.wh,
                                          child: buildImage(
                                            width: 90.wh,
                                            height: 90.wh,
                                            Assets.managerImageNotFound,
                                            fit: BoxFit.contain,
                                          ),
                                        )),
                                    Positioned(
                                        top: 0,
                                        left: 0,
                                        child: InventoryTagWidget(
                                          type: dessert.newInventory,
                                        )),
                                  ],
                                ),
                              ))),
                          DataCell(
                            EditTableTextCell(
                              initialValue: dessert.content ?? '',
                              maxLines: 2,
                              onValueChanged: (String newValue) {
                                controller.onEditKnowledgeDetail(dessert, newContent: newValue);
                              },
                            ),
                          ),
                          DataCell(
                            EditTableTextCell(
                              initialValue: dessert.definition ?? '',
                              maxLines: 3,
                              onValueChanged: (String newValue) {
                                controller.onEditKnowledgeDetail(dessert, newDefinition: newValue);
                              },
                            ),
                          ),
                          DataCell(DataGeneralColumnWidget(
                            child: Text(
                              dessert.target ?? '',
                              style: TextStyle(
                                color: const Color(0xffEBEEF3),
                                fontSize: 18.wMin,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          )),
                          DataCell(DataGeneralColumnWidget(
                            child: _buildMatchWidget(isMatch: dessert.hasMatch),
                          )),
                          DataCell(DataGeneralColumnWidget(
                            child: Text(
                              '${dessert.similarity ?? 0}',
                              style: TextStyle(
                                color: const Color(0xffEBEEF3),
                                fontSize: 18.wMin,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          )),
                          DataCell(DataGeneralColumnWidget(
                            child: _buildHandleMatchWidget(context,
                                index: index, dessert: dessert, needMatch: !dessert.hasMatch),
                          )),
                          DataCell(_buildKnowledgeTypeCell(dessert)),
                          DataCell(
                              DataGeneralColumnWidget(
                                child: Text(
                                  dessert.unitName ?? '',
                                  style: TextStyle(
                                    color: const Color(0xffEBEEF3),
                                    fontSize: 18.wMin,
                                    fontWeight: FontWeight.w400,
                                    height: 1.0,
                                  ),
                                ),
                              ), onTap: () {
                            controller.toEditUnit(index, dessert);
                          }),
                        ];
                      },
                    ))
                  ],
                ),
              ))),
          floatingActionButton: controller.state.editEnable
              ? TapScaleWidget(
                  onTap: OptimizeUtils.noneThrottle(() {
                    controller.onConfirm();
                  }, 200),
                  child: Container(
                    width: 100.ww,
                    height: 60.wh,
                    alignment: const Alignment(0, 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.wMin),
                      color: const Color(0xff2388FF),
                    ),
                    child: Text(
                      "确认",
                      style: TextStyle(
                        fontSize: 16.wMin,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xffEBEEF3),
                      ),
                    ),
                  ))
              : null,
        );
      },
    );
  }

  /// 构建排序按钮
  Widget _buildSortButton(String field, String label) {
    return GetBuilder<ManageBookWordListController>(
      id: "sort_buttons",
      builder: (_) {
        final isActive = controller.state.sortField == field;
        final isAsc = controller.state.sortDirection == 'asc';
        return SortButton(
          text: label,
          isActive: isActive,
          isAsc: isAsc,
          width: 117.ww,
          height: 42.wh,
          activeBackgroundColor: const Color(0xff23283D),
          inactiveBackgroundColor: const Color(0xff23283D),
          borderColor: const Color(0xff4B5268),
          iconColor: const Color(0xff2388FF),
          borderWidth: 1.wMin,
          borderRadius: 8.wMin,
          textStyle: TextStyle(
            fontSize: Dimens.dn_16.wMin,
            height: 1.0,
            fontWeight: FontWeight.w400,
            color: const Color(0xffEBEEF3),
          ),
          onTap: () => controller.setSort(field),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(children: [
      // 状态筛选下拉框
      GetBuilder<ManageBookWordListController>(
        id: "unit_response_entity_filter",
        builder: (_) {
          // 使用ReviewStatus枚举值作为选项
          final statusOptions = [null, ...controller.state.simpleUnits];
          // 使用枚举的label属性作为显示文本
          String getStatusLabel(UnitResponseEntity? status) => status?.unitName ?? '全部单元';
          // 获取当前选中的索引
          final selectedIndex = statusOptions.indexOf(controller.state.unitResponseEntityFilter);
          return Builder(builder: (targetContext) {
            return GestureDetector(
              onTap: () {
                // 在指定位置显示菜单
                ButtonDropdownMenu.showAtPosition<UnitResponseEntity?>(
                  context: targetContext,
                  options: statusOptions,
                  labelBuilder: (option) => getStatusLabel(option),
                  selectedIndex: selectedIndex,
                  backgroundColor: const Color(0xff23283D),
                  borderColor: const Color(0xff4B5268),
                  borderRadius: 8.wMin,
                  width: 132.ww,
                  onSelected: (index, option) {
                    // 处理选择
                    controller.setUnitResponseEntityFilter(option);
                  },
                );
              },
              child: Container(
                key: controller.state.unitResponseEntityFilterKey,
                width: 117.ww,
                height: 42.wh,
                padding: EdgeInsets.symmetric(horizontal: 12.ww),
                decoration: BoxDecoration(
                  color: const Color(0xff23283D),
                  borderRadius: BorderRadius.circular(8.wMin),
                  border: Border.all(
                    color: const Color(0xff4B5268),
                    width: 1.wMin,
                  ),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      Assets.imageModerationStatus,
                      width: 14.wMin,
                      height: 14.wMin,
                    ),
                    Gaps.getWidth(6.ww),
                    Text(
                      getStatusLabel(controller.state.unitResponseEntityFilter),
                      style: TextStyle(
                        fontSize: Dimens.dn_16.wMin,
                        height: 1.0,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xffEBEEF3),
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        },
      ),
      Gaps.getWidth(12.ww),
      // 状态筛选下拉框
      GetBuilder<ManageBookWordListController>(
        id: "match_status_filter",
        builder: (_) {
          // 使用枚举的label属性作为显示文本
          String getStatusLabel(status) => status ?? '全部状态';
          final statusFilterKey = GlobalKey();

          return Builder(builder: (targetContext) {
            return GestureDetector(
              onTap: () {
                ButtonDropdownMenu.showAtPosition<String?>(
                  context: targetContext,
                  options: controller.state.matchTypeList,
                  labelBuilder: (option) => getStatusLabel(option),
                  selectedIndex: controller.state.statusFilterIndex,
                  onSelected: (index, option) => controller.setStatusFilter(index, option),
                  backgroundColor: const Color(0xff23283D),
                  borderColor: const Color(0xff4B5268),
                  borderRadius: 8.wMin,
                  width: 132.ww,
                );
              },
              child: Container(
                key: statusFilterKey,
                width: 117.ww,
                height: 42.wh,
                padding: EdgeInsets.symmetric(horizontal: 12.ww),
                decoration: BoxDecoration(
                  color: const Color(0xff23283D),
                  borderRadius: BorderRadius.circular(8.wMin),
                  border: Border.all(
                    color: const Color(0xff4B5268),
                    width: 1.wMin,
                  ),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      Assets.imageModerationStatus,
                      width: 14.wMin,
                      height: 14.wMin,
                    ),
                    Gaps.getWidth(6.ww),
                    Text(
                      getStatusLabel(controller.state.statusFilter),
                      style: TextStyle(
                        fontSize: Dimens.dn_16.wMin,
                        height: 1.0,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xffEBEEF3),
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        },
      ),
      Gaps.getWidth(12.ww),
      _buildSortButton('similarity', '匹配度排序'),
      const Spacer(),
      SearchWidget(
        width: 160.ww,
        height: 42.wh,
        hintText: '英文',
        onChanged: (String value) {
          controller.onSetTitle(value);
        },
        onSubmitted: (String value) {
          controller.onSetTitle(value, isSubmit: true);
        },
      ),
      Gaps.getWidth(12.ww),
      SearchWidget(
        width: 160.ww,
        height: 42.wh,
        hintText: '翻译',
        onChanged: (String value) {
          controller.onSetDefinition(value);
        },
        onSubmitted: (String value) {
          controller.onSetDefinition(value, isSubmit: true);
        },
      ),
      Gaps.getWidth(12.ww),
      SearchWidget(
        width: 160.ww,
        height: 42.wh,
        hintText: '单元',
        onChanged: (String value) {
          controller.onSetName(value);
        },
        onSubmitted: (String value) {
          controller.onSetName(value, isSubmit: true);
        },
      ),
      Obx(() {
        if (controller.state.selectedRows.isEmpty) return const SizedBox();
        return TapScaleWidget(
            onTap: OptimizeUtils.noneThrottle(() {
              controller.toBathDelete(context);
            }, 100),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.wMin),
                color: const Color(0xFF2388FF), // 底色
              ),
              margin: EdgeInsets.only(left: 12.ww, right: 12.ww),
              width: 100.ww,
              height: 42.wh,
              alignment: Alignment.center,
              child: Text(
                "批量删除(${controller.state.selectedRows.length})",
                style: TextStyle(
                  color: const Color(0xffEBEEF3),
                  fontSize: 14.wMin,
                  fontWeight: FontWeight.w400,
                  height: 1.0,
                ),
              ),
            ));
      }),
      Obx(() {
        if (controller.state.selectedRows.isEmpty) return const SizedBox();
        return TapScaleWidget(
            onTap: OptimizeUtils.noneThrottle(() {
              controller.toBathEdit();
            }, 100),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.wMin),
                color: const Color(0xFF2388FF), // 底色
              ),
              width: 100.ww,
              height: 42.wh,
              alignment: Alignment.center,
              child: Text(
                "批量编辑(${controller.state.selectedRows.length})",
                style: TextStyle(
                  color: const Color(0xffEBEEF3),
                  fontSize: 14.wMin,
                  fontWeight: FontWeight.w400,
                  height: 1.0,
                ),
              ),
            ));
      }),
      ManageAuthBoxWidget(
        authCodes: const [ManageAuthCode.bookMatchBatch],
        child: TapScaleWidget(
            onTap: OptimizeUtils.noneThrottle(() {
              controller.onAutoMatch();
            }, 100),
            child: Container(
              margin: EdgeInsets.only(left: 12.ww),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.wMin),
                color: const Color(0xFF2388FF), // 底色
              ),
              width: 100.ww,
              height: 42.wh,
              alignment: Alignment.center,
              child: Text(
                "自动匹配",
                style: TextStyle(
                  color: const Color(0xffEBEEF3),
                  fontSize: 14.wMin,
                  fontWeight: FontWeight.w400,
                  height: 1.0,
                ),
              ),
            )),
      ),
      ManageAuthBoxWidget(
        authCodes: const [ManageAuthCode.courseModuleUnitList],
        child: TapScaleWidget(
            onTap: OptimizeUtils.noneThrottle(() {
              controller.toUnitManage();
            }, 100),
            child: Container(
              margin: EdgeInsets.only(left: 12.ww),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.wMin),
                color: const Color(0xFF2388FF), // 底色
              ),
              width: 100.ww,
              height: 42.wh,
              alignment: Alignment.center,
              child: Text(
                "单元管理",
                style: TextStyle(
                  color: const Color(0xffEBEEF3),
                  fontSize: 14.wMin,
                  fontWeight: FontWeight.w400,
                  height: 1.0,
                ),
              ),
            )),
      )
    ]);
  }

  List<DataColumn> _buildColumns() {
    return [
      DataColumn2(
          label: DataGeneralColumnWidget(
            child: Text(
              '图片',
              style: TextStyle(
                  fontSize: 18.wMin,
                  color: const Color(0xffACB4C0),
                  fontWeight: FontWeight.w400,
                  overflow: TextOverflow.ellipsis),
            ),
          ),
          fixedWidth: 160.ww),
      DataColumn2(
          label: DataGeneralColumnWidget(
            child: Text(
              '英文',
              style: TextStyle(
                  fontSize: 18.wMin,
                  color: const Color(0xffACB4C0),
                  fontWeight: FontWeight.w400,
                  overflow: TextOverflow.ellipsis),
            ),
          ),
          fixedWidth: 220.ww),
      DataColumn2(
          label: DataGeneralColumnWidget(
            child: Text(
              '翻译',
              style: TextStyle(
                  fontSize: 18.wMin,
                  color: const Color(0xffACB4C0),
                  fontWeight: FontWeight.w400,
                  overflow: TextOverflow.ellipsis),
            ),
          ),
          fixedWidth: 320.ww),
      DataColumn2(
          label: DataGeneralColumnWidget(
            child: Text(
              '匹配文本',
              style: TextStyle(
                fontSize: 18.wMin,
                color: const Color(0xffACB4C0),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          headingRowAlignment: MainAxisAlignment.start,
          fixedWidth: 220.ww),
      DataColumn2(
          label: DataGeneralColumnWidget(
            child: Text(
              '是否匹配',
              style: TextStyle(
                  fontSize: 18.wMin,
                  color: const Color(0xffACB4C0),
                  fontWeight: FontWeight.w400,
                  overflow: TextOverflow.ellipsis),
            ),
          ),
          fixedWidth: 160.ww),
      DataColumn2(
          label: DataGeneralColumnWidget(
            child: Text(
              '匹配度',
              style: TextStyle(
                  fontSize: 18.wMin,
                  color: const Color(0xffACB4C0),
                  fontWeight: FontWeight.w400,
                  overflow: TextOverflow.ellipsis),
            ),
          ),
          fixedWidth: 160.ww),
      DataColumn2(
          label: DataGeneralColumnWidget(
            child: Text(
              '手动匹配',
              style: TextStyle(
                  fontSize: 18.wMin,
                  color: const Color(0xffACB4C0),
                  fontWeight: FontWeight.w400,
                  overflow: TextOverflow.ellipsis),
            ),
          ),
          fixedWidth: 160.ww),
      DataColumn2(
          label: DataGeneralColumnWidget(
            child: Text(
              '类型',
              style: TextStyle(
                  fontSize: 18.wMin,
                  color: const Color(0xffACB4C0),
                  fontWeight: FontWeight.w400,
                  overflow: TextOverflow.ellipsis),
            ),
          ),
          fixedWidth: 160.ww),
      DataColumn2(
          label: DataGeneralColumnWidget(
            child: Text(
              '单元',
              style: TextStyle(
                  fontSize: 18.wMin,
                  color: const Color(0xffACB4C0),
                  fontWeight: FontWeight.w400,
                  overflow: TextOverflow.ellipsis),
            ),
          ),
          fixedWidth: 160.ww)
    ];
  }

  /// 是否匹配标签
  Widget _buildMatchWidget({bool isMatch = false}) {
    // 定义颜色
    const Color matchColor = Color(0xff63DE77); // 匹配颜色
    const Color unmatchColor = Color(0xffFF2D46); // 不匹配颜色
    final Color currentColor = isMatch ? matchColor : unmatchColor;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.ww, vertical: 6.wMax),
      decoration: BoxDecoration(
        // 使用当前颜色的 0.2 透明度作为背景
        color: currentColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8.wMin),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isMatch ? Icons.check_circle_sharp : Icons.cancel_sharp,
            size: 24.wMin,
            color: currentColor,
          ),
          SizedBox(width: 4.ww),
          Text(
            isMatch ? '是' : '否',
            style: TextStyle(
              color: currentColor,
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  /// 手动匹配按钮
  Widget _buildHandleMatchWidget(BuildContext context,
      {required int index, required UnitResponseEntity dessert, bool needMatch = false}) {
    return GestureDetector(
      onTap: () {
        if (needMatch) {
          controller.toAddKnowledge(context, index, dessert, []);
        } else {
          controller.onCancelMatch(context, dessert);
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.ww, vertical: 6.wMax),
        decoration: BoxDecoration(
          color: needMatch ? const Color(0xff2388FF) : const Color(0xFF353E5C),
          borderRadius: BorderRadius.circular(4.wMin),
        ),
        child: Text(
          needMatch ? '手动匹配' : '已匹配',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  /// 状态标签单元格
  /// 状态标签单元格
  /// 点击时显示状态选择菜单
  /// [item] - 书籍对象
  Widget _buildKnowledgeTypeCell(UnitResponseEntity dessert) {
    return DataGeneralColumnWidget(
      child: Builder(builder: (context) {
        return TapScaleWidget(
            onTap: OptimizeUtils.noneThrottle(() {
              // 获取有效的状态类型列表
              final validTypes = KnowledgeType.values.toList();
              // 显示状态选择菜单
              KnowledgeTypeMenuManager.showMenu(
                context: context,
                verticalOffset: 0,
                horizontalOffset: 0,
                backgroundColor: const Color(0xff2F364C),
                types: validTypes,
                onSelected: (type, index) {
                  controller.onEditKnowledgeDetail(dessert, newContentType: type.value);
                },
              );
            }, 200),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                dessert.newKnowledgeType.title,
                style: TextStyle(
                  color: const Color(0xffEBEEF3),
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ));
      }),
    );
  }
}
