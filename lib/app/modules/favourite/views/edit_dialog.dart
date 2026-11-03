import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/favourite/controllers/favourite_controller.dart';
import 'package:langwise/common/entities/favourite_listen_entity.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../../../../theme/theme.dart';

class PlayListEditDialog {
  static Future<String> show(BuildContext context, FavouriteListenEntity? entity) async {
    String? res = await showCupertinoDialog<String?>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return PlayListEditDialogWidget(entity: entity);
      },
    );
    return res ?? '';
  }
}

class PlayListEditDialogWidget extends StatefulWidget {
  const PlayListEditDialogWidget({super.key, required this.entity });

  final FavouriteListenEntity? entity;

  @override
  State<PlayListEditDialogWidget> createState() => _PlayListEditDialogWidgetState();
}

class _PlayListEditDialogWidgetState extends State<PlayListEditDialogWidget> {
  TextEditingController nameCtrl = TextEditingController();
  TextEditingController desCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameCtrl.text = widget.entity?.name ?? '';
    desCtrl.text = widget.entity?.description ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppTheme.cOverlayBackground,
        resizeToAvoidBottomInset: true,
        body: Center(
          child: Stack(
            children: [
              Container(
                  width: 800.wMin,
                  padding: EdgeInsets.all(32.wMin),
                  decoration: BoxDecoration(
                    color: AppTheme.cSurfaceSecondary.color,
                    border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary),
                    borderRadius: BorderRadius.circular(24.wMin),
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Align(
                        alignment: Alignment.topLeft,
                        child: Text(widget.entity == null ? '新建听单' : '编辑听单', style: TextStyle(color: AppTheme.cTextPrimary, fontSize: 32.wMin, fontWeight: FontWeight.w600))),
                    SizedBox(height: 56.wMin),
                    Text(
                      '名称',
                      style: TextStyle(color: AppTheme.cTextPrimary, fontSize: 24.wMin, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 8.wMin),
                    Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.wMin)),
                        child: TextField(
                          maxLength: 10,
                          controller: nameCtrl,
                          decoration: InputDecoration(
                            hintText: '请输入听单名称',
                            contentPadding: EdgeInsets.all(16.wMin),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.wMin),
                              borderSide: BorderSide(width: 1.wMin, color: AppTheme.cBorderSecondary),
                            ),
                          ),
                          style: TextStyle(color: AppTheme.cTextPrimary),
                        )),
                    Text(
                      '描述',
                      style: TextStyle(color: AppTheme.cTextPrimary, fontSize: 24.wMin, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 8.wMin),
                    Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.wMin)),
                        child: TextField(
                          maxLength: 15,
                          controller: desCtrl,
                          decoration: InputDecoration(
                            hintText: '请输入听单描述',
                            contentPadding: EdgeInsets.all(16.wMin),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.wMin),
                              borderSide: BorderSide(width: 1.wMin, color: AppTheme.cBorderSecondary),
                            ),
                          ),
                          style: TextStyle(color: AppTheme.cTextPrimary),
                        )),
                    SizedBox(height: 40.wMin),
                    _bottomBtn(),
                  ])),
              Positioned(top: 10.wMin, right: 10.wMin, child: _backIcon()),
            ],
          ),
        ));
  }

  Widget _bottomBtn() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Expanded(
        child: GestureDetector(
          onTap: () {
            Get.back(result: '');
          },
          child: Container(
              height: 72.wMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: AppTheme.cSurfaceQuaternary.color, borderRadius: BorderRadius.circular(12.wMin)),
              child: Text('取消', style: TextStyle(fontSize: 28.wMin, fontWeight: FontWeight.w500, color: AppTheme.cTextPrimary.color))),
        ),
      ),
      SizedBox(width: 12.wMin),
      Expanded(
        child: GestureDetector(
          onTap: () async {
            if (nameCtrl.text.trim().isEmpty) {
              ToastUtils.showToast(text: '请输入听单名称');
              return;
            }
            if (desCtrl.text.trim().isEmpty) {
              ToastUtils.showToast(text: '请输入听单描述');
              return;
            }
            if (widget.entity == null) {
              var res = await FavouriteController().createPlayList(nameCtrl.text.trim(), desCtrl.text.trim());
              if (res) {
                Get.back(result: nameCtrl.text.trim());
              } else {
                ToastUtils.showToast(text: '创建失败');
              }
            } else {
              var res = await Get.find<FavouriteController>().editPlayList(widget.entity!.uid!, nameCtrl.text.trim(), desCtrl.text.trim());
              if (res) {
                Get.back(result: nameCtrl.text.trim());
              } else {
                ToastUtils.showToast(text: '修改失败');
              }
            }
          },
          child: Container(
              height: 72.wMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: AppTheme.cSurfaceInfo.color, borderRadius: BorderRadius.circular(12.wMin)),
              child: Text('确定', style: TextStyle(fontSize: 28.wMin, fontWeight: FontWeight.w500, color: AppTheme.cInverseTextLight.color))),
        ),
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
}
