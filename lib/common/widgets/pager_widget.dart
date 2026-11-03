
import 'package:flutter/services.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'widgets.dart';

class PagerController {
  _PagerWidgetState? _state;
  
  ///跳转页面
  void jumpToPage(int page){
    _state?.jumpToPage(page);
  }


}

class PagerWidget extends StatefulWidget {
  /// 共多少条数据
  final int dataCount;
  /// 每页显示多少条
  final int pageSize;
  /// 同时显示的页码数量
  final int visiblePageCount;
  /// 文字颜色
  final Color activeColor;
  /// 分页器控制器
  final PagerController? controller;
  /// 回调
  final void Function(int page, int pageSize)? onPage;

  /// 分页器
  const PagerWidget({
    super.key, 
    required this.dataCount, 
    this.pageSize = 20,
    this.visiblePageCount = 4,
    this.activeColor = Colors.white,
    this.controller,
    this.onPage,
  });

  @override
  State<PagerWidget> createState() => _PagerWidgetState();
}

class _PagerWidgetState extends State<PagerWidget> {

  /// 下拉菜单
  List<IconDropdownIconData> dropDownMenuWidgetList = [
    IconDropdownIconData(title: "5", value: 5),
    IconDropdownIconData(title: "20", value: 20),
    IconDropdownIconData(title: "30", value: 30),
    IconDropdownIconData(title: "50", value: 50),
    IconDropdownIconData(title: "100", value: 100),
  ];

  /// 每页显示多少条
  int _pageSize = 20;

  /// 共多少页
  int _pageCount = 0;

  /// 当前页
  int _currentPage = 1;

