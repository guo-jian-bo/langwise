import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/enum/enum.dart';
import '../../../../../../utils/utils.dart';
import '../../../../../routes/routes.dart';
import '../../../common/commons.dart';
import '../../../utils/utils.dart';
import '../bindings/manage_review_ass_binding.dart';
import '../controllers/manage_review_ass_controller.dart';

class ManageReviewAssView extends GetView<ManageReviewAssController> {
  final String tagText;
  const ManageReviewAssView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_REVIEW_ASS}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageReviewAssView(tagText: tag),
      binding: ManageReviewAssBinding(tag: tag),
      routeName: Routes.MANAGE_REVIEW_ASS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      body: Column(
        children: [
          _buildHeardWidget(),
          Expanded(child: _buildListWidget(context)),
        ],
      ),
    );
  }

  /// 头部
  Widget _buildHeardWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40.wMin, vertical: 6.wMin),
      color: AppTheme.cSurfaceSecondary.color,
      child: Row(
        children: [
          const Spacer(),
          Obx((){
            return SelectableText(
              "${controller.taskList.length}个待审核",
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
              controller.toReviewHistory(false);
            },
          ),
      
          ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.adminAssReviewAssAuditHistory],
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
                controller.toReviewHistory(true);
              },
            ),
          ),
        ],
      ),
    );
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
        padding: EdgeInsets.all(40.wMin),
        separatorBuilder: (context, index) {
          return SizedBox(height: 16.wMin);
        },
        itemBuilder: (context, index) {
          return _buildListItemWidget(context, controller.taskList[index], index);
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
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            "assets/svg/public/not_data.svg",
            width: 200.wMin,
          ),
          Text(
            "没有待审核的字幕",
            style: TextStyle(
              fontSize: 32.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            "所有字幕都已审核完成",
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
              controller.getAssTaskAnotherBatch();
            },
            
          ),
        ],
      ),
    );

  }


  Widget _buildListItemWidget(BuildContext context, AssTaskEntityList data, int index){
    return TapScaleWidget(
      onTap: () {
        controller.toReviewAss(data);
      },
      sclae: 1,
      child: Container(
        padding: EdgeInsets.all(16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cSurfaceSecondary.color,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTagWidget(data),
            SizedBox(height: 8.wMin),
            _buildContentWidget(data),
            SizedBox(height: 8.wMin),
            _buildBottomWidget(context, data),
          ],
        ),
      ),
    );
  }

  Widget _buildTagWidget(AssTaskEntityList data){
    ElementsCardColor? typeColor = StatusUtils.getElementsCardColor(data.contentType);
    
    return Row(
      spacing: 8.wMin,
      children: [
        ManageTagFS16Widget(
          tag: data.contentType,
          bgColor: typeColor?.color1,
        ),
        StatusTagDifficultyWidget(
          difficulty: data.difficulty,  
          fontSize: 16.wMin,
          language: "en",
        ),
        Container(width: 1.wMin, height: 18.wMin, color: AppTheme.cBorderTertiary.color),

        Container(
          padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 2.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.wMin),
            color: AppTheme.cSurfaceQuaternary.color,
          ),
          child: Row(
            spacing: 4.wMin,
            children: [
              SvgPicture.asset(
                "assets/svg/public/icon_clock_w.svg",
                width: 18.wMin,
                colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
              ),
              SelectableText(
                "${data.duration??0}s",
                style: TextStyle(
                  fontSize: 16.wMin,
                  color: AppTheme.cTextSecondary.color,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),

        ManageTagFS16Widget(
          tag: data.mediaTypeEnum.name,
          fontColor: data.mediaTypeEnum.color,
        ),
        ManageTagFS16Widget(
          tag: data.stageEnum.name,
          fontColor: data.stageEnum.color,
        ),

        const Spacer(),

      ],
    );
  }

  Widget _buildContentWidget(AssTaskEntityList data){
    ElementsCardType contentType = ElementsCardType.fromRawValue(data.contentType??"");

    if(contentType == ElementsCardType.word || contentType == ElementsCardType.phrase || contentType == ElementsCardType.sentence){
      return Text(
        data.content ?? "",
        style: TextStyle(
          fontSize: 24.wMin,
          fontWeight: FontWeight.w500,
          color: AppTheme.cTextPrimary.color,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: data.title != null,
          child: Text(
            data.title ??"",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
        ),

        Visibility(
          visible: data.content != null,
          child: Text(
            data.content ??"",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
        ),

        Visibility(
          visible: data.definition != null,
          child: Text(
            data.definition ??"",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
        ),

      ],
    );
  }


  Widget _buildBottomWidget(BuildContext context, AssTaskEntityList data){
    return Container(
      padding: EdgeInsets.only(top: 16.wMin),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(width: 1.wMin, color: AppTheme.cBorderPrimary.color)),
      ),
      child: Row(
        children: [
    
          SelectableText(
            "任务UID：${data.taskId??''}",
            style: TextStyle(
              fontSize: 14.wMin,
              color: AppTheme.cTextTertiary.color,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(width: 8.wMin),
          Container(width: 1.wMin, height: 20.wMin, color: AppTheme.cBorderPrimary.color),
          SizedBox(width: 8.wMin),
          SelectableText(
            DateFormatUtil.formatStrtoStr(data.started, newPattern: "yyyy-MM-dd HH:mm"),
            style: TextStyle(
              fontSize: 14.wMin,
              color: AppTheme.cTextTertiary.color,
              fontWeight: FontWeight.w400,
            ),
          ),
    
          const Spacer(),
    
          Container(
            margin: EdgeInsets.only(left: 12.wMin),
            child: ButtonWidget(
              text: "审核${data.stageEnum == ResourceAlignEnum.align ? '字幕': '翻译'}",
              padding: EdgeInsets.symmetric(horizontal: 12.wMin),
              height: 40.wMin,
              borderRadius: 6.wMin,
              color: AppTheme.cSurfaceInfo.color.withValues(alpha: 0.2),
              border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceInfo.color),
              fontColor: AppTheme.cSurfaceInfo.color,
              fontSize: 16.wMin,
              fontWeight: FontWeight.w500,
              sclae: 1.05,
            ),
          ),
    
        ],
      ),
    );
  }


}
