
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'package:langwise/common/widgets/widgets.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../controllers/manage_setting_controller.dart';
import 'commons.dart';


class ManageListToolButtonWidget extends GetView<ManageSettingController> {
    /// 一键展开/收起 值
  final bool isExpand;
  /// 一键展开/收起 回调
  final void Function()? onExpand;
  /// 是否隐藏风格模式筛选
  final bool showStyleMode;
  /// 确定筛选
  final void Function()? onSubmit;

  /// 资源切换按钮
  const ManageListToolButtonWidget({
    super.key,
    this.isExpand = false,
    this.showStyleMode = true,
    this.onExpand,
    this.onSubmit,
  });



  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [

        Visibility(
          visible: onExpand != null,
          child: Container(
            margin: EdgeInsets.only(bottom: 24.wMin),
            child: ButtonWidget(
              text: isExpand ? "一键折叠" : "一键展开",
              width: 112.wMin,
              height: 40.wMin,
              borderRadius: 8.wMin,
              color: AppTheme.cSurfacePrimary.color,
              border: Border.all(width: 1.wMin, color: AppTheme.cBorderSecondary.color),
              fontSize: 16.wMin,
              fontColor: AppTheme.cTextSecondary.color,
              sclae: 1.03,
              onTap: onExpand,
            ),
          ),
        ),

        Visibility(
          visible: showStyleMode,
          child: TapScaleWidget(
            onTap: () async{
              ManageListToolReslut? res = await ManageListToolDialog.show(
                context: context,
                mode: controller.defaultResources.value,
              );
              if(res == null) return;
              controller.switchResources(res.mode);
              controller.setStyleIdByStyleKeyAndAreaCode(res.selectedStyleKey, res.selectedStyleAreaCode);
              onSubmit?.call();
            },
            sclae: 1.03,
            child: Container(
              width: 112.wMin,
              height: 120.wMin,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.wMin),
                color: AppTheme.cFeedbackInfoBackground.color,
                border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceInfo.color),
              ),
              child: Obx((){
                return Column(
                  children: [
                    _buildFilterTextWidget(controller.defaultResources.value.name),
                    Container(height: 1.wMin, color: AppTheme.cBorderSecondary.color, margin: EdgeInsets.symmetric(horizontal: 16.wMin)),
                    _buildFilterTextWidget(controller.selectedStyleKey.value),
                    Container(height: 1.wMin, color: AppTheme.cBorderSecondary.color, margin: EdgeInsets.symmetric(horizontal: 16.wMin)),
                    _buildFilterTextWidget(controller.getCurrentStyleAreaName() ?? ""),
                  ],
                );
              }),
            ),
          ),
        ),

      ],
    );
  }

  Widget _buildFilterTextWidget(String text){
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16.wMin,
            color: AppTheme.cTextBrand.color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }



  

}

class ManageListToolReslut{
  ResourceTypeEnum mode;
  String? selectedStyleAreaCode;
  String? selectedStyleKey;

  ManageListToolReslut({
    required this.mode,
    this.selectedStyleAreaCode,
    this.selectedStyleKey,
  });
}

class ManageListToolDialog{

  static Future<ManageListToolReslut?> show({
    required BuildContext context,
    required ResourceTypeEnum mode,
  }) async{
    ManageListToolReslut? res = await showCupertinoDialog<ManageListToolReslut?>(
      context: context,
      builder: (context) {
        return ManageListToolDialogWidget(mode: mode);
      },
    );

    return res;
  }

}

class ManageListToolDialogWidget extends StatefulWidget {
  final ResourceTypeEnum mode;
  const ManageListToolDialogWidget({
    super.key, 
    this.mode = ResourceTypeEnum.image,
  });

  @override
  State<ManageListToolDialogWidget> createState() => _ManageListToolDialogWidgetState();
}

class _ManageListToolDialogWidgetState extends State<ManageListToolDialogWidget> {
  ManageSettingController controller = ManageSettingController.to;

  /// 图片风格地区列表
  List<ImageStyleConfigV2Item> styleAreaList = <ImageStyleConfigV2Item>[];
  /// 选择的地区code
  String selectedStyleAreaCode = '';

  /// 图片风格列表
  List<String> styleKeyList = <String>[];
  /// 选中的画风
  String selectedStyleKey = '';

  final List<ResourceTypeEnum> modeList = [
    ResourceTypeEnum.image,
    ResourceTypeEnum.video,
  ];
  ResourceTypeEnum selectMode = ResourceTypeEnum.image;

  bool loading = false;

  @override
  void initState() {
    super.initState();
    selectMode = widget.mode;
    getStyleData();
  }

