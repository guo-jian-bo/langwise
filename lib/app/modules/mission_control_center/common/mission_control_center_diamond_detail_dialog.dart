import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/theme/theme_utils.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

class MissionControlCenterDiamondDetailDialog {
  static Future<bool> show({
    required BuildContext context,
    required List<TaskDiamondDetailItem> details,
    GlobalKey? collectTargetKey,
  }) async {
    final bool? result = await showCupertinoDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => MissionControlCenterDiamondDetailDialogWidget(
        details: details,
        collectTargetKey: collectTargetKey,
      ),
    );
    return result ?? false;
  }
}

class MissionControlCenterDiamondDetailDialogWidget extends StatefulWidget {
  final List<TaskDiamondDetailItem> details;
  final GlobalKey? collectTargetKey;

  const MissionControlCenterDiamondDetailDialogWidget({
    super.key,
    required this.details,
    this.collectTargetKey,
  });

  @override
  State<MissionControlCenterDiamondDetailDialogWidget> createState() =>
      _MissionControlCenterDiamondDetailDialogWidgetState();
}

class _MissionControlCenterDiamondDetailDialogWidgetState
    extends State<MissionControlCenterDiamondDetailDialogWidget>
    with TickerProviderStateMixin {
  final GlobalKey _targetKey = GlobalKey();
  final List<_DiamondAnimItem> _diamondItems = [];

  bool _showCollectAnimation = false;
  bool _listReady = false;
  bool _submitting = false;

  int get _totalDiamondCount => widget.details.fold<int>(
        0,
        (sum, item) => sum + (item.diamondCount ?? 0),
      );

  @override
  void initState() {
    super.initState();
    _initDiamondItems();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;
      setState(() {
        _listReady = true;
      });
    });
  }

  void _initDiamondItems() {
    final details = widget.details.length > 10
        ? widget.details.sublist(0, 10)
        : widget.details;
    for (int i = 0; i < details.length; i++) {
      _diamondItems.add(
        _DiamondAnimItem(
          key: GlobalKey(),
          detail: details[i],
          offset: Offset(-(i * 10.wMin), i * 15.wMin),
        ),
      );
    }
  }

  Future<void> _onContinue() async {
    if (_submitting || !_listReady) return;
    final uids = widget.details
        .map((item) => item.uid?.toString() ?? '')
        .where((item) => item.isNotEmpty)
        .toList();
    if (uids.isEmpty) {
      Get.back(result: false);
      return;
    }

    _submitting = true;
    if (mounted) setState(() {});
    try {
      final bool ok = await MissionRequest.readTaskDiamondDetail(uids);
      if (!ok) {
        ToastUtils.showToast(text: '领取失败，请稍后再试');
        return;
      }
      await _runCollectAnimation();
    } finally {
      _submitting = false;
      if (mounted) setState(() {});
    }
  }

  Future<void> _runCollectAnimation() async {
    _showCollectAnimation = true;
    if (mounted) setState(() {});

    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    final RenderBox? stackBox = context.findRenderObject() as RenderBox?;
    final RenderBox? targetBox = _resolveCollectTargetBox();
    if (stackBox == null || targetBox == null) {
      Get.back(result: true);
      return;
    }

    final Size stackSize = stackBox.size;
    final Size targetSize = targetBox.size;
    Offset end = stackBox.globalToLocal(targetBox.localToGlobal(Offset.zero));
    end = end - Offset((stackSize.width - targetSize.width) / 2, 100.wMin);
    end = end + Offset(0, targetSize.height / 2);

    for (int i = _diamondItems.length - 1; i >= 0; i--) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      final GlobalKey key = _diamondItems[i].key;
      final RenderBox? box = key.currentContext?.findRenderObject() as RenderBox?;
      if (box == null) continue;
      final Size boxSize = box.size;
      final Offset begin = _diamondItems[i].offset;
      final Offset offset = end - Offset(0, boxSize.height / 2);

      _animateToOffset(
        begin: begin,
        end: offset,
        onUpdate: (current, value) {
          _diamondItems[i].scale = 1.0 - value * 0.95;
          _diamondItems[i].offset = current;
          if (mounted) setState(() {});
        },
        onCompleted: () {
          _diamondItems.removeAt(i);
          if (mounted) setState(() {});
          if (_diamondItems.isEmpty) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                Get.back(result: true);
              }
            });
          }
        },
      );
    }
  }

  void _animateToOffset({
    required Offset begin,
    required Offset end,
    int milliseconds = 200,
    Curve curve = Curves.linear,
    void Function(Offset offset, double value)? onUpdate,
    void Function()? onCompleted,
  }) {
    final AnimationController controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: milliseconds),
    );

    final animation = Tween<Offset>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(parent: controller, curve: curve));

    controller.addListener(() {
      onUpdate?.call(animation.value, controller.value);
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
        onCompleted?.call();
      }
    });

    controller.forward();
  }

  RenderBox? _resolveCollectTargetBox() {
    final RenderBox? externalTargetBox =
        widget.collectTargetKey?.currentContext?.findRenderObject() as RenderBox?;
    if (externalTargetBox != null) return externalTargetBox;
    return _targetKey.currentContext?.findRenderObject() as RenderBox?;
  }

  Rect? _resolveCollectTargetRect() {
    final RenderBox? targetBox =
        widget.collectTargetKey?.currentContext?.findRenderObject() as RenderBox?;
    if (targetBox == null) return null;
    final Offset topLeft = targetBox.localToGlobal(Offset.zero);
    return topLeft & targetBox.size;
  }

  bool get _hasExternalCollectTarget => widget.collectTargetKey?.currentContext != null;

  @override
  Widget build(BuildContext context) {
    final bool useExternalTargetHighlight =
        _showCollectAnimation && _hasExternalCollectTarget;
    final scaffold = Scaffold(
      backgroundColor: useExternalTargetHighlight
          ? Colors.transparent
          : AppTheme.cOverlayBackground.color.withValues(alpha: 0.2),
      extendBody: true,
      body: Stack(
        children: [
          if (useExternalTargetHighlight) Positioned.fill(child: _buildCollectHighlightMask()),
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: _showCollectAnimation ? _buildCollectView() : _buildListView(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: _showCollectAnimation
            ? (_hasExternalCollectTarget
                ? const SizedBox(key: ValueKey(true), height: 120)
                : _buildCollectNavWidget())
            : _buildBottomBar(),
      ),
    );
    return PopScope(
      canPop: false,
      child: useExternalTargetHighlight
          ? scaffold
          : PlatformBackdropFilterWidget(
              sigmaX: 5.wMin,
              sigmaY: 5.wMin,
              child: scaffold,
            ),
    );
  }

  Widget _buildListView() {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 32.wMin,
          right: 32.wMin,
          top: MediaQuery.of(context).padding.top + 110.wMin,
          bottom: MediaQuery.of(context).padding.bottom + 180.wMin,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              (widget.details.length / 5).ceil(),
              (rowIndex) {
                final start = rowIndex * 5;
                final end = (start + 5) > widget.details.length
                    ? widget.details.length
                    : (start + 5);
                final rowItems = widget.details.sublist(start, end);
                return Padding(
                  padding: EdgeInsets.only(bottom: rowIndex == (widget.details.length / 5).ceil() - 1 ? 0 : 28.wMin),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(rowItems.length * 2 - 1, (index) {
                      if (index.isOdd) {
                        return SizedBox(width: 24.wMin);
                      }
                      final itemIndex = index ~/ 2;
                      return _buildDetailItem(rowItems[itemIndex]);
                    }),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(TaskDiamondDetailItem item, {Key? widgetKey}) {
    final int count = item.diamondCount ?? 0;
    return SizedBox(
      key: widgetKey,
      width: 340.wMin,
      height: 230.wMin,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 40.wMin,
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity,
              height: 230.wMin,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.wMin),
                color: AppTheme.cBgSecondary.color,
                border: Border(
                  top: BorderSide(
                    color: const Color(0xFFA855F7),
                    width: 4.wMin,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    height: 96.wMin,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.fromRGBO(168, 85, 247, 0.25),
                          Color.fromRGBO(168, 85, 247, 0),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding:
                          EdgeInsets.fromLTRB(24.wMin, 0, 24.wMin, 28.wMin),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            _cardTitle(item),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 40.wMin,
                              color: AppTheme.cTextPrimary,
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 10.wMin),
                          Text(
                            '获得了$count颗钻石',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24.wMin,
                              color: AppTheme.cTextPrimary,
                              fontWeight: FontWeight.w400,
                              height: 1.2,
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
          Positioned(
            top: 0,
            child: Image.asset(
              _diamondAssetPath(isSuccess: true),
              width: 140.wMin,
              height: 140.wMin,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: 120.wMin,
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(top: 12.wMin),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: _listReady ? 1 : 0,
        child: ButtonWidget(
          text: _submitting ? '领取中...' : '继续',
          color: Color(0xFFA855F7),
          width: 320.wMin,
          height: 64.wMin,
          fontSize: 28.wMin,
          fontColor: AppTheme.cStaticWhite,
          fontWeight: FontWeight.w500,
          borderRadius: 12.wMin,
          sclae: 1.01,
          onTap: !_listReady || _submitting ? null : _onContinue,
        ),
      ),
    );
  }

  Widget _buildCollectView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.only(top: 100.wMin),
      child: Stack(
        alignment: Alignment.topCenter,
        children: List.generate(_diamondItems.length, (index) {
          final item = _diamondItems[index];
          return Transform.translate(
            offset: item.offset,
            child: Transform.scale(
              scale: item.scale,
              child: _buildDetailItem(item.detail, widgetKey: item.key),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCollectHighlightMask() {
    final Rect? targetRect = _resolveCollectTargetRect();
    final overlayColor = AppTheme.cOverlayBackground.color.withValues(alpha: 0.18);
    if (targetRect == null) {
      return ClipRect(
        child: PlatformBackdropFilterWidget(
          sigmaX: 5.wMin,
          sigmaY: 5.wMin,
          child: ColoredBox(color: overlayColor),
        ),
      );
    }
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            right: 0,
            height: targetRect.top,
            child: _buildBackdropOverlayRegion(overlayColor),
          ),
          Positioned(
            left: 0,
            top: targetRect.top,
            width: targetRect.left,
            height: targetRect.height,
            child: _buildBackdropOverlayRegion(overlayColor),
          ),
          Positioned(
            right: 0,
            top: targetRect.top,
            width: MediaQuery.of(context).size.width - targetRect.right,
            height: targetRect.height,
            child: _buildBackdropOverlayRegion(overlayColor),
          ),
          Positioned(
            left: 0,
            top: targetRect.bottom,
            right: 0,
            bottom: 0,
            child: _buildBackdropOverlayRegion(overlayColor),
          ),
        ],
      ),
    );
  }

  Widget _buildBackdropOverlayRegion(Color overlayColor) {
    return ClipRect(
      child: PlatformBackdropFilterWidget(
        sigmaX: 5.wMin,
        sigmaY: 5.wMin,
        child: ColoredBox(color: overlayColor),
      ),
    );
  }

  Widget _buildCollectNavWidget() {
    return Container(
      key: const ValueKey(true),
      height: 120.wMin,
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.only(bottom: 24.wMin),
      child: Container(
        key: _targetKey,
        padding: EdgeInsets.symmetric(horizontal: 20.wMin, vertical: 12.wMin),
        decoration: BoxDecoration(
          color: AppTheme.cBgSecondary.color,
          borderRadius: BorderRadius.circular(999.wMin),
          border: Border.all(
            color: AppTheme.cBorderPrimary.color,
            width: 1.wMin,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              _diamondAssetPath(isSuccess: true),
              width: 32.wMin,
              height: 32.wMin,
            ),
            SizedBox(width: 10.wMin),
            Text(
              '+$_totalDiamondCount',
              style: TextStyle(
                fontSize: 26.wMin,
                color: const Color(0xFFE2B93B),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _diamondAssetPath({required bool isSuccess}) {
    final bool isLight = ThemeUtils.isCurrentTheme(AppThemeKey.light.value);
    if (isLight) {
      return isSuccess
          ? 'assets/images/mission/icon_diamond_yes.png'
          : 'assets/images/mission/icon_diamond.png';
    }
    return isSuccess
        ? 'assets/images/mission/icon_diamond_black_yes.png'
        : 'assets/images/mission/icon_diamond_black.png';
  }

  String _typeText(String? type) {
    switch ((type ?? '').toLowerCase()) {
      case 'listening':
        return '听';
      case 'speaking':
        return '说';
      case 'reading':
        return '读';
      case 'writing':
        return '写';
      case 'overall':
        return '综合';
      default:
        return '任务';
    }
  }

  String _cardTitle(TaskDiamondDetailItem item) {
    final title = _typeText(item.type);
    return '专项拓展·$title';
  }
}

class _DiamondAnimItem {
  final GlobalKey key;
  final TaskDiamondDetailItem detail;
  Offset offset;
  double scale = 1;

  _DiamondAnimItem({
    required this.key,
    required this.detail,
    required this.offset,
  });
}
