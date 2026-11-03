import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/subscribe_and_listening/controller.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../../../../theme/theme.dart';

class UnSubScribeDialog {
  static Future<String> show(
    BuildContext context,
    int id,
    String grene, {
    required String tagText,
  }) async {
    String? res = await showCupertinoDialog<String?>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return UnSubscribeDialogWidget(
          id: id,
          grene: grene,
          tagText: tagText,
        );
      },
    );
    return res ?? '';
  }
}

class UnSubscribeDialogWidget extends StatefulWidget {
  const UnSubscribeDialogWidget({
    super.key,
    required this.id,
    required this.grene,
    required this.tagText,
  });

  final int id;
  final String grene;
  final String tagText;

  @override
  State<UnSubscribeDialogWidget> createState() => _UnSubscribeDialogWidgetState();
}

class _UnSubscribeDialogWidgetState extends State<UnSubscribeDialogWidget> {
  String title = 'zhuanlan  name';

  SubListenController get _controller =>
      Get.find<SubListenController>(tag: widget.tagText);

  @override
  void initState() {
    super.initState();
    title = widget.grene;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        color: AppTheme.cOverlayBackground,
        child: Center(
          child: Stack(
            children: [
              Container(
                  width: 640.wMin,
                  padding: EdgeInsets.all(32.wMin),
                  decoration: BoxDecoration(
                    color: AppTheme.cSurfaceSecondary.color,
                    border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary),
                    borderRadius: BorderRadius.circular(24.wMin),
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('取消订阅', style: TextStyle(fontSize: 32.wMin, fontWeight: FontWeight.w600, color: AppTheme.cTextPrimary.color)),
                    SizedBox(height: 8.wMin),
                    Text('确定取消订阅「$title」吗？已解锁的文章仍可访问。', style: TextStyle(fontSize: 24.wMin, color: AppTheme.cTextSecondary.color)),
                    SizedBox(height: 48.wMin),
                    _bottomBtn(),
                  ])),
              Positioned(top: 10.wMin, right: 10.wMin, child: _backIcon()),
            ],
          ),
        ));
  }

  Widget _bottomBtn() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      GestureDetector(
        onTap: () {
          Get.back(result: '');
        },
        child: Container(
            width: 282.wMin,
            height: 72.wMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppTheme.cSurfaceQuaternary.color, borderRadius: BorderRadius.circular(12.wMin)),
            child: Text('取消', style: TextStyle(fontSize: 28.wMin, fontWeight: FontWeight.w500, color: AppTheme.cTextPrimary.color))),
      ),
      GestureDetector(
        onTap: () {
          _unSub();
        },
        child: Container(
            width: 282.wMin,
            height: 72.wMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppTheme.cSurfaceInfo.color, borderRadius: BorderRadius.circular(12.wMin)),
            child: Text('确定', style: TextStyle(fontSize: 28.wMin, fontWeight: FontWeight.w500, color: AppTheme.cInverseTextLight.color))),
      )
    ]);
  }

  Widget _backIcon() {
    return TapScaleWidget(
      sclae: 1.05,
      onTap: () => Get.back(result: ''),
      child: Container(
        width: 42.wMin,
        height: 42.wMin,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.cSurfaceTertiary.color,
        ),
        child: SvgPicture.asset(
          "assets/svg/public/x.svg",
          width: 24.wMin,
          height: 24.wMin,
        ),
      ),
    );
  }

  //todo:取消订阅
  void _unSub() {
    _controller.toggleSubscribe(
      collectionId: widget.id,
      isSubscribed: false,
    );
  }
}
