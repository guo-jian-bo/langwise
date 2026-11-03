import 'dart:async';
import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:api/entities/entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_title_widget.dart';
import 'package:langwise/app/modules/management/common/manage_button.dart';
import 'package:langwise/app/modules/management/common/manage_select_option_widget.dart';
import 'package:langwise/app/modules/management/common/manage_title_input_widget.dart';
import 'package:langwise/common/entities/chapter.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

/// 章节管理弹框
/// 用于管理教材扫描的章节信息
class ChapterManagement extends StatefulWidget {
  /// 教材ID
  final int? textbookId;

  /// 教材名称
  final String? textbookName;
  final List<BookChapter>? initialChapters;
  final Function(List<BookChapter>)? onSave;
  final Function(int bookId, int chapterId)? onOpenPageManagement;

  const ChapterManagement(
      {Key? key,
      this.textbookId,
      this.textbookName,
      this.initialChapters,
      this.onSave,
      this.onOpenPageManagement})
      : super(key: key);

  /// 显示章节管理弹框
  /// @param context 上下文
  /// @param initialChapters 初始章节列表
  /// @param textbookName 教材名称
  /// @param onSave 保存回调
  /// @return 返回章节列表
  static Future<List<BookChapter>?> show(
      {required BuildContext context,
      List<BookChapter>? initialChapters,
      int? textbookId,
      Function(List<BookChapter>)? onSave,
      Function(int bookId, int chapterId)? onOpenPageManagement}) {
    return Get.dialog<List<BookChapter>?>(
      ChapterManagement(
        initialChapters: initialChapters,
        textbookId: textbookId,
        onSave: onSave,
        onOpenPageManagement: onOpenPageManagement,
      ),
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.5),
    ).then((value) {
      return value;
    });
  }

  @override
  State<ChapterManagement> createState() => _ChapterManagementState();
}

