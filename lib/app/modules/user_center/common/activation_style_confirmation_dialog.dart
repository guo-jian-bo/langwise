import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';

class SctivationStyleConfirmationDialog{

  static Future<bool> show({
    required BuildContext context,
    required String localeTitle,
    required VisualStyleEntityImageStyles data,
  }) async{
    bool? res = await showCupertinoDialog<bool?>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return SctivationStyleConfirmationDialogWidget(
          localeTitle: localeTitle,
          data: data,
        );
      },
    );

    return res??false;
  }

}

class SctivationStyleConfirmationDialogWidget extends StatefulWidget {
  final String localeTitle;
  final VisualStyleEntityImageStyles data;
  const SctivationStyleConfirmationDialogWidget({super.key, required this.localeTitle, required this.data});

  @override
  State<SctivationStyleConfirmationDialogWidget> createState() => _SctivationStyleConfirmationDialogWidgetState();
}

class _SctivationStyleConfirmationDialogWidgetState extends State<SctivationStyleConfirmationDialogWidget> {

  @override
  Widget build(BuildContext context) {

    String imageUrl = "";
    if((widget.data.imageUrl??[]).isNotEmpty){
      imageUrl = widget.data.imageUrl!.first??"";
    }


    return Material(
      color: AppTheme.cOverlayBackground,
      child: Center(
        child: Container(
          width: 640.wMin,
          padding: EdgeInsets.all(40.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.wMin),
            color: AppTheme.cBgSecondary,
            border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "确认激活",
                style: TextStyle(
                  fontSize: 28.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16.wMin),
              Container(
                padding: EdgeInsets.all(8.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.wMin),
                  color: AppTheme.cSurfaceTertiary,
                ),
                child: Row(
                  spacing: 16.wMin,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6.wMin),
                      child: Container(
                        width: 120.wMin,
                        height: 120.wMin,
                        color: AppTheme.cWhiteAlpha10,
                        child: CachedImageWidget(
                          imageUrl,
                          errorWidget: Container(),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.localeTitle,
                            style: TextStyle(
                              fontSize: 28.wMin,
                              color: AppTheme.cTextPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            widget.data.styleTitle??"",
                            style: TextStyle(
                              fontSize: 24.wMin,
                              color: AppTheme.cTextPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "将消耗1张视觉风格激活券",
                            style: TextStyle(
                              fontSize: 18.wMin,
                              color: AppTheme.cTextTertiary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.wMin),
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Text(
                      "激活后，您可以在课程中使用此视觉风格。",
                      style: TextStyle(
                        fontSize: 20.wMin,
                        color: AppTheme.cTextSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "确认要激活吗？",
                      style: TextStyle(
                        fontSize: 24.wMin,
                        color: AppTheme.cTextPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40.wMin),
              Row(
                spacing: 18.wMin,
                children: [
                  Expanded(
                    child: ButtonWidget(
                      text: "取消",
                      sclae: 1.03,
                      color: AppTheme.cBgTertiary,
                      borderRadius: 8.wMin,
                      height: 56.wMin,
                      fontSize: 20.wMin,
                      fontColor: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w500,
                      onTap: () => Get.back(result: false),
                    ),
                  ),
                  Expanded(
                    child: ButtonWidget(
                      text: "确认激活",
                      sclae: 1.03,
                      color: AppTheme.cSurfaceBrand,
                      borderRadius: 8.wMin,
                      height: 56.wMin,
                      fontSize: 20.wMin,
                      fontColor: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w500,
                      onTap: () {
                        Get.back(result: true);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}