  Future<void> getStyleData() async{
    try {
      loading = true;

      styleAreaList = await controller.getStyleAreaList();
      selectedStyleAreaCode = controller.selectedStyleAreaCode.value;
      styleKeyList = await controller.getStyleKeyList();
      selectedStyleKey = controller.selectedStyleKey.value;

      if(mounted) setState(() {});
    } finally{
      loading = false;
    }
  }
  


  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.wMin),
          child: Stack(
            children: [
              Container(
                width: 1200.wMin,
                
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.wMin),
                  color: AppTheme.cSurfaceSecondary.color,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    SizedBox(height: 10.wMin),
                    
                    Container(
                      constraints: BoxConstraints(
                        minHeight: 400.wMin,
                        maxHeight: 800.wMin,
                      ),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(24.wMin),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 24.wMin,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildModeWidget(),
                            _buildImageStyleWidget(),
                            _buildLocalWidget(),
                          ],
                        ),
                      ),
                    ),
                    _buildButtonsWidget(),
                    
                  ],
                ),
              ),
              Positioned(
                right: 16.wMin,
                top: 16.wMin,
                child: TapScaleWidget(
                  sclae: 1.05,
                  onTap: () => Get.back(),
                  child: Container(
                    width: 42.wMin,
                    height: 42.wMin,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.cSurfaceTertiary.color,
                    ),
                    child: SvgPicture.asset(
                      "assets/svg/public/x.svg",
                      width: 24.wMin,
                      height: 24.wMin,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 地区
  Widget _buildLocalWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8.wMin,
      children: [
        _buildTitleTextWidget("地区"),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: styleAreaList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12.wMin,
            crossAxisSpacing: 12.wMin,
            mainAxisExtent: 64.wMin,
          ),
          itemBuilder: (context, index) {
            bool selected = selectedStyleAreaCode == styleAreaList[index].locale;

            return TapScaleWidget(
              sclae: 1,
              onTap: () async{
                if(styleAreaList[index].locale == null) return;
                selectedStyleAreaCode = styleAreaList[index].locale!;
                if(mounted) setState(() {});
              },
              child: _buildFilterItemWidget(
                name: styleAreaList[index].localeTitle??"",
                isSelected: selected,
              ),
            );
          },
        ),

      ],
    );
  }

  /// 风格
  Widget _buildImageStyleWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8.wMin,
      children: [
        _buildTitleTextWidget("风格"),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: styleKeyList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12.wMin,
            crossAxisSpacing: 12.wMin,
            mainAxisExtent: 64.wMin,
          ),
          itemBuilder: (context, index) {
            bool selected = selectedStyleKey == styleKeyList[index];

            return TapScaleWidget(
              sclae: 1,
              onTap: () async{
                selectedStyleKey = styleKeyList[index];
                styleAreaList = await controller.getStyleAreaListByStyleKey(selectedStyleKey);
                ImageStyleConfigV2Item? item = styleAreaList.firstWhereOrNull((element) => element.locale == selectedStyleAreaCode);
                if(item == null) {
                  selectedStyleAreaCode = styleAreaList.first.locale??"";
                }

                if(mounted) setState(() {});
              },
              child: _buildFilterItemWidget(
                name: styleKeyList[index],
                isSelected: selected,
              ),
            );
          },
        ),
      ],
    );
  }

  /// 模式
  Widget _buildModeWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8.wMin,
      children: [
        _buildTitleTextWidget("模式"),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: modeList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12.wMin,
            crossAxisSpacing: 12.wMin,
            mainAxisExtent: 64.wMin,
          ),
          itemBuilder: (context, index) {
            bool selected = selectMode == modeList[index];

            return TapScaleWidget(
              sclae: 1,
              onTap: () {
                selectMode = modeList[index];
                if(mounted) setState(() {});
              },
              child: _buildFilterItemWidget(
                name: modeList[index].name,
                isSelected: selected,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFilterItemWidget({required String name, bool isSelected = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      height: 64.wMin,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: isSelected ? AppTheme.cSurfaceTertiary.color : AppTheme.cSurfaceSecondary.color,
      ),
      child: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 24.wMin,
          color: isSelected ? AppTheme.cTextBrand.color : AppTheme.cTextSecondary.color,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }



  Widget _buildTitleTextWidget(String value) {
    return Text(
      value,
      style: TextStyle(
        fontSize: 24.wMin,
        color: AppTheme.cTextSecondary.color,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  /// 按钮
  Widget _buildButtonsWidget() {
    return Container(
      padding: EdgeInsets.all(24.wMin),
      child: Row(
        spacing: 12.wMin,
        children: [
          ManageButton(
            text: "重置",
            width: 350.wMin,
            height: 72.wMin,
            radius: 12.wMin,
            color: AppTheme.cSurfaceTertiary.color,
            borderColor: Colors.transparent,
            sclae: 1.02,
            style: TextStyle(
              fontSize: 28.wMin,
              color: AppTheme.cTextSecondary.color,
              fontWeight: FontWeight.w400,
            ),
            onTap: () {
              
              selectMode = ResourceTypeEnum.image;
              if(mounted) setState(() {});

            },
          ),
          Expanded(
            child: ManageButton(
              text: "确定",
              height: 72.wMin,
              radius: 12.wMin,
              color: AppTheme.cSurfaceInfo.color,
              borderColor: Colors.transparent,
              sclae: 1.005,
              style: TextStyle(
                fontSize: 28.wMin,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
              onTap: () {
                ManageListToolReslut reslut = ManageListToolReslut(
                  mode: selectMode,
                  selectedStyleAreaCode: selectedStyleAreaCode,
                  selectedStyleKey: selectedStyleKey,
                );
                Get.back(result: reslut);
              },
            ),
          ),
        ],
      ),
    );
  }

}
