
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/widgets/widgets.dart';

class ManageDialogBoxWidget extends StatelessWidget {
  final Widget? child;
  final String? title;
  final double? width;
  final Function()? onConfirm;
  final Function()? onCancel;
  final String confirmText;
  final String cancelText;
  const ManageDialogBoxWidget({
    super.key, 
    this.child,
    this.title,
    this.width,
    this.onConfirm,
    this.onCancel,
    this.confirmText = "确定",
    this.cancelText = "取消",
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cOverlayBackground.color,
      child: Center(
        child: Container(
          width: width ?? 1000.wMin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.wMin),
            color: AppTheme.cSurfaceSecondary.color,
            border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 24.wMin),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24.wMin),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Visibility(
                      visible: title != null,
                      child: Expanded(
                        child: Text(
                          title ?? '',
                          style: TextStyle(
                            fontSize: 24.wMin,
                            color: AppTheme.cTextPrimary.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    
                    TapScaleWidget(
                      sclae: 1.05,
                      onTap: () => Get.back(),
                      child: Container(
                        width: 42.wMin,
                        height: 42.wMin,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.cSurfaceTertiary.color,
                        ),
                        child: SvgPicture.asset(
                          "assets/svg/public/x.svg",
                          width: 24.wMin,
                          height: 24.wMin,
                        ),
                      ),
                    ),
                
                  ],
                ),
              ),
              SizedBox(height: 10.wMin),
              SizedBox(child: child),
              _buildButtonsWidget(),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildButtonsWidget(){

    if(onCancel == null && onConfirm == null) return const SizedBox();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.wMin),
      margin: EdgeInsets.only(bottom: 24.wMin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
      
            Visibility(
              visible: onCancel != null,
              child: ButtonWidget(
                text: cancelText,
                padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 8.wMin),
                onTap: onCancel,
                borderRadius: 8.wMin,
                sclae: 1.05,
                color: Colors.transparent,
                border: Border.all(width: 2.wMin, color: AppTheme.cBorderPrimary.color),
                fontColor: AppTheme.cTextSecondary.color,
                fontSize: 20.wMin,
              ),
            ),

            Visibility(
              visible: onConfirm != null,
              child: Container(
                margin: EdgeInsets.only(left: 24.wMin),
                child: ButtonWidget(
                  text: confirmText,
                  padding: EdgeInsets.symmetric(horizontal: 48.wMin, vertical: 8.wMin),
                  borderRadius: 8.wMin,
                  sclae: 1.03,
                  color: AppTheme.cSurfaceBrand.color,
                  fontColor: AppTheme.cInverseTextLight.color,
                  fontSize: 20.wMin,
                  onTap: OptimizeUtils.noneThrottle(() {
                    onConfirm?.call();
                  }, 300),
                ),
              ),
            ),
      
        ],
      ),
    );
  }


}