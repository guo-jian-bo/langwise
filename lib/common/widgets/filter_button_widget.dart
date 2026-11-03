

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'widgets.dart';


class FilterButtonCondition{
  String? name;
  String? value;
  bool isClose;
  Color? color;
  void Function()? onClear;

  FilterButtonCondition({this.name, this.value, this.color, this.isClose = true, this.onClear});
}

class FilterButtonWidget extends StatelessWidget {
  final List<FilterButtonCondition>? filters;
  final void Function()? onTap;
  /// 筛选按钮
  const FilterButtonWidget({super.key, this.onTap, this.filters});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72.wMin,
      padding: EdgeInsets.only(left: 8.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: const Color(0xff1D2021).withValues(alpha: 0.95),
        border:  Border.all(width: 1.wMin, color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
        
            TapScaleWidget(
              onTap: onTap,
              sclae: 1.03,
              child: Container(
                width: 56.wMin,
                height: 56.wMin,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  "assets/svg/manage/icon_filter.svg",
                  width: 24.wMin,
                  height: 24.wMin,
                ),
              ),
            ),
        
            Container(
              constraints: BoxConstraints(
                maxWidth: 1000.wMin,
                minWidth: 500.wMin,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 8.wMin),
                child: Row(
                  spacing: 16.wMin,
                  children: List.generate(filters?.length??0, (index){
                    return Container(
                      height: 56.wMin,
                      padding: EdgeInsets.only(left: 16.wMin, right: 8.wMin),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: filters?[index].color?.withValues(alpha: 0.12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            filters?[index].name??"",
                            style: TextStyle(
                              fontSize: 24.wMin,
                              color: filters?[index].color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Visibility(
                            visible: filters?[index].isClose??true,
                            child: TapScaleWidget(
                              sclae: 1.03,
                              onTap: (){
                                if(filters?[index] == null) return;
                                filters?[index].onClear?.call();
                              },
                              child: Container(
                                width: 32.wMin,
                                height: 32.wMin,
                                alignment: Alignment.center,
                                child: SvgPicture.asset(
                                  "assets/svg/public/x.svg",
                                  width: 24.wMin,
                                  height: 24.wMin,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
        
        
        
          ],
        ),
      ),
    );
  }

}

class FilterConditionData{
  String title;
  List<FilterConditionItem> conditions;
  bool isSingle;
  int crossAxisCount;

  FilterConditionData({
    required this.title,
    required this.conditions,
    this.isSingle = false,
    this.crossAxisCount = 3,
  });
}

class FilterConditionItem{
  String name;
  dynamic value;
  bool selected;
  Color? color;

  FilterConditionItem({
    required this.name,
    required this.value,
    this.selected = false,
    this.color,
  });
}
