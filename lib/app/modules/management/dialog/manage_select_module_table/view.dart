import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_button.dart';
import 'package:langwise/app/modules/management/common/manage_title_widget.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/generated/assets.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'controller.dart';

/// 管理-添加模块-关联-添加模块
class ManageSelectModuleTablePageManager {
  static Future<List<ModuleResponseEntity>?> show(
      {required BuildContext context,
      required List<ModuleResponseEntity> defaultDessert,
      final bool Function(ModuleResponseEntity)? dataDisableCallback}) async {
    return await showCupertinoDialog<List<ModuleResponseEntity>?>(
      context: context,
      builder: (context) {
        return ManageSelectModuleTablePage(
          defaultDessert: defaultDessert,
          dataDisableCallback: dataDisableCallback,
        );
      },
    );
  }
}

class ManageSelectModuleTablePage extends GetView<ManageSelectModuleTableController> {
  final List<ModuleResponseEntity> defaultDessert;

  final bool Function(ModuleResponseEntity)? dataDisableCallback;

  const ManageSelectModuleTablePage(
      {Key? key, required this.defaultDessert, this.dataDisableCallback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ManageSelectModuleTableController>(
      init: ManageSelectModuleTableController(defaultDessert),
      id: 'manage_select_module_table',
      builder: (_) {
        return Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: Colors.transparent,
            body: GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: Center(
                  child: Container(
                    width: 1080.ww,
                    height: 880.wh,
                    padding: EdgeInsets.symmetric(horizontal: 24.ww, vertical: 24.wh),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.wMin),
                      border: Border.all(
                        color: const Color(0xff444B5F),
                        width: 1.wMin, // 边框宽度
                      ),
                      color: const Color(0xff181B25),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ManageTitleWidget(
                          title: "模块",
                          onCloseTap: () {
                            Get.back();
                          },
                        ),
                        Gaps.getHeight(27.wh),
                        Expanded(
                            child: Container(
                          margin: EdgeInsets.only(left: 24.ww, right: 24.ww),
                          child: AsyncDataTableWidget<ModuleResponseEntity>(
                            header: _buildHeader(),
                            columns: _buildColumns(),
                            pageNumPosition: PageNumPosition.bottom,
                            dataRowHeight: 116.wh,
                            verticalInside: BorderSide.none,
                            // 表头复选框不可点击
                            headerCheckboxEnabled: false,
                            // 显示表头复选框
                            showHeadingCheckBox: true,
                            // 显示复选框
                            showCheckboxColumn: true,
                            dataDisableCallback: dataDisableCallback,
                            defaultDessert: defaultDessert,
                            sourceCallback: (AsyncDataTableSource source) {
                              controller.onSetDataSourceAsync(source);
                            },
                            fetchData: (int currentPage, int startingAt, int count, String sortedBy, bool sortedAsc,
                                bool noData) {
                              return controller.onFetchPages(
                                  currentPage, startingAt, count, sortedBy, sortedAsc, noData);
                            },
                            onRowSelectChanged: (bool selected, int id, ModuleResponseEntity value) {
                              controller.onRowSelectChanged(selected, id, value);
                            },
                            dataCellBuilder: (dessert, int startIndex) {
                              return [
                                DataCell(
                                  DataGeneralColumnWidget(
                                    child: Text(
                                      '${dessert.uid}',
                                      style: TextStyle(
                                        color: const Color(0xffEBEEF3),
                                        fontSize: 18.wMin,
                                        fontWeight: FontWeight.w400,
                                        height: 1.0,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(DataGeneralColumnWidget(
                                  child: Text(
                                    dessert.name ?? '',
                                    style: TextStyle(
                                      color: const Color(0xffEBEEF3),
                                      fontSize: 18.wMin,
                                      fontWeight: FontWeight.w400,
                                      height: 1.0,
                                    ),
                                  ),
                                )),
                                DataCell(DataGeneralColumnWidget(
                                  child: CachedImageWidget(dessert.coverUrl ?? '',
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
                                ))
                              ];
                            },
                          ),
                        )),
                        Gaps.getHeight(24.wh),
                        _buildBottomWidget(),
                      ],
                    ),
                  ),
                )));
      },
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
        hintText: '名称',
        onChanged: (String value) {
          controller.onSetName(value);
        },
        onSubmitted: (String value) {
          controller.onSetName(value, isSubmit: true);
        },
      ),
    ]);
  }

  List<DataColumn> _buildColumns() {
    return [
      DataColumn2(
        label: DataGeneralColumnWidget(
          child: Text(
            'uid',
            style: TextStyle(
              fontSize: 18.wMin,
              color: const Color(0xffACB4C0),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        headingRowAlignment: MainAxisAlignment.start,
        size: ColumnSize.S,
      ),
      DataColumn2(
        headingRowAlignment: MainAxisAlignment.start,
        label: DataGeneralColumnWidget(
            child: Text(
          '名字',
          style: TextStyle(
            fontSize: 18.wMin,
            color: const Color(0xffACB4C0),
            fontWeight: FontWeight.w400,
          ),
        )),
        size: ColumnSize.M,
      ),
      DataColumn2(
          headingRowAlignment: MainAxisAlignment.start,
          label: DataGeneralColumnWidget(
              child: Text(
            '封面',
            style: TextStyle(
                fontSize: 18.wMin,
                color: const Color(0xffACB4C0),
                fontWeight: FontWeight.w400,
                overflow: TextOverflow.ellipsis),
          )),
          fixedWidth: 160.ww),
    ];
  }

  Widget _buildBottomWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ManageButton(
          text: "取消",
          width: 80.ww,
          height: 40.wh,
          borderColor: const Color(0xff666F8D),
          style: TextStyle(
            fontSize: 14.wMin,
            color: const Color(0xffEBEEF3),
            fontWeight: FontWeight.w400,
          ),
          onTap: () {
            Get.back();
          },
        ),
        SizedBox(width: 11.ww),
        Obx(() {
          return ManageButton(
            text: "添加${controller.selectedRows.length}个模块",
            height: 40.wh,
            padding: EdgeInsets.only(left: 16.ww, right: 16.ww),
            color: controller.selectedRows.isEmpty ? const Color(0xff353E5C) : const Color(0xff2388FF),
            borderColor: Colors.transparent,
            style: TextStyle(
              fontSize: 14.wMin,
              color: controller.selectedRows.isNotEmpty ? const Color(0xffEBEEF3) : const Color(0xffACB4C0),
              fontWeight: FontWeight.w400,
            ),
            onTap: controller.selectedRows.isEmpty
                ? null
                : OptimizeUtils.noneThrottle(() {
                    controller.onAdd();
                  }, 100),
          );
        }),
      ],
    );
  }
}
