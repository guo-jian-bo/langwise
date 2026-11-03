import 'package:common_utils/common_utils.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:langwise/common/values/values.dart';
import 'package:langwise/common/widgets/build_image.dart';
import 'package:langwise/generated/assets.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:quiz_play/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'nav_helper.dart';
import 'page_drop_down_widget.dart';

class PageNumber extends StatefulWidget {
  const PageNumber({
    super.key,
    required PaginatorController controller,
  }) : _controller = controller;

  final PaginatorController _controller;

  @override
  PageNumberState createState() => PageNumberState();
}

class PageNumberState extends State<PageNumber> {
  void update() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget._controller.addListener(update);
  }

  @override
  void dispose() {
    widget._controller.removeListener(update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Checking instance id to see if build is called
    // on different ones
    // Due to some reasons when using this widget
    // with AsyncPaginatedDatatable2 the widget is instatiotaed once
    // though it's state is created 3 times upon first loading
    // of the Custom pager example
    // print(identityHashCode(this));
    // 总页数向上取整
    return Text(widget._controller.isAttached
        ? 'Page: ${1 + ((widget._controller.currentRowIndex + 1) / widget._controller.rowsPerPage).floor()} of '
            '${(widget._controller.rowCount / widget._controller.rowsPerPage).ceil()}'
        : 'Page: x of y');
  }
}

class CustomPager extends StatefulWidget {
  const CustomPager(this.controller, {super.key});

  final PaginatorController controller;

  @override
  CustomPagerState createState() => CustomPagerState();
}

class CustomPagerState extends State<CustomPager> {
  static const List<int> _availableSizes = availableRowsPerPage;

  final GlobalKey _pageNumberGlobalKey = GlobalKey();

  final TextEditingController pageNumberController = TextEditingController();

  final FocusNode pageNumberFocus = FocusNode();

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    /*
    todo
    rowsPerPage: 每页多少行, 也就是服务器的pageSize
    rowCount: 总行数
    currentRowIndex: 当前行的索引, 从0开始, 跟rowsPerPage有关。
      - rowsPerPage为20, 那么第一页的currentRowIndex=0, 第二页的currentRowIndex=currentRowIndex+20.
     */
    widget.controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    // skip this build pass
    if (!widget.controller.isAttached) return const SizedBox();
    if (!_initialized) {
      // 初始页数, 默认第一页
      final int currentPage = 1 + ((widget.controller.currentRowIndex + 1) / widget.controller.rowsPerPage).floor();
      pageNumberController.text = currentPage.toString();
      _initialized = true;
    }

