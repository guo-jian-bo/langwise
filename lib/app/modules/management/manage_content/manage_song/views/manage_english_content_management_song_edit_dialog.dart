import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:langwise/app/modules/management/common/manage_button.dart';
import 'package:langwise/app/modules/management/common/manage_content_input_widget.dart';
import 'package:langwise/app/modules/management/common/manage_select_option_widget.dart';
import 'package:langwise/app/modules/management/common/manage_title_input_widget.dart';
import 'package:langwise/app/modules/management/common/manage_title_widget.dart';
import 'package:langwise/common/mixins/mixins.dart';
import 'package:langwise/common/static/static_data.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../../../../common/entities/entities.dart';
import '../controllers/manage_edit_song_controller.dart';

class ManageEditSongManager {
  static Future<EnKnowledgeEntity?> show({
    required BuildContext context,
    required EnKnowledgeEntity entity,
    void Function(int index)? onTap,
  }) async {
    return await showCupertinoDialog<EnKnowledgeEntity?>(
      context: context,
      builder: (context) {
        return ManageEditSongView(
          entity: entity,
        );
      },
    );
  }
}

class ManageEditSongView extends GetView<ManageEditSongController> with GetViewMixin {
  final EnKnowledgeEntity entity;

  const ManageEditSongView({super.key, required this.entity});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ManageEditSongController>(
      init: ManageEditSongController(entity),
      id: "manage_edit_song",
      builder: (context) {
        return LayoutBuilder(builder: (context, constraints) {
          return Scaffold(
            backgroundColor: const Color(0xff040712).withValues(alpha: 0.8),
            body: Center(
              child: Container(
                width: 1080.ww,
                height: 980.wh,
                padding: EdgeInsets.symmetric(horizontal: 24.ww, vertical: 24.wh),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.wMin),
                  border: Border.all(
                    color: const Color(0xff444B5F),
                    width: 1.wMin, // 边框宽度
                  ),
                  color: const Color(0xff181B25),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ManageTitleWidget(
                      title: "编辑歌曲",
                      onCloseTap: () {
                        Get.back();
                      },
                    ),
                    Gaps.getHeight(35.wh),
                    _buildContentWidget(context),
                    Gaps.getHeight(24.wh),
                    _buildBottomWidget(),
                  ],
                ),
              ),
            ),
          );
        });
      }
    );
  }

  /// 主视图
  Widget _buildContentWidget(BuildContext context) {
    return Container(
      height: 780.wh,
      padding: EdgeInsets.symmetric(horizontal: 16.ww, vertical: 16.wh),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: const Color(0xff22293C),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            ManageTitleInputWidget(
              title: "标题",
              hintText: '请填写文章标题',
              required: true,
              controller: controller.titleController,
              readOnly: false,
            ),
            Gaps.getHeight(24.wh),
            ManageContentInputWidget(
              title: "内容",
              hintText: '请填写文章内容',
              required: true,
              controller: controller.contentController,
              textInputAction: TextInputAction.newline,
              height: 250.wh,
              maxLines: 500,
              padding: EdgeInsets.symmetric(horizontal: 12.ww, vertical: 12.ww),
            ),
            Gaps.getHeight(24.wh),
            ManageSelectWidget(
              title: "上架状态",
              hintText: '请选择上架状态',
              value: controller.newAccessName,
              readOnly: false,
              required: true,
              options: StaticData.getOnOffShelfForCreateOrEditNames,
              onChanged: (String value, int index) {
                controller.setAccess(index);
              },
            ),
            Gaps.getHeight(24.wh),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ManageButton(
          text: "取消",
          width: 80.ww,
          height: 40.wh,
          borderColor: const Color(0xff666F8D),
          style: TextStyle(
            fontSize: 14.wMin,
            color: const Color(0xffEBEEF3),
            fontWeight: FontWeight.w400,
          ),
          onTap: () {
            Get.back();
          },
        ),
        SizedBox(width: 11.ww),
        ManageButton(
          text: "确定",
          width: 80.ww,
          height: 40.wh,
          color: !controller.uploadButtonFlag ? const Color(0xff353E5C) : const Color(0xff2388FF),
          borderColor: Colors.transparent,
          style: TextStyle(
            fontSize: 14.wMin,
            color: controller.uploadButtonFlag ? const Color(0xffEBEEF3) : const Color(0xffACB4C0),
            fontWeight: FontWeight.w400,
          ),
          onTap: !controller.uploadButtonFlag
              ? null
              : OptimizeUtils.noneThrottle(() {
                  controller.onEditSong();
                }, 100),
        ),
      ],
    );
  }
}
