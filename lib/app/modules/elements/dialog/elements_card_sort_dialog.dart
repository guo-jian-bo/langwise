
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:themed/themed.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/enum/enum.dart';
import '../../../../theme/theme.dart';


class ElementsCardSortDialogIconWidget extends StatefulWidget {
  final List<NameValueModel> sortList;
  final NameValueModel? initSort;
  final bool? initIsAsc;
  final void Function(NameValueModel sort, bool isAsc)? onSort;
  const ElementsCardSortDialogIconWidget({
    super.key, 
    this.onSort, 
    this.initSort, 
    this.initIsAsc,
    required this.sortList,
  });

  @override
  State<ElementsCardSortDialogIconWidget> createState() => _ElementsCardSortDialogIconWidgetState();
}

class _ElementsCardSortDialogIconWidgetState extends State<ElementsCardSortDialogIconWidget> {
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return TapScaleWidget(
          sclae: 1.1,
          onTap: () async{
            if(Platform.isIOS){
              await Future.delayed(const Duration(milliseconds: 350));
            }
            
            BotToast.showAttachedWidget(
              targetContext: context,
              preferDirection: PreferDirection.bottomLeft,
              attachedBuilder: (cancelFunc) {
                return ElementsCardSortDialogIconBodyWidget(
                  initSort: widget.initSort,
                  initIsAsc: widget.initIsAsc,
                  onSort: widget.onSort,
                  sortList: widget.sortList,
                  cancelFunc: cancelFunc,
                );
              },
            );
          },
          child: Container(
            width: 54.wMin,
            height: 54.wMin,
            color: Colors.transparent,
            alignment: Alignment.center,
            child: SvgPicture.asset(
              "assets/svg/elements/icon_sort.svg",
              width: 40.wMin,
              height: 40.wMin,
              colorFilter: const ColorFilter.mode(AppTheme.cTextPrimary, BlendMode.srcIn),
            ),
          ),
        );
      },
    );
  }
}

class ElementsCardSortDialogIconBodyWidget extends StatefulWidget {
  final List<NameValueModel> sortList;
  final NameValueModel? initSort;
  final bool? initIsAsc;
  final void Function(NameValueModel sort, bool isAsc)? onSort;
  final void Function() cancelFunc;
  final bool showDescAsc;
  const ElementsCardSortDialogIconBodyWidget({
    super.key, 
    this.onSort, 
    required this.cancelFunc, 
    this.initSort, 
    this.initIsAsc,
    this.showDescAsc = true,
    required this.sortList,
  });

  @override
  State<ElementsCardSortDialogIconBodyWidget> createState() => _ElementsCardSortDialogIconBodyWidgetState();
}

class _ElementsCardSortDialogIconBodyWidgetState extends State<ElementsCardSortDialogIconBodyWidget> with WidgetsBindingObserver{


  NameValueModel? sortData;

  int isAsc = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    sortData = widget.initSort;
    isAsc = (widget.initIsAsc??true) ? 0 : 1;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if(Platform.isLinux || Platform.isWindows || Platform.isMacOS){
      widget.cancelFunc();
    }
  }


  @override
  Widget build(BuildContext context) {
   return Container(
      width: 400.wMin,
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cBgTertiary.color,
        borderRadius: BorderRadius.circular(16.wMin),
        boxShadow: [
          BoxShadow(
            color: AppTheme.cDark.color,
            blurRadius: 4.wMin,
            offset: Offset(0, 2.wMin),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "排序方式",
            style: TextStyle(
              fontSize: 28.wMin,
              color: AppTheme.cTextPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16.wMin),
          Column(
            children: List.generate(
              widget.sortList.length,
              (index) => _buildTextItemWidget(widget.sortList[index]),
            ),
          ),

          Visibility(
            visible: widget.showDescAsc,
            child: Container(
              margin: EdgeInsets.only(top: 16.wMin),
              width: 360.wMin,
              padding: EdgeInsets.all(4.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.wMin),
                color:AppTheme.cBgQuaternary,
              ),
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    alignment: isAsc == 0 ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      width: 180.wMin,
                      height: 50.wMin,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.wMin),
                        color:AppTheme.cBgTertiary,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      _buildSortItemWidget(0),
                      _buildSortItemWidget(1),
                    ],
                  ),
                ],
              ),
            
            ),
          ),
          
        ],
      ),
    );
  }

  Widget _buildSortItemWidget(int index){
    return Expanded(
      child: TapScaleWidget(
        onTap: () {
          if(sortData == null) return;
          isAsc = index;
          setState(() {});
          widget.onSort?.call(sortData!, index == 0);
        },
        sclae: 1,
        child: Container(
          height: 50.wMin,
          alignment: Alignment.center,
          color: Colors.transparent,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 100),
            style: TextStyle(
              fontSize: 24.wMin,
              color: isAsc == index ? AppTheme.cFeedbackInfoText : AppTheme.cFeedbackDefaultText,
              fontWeight: FontWeight.w500,
            ),
            child: Text(index == 0 ? "升序" : "降序"),
          ),
        ),
      ),
    );
  }

  Widget _buildTextItemWidget(NameValueModel sort){
    return TapScaleWidget(
      sclae: 1,
      onTap: () {
        sortData = sort;
        setState(() {});
        widget.onSort?.call(sortData!, isAsc == 0);
      },
      child: AnimatedContainer(
        width: double.infinity,
        duration: const Duration(milliseconds: 100),
        height: 50.wMin,
        padding: EdgeInsets.symmetric(horizontal: 8.wMin),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          color:AppTheme.cBgQuaternary.addOpacity(sort.value == sortData?.value ? 1 : 0),
        ),
        child: Text(
          sort.name,
          style: TextStyle(
            fontSize: 24.wMin,
            color: AppTheme.cTextSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

}