    return Container(
        decoration: BoxDecoration(
          // color: Colors.red,
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            PageTotalNumberWidget(
              number: widget.controller.rowCount,
            ),
            Gaps.getWidth(6.ww),
            PageNumberWidget(
              key: _pageNumberGlobalKey,
              number: _availableSizes.contains(widget.controller.rowsPerPage)
                  ? widget.controller.rowsPerPage
                  : _availableSizes[0],
              onTap: () {
                var record = CommonUtils.getSizeAndPosition(_pageNumberGlobalKey);
                print(
                    '---😆😆globalPosition: ${record.globalPosition}, localPosition:${record.localPosition}, size: ${record.size}');
                final double center = record.globalPosition.dx + record.size.width / 2;

                print(
                    '---currentRowIndex: ${widget.controller.currentRowIndex},rowCount:${widget.controller.rowCount} ');

                PageDropDownManager.show(
                    context: context,
                    list: _availableSizes,
                    left: center - AppConstant.managerPageNumberDropDownWidth / 2,
                    top: record.globalPosition.dy + record.size.height,
                    onTap: (int index) {
                      widget.controller.setRowsPerPage(_availableSizes[index]);
                    });
              },
            ),
            Gaps.getWidth(6.ww),
            PageButtonImageWidget(
              icon: pointPreviousIcon,
              isEnable: isPointPreviousEnable,
              onTap: (bool isEnable) {
                print('上一页');
                widget.controller.goToPreviousPage();
              },
            ),
            ..._buildButtonWidget(onPageTap: (value) {
              print('---😆😆点击页数,value: $value😆😆---');
              if (ObjectUtil.isNotEmpty(value)) {
                /*
                 将用户输入的页面转换成行索引,因为行索引rowIndex是从0开始,所以用户输入第一页1,实际赋予的行索引rowIndex=0
                    行索引= rowsPerPage每页行数 * value
                */
                final int newValue = (int.tryParse(value!) ?? 0);
                final int rowIndex = widget.controller.rowsPerPage * (newValue - 1);
                print('---😆😆点击页数, rowIndex: $rowIndex😆😆---');
                widget.controller.goToPageWithRow(rowIndex);
              }
            }),
            Gaps.getWidth(6.ww),
            PageButtonImageWidget(
              icon: pointNextIcon,
              isEnable: isPointNextEnable,
              onTap: (bool isEnable) {
                print('下一页');
                widget.controller.goToNextPage();
              },
            ),
            Gaps.getWidth(6.ww),
            Text('前往',
                style: TextStyle(
                  color: const Color(0xffBAC0CC),
                  fontSize: 14.wMin,
                  fontWeight: FontWeight.w400,
                  height: 1.0,
                )),
            Gaps.getWidth(6.ww),
            Container(
              width: 51.ww,
              height: 36.wh,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.wMin),
                color: const Color(0xff353E5C),
                border: Border.all(width: 1.wMin, color: const Color(0xff444B5F)),
              ),
              alignment: Alignment.center,
              child: TextField(
                controller: pageNumberController,
                keyboardType: TextInputType.number,
                focusNode: pageNumberFocus,
                textAlign: TextAlign.center,
                inputFormatters: [
                  // 限制输入为数字
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                  // important 用于编辑框对齐
                  border: InputBorder.none,
                  hintText: '页数',
                  hintStyle: TextStyle(
                      color: const Color(0xffBAC0CC),
                      fontSize: 14.wMin,
                      fontWeight: FontWeight.w400,
                      height: 1.0,
                      textBaseline: TextBaseline.alphabetic),
                ),
                style: TextStyle(
                  color: const Color(0xffFFFFFF),
                  fontSize: 14.wMin,
                  fontWeight: FontWeight.w400,
                  height: 1.0,
                ),
                autocorrect: false,
                enableSuggestions: false,
                cursorColor: Colors.white,
                onSubmitted: OptimizeUtils.throttle((value) {
                  print('---前往页数,value: $value😆😆---');
                  if (ObjectUtil.isNotEmpty(value)) {
                    /*
                    将用户输入的页面转换成行索引,因为行索引rowIndex是从0开始,所以用户输入第一页1,实际赋予的行索引rowIndex=0
                    用户输入的最后一页, 不大于总行数
                    行索引= rowsPerPage每页行数 * value
                     */
                    final int newValue = (int.tryParse(value) ?? 0);
                    if (newValue <= 0) {
                      print('---前往页数必须大于0😆😆---');
                      return;
                    }

                    final int totalPage = (widget.controller.rowCount / widget.controller.rowsPerPage).ceil();
                    print('---总页数totalPage:$totalPage😆😆---');
                    if (newValue > (totalPage)) {
                      print('---前往页数超过总页数:$totalPage😆😆---');
                      return;
                    }

                    final int rowIndex = widget.controller.rowsPerPage * (newValue - 1);
                    print('---前往页数,rowIndex: $rowIndex😆😆---');
                    widget.controller.goToPageWithRow(rowIndex);
                  }
                }, 100),
              ),
            ),
            Gaps.getWidth(6.ww),
            Text('页',
                style: TextStyle(
                  color: const Color(0xffBAC0CC),
                  fontSize: 14.wMin,
                  fontWeight: FontWeight.w400,
                  height: 1.0,
                )),
            Gaps.getWidth(6.ww),
          ],
        ));
  }

  List<Widget> _buildButtonWidget({ValueChanged<String?>? onPageTap}) {
    // 重点/强制当前页在有效范围内（重要防御性编程）. 页数显示跟当前行索引的关系,也就是+1的问题
    final int currentPage = 1 + ((widget.controller.currentRowIndex + 1) / widget.controller.rowsPerPage).floor();
    // print(
    //     '---😆😆当前页数,rowCount: ${widget.controller.rowCount}, currentRowIndex: ${widget.controller.currentRowIndex}, currentPage:$currentPage---');

    const maxVisible = 5; // 核心可见页码数
    final items = <_PageItem>[];

    // 总页数, 向上取整
    final int total = (widget.controller.rowCount / widget.controller.rowsPerPage).ceil();
    if (total <= maxVisible + 2) {
      // 总页数较少时直接显示
      for (int i = 1; i <= total; i++) {
        items.add(_PageItem.number(i));
      }
    } else {
      // 智能分页模式
      // 始终保留首页
      items.add(_PageItem.number(1));

      // 计算中间页码范围
      int start = currentPage - maxVisible ~/ 2;
      int end = currentPage + maxVisible ~/ 2;

      // 边界修正
      if (start < 2) {
        // 补偿左侧不足
        end += 2 - start;
        start = 2;
      }
      if (end > total - 1) {
        // 补偿右侧不足
        start -= end - (total - 1);
        end = total - 1;
      }
      // 二次校验
      start = start.clamp(2, total - 1);
      end = end.clamp(2, total - 1);

      // 添加前省略号（仅当中间页码不连续时,标记为1）/记录前省略号跳转范围
      if (start > 2) {
        // 跳转到中间区间的第一页-1
        items.add(_PageItem.ellipsis(1, start - 1));
      }

      // 中间页码
      for (int i = start; i <= end; i++) {
        items.add(_PageItem.number(i));
      }

      // 添加后省略号（仅当中间页码不连续时,标记为2）/记录后省略号跳转范围
      if (end < total - 1) {
        // 跳转到中间区间的最后一页+1
        items.add(_PageItem.ellipsis(2, end + 1));
      }

      // 始终保留尾页
      items.add(_PageItem.number(total));
    }

    return List.generate(items.length, (int index) {
      final _PageItem p = items[index];
      if (p.type == 0) {
        return PageButtonTextWidget(
          title: '${p.value}',
          isSelected: currentPage == (p.value),
          onTap: (String? value) {
            print('---选中value:$value');
            onPageTap?.call(value);
          },
        );
      }
      return PageEllipsisButtonWidget(
        icon: Assets.managerPoint,
        item: p,
        margin: EdgeInsets.only(left: 6.ww),
        onTap: (_PageItem item) {
          final int targetPage = p.targetPage!.clamp(1, total);
          final int rowIndex = widget.controller.rowsPerPage * (targetPage - 1);
          print('---点击页数, targetPage: $targetPage, rowIndex: $rowIndex---');
          widget.controller.goToPageWithRow(rowIndex);
        },
      );
    }).toList();
  }

  String get pointPreviousIcon {
    if (isPointPreviousEnable) {
      return Assets.managerPageButtonLeft;
    }
    return Assets.managerPageButtonUnselectedLeft;
  }

  String get pointNextIcon {
    if (isPointNextEnable) {
      return Assets.managerPageButtonRight;
    }
    return Assets.managerPageButtonUnselectedRight;
  }

  bool get isPointPreviousEnable {
    // 当前页
    final int currentPage = 1 + ((widget.controller.currentRowIndex + 1) / widget.controller.rowsPerPage).floor();
    return currentPage != 1;
  }

  bool get isPointNextEnable {
    // 当前页
    final int currentPage = 1 + ((widget.controller.currentRowIndex + 1) / widget.controller.rowsPerPage).floor();
    // 总页数
    final int totalPage = (widget.controller.rowCount / widget.controller.rowsPerPage).ceil();
    return currentPage != totalPage;
  }
}

