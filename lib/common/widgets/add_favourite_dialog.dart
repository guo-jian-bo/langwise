import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/favourite/controllers/favourite_controller.dart';
import 'package:langwise/app/modules/favourite/views/edit_dialog.dart';
import 'package:langwise/common/https/favourite.dart';
import 'package:langwise/common/entities/favourite_listen_entity.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../../../../theme/theme.dart';

class AddFavouriteDialog {
  static Future<String> show(
    BuildContext context, 
    int id, 
    String type, {
      bool isNew = true, 
      int playListId = 0,
      int? styleId,
      String? dialect,
    }) async {
    String? res = await showCupertinoDialog<String?>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AddFavouriteDialogWidget(id: id, type: type, isNew: isNew, playListId: playListId, styleId: styleId, dialect: dialect);
      },
    );
    return res ?? '';
  }
}

class AddFavouriteDialogWidget extends StatefulWidget {
  const AddFavouriteDialogWidget({
    super.key, 
    required this.id, 
    required this.type, 
    required this.isNew, 
    required this.playListId,
    this.styleId,
    this.dialect,
  });

  final int id;
  final String type;
  final bool isNew;
  final int playListId;
  final int? styleId;
  final String? dialect;

  @override
  State<AddFavouriteDialogWidget> createState() => _AddFavouriteDialogWidgetState();
}

