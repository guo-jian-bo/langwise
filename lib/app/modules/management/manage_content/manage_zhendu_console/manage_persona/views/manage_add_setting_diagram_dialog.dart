import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../common/commons.dart';
import '../../common/manage_zhendu_widgets.dart';
import '../../enums/manage_zhendu_enums.dart';

/// 新增设定图弹窗
class ManageAddSettingDiagramDialog{

  static Future<bool> show({
    required BuildContext context,
    required int variantId,
  }) async{
    bool? res = await showCupertinoDialog<bool?>(
      context: context,
      builder: (context) {
        return ManageAddSettingDiagramDialogWidget(variantId: variantId);
      },
    );

    return res??false;
  }

}


class ManageAddSettingDiagramDialogWidget extends StatefulWidget {
  final int variantId;
  const ManageAddSettingDiagramDialogWidget({super.key, required this.variantId});

  @override
  State<ManageAddSettingDiagramDialogWidget> createState() => _ManageAddSettingDiagramDialogWidgetState();
}

class _ManageAddSettingDiagramDialogWidgetState extends State<ManageAddSettingDiagramDialogWidget> {

  /// 视频风格列表
  Map<String, List<ImageStyleConfigV2Item>> styleGroups = {};

  /// 选择的风格id列表
  int? selectStyleId;

  ManageZhenduPersonaViewEnum personaView = ManageZhenduPersonaViewEnum.front_full_body;

  int imageNumber = 1;


  @override
  void initState() {
    super.initState();
    getStyleListV2();
  }

  Future<void> getStyleListV2() async{
    try {
      ToastUtils.showLoading();
      ImageStyleConfigV2ResponseData? res = await LanguageUtil.getStyleListV2();
      if(res == null) return;
      styleGroups = res.groups;

      if(mounted) setState(() {});
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 开始生成
  Future<void> startGenerating() async{
    if(selectStyleId == null) return ToastUtils.showToast(text: "请选择风格");
    Map<String, dynamic> reqData = {
      "variantId": widget.variantId,
      "numberOfImages": imageNumber,
      "styleId": selectStyleId,
      "viewType": personaView.value,
    }; 
    try {
      ToastUtils.showLoading();
      String? res = await LanguageConsoleDramaRequest.addSettingDiagram(data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: res, type: ToastType.success);
    } finally{
      ToastUtils.hideLoading();
    }
  }


  @override
  Widget build(BuildContext context) {
    return ManageDialogBoxWidget(
      title: "新增设定图",
      width: 1200.wMin,
      onCancel: () => Get.back(),
      confirmText: "开始生成",
      onConfirm: () {
        startGenerating();
      },
      child: Container(
        height: 800.wMin,
        padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 10.wMin),
        child: Row(
          spacing: 24.wMin,
          children: [

            _buildLeftWidget(),

            _buildStyleListWidget(),

          ],
        ),
        // child: _buildInputsWidget(),
      ),
    );
  }

  /// 左边
  Widget _buildLeftWidget(){
    return Container(
      width: 400.wMin,
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceTertiary.color,
        borderRadius: BorderRadius.circular(8.wMin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          ManageZhenduDropdownWidget(
            title: "视图类型",
            hintText: "请选择",
            selectValue: personaView,
            items: ManageZhenduDropdownEnums.personaViews,
            onChanged: (choiceData, index) {
              personaView = choiceData.value;
              if(mounted) setState(() {});
            },
          ),

          SizedBox(height: 40.wMin),

          Row(
            children: [
              Text(
                "生成图片数量",
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextSecondary.color,
                ),
              ),
              const Spacer(),
              Text(
                "$imageNumber",
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.wMin),

          SliderTheme(
            data: SliderThemeData(
              trackHeight: 8.wMin,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.wMin),
              overlayShape: SliderComponentShape.noOverlay,
              tickMarkShape: SliderTickMarkShape.noTickMark,
            ),
            child: Slider(
              value: imageNumber.toDouble(),
              max: 4,
              min: 1,
              divisions: 3,
              activeColor: AppTheme.cSurfaceBrand.color,
              inactiveColor: AppTheme.cSurfaceQuinary.color,
              onChanged: (value) {
                imageNumber = value.toInt();
                if(mounted) setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }


  /// 风格列表
  Widget _buildStyleListWidget(){
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          spacing: 16.wMin,
          children: List.generate(styleGroups.keys.length, (index){
              
            return _buildStyleListGroupWidget(styleGroups.keys.toList()[index]);
              
          }),
        ),
      ),
    );
  }

  Widget _buildStyleListGroupWidget(String group){

    List<ImageStyleConfigV2Item> list = styleGroups[group]??[];

    return Column(
      children: [

        Container(
          height: 44.wMin,
          padding: EdgeInsets.symmetric(horizontal: 12.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.wMin),
            color: AppTheme.cSurfaceTertiary.color,
          ),
          child: Row(
            children: [
              Text(
                group,
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
            ],
          ),
        ),

        Container(
          padding: EdgeInsets.symmetric(vertical: 8.wMin),
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 6.wMin,
            runSpacing: 6.wMin,
            children: List.generate(list.length, (index){
              return _buildStyleListGroupItemWidget(list[index]);
            }),
          ),
        ), 



      ],
    );
  }

  Widget _buildStyleListGroupItemWidget(ImageStyleConfigV2Item style){
    bool isSelect = selectStyleId == style.uid;

    List<String> flagList = style.iconUrls??[];

    return TapScaleWidget(
      onTap: () {
        selectStyleId = style.uid;
        if(mounted) setState(() {});
      },
      sclae: 1,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 6.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.wMin),
          color: AppTheme.cSurfaceTertiary.color,
          border: Border.all(
            width: 1.wMin,
            color: isSelect ? AppTheme.cBorderBrand.color : Colors.transparent,
          ),
        ),
        child: Row(
          spacing: 4.wMin,
          mainAxisSize: MainAxisSize.min,
          children: [

            Row(
              spacing: 2.wMin,
              mainAxisSize: MainAxisSize.min,
              children: List.generate(flagList.length, (index){
                return SizedBox(
                  width: 28.wMin,
                  child: CachedImageWidget(
                    flagList[index],
                    errorWidget: buildEmptyWidget(),
                    placeholder: buildEmptyWidget(),
                  ),
                );
              }),
            ),

            Text(
              style.localeTitle??"",
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextSecondary.color,
              ),
            ),

          ],
        ),
      ),
    );
  }


}