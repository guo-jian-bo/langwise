import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/stores/stores.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../../../../utils/utils.dart';
import '../bindings/manage_review_ass_translate_binding.dart';
import '../controllers/manage_review_ass_translate_controller.dart';
import '../models/manage_ass_sentence_model.dart';

class ManageReviewAssTranslateView extends GetView<ManageReviewAssTranslateController> {
  final String tagText;
  const ManageReviewAssTranslateView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_REVIEW_ASS_TRANSLATE}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageReviewAssTranslateView(tagText: tag),
      binding: ManageReviewAssTranslateBinding(tag: tag),
      routeName: Routes.MANAGE_REVIEW_ASS_TRANSLATE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      showCollectButton: false,
      body: Container(
        padding: EdgeInsets.only(
          left: MediaQuery.of(context).padding.left,
          right: MediaQuery.of(context).padding.right,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTagHeardWidget(),
            _buildTitleWidget(),
            Expanded(child: _buildListWidget(context)),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomWidget(context),
    );
  }

  Widget _buildBottomWidget(BuildContext context) {

    if(controller.assId != null){
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 40.wMin),
        padding: EdgeInsets.only(
          top: 10.wMin,
          bottom: 16.wMin,
        ),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
          ),
        ),
        child: Row(
          children: [
            Obx((){
              return SelectableText(
                "assID：${controller.assData.value.assId ?? ''}",
                style: TextStyle(
                  fontSize: 14.wMin,
                  color: AppTheme.cTextTertiary.color,
                  fontWeight: FontWeight.w400,
                ),
              );
            }),
            const Spacer(),

            Obx((){
              List<ManageAssSentenceModel> list = controller.assList.where((e) => e.isSuperfluous).toList();
              if(list.isEmpty) return Container(height: 0);
              return Container(
                margin: EdgeInsets.only(left: 12.wMin),
                child: ButtonWidget(
                  text: "清理多余翻译",
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
                    controller.deleteSuperfluous();
                  },
                ),
              );
            }),

            Container(
              margin: EdgeInsets.only(left: 12.wMin),
              child: Obx(() {
                return ButtonWidget(
                  text: "保存全文",
                  width: 88.wMin,
                  height: 40.wMin,
                  borderRadius: 6.wMin,
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w500,
                  color: (controller.allInputIsChange.value ? AppTheme.cSurfaceWarning.color : AppTheme.cTextTertiary.color).withValues(alpha: 0.2),
                  border: Border.all(
                    width: 1.wMin, 
                    color: controller.allInputIsChange.value ? AppTheme.cSurfaceWarning.color : AppTheme.cTextTertiary.color,
                  ),
                  fontColor: controller.allInputIsChange.value ? AppTheme.cSurfaceWarning.color : AppTheme.cTextTertiary.color,
                  sclae: 1.03,
                  onTap: () {
                    controller.saveEditAssAll();
                  },
                );
              }),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40.wMin),
      padding: EdgeInsets.only(
        top: 10.wMin,
        bottom: 16.wMin,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
        ),
      ),
      child: Obx(() {
        return Row(
          children: [
            SelectableText(
              "任务UID：${controller.assData.value.taskId ?? ''}",
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
              visible: !UserStore.to.rolePermissions.value.userIsAssSuperReviewer, // 高级审核员不允许放弃
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

            Obx((){
              List<ManageAssSentenceModel> list = controller.assList.where((e) => e.isSuperfluous).toList();
              if(list.isEmpty) return Container(height: 0);
              return Container(
                margin: EdgeInsets.only(left: 12.wMin),
                child: ButtonWidget(
                  text: "清理多余翻译",
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
                    controller.deleteSuperfluous();
                  },
                ),
              );
            }),

            Container(
              margin: EdgeInsets.only(left: 12.wMin),
              child: Obx(() {
                return ButtonWidget(
                  text: "保存全文",
                  width: 88.wMin,
                  height: 40.wMin,
                  borderRadius: 6.wMin,
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w600,
                  color: (controller.allInputIsChange.value ? AppTheme.cSurfaceWarning.color : AppTheme.cTextTertiary.color).withValues(alpha: 0.2),
                  border: Border.all(
                    width: 1.wMin, 
                    color: controller.allInputIsChange.value ? AppTheme.cSurfaceWarning.color : AppTheme.cTextTertiary.color,
                  ),
                  fontColor: controller.allInputIsChange.value ? AppTheme.cSurfaceWarning.color : AppTheme.cTextTertiary.color,
                  sclae: 1.03,
                  onTap: () {
                    controller.saveEditAssAll();
                  },
                );
              }),
            ),
            ManageAuthBoxWidget(
              authCodes: const [ManageAuthCode.adminAssReviewTaskTranslateCreate],
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
                  controller.assReviewDeleteCreateTranslate(context);
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 12.wMin),
              child: ButtonWidget(
                text: "审核通过",
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

  Widget _buildTagHeardWidget() {
    return Container(
      margin: EdgeInsets.only(top: 16.wMin),
      padding: EdgeInsets.symmetric(horizontal: 40.wMin),
      child: Obx(() {
        ElementsCardColor? typeColor = StatusUtils.getElementsCardColor(controller.assData.value.contentType);

        return Row(
          spacing: 8.wMin,
          children: [
            ManageTagFS16Widget(
              tag: controller.assData.value.contentType,
              bgColor: typeColor?.color1,
            ),
            StatusTagDifficultyWidget(
              difficulty: controller.assData.value.difficulty,
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
                    "${controller.assData.value.duration ?? 0}s",
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
              tag: controller.assData.value.mediaTypeEnum.name,
              fontColor: controller.assData.value.mediaTypeEnum.color,
            ),
            ManageTagFS16Widget(
              tag: controller.assData.value.stageEnum.name,
              fontColor: controller.assData.value.stageEnum.color,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTitleWidget() {
    return Obx(() {
      if (controller.assData.value.title == null) return Container();
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 40.wMin, vertical: 16.wMin),
        child: Text(
          controller.assData.value.title ?? "",
          style: TextStyle(
            fontSize: 28.wMin,
            fontWeight: FontWeight.w600,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
      );
    });
  }

  /// 列表
  Widget _buildListWidget(BuildContext context) {
    return Obx(() {
      return ListView.separated(
        padding: EdgeInsets.only(
          left: 40.wMin,
          right: 40.wMin,
          top: 10.wMin,
          bottom: 40.wMin,
        ),
        itemCount: controller.assList.length,
        separatorBuilder: (context, index) {
          return SizedBox(height: 12.wMin);
        },
        itemBuilder: (context, index) {
          return _buildListItemWidget(context, controller.assList[index], index);
        },
      );
    });
  }

  Widget _buildListItemWidget(BuildContext context, ManageAssSentenceModel data, int index) {
    return TapScaleWidget(
      onTap: () {
        if(data.isSuperfluous) return;
        data.focusNode.requestFocus();
      },
      sclae: 1,
      child: Obx(() {
        bool selected = controller.currentEditIndex.value == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: EdgeInsets.all(12.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(selected ? 12.wMin : 0),
            color: AppTheme.cSurfacePrimary.color.withValues(alpha: selected ? 1 : 0),
            border: Border(
              bottom: BorderSide(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SelectableText(
                  data.sentence.words.map((e) => "${e.leftSpace}${e.text}${e.rightSpace}").join(''),
                  style: TextStyle(
                    fontSize: 32.wMin,
                    color: AppTheme.cTextPrimary.color.withValues(alpha: selected ? 0.8 : 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(
                width: 711.wMin,
                child: _buildListItemInputWidget(context, data, index, selected),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildListItemInputWidget(BuildContext context, ManageAssSentenceModel data, int index, bool selected) {
    return Container(
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: selected ? AppTheme.cFeedbackWarningBackground.color : AppTheme.cSurfaceSecondary.color,
        border: Border.all(
          width: 1.wMin,
          color: selected ? AppTheme.cFeedbackWarningBorder.color : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Visibility(
            visible: data.isSuperfluous,
            child: Text(
              "多余翻译",
              style: TextStyle(
                fontSize: 16.wMin,
                color: AppTheme.cSurfaceError.color,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          TextField(
            controller: data.translationInput,
            focusNode: data.focusNode,
            maxLines: null,
            style: TextStyle(
              fontSize: 22.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w500,
            ),
            readOnly: data.isSuperfluous,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              counterText: "",
              hintText: "请输入翻译",
              hintStyle: TextStyle(
                fontSize: 22.wMin,
                color: AppTheme.cTextTertiary.color,
                fontWeight: FontWeight.w400,
              ),
            ),
            onTapOutside: (event) {
              FocusScope.of(context).unfocus();
            },
            onChanged: (value) {
              controller.inputIsChange(data);
            },
          ),

          Container(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
            
                Visibility(
                  visible: !data.isSuperfluous,
                  child: ButtonWidget(
                    text: "保存翻译",
                    width: 88.wMin,
                    height: 40.wMin,
                    borderRadius: 6.wMin,
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w500,
                    color: (data.inputChange ? AppTheme.cSurfaceWarning.color : AppTheme.cTextTertiary.color).withValues(alpha: 0.2),
                    border: Border.all(
                      width: 1.wMin,
                      color: data.inputChange ? AppTheme.cSurfaceWarning.color : AppTheme.cTextTertiary.color,
                    ),
                    fontColor: data.inputChange ? AppTheme.cSurfaceWarning.color : AppTheme.cTextTertiary.color,
                    sclae: 1.03,
                    onTap: () {
                      if(!data.inputChange) return;
                      controller.saveEditAss(data, index);
                    },
                  ),
                ),
            
              ],
            ),
          ),
        ],
      ),
    );
  }
}


