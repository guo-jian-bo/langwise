
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../common/commons.dart';
import '../controllers/manage_vocal_timbre_controller.dart';
import '../models/manage_vocal_timbre_model.dart';


class ManageVocalTimbreListCardWidget extends StatelessWidget {
  final ManageVocalTimbreController controller;
  final ManageVocalTimbreModel data;
  final int index;
  const ManageVocalTimbreListCardWidget({super.key, required this.controller, required this.index, required this.data});

  @override
  Widget build(BuildContext context) {
    return TapScaleWidget(
      onTap: () {
        controller.selectLeftTimbre(context, index);
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
              color: selected ? const Color(0xffFB923C) : AppTheme.cBorderPrimary.color,
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
                      data.zhNameInput.text.isNotEmpty ? data.zhNameInput.text : "未命名音色",
                      style: TextStyle(
                        fontSize: 18.wMin,
                        color: AppTheme.cTextPrimary.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
        
                  Visibility(
                    visible: data.data?.uid == null,
                    child: ManageTagFS16Widget(
                      tag: "新增未保存",
                      bgColor: AppTheme.cFeedbackErrorBackground.color,
                      fontColor: AppTheme.cFeedbackErrorText.color,
                    ),
                  ),

                  Visibility(
                    visible: data.data?.uid != null,
                    child: ButtonWidget(
                      text: data.data?.enabled == true ? "启用" : "停用",
                      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 2.wMin),
                      color: data.data?.enabled == true ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.1) : AppTheme.cSurfaceError.color.withValues(alpha: 0.1),
                      fontColor: data.data?.enabled == true ? AppTheme.cSurfaceSuccess.color : AppTheme.cSurfaceError.color,
                      fontSize: 14.wMin,
                      fontWeight: FontWeight.w600,
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
                data.labelInput.text,
                style: TextStyle(
                  fontSize: 16.wMin,
                  color: AppTheme.cTextSecondary.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
        
              SizedBox(height: 16.wMin),
        
              
              Wrap(
                spacing: 6.wMin,
                runSpacing: 6.wMin,
                children: [
                  _buildListItemWidget(data.category?.value),
                  _buildListItemWidget(data.gender?.value),
                  _buildListItemWidget(data.ageGroup?.value),
                  _buildListItemWidget(data.manner?.value),
                  _buildListItemWidget(data.morality?.value),
                  _buildListItemWidget(data.background?.value),
                ],
              ),
        
            ],
          ),
        );
      }),
    );
  }

  Widget _buildListItemWidget(String? value){

    if(value == null) return Container(width: 0);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: AppTheme.cSurfaceTertiary.color,
      ),
      child: Text(
        value,
        style: TextStyle(
          fontSize: 14.wMin,
          color: AppTheme.cTextTertiary.color,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }




}
