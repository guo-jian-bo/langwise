import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';


import '../../../../../../../../common/entities/entities.dart';
import '../../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../../theme/theme.dart';
import '../../../../../../../routes/routes.dart';
import '../../../../../common/commons.dart';
import '../bindings/manage_create_visual_project_binding.dart';
import '../controllers/manage_create_visual_project_controller.dart';
import 'manage_create_visual_project_audio_item_widget.dart';

class ManageCreateVisualProjectView extends GetView<ManageCreateVisualProjectController> {
  final String tagText;
  const ManageCreateVisualProjectView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_CREATE_VISUAL_PROJECT}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageCreateVisualProjectView(tagText: tag),
      binding: ManageCreateVisualProjectBinding(tag: tag),
      routeName: Routes.MANAGE_CREATE_VISUAL_PROJECT,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(
              left: 150.wMin,
              right: 150.wMin,
              top: 24.wMin,
              bottom: 24.wMin,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildSelectAudioWidget()),
                _buildSelectVisualStyleWidget(),
              ],
            ),
          ),
          Positioned(
            right: 8.wMin,
            bottom: 40.wMin,
            child: _buildToolButtonsWidget(),
          ),
        ],
      ),
    );
  }

  /// 工具按钮
  Widget _buildToolButtonsWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        ButtonWidget(
          text: "创建视觉项目",
          padding: EdgeInsets.symmetric(horizontal: 10.wMin),
          height: 44.wMin,
          color: const Color(0xffe12afb).withValues(alpha: 0.2),
          border: Border.all(width: 1.wMin, color: const Color(0xffe12afb)),
          borderRadius: 8.wMin,
          fontSize: 18.wMin,
          fontColor: const Color(0xffe12afb),
          sclae: 1.03,
          onTap: OptimizeUtils.noneThrottle(() {
            controller.createVisualProject();
          }, 300),
        ),
      ],
    );
  }

  Widget _buildSelectAudioWidget(){
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfacePrimary.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            "选择音频项目",
            style: TextStyle(
              fontSize: 20.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 10.wMin),
          Row(
            spacing: 16.wMin,
            children: [
              Expanded(
                child: CardInputWidget(
                  hintText: "综合搜索（标题 / uid / 关联对象）",
                  controller: controller.keywordSearchInput,
                  textInputAction: TextInputAction.search,
                  height: 54.wMin,
                  valueStyle: TextStyle(
                    fontSize: 20.wMin,
                    color: AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w400,
                  ),
                  hintStyle: TextStyle(
                    fontSize: 20.wMin,
                    color: AppTheme.cTextTertiary.color,
                    fontWeight: FontWeight.w400,
                  ),
                  onSubmitted: (value) {
                    controller.refreshAudioListData();
                  },
                ),
              ),
              Expanded(
                child: CardInputWidget(
                  hintText: "uid",
                  controller: controller.uidSearchInput,
                  textInputAction: TextInputAction.search,
                  height: 54.wMin,
                  valueStyle: TextStyle(
                    fontSize: 20.wMin,
                    color: AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w400,
                  ),
                  hintStyle: TextStyle(
                    fontSize: 20.wMin,
                    color: AppTheme.cTextTertiary.color,
                    fontWeight: FontWeight.w400,
                  ),
                  onSubmitted: (value) {
                    controller.refreshAudioListData();
                  },
                ),
              ),
              Expanded(
                child: CardInputWidget(
                  hintText: "title",
                  controller: controller.titleSearchInput,
                  textInputAction: TextInputAction.search,
                  height: 54.wMin,
                  valueStyle: TextStyle(
                    fontSize: 20.wMin,
                    color: AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w400,
                  ),
                  hintStyle: TextStyle(
                    fontSize: 20.wMin,
                    color: AppTheme.cTextTertiary.color,
                    fontWeight: FontWeight.w400,
                  ),
                  onSubmitted: (value) {
                    controller.refreshAudioListData();
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 10.wMin),

          Container(
            height: 54.wMin,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 16.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.wMin),
              color: AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.1),
              border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceSuccess.color),
            ),
            child: Obx((){
              if(controller.selectAudioData.value == null){
                return SelectableText(
                  "请选择音频项目",
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color: AppTheme.cFeedbackWarningText.color,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }
              return SelectableText(
                "已选: ${controller.selectAudioData.value?.title??''} (uid: ${controller.selectAudioData.value?.uid??''})",
                style: TextStyle(
                  fontSize: 20.wMin,
                  color: AppTheme.cFeedbackSuccessText.color,
                  fontWeight: FontWeight.w600,
                ),
              );
            }),
          ),

          SizedBox(height: 10.wMin),

          // TTOD
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.wMin),
              child: Container(
                color: AppTheme.cSurfaceSecondary.color,
                child: Obx((){
                  return ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 16.wMin),
                    controller: controller.audioScrollController,
                    itemCount: controller.audioList.length,
                    separatorBuilder: (context, index) => SizedBox(height: 16.wMin),
                    itemBuilder: (context, index) {
                      return ManageCreateVisualProjectAudioItemWidget(
                        controller: controller,
                        data: controller.audioList[index],
                      );
                    },
                  );
                }),
              ),
            ),
          ),
        ],
      ),

    );
  }

  /// 选择视觉风格
  Widget _buildSelectVisualStyleWidget(){
    return Container(
      height: 350.wMin,
      width: double.infinity,
      margin: EdgeInsets.only(top: 16.wMin),
      padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfacePrimary.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "选择视觉风格",
            style: TextStyle(
              fontSize: 20.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 10.wMin),

          Expanded(
            child: Obx((){
              return GridView.builder(
                itemCount: controller.styleList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 12.wMin,
                  crossAxisSpacing: 12.wMin,
                  mainAxisExtent: 95.wMin,
                ),
                itemBuilder: (context, index) {
                  return _buildSelectVisualStyleItemWidget(controller.styleList[index]);
                },
              );
            }),
          ),

        ],
      ),

    );
  } 

  Widget _buildSelectVisualStyleItemWidget(StyleImageEntity data){
    return Obx((){
      bool selected = controller.selectStyleId.value == data.uid;
      return TapScaleWidget(
        onTap: () {
          controller.selectStyle(data);
        },
        sclae: 1,
        backColor: AppTheme.cSurfaceSecondary.color,
        borderRadius: 12.wMin,
        child: Container(
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
                      data.styleTitle??"",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20.wMin,
                        color: AppTheme.cTextPrimary.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  ButtonWidget(
                    text: "uid: ${data.uid??''}",
                    padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 4.wMin),
                    color: const Color(0xffe12afb).withValues(alpha: 0.2),
                    fontColor: const Color(0xffe12afb),
                    fontSize: 14.wMin,
                  ),
                ],
              ),
              SizedBox(height: 4.wMin),
              Text(
                data.style??"",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16.wMin,
                  color: AppTheme.cTextSecondary.color,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
  
}
