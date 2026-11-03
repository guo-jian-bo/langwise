import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_button.dart';
import 'package:langwise/app/modules/management/common/manage_select_option_widget.dart';
import 'package:langwise/app/modules/management/common/manage_title_input_widget.dart';
import 'package:langwise/app/modules/management/common/manage_title_widget.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'controller.dart';
import 'views/phonic_item_widget.dart';
import 'views/syllable_item_widget.dart';

class ManageEditWordPronounceManager {
  static Future<EnWordPronounceEntity?> show({
    required BuildContext context,
    required final EnWordPronounceEntity entity,
  }) async {
    return await showCupertinoDialog<EnWordPronounceEntity?>(
      context: context,
      builder: (context) {
        return ManageEditWordPronounceView(
          entity: entity,
        );
      },
    );
  }
}

class ManageEditWordPronounceView extends GetView<ManageEditWordPronounceController> {
  final EnWordPronounceEntity entity;

  const ManageEditWordPronounceView({super.key, required this.entity});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: ManageEditWordPronounceController(entity),
        id: "manage_edit_word_pronounce",
        builder: (_) {
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
                      width: 1.wMin,
                    ),
                    color: const Color(0xff181B25),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ManageTitleWidget(
                        title: "单词发音",
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
        });
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
              title: "单词ID",
              hintText: '单词ID',
              required: false,
              controller: controller.wordIdController,
              readOnly: true,
            ),
            Gaps.getHeight(24.wh),
            ManageTitleInputWidget(
              title: "单词",
              hintText: '请填写单词',
              required: true,
              controller: controller.wordController,
              readOnly: true,
            ),
            Gaps.getHeight(24.wh),
            ManageSelectWidget(
              title: "口音",
              hintText: '请选择口音',
              value: controller.nationalIpaTitle,
              controller: controller.nationalIpaController,
              readOnly: true,
              required: true,
              options: CommonUtil.nationalIpaKeys,
              onChanged: (String value, int index) {
                controller.setNationalIpa(index);
              },
            ),
            Gaps.getHeight(24.wh),
            ManageTitleInputWidget(
              title: "IPA",
              hintText: '请填写IPA',
              controller: controller.ipaController,
              required: true,
            ),
            Gaps.getHeight(24.wh),
            _buildExtraWidget(title: "音节"),
            _buildSyllablesWidget(context),
            Gaps.getHeight(24.wh),
            _buildExtraWidget(title: "自拼"),
            _buildPhonicsWidget(context),
            Gaps.getHeight(24.wh),
          ],
        ),
      ),
    );
  }

  // 音节列表
  Widget _buildSyllablesWidget(BuildContext context) {
    return Obx(() => ListView.separated(
          key: const PageStorageKey<String>("syllables"),
          itemCount: controller.syllables.length,
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (_, i) => SizedBox(height: 12.wh),
          itemBuilder: (BuildContext c, int index) {
            final EnWordPronounceEntitySyllable syllable = controller.syllables[index];
            return SyllableItemWidget(
              key: PageStorageKey<String>(syllable.uuid),
              syllable: syllable,
              onIpaError: (syllable) => controller.resetIpaError(syllable),
              onGraphemesError: (syllable) => controller.resetGraphemesError(syllable),
              onPositionError: (syllable) => controller.resetPositionError(syllable),
            );
          },
        ));
  }

  // 音素列表
  Widget _buildPhonicsWidget(BuildContext context) {
    return Obx(() => ListView.separated(
          key: const PageStorageKey<String>("phonics"),
          itemCount: controller.phonics.length,
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (_, i) => SizedBox(height: 12.wh),
          itemBuilder: (BuildContext c, int index) {
            final EnWordPronounceEntityPhonic phonic = controller.phonics[index];
            return PhonicItemWidget(
              key: PageStorageKey<String>(phonic.uuid),
              phonic: phonic,
              onIpaError: (phonic) => controller.resetPhonicIpaError(phonic),
              onGraphemesError: (phonic) => controller.resetPhonicGraphemesError(phonic),
              onPositionError: (phonic) => controller.resetPhonicPositionError(phonic),
            );
          },
        ));
  }

  Widget _buildExtraWidget({required String title}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.wh),
      alignment: Alignment.centerLeft,
      child: Text.rich(
        TextSpan(
          children: [
            // 红色星号
            TextSpan(
              text: '*',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14.wMin,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: title,
              style: TextStyle(
                fontSize: 14.wMin,
                color: const Color(0xffEBEEF3),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomWidget() {
    return GetBuilder(
        init: controller,
        builder: (_) {
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
                        controller.onSave();
                      }, 100),
              ),
            ],
          );
        });
  }
}
