import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../theme/theme.dart';
import '../../entities/entities.dart';
import '../../enum/enum.dart';
import '../widgets.dart';


/// 播放器页面类型
class PlayPageTypeConfig{
  /// 页面类型列表
  List<ZhenduLearnItems>? learnItems;
  /// 当前页面的类型
  ZhenduPageTypeEnum currentPageType;
  /// 页面类型回调
  void Function(ZhenduLearnItems item)? onPageTypeChange;
  
  PlayPageTypeConfig({
    this.learnItems,
    required this.currentPageType,
    this.onPageTypeChange,
  });

}

class PlayPageTypeButtonWidget extends StatefulWidget {
  /// 页面类型配置
  final PlayPageTypeConfig? pageTypeConfig;
  /// 弹窗显示回调
  final void Function(bool visible)? onPopupVisibilityChanged;
  const PlayPageTypeButtonWidget({super.key, this.pageTypeConfig, this.onPopupVisibilityChanged});

  @override
  State<PlayPageTypeButtonWidget> createState() => _PlayPageTypeButtonWidgetState();
}

class _PlayPageTypeButtonWidgetState extends State<PlayPageTypeButtonWidget> {


  Function()? _closePageTypeDialog;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _closePageTypeDialog?.call();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PlayPageTypeButtonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.pageTypeConfig?.learnItems, widget.pageTypeConfig?.learnItems)) {
      _closePageTypeDialog?.call();
    }
   }

  void _notifyPopupVisibility(bool visible){
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onPopupVisibilityChanged?.call(visible);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildPageTypeButton();
  }

    /// 页面类型按钮
  Widget _buildPageTypeButton(){
    List<ZhenduLearnItems> learnItems = widget.pageTypeConfig?.learnItems ?? [];
    ZhenduPageTypeEnum? currentPageType = widget.pageTypeConfig?.currentPageType;
    if(currentPageType == null) return const SizedBox();
    ZhenduLearnItems? currentPageItem = learnItems.firstWhereOrNull((element) => element.pageType == currentPageType);
    if(currentPageItem == null) return const SizedBox();
    Color fromColor = currentPageItem.color?.fromColor??AppTheme.cSurfaceBrand.color;
    Color toColor = currentPageItem.color?.toColor??AppTheme.cSurfaceBrand.color;
    LanguageText? title = LearningLangUtils.getLocalLang(currentPageItem.title);

    return Builder(
      builder: (context) {
        return TapScaleWidget(
          onTap: () {
            _closePageTypeDialog?.call();
            _closePageTypeDialog = PlayPageTypeDialog.showPageTypeDialog(
              context: context,
              learnItems: learnItems,
              currentPageType: currentPageType,
              onPageTypeChange: widget.pageTypeConfig?.onPageTypeChange,
              onVisibilityChanged: _notifyPopupVisibility,
            );
          },
          sclae: 1.05,
          child: Container(
            height: 56.wMin,
            width: 136.wMin,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: AppTheme.cSurfaceLayerDarken.color,
              border: Border.all(width: 1.2.wMin, color: fromColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(right: 12.wMin),
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        colors: [fromColor, toColor],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ).createShader(bounds);
                    },
                    child: SvgPicture.network(
                      currentPageItem.iconUrl??"",
                      width: 32.wMin,
                      // errorBuilder: (context, error, stackTrace) => const SizedBox(),
                      placeholderBuilder: (context) => const SizedBox(),
                    ),
                  ),
                ),
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      colors: [fromColor, toColor],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(bounds);
                  },
                  child: Text(
                    title?.text??(currentPageType.label),
                    style: TextStyle(
                      color: toColor,
                      fontSize: 28.wMin,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );


  }
}




class PlayPageTypeDialog{
  /// 显示播放器页面类型弹窗
  static Function() showPageTypeDialog({
    required BuildContext context,
    required List<ZhenduLearnItems> learnItems,
    required ZhenduPageTypeEnum currentPageType,
    void Function(ZhenduLearnItems item)? onPageTypeChange,
    void Function(bool visible)? onVisibilityChanged,
  }){
    onVisibilityChanged?.call(true);
    return BotToast.showAttachedWidget(
      targetContext: context,
      preferDirection: PreferDirection.topCenter,
      verticalOffset: 52.wMin,
      allowClick: false,
      attachedBuilder: (cancelFunc) {
        return _DismissOnWindowChange(
          cancelFunc: cancelFunc,
          child: PlayerControllerDialogPageTypeidget(
            learnItems: learnItems,
            currentPageType: currentPageType,
            onPageTypeChange: onPageTypeChange,
            cancelFunc: cancelFunc,
          ),
        );
      },
      onClose: () {
        onVisibilityChanged?.call(false);
      },
    );
  }
}



