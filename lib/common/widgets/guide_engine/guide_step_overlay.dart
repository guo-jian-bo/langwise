import 'dart:async';
import 'dart:math' as math;

import 'package:bubble_box/bubble_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'guide_engine.dart';


class GuideStepOverlayDialog{

  /// 关闭引导浮层
  static void close(TutorialCoachMark tutorialCoachMark) {
    tutorialCoachMark.removeOverlayEntry();
  }

  /// 昕示引导浮层。
  ///
  /// 这个方法负责创建并展示引导浮层，不负责步骤调度。
  /// 也就是说，它只负责“引导气泡本身的 UI 展示”，不负责步骤调度。
  ///
  /// 这个方法返回一个 `TutorialCoachMark` 实例，用于后续的展示和隐藏。
  ///
  static TutorialCoachMark? show({
    required String identify,
    required GuideTaskGuide guide,
    required BuildContext context,
    required GlobalKey targetKey,
    String? progressText,
    void Function()? onCloseTap,
    void Function()? onActionTap,
    void Function()? onFinish,
    bool Function()? onSkip,
    FutureOr<void> Function(TargetFocus)? onClickTarget,
  }) {

    ContentAlign align = _autoDetectPlacement(
      context: context,
      targetKey: targetKey,
    );

    BubbleDirection direction = getBubbleDirection(align);

    final TargetFocus target = TargetFocus(
      identify: identify,
      keyTarget: targetKey,
      shape: ShapeLightFocus.RRect,
      radius: 12.wMin,
      enableOverlayTab: false,
      enableTargetTab: true,
      paddingFocus: 0,
      pulseVariation: Tween<double>(begin: 1.0, end: 0.995),
      borderSide: BorderSide(
        color: Colors.white,
        width: 1.wMin,
      ),
      contents: <TargetContent>[
        TargetContent(
          align: align,
          padding: EdgeInsets.zero,
          builder: (_, __) {
            return GuideStepOverlay(
              targetKey: targetKey,
              title: guide.title,
              content: guide.content,
              progressText: progressText,
              direction: direction,
              showCloseButton: guide.showCloseButton,
              onCloseTap: onCloseTap,
              onActionTap: onActionTap,
            );
          },
        ),
      ],
    );

    TutorialCoachMark tutorialCoachMark = TutorialCoachMark(
      targets: <TargetFocus>[target],
      hideSkip: true,
      colorShadow: Colors.black,
      opacityShadow: 0.5,
      paddingFocus: 0,
      pulseEnable: true,
      disableBackButton: true,
      focusAnimationDuration: const Duration(milliseconds: 300),
      unFocusAnimationDuration: const Duration(milliseconds: 300),
      onClickOverlay: (_) {},
      onClickTarget: onClickTarget,
      onFinish: onFinish,
      onSkip: onSkip,
    );

    tutorialCoachMark.show(context: context);

    return tutorialCoachMark;
  }
  /// 自动判断气泡展示方向。
  ///
  /// 这个方法会根据目标区域的位置，自动判断气泡展示的方向。
  /// 例如，如果目标区域在屏幕顶部，气泡会展示在底部；如果在底部，气泡会展示在顶部，如果在左侧，气泡会展示在右侧，如果在右侧，气泡会展示在左侧。
  static ContentAlign _autoDetectPlacement({
    required BuildContext context,
    required GlobalKey targetKey,
  }) {
    final targetContext = targetKey.currentContext;
    if (targetContext == null) return ContentAlign.bottom;

    final RenderObject? targetRenderObject = targetContext.findRenderObject();
    if (targetRenderObject is! RenderBox || !targetRenderObject.attached || !targetRenderObject.hasSize) {
      return ContentAlign.bottom;
    }

    final mediaQuery = MediaQuery.maybeOf(context);
    final Size screenSize = mediaQuery?.size ?? View.of(context).physicalSize / View.of(context).devicePixelRatio;
    final EdgeInsets safePadding = mediaQuery?.padding ?? EdgeInsets.zero;

    final RenderObject? overlayRenderObject = Overlay.maybeOf(context)?.context.findRenderObject();
    final Offset topLeft = overlayRenderObject is RenderBox
        ? targetRenderObject.localToGlobal(Offset.zero, ancestor: overlayRenderObject)
        : targetRenderObject.localToGlobal(Offset.zero);
    final Rect targetRect = topLeft & targetRenderObject.size;

    final double topSpace = targetRect.top - safePadding.top;
    final double bottomSpace = screenSize.height - safePadding.bottom - targetRect.bottom;
    final double leftSpace = targetRect.left - safePadding.left;
    final double rightSpace = screenSize.width - safePadding.right - targetRect.right;

    final ContentAlign bestVertical = bottomSpace >= topSpace
        ? ContentAlign.bottom
        : ContentAlign.top;
    final ContentAlign bestHorizontal = rightSpace >= leftSpace
        ? ContentAlign.right
        : ContentAlign.left;

    final double verticalSpace = math.max(topSpace, bottomSpace);
    final double horizontalSpace = math.max(leftSpace, rightSpace);

    // 当前引导气泡是偏说明型内容，常规场景下优先使用上下布局。
    if (targetRect.width >= screenSize.width * 0.5 ||
        verticalSpace >= 160 ||
        verticalSpace >= horizontalSpace) {
      return bestVertical;
    }

    return bestHorizontal;
  }

