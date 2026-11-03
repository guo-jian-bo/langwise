import 'package:common_utils/common_utils.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/generated/assets.dart';
import 'package:langwise/utils/difficultie_utils.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:popover/popover.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../../../common/widgets/widgets.dart';
import '../../../../../routes/routes.dart';
import '../../../common/commons.dart';
import '../../../models/manage_exercise_quiz_model.dart';
import '../../../utils/utils.dart';
import '../bindings/manage_select_exercises_binding.dart';
import '../controllers/manage_select_exercises_controller.dart';

class ManageSelectExercisesView extends GetView<ManageSelectExercisesController> {
  final String tagText;
  const ManageSelectExercisesView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_SELECT_EXERCISES}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageSelectExercisesView(tagText: tag),
      binding: ManageSelectExercisesBinding(tag: tag),
      routeName: Routes.MANAGE_SELECT_EXERCISES,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      builder: (_) {
        return ManageScaffold(
          resizeToAvoidBottomInset: true,
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
                  child: AsyncDataTableWidget<ManageExerciseQuizModel>(
                    header: _buildHeader(context),
                    dataRowHeight: 100.wMin,
                    minWidth: 5000.ww,
                    showCheckboxColumn: true,
                    horizontalMargin: 40.wMin,
                    sourceCallback: (AsyncDataTableSource source) {
                      controller.onSetDataSourceAsync(source);
                    },
                    fetchData: (int currentPage, int startingAt, int count, String sortedBy, bool sortedAsc,
                        bool noData) {
                      return controller.onFetchPages(currentPage, startingAt, count, sortedBy, sortedAsc, noData);
                    },
                    columns: _buildColumns(),
                    dataCellBuilder: (dessert, int startIndex) {
                      return _buildDataCells(context, dessert, startIndex);
                    },
                    onRowSelectChanged: (selected, id, value) {
                      controller.onRowSelectChanged(selected, id, value);
                    },
                    dataDisableCallback: (p0) {
                      return false;
                    },
                  ),
                )),
              ],
            ),
          ),
          floatingActionButton: _buildBottomWidget(context),
        );
      },
    );
  }

  Widget _buildBottomWidget(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.wMin),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.wMin),
        padding: EdgeInsets.all(20.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          border: Border.all(width: 1.wMin, color: const Color(0xff353E5C)),
          color: const Color(0xff141828),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ButtonWidget(
              text: "取消",
              fontColor: const Color(0xffEBEFF5),
              color: Colors.transparent,
              border: Border.all(width: 2.wMin, color: const Color(0xff353E5C)),
              fontSize: 18.wMin,
              width: 100.wMin,
              height: 45.wMin,
              borderRadius: 4.wMin,
              sclae: 1.05,
              padding: EdgeInsets.symmetric(horizontal: 16.wMin),
              onTap: () {
                Get.back();
              },
            ),
            SizedBox(width: 12.wMin),
            Obx(() {
              return ButtonWidget(
                text: "确定选择(${controller.selectedExerciseIds.length})",
                fontColor: const Color(0xffEBEFF5),
                fontSize: 18.wMin,
                color: const Color(0xff2388FF),
                width: 200.wMin,
                height: 45.wMin,
                borderRadius: 4.wMin,
                sclae: 1.05,
                padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                onTap: () {
                  controller.onConfirmSelect();
                },
              );
            }),
          ],
        ),
      ),
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
            Builder(
              builder: (targetContext) {
                return TopTabBarWidget(
                  index: 2,
                  title: '筛选',
                  leftIcon: Assets.manageIconFilter,
                  rightIcon: Assets.manageIconArrowDown,
                  onTap: (int index) {
                    showPopover(
                      context: targetContext,
                      bodyBuilder: (context) => filterPopWidget(context),
                      direction: PopoverDirection.bottom,
                      width: 500.wMin,
                      height: 600.wMin,
                      arrowHeight: 10.wMin,
                      arrowWidth: 20.wMin,
                      barrierColor: Colors.transparent,
                      backgroundColor: const Color(0xFF18191A),
                    );
                  },
                );
              },
            ),
            const Spacer(),
            Gaps.getWidth(24.ww),
          ],
        ),
      ],
    );
  }

  Widget filterPopWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.wMin),
      decoration: BoxDecoration(
        color: const Color(0xF22B2F3C),
        borderRadius: BorderRadius.circular(12.wMin),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(20.wMin),
                      decoration: BoxDecoration(
                        color: const Color(0x4D41465A),
                        borderRadius: BorderRadius.circular(12.wMin),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '上架状态',
                            style: TextStyle(
                              fontSize: 20.wMin,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Gaps.getHeight(10.wMin),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  child: _buildChip(
                                '上架',
                                0,
                                controller.selectAccessIndex.value == 0,
                              )),
                              Gaps.getWidth(20.wMin),
                              Expanded(
                                  child: _buildChip(
                                '下架',
                                1,
                                controller.selectAccessIndex.value == 1,
                              )),
                            ],
                          ),
                          Gaps.getHeight(20.wMin),
                          Text(
                            '难度',
                            style: TextStyle(
                              fontSize: 20.wMin,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Gaps.getHeight(10.wMin),
                          Wrap(
                            children: controller.difficultyList.asMap().entries.map((entry) {
                              int index = entry.key;
                              var name = entry.value;
                              return _buildNewChip(
                                name,
                                index,
                                controller.selectDifficultyIndex.value == index,
                                1,
                              );
                            }).toList(),
                          ),
                          Gaps.getHeight(20.wMin),
                          Text(
                            '类型',
                            style: TextStyle(
                              fontSize: 20.wMin,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Gaps.getHeight(10.wMin),
                          Wrap(
                            children: controller.typeList.asMap().entries.map((entry) {
                              int index = entry.key;
                              var element = entry.value;
                              return _buildNewChip(
                                element.typeName!,
                                index,
                                controller.selectTypeIndex.value == index,
                                2,
                              );
                            }).toList(),
                          ),
                        ],
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
          Row(
            children: [
              Expanded(
                child: ManageButton(
                  text: "重置",
                  height: 50.wMin,
                  color: const Color(0xCC41465A),
                  borderColor: Colors.transparent,
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  onTap: () {
                    controller.selectAccessIndex.value = -1;
                    controller.selectDifficultyIndex.value = -1;
                    controller.selectTypeIndex.value = -1;
                  },
                ),
              ),
              SizedBox(width: 20.wMin),
              Expanded(
                child: ManageButton(
                  text: "确认",
                  height: 50.wMin,
                  color: const Color(0xFF38BDF8),
                  borderColor: Colors.transparent,
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  onTap: () {
                    controller.onRefresh();
                    Get.back();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewChip(String label, int index, bool isSelected, int type) {
    return GestureDetector(
      onTap: () {
        if (type == 1) {
          if (controller.selectDifficultyIndex.value == index) {
            controller.selectDifficultyIndex.value = -1;
          } else {
            controller.selectDifficultyIndex.value = index;
          }
        } else if (type == 2) {
          if (controller.selectTypeIndex.value == index) {
            controller.selectTypeIndex.value = -1;
          } else {
            controller.selectTypeIndex.value = index;
          }
        }
      },
      child: Container(
        margin: EdgeInsets.only(right: 15.wMin, bottom: 15.wMin),
        padding: EdgeInsets.symmetric(vertical: 6.wMin, horizontal: 15.wMin),
        decoration: BoxDecoration(
          color: isSelected ? const Color.fromRGBO(35, 136, 255, 0.1) : const Color(0xCC41465A),
          borderRadius: BorderRadius.circular(6.wMin),
          border: Border.all(
            width: 2.wMin,
            color: isSelected ? const Color.fromRGBO(35, 136, 255, 0.5) : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18.wMin,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, int index, bool isSelected) {
    return GestureDetector(
      onTap: () {
        if (controller.selectAccessIndex.value == index) {
          controller.selectAccessIndex.value = -1;
        } else {
          controller.selectAccessIndex.value = index;
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.wMin),
        decoration: BoxDecoration(
          color: isSelected ? const Color.fromRGBO(35, 136, 255, 0.1) : const Color(0xCC41465A),
          borderRadius: BorderRadius.circular(6.wMin),
          border: Border.all(
            width: 2.wMin,
            color: isSelected ? const Color.fromRGBO(35, 136, 255, 0.5) : Colors.transparent,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18.wMin,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
      GestureDetector(
        onTap: () {
          controller.chooseContent(context);
        },
        child: Container(
          width: 160.ww,
          height: 42.wh,
          padding: EdgeInsets.only(left: 12.ww, right: 12.ww),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.wMin),
            color: const Color(0xff23283D),
            border: Border.all(
              color: controller.content != null ? const Color(0xff2388FF) : const Color(0xff4B5268),
              width: 1.wMin,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF19213D).withValues(alpha: 0.10),
                offset: const Offset(0, 1),
                blurRadius: 3,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              buildImage(
                Assets.managerSearch,
                width: 14.ww,
                height: 14.ww,
              ),
              Gaps.getWidth(4.ww),
              Text(
                controller.content == null ? '知识点' : controller.content!['uid'].toString(),
                style: TextStyle(
                  fontSize: Dimens.dn_16.wMin,
                  height: 1.0,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xffEBEEF3),
                ),
              ),
              const Spacer(),
              Visibility(
                visible: controller.content != null,
                child: GestureDetector(
                  onTap: () {
                    controller.content = null;
                    controller.onRefresh();
                    controller.update();
                  },
                  child: buildImage(
                    Assets.managerClose,
                    width: 18.ww,
                    height: 18.ww,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ]);
  }

  List<DataColumn> _buildColumns() {
    return [
      _buildColumn('操作', fixedWidth: 200.ww),
      _buildColumn('UID', fixedWidth: 170.ww),
      _buildColumn('类型', fixedWidth: 250.ww),
      _buildColumn('课程归属', fixedWidth: 300.ww),
      _buildColumn('上架状态', fixedWidth: 250.ww),
      _buildColumn('难度', fixedWidth: 200.ww),
      _buildColumn('更新时间', fixedWidth: 200.ww),
      _buildColumn('创建时间', fixedWidth: 200.ww),
    ];
  }

  DataColumn2 _buildColumn(String title, {double? fixedWidth, MainAxisAlignment alignment = MainAxisAlignment.start}) {
    return DataColumn2(
      label: DataGeneralColumnWidget(
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18.wMin,
              color: const Color(0xffACB4C0),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
      headingRowAlignment: alignment,
      fixedWidth: fixedWidth,
    );
  }

  List<DataCell> _buildDataCells(BuildContext context, ManageExerciseQuizModel item, int startIndex) {
    return [
      DataCell(_buildOperateCell(context, item)),
      DataCell(_buildUIDCell(item)),
      DataCell(_buildTypeCell(item)),
      DataCell(_buildCourseAffiliationCell(context, item)),
      DataCell(_buildAccessStatusCell(context, item)),
      DataCell(_buildDifficultyCell(item)),
      DataCell(_buildModifyDateCell(item)),
      DataCell(_buildCreateDateCell(item)),
    ];
  }

  Widget _buildOperateCell(BuildContext context, ManageExerciseQuizModel item) {
    return DataGeneralColumnWidget(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ManageButton(
              text: "演示题型",
              width: 100.wMin,
              height: 40.wMin,
              color: const Color(0xFF353E5C),
              borderColor: Colors.transparent,
              style: TextStyle(
                fontSize: 16.wMin,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
              onTap: () {
                controller.showQuizJson(item);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUIDCell(ManageExerciseQuizModel item) {
    return DataGeneralColumnWidget(
      child: Center(
        child: Text(
          item.uid.toString(),
          style: TextStyle(fontSize: 18.wMin, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTypeCell(ManageExerciseQuizModel item) {
    return DataGeneralColumnWidget(
      child: Center(
        child: Text(
          item.type ?? '暂无',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15.wMin,
          ),
        ),
      ),
    );
  }

  Widget _buildCourseAffiliationCell(BuildContext context, ManageExerciseQuizModel item) {
    return DataGeneralColumnWidget(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '共计在${item.inLessonCount ?? 0}个课时',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17.wMin,
            ),
          ),
          SizedBox(width: 10.wMin),
          ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.exerciseExerciseCourseInfos],
            child: ManageButton(
              text: "查看",
              width: 55.wMin,
              height: 32.wMin,
              color: const Color(0xFF353E5C),
              borderColor: Colors.transparent,
              style: TextStyle(
                fontSize: 14.wMin,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
              onTap: () {
                controller.courseAffiliation(context, item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessStatusCell(BuildContext context, ManageExerciseQuizModel item) {
    return DataGeneralColumnWidget(
      child: Builder(
        builder: (targetContext) {
          return GestureDetector(
            onTap: () {
              if(!ManageAuthUtils.isAuth(ManageAuthCode.exerciseOperationCode)) return;
              showPopover(
                context: targetContext,
                bodyBuilder: (context) => accessPopWidget(context, item),
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
                  text: item.accessNormal ? '上架' : '下架',
                  width: 70,
                  height: 32.wMin,
                  color: item.accessNormal ? const Color(0xFF63DE77) : const Color(0xFFFF2D46),
                  borderColor: Colors.transparent,
                  style: TextStyle(
                    fontSize: 14.wMin,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                ManageAuthBoxWidget(
                  authCodes: const [ManageAuthCode.exerciseOperationCode],
                  margin: EdgeInsets.only(left: 15.wMin),
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

  Widget accessPopWidget(BuildContext context, ManageExerciseQuizModel item) {
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
              if (!item.accessNormal) {
                controller.accessQuiz(context, item);
              } else {
                ToastUtils.showManageToast(text: '题目已是上架状态');
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
              if (item.accessNormal) {
                controller.accessQuiz(context, item);
              } else {
                ToastUtils.showManageToast(text: '题目已是下架状态');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyCell(ManageExerciseQuizModel item) {
    if (item.difficulty == null) {
      return DataGeneralColumnWidget(
        child: Center(
          child: Text(
            '-',
            style: TextStyle(color: Colors.white, fontSize: 18.wMin),
          ),
        ),
      );
    }

    final configEntity = Get.find<ConfigController>().appConfig.value;
    DifficultieEntity? minDifficulty =
        DifficultieUtils.getLanguageDifficultieLevel(configEntity, 'en', item.difficulty?.min);
    DifficultieEntity? maxDifficulty =
        DifficultieUtils.getLanguageDifficultieLevel(configEntity, 'en', item.difficulty?.max);

    return item.difficulty != null
        ? DataGeneralColumnWidget(
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    minDifficulty?.name?.text ?? '',
                    style: TextStyle(fontSize: 18.wMin, color: Colors.white),
                  ),
                  Text(
                    '-',
                    style: TextStyle(fontSize: 18.wMin, color: Colors.white),
                  ),
                  Text(
                    maxDifficulty?.name?.text ?? '',
                    style: TextStyle(fontSize: 18.wMin, color: Colors.white),
                  ),
                ],
              ),
            ),
          )
        : Container();
  }

  Widget _buildCreateDateCell(ManageExerciseQuizModel item) {
    return DataGeneralColumnWidget(
      child: Center(
        child: Text(
          _formatDate(item.created),
          style: TextStyle(color: Colors.white, fontSize: 18.wMin),
        ),
      ),
    );
  }

  Widget _buildModifyDateCell(ManageExerciseQuizModel item) {
    return DataGeneralColumnWidget(
      child: Center(
        child: Text(
          _formatDate(item.updated),
          style: TextStyle(color: Colors.white, fontSize: 18.wMin),
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    return DateUtil.formatDateStr(dateStr, format: "yyyy-MM-dd");
  }
}
