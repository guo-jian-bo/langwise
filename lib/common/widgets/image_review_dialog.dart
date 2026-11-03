/// 图片审核对话框
///
/// 功能与特点：
/// 1. 使用 GridView 展示图片和评分选项，第一个元素为图片，后面是评分选项
/// 2. 评分选项使用 RatingOption 模型封装属性（星级、标题、描述列表、选中状态）
/// 3. 选中的评分选项边框颜色根据星级变化，且只能选中一个选项
/// 4. 标题栏显示选中的词性和释义，鼠标悬停时有蓝色下划线动画
/// 5. 实现全屏宽度的交错动画提示，在确认评分后显示反馈
/// 6. 使用可复用的 StarRatingWidget 组件展示星级评分
/// 7. 采用 Hero 动画实现图片在列表和详情对话框之间的平滑过渡
///
/// 审核流程与职责划分：
/// 1. 初始状态：
///    - 首次打开对话框时，显示用户选中的词性、释义和图片
///    - 界面显示当前审核的完整上下文信息（词性、释义、图片信息）
///
/// 2. 职责划分：
///    - ImageReviewDialog：负责审核、UI展示、用户交互和动画反馈
///    - 确认按钮：调用审核API，将选中的评分项的返回给 ImageModerationDetailController
///    - ImageModerationDetailController：负责处理审核成功后的逻辑，返回下一个待审核项
///    - 检索下一个待审核项的逻辑完全由 ImageModerationDetailController 实现
///
/// 3. 审核顺序逻辑（由控制器实现）：
///    - 当前释义内图片审核：从选中图片开始，按索引顺序向后审核未审核图片
///    - 释义间切换逻辑：当前释义审核完成后，自动切换到下一个有未审核图片的释义
///    - 跳过所有图片已审核完成的释义，只关注有未审核图片的释义
///    - 词性间切换逻辑：当前词性下选中的释义及以后的释义的未审核图片都审核完成后，自动切换到下一个词性
///    - 全局循环检查：最后一个词性下的未审核释义的图片审核成功后，会从词性数组开始重新检索是否还有未审核的词性、释义、图片，有则继续执行审核逻辑
///
/// 4. 交互反馈（由对话框实现）：
///    - 切换提示：切换到新释义或新词性时，显示交错动画提示
///    - 完成反馈：确认评分后显示动画反馈，等待控制器返回下一个待审核项
///    - 审核完成提示：当所有图片审核完成时，显示特殊的完成提示
///
/// 技术实现：
/// 1. 使用 PageRouteBuilder 而非 showDialog 来显示对话框，确保 Hero 动画正常工作
/// 2. 封装 BounceAnimationWidget 实现交错动画效果（从顶部滑入后抖动）
/// 3. 采用 CommonUtils.getSizeAndPosition 准确获取组件位置和尺寸
/// 4. 实现高效的查找算法，快速定位下一个有未审核图片的释义和词性
/// 5. 使用 PopScope 代替已废弃的 WillPopScope 来防止意外关闭
/// 6. 采用组合模式复用多个独立组件（StarRatingWidget、BounceAnimationWidget）
///
/// 使用示例：
/// ```dart
/// ImageReviewDialog.show(
///   context: context,
///   image: imageItem,
///   selectedPos: posGroup,
///   selectedGloss: glossItem,
///   onClose: () => Navigator.pop(context),
///   onPrevious: _navigateToPrevious,
///   onNext: _navigateToNext,
///   onReview: _handleReview,
/// );
/// ```
///
/// 作者：LangWise Team
/// 最后更新：2025-05-25

import 'package:api/entities/entities.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:quiz_play/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:collection/collection.dart';

import '../values/values.dart';

/// 图片审核对话框
class ImageReviewDialog extends StatefulWidget {
  /// 当前选中的知识点
  final KnowledgePointDetail? selectedKnowledgePoint;