  /// 获取箭头方向
  static BubbleDirection getBubbleDirection(ContentAlign align) {
    if(align == ContentAlign.bottom){
      return BubbleDirection.top;
    }else if(align == ContentAlign.top){
      return BubbleDirection.bottom;
    }else if(align == ContentAlign.right){
      return BubbleDirection.left;
    }else if(align == ContentAlign.left){
      return BubbleDirection.right;
    }
    return BubbleDirection.none;
  }

  

}


/// 单步引导浮层内容组件
///
/// 这个组件只负责“引导气泡本身的 UI 展示”，不负责步骤调度。
///
/// 也就是说：
///
/// - `GuideTaskController` 负责决定当前该展示哪个步骤
/// - `tutorial_coach_mark` 负责遮罩和高亮目标区域
/// - `GuideStepOverlay` 只负责显示标题、说明文案和操作按钮
///
/// 这样拆分后，控制器里就不需要硬编码一大段 UI，
/// 后续如果想统一更换视觉风格，也只需要改这个组件。

class GuideStepOverlay extends StatefulWidget {
  /// 目标widget key
  final GlobalKey targetKey;

  /// 当前步骤标题。
  final String title;

  /// 当前步骤说明文案。
  final String content;

  /// 可选的进度提示，例如“1/3”。
  final String? progressText;

  /// 主按钮文案。
  ///
  /// 这个按钮通常表示“我知道了”“关闭提示”等行为，
  /// 默认并不等于“步骤完成上报”。
  final String actionText;

  /// 点击关闭按钮时的回调。
  final VoidCallback? onCloseTap;

  /// 点击主按钮时的回调。
  final VoidCallback? onActionTap;

  /// 是否显示右上角关闭按钮。
  final bool showCloseButton;

  /// 箭头方向
  final BubbleDirection direction;

  /// 创建一个统一风格的引导浮层内容组件。
  const GuideStepOverlay({
    super.key,
    required this.targetKey,
    required this.title,
    required this.content,
    this.progressText,
    this.actionText = '我知道了',
    this.showCloseButton = true,
    this.onCloseTap,
    this.onActionTap,
    this.direction = BubbleDirection.none,
  });

  @override
  State<GuideStepOverlay> createState() => _GuideStepOverlayState();
}

