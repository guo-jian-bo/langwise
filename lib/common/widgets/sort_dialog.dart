import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../static/static_data.dart';

class SortDialogResult {
  /// 排序策略
  StaticDataEntity? basis;

  /// 升序/降序
  StaticDataEntity? sort;

  /// sortList选择的下标
  int selectBasisIndex;

  /// 升序降序下标
  int selectSortIndex;

  SortDialogResult({
    this.sort,
    this.basis,
    this.selectBasisIndex = 0,
    this.selectSortIndex = 0,
  });
}

/// 排序弹窗
class SortDialog {
  static void show({
    required BuildContext context,
    required List<StaticDataEntity> basisList,
    SortDialogResult? init,
    double? itemWidth,
    void Function(SortDialogResult data)? onSort,
  }) {
    BotToast.showAttachedWidget(
      targetContext: context,
      preferDirection: PreferDirection.bottomLeft,
      verticalOffset: 8.0,
      allowClick: false,
      onlyOne: true,
      attachedBuilder: (cancelFunc) {
        return _SortDialogWidget(
          cancelFunc: cancelFunc,
          onSort: onSort,
          itemWidth: itemWidth,
          basisList: basisList,
          init: init,
        );
      },
    );
  }
}

class _SortDialogWidget extends StatefulWidget {
  final List<StaticDataEntity> basisList;
  final SortDialogResult? init;
  final void Function() cancelFunc;
  final double? itemWidth;
  final void Function(SortDialogResult data)? onSort;

  const _SortDialogWidget({
    required this.basisList,
    required this.cancelFunc,
    this.onSort,
    this.itemWidth,
    this.init,
  });

  @override
  State<_SortDialogWidget> createState() => __SortDialogWidgetState();
}

class __SortDialogWidgetState extends State<_SortDialogWidget> {
  int selectBasisIndex = 0;
  int selectSortIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.init != null) {
      selectBasisIndex = widget.init?.selectBasisIndex ?? 0;
      selectSortIndex = widget.init?.selectSortIndex ?? 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget buildTextList() {
      return Column(
        spacing: 8.wMin,
        children: List.generate(widget.basisList.length, (index) {
          return TapScaleWidget(
            onTap: () {
              selectBasisIndex = index;
              if (mounted) setState(() {});
              widget.onSort?.call(SortDialogResult(
                sort: StaticData.sortList[selectSortIndex],
                basis: widget.basisList[selectBasisIndex],
                selectBasisIndex: selectBasisIndex,
                selectSortIndex: selectSortIndex,
              ));
            },
            sclae: 1.03,
            child: Container(
              width: widget.itemWidth ?? 116.wMin,
              height: 40.wMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selectBasisIndex == index
                    ? const Color(0xff2388FF).withValues(alpha: 0.2)
                    : const Color(0xff41465A).withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(4.wMin),
                border: Border.all(
                  width: 1.wMin,
                  color: selectBasisIndex == index
                      ? const Color(0xff2388FF).withValues(alpha: 0.8)
                      : Colors.transparent,
                ),
              ),
              child: Text(
                widget.basisList[index].name,
                style: TextStyle(
                  fontSize: 14.wMin,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          );
        }),
      );
    }

    Widget buildSortTextList() {
      return Column(
        spacing: 8.wMin,
        children: List.generate(StaticData.sortList.length, (index) {
          return TapScaleWidget(
            onTap: () {
              selectSortIndex = index;
              if (mounted) setState(() {});
              widget.onSort?.call(SortDialogResult(
                sort: StaticData.sortList[selectSortIndex],
                basis: widget.basisList[selectBasisIndex],
                selectBasisIndex: selectBasisIndex,
                selectSortIndex: selectSortIndex,
              ));
            },
            sclae: 1.03,
            child: Container(
              width: widget.itemWidth ?? 116.wMin,
              height: 40.wMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selectSortIndex == index
                    ? const Color(0xff2388FF).withValues(alpha: 0.2)
                    : const Color(0xff41465A).withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(4.wMin),
                border: Border.all(
                  width: 1.wMin,
                  color: selectSortIndex == index
                      ? const Color(0xff2388FF).withValues(alpha: 0.8)
                      : Colors.transparent,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Visibility(
                    visible: StaticData.sortList[index].svg != null,
                    child: Container(
                      margin: EdgeInsets.only(right: 6.wMin),
                      child: SvgPicture.asset(
                        StaticData.sortList[index].svg ?? "",
                        width: 20.wMin,
                        height: 20.wMin,
                      ),
                    ),
                  ),
                  Text(
                    StaticData.sortList[index].name,
                    style: TextStyle(
                      fontSize: 14.wMin,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      );
    }

    return Container(
      // width: 396.ww,
      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: const Color(0xff2B2F3C).withValues(alpha: 0.95),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "排序依据",
            style: TextStyle(
              fontSize: 18.wMin,
              color: const Color(0xffEBEEF3),
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 10.wMin),
          buildTextList(),
          SizedBox(height: 20.wMin),
          Text(
            "排序",
            style: TextStyle(
              fontSize: 18.wMin,
              color: const Color(0xffEBEEF3),
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 10.wMin),
          buildSortTextList(),
        ],
      ),
    );
  }
}
