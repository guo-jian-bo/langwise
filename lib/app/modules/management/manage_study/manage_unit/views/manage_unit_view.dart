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
import '../bindings/manage_unit_binding.dart';
import '../controllers/manage_unit_controller.dart';

class ManageUnitView extends GetView<ManageUnitController> {
  final String tagText;
  const ManageUnitView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_UNIT}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      () => ManageUnitView(tagText: tag),
      binding: ManageUnitBinding(tag: tag),
      arguments: arguments,
      routeName: Routes.MANAGE_UNIT,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ManageUnitController>(
      tag: tagText,
      id: 'manage_unit',
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
                    child: AsyncDataTableWidget<NewUnitResponseEntity>(
                      header: _buildHeader(),
                      dataRowHeight: 116.wh,
                      minWidth: 2220.ww,
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
                                      authCodes: const [ManageAuthCode.courseUnitEdit],
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
                                      authCodes: const [ManageAuthCode.courseUnitLessonList],
                                      child: EditStructureCell(
                                        title: '查看课时',
                                        icon: Assets.managerEye,
                                        onTap: () {
                                          controller.toModuleDetils(dessert);
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
                          DataCell(TableTextCell(dessert.name ?? '')),
                          DataCell(TableTextCell(
                            dessert.description ?? '',
                            maxLines: 3,
                          )),
                          DataCell(TableTextCell(dessert.newLanguage)),
                          DataCell(DataGeneralColumnWidget(
                            child: Column(
                              children: dessert.lessonList != null
                                  ? List.generate(
                                      (dessert.lessonList!.length <= 2) ? dessert.lessonList!.length : 3,
                                      (int index) {
                                      final MiniModuleResponseEntity miniEntity = dessert.lessonList![index];
                                      return Builder(builder: (targetContext) {
                                        return UnitItemWidget(
                                          key: miniEntity.globalKey,
                                          index: index,
                                          title: (index == 2)
                                              ? "共${dessert.lessonList!.length}个课时"
                                              : miniEntity.name ?? '',
                                          isNeedIcon: index == 2,
                                          onTap: (int i) {
                                            if (index == 2) {
                                              final MiniModuleResponseEntity newEntity = dessert.lessonList![i];
                                              var record = CommonUtils.getSizeAndPosition(newEntity.globalKey);
                                              UnitItemWidgetManager.show(
                                                context: targetContext,
                                                list: dessert.lessonList!.map((element) => element.name).toList(),
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
                          DataCell(DataGeneralColumnWidget(
                            child: StatusTagDifficultyWidget(
                              difficulty: dessert.minDifficulty,
                              language: dessert.language,
                            ),
                          )),
                          DataCell(DataGeneralColumnWidget(
                            child: StatusTagDifficultyWidget(
                              difficulty: dessert.maxDifficulty,
                              language: dessert.language,
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
              authCodes: const [ManageAuthCode.courseUnitCreate],
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

  DataColumn2 _buildColumn(String title, {double width = 160, bool alignStart = true}) {
    return DataColumn2(
      label: DataGeneralColumnWidget(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18.wMin,
            color: const Color(0xffACB4C0),
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      headingRowAlignment: alignStart ? MainAxisAlignment.start : MainAxisAlignment.center,
      fixedWidth: width.ww,
    );
  }

  List<DataColumn> _buildColumns() {
    return [
      _buildColumn('操作', width: 210),
      _buildColumn('uid'),
      _buildColumn('名字'),
      _buildColumn('描述', width: 320),
      _buildColumn('语言'),
      _buildColumn('课时', width: 240),
      _buildColumn('最小难度水平'),
      _buildColumn('最大难度水平'),
      _buildColumn('供应商'),
      _buildColumn('创建者'),
      _buildColumn('更新时间'),
      _buildColumn('创建时间'),
    ];
  }
}
