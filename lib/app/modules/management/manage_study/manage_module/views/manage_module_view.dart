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
import '../bindings/manage_module_binding.dart';
import '../controllers/manage_module_controller.dart';

class ManageModuleView extends GetView<ManageModuleController> {
  final String tagText;
  const ManageModuleView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_MODULE}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      () => ManageModuleView(tagText: tag),
      binding: ManageModuleBinding(tag: tag),
      arguments: arguments,
      routeName: Routes.MANAGE_MODULE,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ManageModuleController>(
      tag: tagText,
      id: 'manage_module',
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
                    child: AsyncDataTableWidget<ModuleResponseEntity>(
                      header: _buildHeader(),
                      dataRowHeight: 116.wh,
                      minWidth: 1939.ww,
                      sourceCallback: (AsyncDataTableSource source) {
                        controller.onSetDataSourceAsync(source);
                      },
                      fetchData: (int currentPage, int startingAt, int count, String sortedBy, bool sortedAsc, bool noData) {
                        return controller.onFetchPages(currentPage, startingAt, count, sortedBy, sortedAsc, noData);
                      },
                      columns: _buildColumns(),
                      dataCellBuilder: (module, int startIndex) {
                        return _buildDataCells(module);
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
                ManageAuthCode.courseModuleCreate,
                ManageAuthCode.courseModuleCopy,
                ManageAuthCode.courseLevelRelationModule,
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

  List<DataCell> _buildDataCells(ModuleResponseEntity module) {
    return [
      _buildOperationCell(module),
      DataCell(TableTextCell('${module.uid}')),
      DataCell(
        EditTableTextCell(
          initialValue: module.name ?? '',
          maxLines: 2,
          onValueChanged: (String newValue) {
            controller.onEditModule(module, newName: newValue);
          },
        ),
      ),
      _buildImageCell(module),
      DataCell(
        EditTableTextCell(
          initialValue: module.description ?? '',
          maxLines: 3,
          onValueChanged: (String newValue) {
            controller.onEditModule(module, newDescription: newValue);
          },
        ),
      ),
      DataCell(TableTextCell(module.newLanguage)),
      _buildUnitListCell(module),
      DataCell(TableTextCell(module.vendor ?? '')),
      DataCell(TableTextCell(module.vendorName ?? '')),
      DataCell(TableTextCell(module.newUpdate)),
      DataCell(TableTextCell(module.newCreate)),
    ];
  }

  DataCell _buildOperationCell(ModuleResponseEntity module) {
    return DataCell(DataGeneralColumnWidget(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              const Spacer(),
              ManageAuthBoxWidget(
                authCodes: const [
                  ManageAuthCode.courseModuleEdit,
                ],
                child: EditStructureCell(
                  title: '编辑信息',
                  icon: Assets.managerEdit,
                  onTap: () => controller.onEdit(module),
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
                  ManageAuthCode.courseModuleUnitLessonList,
                ],
                child: EditStructureCell(
                  title: '查看课时',
                  icon: Assets.managerEye,
                  onTap: () => controller.toModuleDetils(module),
                ),
              ),
              const Spacer(),
            ],
          )
        ],
      ),
    ));
  }

  DataCell _buildImageCell(ModuleResponseEntity module) {
    return DataCell(DataGeneralColumnWidget(
      child: CachedImageWidget(module.coverUrl ?? '',
          width: 120.ww,
          height: 76.wh,
          fit: BoxFit.contain,
          errorWidget: Container(
            color: const Color(0xffD9D9D9),
            width: 120.ww,
            child: buildImage(
              width: 120.ww,
              height: 76.wh,
              Assets.managerImageNotFound,
              fit: BoxFit.contain,
            ),
          )),
    ));
  }

  DataCell _buildUnitListCell(ModuleResponseEntity module) {
    return DataCell(DataGeneralColumnWidget(
      child: Column(
        children: module.unitList != null
            ? List.generate((module.unitList!.length <= 2) ? module.unitList!.length : 3, (int index) {
                final MiniUnitResponseEntity miniEntity = module.unitList![index];
                return Builder(builder: (targetContext) {
                  return UnitItemWidget(
                    key: miniEntity.globalKey,
                    index: index,
                    title: (index == 2) ? "共${module.unitList!.length}个单元" : miniEntity.name ?? '',
                    isNeedIcon: index == 2,
                    onTap: (int i) {
                      if (index == 2) {
                        final record = CommonUtils.getSizeAndPosition(miniEntity.globalKey);
                        UnitItemWidgetManager.show(
                          context: targetContext,
                          list: module.unitList!.map((element) => element.name).toList(),
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
    ));
  }

  Widget _buildColumn(String title) {
    return DataGeneralColumnWidget(
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.wMin,
          color: const Color(0xffACB4C0),
          fontWeight: FontWeight.w400,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  List<DataColumn> _buildColumns() {
    return [
      DataColumn2(
        headingRowAlignment: MainAxisAlignment.start,
        label: _buildColumn('操作'),
        fixedWidth: 140.ww,
      ),
      DataColumn2(
        headingRowAlignment: MainAxisAlignment.start,
        label: _buildColumn('uid'),
        fixedWidth: 160.ww,
      ),
      DataColumn2(
        headingRowAlignment: MainAxisAlignment.start,
        label: _buildColumn('名字'),
        fixedWidth: 240.ww,
      ),
      DataColumn2(
        headingRowAlignment: MainAxisAlignment.start,
        label: _buildColumn('封面'),
        fixedWidth: 109.ww,
      ),
      DataColumn2(
        headingRowAlignment: MainAxisAlignment.start,
        label: _buildColumn('描述'),
        fixedWidth: 240.ww,
      ),
      DataColumn2(
        headingRowAlignment: MainAxisAlignment.start,
        label: _buildColumn('语言'),
        fixedWidth: 160.ww,
      ),
      DataColumn2(
        headingRowAlignment: MainAxisAlignment.start,
        label: _buildColumn('单元'),
        fixedWidth: 240.ww,
      ),
      DataColumn2(
        headingRowAlignment: MainAxisAlignment.start,
        label: _buildColumn('供应商'),
        fixedWidth: 160.ww,
      ),
      DataColumn2(
        headingRowAlignment: MainAxisAlignment.start,
        label: _buildColumn('创建者'),
        fixedWidth: 160.ww,
      ),
      DataColumn2(
        headingRowAlignment: MainAxisAlignment.start,
        label: _buildColumn('更新时间'),
        fixedWidth: 160.ww,
      ),
      DataColumn2(
        headingRowAlignment: MainAxisAlignment.start,
        label: _buildColumn('创建时间'),
        fixedWidth: 160.ww,
      ),
    ];
  }
}
