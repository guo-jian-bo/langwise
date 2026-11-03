

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/theme/theme_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/widgets/starsview/config/MeteoriteConfig.dart';
import '../../../../common/widgets/starsview/config/StarsConfig.dart';
import '../../../../common/widgets/starsview/starsview.dart';
import '../../../../theme/theme.dart';

class StarryBackgroundWidget extends StatefulWidget {
  final Widget child;
  /// 星空背景
  const StarryBackgroundWidget({super.key, required this.child});

  @override
  State<StarryBackgroundWidget> createState() => _StarryBackgroundWidgetState();
}

class _StarryBackgroundWidgetState extends State<StarryBackgroundWidget> {
  double _xOffset = 0;
  double _yOffset = 0;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerMove: (event) {
        if(Platform.isAndroid || Platform.isIOS) return;
        _xOffset = (event.position.dx - MediaQuery.of(context).size.width / 2);
        _yOffset = (event.position.dy - MediaQuery.of(context).size.height / 2);
        if(mounted) setState(() {});
      },
      child: MouseRegion(
        onHover: (event) {
          if(Platform.isAndroid || Platform.isIOS) return;
          _xOffset = (event.position.dx - MediaQuery.of(context).size.width / 2);
          _yOffset = (event.position.dy - MediaQuery.of(context).size.height / 2);
          if(mounted) setState(() {});
        },
      
        child: Container(
          color: AppTheme.cBgPrimary.color,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildStarryBackground(),
              widget.child,
            ],
          ),
        ),
      ),
    );
  }

  /// 星空背景
  Widget _buildStarryBackground() {
    
    Color starColor = AppTheme.cStaticWhite.color;
    String bgImg = "assets/images/practice_questions/bg_misson-dark.webp";
    if(ThemeUtils.isCurrentTheme(AppThemeKey.light.value)){
      starColor = AppTheme.cFeedbackInfoIcon.color.withValues(alpha: 0.2);
      bgImg = "assets/images/practice_questions/bg_misson-light.webp";
    }

    StarsConfig starsConfig = StarsConfig(
      starCount: 20, 
      colors: [starColor],
      minStarSize: 1.wMin,
      maxStarSize: 3.wMin,
    );

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(bgImg, fit: BoxFit.cover),
        ),
        Positioned.fill(
          child: Transform.translate(
            offset: Offset(_xOffset * 0.05, _yOffset * 0.05),
            child: StarsView(
              starsConfig: starsConfig,
              meteoriteConfig: const MeteoriteConfig(enabled: false),
            ),
          ),
        ),
        Positioned.fill(
          child: Transform.translate(
            offset: Offset(_xOffset * 0.01, _yOffset * 0.01),
            child: StarsView(
              starsConfig: starsConfig,
              meteoriteConfig: const MeteoriteConfig(enabled: false),
            ),
          ),
        ),
        Positioned.fill(
          child: Transform.translate(
            offset: Offset(_xOffset * 0.005, _yOffset * 0.005),
            child: StarsView(
              starsConfig: starsConfig,
              meteoriteConfig: const MeteoriteConfig(enabled: false),
            ),
          ),
        ),
        Positioned(
          top: 180.wMin,
          left: 100.wMin,
          child: Transform.translate(
            offset: Offset(_xOffset * 0.01, _yOffset * 0.01),
            child: SvgPicture.asset(
              "assets/svg/practice_questions/icon_meteor.svg",
              width: 134.wMin,
            ),
          ),
        ),
        StarsView(
          starsConfig: starsConfig,
          meteoriteConfig: MeteoriteConfig(
            minMeteoriteSize: 0.1.wMin,
            maxMeteoriteSize: 0.2.wMin,
            minMeteoriteSpeed: 18.0,
            maxMeteoriteSpeed: 20.0,
            colors: [
              const Color(0xffBFEBFF),
              const Color(0xff0EA5E9),
            ],
          ),
        ),
        
      ],
    );
  }


}