class _AddFavouriteDialogWidgetState extends State<AddFavouriteDialogWidget> {
  late FavouriteController ctrl;
  List<FavouriteListenEntity> playList = [];
  List<bool> isChecked = [];
  bool _submitting = false;
  final ScrollController _listScrollController = ScrollController();
  final EasyRefreshController _refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );
  final Set<int> _loadedPlayListIds = <int>{};
  int _offset = 0;
  final int _limit = 30;
  int _totalCount = 0;
  int _maxPlayListCount = 100;

  @override
  void initState() {
    super.initState();
    initData();
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  initData() async {
    if (Get.isRegistered<FavouriteController>()) {
      ctrl = Get.find<FavouriteController>();
    } else {
      ctrl = FavouriteController();
    }

    await _onRefreshPlayList();
  }

  Future<void> _onRefreshPlayList() async {
    final Set<int> selectedIds = <int>{};
    for (int i = 0; i < playList.length && i < isChecked.length; i++) {
      if (!isChecked[i]) continue;
      final id = playList[i].uid;
      if (id != null) selectedIds.add(id);
    }

    try {
      _offset = 0;
      final res = await FavouriteRequest.getListenListPages(
        offset: _offset,
        limit: _limit,
      );
      _refreshController.finishRefresh(IndicatorResult.none);
      if (res == null) return;

      _totalCount = res.count ?? 0;
     _maxPlayListCount = res.maxCount ?? ctrl.maxPlayListCount.value;
     if(!widget.isNew||widget.playListId!=0){
      _totalCount -=1;
     }
      if (!mounted) return;
      setState(() {
        playList.clear();
        isChecked.clear();
        _loadedPlayListIds.clear();
      });

      _appendFromResponse(res.datas ?? [], selectedIds: selectedIds);
    } catch (_) {
      _refreshController.finishRefresh(IndicatorResult.fail);
    }
  }

  Future<void> _onLoadMorePlayList() async {
    if (_totalCount <= playList.length) {
      _refreshController.finishLoad(IndicatorResult.none);
      return;
    }
    try {
      final nextOffset = _offset + _limit;
      final res = await FavouriteRequest.getListenListPages(
        offset: nextOffset,
        limit: _limit,
      );
      _refreshController.finishLoad(IndicatorResult.none);
      if (res == null) return;

      _offset = nextOffset;
      _totalCount = res.count ?? _totalCount;
      _maxPlayListCount = res.maxCount ?? ctrl.maxPlayListCount.value;
      if(!widget.isNew||widget.playListId!=0){
        _totalCount -=1;
      }
      _appendFromResponse(res.datas ?? []);
    } catch (_) {
      _refreshController.finishLoad(IndicatorResult.fail);
    }
  }

  void _appendFromResponse(List<FavouriteListenEntity> items, {Set<int>? selectedIds}) {
    if (!mounted) return;
    setState(() {
      for (final item in items) {
        final int? uid = item.uid;
        if (uid == null) continue;
        if (uid == widget.playListId) continue;
        if (_loadedPlayListIds.contains(uid)) continue;

        _loadedPlayListIds.add(uid);
        playList.add(item);
        isChecked.add(selectedIds?.contains(uid) ?? false);
      }
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
                      widget.isNew ? '已存入我的收藏，还可以...' : '另外收藏到',
                      style: TextStyle(fontSize: 32.wMin, fontWeight: FontWeight.w600, color: AppTheme.cTextPrimary.color),
                    ),
                    SizedBox(height: 56.wMin),
                    if (playList.length < _maxPlayListCount) _newList(),
                    SizedBox(height: 24.wMin),
                    Container(
                        height: 432.wMin,
                        child: EasyRefresh(
                          controller: _refreshController,
                          header: null,
                          footer: null,
                          onRefresh: null,
                          onLoad: _totalCount <= playList.length ? null : () async {
                            await _onLoadMorePlayList();
                          },
                          child: ListView.builder(
                              controller: _listScrollController,
                              primary: false,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: playList.length,
                              itemBuilder: (ctx, idx) {
                                var item = playList[idx];
                                return _playList(item, idx);
                              }),
                        )),
                    SizedBox(height: 24.wMin),
                    _bottomBtn(),
                  ])),
              Positioned(top: 10.wMin, right: 10.wMin, child: _backIcon()),
            ],
          ),
        ));
  }

  Widget _playList(FavouriteListenEntity item, int idx) {
    return GestureDetector(
        onTap: () {
          if(item.contentCount==item.maxContentCount){
            ToastUtils.showToast(text: '已达到最大收藏数量',type: ToastType.warning);
            return;
          }
          isChecked[idx] = !isChecked[idx];
          if (mounted) setState(() {});
        },
        child: Container(
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
              SvgPicture.asset(
                isChecked[idx] ? "assets/svg/public/icon_check_box.svg" : "assets/svg/public/icon_uncheck_box.svg",
                width: 36.wMin,
                height: 36.wMin,
              ),
            ],
          ),
        ));
  }

  Widget _newList() {
    return GestureDetector(
      onTap: () async {
        String res = await PlayListEditDialog.show(Get.context!, null);
        if (res != '') {
          await _onRefreshPlayList();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.wMin),
          color: Colors.transparent,
          border: Border.all(width: 1.wMin, color: AppTheme.cBorderSecondary),
        ),
        padding: EdgeInsets.all(16.wMin),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/svg/public/icon_add.svg', width: 40.wMin, height: 40.wMin),
            Text(
              '新建听单',
              style: TextStyle(fontSize: 24.wMin, fontWeight: FontWeight.w600, color: AppTheme.cTextTertiary.color),
            )
          ],
        ),
      ),
    );
  }

  Widget _bottomBtn() {
    return GestureDetector(
      onTap: () async {
        if (_submitting) return;

        final List<int> selectedPlayListIds = [];
        for (int i = 0; i < isChecked.length; i++) {
          if (isChecked[i]) {
            final int? id = playList[i].uid;
            if (id != null) selectedPlayListIds.add(id);
          }
        }

        setState(() {
          _submitting = true;
        });

        try {
          final bool ok = await ctrl.addContentBatch(selectedPlayListIds, widget.id, widget.type, styleId: widget.styleId, dialect: widget.dialect);
          if (ok) {
            Get.back(result: '');
          }
        } finally {
          if (mounted) {
            setState(() {
              _submitting = false;
            });
          }
        }
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
