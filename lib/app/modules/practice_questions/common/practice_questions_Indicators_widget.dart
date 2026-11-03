import 'package:flutter/material.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

class PracticeQuestionsIndicatorsData{
  /// 是否已经完成过
  bool isFinish;
  /// 是否正确
  String? result;
  GlobalKey key;
  String? purpose;
  PracticeQuestionsIndicatorsData({
    this.isFinish = false,
    required this.key,
    this.purpose,
    this.result,
  });
}

class PracticeQuestionsIndicatorsWidget extends StatefulWidget {
  final int current;
  final List<PracticeQuestionsIndicatorsData> list;
  final ScrollController? scrollController;
  final double paddingLeft;
  const PracticeQuestionsIndicatorsWidget({super.key, required this.current, required this.list, this.scrollController, this.paddingLeft = 0});

  @override
  State<PracticeQuestionsIndicatorsWidget> createState() => _PracticeQuestionsIndicatorsWidgetState();
}

class _PracticeQuestionsIndicatorsWidgetState extends State<PracticeQuestionsIndicatorsWidget> {


  @override
  Widget build(BuildContext context) {

    Widget buildItem(int index){
      LearnTypeColors bgBorderColor = StatusUtils.getLearnTypeColor(
        widget.list[index].purpose??'', 
        result: widget.list[index].result,
        isCurrent: widget.current == index,
      );
      
      String value = widget.list[index].purpose??'';
      if(value.isNotEmpty){
        value = value.substring(0, 1);
      }

      return Transform.scale(
        scale: widget.current == index ? 1.15 : 1,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 5.wMin),
          key: widget.list[index].key,
          alignment: Alignment.center,
          child: AnimatedContainer(
            width: 50.wMin,
            height: 50.wMin,
            alignment: Alignment.center,
            duration: const Duration(milliseconds: 200),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40.wMin,
              height: 40.wMin,
              padding: EdgeInsets.only(top: 1.wMin),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: bgBorderColor.statusBgColor,
                border: Border.all(
                  color: bgBorderColor.statusBorderColor,
                  width: 3.wMin,
                ),
                boxShadow: [
                  BoxShadow(
                    color: bgBorderColor.shadowTypeColor,
                    blurRadius: 2.wMin,
                    spreadRadius: 5.wMin,
                  ),
                ],
              ),
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.cStaticWhite.color,
                  fontSize: 28.wMin,
                  fontWeight: FontWeight.w800,
                  fontFamily: "LangWiseFont",
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      alignment: Alignment.center,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          scrollbars: false, // 隐藏所有滚动条
        ),
        child: SingleChildScrollView(
          controller: widget.scrollController,
          padding: EdgeInsets.only(
            top: 8.wMin,
            bottom: 8.wMin,
            left: MediaQuery.of(context).padding.left + widget.paddingLeft,
          ),
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            children: List.generate(widget.list.length, (index){
              return buildItem(index);
            }),
          ),
        ),
      ),
    );
  }
}