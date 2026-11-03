import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../../../common/values/values.dart';
import '../../../common/entities/entities.dart';
import 'package:collection/collection.dart';
import 'index.dart';

class ImageModerationDetailPage extends GetView<ImageModerationDetailController> {
  const ImageModerationDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        id: "image_moderation_detail",
        builder: (ImageModerationDetailController controller) {
          return Scaffold(
            backgroundColor: color_1E2939,
            body: Stack(
              children: [
                SafeArea(
                  left: true,
                  top: true,
                  right: false,
                  child: Column(
                    children: [
                      // 导航栏
                      _buildNavigationBar(context),

                      // 主体内容 - 左侧信息区和右侧图片区
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 左侧信息区
                            _buildInfoSection(),

                            // 右侧图片区
                            _buildImageSection(context),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 底部按钮组
                Positioned(
                  right: 16.ww,
                  bottom: 36.wh,
                  child: Row(
                    children: [
                      // 批量评分按钮组 - 仅在批量模式且有图片被选中时显示
                      BatchImageRatingButtons(
                        isVisible: controller.state.isBatchMode && controller.hasSelectedImages(),
                        onRateSelected: (stars) => controller.batchRateImages(stars),
                      ),
                      // 操作按钮组
                      ImageModerationActionButtons(
                        imageModerationType: controller.imageModerationType,
                        isBatchMode: controller.state.isBatchMode,
                        canBatchReview: controller.state.canBatchReview,
                        onStartReview: () => controller.startReview(context),
                        onEnterBatchMode: () => controller.enterBatchMode(),
                        onExitBatchMode: () => controller.exitBatchMode(),
                        onAbandonReview: () => controller.showAbandonReviewDialog(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  /// 构建导航栏
  Widget _buildNavigationBar(BuildContext context) {
    return Container(
      color: color_1E2939,
      child: Row(
        children: [
          BackWidget(title: controller.state.selectedKnowledgePoint?.content ?? ''),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.ww, vertical: 6.wh),
            decoration: BoxDecoration(
              color: color_364153,
              borderRadius: BorderRadius.circular(8.ww),
            ),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '已审核: ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.wMin,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  TextSpan(
                    text: '${controller.state.getReviewedImagesCount()}',
                    style: TextStyle(
                      color: color_51A2FF,
                      fontSize: 14.wMin,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  TextSpan(
                    text: ' / ${controller.state.getTotalImagesCount()}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.wMin,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Gaps.getWidth(16.ww)
        ],
      ),
    );
  }

  /// 构建左侧信息区
  Widget _buildInfoSection() {
    return Container(
      width: 320.ww,
      padding: EdgeInsets.all(16.ww),
      decoration: BoxDecoration(
        color: color_1E2939,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '知识点信息',
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cTextPrimary,
              ),
            ),
            _buildKnowledgePointInfo(),
            Gaps.getHeight(24.wh),
            Text(
              '类别',
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cTextPrimary,
              ),
            ),
            _buildPosSelector(),
            Gaps.getHeight(24.wh),
            Text(
              '释义',
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cTextPrimary,
              ),
            ),
            _buildGlossSelector(),
            Gaps.getHeight(24.wh),
            Text(
              '快速筛序',
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cTextPrimary,
              ),
            ),
            _buildFilterSelector(),
          ],
        ),
      ),
    );
  }

  /// 构建知识点信息
  Widget _buildKnowledgePointInfo() {
    // 计算审核进度百分比
    final reviewedCount = controller.state.getReviewedImagesCount();
    final totalCount = controller.state.getTotalImagesCount();
    final progressPercentage = totalCount > 0 ? (reviewedCount / totalCount) : 0.0;

    return Container(
      margin: EdgeInsets.only(top: 12.wh),
      padding: EdgeInsets.only(left: 16.ww, right: 16.ww, top: 16.wh, bottom: 16.wh),
      decoration: BoxDecoration(
        color: color_364153, // 深蓝色背景
        borderRadius: BorderRadius.circular(8.ww),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '描述：',
                  style: TextStyle(
                    fontSize: 14.wMin,
                    fontWeight: FontWeight.w400,
                    color: color_99A1AF,
                  ),
                ),
                TextSpan(
                  text: controller.state.selectedPos?.description ?? '',
                  style: TextStyle(
                    fontSize: 14.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextPrimary,
                  ),
                ),
              ],
            ),
          ),
          Gaps.getHeight(8.wh),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '总图片: ',
                      style: TextStyle(
                        fontSize: 14.wMin,
                        fontWeight: FontWeight.w400,
                        color: color_99A1AF,
                      ),
                    ),
                    TextSpan(
                      text: '$totalCount',
                      style: TextStyle(
                        fontSize: 14.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '已审核: ',
                      style: TextStyle(
                        fontSize: 14.wMin,
                        fontWeight: FontWeight.w400,
                        color: color_99A1AF,
                      ),
                    ),
                    TextSpan(
                      text: '$reviewedCount',
                      style: TextStyle(
                        fontSize: 14.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Gaps.getHeight(8.wh),
          // 进度条
          ClipRRect(
            borderRadius: BorderRadius.circular(4.ww),
            child: LinearProgressIndicator(
              value: progressPercentage,
              backgroundColor: color_4A5565,
              valueColor: AlwaysStoppedAnimation<Color>(color_2B7FFF),
              minHeight: 10.wh,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建词性选择器
  Widget _buildPosSelector() {
    if (!(controller.state.hasContentPosList)) {
      return const SizedBox();
    }
    final posList = controller.state.selectedKnowledgePoint?.contentPosList ?? [];
    return Container(
      margin: EdgeInsets.only(top: 12.wh),
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...posList.mapIndexed((index, posGroup) {
            // 直接使用PosGroup类中的getter方法获取未审核的图片数量
            return PosItemWidget(
              posGroup: posGroup,
              index: index,
              isSelected: controller.state.selectedPos == posGroup,
              needMargin: (index != (posList.length - 1)),
              unreviewedCount: posGroup.unreviewedImagesCount,
              // 直接使用实体类的getter方法
              onSelected: (_, _posGroup) {
                controller.selectPos(_posGroup);
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  /// 构建释义选择器
  Widget _buildGlossSelector() {
    final glosses = controller.state.getCurrentGlosses();
    return Container(
      margin: EdgeInsets.only(top: 12.wh),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...glosses.asMap().entries.map((entry) {
            final index = entry.key;
            final gloss = entry.value;
            return GlossItemWidget(
              gloss: gloss,
              index: index,
              isSelected: controller.state.selectedGloss == gloss,
              needMargin: (index != (glosses.length - 1)),
              onSelected: (index, gloss) {
                controller.selectGloss(gloss);
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  /// 构建快速筛选器
  Widget _buildFilterSelector() {
    return GetBuilder<ImageModerationDetailController>(
      id: 'filter_section',
      builder: (_) {
        return Container(
          margin: EdgeInsets.only(top: 12.wh),
          height: 45.wh * (controller.state.filterItems.length),
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: controller.state.filterItems.length,
            itemBuilder: (context, index) {
              final item = controller.state.filterItems[index];
              return FilterItemWidget(
                label: item['label'],
                count: item['count'],
                index: index,
                isSelected: controller.state.selectedFilterIndex == index,
                onSelected: (index) {
                  controller.selectFilter(index);
                },
              );
            },
          ),
        );
      },
    );
  }

  /// 构建右侧图片区
  Widget _buildImageSection(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: color_101828,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSectionHeader(context),
            _buildImageGrid(),
          ],
        ),
      ),
    );
  }

  /// 构建自定义按钮
  Widget _buildCustomButton<T>({
    required String text,
    required BuildContext context,
    Color backgroundColor = const Color(0xFF155DFC),
    Color textColor = Colors.white,
    double borderRadius = 8.0,
    EdgeInsets? padding,
    GlobalKey? key,
    List<T>? options,
    String Function(T)? labelBuilder,
    int? selectedIndex,
    Function(int, T)? onSelected,
  }) {
    final buttonKey = key ?? GlobalKey();

    return GestureDetector(
      onTap: () {
        if (options != null && options.isNotEmpty && labelBuilder != null && onSelected != null) {
          // 如果提供了选项，则显示下拉菜单
          ButtonDropdownMenu.show<T>(
            context: context,
            options: options,
            labelBuilder: labelBuilder,
            selectedIndex: selectedIndex ?? 0,
            onSelected: onSelected,
            anchorKey: buttonKey,
            width: 172.ww,
            backgroundColor: const Color(0xFF1D2939),
            borderColor: color_4A5565,
            hoverColor: color_155DFC,
          );
        }
      },
      child: Container(
        key: buttonKey,
        width: 172.ww,
        padding: EdgeInsets.symmetric(horizontal: 16.wMax, vertical: 16.wMax),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius.ww),
          border: Border.all(
            width: 1.wMin,
            color: color_4A5565,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 居中文本
            Center(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            // 右侧图标
            Positioned(
              right: 0,
              child: Icon(
                Icons.keyboard_arrow_down,
                size: 24.ww,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建图片区标题
  Widget _buildImageSectionHeader(BuildContext context) {
    // 创建全局键
    final styleButtonKey = GlobalKey();
    final regionButtonKey = GlobalKey();

    // 获取选中的词性和释义
    final selectedPos = controller.state.selectedPos;
    final selectedGloss = controller.state.selectedGloss;
    final imagesCount = controller.state.getCurrentImages().length;

    // 从状态中获取风格和地区选项
    final styleOptions = controller.state.getStyleOptions();
    final localeOptions = controller.state.getLocaleOptions();

    return Container(
      padding: EdgeInsets.all(16.ww),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: selectedPos != null
                ? RichText(
                    maxLines: 5,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: selectedPos.title,
                          style: TextStyle(
                            fontSize: 18.wMin,
                            fontWeight: FontWeight.w600,
                            color: color_51A2FF,
                          ),
                        ),
                        // 只在glossZh有值时才显示分隔符和文本
                        if (selectedGloss?.glossZh != null && selectedGloss!.glossZh!.isNotEmpty) ...[
                          TextSpan(
                            text: ' - ',
                            style: TextStyle(
                              fontSize: 18.wMin,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.cTextPrimary,
                            ),
                          ),
                          TextSpan(
                            text: selectedGloss.glossZh!,
                            style: TextStyle(
                              fontSize: 18.wMin,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.cTextPrimary,
                            ),
                          ),
                        ],
                        TextSpan(
                          text: ' (共$imagesCount张图片)',
                          style: TextStyle(
                            fontSize: 14.wMin,
                            fontWeight: FontWeight.w700,
                            color: color_99A1AF,
                          ),
                        ),
                      ],
                    ),
                  )
                : Text(
                    '共$imagesCount张图片',
                    style: TextStyle(
                      fontSize: 14.wMin,
                      fontWeight: FontWeight.w700,
                      color: color_99A1AF,
                    ),
                  ),
          ),
          // 风格筛选按钮
          _buildCustomButton<ImageFilterOption>(
            key: styleButtonKey,
            context: context,
            text: controller.state.selectedStyle?.styleTitle ?? '所有风格',
            backgroundColor: color_364153,
            options: styleOptions,
            labelBuilder: (option) => option.styleTitle ?? '',
            selectedIndex: controller.state.selectedStyle != null && styleOptions.isNotEmpty
                ? styleOptions.indexWhere((option) => option.style == controller.state.selectedStyle!.style)
                : 0,
            onSelected: (index, option) {
              // 处理风格选择
              controller.selectStyle(index, option);
            },
          ),
          Gaps.getWidth(8.ww),
          // 地区筛选按钮
          _buildCustomButton<ImageFilterOption>(
            key: regionButtonKey,
            context: context,
            text: controller.state.selectedLocale?.localeTitle ?? '所有地区',
            backgroundColor: color_364153,
            options: localeOptions,
            labelBuilder: (option) => option.localeTitle ?? '',
            selectedIndex: controller.state.selectedLocale != null && localeOptions.isNotEmpty
                ? localeOptions.indexWhere((option) => option.locale == controller.state.selectedLocale!.locale)
                : 0,
            onSelected: (index, option) {
              // 处理地区选择
              controller.selectLocale(index, option);
            },
          ),
        ],
      ),
    );
  }

  /// 构建图片网格
  Widget _buildImageGrid() {
    return Expanded(
      child: GridView.builder(
        padding: EdgeInsets.only(left: 16.ww, right: 16.ww),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1.0,
          crossAxisSpacing: 16.ww,
          mainAxisSpacing: 10.wh,
        ),
        itemCount: controller.state.getCurrentImages().length,
        itemBuilder: (context, index) {
          final image = controller.state.getCurrentImages()[index];
          return GetBuilder<ImageModerationDetailController>(
            id: "image_moderation_detail",
            builder: (controller) => ImageCardWidget(
              image: image,
              isBatchMode: controller.state.isBatchMode,
              reviewText: '审核图片',
              onTap: (image) {
                // 批量模式下切换选中状态，非批量模式下显示审核对话框
                if (controller.state.isBatchMode) {
                  controller.toggleImageSelection(image);
                } else {
                  controller.onShowImageReviewDialog(context, image);
                }
              },
            ),
          );
        },
      ),
    );
  }
}