class _DismissOnWindowChange extends StatefulWidget {
  final CancelFunc cancelFunc;
  final Widget child;

  const _DismissOnWindowChange({
    required this.cancelFunc,
    required this.child,
  });

  @override
  State<_DismissOnWindowChange> createState() => _DismissOnWindowChangeState();
}

class _DismissOnWindowChangeState extends State<_DismissOnWindowChange> with WidgetsBindingObserver {
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    _dismissDialog();
  }

  void _dismissDialog() {
    if (_isDismissed) return;
    _isDismissed = true;
    widget.cancelFunc.call();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}



class PlayerControllerDialogPageTypeidget extends StatefulWidget {
  final List<ZhenduLearnItems> learnItems;
  final ZhenduPageTypeEnum currentPageType;
  final void Function(ZhenduLearnItems item)? onPageTypeChange;
  final void Function()? cancelFunc;
  const PlayerControllerDialogPageTypeidget({
    super.key, 
    required this.learnItems, 
    required this.currentPageType, 
    this.onPageTypeChange,
    this.cancelFunc,
  });

  @override
  State<PlayerControllerDialogPageTypeidget> createState() => _PlayerControllerDialogPageTypeidgetState();
}

class _PlayerControllerDialogPageTypeidgetState extends State<PlayerControllerDialogPageTypeidget> {
  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: 500.wMin,
        padding: EdgeInsets.all(20.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.wMin),
          border: Border.all(width: 0.8.wMin, color: AppTheme.cBorderPrimary.color),
          color: AppTheme.cSurfacePlayerOverlay.color,
        ),
        child: Column(
          spacing: 12.wMin,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.learnItems.length, (index){
            return _buildItemWidget(widget.learnItems[index]);
          }),
        ),
      ),
    );
  }

  Widget _buildItemWidget(ZhenduLearnItems item){

    bool isSelected = item.pageType == widget.currentPageType;
    Color formColor = item.color?.fromColor??AppTheme.cSurfaceBrand.color;
    Color toColor = item.color?.toColor??AppTheme.cSurfaceBrand.color;

    return IgnorePointer(
      ignoring: item.status != 1,
      child: Opacity(
        opacity: item.status != 1 ? 0.5 : 1.0,
        child: TapScaleWidget(
          onTap: isSelected ? null : () {
            widget.cancelFunc?.call();
            widget.onPageTypeChange?.call(item);
          },
          sclae: 1.01,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.wMin),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.cSurfacePlayerOverlay.color, 
                  AppTheme.cSurfacePlayerOverlay.color,
                ],
              ),
              border: Border.all(
                width: 0.8.wMin, 
                color: isSelected ? formColor : AppTheme.cBorderPrimary.color,
              ),
            ),
            child: Container(
              padding: EdgeInsets.all(16.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.wMin),
                gradient: !isSelected ? null : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    formColor.withValues(alpha: 0.12), 
                    toColor.withValues(alpha: 0.12),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 66.wMin,
                    height: 66.wMin,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.wMin),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          formColor, 
                          toColor,
                        ],
                      ),
                    ),
                    child: SvgPicture.network(
                      item.iconUrl??'',
                      width: 46.wMin,
                      placeholderBuilder: (context) => Container(),
                    ),
                  ),
                  SizedBox(width: 12.wMin),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              LearningLangUtils.getLocalLang(item.title)?.text??"",
                              style: TextStyle(
                                fontSize: 28.wMin,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.cTextPrimary.color,
                              ),
                            ),
                            SizedBox(width: 12.wMin),
                            Text(
                              LearningLangUtils.getLearningLang(item.title)?.text?.toUpperCase()??"",
                              style: TextStyle(
                                fontSize: 14.wMin,
                                fontWeight: FontWeight.w400,
                                color: AppTheme.cTextTertiary.color,
                              ),
                            ),
              
                          ],
                        ),
                        SizedBox(height: 4.wMin),
                        Text(
                          item.description??"",
                          style: TextStyle(
                            fontSize: 20.wMin,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.cTextSecondary.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}
