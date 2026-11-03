import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';



import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../../../../utils/utils.dart';
import '../bindings/manage_script_details_binding.dart';
import '../controllers/manage_script_details_controller.dart';
import 'manage_script_content_widget.dart';
import 'manage_script_scene_widget.dart';

class ManageScriptDetailsView extends GetView<ManageScriptDetailsController> {
  final String tagText;
  const ManageScriptDetailsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_SCRIPT_DETAILS}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageScriptDetailsView(tagText: tag),
      binding: ManageScriptDetailsBinding(tag: tag),
      routeName: Routes.MANAGE_SCRIPT_DETAILS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      onBack: () => controller.checkBeforeExit(context),
      onRefresh: () => controller.getDetilData(),
      onMessagePageBack: (message) => controller.updateAudioProjectCreateStatus(message.code),
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 150.wMin,
                right: 150.wMin,
                top: 24.wMin,
                bottom: 200.wMin,
              ),
              child: Column(
                children: [
                  ManageScriptContentWidget(controller: controller),
                  SizedBox(height: 16.wMin),
                  _buildListWidget(),
                ],
              ),
            ),
          ),
          Positioned(
            right: 8.wMin,
            bottom: 40.wMin,
            child: _buildToolButtonsWidget(context),
          ),
        ],
      ),
    );
  }

  /// 工具按钮
  Widget _buildToolButtonsWidget(BuildContext context){
    return Obx((){
      ManageScriptDetilEntityAudioProjects? audioProject;
      if((controller.detilData.value.audioProjects??[]).isNotEmpty){
        audioProject = controller.detilData.value.audioProjects?[0];
      }
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [

          // 检查符号
          ButtonWidget(
            text: "检查符号",
            padding: EdgeInsets.symmetric(horizontal: 10.wMin),
            height: 44.wMin,
            color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
            border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceBrand.color),
            borderRadius: 8.wMin,
            fontSize: 18.wMin,
            fontColor: AppTheme.cSurfaceBrand.color,
            sclae: 1.03,
            onTap: () {
              controller.checkDialogueSymbol();
            },
          ),

          SizedBox(height: 12.wMin),

          Visibility(
            visible: audioProject != null,
            child: ManageAuthBoxWidget(
              authCodes: const [ManageAuthCode.dramaAudioProjectDetail],
              child: TapScaleWidget(
                onTap: () {
                  controller.toAudioProjectDetail(audioProject);
                },
                sclae: 1.03,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 6.wMin),
                  decoration: BoxDecoration(
                    color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8.wMin),
                    border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceBrand.color),
                  ),
                  child: Column(
                    children: [
                      Text("音频项目", style: TextStyle(fontSize: 18.wMin, color: AppTheme.cSurfaceBrand.color)),
                      SizedBox(height: 4.wMin),
                      Text(audioProject?.status??"", style: TextStyle(fontSize: 14.wMin, color: AppTheme.cSurfaceBrand.color)),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Visibility(
            visible: audioProject == null,
            child: ButtonWidget(
              text: "创建音频项目",
              padding: EdgeInsets.symmetric(horizontal: 10.wMin),
              height: 44.wMin,
              color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
              border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceBrand.color),
              borderRadius: 8.wMin,
              fontSize: 18.wMin,
              fontColor: AppTheme.cSurfaceBrand.color,
              sclae: 1.03,
              onTap: () {
                controller.createAudioProject();
              },
            ),
          ),

          SizedBox(height: 12.wMin),

          ButtonWidget(
            text: "查看全文",
            padding: EdgeInsets.symmetric(horizontal: 10.wMin),
            height: 44.wMin,
            color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
            border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceBrand.color),
            borderRadius: 8.wMin,
            fontSize: 18.wMin,
            fontColor: AppTheme.cSurfaceBrand.color,
            sclae: 1.03,
            onTap: () {
              controller.viewFull(context);
            },
          ),
          ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.dramaScriptSceneEdit, ManageAuthCode.dramaScriptDialogueEdit],
            margin: EdgeInsets.only(top: 12.wMin),
            child: ButtonWidget(
              text: "保存全部",
              padding: EdgeInsets.symmetric(horizontal: 10.wMin),
              height: 44.wMin,
              color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
              border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceBrand.color),
              borderRadius: 8.wMin,
              fontSize: 18.wMin,
              fontColor: AppTheme.cSurfaceBrand.color,
              sclae: 1.03,
              onTap: () {
                controller.saveAllEdit();
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildListWidget(){
    return Obx((){
      return ListView.separated(
        itemCount: controller.sceneList.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (context, index) => SizedBox(height: 24.wMin),
        itemBuilder: (context, index) {
          return ManageScriptSceneWidget(controller: controller, scene: controller.sceneList[index]);
        },
      );
    });
  }


}
