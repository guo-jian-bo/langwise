import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/favourite/controllers/favourite_controller.dart';
import 'package:langwise/common/entities/favourite_listen_entity.dart';
import 'package:langwise/common/https/favourite.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../../../../theme/theme.dart';
import '../../../routes/routes.dart';
import '../../../routes/tag_routes.dart';

class MovePlayListDialog {
  static Future<String> show(BuildContext context, int id, String type, String tagText) async {
    String? res = await showCupertinoDialog<String?>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return MovePlayListDialogWidget(id: id, type: type, tagText: tagText);
      },
    );
    return res ?? '';
  }
}

class MovePlayListDialogWidget extends StatefulWidget {
  const MovePlayListDialogWidget({super.key, required this.id, required this.type, required this.tagText});

  final int id;
  final String type;
  final String tagText;

  @override
  State<MovePlayListDialogWidget> createState() => _MovePlayListDialogWidgetState();
}

class _MovePlayListDialogWidgetState extends State<MovePlayListDialogWidget> {
  late FavouriteController ctrl;
  List<FavouriteListenEntity> playList = [];
  int isChecked = -1;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() async {

    ctrl = TagRoutes.find<FavouriteController>(Routes.FAVOURITE, widget.tagText) ?? FavouriteController(tagText: widget.tagText);

    var list = await ctrl.getMyPlayList();
    setState(() {
      playList = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        color: AppTheme.cOverlayBackground,
        child: Center(
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
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                    Text(
                      '收藏到听单',
                      style: TextStyle(fontSize: 32.wMin, fontWeight: FontWeight.w600, color: AppTheme.cTextPrimary.color),
                    ),
                    SizedBox(height: 56.wMin),
                    Container(
                        height: 432.wMin,
                        child: ListView.builder(
                            itemCount: playList.length,
                            itemBuilder: (ctx, idx) {
                              var item = playList[idx];
                              return _playList(item, idx);
                            })),
                    SizedBox(height: 24.wMin),
                    _bottomBtn(),
                  ])),
              Positioned(top: 10.wMin, right: 10.wMin, child: _backIcon()),
            ],
          ),
        ));
  }

  Widget _playList(FavouriteListenEntity item, int idx) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        color: AppTheme.cSurfaceTertiary.color,
      ),
      margin: EdgeInsets.only(bottom: 24.wMin),
      padding: EdgeInsets.all(16.wMin),
      child: Row(
        children: [
          Container(
            height: 70.wMin,
            width: 70.wMin,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(8.wMin), child: CachedImageWidget(item.cover ?? "", errorWidget: buildEmptyWidget(), placeholder: buildLoadingWidget())),
          ),
          SizedBox(width: 10.wMin),
          Expanded(
            child: Text(
              '${item.name}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 24.wMin, fontWeight: FontWeight.w600, color: AppTheme.cTextPrimary.color),
            ),
          ),
          SizedBox(width: 40.wMin),
          GestureDetector(
            onTap: () {
              isChecked = idx;
              if (mounted) setState(() {});
            },
            child: SvgPicture.asset(
              isChecked == idx ? "assets/svg/public/icon_check_box.svg" : "assets/svg/public/icon_uncheck_box.svg",
              width: 36.wMin,
              height: 36.wMin,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomBtn() {
    return GestureDetector(
      onTap: () async {
        if (_submitting) return;
        _submitting = true;
        if (isChecked == -1) {
          ToastUtils.showToast(text: "请选择听单", type: ToastType.warning);
          return;
        }
        var res = await FavouriteRequest.moveToPlayList(playListId: 0, uid: widget.id, type: widget.type, targetFavoriteId: playList[isChecked].uid!);
        if (res) {
          ToastUtils.showToast(text: "迁移成功", type: ToastType.success);
          Get.back();
        }
        _submitting = false;
      },
      child: Container(
          width: 736.wMin,
          height: 72.wMin,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: AppTheme.cSurfaceQuaternary.color, borderRadius: BorderRadius.circular(12.wMin)),
          child: Text('完成', style: TextStyle(fontSize: 28.wMin, fontWeight: FontWeight.w500, color: AppTheme.cTextPrimary.color))),
    );
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
