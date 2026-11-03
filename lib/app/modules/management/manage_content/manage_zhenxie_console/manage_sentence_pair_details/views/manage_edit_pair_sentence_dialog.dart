
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';

/// 编辑对句弹窗
class ManageEditPairSentenceDialog{
  static Future<void> show({
    required BuildContext context,
  }) async{
    return await showCupertinoDialog(
      context: context,
      builder: (context) {
        return ManageEditPairSentenceDialogWidget();
      },
    );
  }
}

class ManageEditPairSentenceDialogWidget extends StatefulWidget {
  const ManageEditPairSentenceDialogWidget({super.key});

  @override
  State<ManageEditPairSentenceDialogWidget> createState() => _ManageEditPairSentenceDialogWidgetState();
}

class _ManageEditPairSentenceDialogWidgetState extends State<ManageEditPairSentenceDialogWidget> {
  @override
  Widget build(BuildContext context) {
    return DialogUserWidget(
      title: "编辑句对",
      width: 1000.wMin,
      titlePadding: EdgeInsets.only(
        left: 32.wMin,
        right: 32.wMin,
        top: 32.wMin,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 950.wMin,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleWidget(),
            SizedBox(height: 12.wMin),
            Container(
              height: 1.wMin,
              color: AppTheme.cBorderSubtle.color,
            ),
            Expanded(child: _buildListWidget()),
            Container(
              height: 1.wMin,
              color: AppTheme.cBorderThin.color,
            ),
            SizedBox(height: 12.wMin),
            _buildButtonsWidget(),
            SizedBox(height: 24.wMin),
          ],
        ),
      ),
    );
  }

   Widget _buildTitleWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.wMin),
      child: Text(
        "与 paradigm 菜单同构；成对门禁 = pattern 硬验 + LLM 语义（不能只靠结构）",
        style: TextStyle(
          fontSize: 24.wMin,
          fontWeight: FontWeight.w400,
          color: AppTheme.cTextTertiary.color,
        ),
      ),
    );
  }

  Widget _buildButtonsWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.wMin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ButtonWidget(
            text: "新增对句",
            padding: EdgeInsets.symmetric(horizontal: 12.wMin),
            height: 56.wMin,
            borderRadius: 8.wMin,
            color: AppTheme.cSurfaceLayerElevated.color,
            fontColor: AppTheme.cTextSecondary.color,
            fontSize: 24.wMin,
            fontWeight: FontWeight.w500,
            sclae: 1.03,
            leftIcon: SvgPicture.asset(
              "assets/svg/public/icon_add.svg",
              width: 28.wMin,
              colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
            ),
            onTap: () {
              
            },
          ),
          const Spacer(),
          ButtonWidget(
            text: "取消",
            width: 112.wMin,
            height: 56.wMin,
            borderRadius: 8.wMin,
            color: AppTheme.cSurfaceLayerElevated.color,
            fontColor: AppTheme.cTextSecondary.color,
            fontSize: 24.wMin,
            fontWeight: FontWeight.w500,
            sclae: 1.03,
            onTap: () {
              Get.back();
            },
          ),
          SizedBox(width: 12.wMin),
          ButtonWidget(
            text: "保存",
            width: 112.wMin,
            height: 56.wMin,
            borderRadius: 8.wMin,
            color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.8),
            fontSize: 24.wMin,
            fontWeight: FontWeight.w500,
            sclae: 1.03,
            onTap: () {
              
            },
          ),
        ],
      ),
    );
  }


  Widget _buildListWidget(){
    return ListView.separated(
      itemCount: 3,
      padding: EdgeInsets.symmetric(horizontal: 32.wMin, vertical: 24.wMin),
      separatorBuilder: (context, index) => SizedBox(height: 12.wMin),
      itemBuilder: (context, index) {
        return _buildItemWidget(index);
      },
    );
  }

  Widget _buildItemWidget(int index){
    return Container(
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceTertiary.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "句对 ${index + 1}",
                style: TextStyle(
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
              const Spacer(),
              TapScaleWidget(
                onTap: () {
                  
                },
                sclae: 1.03,
                child: Container(
                  padding: EdgeInsets.all(6.wMin),
                  color: Colors.transparent,
                  child: SvgPicture.asset(
                    "assets/svg/public/icon_delete.svg",
                    width: 24.wMin,
                  ),
                ),
              ),
            ],
          ),
          _buildItemSelectWidget("From · concede_in_spite_of_np_main"),
          SizedBox(height: 12.wMin),
          _buildItemSelectWidget("To · opinion_frame_clause"),
        ],
      ),
    );
  }


  Widget _buildItemSelectWidget(String title){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextSecondary.color,
          ),
        ),
        SizedBox(height: 8.wMin),
        IconDropdownSelectWidget(
          height: 52.wMin,
          borderRadius: BorderRadius.circular(8.wMin),
          hintText: "请选择",
          hintStyle: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextTertiary.color,
          ),
          valueStyle: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextPrimary.color,
          ),
          items: [
            IconDropdownCheckData(
              title: "选项1",
              value: "1",
            ),
          ],
          selectValue: null,
        ),
      ],
    );
  }




}