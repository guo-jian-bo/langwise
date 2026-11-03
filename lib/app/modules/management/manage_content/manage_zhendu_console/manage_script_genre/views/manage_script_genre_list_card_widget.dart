
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../controllers/manage_script_genre_controller.dart';
import '../models/manage_script_genre_model.dart';

class ManageScriptGenreListCardWidget extends StatelessWidget {
  final ManageScriptGenreController controller;
  final int index;
  final ManageScriptGenreModel data;
  const ManageScriptGenreListCardWidget({super.key, required this.controller, required this.index, required this.data});

  @override
  Widget build(BuildContext context) {
    return TapScaleWidget(
      onTap: () {
        controller.selectLeftGenre(context, index);
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
              color: selected ? const Color(0xff00A6F4) : AppTheme.cBorderPrimary.color,
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
                      data.zhNameInput.text.isNotEmpty ? data.zhNameInput.text : "未命名题材",
                      style: TextStyle(
                        fontSize: 18.wMin,
                        color: AppTheme.cTextPrimary.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
        
                  ButtonWidget(
                    text: "${data.difficultyMinInput.text}-${data.difficultyMaxInput.text}",
                    padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 2.wMin),
                    color: const Color(0xff00A6F4).withValues(alpha: 0.1),
                    fontColor: const Color(0xff00A6F4),
                    fontSize: 14.wMin,
                    fontWeight: FontWeight.w600,
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