  /// 当前选中的词性
  final PosGroup? selectedPos;

  /// 当前选中的释义
  final GlossItem? selectedGloss;

  /// 当前选中的图片
  final ImageItem image;

  /// 是否用户端
  final bool isUser;

  /// 关闭对话框回调
  final VoidCallback onClose;

  /// 评分回调
  /// 参数包括：图片、评分星级、当前词性和当前释义
  final Function(ImageItem image, int stars, PosGroup? pos, GlossItem? gloss) onReview;

  const ImageReviewDialog({
    Key? key,
    this.selectedKnowledgePoint,
    required this.image,
    this.selectedPos,
    this.selectedGloss,
    this.isUser = true,
    required this.onClose,
    required this.onReview,
  }) : super(key: key);

  /// 显示图片审核对话框
  static Future<void> show({
    required BuildContext context,
    required ImageItem image,
    KnowledgePointDetail? selectedKnowledgePoint,
    PosGroup? selectedPos,
    GlossItem? selectedGloss,
    bool isUser = true,
    required VoidCallback onClose,
    required Function(ImageItem image, int stars, PosGroup? pos, GlossItem? gloss) onReview,
  }) {
    // 使用PageRouteBuilder代替showDialog，以确保Hero动画能够正常工作
    return Navigator.of(context).push(
      PageRouteBuilder(
        // 设置透明背景，使对话框看起来像是浮动的
        opaque: false,
        // 设置过渡动画持续时间
        transitionDuration: const Duration(milliseconds: 220),
        // 设置页面构建器
        pageBuilder: (BuildContext context, _, __) {
          return Material(
            color: color_1E2939,
            child: PopScope(
              // 禁止点击外部关闭
              canPop: false,
              child: ImageReviewDialog(
                image: image,
                selectedKnowledgePoint: selectedKnowledgePoint,
                selectedPos: selectedPos,
                selectedGloss: selectedGloss,
                isUser: isUser,
                onClose: onClose,
                onReview: onReview,
              ),
            ),
          );
        },
        // 设置过渡动画
        transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  State<ImageReviewDialog> createState() => _ImageReviewDialogState();
}

class _ImageReviewDialogState extends State<ImageReviewDialog> with SingleTickerProviderStateMixin, SafeSetStateMixin {
  /// 当前图片
  late ImageItem _image;

  /// 当前选中的词性
  PosGroup? _selectedPos;

  /// 当前选中的释义
  GlossItem? _selectedGloss;

  /// 选中的知识点
  KnowledgePointDetail? _selectedKnowledgePoint;

  /// 提示动画的OverlayEntry
  OverlayEntry? _tipOverlayEntry;

  /// 当前显示的星星数量
  int _currentStars = 0;

  /// 评分选项列表
  List<RatingOption> _ratingOptions = [];

  /// 鼠标悬停状态
  bool _isTitleHovered = false;

  /// 标题文本的GlobalKey，用于获取宽度
  final GlobalKey _titleTextKey = GlobalKey();

  /// 第二行（释义和语义）的GlobalKey
  final GlobalKey _secondLineKey = GlobalKey();

  /// 是否正在提交评分，防止频繁点击
  bool _isSubmitting = false;

  /// 释义文本颜色是否为红色
  bool _isDefinitionRed = false;

  /// 词性文本颜色是否为红色
  bool _isPosRed = false;

  /// 是否正在显示鼠标悬停动画
  bool _isHoveringAnimation = false;

  /// 是否已经完成首次渲染，用于控制动画底线的显示
  bool _isFirstFrameRendered = false;

  /// 动态计算的标题宽度，用于设置动画底线
  double _titleWidth = 0;

  /// 释义文本覆盖层动画控制器
  late AnimationController _overlayAnimationController;

  /// 覆盖层透明度动画
  late Animation<double> _overlayAnimation;

  @override
  void initState() {
    super.initState();

    // 初始化私有变量
    _selectedKnowledgePoint = widget.selectedKnowledgePoint;
    _selectedPos = widget.selectedPos;
    _selectedGloss = widget.selectedGloss;
    _image = widget.image;

    // 初始化动画控制器
    _overlayAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // 初始化动画，透明度从0到0.5再到0
    _overlayAnimation = TweenSequence<double>([
      // 淡入效果
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.5).chain(
          CurveTween(curve: Curves.easeIn),
        ),
        weight: 40.0,
      ),
      // 停留效果
      TweenSequenceItem(
        tween: ConstantTween<double>(0.5),
        weight: 20.0,
      ),
      // 淡出效果
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.5, end: 0.0).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 40.0,
      ),
    ]).animate(_overlayAnimationController);

