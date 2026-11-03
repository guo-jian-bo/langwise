
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../controllers/manage_script_grouping_controller.dart';
import '../models/manage_script_grouping_model.dart';

class ManageScriptGroupingListCardWidget extends StatelessWidget {
  final ManageScriptGroupingController controller;
  final int index;
  final ManageScriptGroupingModel data;
  const ManageScriptGroupingListCardWidget({super.key, required this.controller, required this.index, required this.data});

  @override
  Widget build(BuildContext context) {
    return TapScaleWidget(
      onTap: () {
        controller.selectLeftGroup(context, index);
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
              color: selected ? const Color(0xff00b8db) : AppTheme.cBorderPrimary.color,
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
                      data.zhNameInput.text.isNotEmpty ? data.zhNameInput.text : "未命名分组",
                      style: TextStyle(
                        fontSize: 18.wMin,
                        color: AppTheme.cTextPrimary.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
        
                  ButtonWidget(
                    text: "#${data.orderInput.text}",
                    padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 2.wMin),
                    color: const Color(0xff00b8db).withValues(alpha: 0.1),
                    fontColor: const Color(0xff00b8db),
                    fontSize: 14.wMin,
                    fontWeight: FontWeight.w400,
                  ),

                  SizedBox(width: 4.wMin),

                  ButtonWidget(
                    text: data.data?.enabled == true ? "启用" : "停用",
                    padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 2.wMin),
                    color: data.data?.enabled == true ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.1) : AppTheme.cSurfaceError.color.withValues(alpha: 0.1),
                    fontColor: data.data?.enabled == true ? AppTheme.cSurfaceSuccess.color : AppTheme.cSurfaceError.color,
                    fontSize: 14.wMin,
                    fontWeight: FontWeight.w600,
                  ),
        
                ],
              ),
        
              SelectableText(
                "uid: ${data.uidInput.text}",
                style: TextStyle(
                  fontSize: 16.wMin,
                  color: AppTheme.cTextTertiary.color,
                  fontWeight: FontWeight.w400,
                ),
              ),

              SizedBox(height: 6.wMin),

              SelectableText(
                data.categoryInput.text,
                style: TextStyle(
                  fontSize: 16.wMin,
                  color: AppTheme.cTextTertiary.color,
                  fontWeight: FontWeight.w400,
                ),
              ),
        
              SizedBox(height: 6.wMin),
        
              SelectableText(
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