import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';

import '../../../../../common/entities/entities.dart';
import '../controllers/course_level_select_unit_controller.dart';

class CourseLevelSelectUnitView extends GetView<CourseLevelSelectUnitController> {
  const CourseLevelSelectUnitView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary.color,
      body: Column(
        children: [
          _buildTitleWidget(context),
          _buildSubTitleWidget(context),
          SizedBox(height: 24.wMin),

          Expanded(
            child: Obx((){
              return GridView.builder(
                itemCount: controller.unitList.length,
                padding: EdgeInsets.only(
                  left: 64.wMin, 
                  right: 64.wMin,
                  bottom: 84.wMin + MediaQuery.of(context).padding.bottom,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 24.wMin,
                  crossAxisSpacing: 24.wMin,
                  mainAxisExtent: 200.wMin,
                ),
                itemBuilder: (context, index) {
                  return _buildUnitItemWidget(context, controller.unitList[index]);
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: _buildFloatActionButtonWidget(context),
    );
  }

  Widget _buildFloatActionButtonWidget(BuildContext context){
    return ButtonWidget(
      text: "确定选择",
      width: 160.wMin,
      height: 64.wMin,
      borderRadius: 12.wMin,
      color: AppTheme.cBgBrand.color,
      fontColor: AppTheme.cInverseTextLight.color,
      fontSize: 24.wMin,
      fontWeight: FontWeight.w600,
      sclae: 1.05,
      onTap: () {
        controller.submit();
      },
    );
  }

  Widget _buildTitleWidget(BuildContext context){
    return Container(
      margin: EdgeInsets.only(top: 24.wMin + MediaQuery.of(context).padding.top),
      padding: EdgeInsets.symmetric(horizontal: 40.wMin),
      child: const BackWidget(title: "选择单元"),
    );
  }

  Widget _buildSubTitleWidget(BuildContext context){
    if(controller.subTitle == null || controller.subTitle!.isEmpty) return const SizedBox();
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 24.wMin, left: 64.wMin, right: 64.wMin),
      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 12.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        color: AppTheme.cFeedbackInfoBackground.color,
      ),
      child: Text(
        controller.subTitle??"",
        style: TextStyle(
          fontSize: 28.wMin,
          color: AppTheme.cTextBrand.color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildUnitItemWidget(BuildContext context, CourseLevelModuleUnitEntityUnits unit){
    return TapScaleWidget(
      onTap: () {
        controller.selectUnit(unit.unitId);
      },
      sclae: 1.005,
      child: Container(
        padding: EdgeInsets.all(24.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cSurfaceSecondary.color,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    unit.unitName??"",
                    maxLines: (unit.unitDescription != null && unit.unitDescription!.isNotEmpty) ? 1 : 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 32.wMin,
                      color: AppTheme.cTextPrimary.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Obx((){
                  bool select = controller.selectId.value == unit.unitId;

                  return Container(
                    margin: EdgeInsets.only(left: 4.wMin),
                    padding: EdgeInsets.only(top: 6.wMin),
                    child: SvgPicture.asset(
                      select ? "assets/svg/public/icon_radio.svg" : "assets/svg/public/icon_radio_un.svg",
                      width: 32.wMin,
                      colorFilter: select ? null : ColorFilter.mode(
                        AppTheme.cBorderTertiary.color,
                        BlendMode.srcIn,
                      ),
                    ),
                  );
                }),
              ],
            ),
            Visibility(
              visible: unit.unitDescription != null && unit.unitDescription!.isNotEmpty,
              child: Text(
                unit.unitDescription??"",
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: AppTheme.cTextTertiary.color,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            
      
          ],
        ),
      ),
    );
  }

}