  TextEditingController _numberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
    _pageSize = widget.pageSize;
    _pageCount = (widget.dataCount / widget.pageSize).ceil();
    print(_pageCount);
  }
  
  @override
  void didUpdateWidget(covariant PagerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(widget.dataCount != oldWidget.dataCount || widget.pageSize != oldWidget.pageSize){
      _pageCount = (widget.dataCount / widget.pageSize).ceil();
    }

  }

  /// 跳转页面
  void jumpToPage(int page){
    _numberController.clear();
    setState(() {
      _currentPage = page;
    });
    widget.onPage?.call(_currentPage, _pageSize);
  }
  

  


  @override
  Widget build(BuildContext context) {

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
       
        _buildAllCountWidget(),

        SizedBox(width: 10.wMin, height: 54.wMin + 24),// 这个24是分页器的上下边距

        _buildPageSizeWidget(),

        Visibility(
          visible: _pageCount > 0,
          child: Container(
            margin: EdgeInsets.only(left: 10.wMin),
            child: Row(
              spacing: 10.wMin,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPaginationWidget(),
                _buildNumberWidget(),
              ],
            ),
          ),
        ),
    
      ],
    );
  }

  /// 共多少条
  Widget _buildAllCountWidget(){
    return Container(
      height: 54.wMin,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 10.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.wMin),
        border: Border.all(color: widget.activeColor.withValues(alpha: 0.2), width: 1.wMin),
      ),
      child: Text(
        "共${widget.dataCount}条",
        style: TextStyle(
          color: widget.activeColor,
          fontSize: 18.wMin,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  /// 显示多少条1页
  Widget _buildPageSizeWidget(){
    return IconDropdownMenuWidget(
      sclae: 1.03,
      width: 140.wMin,
      items: dropDownMenuWidgetList,
      itemHeight: 54.wMin,
      textStyle: TextStyle(
        color: AppTheme.cTextPrimary.color,
        fontSize: 18.wMin,
        fontWeight: FontWeight.w400,
      ),
      onTap: (data, index) {
        setState(() {
          _pageSize = data.value??20;
          _pageCount = (widget.dataCount / _pageSize).ceil();
        });
        widget.onPage?.call(_currentPage, _pageSize);
      },
      child: Container(
        height: 54.wMin,
        width: 140.wMin,
        padding: EdgeInsets.only(right: 10.wMin),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10.wMin),
          border: Border.all(color: widget.activeColor.withValues(alpha: 0.2), width: 1.wMin),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Center(
                child: Text(
                  "$_pageSize条/页",
                  style: TextStyle(
                    color: widget.activeColor,
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            SvgPicture.asset(
              "assets/svg/manage/icon_arrow_down.svg",
              width: 24.wMin,
              height: 24.wMin,
            ),
            
          ],
        ),
      ),
    );
  }

  /// 分页器
  Widget _buildPaginationWidget(){
    return MaterialPagination(
      currentPage: _currentPage,
      totalPages: _pageCount,
      visiblePageCount: widget.visiblePageCount,
      buttonSize: 54.wMin,
      iconSize: 20.wMin,
      borderRadius: 10.wMin,
      activeColor: widget.activeColor,
      inactiveColor: widget.activeColor,
      type: MPageType.outlined,
      colorDarkness: 0.3,
      activeTextColor: widget.activeColor,
      inactiveTextColor: widget.activeColor,
      iconGap: 4.wMin,
      fontStyle: TextStyle(
        color: widget.activeColor,
        fontSize: 18.wMin,
        fontWeight: FontWeight.w400,
      ),
      onPageChanged: (int pageNumber) {
        setState(() {
          _currentPage = pageNumber;
        });
        widget.onPage?.call(_currentPage, _pageSize);
      },
    );
  }

  /// 前往多少页
  Widget _buildNumberWidget(){
    return Row(
      spacing: 4.wMin,
      children: [
        Text(
          "前往",
          style: TextStyle(
            fontSize: 18.wMin,
            color: widget.activeColor,
            fontWeight: FontWeight.w400,
          ),
        ),
        Container(
          width: 70.wMin,
          height: 54.wMin,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.wMin),
            color: Colors.transparent,
            border: Border.all(
              width: 1.wMin,
              color: widget.activeColor.withValues(alpha: 0.2),
            ),
          ),
          child: _buildInputWidget(),
        ),
        Text(
          "页",
          style: TextStyle(
            fontSize: 18.wMin,
            color: widget.activeColor,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }


  Widget _buildInputWidget(){
    return TextField(
      controller: _numberController,
      maxLines: 1,
      maxLength: _pageCount.toString().length,
      style: TextStyle(
        fontSize: 18.wMin,
        color: widget.activeColor,
        fontWeight: FontWeight.w400,
      ),
      textAlignVertical: TextAlignVertical.center,
      textAlign: TextAlign.center,
      textInputAction: TextInputAction.done,
      cursorColor: Colors.blue,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        isDense: true,
        counterText: "",
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
      ),
      onSubmitted: (text){
        try {
          int? num = int.tryParse(text);
          if(num == null) return;
          if(num < 1) {
            num = 1;
            _numberController.text = num.toString();
          }
          if(num > _pageCount) {
            num = _pageCount;
            _numberController.text = num.toString();
          }
          setState(() {
            _currentPage = num!;
            
          });
          widget.onPage?.call(_currentPage, _pageSize);
        } catch (_) {
          
        }
      },
      onTapOutside: (event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
    );
  }

}


class MaterialPagination extends StatelessWidget {
  /// The currently active page in the pagination.
  final int currentPage;

  /// The total number of pages in the pagination.
  final int totalPages;

  /// Callback function that is triggered when the user selects a different page.
  /// It passes the selected page index.
  final Function(int page) onPageChanged;

  /// The number of page buttons visible at once.
  /// Defaults to 5.
  final int visiblePageCount;

  /// The color of the active page button.
  /// Defaults to [Colors.blue].
  final Color? activeColor;

  /// The color of inactive page buttons.
  /// Defaults to [Colors.grey].
  final Color? inactiveColor;

  /// Customizable text style for the page numbers.
  final TextStyle? fontStyle;

  /// The size of the page buttons.
  /// Defaults to 32.0.
  final double buttonSize;

  /// The size of the icons (e.g., for next/previous arrows).
  /// Defaults to 12.0.
  final double iconSize;

  /// The gap between the pagination icons and the buttons.
  /// Defaults to 4.0.
  final double iconGap;

  /// The border radius for the page buttons.
  /// Defaults to 8.0.
  final double borderRadius;

  /// The darkness level of the button colors when inactive, represented as a value between 0 and 1.
  /// Defaults to 0.3.
  final double colorDarkness;

  /// The type of pagination button style to be used.
  /// Determines the visual appearance of the pagination buttons.
  /// Defaults to [MPageType.filled].
  final MPageType type;

  /// The color of the text for active buttons.
  /// Defaults to null.
  final Color? activeTextColor;

  /// The color of the text for inactive buttons.
  /// Defaults to null.
  final Color? inactiveTextColor;

  const MaterialPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.visiblePageCount = 5,
    this.fontStyle,
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.grey,
    this.buttonSize = 32.0,
    this.iconGap = 4.0,
    this.borderRadius = 8.0,
    this.colorDarkness = 0.3,
    this.iconSize = 12.0,
    this.type = MPageType.filled,
    this.activeTextColor,
    this.inactiveTextColor,
  });

  /// Helper method to calculate the visible range of page numbers to display.
  /// It ensures the range is adjusted correctly based on the current page, total pages,
  /// and the number of visible pages.
  List<int> _calculatePageRange() {
    int halfVisible =
        (visiblePageCount / 2).floor(); // Calculate half of visible pages
    int startPage = (currentPage - halfVisible)
        .clamp(1, totalPages); // Calculate start page
    int endPage =
        (currentPage + halfVisible).clamp(1, totalPages); // Calculate end page

    // Adjust start or end page if they exceed the range
    if (startPage == 1) {
      endPage = visiblePageCount.clamp(1, totalPages);
    } else if (endPage == totalPages) {
      startPage = (totalPages - visiblePageCount + 1).clamp(1, totalPages);
    }

    return [
      startPage,
      endPage
    ]; // Return the range as a list of start and end pages
  }

  /// Helper method to build a button for individual page numbers.
  /// [pageIndex] is the page number displayed on the button, [isCurrentPage] indicates whether it's the active page.
  Widget _buildPageButton(int pageIndex, bool isCurrentPage) {
    return SizedBox(
      height: buttonSize,
      width: buttonSize + 20,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: type == MPageType.filled
              ? (isCurrentPage ? activeColor : inactiveColor?.withAlpha(50))
              : (isCurrentPage
                  ? activeColor?.withAlpha(51)
                  : inactiveColor?.withAlpha(3)),
          borderRadius: BorderRadius.circular(borderRadius),
          border: type == MPageType.outlined
              ? Border.all(
                  color: isCurrentPage
                      ? activeColor?.darken() ?? inactiveColor!
                      : inactiveColor!.withAlpha(59),
                )
              : null,
        ),
        child: TextButton(
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: EdgeInsets.zero,
            textStyle: fontStyle?.copyWith(
              color: type == MPageType.filled && isCurrentPage
                  ? activeTextColor ?? Colors.white
                  : isCurrentPage
                      ? activeTextColor ?? activeColor
                      : inactiveTextColor ?? inactiveColor?.withAlpha(128),
            ),
            backgroundColor: Colors.transparent,
            foregroundColor: isCurrentPage
                ? (type == MPageType.filled
                    ? activeTextColor ?? Colors.white
                    : activeTextColor ?? activeColor?.darken())
                : inactiveTextColor ?? inactiveColor?.withAlpha(128),
            disabledForegroundColor: isCurrentPage
                ? (type == MPageType.filled
                    ? activeTextColor ?? Colors.white
                    : activeTextColor ?? activeColor?.darken())
                : inactiveTextColor ?? inactiveColor?.withAlpha(128),
          ),
          onPressed: isCurrentPage ? null : () => onPageChanged(pageIndex),
          child: Text(
            pageIndex.toString(),
          ),
        ),
      ),
    );
  }

  /// Helper method to build the next/previous icon button.
  /// [icon] is the icon to be displayed (next/previous), [isNext] indicates whether it's the 'next' button.
  Widget _buildIconButton(IconData icon, bool isNext) {
    return SizedBox(
      height: buttonSize,
      width: buttonSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: type == MPageType.filled
              ? inactiveColor?.withAlpha(50)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          border: type == MPageType.outlined
              ? Border.all(color: inactiveColor!.withAlpha(59))
              : null,
        ),
        child: IconButton(
          style: IconButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: Colors.transparent,
            foregroundColor: inactiveTextColor ?? inactiveColor?.withAlpha(128),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          padding: EdgeInsets.zero,
          onPressed: isNext
              ? () => onPageChanged(currentPage + 1)
              : () => onPageChanged(currentPage - 1),
          icon: Icon(
            icon,
            size: iconSize,
            color: inactiveTextColor ?? inactiveColor?.withAlpha(128),
          ),
        ),
      ),
    );
  }

  /// Builds the widget tree for the pagination control.
  @override
  Widget build(BuildContext context) {
    final range = _calculatePageRange();
    final startPage = range[0];
    final endPage = range[1];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (currentPage > 1) ...[
            _buildIconButton(Icons.arrow_back_ios_new_rounded, false),
            SizedBox(width: iconGap),
          ],
          if (startPage > (visiblePageCount / 2) + 1) ...[
            _buildPageButton(1, false),
            SizedBox(width: iconGap),
            Text('...',
                style: fontStyle?.copyWith(
                    color: inactiveTextColor ?? inactiveColor?.withAlpha(128))),
            SizedBox(width: iconGap),
          ],
          ...List.generate(endPage - startPage + 1, (index) {
            int pageIndex = startPage + index;
            return Row(
              children: [
                _buildPageButton(pageIndex, pageIndex == currentPage),
                if (pageIndex != endPage) SizedBox(width: iconGap),
              ],
            );
          }),
          if (endPage < totalPages) ...[
            SizedBox(width: iconGap),
            Text('...',
                style: fontStyle?.copyWith(
                    color: inactiveTextColor ?? inactiveColor?.withAlpha(128))),
            SizedBox(width: iconGap),
            _buildPageButton(totalPages, false),
          ],
          if (currentPage < totalPages) ...[
            SizedBox(width: iconGap),
            _buildIconButton(Icons.arrow_forward_ios_rounded, true),
          ],
        ],
      ),
    );
  }
}


extension ColorExtensions on Color {
  Color darken([double amount = 0.1]) {
    // Ensure amount is within valid range
    assert(amount >= 0 && amount <= 1, 'Amount should be between 0 and 1');

    // Convert color to HSV, which makes it easier to adjust brightness
    final hsvColor = HSVColor.fromColor(this);

    // Calculate new value (brightness) of the color
    final newValue = (hsvColor.value - amount).clamp(0.0, 1.0);

    // Return new color with adjusted brightness
    return hsvColor.withValue(newValue).toColor();
  }
}

enum MPageType { outlined, filled }