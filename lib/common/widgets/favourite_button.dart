import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/https/favourite.dart';
import 'package:langwise/common/widgets/add_favourite_dialog.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/lock_utils.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

class FavouriteButton extends StatefulWidget {
  const FavouriteButton({
    super.key,
    required this.contentId,
    required this.isFavourited,
    this.contentType = 'EN_SONG',
    this.size = 32,
    this.playListId = 0,
    this.fromPlaylist = 0,
    required this.onRefresh,
    this.styleId,
    this.dialect,
  });
  final Function(bool) onRefresh;
  final int contentId;
  final String contentType;
  final bool isFavourited;
  final double size;
  final int playListId;
  final int fromPlaylist;
  final int? styleId;
  final String? dialect;

  @override
  State<StatefulWidget> createState() {
    return FavouriteButtonState();
  }
}

class FavouriteButtonState extends State<FavouriteButton> {
  @override
  void didUpdateWidget(covariant FavouriteButton oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return TapScaleWidget(
      onTap: () async {
        bool experience = await LockUtils.checkExperienceApp(context);
        if (experience) return;
        bool student = await LockUtils.checkStudent(context);
        if(!student) return;
        var needRefresh = await toggleFavourite(widget.contentId, widget.contentType, favourite: widget.isFavourited, playListId: widget.playListId);
        widget.onRefresh(needRefresh);
      },
      child: Container(
        height: 48.wMin,
        width: 48.wMin,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.wMin), color: AppTheme.cFeedbackErrorBackground),
        alignment: Alignment.center,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeOutBack,
          transitionBuilder: (child, animation) {
            final animWidget = child.key == ValueKey(widget.isFavourited);
            if (animWidget) {
              if (!widget.isFavourited) return child;
              return ScaleTransition(
                scale: animation,
                child: child,
              );
            }

            if (widget.isFavourited) return child;

            return ScaleTransition(
              scale: animation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          child: SvgPicture.asset(
            widget.isFavourited ? "assets/svg/public/icon_like.svg" : "assets/svg/public/icon_dislike.svg",
            width: widget.size.wMin,
            height: widget.size.wMin,
            key: ValueKey(widget.isFavourited),
          ),
        ),
        // child: SvgPicture.asset(widget.isFavourited ? 'assets/svg/public/icon_like.svg' : 'assets/svg/public/icon_dislike.svg', width: widget.size.wMin, height: widget.size.wMin),
      ),
    );
  }

  Future<bool> toggleFavourite(int contentId, String contentType, {bool favourite = true, int playListId = 0}) async {
    bool needRefresh = false;
    if (favourite) {
      //todo:取消收藏
      var res = await FavouriteRequest.removeContent(playListId: playListId, uid: contentId, type: contentType, styleId: widget.styleId, dialect: widget.dialect);
      if (res) {
        ToastUtils.showManageToast(text: '已取消收藏', type: ManageToastType.aiGiveUp);
        needRefresh = true;
      }
    } else {
      var res = await FavouriteRequest.addContent(playListId: playListId, uid: contentId, type: contentType, styleId: widget.styleId, dialect: widget.dialect);
      if (res) {
        needRefresh = true;
        ToastUtils.showManageToast(text: '已添加至默认收藏', type: ManageToastType.aiComplete);
        AddFavouriteDialog.show(Get.context!, contentId, contentType, playListId: widget.fromPlaylist, styleId: widget.styleId, dialect: widget.dialect);
      } else {
        ToastUtils.showToast(text: '收藏失败', type: ToastType.error);
      }
    }
    return needRefresh;
  }
}
