import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/utils/manage_auth_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../../enums/manage_visual_image_status_enum.dart';
import '../bindings/manage_visual_project_binding.dart';
import '../controllers/manage_visual_project_controller.dart';

class ManageVisualProjectView extends GetView<ManageVisualProjectController> {
  final String tagText;
  const ManageVisualProjectView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_VISUAL_PROJECT}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageVisualProjectView(tagText: tag),
      binding: ManageVisualProjectBinding(tag: tag),
      routeName: Routes.MANAGE_VISUAL_PROJECT,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      onRefresh: () => controller.getDataList(),
      body: Stack(
        children: [
          Column(
            children: [
              _buildTitleWidget(),
              Expanded(child: _buildListWidget(context)),
            ],
          ),
          Positioned(
            right: 8.wMin,
            bottom: 40.wMin,
            child: _buildToolButtonsWidget(),
          ),
        ],
      ),
      floatingActionButton: _buildFilterWidget(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /// 筛选的按钮
  Widget _buildFilterWidget(BuildContext context){
    
    Map<String, FilterConditionData> filterConditionDatas = {...controller.filterConditionDatas};
    Map<String, FilterInputData> filterInputDatas = {...controller.filterInputDatas};
    return FilterFloatWidget(
      width: 1620.wMin,
      conditions: filterConditionDatas,
      inputs: filterInputDatas,
      onChange: (datas) {
        controller.changeFilterConditionData(datas);
      },
      onSubmitted: () {
        controller.searchSubmitted();
      },
    );
  }

  /// 工具按钮
  Widget _buildToolButtonsWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        ManageAuthBoxWidget(
          authCodes: const [ManageAuthCode.dramaVisualProjectCreate],
          child: ButtonWidget(
            text: "新建视觉项目",
            padding: EdgeInsets.symmetric(horizontal: 10.wMin),
            height: 44.wMin,
            color: const Color(0xffe12afb).withValues(alpha: 0.2),
            border: Border.all(width: 1.wMin, color: const Color(0xffe12afb)),
            borderRadius: 8.wMin,
            fontSize: 18.wMin,
            fontColor: const Color(0xffe12afb),
            sclae: 1.03,
            onTap: () {
              controller.addVisualProject();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTitleWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 150.wMin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          PagerWidget(
            dataCount: controller.totalCount.value,
            controller: controller.pagerController,
            pageSize: controller.limit,
            visiblePageCount: 3,
            activeColor: AppTheme.cTextPrimary.color,
            onPage: (page, pageSize) {
              controller.pagerCallback(page, pageSize);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListWidget(BuildContext context){
    return Obx((){
      return ListView.separated(
        itemCount: controller.dataList.length,
        padding: EdgeInsets.only(
          left: 150.wMin,
          right: 150.wMin,
          top: 10.wMin,
          bottom: 200.wMin,
        ),
        separatorBuilder: (context, index) => SizedBox(height: 16.wMin),
        itemBuilder: (context, index) {
          return _buildListitemWidget(context, controller.dataList[index]);
        },
      );
    });
  }


  Widget _buildListitemWidget(BuildContext context, ManageVisualProjectEntity data){
    return TapScaleWidget(
      onTap: () {
        if(!ManageAuthUtils.isAuth(ManageAuthCode.dramaVisualProjectDetail)) return;
        controller.visualProjectDetail(data);
      },
      sclae: 1,
      child: Container(
        padding: EdgeInsets.all(12.wMin),
        decoration: BoxDecoration(
          border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
          color: AppTheme.cSurfaceSecondary.color,
          borderRadius: BorderRadius.circular(12.wMin),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildListitemTagsWidget(context, data),
            SizedBox(height: 16.wMin),
            _buildListitemContentWidget(data),
            SizedBox(height: 10.wMin),
            _buildListItemInfoWidget(data),
          ],
        ),
      ),
    );
  }

  Widget _buildListitemTagsWidget(BuildContext context, ManageVisualProjectEntity data){

    int checkedNumber = data.sceneRelations?.where((e) => e?.statusEnum == ManageVisualImageStatusEnum.checked || e?.statusEnum == ManageVisualImageStatusEnum.image_checked).toList().length??0;
    Color sceneNumberColor = AppTheme.cSurfaceError.color;
    if(checkedNumber == data.sceneRelations?.length){
      sceneNumberColor = AppTheme.cSurfaceSuccess.color;
    }else if(checkedNumber != 0){
      sceneNumberColor = AppTheme.cSurfaceWarning.color;
    }
    
    return Row(
      children: [
        ManageTagFS16Widget(
          tag: "project_uid: ${data.uid??''}",
          bgColor: AppTheme.cSurfaceTertiary.color,
          fontColor: AppTheme.cTextSecondary.color,
        ),
        SizedBox(width: 6.wMin),
        ManageTagFS16Widget(
          tag: "创建人: ${data.userId??''}",
          bgColor: AppTheme.cSurfaceTertiary.color,
          fontColor: AppTheme.cTextSecondary.color,
        ),
        SizedBox(width: 6.wMin),
        // ManageTagFS16Widget(
        //   tag: data.statusEnum?.name,
        //   bgColor: data.statusEnum?.bg,
        //   fontColor: data.statusEnum?.font??AppTheme.cTextSecondary.color,
        // ),
        
        const Spacer(),
        ManageTagFS16Widget(
          tag: "$checkedNumber / ${data.sceneRelations?.length??0} 场景",
          bgColor: sceneNumberColor.withValues(alpha: 0.2),
          fontColor: sceneNumberColor,
        ),

        ManageAuthBoxWidget(
          authCodes: const [ManageAuthCode.dramaVisualProjectDelete],
          margin: EdgeInsets.only(left: 16.wMin),
          child: TapScaleWidget(
            onTap: () {
              controller.deleteData(context, data);
            },
            sclae: 1.1,
            borderRadius: 8.wMin,
            backColor: AppTheme.cSurfaceTertiary.color,
            child: Container(
              width: 50.wMin,
              height: 40.wMin,
              alignment: Alignment.center,
              child: SvgPicture.asset(
                "assets/svg/public/icon_delete.svg",
                width: 24.wMin,
              ),
            ),
          ),
        ),

      ],
    );
  }

  Widget _buildListitemContentWidget(ManageVisualProjectEntity data){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        SelectableText(
          data.title??"",
          style: TextStyle(
            fontSize: 24.wMin,
            color: AppTheme.cTextPrimary.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4.wMin),
        SelectableText(
          "来源剧本: ${data.scriptTitle??''}，音频底座 audio_project_uid: ${data.audioProjectId??''}",
          style: TextStyle(
            fontSize: 16.wMin,
            color: AppTheme.cTextPrimary.color.withValues(alpha: 0.6),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildListItemInfoWidget(ManageVisualProjectEntity data){
    return Row(
      spacing: 24.wMin,
      children: [
        _buildListItemInfoItemWidget("视觉风格: ", data.styleTitle??""),
        _buildListItemInfoItemWidget("场景进度: ", "${data.sceneImageGeneratedCount??0}/${data.sceneRelations?.length??0} 已出图"),
        _buildListItemInfoItemWidget("图片审核: ", "${data.sceneTaskCheckedCount??0}/${data.sceneRelations?.length??0} 已审核"),
        _buildListItemInfoItemWidget("视频片段: ", "${data.videoSegmentCount??0}段"),
      ],
    );
  }

  Widget _buildListItemInfoItemWidget(String name, String value){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 8.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.wMin),
        color: AppTheme.cSurfaceTertiary.color,
        border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
      ),
      child: Row(
        children: [
          SelectableText(
            name,
            style: TextStyle(
              fontSize: 16.wMin,
              color: AppTheme.cTextSecondary.color,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(width: 4.wMin),
          SelectableText(
            value,
            style: TextStyle(
              fontSize: 18.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  
}
