import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../generated/assets.dart';
import '../../../../../routes/routes.dart';
import '../../../common/commons.dart';
import '../../../utils/utils.dart';
import '../bindings/manage_lesson_binding.dart';
import '../controllers/manage_lesson_controller.dart';

class ManageLessonView extends GetView<ManageLessonController> {
  final String tagText;
  const ManageLessonView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_LESSON}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      () => ManageLessonView(tagText: tag),
      binding: ManageLessonBinding(tag: tag),
      arguments: arguments,
      routeName: Routes.MANAGE_LESSON,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ManageLessonController>(
      tag: tagText,
      id: 'manage_lesson',
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
                    child: AsyncDataTableWidget<LessonResponseEntity>(
                      header: _buildHeader(),
                      dataRowHeight: 96.wh,
                      minWidth: 1730.ww,
                      sourceCallback: (AsyncDataTableSource source) {
                        controller.onSetDataSourceAsync(source);
                      },
                      fetchData: (int currentPage, int startingAt, int count, String sortedBy, bool sortedAsc, bool noData) {
                        return controller.onFetchPages(currentPage, startingAt, count, sortedBy, sortedAsc, noData);
                      },
                      columns: _buildColumns(),
                      dataCellBuilder: (dessert, int startIndex) {
                        return [
                          DataCell(
                              DataGeneralColumnWidget(
                                child: Row(
                                  children: [
                                    ManageAuthBoxWidget(
                                      authCodes: const [
                                        ManageAuthCode.courseLessonEdit,
                                      ],
                                      child: EditStructureCell(
                                        title: '编辑信息',
                                        icon: Assets.managerEdit,
                                        onTap: () {
                                          controller.toEditLesson(dessert);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              showEditIcon: false),
                          DataCell(TableTextCell('${dessert.uid}')),
                          DataCell(TableTextCell(dessert.name ?? '')),
                          DataCell(DataGeneralColumnWidget(
                            child: CachedImageWidget(dessert.coverUrl ?? '',
                                width: 62.ww,
                                height: 80.wh,
                                fit: BoxFit.contain,
                                errorWidget: Container(
                                  color: const Color(0xffD9D9D9),
                                  width: 62.ww,
                                  alignment: Alignment.center,
                                  child: buildImage(
                                    width: 62.ww,
                                    height: 80.wh,
                                    Assets.managerImageNotFound,
                                    fit: BoxFit.contain,
                                  ),
                                )),
                          )),
                          DataCell(
                            EditTableTextCell(
                              initialValue: dessert.description ?? '',
                              onValueChanged: (String newValue) {
                                controller.onEditLesson(dessert, newValue);
                              },
                            ),
                          ),
                          DataCell(TableTextCell(dessert.newLanguage)),
                          DataCell(TableTextCell(dessert.vendor ?? '')),
                          DataCell(TableTextCell(dessert.vendorName ?? '')),
                          DataCell(TableTextCell(dessert.newUpdate)),
                          DataCell(TableTextCell(dessert.newCreate))
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

  DataColumn2 _buildColumn(String title, {double width = 160, bool alignStart = true, int? maxLines}) {
    return DataColumn2(
      label: DataGeneralColumnWidget(
        child: Text(
          title,
          maxLines: maxLines,
          style: TextStyle(
            fontSize: 18.wMin,
            color: const Color(0xffACB4C0),
            fontWeight: FontWeight.w400,
            overflow: maxLines != null ? TextOverflow.ellipsis : null,
          ),
        ),
      ),
      headingRowAlignment: alignStart ? MainAxisAlignment.start : MainAxisAlignment.center,
      fixedWidth: width.ww,
    );
  }

  List<DataColumn> _buildColumns() {
    return [
      _buildColumn('操作', width: 140),
      _buildColumn('uid'),
      _buildColumn('名字', width: 200),
      _buildColumn('封面', width: 109),
      _buildColumn('描述', width: 320, maxLines: 3),
      _buildColumn('语言'),
      _buildColumn('供应商'),
      _buildColumn('创建者'),
      _buildColumn('更新时间'),
      _buildColumn('创建时间'),
    ];
  }
}
