import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/card_public_widgets.dart';
import 'package:langwise/common/widgets/city_cascade_picker_widget.dart';
import 'package:langwise/common/widgets/city_pickers_widget.dart';
import 'package:langwise/common/widgets/list_animation_widget.dart';
import 'package:langwise/common/widgets/status_tag_widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../controllers/custom_course_controller.dart';

class CustomCourseAddBookWidget extends GetView<CustomCourseController> {
  final String tagText;
  const CustomCourseAddBookWidget({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      late final Widget content;
      if (controller.bookCurrentStep.value == 1) {
        content = _buildCoverWidget(context);
      } else if (controller.bookCurrentStep.value == 2) {
        if (controller.bookEntity.status == 4) {
          content = _checkExistingBookInfo(context);
        } else if (controller.bookEntity.status == 3 && controller.bookEntity.levelMatched == false && !controller.levelPlacementResolved.value) {
          content = _checkLevelMismatchInfo(context);
        } else if (controller.recognitionErrorTip.value.isNotEmpty && controller.bookSelectIndex.value != 1) {
          content = _checkIdentifyFailedInfo(context);
        } else {
          content = _getBookInfo(context);
        }
      } else if (controller.bookCurrentStep.value == 3) {
        if (controller.bookEntity.status == 3) {
          //此书籍支持
          content = _checkSupportBookInfo(context);
        } else {
          //此书籍不支持
          content = _checkNotSupportBookInfo(context);
        }
      } else {
        content = const SizedBox();
      }

      return content;
    });
  }

  //确认支持书籍
  Widget _checkSupportBookInfo(context) {
    final String title = controller.bookEntity.title ?? controller.bookInfoNameInput.text.trim();
    final String coverUrl = controller.bookEntity.coverUrl ?? '';
    final String publisher = controller.bookEntity.publisher?.trim().isNotEmpty == true ? controller.bookEntity.publisher!.trim() : '--';
    final String isbn = controller.bookEntity.isbn?.trim().isNotEmpty == true ? controller.bookEntity.isbn!.trim() : '--';
    final String unitCount = controller.bookEntity.unitCount == null ? '--' : '${controller.bookEntity.unitCount}';

    return Column(
      children: [
        SizedBox(height: 24.wMin),
        Text(
          "确认教材信息",
          style: TextStyle(
            fontSize: 48.wMin,
            color: AppTheme.cTextPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12.wMin),
        Text(
          "教材信息已经确认完成。确认无误后，再进入知识点添加方式。",
          style: TextStyle(
            fontSize: 24.wMin,
            color: AppTheme.cTextSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 40.wMin),
        SizedBox(
          width: 1068.wMin,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBookSummaryCard(
                title: title,
                coverUrl: coverUrl,
                description: "根据封面封底自动识别出的教材，适合添加到当前 Level 作为教材拓展课。",
                publisher: publisher,
                isbn: isbn,
                unitCount: unitCount,
                sceneTag: _buildAiIdentifyTag(),
              ),
              SizedBox(height: 32.wMin),
              Text(
                "孩子上学地区",
                style: TextStyle(
                  fontSize: 28.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 15.wMin),
              CityCascadePickerWidget(
                initDistrictCode: controller.initDistrictCode.value,
                onConfirm: (data) {
                  controller.initDistrictCode.value = data.districtCode;
                  controller.bookInfoButtonDisable.value = false;
                },
              ),
            ],
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            if (!controller.bookInfoButtonDisable.value) {
              print('ds');
              controller.courseInfoContinue(context);
            }
          },
          child: Container(
            width: 832.wMin,
            height: 72.wMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.wMin),
              color: controller.bookInfoButtonDisable.value ? AppTheme.cTextDisabled : AppTheme.cSurfaceInfo.color,
            ),
            child: Text('继续',
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: controller.bookInfoButtonDisable.value ? AppTheme.cTextSecondary : AppTheme.cInverseTextLight,
                  fontWeight: FontWeight.w600,
                )),
          ),
        ),
        SizedBox(height: 47.wMin)
      ],
    );
  }

  Widget _checkExistingBookInfo(BuildContext context) {
    final String title = controller.bookEntity.title ?? controller.bookInfoNameInput.text.trim();
    final String coverUrl = controller.bookEntity.coverUrl ?? '';
    final String publisher = controller.bookEntity.publisher?.trim().isNotEmpty == true ? controller.bookEntity.publisher!.trim() : '--';
    final String isbn = controller.bookEntity.isbn?.trim().isNotEmpty == true ? controller.bookEntity.isbn!.trim() : '--';
    final String unitCount = controller.bookEntity.unitCount == null ? '--' : '${controller.bookEntity.unitCount}';

    return Column(
      children: [
        SizedBox(height: 24.wMin),
        Text(
          "这本教材已经添加过了",
          style: TextStyle(
            fontSize: 48.wMin,
            color: AppTheme.cTextPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12.wMin),
        Text(
          "AI识别到这本教材已经在当前教材库里。你可以直接返回，也可以仍然继续添加一份新的教材记录。",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24.wMin,
            color: AppTheme.cTextSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 40.wMin),
        SizedBox(
          width: 1068.wMin,
          child: _buildBookSummaryCard(
            title: title,
            coverUrl: coverUrl,
            description: "识别到的教材已经在你的教材拓展课里，可以直接复用现有内容，也可以继续追加一份新的教材记录。",
            publisher: publisher,
            isbn: isbn,
            unitCount: unitCount,
            sceneTag: _buildExistingBookTag(),
          ),
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildBottomActionButton(
              title: '返回重新处理',
              width: 400.wMin,
              backgroundColor: AppTheme.cSurfacePrimary.color,
              textColor: const Color(0xFFF59E0B),
              onTap: controller.reprocessExistingBook,
            ),
            SizedBox(width: 20.wMin),
            _buildBottomActionButton(
              title: '仍然继续添加',
              width: 400.wMin,
              backgroundColor: const Color(0xFF3D2A08),
              textColor: const Color(0xFFF59E0B),
              onTap: () => controller.continueAddingExistingBook(context),
            ),
          ],
        ),
        SizedBox(height: 47.wMin),
      ],
    );
  }

  Widget _checkLevelMismatchInfo(BuildContext context) {
    final String title = controller.bookEntity.title ?? controller.bookInfoNameInput.text.trim();
    final String coverUrl = controller.bookEntity.coverUrl ?? '';
    final String currentLevel = controller.bookEntity.sourceLevelName?.trim().isNotEmpty == true
        ? controller.bookEntity.sourceLevelName!.trim()
        : controller.levelName.value;
    final String suggestedLevel = controller.bookEntity.targetLevelName?.trim().isNotEmpty == true
        ? controller.bookEntity.targetLevelName!.trim()
        : '更合适的位置';

    return Column(
      children: [
        SizedBox(height: 24.wMin),
        Text(
          "这本教材的 Level 可能放高了",
          style: TextStyle(
            fontSize: 48.wMin,
            color: AppTheme.cTextPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12.wMin),
        Text(
          "AI 识别结果显示，这本教材更适合放在更高的 Level。你可以保持现在的位置，也可以直接调整过去。",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24.wMin,
            color: AppTheme.cTextSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 40.wMin),
        SizedBox(
          width: 1068.wMin,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.wMin),
              color: AppTheme.cSurfacePrimary.color,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBookCover(coverUrl),
                SizedBox(width: 20.wMin),
                Expanded(
                  child: SizedBox(
                    height: 320.wMin,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8.wMin,
                          runSpacing: 8.wMin,
                          children: [
                            _buildInfoTag(
                              text: 'AI建议 $suggestedLevel',
                              textColor: const Color(0xFFF59E0B),
                              borderColor: const Color(0xFFF59E0B),
                              backgroundColor: const Color(0x14F59E0B),
                            ),
                            _buildInfoTag(
                              text: '当前选择 $currentLevel',
                              textColor: AppTheme.cTextPrimary,
                              borderColor: AppTheme.cBorderTertiary.color,
                              backgroundColor: AppTheme.cBgTertiary,
                            ),
                          ],
                        ),
                        SizedBox(height: 16.wMin),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 36.wMin,
                            color: AppTheme.cTextPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "AI 识别结果显示，这本教材更接近 $suggestedLevel。你可以决定仍放在当前 Level，或直接调整到更合适的位置。",
                          style: TextStyle(
                            fontSize: 24.wMin,
                            color: AppTheme.cTextSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 40.wMin),
        SizedBox(
          width: 1068.wMin,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "请选择教材放置方式",
                style: TextStyle(
                  fontSize: 32.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 20.wMin),
              Row(
                children: [
                  Expanded(
                    child: _buildPlacementOptionCard(
                      title: '保持当前位置',
                      levelName: currentLevel,
                      description: '仍然放在你当前选择的 Level，不自动调整位置。',
                      onTap: () => controller.selectLevelPlacement(moveToSuggested: false),
                    ),
                  ),
                  SizedBox(width: 20.wMin),
                  Expanded(
                    child: _buildPlacementOptionCard(
                      title: '移动到更合适的位置',
                      levelName: suggestedLevel,
                      description: '按照 AI 识别结果，直接放到更匹配的 Level。',
                      highlight: true,
                      onTap: () => controller.selectLevelPlacement(moveToSuggested: true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 47.wMin),
      ],
    );
  }

  Widget _checkIdentifyFailedInfo(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 24.wMin),
        Text(
          "AI 暂时没有识别出教材",
          style: TextStyle(
            fontSize: 48.wMin,
            color: AppTheme.cTextPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12.wMin),
        Text(
          "你可以返回重拍更清晰的封面封底，也可以直接改为手动输入 ISBN。",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24.wMin,
            color: AppTheme.cTextSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
        const Spacer(),
        SizedBox(
          width: 1068.wMin,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "请选择以下方式继续识别",
                style: TextStyle(
                  fontSize: 32.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 20.wMin),
              Row(
                children: [
                  Expanded(
                    child: _buildPlacementOptionCard(
                      title: '返回重拍',
                      levelName: '',
                      description: '重新上传更清晰的封面封底，继续让 AI 自动识别。',
                      onTap: controller.reprocessExistingBook,
                      levelTextVisible: false,
                    ),
                  ),
                  SizedBox(width: 20.wMin),
                  Expanded(
                    child: _buildPlacementOptionCard(
                      title: '去手动输入',
                      levelName: '',
                      description: '如果知道封底上的 ISBN 码，可以直接补录并进入教材确认。',
                      onTap: controller.enterManualIsbnInput,
                      levelTextVisible: false,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 47.wMin),
      ],
    );
  }

  Widget _buildBookSummaryCard({
    required String title,
    required String coverUrl,
    required String description,
    required String publisher,
    required String isbn,
    required String unitCount,
    required Widget sceneTag,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.wMin),
        color: AppTheme.cSurfacePrimary.color,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBookCover(coverUrl),
          SizedBox(width: 20.wMin),
          Expanded(
            child: SizedBox(
              height: 320.wMin,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildInfoTag(
                        text: 'Level ${controller.bookEntity.grade ?? ''}',
                        textColor: const Color(0xFF22C55E),
                        borderColor: const Color(0xFF22C55E),
                        backgroundColor: const Color(0x1422C55E),
                      ),
                      SizedBox(width: 8.wMin),
                      sceneTag,
                    ],
                  ),
                  SizedBox(height: 16.wMin),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 36.wMin,
                      color: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12.wMin),
                  StatusTagDifficultyWidget(
                    difficulty: controller.bookEntity.difficulty,
                    language: controller.languageCode.value,
                    fontSize: 14.wMin,
                    borderRadius: 4.wMin,
                    padding: EdgeInsets.symmetric(horizontal: 4.wMin, vertical: 4.wMin),
                  ),
                  SizedBox(height: 24.wMin),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 24.wMin,
                      color: AppTheme.cTextSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          label: '出版社',
                          value: publisher,
                        ),
                      ),
                      SizedBox(width: 24.wMin),
                      Expanded(
                        child: _buildInfoItem(
                          label: 'ISBN',
                          value: isbn,
                        ),
                      ),
                      SizedBox(width: 24.wMin),
                      Expanded(
                        child: _buildInfoItem(
                          label: '单元数',
                          value: unitCount,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCover(String coverUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.wMin),
      child: coverUrl.isNotEmpty
          ? Image.network(
              coverUrl,
              width: 240.wMin,
              height: 320.wMin,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildBookCoverPlaceholder(),
            )
          : _buildBookCoverPlaceholder(),
    );
  }

  Widget _buildBookCoverPlaceholder() {
    return Container(
      width: 240.wMin,
      height: 320.wMin,
      color: AppTheme.cBgTertiary,
      alignment: Alignment.center,
      child: Text(
        '暂无封面',
        style: TextStyle(
          fontSize: 24.wMin,
          color: AppTheme.cTextSecondary,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildAiIdentifyTag() {
    return _buildInfoTag(
      text: 'AI识别结果',
      textColor: const Color(0xFFC686FF),
      borderColor: const Color(0xFFC686FF),
      borderGradient: const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xFF8D99FF),
          Color(0xFFC686FF),
          Color(0xFFFF6778),
          Color(0xFFFFBA71),
          Color(0xFFAA6EEE),
          Color(0xFFBC82F3),
        ],
        stops: [0.0, 0.16, 0.42, 0.62, 0.82, 1.0],
      ),
      gradient: const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0x1FC686FF),
          Color(0x1FFFBA71),
          Color(0x1FFF6778),
          Color(0x1FAA6EEE),
          Color(0x1F8D99FF),
          Color(0x1FBC82F3),
        ],
        stops: [0.0, 0.0398, 0.3444, 0.5395, 0.7447, 1.0],
      ),
      textGradient: const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xFF8D99FF),
          Color(0xFFC686FF),
          Color(0xFFFF6778),
          Color(0xFFFFBA71),
        ],
      ),
    );
  }

  Widget _buildExistingBookTag() {
    return _buildInfoTag(
      text: '已有教材',
      textColor: const Color(0xFFF59E0B),
      borderColor: const Color(0xFFF59E0B),
      backgroundColor: const Color(0x14F59E0B),
    );
  }

  Widget _buildBottomActionButton({
    required String title,
    required double width,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 72.wMin,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.wMin),
          color: backgroundColor,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 24.wMin,
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPlacementOptionCard({
    required String title,
    required String levelName,
    required String description,
    required VoidCallback onTap,
    bool highlight = false,
    bool levelTextVisible = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cSurfacePrimary.color,
          border: Border.all(
            color: highlight ? const Color(0xFFF59E0B).withValues(alpha: 0.4) : AppTheme.cBorderTertiary.color,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$title >',
              style: TextStyle(
                fontSize: 22.wMin,
                color: AppTheme.cTextSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 16.wMin),
            if (levelTextVisible) ...[
              Text(
                levelName,
                style: TextStyle(
                  fontSize: 28.wMin,
                  color: highlight ? const Color(0xFFF59E0B) : AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16.wMin),
            ],
            Text(
              description,
              style: TextStyle(
                fontSize: 18.wMin,
                color: AppTheme.cTextSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTag({
    required String text,
    required Color textColor,
    required Color borderColor,
    Color? backgroundColor,
    Gradient? borderGradient,
    Gradient? gradient,
    Gradient? textGradient,
  }) {
    final Widget textWidget = Text(
      text,
      style: TextStyle(
        fontSize: 20.wMin,
        color: textColor,
        fontWeight: FontWeight.w500,
        height: 1,
      ),
    );

    final Widget tagContent = Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 6.wMin),
      child: textGradient == null
          ? textWidget
          : ShaderMask(
              shaderCallback: (bounds) => textGradient.createShader(
                Rect.fromLTWH(0, 0, bounds.width, bounds.height),
              ),
              blendMode: BlendMode.srcIn,
              child: textWidget,
            ),
    );

    if (borderGradient != null) {
      return Container(
        padding: EdgeInsets.all(0.8.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          gradient: borderGradient,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular((8 - 0.8).wMin),
            color: const Color(0xFF16181D),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular((8 - 0.8).wMin),
              color: gradient == null ? backgroundColor : null,
              gradient: gradient,
            ),
            child: tagContent,
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 6.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        border: Border.all(
          color: borderColor,
          width: 0.8,
        ),
        color: gradient == null ? backgroundColor : null,
        gradient: gradient,
      ),
      child: textGradient == null
          ? textWidget
          : ShaderMask(
              shaderCallback: (bounds) => textGradient.createShader(
                Rect.fromLTWH(0, 0, bounds.width, bounds.height),
              ),
              blendMode: BlendMode.srcIn,
              child: textWidget,
            ),
    );
  }

  Widget _buildInfoItem({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 18.wMin,
            color: AppTheme.cTextSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 6.wMin),
        Text(
          value,
          style: TextStyle(
            fontSize: 24.wMin,
            color: AppTheme.cTextPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  //确认不支持书籍
  Widget _checkNotSupportBookInfo(context) {
    return SizedBox(
        width: 800.wMin,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 25.wMin),
            const CardTitleIconTextWidget(
              title: "信息确认",
              hideIcon: true,
            ),
            SizedBox(height: 20.wMin),
            Container(
              width: 800.wMin,
              padding: EdgeInsets.symmetric(horizontal: 20.wMin, vertical: 15.wMin),
              decoration: BoxDecoration(
                color: AppTheme.cDifficultyBackgroundColor6.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.wMin),
              ),
              child: Text(
                controller.bookEntity.tip ?? '',
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: AppTheme.cDifficultyBackgroundColor6,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            SizedBox(height: 12.wMin),
            SizedBox(
                width: 800.wMin,
                child: ListAnimationWidget(
                  index: 0,
                  child: CardInputWidget(
                    enabled: false,
                    title: "ISBN",
                    hintText: "请输入书籍ISBN",
                    controller: controller.bookIsbnController,
                    maxLength: 30,
                  ),
                )),
            SizedBox(height: 24.wMin),
            SizedBox(
         
                child: ListAnimationWidget(
                  index: 1,
                  child: CardInputWidget(
                    title: "书籍名称",
                    hintText: "请输入类似 一年级 新概念1",
                    controller: controller.bookInfoNameInput,
                    maxLength: 30,
                    onClean: () {
                      controller.bookInfoNameInput.clear();
                      controller.bookInfoButtonDisable.value = true;
                    },
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        controller.bookInfoButtonDisable.value = false;
                      } else {
                        controller.bookInfoButtonDisable.value = true;
                      }
                    },
                  ),
                )),
            SizedBox(height: 12.wMin),
            SizedBox(
                width: 800.wMin,
                child: ListAnimationWidget(
                  index: 2,
                  child: CardInputWidget(
                    title: "请填写书籍作用",
                    hintText: "请添加书籍用途描述",
                    controller: controller.courseDescribeInput,
                    onClean: () {
                      controller.courseDescribeInput.clear();
                    },
                  ),
                )),
            SizedBox(height: 12.wMin),
            SizedBox(
                width: 800.wMin,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "孩子上学地区",
                      style: TextStyle(
                        fontSize: 28.wMin,
                        color: AppTheme.cTextPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 15.wMin),
                    CityPickersWidget(
                      initDistrictCode: controller.initDistrictCode.value,
                      onConfirm: (data) {
                        controller.initDistrictCode.value = data.districtCode;
                      },
                    ),
                  ],
                )),
            Spacer(),
            GestureDetector(
              onTap: () {
                if (controller.bookInfoButtonDisable.value) return;
                controller.reportBookInfo();
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.wMin),
                  color: controller.bookInfoButtonDisable.value ? AppTheme.cBgTertiary : AppTheme.cSurfaceInfo.color,
                ),
                alignment: Alignment.center,
                height: 72.wMin,
                width: 500.wMin,
                child: Text(
                  "继续",
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color: AppTheme.cTextPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(height: 47.wMin)
          ],
        ));
  }

  ///获取教材信息
  Widget _getBookInfo(context) {
    return Column(
      children: [
        SizedBox(height: 24.wMin),
        Text(
          "手动输入 ISBN",
          style: TextStyle(
            fontSize: 48.wMin,
            color: AppTheme.cTextPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12.wMin),
        Text(
          'ISBN 码通常在书籍封底右下角，靠近条形码位置。这里仅支持输入 13 位 ISBN 数字。',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24.wMin,
            color: AppTheme.cTextSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 40.wMin),
        Container(
          width: 1068.wMin,
          padding: EdgeInsets.all(20.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.wMin),
            color: AppTheme.cSurfacePrimary.color,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 640.wMin,
                padding: EdgeInsets.all(32.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.wMin),
                  color: AppTheme.cBgPrimary,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 280.wMin,
                      height: 280.wMin,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.wMin),
                      ),
                      child: Image.asset(
                        'assets/images/custom_course/ISBN.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 16.wMin),
                    Container(
                      width: 280.wMin,
                      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 14.wMin),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14.wMin),
                        color: const Color(0xFF3D2A08),
                        border: Border.all(
                          color: const Color(0x66F59E0B),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '封底右下角',
                            style: TextStyle(
                              fontSize: 20.wMin,
                              color: const Color(0xFFF59E0B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8.wMin),
                          Text(
                            '通常能看到条形码和ISBN 13 位数字',
                            style: TextStyle(
                              fontSize: 18.wMin,
                              color: AppTheme.cTextPrimary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 24.wMin),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 140.wMin, right: 24.wMin),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '输入ISBN码',
                        style: TextStyle(
                          fontSize: 22.wMin,
                          color: AppTheme.cTextPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 12.wMin),
                      Container(
                        height: 72.wMin,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.wMin,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.wMin),
                          color: AppTheme.cBgPrimary,
                          border: Border.all(
                            color: AppTheme.cBgTertiary,
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: controller.isbnController,
                          style: TextStyle(
                            fontSize: 24.wMin,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.cTextPrimary,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: "例如：9787111633449",
                            hintStyle: TextStyle(
                              color: AppTheme.cQuizDefaultBackground,
                              fontSize: 24.wMin,
                              fontWeight: FontWeight.w400,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 18.wMin,
                            ),
                          ),
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(13),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (value) {
                            controller.bookSelectIndex.value = 1;
                            controller.bookInfoButtonDisable.value = value.length != 13;
                          },
                        ),
                      ),
                      SizedBox(height: 20.wMin),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 14.wMin),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.wMin),
                          color: AppTheme.cBgTertiary,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 4.wMin,
                              height: 108.wMin,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999.wMin),
                                color: const Color(0xFFF59E0B),
                              ),
                            ),
                            SizedBox(width: 14.wMin),
                            Expanded(
                              child: Text(
                                '如果封底上同时有带横杠和不带横杠的写法，直接输入下面那串 13 位数字即可。后续如需调整教材信息，可以再到教材管理里维护。',
                                style: TextStyle(
                                  fontSize: 18.wMin,
                                  color: AppTheme.cTextPrimary,
                                  fontWeight: FontWeight.w400,
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        GestureDetector(
            onTap: () {
              if (controller.bookInfoButtonDisable.value) return;
              controller.courseInfoContinue(context);
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.wMin),
                color: controller.bookInfoButtonDisable.value ? AppTheme.cBgTertiary : AppTheme.cSurfaceInfo.color,
              ),
              alignment: Alignment.center,
              height: 72.wMin,
              width: 650.wMin,
              child: Text(
                "确认并继续",
                style: TextStyle(
                  fontSize: 20.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )),
        SizedBox(height: 47.wMin),
      ],
    );
  }

  /// 封面封底上传卡片
  Widget _buildCoverWidget(context) {
    return Column(
      children: [
        SizedBox(height: 16.wMin),
        Text.rich(
          TextSpan(text: "请找出", children: [
            TextSpan(
              text: controller.cefr.value,
              style: TextStyle(
                fontSize: 40.wMin,
                color: AppTheme.cTextBrand,
                fontWeight: FontWeight.w600,
              ),
            ),
            const TextSpan(text: '这本书'),
          ]),
          style: TextStyle(
            fontSize: 40.wMin,
            color: AppTheme.cTextPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.wMin),
        Text(
          '拍照上传封面封底，或者直接上传封面封底图片',
          style: TextStyle(
            fontSize: 24.wMin,
            color: AppTheme.cTextSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          '不知道加什么教材、怎么加教材，都可以免费联系助教老师',
          style: TextStyle(
            fontSize: 20.wMin,
            color: AppTheme.cTextTertiary,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 16.wMin),
        Row(
          children: [
            SizedBox(width: 70.wMin),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.cSurfacePrimary.color,
                  borderRadius: BorderRadius.circular(24.wMin),
                ),
                padding: EdgeInsets.all(24.wMin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '添加封面',
                          style: TextStyle(
                            fontSize: 28.wMin,
                            color: AppTheme.cTextPrimary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            controller.showSampleCover();
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                color: Color(0x1A0EA5E9),
                                borderRadius: BorderRadius.circular(8.wMin),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 6.wMin),
                              child: Row(children: [
                                Text(
                                  '查看样图',
                                  style: TextStyle(
                                    fontSize: 22.wMin,
                                    color: AppTheme.cTextBrand,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(width: 8.wMin),
                                SvgPicture.asset(
                                  'assets/svg/manage/icon_chevron_right.svg',
                                  width: 20.wMin,
                                  height: 20.wMin,
                                  colorFilter: const ColorFilter.mode(AppTheme.cTextBrand, BlendMode.srcIn),
                                )
                              ])),
                        )
                      ],
                    ),
                    SizedBox(height: 10.wMin),
                    Obx(() => _buildImageWidget(
                      filePath: controller.frontCover.value,
                      svg: "assets/svg/custom_course/book_front_cover.svg",
                      onPhotoAlbumTap: () {
                        controller.selectFrontCoverFromAlbum(context);
                      },
                      onCameraTap: () {
                        controller.selectFrontCover(context);
                      },
                    )),
                  ],
                ),
              ),
            ),
            SizedBox(width: 24.wMin),
            Expanded(
                child: Container(
              decoration: BoxDecoration(
                color: AppTheme.cSurfacePrimary.color,
                borderRadius: BorderRadius.circular(24.wMin),
              ),
              padding: EdgeInsets.all(24.wMin),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(
                  children: [
                    Text(
                      '添加封底',
                      style: TextStyle(
                        fontSize: 28.wMin,
                        color: AppTheme.cTextPrimary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                        onTap: () {
                          controller.showSampleCover();
                        },
                        child: Container(
                            decoration: BoxDecoration(
                              color: Color(0x1A0EA5E9),
                              borderRadius: BorderRadius.circular(8.wMin),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 6.wMin),
                            child: Row(children: [
                              Text(
                                '查看样图',
                                style: TextStyle(
                                  fontSize: 22.wMin,
                                  color: AppTheme.cTextBrand,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(width: 8.wMin),
                              SvgPicture.asset(
                                'assets/svg/manage/icon_chevron_right.svg',
                                width: 20.wMin,
                                height: 20.wMin,
                                colorFilter: const ColorFilter.mode(AppTheme.cTextBrand, BlendMode.srcIn),
                              )
                            ])))
                  ],
                ),
                SizedBox(height: 10.wMin),
                Obx(
                  () => _buildImageWidget(
                    filePath: controller.backCover.value,
                    svg: "assets/svg/custom_course/book_back_cover.svg",
                    onPhotoAlbumTap: () {
                      controller.selectBackCoverFromAlbum(context);
                    },
                    onCameraTap: () {
                      controller.selectBackCover(context);
                    },
                  ),
                )
              ]),
            )),
            SizedBox(width: 70.wMin),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            if (controller.frontCover.value.isEmpty || controller.backCover.value.isEmpty) {
              ToastUtils.showToast(text: "请上传封面和封底");
              return;
            }
            controller.courseInfoContinue(context);
          },
          child: Container(
            height: 72.wMin,
            width: 832.wMin,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.wMin),
              color: controller.frontCover.value.isEmpty || controller.backCover.value.isEmpty ? AppTheme.cSurfaceTertiary.color : AppTheme.cSurfaceInfo.color,
            ),
            alignment: Alignment.center,
            child: Text(
              controller.frontCover.value.isEmpty || controller.backCover.value.isEmpty ? '请上传封面和封底' : '继续',
              style: TextStyle(
                fontSize: 24.wMin,
                color: controller.frontCover.value.isEmpty || controller.backCover.value.isEmpty ? AppTheme.cTextTertiary : AppTheme.cTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(height: 40.wMin),
      ],
    );
  }

  Widget _buildImageWidget({
    String filePath = "",
    required String svg,
    void Function()? onPhotoAlbumTap,
    void Function()? onCameraTap,
  }) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.wMin),
          ),
          child: filePath.isEmpty
              ? SvgPicture.asset(
                  svg,
                  height: 300.wMin,
                )
              : Image.file(
                  File(filePath),
                  height: 300.wMin,
                  errorBuilder: (context, error, stackTrace) {
                    return SvgPicture.asset(
                      svg,
                      height: 300.wMin,
                    );
                  },
                ),
        ),
        SizedBox(width: 16.wMin),
        Expanded(
          child: Column(
            children: [
              GestureDetector(
                onTap: onCameraTap,
                child: Container(
                  height: 140.wMin,
                  decoration: BoxDecoration(
                    color: AppTheme.cSurfaceSecondary.color,
                    borderRadius: BorderRadius.circular(8.wMin),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipOval(
                        child: Container(
                          color: const Color.fromRGBO(56, 189, 248, 0.1),
                          width: 56.wMin,
                          height: 56.wMin,
                          child: Center(
                            child: SvgPicture.asset(
                              "assets/svg/public/icon_camera1.svg",
                              width: 28.wMin,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.wMin),
                      Text(
                        filePath.isEmpty ? "拍照" : "重新拍摄",
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: AppTheme.cTextPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10.wMin),
              GestureDetector(
                onTap: onPhotoAlbumTap,
                child: Container(
                  height: 140.wMin,
                  decoration: BoxDecoration(
                    color: AppTheme.cSurfaceSecondary.color,
                    borderRadius: BorderRadius.circular(8.wMin),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipOval(
                        child: Container(
                          color: const Color.fromRGBO(56, 189, 248, 0.1),
                          width: 56.wMin,
                          height: 56.wMin,
                          child: Center(
                            child: SvgPicture.asset(
                              "assets/svg/public/icon_image1.svg",
                              width: 28.wMin,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.wMin),
                      Text(
                        filePath.isEmpty ? "上传" : "重新上传",
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: AppTheme.cTextPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
