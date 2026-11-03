import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../theme/theme.dart';
import '../../../enums/enums.dart';

class ManageUnifiedImageCreateSizeDialog{

  static void show({
    required BuildContext context,
    ImageAspectRatioEnums? aspectRatio,
    ImageQualityEnums? quality,
    void Function(ImageAspectRatioEnums, ImageQualityEnums)? onChange,
  }){
    BotToast.showAttachedWidget(
      targetContext: context,
      preferDirection: PreferDirection.bottomCenter,
      allowClick: false,
      attachedBuilder: (cancelFunc) {
        return ManageUnifiedImageCreateSizeDialogWidget(
          aspectRatio: aspectRatio,
          quality: quality,
          onChange: onChange,
        );
      },
    );
  }

}

class ManageUnifiedImageCreateSizeDialogWidget extends StatefulWidget {
  final ImageAspectRatioEnums? aspectRatio;
  final ImageQualityEnums? quality;
  final void Function(ImageAspectRatioEnums, ImageQualityEnums)? onChange;
  const ManageUnifiedImageCreateSizeDialogWidget({super.key, this.aspectRatio, this.quality, this.onChange});

  @override
  State<ManageUnifiedImageCreateSizeDialogWidget> createState() => _ManageUnifiedImageCreateSizeDialogWidgetState();
}

class _ManageUnifiedImageCreateSizeDialogWidgetState extends State<ManageUnifiedImageCreateSizeDialogWidget> {

  ImageAspectRatioEnums selectedAspectRatio = ImageAspectRatioEnums.ratio_1_1;
  ImageQualityEnums selectedQuality = ImageQualityEnums.quality_2048;

  @override
  void initState(){
    super.initState();
    if(widget.aspectRatio != null){
      selectedAspectRatio = widget.aspectRatio!;
    }
    if(widget.quality != null){
      selectedQuality = widget.quality!;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: 580.wMin,
        padding: EdgeInsets.all(16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          border: Border.all(width: 0.8.wMin, color: AppTheme.cBorderPrimary.color),
          color: AppTheme.cSurfaceTertiary.color,
        ),
        child: Column(
          spacing: 12.wMin,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAspectWidget(),
            SizedBox(height: 12.wMin),
            _buildQualityWidget(),
            SizedBox(height: 12.wMin),
            _buildSizeInfoWidget(),
          ],
        ),
      ),
    );
  }

  /// 比例
  Widget _buildAspectWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          "选择比例",
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextSecondary.color,
          ),
        ),

        SizedBox(height: 4.wMin),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: ImageAspectRatioEnums.values.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 6.wMin,
            crossAxisSpacing: 6.wMin,
            mainAxisExtent: 44.wMin,
          ),
          itemBuilder: (context, index) {
            return _buildItemWidget(
              text: ImageAspectRatioEnums.values[index].name,
              isSelected: selectedAspectRatio == ImageAspectRatioEnums.values[index],
              onTap: () {
                setState(() {
                  selectedAspectRatio = ImageAspectRatioEnums.values[index];
                });
                widget.onChange?.call(selectedAspectRatio, selectedQuality);
              },
            );
          },
        ),

      ],
    );
  }

  /// 质量
  Widget _buildQualityWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          "选择分辨率",
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextSecondary.color,
          ),
        ),

        SizedBox(height: 4.wMin),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: ImageQualityEnums.values.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 6.wMin,
            crossAxisSpacing: 6.wMin,
            mainAxisExtent: 44.wMin,
          ),
          itemBuilder: (context, index) {
            return _buildItemWidget(
              text: ImageQualityEnums.values[index].name,
              isSelected: selectedQuality == ImageQualityEnums.values[index],
              onTap: () {
                setState(() {
                  selectedQuality = ImageQualityEnums.values[index];
                });
                widget.onChange?.call(selectedAspectRatio, selectedQuality);
              },
            );
          },
        ),

      ],
    );
  }


  /// 尺寸信息
  Widget _buildSizeInfoWidget(){
    Size size = ImageAspectRatioUtils.getImageSize(selectedAspectRatio, selectedQuality);
    return Row(
      spacing: 16.wMin,
      children: [

        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.wMin),
              color: AppTheme.cSurfaceSecondary.color,
              border: Border.all(width: 0.8.wMin, color: AppTheme.cBorderPrimary.color),
            ),
            child: Column(
              children: [
                Text(
                  "W",
                  style: TextStyle(
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextTertiary.color,
                  ),
                ),
                Text(
                  "${size.width.toInt()}",
                  style: TextStyle(
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cTextPrimary.color,
                  ),
                ),
              ],
            ),
          ),
        ),

        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.wMin),
              color: AppTheme.cSurfaceSecondary.color,
              border: Border.all(width: 0.8.wMin, color: AppTheme.cBorderPrimary.color),
            ),
            child: Column(
              children: [
                Text(
                  "H",
                  style: TextStyle(
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextTertiary.color,
                  ),
                ),
                Text(
                  "${size.height.toInt()}",
                  style: TextStyle(
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cTextPrimary.color,
                  ),
                ),
              ],
            ),
          ),
        ),

      ],
    );
  }



  Widget _buildItemWidget({
    required String text,
    bool isSelected = false,
    void Function()? onTap,
  }){
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.01,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          color: isSelected ? AppTheme.cSurfaceBrand.color : AppTheme.cSurfaceSecondary.color,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppTheme.cTextPrimary.color,
          ),
        ),
      ),
    );
  }

}