
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../theme/theme.dart';
import '../controllers/manage_vocal_emotions_controller.dart';
import '../models/manage_vocal_emotions_model.dart';

class ManageVocalEmotionsListCardWidget extends StatelessWidget {
  final ManageVocalEmotionsController controller;
  final int index;
  final ManageVocalEmotionsModel data;
  const ManageVocalEmotionsListCardWidget({super.key, required this.controller, required this.index, required this.data});

  @override
  Widget build(BuildContext context) {
    return TapScaleWidget(
      onTap: () {
        controller.selectLeftEmotions(context, index);
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
              color: selected ? const Color(0xff00D492) : AppTheme.cBorderPrimary.color,
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
                      data.zhNameInput.text.isNotEmpty ? data.zhNameInput.text : "未命名情绪",
                      style: TextStyle(
                        fontSize: 18.wMin,
                        color: AppTheme.cTextPrimary.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
        
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
        
              SizedBox(height: 16.wMin),
        
              _buildListWidget(),
        
            ],
          ),
        );
      }),
    );
  }

  Widget _buildListWidget(){

    return Obx((){
      ManageVocalEmotionsModel data = controller.listData[index];

      return Column(
        spacing: 6.wMin,
        children: [
          Row(
            spacing: 6.wMin,
            children: [
              _buildListItemWidget("HAP", data.happySlider),
              _buildListItemWidget("ANG", data.angrySlider),
              _buildListItemWidget("SAD", data.sadSlider),
              _buildListItemWidget("AFR", data.afraidSlider),
            ],
          ),
          Row(
            spacing: 6.wMin,
            children: [
              _buildListItemWidget("DIS", data.disgustedSlider),
              _buildListItemWidget("MEL", data.melancholicSlider),
              _buildListItemWidget("SUR", data.surprisedSlider),
              _buildListItemWidget("CAL", data.calmSlider),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildListItemWidget(String name, double value){
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.wMin),
          color: AppTheme.cSurfaceTertiary.color,
        ),
        child: Column(
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 16.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              value.toStringAsFixed(2).padLeft(2, '0'),
              style: TextStyle(
                fontSize: 18.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }


}