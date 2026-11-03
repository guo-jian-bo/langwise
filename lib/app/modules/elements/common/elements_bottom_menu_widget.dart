
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../theme/theme.dart';
import '../model/elements_menu_model.dart';

enum ElementsBottomMenuType {
  /// 升卡
  upgradeCard,
  /// 集卡
  collectCard,
  /// 斗智
  battle,
  /// 奖杯
  cup,
}

class ElementsBottomMenuWidget extends StatefulWidget {
  final void Function(ElementsBottomMenuType type)? onTap;
  const ElementsBottomMenuWidget({super.key, this.onTap});

  @override
  State<ElementsBottomMenuWidget> createState() => _ElementsBottomMenuWidgetState();
}

class _ElementsBottomMenuWidgetState extends State<ElementsBottomMenuWidget> {
  final List<ElementsMenuModel> menuList = [
    ElementsMenuModel(name: "升卡", svgIcon: "assets/svg/elements/icon_upgrade_card.svg", index: 0),
    ElementsMenuModel(name: "集卡", svgIcon: "assets/svg/elements/icon_collect_card.svg", index: 1),
    // ElementsMenuModel(name: "斗智", svgIcon: "assets/svg/elements/icon_battle.svg", index: 2),
    // ElementsMenuModel(name: "奖杯", svgIcon: "assets/svg/elements/icon_cup.svg", index: 3),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76.wMin,
      padding: EdgeInsets.symmetric(horizontal: 32.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999.wMin),
        color: AppTheme.cFeedbackInfoIcon,
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: menuList.length,
        itemBuilder: (context, index) {
          return _buildMenuItem(index);
        },
        separatorBuilder: (context, index) {
          return SizedBox(width: 16.wMin);
        },
      ),
    );
  }

  Widget _buildMenuItem(int index){
    return TapScaleWidget(
      onTap: () {
        if(index == 0){
          widget.onTap?.call(ElementsBottomMenuType.upgradeCard);
        }else if(index == 1){
          widget.onTap?.call(ElementsBottomMenuType.collectCard);
        }else if(index == 2){
          widget.onTap?.call(ElementsBottomMenuType.battle);
        }else if(index == 3){
          widget.onTap?.call(ElementsBottomMenuType.cup);
        }
      },
      sclae: 1.05,
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 8.wMin),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              menuList[index].svgIcon,
              width: 32.wMin,
              height: 32.wMin,
            ),
            Text(
              menuList[index].name,
              style: TextStyle(
                fontSize: 20.wMin,
                color: AppTheme.cStaticWhite,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}