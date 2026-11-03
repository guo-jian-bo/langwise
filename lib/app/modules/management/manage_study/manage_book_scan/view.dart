/// 书籍扫描管理页面
///
/// 功能：
/// 1. 显示书籍扫描列表，包括操作、UID、状态、书名、封面等信息
/// 2. 支持书籍词汇扫描、内页管理、词汇列表查看和结构编辑操作
/// 3. 集成搜索、排序、筛选等表格通用功能
///
/// 优点：
/// 1. 采用TableTextCell组件替代重复的DataGeneralColumnWidget+Text组合，减少约70%代码量
/// 2. 使用_buildColumn辅助方法统一列样式和结构，提高代码复用性
/// 3. 将表格单元格实现抽离为独立函数，使代码结构更清晰、易维护
/// 4. 为长文本内容设置maxLines参数，优化显示效果
/// 5. 统一文本样式，确保表格外观一致
///
/// 此优化模式已应用于：ManageSentencePage, ManageUnitPage, ManageLessonTemplatePage等组件
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/utils/manage_auth_utils.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/values/values.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/generated/assets.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../../common/commons.dart';
import 'bindings.dart';
import 'controller.dart';

class ManageBookScanPage extends GetView<ManageBookScanController> {
  final String tagText;
  const ManageBookScanPage({Key? key, required this.tagText}) : super(key: key);

  @override
  String? get tag => tagText;

