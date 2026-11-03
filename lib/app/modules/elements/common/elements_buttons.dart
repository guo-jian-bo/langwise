import 'package:flutter/material.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';


class ElementsButtons extends StatelessWidget {
  final String button1;
  final bool showButton1;
  final String button2;
  final void Function()? onTap1;
  final void Function()? onTap2;
  
  const ElementsButtons({
    super.key, 
    this.button1 = "换一组", 
    this.button2 = "开始升卡", 
    this.showButton1 = true, 
    this.onTap1, 
    this.onTap2,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){},
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.wMin),
        child: PlatformBackdropFilterWidget(
          sigmaX: 20.wMin,
          sigmaY: 20.wMin,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 28.wMin, vertical: 24.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.wMin),
              color: const Color(0xffffffff).withValues(alpha: 0.2),
              border: Border.all(width: 0.75.wMin, color: const Color(0xff000000).withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Visibility(
                  visible: showButton1,
                  child: Container(
                    margin: EdgeInsets.only(right: 8.wMin),
                    child: ButtonWidget(
                      text: button1,
                      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 8.wMin),
                      color: const Color(0xff000000).withValues(alpha: 0.04),
                      borderRadius: 12.wMin,
                      fontSize: 24.wMin,
                      fontColor: const Color(0xff000000),
                      sclae: 1.03,
                      onTap: onTap1,
                    ),
                  ),
                ),
                
                ButtonWidget(
                  text: button2,
                  padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 8.wMin),
                  color: const Color(0xffffffff).withValues(alpha: 0.4),
                  borderRadius: 12.wMin,
                  fontSize: 24.wMin,
                  fontColor: const Color(0xffffffff),
                  sclae: 1.03,
                  onTap: onTap2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}