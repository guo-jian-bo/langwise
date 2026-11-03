
import 'package:draggable_float_widget/draggable_float_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../theme/theme.dart';
import '../../theme/theme_utils.dart';
import '../public_controller/mv_player_global_float_controller.dart';

class MvPlayerGlobalFloatWidget extends GetView<MvPlayerGlobalFloatController> {
  /// 全局悬浮窗 音乐播放
  const MvPlayerGlobalFloatWidget({super.key});

  @override
  Widget build(BuildContext context) {

    return Obx((){
      return DraggableFloatWidget(
        key: ValueKey(controller.windowSize.value),
        width: 200.wMin,
        height: 136.wMin,
        config: DraggableFloatWidgetBaseConfig(
          initPositionYInTop: false,
          initPositionXInLeft: true,
          delayShowDuration: const Duration(milliseconds: 200),
          animDuration: const Duration(milliseconds: 200),
          borderRight: 10.wMin,
          borderLeft: 10.wMin,
          borderTop: 10.wMin,
          borderBottom: 10.wMin + MediaQuery.of(context).padding.bottom,
          initPositionYMarginBorder: 200.wMin + MediaQuery.of(context).padding.bottom,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: _buildBodyWidget(),
        ),
      );
    });
  }



  Widget _buildBodyWidget(){
    Color borderColor = Colors.white.withValues(alpha: 0.04);
    Color bgColor = const Color.fromRGBO(53, 56, 60, 0.98);
    Color shadowColor = Colors.black.withValues(alpha: 0.1);

    bool isLight = ThemeUtils.isCurrentTheme(AppThemeKey.light.value);
    if(isLight){
      borderColor = Colors.black.withValues(alpha: 0.04);
      bgColor = const Color.fromRGBO(255, 255, 255, 0.98);
      shadowColor = Colors.black.withValues(alpha: 0.1);
    }

    return Obx((){
      if (!controller.isShowFloatButton.value) return const SizedBox();
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(8.wMin),
        decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
          color: bgColor,
          border: Border.all(color: borderColor, width: 1.wMin),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 2.wMin,
            ),
          ],
        ),
        child: Row(
          spacing: 6.wMin,
          children: [
            _buildFilmImgaeWidget(),
            _buildCloseWidget(),
          ],
        ),
      );
    });
  }

  Widget _buildFilmImgaeWidget(){
    return AspectRatio(
      aspectRatio: 1,
      child: TapScaleWidget(
        onTap: OptimizeUtils.noneThrottle(() {
          controller.navigateToMvDetail();
        }, 500),
        sclae: 1,
        child: Stack(
          children: [
            RotationTransitionWidget(
              duration: const Duration(seconds: 15),
              controller: controller.rotationTransitionController,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.cBgTertiary.color,
                  image: const DecorationImage(
                    image: AssetImage("assets/images/public/cd_bg.webp"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  width: 82.wMin,
                  height: 82.wMin,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.cStaticWhite.color.withValues(alpha: 0.48),
                        blurRadius: 10.wMin,
                        spreadRadius: 0.3.wMin,
                        blurStyle: BlurStyle.inner,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Container(
                      color: Colors.black,
                      child: Obx((){
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: CachedImageWidget(
                            controller.mvImageUrl.value,
                            key: ValueKey(controller.mvImageUrl.value),
                            errorWidget: Container(),
                            placeholder: Container(),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Obx((){
                return CircularProgressIndicator(
                  value: controller.progress.value,
                  strokeWidth: 5.wMin,
                  backgroundColor: AppTheme.cStaticWhite.withValues(alpha: 0.4),
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.cStaticWhite.color),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
  

  Widget _buildCloseWidget(){
    return Container(
      alignment: Alignment.center,
      child: TapScaleWidget(
        onTap: OptimizeUtils.noneThrottle(() {
          controller.stop();
        }, 500),
        borderRadius: 999,
        sclae: 1.1,
        child: Container(
          width: 50.wMin,
          height: 50.wMin,
          alignment: Alignment.center,
          child: SvgPicture.asset(
            "assets/svg/public/x.svg",
            width: 32.wMin,
          ),
        ),
      ),
    );
  }
  



}