class PageTotalNumberWidget extends StatelessWidget {
  final int number;
  final VoidCallback? onTap;

  const PageTotalNumberWidget({super.key, required this.number, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 12.ww, right: 12.ww),
      height: 36.wh,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.wMin),
        color: const Color(0xff353E5C),
        border: Border.all(width: 1.wMin, color: const Color(0xff444B5F)),
      ),
      alignment: Alignment.center,
      child: Text(
        '共$number条',
        style: TextStyle(
          color: const Color(0xffFFFFFF),
          fontSize: 14.wMin,
          fontWeight: FontWeight.w400,
          height: 1.0,
        ),
      ),
    );
  }
}

class PageNumberWidget extends StatelessWidget {
  final int number;
  final String? title;
  final VoidCallback? onTap;

  const PageNumberWidget({super.key, required this.number, this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: OptimizeUtils.noneThrottle(() {
        onTap?.call();
      }, 80),
      child: Container(
        padding: EdgeInsets.only(left: 12.ww, right: 12.ww, top: 8.wh, bottom: 8.wh),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.wMin),
          color: const Color(0xff353E5C),
          border: Border.all(width: 1.wMin, color: const Color(0xff444B5F)),
        ),
        child: Row(
          children: [
            Text(
              '$number条/页',
              style: TextStyle(
                color: const Color(0xffFFFFFF),
                fontSize: 14.wMin,
                fontWeight: FontWeight.w400,
                height: 1.0,
              ),
            ),
            Gaps.getWidth(8.ww),
            buildImage(Assets.managerPaginationDown, width: 16.wMax, height: 16.wMax),
          ],
        ),
      ),
    );
  }
}

