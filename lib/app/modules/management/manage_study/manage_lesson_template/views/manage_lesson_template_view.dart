import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/enum/enum.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:popover/popover.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../generated/assets.dart';
import '../../../../../../utils/utils.dart';
import '../../../../../routes/routes.dart';
import '../../../common/commons.dart';
import '../../../utils/utils.dart';
import '../bindings/manage_lesson_template_binding.dart';
import '../controllers/manage_lesson_template_controller.dart';

class ManageLessonTemplateView extends GetView<ManageLessonTemplateController> {
  final String tagText;
  const ManageLessonTemplateView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_LESSON_TEMPLATE}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      () => ManageLessonTemplateView(tagText: tag),
      binding: ManageLessonTemplateBinding(tag: tag),
      arguments: arguments,
      routeName: Routes.MANAGE_LESSON_TEMPLATE,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ManageLessonTemplateController>(
      tag: tagText,
      id: 'manage_lesson_template',
      builder: (_) {
        return ManageScaffold(
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Column(
              children: [
                _buildTitleWidget(context),
                Gaps.getHeight(15.wh),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: 24.ww, right: 24.ww),
                    child: AsyncDataTableWidget<LessonTemplateResponseEntity>(
                      header: _buildHeader(),
                      dataRowHeight: 96.wh,
                      minWidth: 2350.ww,
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
                                      authCodes: const [ManageAuthCode.courseLessonTemplateEdit],
                                      child: EditStructureCell(
                                        title: '编辑课时模版',
                                        icon: Assets.managerEdit,
                                        onTap: () {
                                          controller.onEdit(context, data: dessert);
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
                                        authCodes: const [ManageAuthCode.courseLessonTemplateExerciseTemplateList],
                                        child: EditStructureCell(
                                        title: '管理题目列表',
                                        icon: Assets.managerEdit,
                                        onTap: () {
                                          controller.toManageLessonTemplate(dessert.uid);
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
                                controller.onEditLessonTemplateInline(dessert, newName: newValue);
                              },
                            ),
                          ),
                          DataCell(
                            EditTableTextCell(
                              initialValue: dessert.description ?? '',
                              maxLines: 3,
                              onValueChanged: (String newValue) {
                                controller.onEditLessonTemplateInline(dessert, newDescription: newValue);
                              },
                            ),
                          ),
                          DataCell(TableTextCell(dessert.newLanguage)),
                          DataCell(DataGeneralColumnWidget(
                            margin: EdgeInsets.only(left: 10.wMin),
                            child: Row(
                              children: [
                                StatusTagDifficultyWidget(
                                  difficulty: dessert.minDifficulty,
                                  language: dessert.language,
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 4.wMin),
                                  width: 8.wMin,
                                  height: 1.wMin,
                                  color: Colors.white,
                                ),
                                StatusTagDifficultyWidget(
                                  difficulty: dessert.maxDifficulty,
                                  language: dessert.language,
                                ),
                              ],
                            ),
                          )),
                          DataCell(DataGeneralColumnWidget(
                            child: StatusTagDirectionWidget(
                              direction: dessert.direction,
                            ),
                          )),
                          DataCell(DataGeneralColumnWidget(
                            child: TableTextCell(
                              LessonTypeEnum.fromRawValue(dessert.type)?.name ?? "",
                            ),
                          )),
                          DataCell(_buildAccessStatusCell(context, dessert)),
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

  Widget _buildTitleWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gaps.getHeight(20.wh),
        Row(
          children: [
            Gaps.getWidth(24.ww),
            ManageAuthBoxWidget(
              authCodes: const [ManageAuthCode.courseLessonTemplateCreate],
              child: Obx(() {
                return TopTabBarWidget(
                  index: 0,
                  title: '添加',
                  leftIcon: Assets.manageIconAdd,
                  isSelected: controller.filterIndex == 0,
                  onTap: (int index) {
                    controller.filterIndex = index;
                    controller.add(context);
                  },
                );
              }),
            ),
            Gaps.getWidth(12.ww),
            Builder(builder: (BuildContext ctx) {
              return TopTabBarWidget(
                index: 1,
                title: '排序',
                leftIcon: Assets.manageIconSort,
                isSelected: controller.filterIndex == 1,
                onTap: (int index) {
                  controller.filterIndex = index;
                  controller.toSort(ctx);
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

  Widget _buildAccessStatusCell(BuildContext context, LessonTemplateResponseEntity item) {
    return DataGeneralColumnWidget(
      child: Builder(
        builder: (targetContext) {
          return GestureDetector(
            onTap: () {
              if(!ManageAuthUtils.isAuth(ManageAuthCode.courseLessonTemplateEdit)) return;
              showPopover(
                context: targetContext,
                bodyBuilder: (ctx) => _accessPopWidget(ctx, item),
                direction: PopoverDirection.bottom,
                width: 150.wMin,
                height: 110.wMin,
                arrowHeight: 10.wMin,
                arrowWidth: 20.wMin,
                barrierColor: Colors.transparent,
                backgroundColor: const Color(0xFF18191A),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ManageButton(
                  text: item.access == 'NORMAL' ? '上架' : '下架',
                  width: 70,
                  height: 32.wMin,
                  color: item.access == 'NORMAL' ? const Color(0xFF63DE77) : const Color(0xFFFF2D46),
                  borderColor: Colors.transparent,
                  style: TextStyle(
                    fontSize: 14.wMin,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(width: 15.wMin),
                ManageAuthBoxWidget(
                  authCodes: const [ManageAuthCode.courseLessonTemplateEdit],
                  child: SvgPicture.asset(
                    Assets.manageIconArrowDown,
                    width: 20.ww,
                    height: 20.ww,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _accessPopWidget(BuildContext context, LessonTemplateResponseEntity item) {
    return Container(
      padding: EdgeInsets.all(15.wMin),
      decoration: BoxDecoration(
        color: const Color(0xF22B2F3C),
        borderRadius: BorderRadius.circular(12.wMin),
      ),
      child: Column(
        children: [
          ManageButton(
            text: '上架',
            width: 80,
            height: 32.wMin,
            color: const Color(0xFF63DE77),
            borderColor: Colors.transparent,
            style: TextStyle(
              fontSize: 14.wMin,
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
            onTap: () {
              Get.back();
              if (item.access != 'NORMAL') {
                controller.accessSong(context, item);
              } else {
                ToastUtils.showToast(text: '题目已是上架状态');
              }
            },
          ),
          SizedBox(height: 15.wMin),
          ManageButton(
            text: '下架',
            width: 80,
            height: 32.wMin,
            color: const Color(0xFFFF2D46),
            borderColor: Colors.transparent,
            style: TextStyle(
              fontSize: 14.wMin,
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
            onTap: () {
              Get.back();
              if (item.access == 'NORMAL') {
                controller.accessSong(context, item);
              } else {
                ToastUtils.showToast(text: '题目已是下架状态');
              }
            },
          ),
        ],
      ),
    );
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
      _buildColumn('名字', width: 200),
      _buildColumn('描述', width: 320, maxLines: 3),
      _buildColumn('语言'),
      _buildColumn('难度水平'),
      _buildColumn('考核方向'),
      _buildColumn('类型'),
      _buildColumn('状态'),
      _buildColumn('供应商'),
      _buildColumn('创建者'),
      _buildColumn('更新时间'),
      _buildColumn('创建时间'),
    ];
  }
}
