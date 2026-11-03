

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../common/commons.dart';
import '../controllers/manage_script_theme_controller.dart';
import '../models/manage_script_theme_model.dart';

class ManageScriptThemeListCardWidget extends StatelessWidget {
  final ManageScriptThemeController controller;
  final int index;
  final ManageScriptThemeModel data;
  const ManageScriptThemeListCardWidget({super.key, required this.controller, required this.index, required this.data});

  @override
  Widget build(BuildContext context) {
    return TapScaleWidget(
      onTap: () {
        controller.selectLeftTheme(context, index);
      },
      sclae: 1.001,
      child: Obx((){
        bool selected = controller.currentIndex.value == index;
        return Container(
          padding: EdgeInsets.all(16.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.wMin),
            color: Colors.transparent,
            border: Border.all(
              width: 1.wMin, 
              color: selected ? const Color(0xff8E51FF) : AppTheme.cBorderPrimary.color,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
        
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
        
                  Expanded(
                    child: Text(
                      data.zhNameInput.text.isNotEmpty ? data.zhNameInput.text : "未命名主题",
                      style: TextStyle(
                        fontSize: 18.wMin,
                        color: AppTheme.cTextPrimary.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
        
                  ButtonWidget(
                    text: data.categoryInput.text,
                    padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 2.wMin),
                    color: const Color(0xff8E51FF).withValues(alpha: 0.1),
                    fontColor: const Color(0xff8E51FF),
                    fontSize: 14.wMin,
                    fontWeight: FontWeight.w600,
                  ),

                  SizedBox(width: 4.wMin),

                  Visibility(
                    visible: data.data?.nid == null,
                    child: ManageTagFS16Widget(
                      tag: "新增未保存",
                      bgColor: AppTheme.cFeedbackErrorBackground.color,
                      fontColor: AppTheme.cFeedbackErrorText.color,
                    ),
                  ),
                ],
              ),
        
              Text(
                data.nidInput.text,
                style: TextStyle(
                  fontSize: 16.wMin,
                  color: AppTheme.cTextSecondary.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
        
              SizedBox(height: 10.wMin),
        
              Text(
                data.zhDescInput.text,
                style: TextStyle(
                  fontSize: 16.wMin,
                  color: AppTheme.cTextSecondary.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
        
            ],
          ),
        );
      }),
    );
  }
}