class PageButtonTextWidget extends StatelessWidget {
  final String? title;
  final bool isSelected;
  final ValueChanged<String?>? onTap;

  const PageButtonTextWidget({super.key, this.title, required this.isSelected, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: OptimizeUtils.noneThrottle(() {
        onTap?.call(title);
      }, 50),
      child: Container(
          margin: EdgeInsets.only(
            left: 6.ww,
          ),
          width: 52.wh,
          height: 36.wh,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.wMin),
            color: isSelected ? const Color(0xff353E5C) : Colors.transparent,
            border: Border.all(width: 1.wMin, color: const Color(0xff444B5F)),
          ),
          child: Text(title ?? '',
              style: TextStyle(
                color: const Color(0xffFFFFFF),
                fontSize: 14.wMin,
                fontWeight: FontWeight.w400,
                height: 1.0,
              ))),
    );
  }
}

class PageButtonImageWidget extends StatelessWidget {
  final String? icon;
  final EdgeInsetsGeometry? margin;
  final bool isEnable;
  final Function(bool)? onTap;

  const PageButtonImageWidget({super.key, this.icon, this.margin, this.isEnable = true, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: OptimizeUtils.noneThrottle(() {
        if (isEnable) onTap?.call(isEnable);
      }, 50),
      child: Container(
          width: 52.wh,
          height: 36.wh,
          margin: margin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.wMin),
            color: Colors.transparent,
            border: Border.all(width: 1.wMin, color: borderColor),
          ),
          child: buildImage(icon ?? '', width: 16.ww, height: 16.ww, fit: BoxFit.contain)),
    );
  }

  Color get borderColor {
    if (isEnable) {
      return const Color(0xff444B5F);
    }
    return const Color(0xff444B5F).withValues(alpha: 0.3);
  }
}

class PageEllipsisButtonWidget extends StatefulWidget {
  final String? icon;
  final _PageItem item;
  final EdgeInsetsGeometry? margin;
  final Function(_PageItem)? onTap;

  const PageEllipsisButtonWidget({super.key, this.icon, required this.item, this.margin, this.onTap});

  @override
  State<PageEllipsisButtonWidget> createState() => _PageEllipsisButtonWidgetState();
}

class _PageEllipsisButtonWidgetState extends State<PageEllipsisButtonWidget> with SafeSetStateMixin {
  bool _isHover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onHover: (event) {
        safeSetState(() {
          _isHover = true;
        });
      },
      onExit: (event) {
        safeSetState(() {
          _isHover = false;
        });
      },
      child: GestureDetector(
        onTapCancel: () {
          safeSetState(() {
            _isHover = false;
          });
        },
        onTap: OptimizeUtils.noneThrottle(() {
          widget.onTap?.call(widget.item);
        }, 50),
        child: Container(
          width: 52.wh,
          height: 36.wh,
          margin: widget.margin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.wMin),
            color: Colors.transparent,
            border: Border.all(width: 1.wMin, color: const Color(0xff444B5F)),
          ),
          child: buildImage(
              _isHover
                  ? (widget.item.isLeftEllipsis ? Assets.managerPageButtonLeft : Assets.managerPageButtonRight)
                  : widget.icon ?? '',
              width: 16.ww,
              height: 16.ww,
              fit: BoxFit.contain),
        ),
      ),
    );
  }
}

class _PageItem {
  final int type; // 0:数字页码，1:左省略号，2:右省略号
  final int? value;
  final int? targetPage;

  _PageItem.number(this.value)
      : type = 0,
        targetPage = null;

  _PageItem.ellipsis(this.type, this.targetPage)
      : value = null,
        assert(type == 1 || type == 2);

  bool get isLeftEllipsis => type == 1;
}