class _GuideStepOverlayState extends State<GuideStepOverlay> {
  final GlobalKey _bubbleKey = GlobalKey();
  final GlobalKey _contentRootKey = GlobalKey();
  double _arrowOffset = 0;
  double _bubbleWidth = 320;
  Rect? _contentRootRect;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateBubbleMetrics());
  }

  @override
  void didUpdateWidget(covariant GuideStepOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateBubbleMetrics());
  }

  void _updateBubbleMetrics() {
    if (!mounted) return;

    final BuildContext? bubbleContext = _bubbleKey.currentContext;
    final BuildContext? contentRootContext = _contentRootKey.currentContext;
    final BuildContext? targetContext = widget.targetKey.currentContext;
    if (bubbleContext == null || contentRootContext == null || targetContext == null) return;

    final RenderObject? bubbleObject = bubbleContext.findRenderObject();
    final RenderObject? contentRootObject = contentRootContext.findRenderObject();
    final RenderObject? targetObject = targetContext.findRenderObject();
    final RenderObject? overlayObject = Overlay.maybeOf(context)?.context.findRenderObject();
    if (bubbleObject is! RenderBox ||
        contentRootObject is! RenderBox ||
        targetObject is! RenderBox ||
        overlayObject is! RenderBox ||
        !bubbleObject.attached ||
        !contentRootObject.attached ||
        !targetObject.attached ||
        !bubbleObject.hasSize ||
        !contentRootObject.hasSize ||
        !targetObject.hasSize) {
      return;
    }

    final Rect bubbleRect =
        bubbleObject.localToGlobal(Offset.zero, ancestor: overlayObject) &
            bubbleObject.size;
    final Rect contentRootRect =
        contentRootObject.localToGlobal(Offset.zero, ancestor: overlayObject) &
            contentRootObject.size;
    final Rect targetRect =
        targetObject.localToGlobal(Offset.zero, ancestor: overlayObject) &
            targetObject.size;
    final double nextArrowOffset = _resolveArrowOffset(
      bubbleRect: bubbleRect,
      targetRect: targetRect,
      direction: widget.direction,
    );

    final bool arrowChanged = (nextArrowOffset - _arrowOffset).abs() > 0.5;
    final bool contentRootChanged = _contentRootRect == null ||
        (contentRootRect.left - _contentRootRect!.left).abs() > 0.5 ||
        (contentRootRect.top - _contentRootRect!.top).abs() > 0.5 ||
        (contentRootRect.width - _contentRootRect!.width).abs() > 0.5 ||
        (contentRootRect.height - _contentRootRect!.height).abs() > 0.5;

    if (arrowChanged || contentRootChanged) {
      setState(() {
        if (arrowChanged) {
          _arrowOffset = nextArrowOffset;
        }
        _contentRootRect = contentRootRect;
      });
    }
  }

  Size _resolveOverlaySize(BuildContext context) {
    final RenderObject? overlayObject =
        Overlay.maybeOf(context)?.context.findRenderObject();
    if (overlayObject is RenderBox && overlayObject.attached && overlayObject.hasSize) {
      return overlayObject.size;
    }
    return MediaQuery.sizeOf(context);
  }

  double _resolveBubbleWidth(BuildContext context) {
    final double screenWidth = _resolveOverlaySize(context).width;
    final double horizontalMargin = 24.wMin;
    final double maxWidth = math.min(
      800.wMin,
      math.max(260.wMin, screenWidth - horizontalMargin * 2),
    );
    final double minWidth = 260.wMin;
    final double titleWidth = _measureTextWidth(
      text: widget.title,
      style: TextStyle(
        color: Colors.white,
        fontSize: 24.wMin,
        fontWeight: FontWeight.w600,
      ),
      maxWidth: maxWidth,
    );
    final double contentWidth = _measureTextWidth(
      text: widget.content,
      style: TextStyle(
        color: Colors.white,
        fontSize: 22.wMin,
        fontWeight: FontWeight.w400,
      ),
      maxWidth: maxWidth,
    );
    final double progressWidth = _measureTextWidth(
      text: widget.progressText ?? '',
      style: TextStyle(
        color: Colors.white70,
        fontSize: 22.wMin,
        fontWeight: FontWeight.w600,
      ),
      maxWidth: maxWidth,
    );
    final double actionReserveWidth =
        widget.showCloseButton ? 56.wMin : 16.wMin;
    final double horizontalPadding = 32.wMin;
    final double measuredWidth = math.max(
      titleWidth + actionReserveWidth,
      math.max(contentWidth, progressWidth),
    ) +
        horizontalPadding;

    return measuredWidth.clamp(minWidth, maxWidth);
  }

  double _measureTextWidth({
    required String text,
    required TextStyle style,
    required double maxWidth,
  }) {
    if (text.trim().isEmpty) return 0;
    final TextPainter painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 3,
      ellipsis: '...',
    )..layout(maxWidth: maxWidth - 32.wMin);
    return painter.size.width;
  }

  Rect? _resolveTargetRect(BuildContext context) {
    final BuildContext? targetContext = widget.targetKey.currentContext;
    if (targetContext == null) return null;

    final RenderObject? targetObject = targetContext.findRenderObject();
    final RenderObject? overlayObject = Overlay.maybeOf(context)?.context.findRenderObject();
    if (targetObject is! RenderBox ||
        overlayObject is! RenderBox ||
        !targetObject.attached ||
        !targetObject.hasSize) {
      return null;
    }

    final Offset offset =
        targetObject.localToGlobal(Offset.zero, ancestor: overlayObject);
    return offset & targetObject.size;
  }

  double _resolveBubbleLeft({
    required BuildContext context,
    required double bubbleWidth,
  }) {
    final Rect? targetRect = _resolveTargetRect(context);
    if (targetRect == null) return 16.wMin;

    final double screenWidth = _resolveOverlaySize(context).width;
    final double edge = 16.wMin;
    final double contentRootLeft = _contentRootRect?.left ?? 0;
    final double contentRootWidth = _contentRootRect?.width ?? screenWidth;
    final double minLeft = math.max(0, edge - contentRootLeft);
    final double maxLeft = math.min(
      contentRootWidth - bubbleWidth,
      screenWidth - edge - bubbleWidth - contentRootLeft,
    );
    final double desiredLeft =
        targetRect.center.dx - bubbleWidth / 2 - contentRootLeft;

    if (maxLeft <= minLeft) {
      return minLeft;
    }

    return desiredLeft.clamp(minLeft, maxLeft);
  }

  double _resolveArrowOffset({
    required Rect bubbleRect,
    required Rect targetRect,
    required BubbleDirection direction,
  }) {
    const double minEdgeSpacing = 26;
    if (direction == BubbleDirection.top || direction == BubbleDirection.bottom) {
      final double offset = targetRect.center.dx - bubbleRect.left;
      return offset.clamp(minEdgeSpacing.wMin, bubbleRect.width - minEdgeSpacing.wMin);
    }

    if (direction == BubbleDirection.left || direction == BubbleDirection.right) {
      final double offset = targetRect.center.dy - bubbleRect.top;
      return offset.clamp(minEdgeSpacing.wMin, bubbleRect.height - minEdgeSpacing.wMin);
    }

    return bubbleRect.width / 2;
  }

  EdgeInsets _bubblePadding() {
    final double arrowSpace = 10.wMin;
    final double contentHorizontal = 10.wMin;
    final double contentVertical = 10.wMin;

    if (widget.direction == BubbleDirection.top) {
      return EdgeInsets.fromLTRB(
        contentHorizontal,
        contentVertical + arrowSpace,
        contentHorizontal,
        contentVertical,
      );
    }

    if (widget.direction == BubbleDirection.bottom) {
      return EdgeInsets.fromLTRB(
        contentHorizontal,
        contentVertical,
        contentHorizontal,
        contentVertical + arrowSpace,
      );
    }

    if (widget.direction == BubbleDirection.left) {
      return EdgeInsets.fromLTRB(
        contentHorizontal + arrowSpace,
        contentVertical,
        contentHorizontal,
        contentVertical,
      );
    }

    if (widget.direction == BubbleDirection.right) {
      return EdgeInsets.fromLTRB(
        contentHorizontal,
        contentVertical,
        contentHorizontal + arrowSpace,
        contentVertical,
      );
    }

    return EdgeInsets.all(contentVertical);
  }

  Offset _bubbleCompensationOffset(BuildContext context) {
    final Rect? targetRect = _resolveTargetRect(context);
    if (targetRect == null) return Offset.zero;

    // tutorial_coach_mark 在上下布局时会额外引入约 10% 目标高度的间距，
    // 这里做动态抵消，并保留一个固定视觉间距。
    final double desiredGap = 16.wMin;
    final double extraSpacing = targetRect.height * 0.1;

    if (widget.direction == BubbleDirection.top) {
      return Offset(0, desiredGap - extraSpacing);
    }

    if (widget.direction == BubbleDirection.bottom) {
      return Offset(0, extraSpacing - desiredGap);
    }

    return Offset.zero;
  }

  @override
  Widget build(BuildContext context) {
    _bubbleWidth = _resolveBubbleWidth(context);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateBubbleMetrics());
    final bool useFullWidthWrapper =
        widget.direction == BubbleDirection.top ||
        widget.direction == BubbleDirection.bottom;
    final double screenWidth = _resolveOverlaySize(context).width;
    final double bubbleLeft = useFullWidthWrapper
        ? _resolveBubbleLeft(
            context: context,
            bubbleWidth: _bubbleWidth,
          )
        : 0;
    final Widget bubbleBody = SizedBox(
      key: _bubbleKey,
      width: _bubbleWidth,
      child: CustomPaint(
        painter: _GuideStepBubblePainter(
          direction: widget.direction,
          arrowOffset: _arrowOffset == 0 ? _bubbleWidth / 2 : _arrowOffset,
          radius: 16.wMin,
        ),
        child: Stack(
          children: [
            Padding(
              padding: _bubblePadding(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.wMin,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.wMin),
                  Text(
                    widget.content,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.wMin,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Visibility(
                    visible: widget.progressText != null &&
                        widget.progressText!.trim().isNotEmpty,
                    child: Container(
                      margin: EdgeInsets.only(top: 8.wMin),
                      alignment: Alignment.centerRight,
                      child: Text(
                        widget.progressText ?? "",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 22.wMin,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: widget.showCloseButton,
              child: Positioned(
                top: 16.wMin,
                right: 10.wMin,
                child: TapScaleWidget(
                  onTap: widget.onCloseTap,
                  sclae: 1.1,
                  child: Container(
                    padding: EdgeInsets.all(4.wMin),
                    color: Colors.transparent,
                    child: SvgPicture.asset(
                      'assets/svg/public/x.svg',
                      width: 32.wMin,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Material(
      color: Colors.transparent,
      child: Transform.translate(
        offset: _bubbleCompensationOffset(context),
        child: useFullWidthWrapper
            ? SizedBox(
                key: _contentRootKey,
                width: screenWidth,
                child: Padding(
                  padding: EdgeInsets.only(left: bubbleLeft),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: bubbleBody,
                  ),
                ),
              )
            : SizedBox(
                key: _contentRootKey,
                child: bubbleBody,
              ),
      ),
    );
  }
}

class _GuideStepBubblePainter extends CustomPainter {
  final BubbleDirection direction;
  final double arrowOffset;
  final double radius;

  const _GuideStepBubblePainter({
    required this.direction,
    required this.arrowOffset,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double arrowWidth = 20.wMin;
    final double arrowHeight = 10.wMin;
    final Paint backgroundPaint = Paint()..color = const Color(0xFF38BDF8);
    final Path path = Path();

    Rect bodyRect = Offset.zero & size;
    if (direction == BubbleDirection.top) {
      bodyRect = Rect.fromLTWH(0, arrowHeight, size.width, size.height - arrowHeight);
    } else if (direction == BubbleDirection.bottom) {
      bodyRect = Rect.fromLTWH(0, 0, size.width, size.height - arrowHeight);
    } else if (direction == BubbleDirection.left) {
      bodyRect = Rect.fromLTWH(arrowHeight, 0, size.width - arrowHeight, size.height);
    } else if (direction == BubbleDirection.right) {
      bodyRect = Rect.fromLTWH(0, 0, size.width - arrowHeight, size.height);
    }

    path.addRRect(RRect.fromRectAndRadius(bodyRect, Radius.circular(radius)));

    if (direction == BubbleDirection.top || direction == BubbleDirection.bottom) {
      final double clampedDx = arrowOffset.clamp(
        radius + arrowWidth / 2 + 2,
        size.width - radius - arrowWidth / 2 - 2,
      );
      if (direction == BubbleDirection.top) {
        path.moveTo(clampedDx - arrowWidth / 2, arrowHeight);
        path.lineTo(clampedDx, 0);
        path.lineTo(clampedDx + arrowWidth / 2, arrowHeight);
      } else {
        final double y = size.height - arrowHeight;
        path.moveTo(clampedDx - arrowWidth / 2, y);
        path.lineTo(clampedDx, size.height);
        path.lineTo(clampedDx + arrowWidth / 2, y);
      }
      path.close();
    }

    if (direction == BubbleDirection.left || direction == BubbleDirection.right) {
      final double clampedDy = arrowOffset.clamp(
        radius + arrowWidth / 2 + 2,
        size.height - radius - arrowWidth / 2 - 2,
      );
      if (direction == BubbleDirection.left) {
        path.moveTo(arrowHeight, clampedDy - arrowWidth / 2);
        path.lineTo(0, clampedDy);
        path.lineTo(arrowHeight, clampedDy + arrowWidth / 2);
      } else {
        final double x = size.width - arrowHeight;
        path.moveTo(x, clampedDy - arrowWidth / 2);
        path.lineTo(size.width, clampedDy);
        path.lineTo(x, clampedDy + arrowWidth / 2);
      }
      path.close();
    }

    canvas.drawPath(path, backgroundPaint);
  }

  @override
  bool shouldRepaint(covariant _GuideStepBubblePainter oldDelegate) {
    return oldDelegate.direction != direction ||
        oldDelegate.arrowOffset != arrowOffset ||
        oldDelegate.radius != radius;
  }
}
