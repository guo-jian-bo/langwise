import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:quiz_play/utils/common_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../generated/assets.dart';
import '../../../../../routes/routes.dart';
import '../../../common/commons.dart';
import '../../../utils/utils.dart';
import '../bindings/manage_level_binding.dart';
import '../controllers/manage_level_controller.dart';

class ManageLevelView extends GetView<ManageLevelController> {
  final String tagText;
  const ManageLevelView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_LEVEL}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      () => ManageLevelView(tagText: tag),
      binding: ManageLevelBinding(tag: tag),
      arguments: arguments,
      routeName: Routes.MANAGE_LEVEL,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ManageLevelController>(
      tag: tagText,
      id: 'manage_level',
      builder: (_) {
        return ManageScaffold(
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Column(
              children: [
                _buildTitleWidget(),
                Gaps.getHeight(15.wh),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: 24.ww, right: 24.ww),
                    child: AsyncDataTableWidget<LevelResponseEntity>(
                      header: _buildHeader(),
                      dataRowHeight: 116.wh,
                      minWidth: 1830.ww,
                      sourceCallback: (AsyncDataTableSource source) {
                        controller.onSetDataSourceAsync(source);
                      },
                      fetchData: (int currentPage, int startingAt, int count, String sortedBy, bool sortedAsc, bool noData) {
                        return controller.onFetchPages(currentPage, startingAt, count, sortedBy, sortedAsc, noData);
                      },
                      columns: _buildColumns(),
                      dataCellBuilder: (dessert, int startIndex) {
                        return [
                          DataCell(DataGeneralColumnWidget(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    const Spacer(),
                                    ManageAuthBoxWidget(
                                      authCodes: const [
                                        ManageAuthCode.courseLevelEdit,
                                      ],
                                      child: EditStructureCell(
                                        title: '编辑信息',
                                        icon: Assets.managerEdit,
                                        onTap: () {
                                          controller.onEdit(dessert);
                                        },
                                      ),
                                    ),
                                    const Spacer(),
                                  ],
                                ),
                                Gaps.getHeight(8.wh),
                                Row(
                                  children: [
                                    const Spacer(),
                                    ManageAuthBoxWidget(
                                      authCodes: const [
                                        ManageAuthCode.courseLevelModuleList,
                                      ],
                                      child: EditStructureCell(
                                        title: '查看模块',
                                        icon: Assets.managerEye,
                                        onTap: () {
                                          controller.toAllCourseDetail(dessert);
                                        },
                                      ),
                                    ),
                                    const Spacer(),
                                  ],
                                )
                              ],
                            ),
                          )),
                          DataCell(TableTextCell('${dessert.uid}')),
                          DataCell(
                            EditTableTextCell(
                              initialValue: dessert.name ?? '',
                              maxLines: 2,
                              onValueChanged: (String newValue) {
                                controller.onEditLevel(dessert, newName: newValue);
                              },
                            ),
                          ),
                          DataCell(
                            EditTableTextCell(
                              initialValue: dessert.description ?? '',
                              maxLines: 3,
                              onValueChanged: (String newValue) {
                                controller.onEditLevel(dessert, newDescription: newValue);
                              },
                            ),
                          ),
                          DataCell(TableTextCell(dessert.newLanguage)),
                          DataCell(DataGeneralColumnWidget(
                            child: Column(
                              children: dessert.moduleList != null
                                  ? List.generate(
                                      (dessert.moduleList!.length <= 2) ? dessert.moduleList!.length : 3,
                                      (int index) {
                                      final ModuleResponseEntity miniEntity = dessert.moduleList![index];
                                      return Builder(builder: (targetContext) {
                                        return UnitItemWidget(
                                          key: miniEntity.globalKey,
                                          index: index,
                                          title: (index == 2)
                                              ? "共${dessert.moduleList!.length}个模块"
                                              : miniEntity.name ?? '',
                                          isNeedIcon: index == 2,
                                          onTap: (int i) {
                                            if (index == 2) {
                                              final ModuleResponseEntity newEntity = dessert.moduleList![i];
                                              var record = CommonUtils.getSizeAndPosition(newEntity.globalKey);
                                              UnitItemWidgetManager.show(
                                                context: targetContext,
                                                list: dessert.moduleList!.map((element) => element.name).toList(),
                                                defaultIndex: 0,
                                                width: record.size.width,
                                              );
                                            }
                                          },
                                        );
                                      });
                                    })
                                  : [],
                              mainAxisAlignment: MainAxisAlignment.center,
                            ),
                          )),
                          DataCell(TableTextCell(dessert.vendor ?? '')),
                          DataCell(TableTextCell(dessert.vendorName ?? '')),
                          DataCell(TableTextCell(dessert.newUpdate)),
                          DataCell(TableTextCell(dessert.newCreate)),
                        ];
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitleWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gaps.getHeight(20.wh),
        Row(
          children: [
            Gaps.getWidth(24.ww),
            ManageAuthBoxWidget(
              authCodes: const [
                ManageAuthCode.courseRelationLevel,
                ManageAuthCode.courseLevelCopy,
                ManageAuthCode.courseLevelCreate,
              ],
              isAny: true,
              child: Obx(() {
                return TopTabBarWidget(
                  index: 0,
                  title: '添加',
                  leftIcon: Assets.manageIconAdd,
                  isSelected: controller.filterIndex == 0,
                  onTap: (int index) {
                    controller.filterIndex = index;
                    controller.add();
                  },
                );
              }),
            ),
            Gaps.getWidth(12.ww),
            Builder(builder: (BuildContext context) {
              return TopTabBarWidget(
                index: 1,
                title: '排序',
                leftIcon: Assets.manageIconSort,
                isSelected: controller.filterIndex == 1,
                onTap: (int index) {
                  controller.filterIndex = index;
                  controller.toSort(context);
                },
              );
            }),
            Gaps.getWidth(12.ww),
            Builder(builder: (targetContext) {
              return Obx(() {
                return TopTabBarWidget(
                  index: 2,
                  title: '筛选',
                  leftIcon: Assets.manageIconFilter,
                  rightIcon: Assets.manageIconArrowDown,
                  isSelected: controller.filterIndex == 2,
                  onTap: (int index) {
                    controller.filterIndex = index;
                    controller.showFilter(targetContext);
                  },
                );
              });
            }),
            const Spacer(),
            Gaps.getWidth(24.ww),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(children: [
      SearchWidget(
        width: 160.ww,
        height: 42.wh,
        hintText: 'uid',
        onChanged: (String value) {
          controller.onSetId(value);
        },
        onSubmitted: (String value) {
          controller.onSetId(value, isSubmit: true);
        },
      ),
      Gaps.getWidth(12.ww),
      SearchWidget(
        width: 160.ww,
        height: 42.wh,
        hintText: '名字',
        onChanged: (String value) {
          controller.onSetName(value);
        },
        onSubmitted: (String value) {
          controller.onSetName(value, isSubmit: true);
        },
      ),
      Gaps.getWidth(12.ww),
      SearchWidget(
        width: 160.ww,
        height: 42.wh,
        hintText: '描述',
        onChanged: (String value) {
          controller.onSetDes(value);
        },
        onSubmitted: (String value) {
          controller.onSetDes(value, isSubmit: true);
        },
      ),
    ]);
  }

  DataColumn2 _buildColumn(String title, {double? width, bool alignStart = true, int? maxLines, ColumnSize size = ColumnSize.L}) {
    return DataColumn2(
      label: DataGeneralColumnWidget(
        child: Text(
          title,
          maxLines: maxLines,
          style: TextStyle(
            fontSize: 18.wMin,
            color: const Color(0xffACB4C0),
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      headingRowAlignment: alignStart ? MainAxisAlignment.start : MainAxisAlignment.center,
      fixedWidth: width?.ww,
      size: size,
    );
  }

  List<DataColumn> _buildColumns() {
    return [
      _buildColumn('操作', width: 210),
      _buildColumn('uid', size: ColumnSize.S),
      _buildColumn('名字'),
      _buildColumn('描述', maxLines: 3),
      _buildColumn('语言', size: ColumnSize.S),
      _buildColumn('模块', width: 240),
      _buildColumn('供应商', width: 160),
      _buildColumn('创建者', size: ColumnSize.S),
      _buildColumn('更新时间', size: ColumnSize.S),
      _buildColumn('创建时间', size: ColumnSize.S),
    ];
  }
}