class _ChapterManagementState extends State<ChapterManagement>
    with SafeSetStateMixin {
  late AutoScrollController _scrollController;

  /// 章节类型列表，从服务器加载
  List<ChapterType> _chapterTypes = [];

  /// 章节数据
  List<BookChapter> chapters = [];

  Book? _book;

  // 是否正在批量编辑中
  bool _isBatchEditing = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scrollController = AutoScrollController(
            viewportBoundaryGetter: () =>
                Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
            axis: Axis.vertical);
      }
    });

    // 使用初始章节列表或创建默认章节
    chapters =
        widget.initialChapters != null && widget.initialChapters!.isNotEmpty
            ? List.from(widget.initialChapters!)
            : [];

    _loadPages();
    _loadTypes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff040712).withValues(alpha: 0.8),
      body: Center(
        child: Container(
          width: 1080.ww,
          height: 980.wh,
          padding: EdgeInsets.symmetric(horizontal: 24.ww, vertical: 24.wh),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.wMin),
            border: Border.all(
              color: const Color(0xff444B5F),
              width: 1.wMin, // 边框宽度
            ),
            color: const Color(0xff181B25),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ManageTitleWidget(
                title: "教材章节",
                onCloseTap: () {
                  Get.back();
                },
              ),
              Gaps.getHeight(35.wh),
              // 章节列表
              Expanded(
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.ww, vertical: 16.wh),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.wMin),
                    color: const Color(0xff22293C),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _book?.bookName ?? '',
                        style: TextStyle(
                            fontSize: 22.wMin,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xffEBEEF3)),
                      ),
                      Gaps.getHeight(4.wh),
                      Row(
                        children: [
                          Text(
                            "书籍ID: ${_book?.bookId ?? ''}",
                            style: TextStyle(
                                fontSize: 18.wMin,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xffEBEEF3)),
                          ),
                          SizedBox(width: 16.ww),
                          Text(
                            "模块ID: ${_book?.moduleId ?? ''}",
                            style: TextStyle(
                                fontSize: 18.wMin,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xffEBEEF3)),
                          ),
                        ],
                      ),
                      Gaps.getHeight(56.wh),
                      if (chapters.isNotEmpty)
                        Expanded(
                            child: AnimatedReorderableListView(
                                key: const PageStorageKey("ChapterManagement"),
                                controller: _scrollController,
                                // 去掉默认的右边编辑按钮
                                buildDefaultDragHandles: false,
                                enableSwap: false,
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                enterTransition: [SlideInDown()],
                                exitTransition: [SlideInUp()],
                                insertDuration:
                                    const Duration(milliseconds: 200),
                                removeDuration:
                                    const Duration(milliseconds: 200),
                                dragStartDelay:
                                    const Duration(milliseconds: 200),
                                // 预加载足够多的单元，避免拖拽过程中浮层消失
                                cacheExtent: 50000,
                                proxyDecorator: proxyDecorator,
                                onReorder: _onReorder,
                                items: chapters,
                                itemBuilder: (BuildContext context, int index) {
                                  final BookChapter chapter = chapters[index];
                                  return ChapterItem(
                                    key: ValueKey(chapter.uid),
                                    chapter: chapter,
                                    index: index,
                                    controller: _scrollController,
                                    isDone: _book?.isDone,
                                    onUpdate: _updateChapter,
                                    onDelete: _deleteChapter,
                                    onAdd: _saveChapter,
                                    relatedUnit: _relatedUnit,
                                    onOpenPageManagement: _openPageManagement,
                                    chapterTypes: _chapterTypes,
                                  );
                                },
                                isSameItem: (a, b) => a.uid == b.uid)),
                      if (chapters.isEmpty)
                        Expanded(
                            child: Center(
                          child: Text(
                            "暂无数据",
                            style: TextStyle(
                                color: const Color(
                                  0xffEBEEF3,
                                ),
                                fontSize: 13.wMin,
                                fontWeight: FontWeight.w400),
                          ),
                        )),
                      buildAddButton(context, "添加章节", () {
                        _addChapter();
                      }),
                    ],
                  ),
                ),
              ),
              Gaps.getHeight(32.wh),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ManageButton(
                    text: "分割PDF",
                    width: 120.ww,
                    height: 40.wh,
                    color: const Color(0xff353E5C),
                    borderColor: Colors.transparent,
                    style: TextStyle(
                      fontSize: 14.wMin,
                      color: const Color(0xffEBEEF3),
                      fontWeight: FontWeight.w400,
                    ),
                    onTap: OptimizeUtils.noneThrottle(() {
                      _splitChapter();
                    }, 100),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      ManageButton(
                        text: "提取正文",
                        width: 120.ww,
                        height: 40.wh,
                        color: const Color(0xff353E5C),
                        borderColor: Colors.transparent,
                        style: TextStyle(
                          fontSize: 14.wMin,
                          color: const Color(0xffEBEEF3),
                          fontWeight: FontWeight.w400,
                        ),
                        onTap: OptimizeUtils.noneThrottle(() {
                          _extractText();
                        }, 100),
                      ),
                      Gaps.getWidth(20.ww),
                      ManageButton(
                        text: "提取目录",
                        width: 120.ww,
                        height: 40.wh,
                        color: const Color(0xff353E5C),
                        borderColor: Colors.transparent,
                        style: TextStyle(
                          fontSize: 14.wMin,
                          color: const Color(0xffEBEEF3),
                          fontWeight: FontWeight.w400,
                        ),
                        onTap: OptimizeUtils.noneThrottle(() {
                          _extractTableOfContents();
                        }, 100),
                      ),
                      Gaps.getWidth(20.ww),
                      ManageButton(
                        text: "提取词汇表",
                        width: 120.ww,
                        height: 40.wh,
                        color: const Color(0xff353E5C),
                        borderColor: Colors.transparent,
                        style: TextStyle(
                          fontSize: 14.wMin,
                          color: const Color(0xffEBEEF3),
                          fontWeight: FontWeight.w400,
                        ),
                        onTap: OptimizeUtils.noneThrottle(() {
                          _extractVocabularyTable();
                        }, 100),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Visibility(
                    visible: _book?.isDone != true,
                    child: ManageButton(
                      text: "保存章节",
                      width: 120.ww,
                      height: 40.wh,
                      color: const Color(0xff2388FF),
                      borderColor: Colors.transparent,
                      style: TextStyle(
                        fontSize: 14.wMin,
                        color: const Color(0xffEBEEF3),
                        fontWeight: FontWeight.w400,
                      ),
                      onTap: OptimizeUtils.noneThrottle(() {
                        _batchEditChapter();
                      }, 300),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        return Material(
          elevation: 0,
          color: const Color(0xff23283D),
          borderRadius: BorderRadius.circular(6.wMin),
          child: child,
        );
      },
      child: child,
    );
  }

  // 添加知识点
  Widget buildAddButton(
      BuildContext context, String title, VoidCallback onTap) {
    return TapScaleWidget(
      onTap: OptimizeUtils.noneThrottle(() {
        onTap.call();
      }, 300),
      sclae: 1.03,
      child: DottedBorder(
        radius: Radius.circular(8.wMin),
        borderType: BorderType.RRect,
        padding: EdgeInsets.zero,
        color: const Color(0xff444B5F),
        dashPattern: const [1, 2],
        strokeWidth: 1.wMin,
        child: Container(
          alignment: Alignment.center,
          height: 40.wh,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                color: const Color(
                  0xffEAECFF,
                ),
                size: 18.wMax,
              ),
              Gaps.getWidth(3.ww),
              Text(
                title,
                style: TextStyle(
                    color: const Color(
                      0xffEAECFF,
                    ),
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _loadPages() async {
    try {
      ToastUtils.showLoading();
      var response = await BookUtil.chapter(
          bookId: widget.textbookId!,
          config: RequestConfig(requireToken: true));
      safeSetState(() {
        _book = response.data;
        chapters = _book?.chapterList ?? [];
      });
    } catch (e) {
      print(e.toString());
    } finally {
      ToastUtils.hideLoading();
    }
  }

  void _loadTypes() async {
    try {
      var response =
          await BookUtil.chapterType(config: RequestConfig(requireToken: true));
      safeSetState(() {
        _chapterTypes = response.data?.list ?? [];
      });
    } catch (e) {
      print(e.toString());
    }
  }

  // 批量编辑章节
  void _batchEditChapter() async {
    if (_isBatchEditing) {
      return;
    }

    // 提交前校验数据，确保chapterTypeId和chapterName必须有值
    final invalidChapters = chapters
        .where(
            (chapter) => chapter.chapterTypeId == null || chapter.isNameEmpty)
        .toList();

    if (invalidChapters.isNotEmpty) {
      // 如果有无效章节，显示提示并返回
      ToastUtils.showToast(
        text: "请完善所有章节的类型和名称信息",
      );
      return;
    }

    _isBatchEditing = true;

    try {
      ToastUtils.showLoading();
      var response = await BookUtil.batchEditChapter(
          config: RequestConfig(data: {
        "bookId": _book?.bookId,
        "bookName": _book?.bookName,
        "chapterList": chapters.map((element) => element.toJson()).toList(),
      }, requireToken: true));
      if (response.data != null) {
        // 重新拉取数据
        _loadPages();
        ToastUtils.showToast(text: "保存成功", type: ToastType.success);
      }
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message ?? "保存失败");
    } catch (e) {
      print(e.toString());
      ToastUtils.showToast(text: "保存失败");
    } finally {
      ToastUtils.hideLoading();
      _isBatchEditing = false;
    }
  }

  /// 添加新章节
  void _addChapter() {
    if (_book?.isDone == true) {
      final bool hasIncompleteChapter =
          chapters.any((chapter) => chapter.uid < 0);
      if (hasIncompleteChapter) {
        // 如果有未完成的章节，提示用户
        Get.snackbar(
          '提示',
          '一次只能添加一个章节，请先完成新建的章节并保存后，再继续添加新的章节。',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colours.blue_1AA6F3,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }
    } else {
      // 检查是否有未完成的新章节
      final bool hasIncompleteChapter = chapters.any(
          (chapter) => chapter.isNameEmpty || chapter.chapterTypeId == null);

      if (hasIncompleteChapter) {
        // 如果有未完成的章节，提示用户
        Get.snackbar(
          '提示',
          '请先完成新章节',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colours.blue_1AA6F3,
          colorText: Colors.white,
          duration: const Duration(seconds: 1),
        );
        return;
      }
    }

    // 计算当前最大页码
    // 注意：如果章节列表为空，则使用 0 作为默认值
    // 否则使用 reduce 函数找出最大值
    final maxPdfPage = chapters.isEmpty
        ? 0
        : chapters
            .map((c) => c.pageRange?.pdf?.end ?? 0)
            .reduce((a, b) => a > b ? a : b);
    final maxActualPage = chapters.isEmpty
        ? 0
        : chapters
            .map((c) => c.pageRange?.book?.end ?? 0)
            .reduce((a, b) => a > b ? a : b);

    // 计算新章节的uid，从-1开始递减
    int newUid = -1;
    // 找出当前最小uid值
    if (chapters.isNotEmpty) {
      // 筛选出所有负数uid
      final negativeUids =
          chapters.map((c) => c.uid).where((uid) => uid < 0).toList();
      if (negativeUids.isNotEmpty) {
        // 找出最小的uid值
        final minUid = negativeUids.reduce((min, uid) => uid < min ? uid : min);
        // 新uid应该比当前最小uid再小1
        newUid = minUid - 1;
        print("---计算新章节uid: 当前最小uid=$minUid, 新uid=$newUid---");
      }
    }

    // 创建新章节，使用计算出的最大页码初始化页码范围
    final newChapter = BookChapter(
        uid: newUid, // 使用递减的uid
        chapterTypeId: 4, // 正文
        pageRange: PageRange(
          pdf: PageMinMax(
              start: maxPdfPage > 0 ? maxPdfPage + 1 : 0,
              end: maxPdfPage > 0 ? maxPdfPage + 5 : 5),
          book: PageMinMax(
              start: maxActualPage > 0 ? maxActualPage + 1 : 0,
              end: maxActualPage > 0 ? maxActualPage + 5 : 5),
        ));
    safeSetState(() {
      chapters.add(newChapter);
    });
    _scrollToCounter();
  }

  /// 验证当前章节与上一章节的页码范围是否有重叠
  ///
  /// [chapters] - 章节列表
  /// [currentIndex] - 当前章节的索引
  /// [field] - 页码字段类型，'pdf'或'actual'
  /// [currentMin] - 当前章节的最小页码
  /// 返回是否与上一章节存在重叠
  bool hasOverlapWithPrevChapter(List<BookChapter> chapters, int currentIndex,
      String field, int currentMin) {
    // 如果当前输入的页码最小值为 0，不进行重叠检测
    if (currentMin == 0) return false;

    // 如果是第一个章节，没有上一章节，不存在重叠
    if (currentIndex <= 0) return false;

    // 检查上一个章节
    final prevChapter = chapters[currentIndex - 1];
    final prevMax = field == 'pdf'
        ? (prevChapter.pageRange?.pdf?.end ?? 0)
        : (prevChapter.pageRange?.book?.end ?? 0);

    print("检查上一个章节prevMax: $prevMax, currentMin: $currentMin");
    // 如果上一章节的最大值不为0，且当前章节的最小值小于等于上一章节的最大值
    if (prevMax != 0 && currentMin <= prevMax) {
      return true; // 存在重叠
    }

    return false; // 不存在重叠
  }

  /// 验证当前章节与下一章节的页码范围是否有重叠
  ///
  /// [chapters] - 章节列表
  /// [currentIndex] - 当前章节的索引
  /// [field] - 页码字段类型，'pdf'或'actual'
  /// [currentMax] - 当前章节的最大页码
  /// 返回是否与下一章节存在重叠
  bool hasOverlapWithNextChapter(List<BookChapter> chapters, int currentIndex,
      String field, int currentMax) {
    // 如果当前输入的页码最大值为 0，不进行重叠检测
    if (currentMax == 0) return false;

    // 如果是最后一个章节，没有下一章节，不存在重叠
    if (currentIndex >= chapters.length - 1) return false;

    // 检查下一个章节
    final nextChapter = chapters[currentIndex + 1];
    final nextMin = field == 'pdf'
        ? (nextChapter.pageRange?.pdf?.start ?? 0)
        : (nextChapter.pageRange?.book?.start ?? 0);

    // 如果下一章节的最小值不为0，且当前章节的最大值大于等于下一章节的最小值
    print("检查下一个章节nextMin: $nextMin, currentMax: $currentMax");
    if (nextMin != 0 && currentMax >= nextMin) {
      return true; // 存在重叠
    }

    return false; // 不存在重叠
  }

  /// 更新章节的页码范围
  ///
  /// [field] - 要更新的字段名（pdfPageMin、pdfPageMax、actualPageMin、actualPageMax）
  /// [chapter] - 要更新的章节对象
  /// [numValue] - 新的页码值
  void _updateChapterPageRange(
      String field, BookChapter chapter, int numValue) {
    if (field == 'pdfPageMin') {
      // 直接更新现有对象的属性
      if (chapter.pageRange?.pdf == null) {
        // 如果pdf为空，需要先创建
        chapter.pageRange?.pdf = PageMinMax(start: numValue, end: 0);
      } else {
        // 直接更新现有pdf对象的start属性
        chapter.pageRange?.pdf?.start = numValue;
      }
      print(
          "---😆😆pdfPageMin更新成功: ${chapter.pageRange?.pdf?.toJson()}😆😆---");
    } else if (field == 'pdfPageMax') {
      // 直接更新现有对象的属性
      if (chapter.pageRange?.pdf == null) {
        // 如果pdf为空，需要先创建
        chapter.pageRange?.pdf = PageMinMax(start: 0, end: numValue);
      } else {
        // 直接更新现有pdf对象的end属性
        chapter.pageRange?.pdf?.end = numValue;
      }
      print(
          "---😆😆pdfPageMax更新成功: ${chapter.pageRange?.pdf?.toJson()}😆😆---");
    } else if (field == 'actualPageMin') {
      // 直接更新现有对象的属性
      if (chapter.pageRange?.book == null) {
        // 如果book为空，需要先创建
        chapter.pageRange?.book = PageMinMax(start: numValue, end: 0);
      } else {
        // 直接更新现有book对象的start属性
        chapter.pageRange?.book?.start = numValue;
      }
      print(
          "---😆😆actualPageMin更新成功: ${chapter.pageRange?.book?.toJson()}😆😆---");
    } else if (field == 'actualPageMax') {
      // 直接更新现有对象的属性
      if (chapter.pageRange?.book == null) {
        // 如果book为空，需要先创建
        chapter.pageRange?.book = PageMinMax(start: 0, end: numValue);
      } else {
        // 直接更新现有book对象的end属性
        chapter.pageRange?.book?.end = numValue;
      }
      print(
          "---😆😆actualPageMax更新成功: ${chapter.pageRange?.book?.toJson()}😆😆---");
    }
  }

  /// 更新章节信息
  void _updateChapter(
      int index, BookChapter chapter, String field, dynamic value) {
    print("---😆😆更新章节信息_updateChapter, field: $field, value: $value😆😆---");
    // 使用传入的索引，不需要再查找
    final chapterIndex = index;

    if (field == 'pdfPageMin' ||
        field == 'pdfPageMax' ||
        field == 'actualPageMin' ||
        field == 'actualPageMax') {
      // 将输入转换为数字
      final numValue = int.tryParse(value.toString());
      if (numValue == null) return; // 非数字输入不处理

      // 确保 min <= max，处理可能为空的情况
      final pdfPageMin = chapter.pageRange?.pdf?.start ?? 0;
      final pdfPageMax = chapter.pageRange?.pdf?.end ?? 0;

      final actualPageMin = chapter.pageRange?.book?.start ?? 0;
      final actualPageMax = chapter.pageRange?.book?.end ?? 0;

      // 当PDF最大页码不为0时，检查PDF最小页码是否大于最大页码
      if (pdfPageMax != 0) {
        if ((field == 'pdfPageMin' && numValue > pdfPageMax)) {
          // pdf最小值大于pdfPageMax
          ToastUtils.showToast(
            text: "最小页码不能大于最大页码",
          );
          return;
        }

        if ((field == 'pdfPageMax' && numValue < pdfPageMin)) {
          // pdf最小值大于pdfPageMax
          ToastUtils.showToast(
            text: "最小页码不能大于最大页码",
          );
          return;
        }
      }

      // 当实际最大页码不为0时，检查实际最小页码是否大于最大页码
      if (actualPageMax != 0) {
        if ((field == 'actualPageMin' && numValue > actualPageMax)) {
          // 实际最小值大于actualPageMax
          ToastUtils.showToast(
            text: "最小页码不能大于最大页码",
          );
          return;
        }

        // print("---😆😆实际页码field:$field, numValue:$numValue, actualPageMin:$actualPageMin😆😆---");
        if ((field == 'actualPageMax' && numValue < actualPageMin)) {
          // 实际最小值大于actualPageMax
          ToastUtils.showToast(
            text: "最小页码不能大于最大页码",
          );
          return;
        }
      }

      // 检查是否与其他章节有重叠
      int newMin = 0, newMax = 0;
      String checkField = 'pdf';
      bool hasOverlapWithPrev = false;
      bool hasOverlapWithNext = false;

      if (field == 'pdfPageMin' || field == 'pdfPageMax') {
        newMin = field == 'pdfPageMin'
            ? numValue
            : (chapter.pageRange?.pdf?.start ?? 0);
        newMax = field == 'pdfPageMax'
            ? numValue
            : (chapter.pageRange?.pdf?.end ?? 0);
        checkField = 'pdf';
      } else {
        newMin = field == 'actualPageMin'
            ? numValue
            : (chapter.pageRange?.book?.start ?? 0);
        newMax = field == 'actualPageMax'
            ? numValue
            : (chapter.pageRange?.book?.end ?? 0);
        checkField = 'actual';
      }

      // 分别检查与上一章节和下一章节的重叠
      if (field == 'pdfPageMin' || field == 'actualPageMin') {
        // 对于最小值，检查与上一章节的重叠
        hasOverlapWithPrev =
            hasOverlapWithPrevChapter(chapters, index, checkField, newMin);
        if (hasOverlapWithPrev) {
          ToastUtils.showToast(
            text: "页码范围与上一章节重叠",
          );
          return;
        } else {
          // 没有重叠, 调用更新章节页码范围的函数
          _updateChapterPageRange(field, chapter, numValue);

          // 再检测最大值是否有重叠
          // 对于最大值，检查与下一章节的重叠
          hasOverlapWithNext =
              hasOverlapWithNextChapter(chapters, index, checkField, newMax);
          if (hasOverlapWithNext) {
            ToastUtils.showToast(
              text: "页码范围与下一章节重叠",
            );
          }

          // 更新章节列表
          chapters[chapterIndex] = chapter;
        }
      }

      if (field == 'pdfPageMax' || field == 'actualPageMax') {
        // 对于最大值，检查与下一章节的重叠
        hasOverlapWithNext =
            hasOverlapWithNextChapter(chapters, index, checkField, newMax);
        if (hasOverlapWithNext) {
          ToastUtils.showToast(
            text: "页码范围与下一章节重叠",
          );
        } else {
          // 没有重叠, 调用更新章节页码范围的函数
          _updateChapterPageRange(field, chapter, numValue);

          // 对于最小值，检查与上一章节的重叠
          hasOverlapWithPrev =
              hasOverlapWithPrevChapter(chapters, index, checkField, newMin);
          if (hasOverlapWithPrev) {
            ToastUtils.showToast(
              text: "页码范围与上一章节重叠",
            );
          }
        }

        // 更新章节列表
        chapters[chapterIndex] = chapter;
      }
    } else {
      if (field == 'type') {
        final int? typeId = int.tryParse(value.toString());
        chapter.chapterTypeId = typeId;
        // 更新章节列表
        chapters[chapterIndex] = chapter;
      }
    }
  }

  ///关联单元
  void _relatedUnit(int index, BookChapter chapter) async {
    try {
      ToastUtils.showLoading();
      final response = await BookUtil.relatedUnit(
          bookId: _book!.bookId,
          chapterId: chapters[index].uid,
          config: RequestConfig(requireToken: true));
      if (response?.data != null) {
        ToastUtils.showManageToast(text: response!.data!);
      }
      _loadPages();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 确认保存
  void _saveChapter(int index, BookChapter chapter) async {
    final invalidChapter =
        chapter.chapterTypeId == null || chapter.chapterName?.isEmpty == true;
    if (invalidChapter) {
      Get.snackbar(
        '提示',
        '请完善当前章节的类型和名称信息',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colours.blue_1AA6F3,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    try {
      ToastUtils.showLoading();
      final response = await BookUtil.addChapter(
          config: RequestConfig(data: {
        "bookId": _book?.bookId,
        "bookName": _book?.bookName,
        "chapterList": [chapter.toJson()],
      }, requireToken: true));
      if (response?.data != null) {
        ToastUtils.showManageToast(text: response!.data!);
      }
      _loadPages();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 删除章节
  void _deleteChapter(int index, BookChapter chapter) async {
    final bool ask = await AskDialog.show(
      context: context,
      showLastCountdown: true,
      title: "温馨提示",
      content: "确定要删除${chapter.chapterName}吗？",
      lastCountdown: 2,
    );

    if (!ask) {
      return;
    }

    if (_book?.isDone == true && chapters[index].uid > 0) {
      try {
        ToastUtils.showLoading();
        final response = await BookUtil.deleteChapter(
            chapterId: chapters[index].uid,
            config: RequestConfig(requireToken: true));
        if (response?.data != null) {
          ToastUtils.showManageToast(text: response!.data!);
        }
        _loadPages();
      } finally {
        ToastUtils.hideLoading();
      }
    } else {
      // 直接使用传入的索引
      final chapterIndex = index;
      if (chapterIndex >= 0 && chapterIndex < chapters.length) {
        chapter.disposeControllers();
        safeSetState(() {
          chapters.removeAt(chapterIndex);
        });
      }
    }
  }

  // 分割章节
  void _splitChapter() async {
    if (_book?.bookId == null) {
      ToastUtils.showToast(
        text: "教材ID为空",
      );
      return;
    }

    // 提交前校验数据，确保chapterTypeId和chapterName必须有值
    final invalidChapters = chapters
        .where(
            (chapter) => chapter.chapterTypeId == null || chapter.isNameEmpty)
        .toList();

    if (invalidChapters.isNotEmpty) {
      // 如果有无效章节，显示提示并返回
      ToastUtils.showToast(
        text: "请完善所有章节的类型和名称信息",
      );
      return;
    }

    try {
      ToastUtils.showLoading();
      final response = await BookUtil.splitChapter(
          bookId: _book!.bookId, config: RequestConfig(requireToken: true));
      if (response?.data != null) {
        ToastUtils.showManageToast(text: response!.data!);
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  //提取正文
  void _extractText() async {
    if (_book?.bookId == null) {
      ToastUtils.showToast(
        text: "教材ID为空",
      );
      return;
    }

    try {
      ToastUtils.showLoading();
      final response = await BookUtil.extractText(
          bookId: _book!.bookId, config: RequestConfig(requireToken: true));
      if (response?.data != null) {
        ToastUtils.showManageToast(text: response!.data!);
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  //提取目录
  void _extractTableOfContents() async {
    if (_book?.bookId == null) {
      ToastUtils.showToast(
        text: "教材ID为空",
      );
      return;
    }

    try {
      ToastUtils.showLoading();
      final response = await BookUtil.extractTableOfContents(
          bookId: _book!.bookId, config: RequestConfig(requireToken: true));
      if (response?.data != null) {
        ToastUtils.showManageToast(text: response!.data!);
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  //提取词汇表
  void _extractVocabularyTable() async {
    if (_book?.bookId == null) {
      ToastUtils.showToast(
        text: "教材ID为空",
      );
      return;
    }

    final bool ask = await AskDialog.show(
      context: context,
      showLastCountdown: true,
      title: "温馨提示",
      content: "词汇表已经提取并匹配确认过，您确认需要重新提取？",
      lastCountdown: 3,
    );

    if (!ask) {
      return;
    }

    try {
      ToastUtils.showLoading();
      final response = await BookUtil.analysis(
          bookId: _book!.bookId, config: RequestConfig(requireToken: true));
      if (response?.data != null) {
        ToastUtils.showManageToast(text: response!.data!);
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  void _openPageManagement(int chapterUid) {
    widget.onOpenPageManagement?.call(_book?.bookId ?? 0, chapterUid);
  }

  void _onReorder(int oldIndex, int newIndex) async {
    safeSetState(() {
      final BookChapter row = chapters.removeAt(oldIndex);
      chapters.insert(newIndex, row);
    });
  }

  void _scrollToCounter() async {
    _scrollController.scrollToIndex(chapters.length - 1,
        preferPosition: AutoScrollPosition.end);
  }

  @override
  void dispose() {
    print("---😆😆dispose了[$runtimeType]😆😆---");
    // 释放所有章节的控制器
    for (var chapter in chapters) {
      chapter.disposeControllers();
    }
    super.dispose();
  }
}

class ChapterItem extends StatefulWidget {
  final BookChapter chapter;
  final int index;
  final AutoScrollController controller;
  final bool? isDone;
  final Function(int index, BookChapter chapter, String field, dynamic value)
      onUpdate;
  final Function(int index, BookChapter chapter) onDelete;
  final Function(int index, BookChapter chapter) onAdd;
  final Function(int index, BookChapter chapter) relatedUnit;
  final Function(int uid) onOpenPageManagement;
  final List<ChapterType> chapterTypes;

  const ChapterItem({
    Key? key,
    required this.chapter,
    required this.index,
    required this.controller,
    this.isDone,
    required this.onUpdate,
    required this.onDelete,
    required this.onAdd,
    required this.relatedUnit,
    required this.onOpenPageManagement,
    required this.chapterTypes,
  }) : super(key: key);

  @override
  State<ChapterItem> createState() => _ChapterItemState();
}

class _ChapterItemState extends State<ChapterItem>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    print(
        "---😆😆初始化[$runtimeType],uid:${widget.chapter.uid}, chapter:${widget.chapter.toJson()}😆😆---");
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // print("---😆😆[$runtimeType],chapter:${widget.chapter.toJson()}😆😆---");
    return AutoScrollTag(
      key: ValueKey(widget.chapter.uid),
      index: widget.index,
      controller: widget.controller,
      child: Container(
        key: ValueKey(widget.chapter.uid),
        margin: EdgeInsets.only(bottom: 32.wh),
        decoration: BoxDecoration(
          color: const Color(0xff22293C),
          border: Border(
            bottom: BorderSide(
              width: 1.wMin,
              color: const Color(0xff4B5268),
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 32.ww,
                  child: SvgPicture.asset(
                    'assets/svg/manage/icon_drag.svg',
                    width: 32.wMin,
                    height: 32.wMin,
                  ),
                ),
                SizedBox(
                  width: 73.ww,
                  child: Text(
                    "${widget.index + 1}",
                    style: TextStyle(
                        color: const Color(
                          0xffEBEEF3,
                        ),
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                Gaps.getWidth(16.ww),
                Text(
                  "章节ID: ${widget.chapter.uid}",
                  style: TextStyle(
                      color: const Color(
                        0xffEBEEF3,
                      ),
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w400),
                ),
                Gaps.getWidth(16.ww),
                Text(
                  "单元ID: ${widget.chapter.unitId ?? ''}",
                  style: TextStyle(
                      color: const Color(
                        0xffEBEEF3,
                      ),
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w400),
                ),
                const Spacer(),
                // 删除按钮
                TapScaleWidget(
                  onTap: OptimizeUtils.noneThrottle(() {
                    widget.onDelete(widget.index, widget.chapter);
                  }, 100),
                  sclae: 1.5,
                  child: Container(
                    width: 32.wMax,
                    height: 32.wMax,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(3.wMin),
                    ),
                    child: SvgPicture.asset('assets/images/manager/trash.svg',
                        width: 32.wMin, height: 32.wMin),
                  ),
                ),
              ],
            ),
            Gaps.getHeight(8.wh),
            // 章节名称
            Row(
              children: [
                Gaps.getWidth(32.ww),
                SizedBox(
                  width: 73.ww,
                  child: Text(
                    "章节名",
                    style: TextStyle(
                        color: const Color(
                          0xffEBEEF3,
                        ),
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                Gaps.getWidth(16.ww),
                // 章节名称输入框
                Expanded(
                  child: ManageTitleInputWidget(
                    controller: widget.chapter.nameController ??
                        TextEditingController(),
                    hintText: "请输入章节名",
                    height: 40.wh,
                    onChanged: (value) {
                      widget.onUpdate(
                          widget.index, widget.chapter, 'name', value);
                    },
                  ),
                ),
              ],
            ),

            // 章节类型
            Gaps.getHeight(12.wh),
            Row(
              children: [
                Gaps.getWidth(32.ww),
                SizedBox(
                  width: 73.ww,
                  child: Text(
                    "章节类型",
                    style: TextStyle(
                        color: const Color(
                          0xffEBEEF3,
                        ),
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                Gaps.getWidth(16.ww),
                // 章节类型选择框
                Expanded(
                  child: ManageSelectWidget(
                    value: chapterTypeTitle,
                    hintText: "请选择章节类型",
                    height: 40.wh,
                    options: widget.chapterTypes
                        .where((type) => type.hasValidTitle)
                        .map((type) => type.title!)
                        .toList(),
                    onChanged: (value, index) {
                      // 直接使用 index 获取选中的 ChapterType 对象
                      final validTypes = widget.chapterTypes
                          .where((type) => type.hasValidTitle)
                          .toList();
                      if (index >= 0 && index < validTypes.length) {
                        final selectedType = validTypes[index];
                        widget.onUpdate(widget.index, widget.chapter, 'type',
                            selectedType.uid.toString());
                      }
                    },
                  ),
                ),
              ],
            ),

            // PDF页码范围设置
            Gaps.getHeight(12.wh),
            Row(
              children: [
                Gaps.getWidth(32.ww),
                SizedBox(
                  width: 73.ww,
                  child: Text(
                    "PDF页码",
                    style: TextStyle(
                        color: const Color(
                          0xffEBEEF3,
                        ),
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                Gaps.getWidth(16.ww),
                // PDF最小页码
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: ManageTitleInputWidget(
                          controller:
                              widget.chapter.pageRange?.pdf?.startController,
                          hintText: "起始页",
                          height: 40.wh,
                          onChanged: OptimizeUtils.debounce(
                            (value) {
                              widget.onUpdate(widget.index, widget.chapter,
                                  'pdfPageMin', value);
                            },
                            const Duration(milliseconds: 500),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          child: _buildNumberInput(
                            value: (widget.chapter.pageRange?.pdf?.start ?? 0)
                                .toString(),
                            onChanged: (value) {
                              widget.onUpdate(widget.index, widget.chapter,
                                  'pdfPageMin', value);
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.ww),
                        child: Text(
                          '-',
                          style: TextStyle(
                            color: const Color(0xff4B5268),
                            fontSize: 16.wMin,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      // PDF最大页码
                      Expanded(
                        child: ManageTitleInputWidget(
                          controller:
                              widget.chapter.pageRange?.pdf?.endController,
                          hintText: "结束页",
                          height: 40.wh,
                          onChanged: OptimizeUtils.debounce(
                            (value) {
                              widget.onUpdate(widget.index, widget.chapter,
                                  'pdfPageMax', value);
                            },
                            const Duration(milliseconds: 500),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          child: _buildNumberInput(
                            value: (widget.chapter.pageRange?.pdf?.end ?? 0)
                                .toString(),
                            onChanged: (value) {
                              widget.onUpdate(widget.index, widget.chapter,
                                  'pdfPageMax', value);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // 实际页码范围设置
            Gaps.getHeight(12.wh),
            Row(
              children: [
                Gaps.getWidth(32.ww),
                SizedBox(
                  width: 73.ww,
                  child: Text(
                    "实际页码",
                    style: TextStyle(
                        color: const Color(
                          0xffEBEEF3,
                        ),
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                Gaps.getWidth(16.ww),
                // 实际最小页码
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: ManageTitleInputWidget(
                          controller:
                              widget.chapter.pageRange?.book?.startController,
                          hintText: "起始页",
                          height: 40.wh,
                          onChanged: OptimizeUtils.debounce(
                            (value) {
                              widget.onUpdate(widget.index, widget.chapter,
                                  'actualPageMin', value);
                            },
                            const Duration(milliseconds: 500),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          child: _buildNumberInput(
                            value: (widget.chapter.pageRange?.book?.start ?? 0)
                                .toString(),
                            onChanged: (value) {
                              widget.onUpdate(widget.index, widget.chapter,
                                  'actualPageMin', value);
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.ww),
                        child: Text(
                          '-',
                          style: TextStyle(
                            color: const Color(0xff4B5268),
                            fontSize: 16.wMin,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      // 实际最大页码
                      Expanded(
                        child: ManageTitleInputWidget(
                          controller:
                              widget.chapter.pageRange?.book?.endController,
                          hintText: "结束页",
                          height: 40.wh,
                          onChanged: OptimizeUtils.debounce(
                            (value) {
                              widget.onUpdate(widget.index, widget.chapter,
                                  'actualPageMax', value);
                            },
                            const Duration(milliseconds: 500),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          child: _buildNumberInput(
                            value: (widget.chapter.pageRange?.book?.end ?? 0)
                                .toString(),
                            onChanged: (value) {
                              widget.onUpdate(widget.index, widget.chapter,
                                  'actualPageMax', value);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Gaps.getHeight(32.wh),
            Row(
              children: [
                SizedBox(
                  width: 121.ww,
                ),
                Row(
                  children: [
                    Visibility(
                      visible: widget.chapter.splited == true,
                      child: ManageButton(
                        text: '已分割',
                        height: 40.wh,
                        width: 120.ww,
                        radius: 6.wMin,
                        color: const Color(0xff17C964).withValues(alpha: 0.12),
                        style: TextStyle(
                          fontSize: 18.wMin,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xff63DE77),
                        ),
                      ),
                    ),
                    Gaps.getWidth(16.ww),
                    Visibility(
                      visible: widget.chapter.extracted == true,
                      child: ManageButton(
                        text: '已提取',
                        height: 40.wh,
                        width: 120.ww,
                        radius: 6.wMin,
                        color: const Color(0xff17C964).withValues(alpha: 0.12),
                        style: TextStyle(
                          fontSize: 18.wMin,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xff63DE77),
                        ),
                      ),
                    )
                  ],
                ),
                const Spacer(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.chapter.united != null)
                      Visibility(
                        visible: widget.chapter.united == false,
                        child: ManageButton(
                          text: '关联单元',
                          onTap: () => {
                            widget.relatedUnit(widget.index, widget.chapter)
                          },
                          color: const Color(0xff353E5C),
                          height: 40.wh,
                          width: 120.ww,
                          borderColor: Colors.transparent,
                          radius: 6.wMin,
                          style: TextStyle(
                            fontSize: 18.wMin,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xffACB4C0),
                          ),
                        ),
                      ),
                    Gaps.getWidth(16.ww),
                    Visibility(
                      visible: widget.isDone == true,
                      child: ManageButton(
                        text: '确认保存',
                        onTap: () =>
                            {widget.onAdd(widget.index, widget.chapter)},
                        color: const Color(0xff353E5C),
                        height: 40.wh,
                        width: 120.ww,
                        borderColor: Colors.transparent,
                        radius: 6.wMin,
                        style: TextStyle(
                          fontSize: 18.wMin,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xffACB4C0),
                        ),
                      ),
                    ),
                    Gaps.getWidth(16.ww),
                    ManageButton(
                      text: '管理页面',
                      onTap: () =>
                          widget.onOpenPageManagement(widget.chapter.uid),
                      color: const Color(0xff353E5C),
                      height: 40.wh,
                      width: 120.ww,
                      borderColor: Colors.transparent,
                      radius: 6.wMin,
                      style: TextStyle(
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xffACB4C0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Gaps.getHeight(32.wh)
          ],
        ),
      ),
    );
  }

  /// 获取章节类型标题
  String get chapterTypeTitle {
    String title = '';
    try {
      // 如果有类型 ID，则在类型列表中查找对应的标题
      if (widget.chapter.chapterTypeId != null) {
        final typeId = widget.chapter.chapterTypeId;
        final type = widget.chapterTypes.firstWhereOrNull(
          (type) => type.uid == typeId,
        );
        if (type != null && type.hasValidTitle) {
          title = type.title!;
        }
      }
    } catch (e) {
      print(e.toString());
    }
    return title;
  }

  // 构建带上下箭头的数字输入组件
  Widget _buildNumberInput({
    required String value,
    required Function(String) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.only(left: 12.ww),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            width: 1.wMin,
            color: const Color(0xff4B5268),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 上箭头按钮
          GestureDetector(
            onTap: () {
              final intValue = int.tryParse(value) ?? 0;
              onChanged((intValue + 1).toString());
            },
            child: Container(
              width: 24.ww,
              height: 18.wh,
              alignment: Alignment.center,
              child: SvgPicture.asset(
                'assets/svg/manage/icon_chevron_up.svg',
                width: 14.ww,
                height: 14.wh,
                colorFilter: const ColorFilter.mode(
                  Color(0xffEBEEF3),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          // 下箭头按钮
          GestureDetector(
            onTap: () {
              final intValue = int.tryParse(value) ?? 0;
              if (intValue > 0) {
                onChanged((intValue - 1).toString());
              }
            },
            child: Container(
              width: 24.ww,
              height: 18.wh,
              alignment: Alignment.center,
              child: SvgPicture.asset(
                'assets/svg/manage/icon_chevron_down.svg',
                width: 14.ww,
                height: 14.wh,
                colorFilter: const ColorFilter.mode(
                  Color(0xffEBEEF3),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    print(
        "---😆😆ChapterItem章节dispose了[$runtimeType],chapterName:${widget.chapter.chapterName}, uid:${widget.chapter.uid}😆😆---");
    super.dispose();
  }
}
