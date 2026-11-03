import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../common/commons.dart';
import '../controllers/manage_persona_controller.dart';
import '../models/manage_persona_model.dart';

class ManagePersonaLeftCardWidget extends StatelessWidget {
  final ManagePersonaController controller;
  final ManagePersonaModel data;
  final int index;
  const ManagePersonaLeftCardWidget({super.key, required this.controller, required this.index, required this.data});

  @override
  Widget build(BuildContext context) {

    String tagsText = data.tagsInput.text;
    List<String> tagsList = [];
    if(tagsText.isNotEmpty){
      tagsList = tagsText.split(",");
    }

    return TapScaleWidget(
      onTap: () {
        controller.selectLeftPersona(context, index);
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
              color: selected ? const Color(0xffFF2056) : AppTheme.cBorderPrimary.color,
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
                      data.zhNameInput.text.isNotEmpty ? data.zhNameInput.text : "未命名角色",
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
                data.personalityInput.text,
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
                children: List.generate(tagsList.length, (index){
                  return _buildListItemWidget(tagsList[index]);
                }),
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
        "#$value",
        style: TextStyle(
          fontSize: 14.wMin,
          color: AppTheme.cTextTertiary.color,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }


}