  /// 静态跳转方法
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_BOOK_SCAN}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageBookScanPage(tagText: tag),
      binding: ManageBookScanBinding(tag: tag),
      routeName: Routes.MANAGE_BOOK_SCAN,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ManageBookScanController>(
      init: controller,
      tag: tagText,
      id: 'manage_word_scan',
      builder: (_) {
        return ManageScaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: Colors.transparent,
            body: GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: PageBackWidget(
                  child: Column(
                    children: [
                      _buildTitleWidget(),
                      Gaps.getHeight(15.wh),
                      Expanded(
                          child: Container(
                        margin: EdgeInsets.only(left: 24.ww, right: 24.ww),
                        child: AsyncDataTableWidget<BookResponseEntity>(
                          header: _buildHeader(context),
                          dataRowHeight: 96.wh,
                          minWidth: 3415.ww,
                          rowsPerPage: defaultRawRowsPerPage,
                          sourceCallback: (AsyncDataTableSource source) {
                            controller.onSetDataSourceAsync(source);
                          },
                          fetchData: (int currentPage,
                              int startingAt,
                              int count,
                              String sortedBy,
                              bool sortedAsc,
                              bool noData) {
                            return controller.onFetchPages(currentPage,
                                startingAt, count, sortedBy, sortedAsc, noData);
                          },
                          columns: _buildColumns(),
                          dataCellBuilder: (dessert, int startIndex) {
                            return _buildDataCells(
                                context, dessert, startIndex);
                          },
                        ),
                      )),
                    ],
                  ),
                )));
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
              authCodes: const [ManageAuthCode.bookCreate],
              child: Obx(() {
                return TopTabBarWidget(
                    index: 0,
                    title: '添加',
                    leftIcon: Assets.manageIconAdd,
                    isSelected:
                        controller.state.filterIndex == 0,
                    onTap: (int index) {
                      controller.state.filterIndex = index;
                      controller.add();
                    });
              }),
            ),
            Gaps.getWidth(9.ww),
            Builder(
              builder: (context) {
                return TopTabBarWidget(
                    index: 1,
                    title: '排序',
                    leftIcon: Assets.manageIconSort,
                    isSelected:
                        controller.state.filterIndex == 1,
                    onTap: (int index) {
                      controller.state.filterIndex = index;
                      controller.toSort(context);
                    });
              },
            ),
            // Gaps.getWidth(12.ww),
            // Builder(builder: (targetContext) {
            //   return Obx(() {
            //     return TopTabBarWidget(
            //         index: 2,
            //         title: '筛选',
            //         isSelected: ManageScanController.to.state.filterIndex == 2,
            //         onTap: (int index) {
            //           ManageScanController.to.state.filterIndex = index;
            //           controller.showFilter(targetContext);
            //         });
            //   });
            // }),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(children: [
      SearchWidget(
        width: 160.ww,
        height: 42.wh,
        hintText: 'uid',
        controller: controller.uidController,
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
        hintText: '书名',
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
        hintText: '出版社',
        onChanged: (String value) {
          controller.onSetPublisher(value);
        },
        onSubmitted: (String value) {
          controller.onSetPublisher(value, isSubmit: true);
        },
      ),
      Gaps.getWidth(12.ww),
      SearchWidget(
        width: 160.ww,
        height: 42.wh,
        hintText: 'ISBN',
        onChanged: (String value) {
          controller.onSetIsbn(value);
        },
        onSubmitted: (String value) {
          controller.onSetIsbn(value, isSubmit: true);
        },
      ),

      // 状态筛选下拉框
      // GetBuilder<ManageBookScanController>(
      //   id: "status_filter",
      //   builder: (_) {
      //     // 使用ReviewStatus枚举值作为选项
      //     final statusOptions = [null, ...ScanWordType.values];
      //
      //     // 使用枚举的label属性作为显示文本
      //     String getStatusLabel(ScanWordType? status) {
      //       return status?.title ?? '全部状态';
      //     }
      //
      //     // 获取当前选中的索引
      //     final selectedIndex = statusOptions.indexOf(controller.state.statusFilter);
      //     return GestureDetector(
      //       onTap: () {
      //         ButtonDropdownMenu.show<ScanWordType?>(
      //           context: context,
      //           options: statusOptions,
      //           labelBuilder: (option) => getStatusLabel(option),
      //           selectedIndex: selectedIndex,
      //           onSelected: (index, option) => controller.setStatusFilter(option),
      //           anchorKey: controller.state.statusFilterKey,
      //           backgroundColor: color_1E2939,
      //           borderColor: color_4A5565,
      //           borderRadius: 8.ww,
      //           width: 132.ww,
      //         );
      //       },
      //       child: Container(
      //         key: controller.state.statusFilterKey,
      //         height: 40.wh,
      //         width: 102.ww,
      //         padding: EdgeInsets.symmetric(horizontal: 12.ww),
      //         decoration: BoxDecoration(
      //           color: color_364153,
      //           borderRadius: BorderRadius.circular(8.wMin),
      //         ),
      //         child: Row(
      //           children: [
      //             SvgPicture.asset(
      //               Assets.imageModerationStatus,
      //               width: 14.wMin,
      //               height: 14.wMin,
      //             ),
      //             Gaps.getWidth(6.ww),
      //             Text(
      //               getStatusLabel(controller.state.statusFilter),
      //               style: TextStyle(color: Colors.white, fontSize: 14.wMin, fontWeight: FontWeight.w400),
      //             ),
      //           ],
      //         ),
      //       ),
      //     );
      //   },
      // ),
    ]);
  }

  /// 创建列定义的辅助方法，统一列样式和结构
  DataColumn2 _buildColumn(String title,
      {double? fixedWidth,
      MainAxisAlignment alignment = MainAxisAlignment.start}) {
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
      headingRowAlignment: alignment,
      fixedWidth: fixedWidth,
    );
  }

  List<DataColumn> _buildColumns() {
    return [
      _buildColumn('操作', fixedWidth: 245.ww),
      _buildColumn('书籍ID', fixedWidth: 160.ww),
      _buildColumn('模块ID', fixedWidth: 160.ww),
      _buildColumn('状态', fixedWidth: 260.ww),
      _buildColumn('书名', fixedWidth: 320.ww),
      _buildColumn('封面', fixedWidth: 109.ww),
      _buildColumn('关联模块', fixedWidth: 160.ww),
      _buildColumn('学科', fixedWidth: 160.ww),
      _buildColumn('年级', fixedWidth: 160.ww),
      _buildColumn('学期', fixedWidth: 160.ww),
      _buildColumn('类型', fixedWidth: 160.ww),
      _buildColumn('版次', fixedWidth: 160.ww),
      _buildColumn('作者', fixedWidth: 320.ww),
      _buildColumn('出版社', fixedWidth: 240.ww),
      _buildColumn('出版时间', fixedWidth: 160.ww),
      _buildColumn('ISBN', fixedWidth: 240.ww),
    ];
  }

  /// 构建所有表格单元格
  List<DataCell> _buildDataCells(
      BuildContext context, BookResponseEntity item, int startIndex) {
    return [
      DataCell(_buildOperationCell(context, item)),
      DataCell(TableTextCell('${item.uid}')),
      DataCell(_buildModuleCell(item)),
      DataCell(_buildStatusCell(item)),
      DataCell(TableTextCell('${item.title}', maxLines: 2)),
      DataCell(_buildImageCell(item.coverUrl)),
      DataCell(TableTextCell(item.moduleName ?? '')),
      DataCell(TableTextCell(item.newSubject)),
      DataCell(TableTextCell(item.newGrade)),
      DataCell(TableTextCell(item.newSemester)),
      DataCell(TableTextCell(item.newType.title)),
      DataCell(TableTextCell(item.version?.toString() ?? '')),
      DataCell(TableTextCell(item.author ?? '', maxLines: 2)),
      DataCell(TableTextCell(item.publisher ?? '', maxLines: 2)),
      DataCell(TableTextCell(item.pubDate ?? '')),
      DataCell(TableTextCell(item.isbn ?? '')),
    ];
  }

  /// 操作列单元格
  Widget _buildOperationCell(BuildContext context, BookResponseEntity item) {
    return DataGeneralColumnWidget(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row(
          //   children: [
          //     EditStructureCell(
          //       title: '扫描词汇',
          //       icon: Assets.managerWordScan,
          //       onTap: () {
          //         if (!item.wordType.isParsing && !item.wordType.isConfirmed) {
          //           controller.toScanWord(context, item.uid, item.glossaryChapterId,
          //               editEnable: !item.wordType.isParsing && !item.wordType.isConfirmed);
          //         }
          //       },
          //     ),
          //     Gaps.getWidth(5.wMin),
          //     EditStructureCell(
          //       title: '内页管理',
          //       icon: Assets.managerWordSetting,
          //       onTap: () {
          //         // 1. 正在分析 和 已经确认 的不能编辑内页，禁止拍照和上传图片按钮。
          //         controller.toWordImageUpload(context,
          //             bookId: item.uid, editEnable: !item.wordType.isParsing && !item.wordType.isConfirmed);
          //       },
          //     ),
          //   ],
          // ),
          SizedBox(
            width: 100.wMin,
            child: ManageAuthBoxWidget(
              authCodes: const [ManageAuthCode.bookLoadChapter],
              child: EditStructureCell(
                title: '内页管理',
                icon: Assets.managerWordSetting,
                onTap: () {
                  // 1. 正在分析 和 已经确认 的不能编辑内页，禁止拍照和上传图片按钮。
                  controller.toWordImageUpload(context,
                      bookId: item.uid,
                      editEnable:
                          !item.wordType.isParsing && !item.wordType.isConfirmed);
                },
              ),
            ),
          ),
          Gaps.getHeight(5.wMin),
          Row(
            children: [
              ManageAuthBoxWidget(
                authCodes: const [ManageAuthCode.courseModuleKnowledgeList],
                child: EditStructureCell(
                  title: '词汇列表',
                  icon: Assets.managerWordList,
                  onTap: () {
                    controller.toWordList(
                        moduleId: item.moduleId,
                        bookId: item.uid,
                        bookName: item.title,
                        editEnable: item.wordType.isPending);
                  },
                ),
              ),
              Gaps.getWidth(5.wMin),
              ManageAuthBoxWidget(
                authCodes: const [ManageAuthCode.bookEdit],
                child: EditStructureCell(
                  title: '编辑信息',
                  icon: Assets.managerEdit,
                  onTap: () {
                    controller.onEdit(item);
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  /// 状态标签单元格
  /// 状态标签单元格
  /// 点击时显示状态选择菜单
  /// [item] - 书籍对象
  Widget _buildStatusCell(BookResponseEntity item) {
    return DataGeneralColumnWidget(
      child: Builder(builder: (context) {
        return TapScaleWidget(
            onTap: OptimizeUtils.noneThrottle(() {
              // 获取有效的状态类型列表（排除错误状态）
              final validTypes = ScanWordType.values
                  .where((element) => !element.isError)
                  .toList();

              // 显示状态选择菜单
              ScanWordTypeMenuManager.showMenu(
                context: context,
                verticalOffset: 0,
                horizontalOffset: 0,
                backgroundColor: const Color(0xff2F364C),
                types: validTypes,
                onSelected: (type, index) {
                  // 如果选择的状态与当前状态不同，才进行更新
                  if (type != item.wordType) {
                    controller.changeWordType(item, type);
                  }
                },
              );
            }, 200),
            child: IntrinsicWidth(
              child: ScanWordTagWidget(
                type: item.wordType,
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
              ),
            ));
      }),
    );
  }

  /// 图片单元格
  Widget _buildImageCell(String? url) {
    return DataGeneralColumnWidget(
      child: CachedImageWidget(url ?? '',
          width: 62.ww,
          height: 80.wh,
          fit: BoxFit.contain,
          errorWidget: Container(
            color: const Color(0xffD9D9D9),
            width: 62.ww,
            child: buildImage(
              width: 62.ww,
              height: 80.wh,
              Assets.managerImageNotFound,
              fit: BoxFit.contain,
            ),
            alignment: Alignment.center,
          )),
    );
  }

  /// 图片单元格
  Widget _buildModuleCell(BookResponseEntity item) {
    return DataGeneralColumnWidget(
      child: GestureDetector(
        onTap: () {
          controller.toModule(item);
        },
        child: Text(
          item.moduleId?.toString() ?? '',
          style: TextStyle(
            fontSize: 18.wMin,
            color: const Color(0xffACB4C0),
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
