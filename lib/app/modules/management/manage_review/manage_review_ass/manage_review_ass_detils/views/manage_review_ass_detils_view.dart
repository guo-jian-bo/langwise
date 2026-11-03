import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/enum/enum.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/ass_edit_widgets/ass_edit_widget.dart';
import '../../../../common/ass_edit_widgets/editor_sidebar_btn_widget.dart';
import '../../../../common/commons.dart';
import '../../../../utils/utils.dart';
import '../bindings/manage_review_ass_detils_binding.dart';
import '../controllers/manage_review_ass_detils_controller.dart';

class ManageReviewAssDetilsView extends GetView<ManageReviewAssDetilsController> {
  final String tagText;
  const ManageReviewAssDetilsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_REVIEW_ASS_DETILS}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageReviewAssDetilsView(tagText: tag),
      binding: ManageReviewAssDetilsBinding(tag: tag),
      routeName: Routes.MANAGE_REVIEW_ASS_DETILS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      showCollectButton: false,
      body: Obx(() {
        if(controller.assData.value.mediaUrl == null){
          return Container();
        }

        bool isPreview = controller.assData.value.contentTypeEnum == ElementsCardType.song 
        || controller.assData.value.contentTypeEnum == ElementsCardType.reveal
        || controller.assData.value.contentTypeEnum == ElementsCardType.text;

        return SizedBox.expand(
          child: AssEditWidget(
            mediaUrl: controller.assData.value.mediaUrl ?? "",
            mediaType: controller.assData.value.mediaTypeEnum,
            ass: controller.assData.value.ass ?? "",
            hideAddSentence: controller.hideAddSentence,
            hideTranslation: true,
            
            playbackRate: UserStore.to.userInfo.value.config?.playSpeed??1.0,
            // translateAss: controller.assData.value.translate?.firstWhereOrNull((item) => item?.lang == 'zh')?.text,
            onChanged: (value) {
              controller.saveEditAss(value);
            },
            envelopeTopFloatWidget: Visibility(
              visible: (controller.assData.value.lines??[]).isNotEmpty,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 70.wMin),
                margin: EdgeInsets.only(bottom: 10.wMin),
                child: Row(
                  children: [
                    Text(
                      "台词",
                      style: TextStyle(
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.cTextPrimary.color,
                      ),
                    ),
                    SizedBox(width: 20.wMin),
                    Text(
                      controller.assData.value.lines?.join(" / ")??"",
                      style: TextStyle(
                        fontSize: 16.wMin,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.cTextBrand.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            rightToolButtons: [

              if(isPreview) EditorSidebarBtnWidget(
                text: "预览",
                color: AppTheme.cSurfaceBrand.color,
                onTap: () {
                  controller.previewAss(context);
                },
              ),

            ],
          ),
        );
      }),
      bottomNavigationBar: _buildBottomWidget(context),
    );
  }



  Widget _buildBottomWidget(BuildContext context){

    if(controller.assId != null){
      return Container(
        height: 70.wMin,
        padding: EdgeInsets.symmetric(horizontal: 40.wMin),
        child: Row(
          children: [

            ManageAuthBoxWidget(
              authCodes: const [ManageAuthCode.adminAssReviewTaskAlignAudioCreate],
              child: ButtonWidget(
                text: "新建字幕",
                padding: EdgeInsets.symmetric(horizontal: 12.wMin),
                height: 40.wMin,
                borderRadius: 6.wMin,
                color: ResourceAlignEnum.align.color.withValues(alpha: 0.2),
                border: Border.all(width: 1.wMin, color: ResourceAlignEnum.align.color),
                fontColor: ResourceAlignEnum.align.color,
                fontSize: 16.wMin,
                fontWeight: FontWeight.w500,
                sclae: 1.05,
                onTap: () {
                  controller.assReviewCreateAlign();
                },
              ),
            ),

            ManageAuthBoxWidget(
              authCodes: const [ManageAuthCode.adminAssReviewTaskTranslateCreate],
              margin: EdgeInsets.only(left: 16.wMin),
              child: ButtonWidget(
                text: "新建翻译",
                padding: EdgeInsets.symmetric(horizontal: 12.wMin),
                height: 40.wMin,
                borderRadius: 6.wMin,
                color: ResourceAlignEnum.translate.color.withValues(alpha: 0.2),
                border: Border.all(width: 1.wMin, color: ResourceAlignEnum.translate.color),
                fontColor: ResourceAlignEnum.translate.color,
                fontSize: 16.wMin,
                fontWeight: FontWeight.w500,
                sclae: 1.05,
                onTap: () {
                  controller.assReviewCreateTranslate();
                },
              ),
            ),

            const Spacer(),

            Obx((){
              int? assRelationId = controller.assData.value.assRelationId;
              if(assRelationId == null) return Container();
              bool assLocked = controller.assData.value.assLocked == true;
              return ManageAuthBoxWidget(
                authCodes: [assLocked ? ManageAuthCode.adminAssReviewAssUnlock : ManageAuthCode.adminAssReviewAssLock],
                margin: EdgeInsets.only(left: 16.wMin),
                child: ButtonWidget(
                  text: "字幕定稿",
                  padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                    border: Border.all(width: 1.wMin, color: AppTheme.cFeedbackSuccessBorder.color),
                    fontColor: assLocked ? AppTheme.cFeedbackErrorText.color : AppTheme.cFeedbackSuccessText.color,
                    color: assLocked ? AppTheme.cFeedbackErrorBackground.color : AppTheme.cFeedbackSuccessBackground.color,
                    sclae: 1.03,
                    borderRadius: 6.wMin,
                    fontSize: 16.wMin,
                    height: 40.wMin,
                    leftIcon: Container(
                      margin: EdgeInsets.only(right: 6.wMin),
                      child: SvgPicture.asset(
                        assLocked ? "assets/svg/manage/icon_resource_lock.svg" : "assets/svg/manage/icon_resource_unlock.svg",
                        width: 16.wMin,
                      ),
                    ),
                  onTap: () {
                    if(assLocked){
                      controller.cancelFinalDraftAss(context);
                    }else{
                      controller.finalDraftAss(context);
                    }
                  },
                ),
              );
            }),



          ],
        ),
      );
    }


    ElementsCardType contentTypeEnum = controller.assData.value.contentTypeEnum;

    return Container(
      height: 70.wMin,
      padding: EdgeInsets.only(
        left: 40.wMin,
        right: 40.wMin,
      ),
      child: Obx((){
        return Row(
          children: [
      
            SelectableText(
              "任务UID：${controller.assData.value.taskId??''}",
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
              DateFormatUtil.formatStrtoStr(controller.assData.value.started, newPattern: "yyyy-MM-dd HH:mm"),
              style: TextStyle(
                fontSize: 14.wMin,
                color: AppTheme.cTextTertiary.color,
                fontWeight: FontWeight.w400,
              ),
            ),
      
            const Spacer(),
            
            ManageAuthBoxWidget(
              authCodes: const [ManageAuthCode.adminAssReviewAssTaskDelete],
              child: ButtonWidget(
                text: "删除任务",
                padding: EdgeInsets.symmetric(horizontal: 12.wMin),
                height: 40.wMin,
                borderRadius: 6.wMin,
                color: AppTheme.cSurfaceError.color.withValues(alpha: 0.2),
                border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceError.color),
                fontColor: AppTheme.cSurfaceError.color,
                fontSize: 16.wMin,
                fontWeight: FontWeight.w500,
                sclae: 1.05,
                onTap: () {
                  controller.deleteTask(context);
                },
              ),
            ),

            Visibility(
              visible: !UserStore.to.rolePermissions.value.userIsAssSuperReviewer,// 高级审核员不允许放弃
              child: Container(
                margin: EdgeInsets.only(left: 12.wMin),
                child: ButtonWidget(
                  text: "放弃任务",
                  padding: EdgeInsets.symmetric(horizontal: 12.wMin),
                  height: 40.wMin,
                  borderRadius: 6.wMin,
                  color: AppTheme.cSurfaceError.color.withValues(alpha: 0.2),
                  border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceError.color),
                  fontColor: AppTheme.cSurfaceError.color,
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w500,
                  sclae: 1.05,
                  onTap: () {
                    controller.assReviewAbandon(context);
                  },
                ),
              ),
            ),

            ManageAuthBoxWidget(
              authCodes: [ controller.assData.value.mediaTypeEnum == ResourceTypeEnum.audio ? ManageAuthCode.adminAssReviewTaskAlignAudioCreate : ManageAuthCode.adminAssReviewTaskAlignVideoCreate],
              margin: EdgeInsets.only(left: 12.wMin),
              child: ButtonWidget(
                text: "删除并新建",
                padding: EdgeInsets.symmetric(horizontal: 12.wMin),
                height: 40.wMin,
                borderRadius: 6.wMin,
                color: AppTheme.cSurfaceError.color.withValues(alpha: 0.2),
                border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceError.color),
                fontColor: AppTheme.cSurfaceError.color,
                fontSize: 16.wMin,
                fontWeight: FontWeight.w500,
                sclae: 1.05,
                onTap: () {
                  controller.assReviewDeleteCreateAlign(context);
                },
              ),
            ),
      
            Container(
              margin: EdgeInsets.only(left: 12.wMin),
              child: ButtonWidget(
                text: contentTypeEnum == ElementsCardType.phrase || contentTypeEnum == ElementsCardType.sentence ? "审核通过" : "审核通过并生成翻译",
                padding: EdgeInsets.symmetric(horizontal: 12.wMin),
                height: 40.wMin,
                borderRadius: 6.wMin,
                color: AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.2),
                border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceSuccess.color),
                fontColor: AppTheme.cSurfaceSuccess.color,
                fontSize: 16.wMin,
                fontWeight: FontWeight.w500,
                sclae: 1.03,
                onTap: () {
                  controller.assReviewAssApprove(context);
                },
              ),
            ),
      
          ],
        );
      }),
    );
  }

}
