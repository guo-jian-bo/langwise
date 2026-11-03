
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../controllers/manage_script_allocation_group_controller.dart';

class ManageScriptAllocationGroupListCardWidget extends StatelessWidget {
  final ManageScriptAllocationGroupController controller;
  final ManageScriptGroupingEntity data;
  const ManageScriptAllocationGroupListCardWidget({super.key, required this.controller, required this.data});

  @override
  Widget build(BuildContext context) {
    String name = data.name?.firstWhereOrNull((e) => e?.lang == "zh")?.text??"";
    return TapScaleWidget(
      onTap: () {
        controller.selectGroup(data);
      },
      sclae: 1,
      child: Obx((){
        bool selected = controller.getIsSelectData(data);
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
                      name.isEmpty ? "未命名分组" : name,
                      style: TextStyle(
                        fontSize: 18.wMin,
                        color: AppTheme.cTextPrimary.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
        
                  ButtonWidget(
                    text: "#${data.order??''}",
                    padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 2.wMin),
                    color: const Color(0xff00b8db).withValues(alpha: 0.1),
                    fontColor: const Color(0xff00b8db),
                    fontSize: 14.wMin,
                    fontWeight: FontWeight.w400,
                  ),

                  SizedBox(width: 6.wMin),

                  SvgPicture.asset(
                    selected ? "assets/svg/public/icon_check_box.svg" : "assets/svg/public/icon_uncheck_box.svg",
                    width: 32.wMin,
                  ),
        
                ],
              ),
        
              SelectableText(
                "uid: ${data.uid??''}",
                style: TextStyle(
                  fontSize: 16.wMin,
                  color: AppTheme.cTextTertiary.color,
                  fontWeight: FontWeight.w400,
                ),
              ),

              SizedBox(height: 6.wMin),

              SelectableText(
                data.category??"",
                style: TextStyle(
                  fontSize: 16.wMin,
                  color: AppTheme.cTextTertiary.color,
                  fontWeight: FontWeight.w400,
                ),
              ),
        
              SizedBox(height: 6.wMin),
        
              SelectableText(
                data.description?.firstWhereOrNull((e) => e?.lang == "zh")?.text??"",
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