    // 初始化评分选项
    _initRatingOptions();

    // 等待最后一帧渲染完成后再计算标题宽度
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 标记首次渲染已完成
      safeSetState(() {
        // 计算标题宽度
        _titleWidth = _getTitleWidth();
        _isFirstFrameRendered = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      left: true,
      top: true,
      right: false,
      child: Padding(
        padding: EdgeInsets.only(left: 16.ww, top: 16.ww, right: 16.ww),
        child: Column(
          children: [
            Gaps.getHeight(25.wh),
            // 标题栏
            _buildTitleBar(context),
            Gaps.getHeight(20.wh),
            // 内容区域
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 评分选项 - 使用 Row + Expanded 布局
                  SizedBox(
                    height: 500.wh,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 第一个元素：图片 (固定尺寸 500x500)
                        _buildImageItem(),

                        // 间距
                        Gaps.getWidth(16.ww),

                        // 评分选项 - 使用 Flex 组件实现等分布局
                        Expanded(
                          child: Flex(
                            direction: Axis.horizontal,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _getRatingOptions()
                                .mapIndexed((index, option) => Flexible(
                                      flex: 1, // 每个选项占据相同份数
                                      child: Padding(
                                        padding: EdgeInsets.only(left: index > 0 ? 4.ww : 0),
                                        child: RatingOptionCard(
                                          index: index,
                                          option: option,
                                          onSelect: (selectedOption) {
                                            // 更新所有评分选项的选中状态
                                            safeSetState(() {
                                              for (var item in _ratingOptions) {
                                                item.isSelected = false;
                                              }
                                              selectedOption.isSelected = true;

                                              // 更新当前星星数量，使图片项右侧的星星同步更新
                                              _currentStars = selectedOption.imageScore;
                                            });
                                          },
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Gaps.getHeight(22.wh),

                  // 确认并继续按钮和返回按钮行
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 返回按钮
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          widget.onClose.call();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.wMax, vertical: 16.wMax),
                          decoration: BoxDecoration(
                            color: color_4A5565,
                            borderRadius: BorderRadius.circular(8.ww),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.arrow_back,
                                size: 24.ww,
                                color: AppTheme.cTextPrimary,
                              ),
                              SizedBox(width: 8.ww),
                              Text(
                                '返回',
                                style: TextStyle(
                                  color: AppTheme.cTextPrimary,
                                  fontSize: 24.wMin,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 确认并继续按钮
                      GestureDetector(
                        onTap: _hasSelectedRating && !_isSubmitting
                            ? () {
                                if (widget.isUser) {
                                  onUserReview();
                                } else {
                                  onAdminReview();
                                }
                              }
                            : null,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.wMax, vertical: 16.wMax),
                          decoration: BoxDecoration(
                            color: color_155DFC,
                            borderRadius: BorderRadius.circular(8.ww),
                          ),
                          foregroundDecoration: BoxDecoration(
                            color: _hasSelectedRating && !_isSubmitting
                                ? Colors.transparent
                                : Colors.white.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8.ww),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check,
                                size: 24.ww,
                                color: AppTheme.cTextPrimary,
                              ),
                              SizedBox(width: 8.ww),
                              Text(
                                '确认并继续',
                                style: TextStyle(
                                  color: AppTheme.cTextPrimary,
                                  fontSize: 24.wMin,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建图片项
  Widget _buildImageItem() {
    // 初始化当前星星数量为图片的星级
    if (_currentStars == 0) {
      _currentStars = _image.imageScore ?? 0;
    }

    return Container(
      width: 500.wh,
      height: 500.wh,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8.ww),
        border: Border.all(
          color: color_364153,
          width: 1.wMin,
        ),
      ),
      padding: EdgeInsets.only(left: 16.91.wh, right: 16.91.wh, top: 16.91.wh, bottom: 16.91.wh),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 图片信息
          SizedBox(
            height: 28.wh,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 图片风格和地区
                Text(
                  (_image.localeTitle ?? '') + " " + (_image.styleTitle ?? ''),
                  style: TextStyle(
                    color: AppTheme.cTextPrimary,
                    fontSize: 20.wMin,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                // 星星评分显示 - 使用封装组件
                StarRatingWidget(
                  litStars: _currentStars,
                  starSize: 14.0,
                  litStarColor: color_FDC700,
                  unlitStarColor: color_D1D5DC,
                ),
              ],
            ),
          ),

          Gaps.getHeight(8.wh),

          // 图片 - 使用Hero动画
          Expanded(
              child: Hero(
            // 使用图片ID作为Hero标签，确保在不同页面之间的唯一性
            tag: 'image_${_image.imageId}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.ww),
              child: CachedImageWidget(
                _image.imageUrl ?? '',
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(8.ww),
                placeholder: buildLoadingWidget(),
                errorWidget: Center(
                  child: Icon(
                    Icons.broken_image,
                    size: 80.ww,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  /// 获取第二行（释义和语义）的宽度，用于设置动画底线
  double _getTitleWidth() {
    if (_secondLineKey.currentContext != null) {
      final RenderBox renderBox = _secondLineKey.currentContext!.findRenderObject() as RenderBox;
      return renderBox.size.width;
    }
    return 0;
  }

  /// 显示抖动提示动画
  void _showBounceAnimation(String message) {
    // 先移除之前的提示（如果有）
    _removeTipOverlay();

    var record = CommonUtils.getSizeAndPosition(_secondLineKey);

    final position = Offset(
      0, // 从屏幕左侧开始
      record.globalPosition.dy + record.size.height + 10, // 在标题栏下方
    );

    // 显示新提示，宽度为屏幕总宽度
    _tipOverlayEntry = BounceAnimationHelper.showBounceMessage(
      context: context,
      message: message,
      position: position,
      repeatCount: 2,
      // 设置宽度为屏幕总宽度
      width: AppConst.width,
      // 文本居中对齐
      textAlign: TextAlign.center,
      // 子组件在容器中居中显示
      alignment: Alignment.centerLeft,
      textStyle: TextStyle(
        fontSize: 14.wMin,
        fontWeight: FontWeight.w400,
        color: const Color(0xFFAA7700), // 更深的黄色，带点黑色
      ),
      // 增加显示时间
      displayDuration: const Duration(milliseconds: 200),
      onDismissed: () {
        _tipOverlayEntry = null;
      },
    );
  }

  /// 构建标题栏
  Widget _buildTitleBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.wh, horizontal: 8.ww),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: MouseRegion(
              onEnter: (_) {
                safeSetState(() => _isTitleHovered = true);
                // 鼠标进入时只触发闪烁动画，不改变文本颜色
                _triggerOverlayAnimation();
              },
              onExit: (_) => safeSetState(() => _isTitleHovered = false),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedKnowledgePoint?.content ?? "",
                    style: TextStyle(
                      fontSize: 24.wMin,
                      color: color_D1D5DC,
                      fontWeight: FontWeight.bold,
                      height: 1.2, // 添加行高确保文本对齐
                    ),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                  Gaps.getHeight(2.wh),
                  // 第一行：词性和描述
                  Stack(
                    children: [
                      RichText(
                        key: _titleTextKey,
                        maxLines: 20,
                        textAlign: TextAlign.start,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${_selectedPos?.title}',
                              style: TextStyle(
                                fontSize: 24.wMin,
                                color: _isPosRed ? Colors.red : color_2B7FFF,
                                fontWeight: FontWeight.bold,
                                height: 1.2, // 添加行高确保文本对齐
                              ),
                            ),
                            // 只在glossZh有值时才显示分隔符
                            if (_selectedGloss?.glossZh != null && _selectedGloss!.glossZh!.isNotEmpty)
                              TextSpan(
                                text: ' - ',
                                style: TextStyle(
                                  fontSize: 24.wMin,
                                  color: color_D1D5DC,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2, // 添加行高确保文本对齐
                                ),
                              ),
                            if (_selectedGloss?.glossZh != null && _selectedGloss!.glossZh!.isNotEmpty)
                              TextSpan(
                                text: _selectedGloss!.glossZh!,
                                style: TextStyle(
                                  fontSize: 24.wMin,
                                  color: _isDefinitionRed ? Colors.red : color_D1D5DC,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2, // 添加行高确保文本对齐
                                ),
                              ),
                          ],
                        ),
                      ),
                      // 白色半透明覆盖层，覆盖整个标题文本
                      if (_isDefinitionRed || _isHoveringAnimation)
                        Positioned.fill(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return AnimatedBuilder(
                                animation: _overlayAnimation,
                                builder: (context, child) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: _overlayAnimation.value),
                                      borderRadius: BorderRadius.circular(2.ww),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                  // 第二行：释义和语义 - 分行显示
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 释义
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IntrinsicWidth(
                            key: _secondLineKey,
                            child: Text(
                              _selectedGloss?.definition ?? "",
                              style: TextStyle(
                                fontSize: 24.wMin,
                                color: color_D1D5DC,
                                fontWeight: FontWeight.bold,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                          ),

                          // 动画底线直接放在释义下方
                          // 只在首次渲染完成后才显示动画底线
                          if (_isFirstFrameRendered)
                            SizedBox(
                              width: _titleWidth, // 使用预先计算好的宽度
                              height: 2.wMin,
                              child: Center(
                                child: AnimatedBuilder(
                                  animation: _overlayAnimationController,
                                  builder: (context, child) {
                                    // 只在鼠标悬停时显示蓝色线
                                    final currentWidth = _isTitleHovered ? _titleWidth : 0.0;
                                    return AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeOutCubic,
                                      height: 2.wMin,
                                      width: currentWidth,
                                      decoration: BoxDecoration(
                                        color: color_155DFC, // 线始终是蓝色
                                        borderRadius: BorderRadius.circular(2.wMin),
                                      ),
                                      transformAlignment: Alignment.center,
                                    );
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),

                      // 语义
                      if (_selectedGloss?.semantic != null && _selectedGloss!.semantic!.isNotEmpty)
                        Text(
                          '(${_selectedGloss?.semantic ?? ""})',
                          style: TextStyle(
                            fontSize: 20.wMin,
                            color: color_6A7282,
                            fontWeight: FontWeight.bold,
                          ),
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            iconSize: 24.wMin,
            hoverColor: color_E5E7EB,
            icon: Icon(
              Icons.close,
              color: color_6A7282,
            ),
            onPressed: () {
              Navigator.pop(context);
              widget.onClose.call();
            },
          ),
        ],
      ),
    );
  }

  /// 触发文本颜色变化和覆盖层动画
  /// [isPosChanged] 是否是词性变化，如果是true则词性文本变红，否则释义文本变红
  void _triggerDefinitionAnimation({bool isPosChanged = false}) {
    // 设置文本颜色状态
    safeSetState(() {
      if (isPosChanged) {
        // 如果是词性变化，则词性文本变红
        _isPosRed = true;
        _isDefinitionRed = false;
      } else {
        // 如果是释义变化，则释义文本变红
        _isPosRed = false;
        _isDefinitionRed = true;
      }
    });

    // 重置动画控制器
    _overlayAnimationController.reset();

    // 开始覆盖层动画（淡入-停留-淡出）
    _overlayAnimationController.forward().then((_) {
      // 动画结束后，恢复默认颜色
      safeSetState(() {
        _isPosRed = false;
        _isDefinitionRed = false;
      });
    });
  }

  /// 只触发覆盖层动画，不改变文本颜色
  void _triggerOverlayAnimation() {
    // 添加一个临时变量来追踪鼠标悬停状态
    safeSetState(() {
      _isHoveringAnimation = true;
    });

    // 重置动画控制器
    _overlayAnimationController.reset();

    // 开始覆盖层动画（淡入-停留-淡出）
    _overlayAnimationController.forward().then((_) {
      // 动画结束后重置状态
      safeSetState(() {
        _isHoveringAnimation = false;
      });
    });
  }

  /// 初始化评分选项列表
  void _initRatingOptions() async {
    // 初始化当前星星数量为图片的星级
    _currentStars = _image.imageScore ?? 0;

    try {
      final response = await ImageUtil.introduce(config: RequestConfig(requireToken: true));
      safeSetState(() {
        // 获取选项列表
        _ratingOptions = response.data?.list ?? [];

        // 根据当前星级选中相应的选项
        if (_currentStars > 0 && _ratingOptions.isNotEmpty) {
          for (var option in _ratingOptions) {
            // 将选项的isSelected设置为是否与当前星级相等
            option.isSelected = option.imageScore == _currentStars;
          }
        }
      });
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message ?? "获取选项失败");
    } catch (e) {
      print("获取选项异常: $e");
      ToastUtils.showToast(text: "获取选项失败");
    }
  }

  /// 确认并继续/用户审核
  void onUserReview() async {
    // 如果正在提交，直接返回，防止频繁点击
    if (_isSubmitting) {
      return;
    }

    // 设置提交状态为true
    _isSubmitting = true;

    try {
      // 当前选中的评分选项
      final selectedOption = _ratingOptions.firstWhereOrNull((option) => option.isSelected);

      // 调用API提交评分
      final response = await ImageUtil.review(
          config: RequestConfig(data: {
        "content": _selectedKnowledgePoint?.content,
        "contentType": _selectedKnowledgePoint?.contentType,
        "imageIds": [_image.imageId],
        "imageScore": selectedOption?.imageScore,
      }, requireToken: true));

      if (ObjectUtil.isNotEmpty(response.data)) {
        // 通知外部评分已完成，传递选中的星级、当前词性和释义
        // 接收控制器返回的NextReviewItem对象
        final nextItem = widget.onReview(
            _image,
            selectedOption?.imageScore ?? 0,
            // 传递当前选中的词性
            _selectedPos,
            // 传递当前选中的释义
            _selectedGloss);

        // 如果所有图片已审核完成，关闭对话框
        if (nextItem.isAllReviewed) {
          _showBounceAnimation("所有图片已审核完成");
          // 延迟关闭对话框，让用户有时间看到提示
          Future.delayed(const Duration(milliseconds: 1400), () {
            // 在访问context前检查组件是否仍然挂载
            if (mounted) {
              Navigator.pop(context);
              widget.onClose.call();
            }
          });
        } else if (nextItem.image != null) {
          // 判断词性和释义是否发生变化
          final bool posChanged = _selectedPos != nextItem.pos;
          final bool glossChanged = _selectedGloss != nextItem.gloss;

          // 更新当前图片、词性和释义
          safeSetState(() {
            _image = nextItem.image!;
            _selectedPos = nextItem.pos;
            _selectedGloss = nextItem.gloss;

            // 重置评分选项的选中状态
            for (var option in _ratingOptions) {
              option.isSelected = false;
            }
            _currentStars = 0;
          });

          // 在 safeSetState 外部处理动画和颜色变化
          // 如果词性发生变化，显示词性切换动画
          if (posChanged && _selectedPos != null) {
            _showBounceAnimation("切换到新词性: ${_selectedPos?.description ?? ''}");
            // 触发词性文本颜色变化和覆盖层动画，传递isPosChanged=true
            _triggerDefinitionAnimation(isPosChanged: true);
          } else if (glossChanged && _selectedGloss != null) {
            // 如果释义发生变化，显示释义切换动画
            _showBounceAnimation("切换到新释义: ${_selectedGloss?.definition ?? ''}");
            // 触发释义文本颜色变化和覆盖层动画，默认isPosChanged=false
            _triggerDefinitionAnimation(isPosChanged: false);
          }
        }
      } else {
        throw "审核失败";
      }
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message ?? "审核失败");
    } catch (e) {
      print("审核异常: $e");
      ToastUtils.showToast(text: "审核失败");
    } finally {
      // 无论成功还是失败，最终都要重置提交状态
      _isSubmitting = false;
    }
  }

  ///  确认并继续/管理审核
  void onAdminReview() async {
    // 如果正在提交，直接返回，防止频繁点击
    if (_isSubmitting) {
      return;
    }

    // 设置提交状态为true
    _isSubmitting = true;

    try {
      // 当前选中的评分选项
      final selectedOption = _ratingOptions.firstWhereOrNull((option) => option.isSelected);

      // 调用API提交评分
      final response = await AdminUtil.review(
          config: RequestConfig(data: {
        "content": _selectedKnowledgePoint?.content,
        "contentType": _selectedKnowledgePoint?.contentType,
        "imageIds": [_image.imageId],
        "imageScore": selectedOption?.imageScore,
      }, requireToken: true));

      if (ObjectUtil.isNotEmpty(response.data)) {
        // 通知外部评分已完成，传递选中的星级、当前词性和释义
        // 接收控制器返回的NextReviewItem对象
        final nextItem = widget.onReview(
            _image,
            selectedOption?.imageScore ?? 0,
            // 传递当前选中的词性
            _selectedPos,
            // 传递当前选中的释义
            _selectedGloss);

        // 如果所有图片已审核完成，关闭对话框
        if (nextItem.isAllReviewed) {
          _showBounceAnimation("所有图片已审核完成");
          // 延迟关闭对话框，让用户有时间看到提示
          Future.delayed(const Duration(milliseconds: 1400), () {
            // 在访问context前检查组件是否仍然挂载
            if (mounted) {
              Navigator.pop(context);
              widget.onClose.call();
            }
          });
        } else if (nextItem.image != null) {
          // 判断词性和释义是否发生变化
          final bool posChanged = _selectedPos != nextItem.pos;
          final bool glossChanged = _selectedGloss != nextItem.gloss;

          // 更新当前图片、词性和释义
          safeSetState(() {
            _image = nextItem.image!;
            _selectedPos = nextItem.pos;
            _selectedGloss = nextItem.gloss;

            // 重置评分选项的选中状态
            for (var option in _ratingOptions) {
              option.isSelected = false;
            }
            _currentStars = 0;
          });

          // 在 safeSetState 外部处理动画和颜色变化
          // 如果词性发生变化，显示词性切换动画
          if (posChanged && _selectedPos != null) {
            _showBounceAnimation("切换到新词性: ${_selectedPos?.description ?? ''}");
            // 触发词性文本颜色变化和覆盖层动画，传递isPosChanged=true
            _triggerDefinitionAnimation(isPosChanged: true);
          } else if (glossChanged && _selectedGloss != null) {
            // 如果释义发生变化，显示释义切换动画
            _showBounceAnimation("切换到新释义: ${_selectedGloss?.definition ?? ''}");
            // 触发释义文本颜色变化和覆盖层动画，默认isPosChanged=false
            _triggerDefinitionAnimation(isPosChanged: false);
          }
        }
      } else {
        throw "审核失败";
      }
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message ?? "审核失败");
    } catch (e) {
      print("审核异常: $e");
      ToastUtils.showToast(text: "审核失败");
    } finally {
      // 无论成功还是失败，最终都要重置提交状态
      _isSubmitting = false;
    }
  }

  /// 获取评分选项列表
  List<RatingOption> _getRatingOptions() {
    return _ratingOptions;
  }

  // 检查是否有选中的评分选项
  bool get _hasSelectedRating => _ratingOptions.any((option) => option.isSelected);

  /// 移除提示动画
  void _removeTipOverlay() {
    _tipOverlayEntry?.remove();
    _tipOverlayEntry = null;
  }

  @override
  void dispose() {
    // 释放动画控制器
    _overlayAnimationController.dispose();
    // 移除提示动画
    _removeTipOverlay();
    super.dispose();
  }
}

/// 评分选项卡片组件
class RatingOptionCard extends StatefulWidget {
  /// 索引
  final int index;

  /// 评分选项
  final RatingOption option;

  /// 选中回调
  final Function(RatingOption) onSelect;

  const RatingOptionCard({
    Key? key,
    required this.index,
    required this.option,
    required this.onSelect,
  }) : super(key: key);

  @override
  State<RatingOptionCard> createState() => _RatingOptionCardState();
}

class _RatingOptionCardState extends State<RatingOptionCard> with SafeSetStateMixin {
  /// 是否悬停状态
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.option.isSelected;
    final color = widget.option.color;

    return MouseRegion(
      onEnter: (_) => safeSetState(() => _isHovering = true),
      onExit: (_) => safeSetState(() => _isHovering = false),
      child: GestureDetector(
        onTap: () {
          // 调用选中回调
          widget.onSelect(widget.option);
        },
        child: Container(
          padding: EdgeInsets.all(9.82.ww),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8.ww),
            border: Border.all(
              // 选中时使用选项颜色，悬停时使用淡蓝色，否则使用灰色
              color: isSelected ? color : (_isHovering ? Colors.lightBlue.shade200 : color_364153),
              width: 1.wMin,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 星级和标题
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 左边显示索引+1（圆形容器）
                  Container(
                    width: 24.ww,
                    height: 24.ww,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${widget.index + 1}',
                      style: TextStyle(
                        color: AppTheme.cTextPrimary,
                        fontSize: 14.wMin,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // 右边显示星星数量
                  Row(
                    children: List.generate(5, (starIndex) {
                      // 如果星级大于索引，则点亮星星
                      final isActive = starIndex < (widget.option.imageScore);
                      return Icon(
                        Icons.star,
                        size: 14.wMin,
                        color: isActive ? color_FDC700 : color_D1D5DC,
                      );
                    }),
                  ),
                ],
              ),

              SizedBox(height: 3.wh),

              Text(
                widget.option.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.wMin,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Gaps.getHeight(8.wh),

              // 描述列表
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: widget.option.subIntroduces.map((desc) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 6.wh),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 分类标题
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('• ', style: TextStyle(fontSize: 14.wMin, color: color_99A1AF)),
                              Text(
                                desc.category + (desc.items.isNotEmpty ? '：' : ''),
                                style: TextStyle(fontSize: 18.wMin, color: color_99A1AF),
                              ),
                            ],
                          ),
                          // 分类下的项目列表
                          ...desc.items.map((item) {
                            return Padding(
                              padding: EdgeInsets.only(left: 8.ww, top: 1.wh),
                              child: Text(
                                item,
                                style: TextStyle(fontSize: 18.wMin, color: color_99A1AF),
                                maxLines: 5,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
