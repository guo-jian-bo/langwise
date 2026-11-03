

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../common/elements_cards/elements_type_card_widget.dart';
import '../model/elements_detils_data_model.dart';

class ElementsDeleteCardDialog{


  static Future<void> show({
    required BuildContext context,
    required ElementsDetilsDataModel data,
    void Function(int type)? onTap,
  }) async{

    await showDialog(
      context: context,
      useSafeArea: false,
      builder: (context) {
        return ElementsDeleteCardDialogWidget(data: data, onTap: onTap);
      },
    );

  }


}

class ElementsDeleteCardDialogWidget extends StatefulWidget {
  final ElementsDetilsDataModel data;
  final void Function(int type)? onTap;

  const ElementsDeleteCardDialogWidget({super.key, required this.data, this.onTap});

  @override
  State<ElementsDeleteCardDialogWidget> createState() => _ElementsDeleteCardDialogWidgetState();
}

class _ElementsDeleteCardDialogWidgetState extends State<ElementsDeleteCardDialogWidget> {

  Offset cardOffset = Offset.zero;

  Size cardSize = Size.zero;

  bool showButton = false;

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _getCardPosition();
    });
  }

  /// 获取卡片位置
  void _getCardPosition(){
    RenderBox? renderBox = widget.data.key?.currentContext?.findRenderObject() as RenderBox?;
    if(renderBox == null) return;
    cardOffset = renderBox.localToGlobal(Offset.zero);
    cardSize = renderBox.size;

    if(mounted) setState(() {});

    _movePosition();
  }

  /// 移动位置
  Future<void> _movePosition() async{
    if(cardOffset == Offset.zero) return;
    await Future.delayed(const Duration(milliseconds: 300));
    /// 是否超出顶部屏幕
    bool isOverflowTop = cardOffset.dy < 0;

    double buttonHeight = 56.wMin + 24.wMin;

    double bottomPadding = MediaQuery.of(context).padding.bottom;
    /// 是否超出底部屏幕
    bool isOverflowBottom = cardOffset.dy + cardSize.height > MediaQuery.of(context).size.height - bottomPadding - buttonHeight; 

    if(isOverflowTop){
      cardOffset = Offset(cardOffset.dx, 24.wMin + MediaQuery.of(context).padding.top);
      if(mounted) setState(() {});
      await Future.delayed(const Duration(milliseconds: 300));
    }
    if(isOverflowBottom){
      
      cardOffset = Offset(
        cardOffset.dx, 
        MediaQuery.of(context).size.height - cardSize.height - 24.wMin - bottomPadding - buttonHeight,
      );
      if(mounted) setState(() {});
      await Future.delayed(const Duration(milliseconds: 300));
    }
    
    
    
    showButton = true;
    if(mounted) setState(() {});
  }


  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () => Get.back(),
      child: Material(
        color: AppTheme.cOverlayBackground.color,
        child: Visibility(
          visible: cardOffset != Offset.zero,
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                left: cardOffset.dx,
                top: cardOffset.dy,
                child: Column(
                  children: [
                    SizedBox(
                      width: cardSize.width,
                      height: cardSize.height,
                      child: ElementsTypeCardWidget(
                        data: widget.data,
                        disableTap: true,
                      ),  
                    ),
                    SizedBox(height: 24.wMin),
                    AnimatedOpacity(
                      opacity: showButton ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: ButtonWidget(
                        text: "重置学习记录",
                        height: 56.wMin,
                        width: 200.wMin,
                        borderRadius: 8.wMin,
                        color: AppTheme.cFeedbackErrorBorder.color,
                        fontColor: AppTheme.cStaticWhite.color,
                        fontSize: 24.wMin,
                        fontWeight: FontWeight.w600,
                        sclae: 1.03,
                        onTap: () {
                          widget.onTap?.call(1);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}