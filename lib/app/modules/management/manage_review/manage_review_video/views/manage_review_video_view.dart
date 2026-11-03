import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/utils/utils.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../common/widgets/widgets.dart';
import '../../../../../routes/routes.dart';
import '../../../common/commons.dart';
import '../bindings/manage_review_video_binding.dart';
import '../controllers/manage_review_video_controller.dart';
import '../model/video_rame_mode_enum.dart';
import '../../../enums/video_task_status_enum.dart';
import 'manage_review_item_widget.dart';

class ManageReviewVideoView extends GetView<ManageReviewVideoController> {
  final String tagText;
  const ManageReviewVideoView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_REVIEW_VIDEO}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageReviewVideoView(tagText: tag),
      binding: ManageReviewVideoBinding(tag: tag),
      routeName: Routes.MANAGE_REVIEW_VIDEO,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      body: Column(
        children: [
          _buildFilterHeardWidget(),
          Expanded(child: _buildListWidget(context)),
        ],
      ),
    );
  }


  Widget _buildFilterHeardWidget(){
    
    return Container( 
      padding: EdgeInsets.symmetric(horizontal: 40.wMin, vertical: 6.wMin),
      color: AppTheme.cSurfaceSecondary.color,
      child: Row(
        children: [
          Expanded(
            child: Visibility(
              visible: controller.subContent != null,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Obx((){
                  // 全部
                  int all = controller.originalTaskList.where((element) => element.status == VideoTaskStatusEnum.image_checking.value || element.status == VideoTaskStatusEnum.finished.value).length;
                  // 图片待审核
                  int imageChecking = controller.originalTaskList.where((element) => element.status == VideoTaskStatusEnum.image_checking.value).length;
                  // 视频生成中
                  // int videoGenerating = controller.originalTaskList.where((element) => element.status == VideoTaskStatusEnum.video_generating.value).length;
                  // 视频待审核
                  int videoFinished = controller.originalTaskList.where((element) => element.status == VideoTaskStatusEnum.finished.value).length;
                  // 视频已审核
                  // int videoChecked = controller.originalTaskList.where((element) => element.status == VideoTaskStatusEnum.checked.value).length;
                  // 视频生成失败
                  int videoFailed = controller.originalTaskList.where((element) => element.status == VideoTaskStatusEnum.failed.value).length;
                  return Row(
                    spacing: 8.wMin,
                    children: [
                      Text(
                        "状态:",
                        style: TextStyle(
                          fontSize: 16.wMin,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.cTextPrimary.color,
                        ),
                      ),
                      _buildFilterStatusItemWidget(VideoTaskStatusEnum.all_pending_review, all),
                      _buildFilterStatusItemWidget(VideoTaskStatusEnum.finished, videoFinished),
                      _buildFilterStatusItemWidget(VideoTaskStatusEnum.image_checking, imageChecking),
                      // _buildFilterStatusItemWidget(VideoTaskStatusEnum.video_generating, videoGenerating),
                      // _buildFilterStatusItemWidget(VideoTaskStatusEnum.checked, videoChecked),
                      _buildFilterStatusItemWidget(VideoTaskStatusEnum.failed, videoFailed),
                
                      SizedBox(width: 42.wMin),
                
                      Text(
                        "模式:",
                        style: TextStyle(
                          fontSize: 16.wMin,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.cTextPrimary.color,
                        ),
                      ),
                      Row(
                        spacing: 8.wMin,
                        children: List.generate(VideoRameModeEnum.values.length, (index){
                          return _buildFilterRameItemWidget(VideoRameModeEnum.values[index]);
                        }),
                      ),
                      
                    ],
                  );
                }),
              ),
            ),
          ),

          Obx((){
            return SelectableText(
              "${controller.originalTaskList.length}个待审核",
              style: TextStyle(
                fontSize: 18.wMin,
                color: AppTheme.cSurfaceWarning.color,
              ),
            );
          }),

          SizedBox(width: 16.wMin),

          ManageButton(
            text: "审核历史",
            height: 50.wMin,
            padding: EdgeInsets.symmetric(horizontal: 20.wMin),
            color: const Color(0xff353E5C),
            borderColor: Colors.transparent,
            sclae: 1.03,
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
            onTap: () {
              controller.toVideoReviewHistory(false);
            },
          ),
      
          ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.videoReviewAuditHistory],
            margin: EdgeInsets.only(left: 16.wMin),
            child: ManageButton(
              text: "管理员",
              height: 50.wMin,
              padding: EdgeInsets.symmetric(horizontal: 20.wMin),
              color: const Color(0xff353E5C),
              borderColor: Colors.transparent,
              sclae: 1.03,
              style: TextStyle(
                fontSize: 20.wMin,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
              onTap: () {
                controller.toVideoReviewHistory(true);
              },
            ),
          ),

        ],
      ),
    );
  }

  /// 状态筛选item
  Widget _buildFilterStatusItemWidget(VideoTaskStatusEnum status, int count){

    return Obx((){
      bool selected = controller.statusFilter.value == status;

      return TapScaleWidget(
        onTap: () {
          controller.chanageFilterStatus(status);
        },
        sclae: 1.03,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
          decoration: BoxDecoration(
            color: selected ? status.bg : AppTheme.cInverseOverlay4.color,
            borderRadius: BorderRadius.circular(6.wMin),
          ),
          child: Row(
            children: [
              Text(
                status.name,
                style: TextStyle(
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w400,
                  color: selected ? status.font : AppTheme.cTextTertiary.color,
                ),
              ),
              SizedBox(width: 8.wMin),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w400,
                  color: selected ? status.font : AppTheme.cTextSecondary.color,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  /// 帧模式筛选item
  Widget _buildFilterRameItemWidget(VideoRameModeEnum ream){

    return Obx((){
      bool selected = controller.rameMode.value == ream;

      return TapScaleWidget(
        onTap: () {
          controller.chanageFilterRameMode(ream);
        },
        sclae: 1.03,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
          decoration: BoxDecoration(
            color: selected ? AppTheme.cInverseOverlay3.color : AppTheme.cInverseOverlay4.color,
            borderRadius: BorderRadius.circular(6.wMin),
          ),
          child: Text(
            ream.name,
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: selected ? AppTheme.cInverseTextLight.color : AppTheme.cTextTertiary.color,
            ),
          ),
        ),
      );
    });
  }



  Widget _buildListWidget(BuildContext context){
    return Obx((){
      if(controller.loadStatus.value == -1){
        return Container();
      }
      if(controller.taskList.isEmpty){
        return _buildEmptyWidget(context);
      }
      return ListView.separated(
        itemCount: controller.taskList.length,
        padding: EdgeInsets.only(
          top: 16.wMin,
          bottom: 120.wMin + MediaQuery.of(context).padding.bottom,
          left: 40.wMin,
          right: 40.wMin,
        ),
        separatorBuilder: (context, index) {
          return SizedBox(height: 24.wMin);
        },
        itemBuilder: (context, index) {
          return ManageReviewItemWidget(
            data: controller.taskList[index],
            controller: controller,
          );
        },
      );
    });
  }

  Widget _buildEmptyWidget(BuildContext context){
    if(controller.isSubConditionQuery.value){
      return const NotDataWidget(
        message: "暂无任务",
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          "assets/svg/public/not_data.svg",
          width: 200.wMin,
        ),
        Text(
          "没有待审核的视频",
          style: TextStyle(
            fontSize: 32.wMin,
            color: AppTheme.cTextPrimary.color,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          "所有视频都已审核完成",
          style: TextStyle(
            fontSize: 32.wMin,
            color: AppTheme.cTextSecondary.color,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 50.wMin),
        ButtonWidget(
          text: "再审核一批",
          height: 58.wMin,
          width: 180.wMin,
          borderRadius: 6.wMin,
          color: AppTheme.cSurfaceBrand.color,
          sclae: 1.03,
          fontSize: 24.wMin,
          fontColor: Colors.white,
          onTap: () {
            controller.getVideoTaskAnotherBatch();
          },
          
        ),
      ],
    );

  }




}
