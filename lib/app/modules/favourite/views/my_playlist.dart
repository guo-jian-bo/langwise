import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/favourite/controllers/favourite_controller.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/date_format_util.dart';
import 'package:ui_essentials/ui_essentials.dart';

class MyPlayList extends GetView<FavouriteController> {
  final String tagText;
  const MyPlayList({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 70.wMin, top: 40.wMin, right: 70.wMin),
      child: Obx(
        () {
          final bool isEdit = controller.isPlayListEditMode.value;
          final double bottomBarHeight = 132.wMin;

          final Widget list = isEdit
              ? ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  itemCount: controller.playList.length,
                  proxyDecorator: (child, index, animation) {
                    return Material(
                      color: Colors.transparent,
                      elevation: 0,
                      child: child,
                    );
                  },
                  onReorder: (oldIndex, newIndex) async {
                    if (oldIndex < newIndex) newIndex -= 1;
                    final item = controller.playList.removeAt(oldIndex);
                    controller.playList.insert(newIndex, item);
                    controller.playList.refresh();
                    if (item.uid != null) {
                      await controller.orderPlayList(newIndex, item.uid!);
                    }
                  },
                  itemBuilder: (ctx, idx) {
                    final item = controller.playList[idx];
                    return Container(
                      key: ValueKey(item.uid ?? idx),
                      child: _playCard(item, idx),
                    );
                  },
                )
              : ListView.builder(
                  itemCount: controller.playList.length,
                  itemBuilder: (ctx, idx) {
                    final item = controller.playList[idx];
                    return _playCard(item, idx);
                  },
                );

          return Stack(
            children: [
              EasyRefresh(
                controller: controller.playListRefreshController,
                header: null,
                footer: null,
                onRefresh: null,
                onLoad: (isEdit || !controller.hasMorePlayList)
                    ? null
                    : () async {
                        await controller.loadMoreMyPlayList();
                      },
                child: Padding(
                  padding: EdgeInsets.only(bottom: isEdit ? bottomBarHeight : 0),
                  child: list,
                ),
              ),
              if (isEdit)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SizedBox(
                    height: bottomBarHeight,
                    child: _buildEditBottomBar(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _playCard(FavouriteListenEntity item, int index) {
    final bool isEdit = controller.isPlayListEditMode.value;
    final int? uid = item.uid;
    final bool checked = uid != null && controller.selectedPlayListIds.contains(uid);

    return GestureDetector(
      onTap: () {
        if (controller.isPlayListEditMode.value) {
          if (uid == null) return;
          controller.togglePlayListSelected(uid);
          return;
        }
        controller.showPlayListDetail(item);
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: 30.wMin),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isEdit)
              GestureDetector(
                onTap: () {
                  if (uid == null) return;
                  controller.togglePlayListSelected(uid);
                },
                child: Container(
                  width: 56.wMin,
                  margin: EdgeInsets.only(right: 24.wMin),
                  alignment: Alignment.centerLeft,
                  child: SvgPicture.asset(checked ? 'assets/svg/public/icon_check_box.svg' : 'assets/svg/public/icon_uncheck_box.svg', width: 52.wMin, height: 52.wMin),
                ),
              ),
            Expanded(
              child: ClipRRect(
                child: Container(
                  width: double.infinity,
                  height: 220.wMin,
                  decoration: BoxDecoration(
                    color: AppTheme.cSurfaceSecondary,
                    border: Border.all(color: AppTheme.cBorderPrimary, strokeAlign: BorderSide.strokeAlignOutside),
                    borderRadius: BorderRadius.circular(12.wMin),
                  ),
                  child: Row(children: [
                    SizedBox(
                        height: 220.wMin,
                        width: 220.wMin,
                        child: ClipRRect(
                            borderRadius: BorderRadius.horizontal(left: Radius.circular(12.wMin), right: Radius.zero),
                            child: CachedImageWidget(item.cover ?? "", errorWidget: buildEmptyWidget(), placeholder: buildLoadingWidget(), fadeInDuration: Duration.zero))),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(16.wMin),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(
                            children: [
                              Text(item.name ?? '', style: TextStyle(fontSize: 32.wMin, fontWeight: FontWeight.w600, color: AppTheme.cTextPrimary)),
                              Spacer(),
                            ],
                          ),
                          SizedBox(height: 8.wMin),
                          Text(
                            "${item.contentCount}个内容 | ${item.created != null ? DateFormatUtil.formatStr(DateTime.tryParse(item.created ?? '')!) : ''}",
                            style: TextStyle(
                              color: AppTheme.cTextTertiary,
                              fontSize: 22.wMin,
                            ),
                          ),
                          Spacer(),
                          Row(mainAxisAlignment: MainAxisAlignment.end, spacing: 12.wMin, children: [
                            Spacer(),
                            if (isEdit)
                              TapScaleWidget(
                                onTap: () {
                                  controller.updatePlayList(item);
                                },
                                child: Container(
                                  height: 48.wMin,
                                  width: 48.wMin,
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.wMin), color: AppTheme.cSurfaceQuaternary),
                                  alignment: Alignment.center,
                                  child: SvgPicture.asset('assets/svg/custom_course/icon_book_info_edit.svg', width: 32.wMin, height: 32.wMin),
                                ),
                              ),
                            // TapScaleWidget(
                            //   onTap: () {
                            //     // TODO: 下载
                            //   },
                            //   child: Container(
                            //     height: 48.wMin,
                            //     width: 48.wMin,
                            //     decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.wMin), color: AppTheme.cSurfaceQuaternary),
                            //     alignment: Alignment.center,
                            //     child: SvgPicture.asset('assets/svg/public/icon_download.svg', width: 32.wMin, height: 32.wMin),
                            //   ),
                            // ),
                            if (!isEdit)
                              GestureDetector(
                                onTap: () async {
                                  //todo:全部播放
                                  controller.playAll(item);
                                },
                                child: Container(
                                  height: 48.wMin,
                                  padding: EdgeInsets.only(left: 16.wMin, right: 8.wMin, top: 6.wMin, bottom: 6.wMin),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.wMin),
                                      color: AppTheme.cSurfaceQuaternary.color,
                                      border: Border.all(color: AppTheme.cBorderTertiary.color, width: 0.6.wMin)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('全部播放', style: TextStyle(fontSize: 22.wMin, color: AppTheme.cTextPrimary.color)),
                                      SizedBox(width: 2.wMin),
                                      SvgPicture.asset(
                                        'assets/svg/user_center/icon_chevron_right1.svg',
                                        width: 20.wMin,
                                        height: 20.wMin,
                                        color: AppTheme.cTextPrimary.color,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                          ])
                        ]),
                      ),
                    )
                  ]),
                ),
              ),
            ),
            if (isEdit)
              ReorderableDragStartListener(
                index: index,
                child: Container(
                  width: 56.wMin,
                  height: 220.wMin,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.drag_handle,
                    size: 28.wMin,
                    color: AppTheme.cTextTertiary.color,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditBottomBar() {
    final bool isAllSelected = controller.isAllPlayListsSelected;
    final bool hasSelected = controller.selectedPlayListIds.isNotEmpty;

    return Row(
        children: [
          GestureDetector(
            onTap: () {
              if (isAllSelected) {
                controller.clearPlayListSelection();
              } else {
                controller.selectAllPlayLists();
              }
            },
            child: Row(
              children: [
                SvgPicture.asset(isAllSelected ? 'assets/svg/public/icon_check_box.svg' : 'assets/svg/public/icon_uncheck_box.svg', width: 52.wMin, height: 52.wMin),
                SizedBox(width: 12.wMin),
                Text(
                    isAllSelected ? '取消全选' : '全选',
                    style: TextStyle(
                      fontSize: 28.wMin,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.cTextPrimary.color,
                    ),
                  ),
                
              ],
            ),
          ),
          Spacer(),
          GestureDetector(
            onTap: hasSelected
                ? () async {
                    await controller.deleteSelectedPlayLists();
                  }
                : null,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.wMin, vertical: 12.wMin),
              decoration: BoxDecoration(
                color: hasSelected ? AppTheme.cFeedbackErrorIcon.color : AppTheme.cSurfaceQuaternary.color,
                borderRadius: BorderRadius.circular(8.wMin),
              ),
              child: Text(
                '删除听单',
                style: TextStyle(
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      
    );
  }
}
