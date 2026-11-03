

import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';

class ElemenetsCardStarLevelWidget extends StatelessWidget {
  final ElementsCardStar? star;
  final double? fontSize;
  final bool hideStar;
  const ElemenetsCardStarLevelWidget({super.key, this.star, this.fontSize, this.hideStar = false});

  @override
  Widget build(BuildContext context) {
  
    return Row(
      children: [
        SizedBox(
          width: 35.wMin,
          height: 46.wMin,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: -2.wMin,
                left: 8.wMin,
                width: 35.wMin,
                child: Visibility(
                  visible: star?.iconUrl != null && star?.iconUrl?.trim() != "",
                  child: Image.network(
                    star?.iconUrl??"",
                    errorBuilder: (context, error, stackTrace) => Container(),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Visibility(
          visible: !hideStar,
          child: Row(
            spacing: 2.wMin,
            children: List.generate(5, (index) {
              if(index < (star?.star??0)){
                return const ShadowStarWidget();
              }
              return Image.asset(
                "assets/images/elements/icon_star_un.webp", 
                width: 22.wMin,
                color: AppTheme.cBgQuaternary,
              );
            }),
          ),
        ),
      ],
    );
  }
}
