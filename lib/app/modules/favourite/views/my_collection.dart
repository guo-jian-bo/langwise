import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:langwise/app/modules/favourite/controllers/favourite_controller.dart';
import 'package:langwise/common/entities/favourite_listen_entity.dart';
import 'package:langwise/common/entities/favourite_listen_list_detail_entity.dart';
import 'package:langwise/common/entities/song_theme_entity.dart';
import 'package:langwise/common/enum/elements_card_type.dart';
import 'package:langwise/common/enum/language_preference_enum.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/common/https/favourite.dart';
import 'package:langwise/common/widgets/build_image.dart';
import 'package:langwise/common/widgets/cached_image_widget.dart';
import 'package:langwise/common/widgets/favourite_button.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/color_utils.dart';
import 'package:langwise/utils/date_format_util.dart';
import 'package:langwise/utils/style_utils.dart';
import 'package:themed/themed.dart';
import 'package:ui_essentials/ui_essentials.dart';

class _ListenDetailReorderItem {
  const _ListenDetailReorderItem({
    required this.entity,
    required this.key,
  });

  final FavouriteListenListDetailItemEntity entity;
  final String key;
}

class MyCollection extends GetView<FavouriteController> {
  const MyCollection({super.key, this.entity});

  final FavouriteListenEntity? entity;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final occurrence = <String, int>{};
        final items = controller.listenListDetail.map((e) {
          final base = '${e.contentType ?? ''}_${e.contentId ?? ''}';
          final next = (occurrence[base] ?? 0) + 1;
          occurrence[base] = next;
          return _ListenDetailReorderItem(entity: e, key: '${base}_$next');
        }).toList(growable: false);

        return Scaffold(
          backgroundColor: AppTheme.cBgPrimary.color,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (entity != null)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 26.wMin),
                    Row(children: [
                      SizedBox(width: 70.wMin),
                      GestureDetector(
                          onTap: () => Get.back(),
                          behavior: HitTestBehavior.translucent,
                          child: Container(
                              width: 52.wMin,
                              height: 52.wMin,
                              alignment: Alignment.center,
                              child: SvgPicture.asset('assets/svg/public/icon_arrow_back.svg', width: 32.wMin, height: 32.wMin))),
                      SizedBox(width: 8.wMin),
                      Text(
                        entity!.name ?? '',
                        style: TextStyle(
                          fontSize: 32.wMin,
                          color: AppTheme.cInverseTextLight.color,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    ]),
                    Padding(
                      padding: EdgeInsets.only(left: 80.wMin),
                      child: Text(
                        "${entity?.contentCount ?? 0}个内容 | ${entity?.created != null ? DateFormatUtil.formatStr(DateTime.tryParse(entity?.created ?? '')!) : ''}",
                        style: TextStyle(
                          color: AppTheme.cTextTertiary,
                          fontSize: 28.wMin,
                        ),
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 16.wMin),
              Container(
                  height: 52.wMin,
                  margin: EdgeInsets.only(left: 70.wMin, right: 70.wMin),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(controller.listenListTypes.length, (e) {
                        return buildListenListTypeWidget(e);
                      }).toList(),
                    ),
                  )),
              SizedBox(height: 20.wMin),
              Expanded(
                  child: RefreshIndicator(
                      onRefresh: () => controller
                          .getListenListDetail(entity == null ? 0 : entity!.uid!, controller.listenListTypes[controller.secondCurrentTabIndex.value].type ?? '', reset: true),
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification notification) {
                          if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 100 && notification is ScrollEndNotification) {
                            controller.getListenListDetail(entity == null ? 0 : entity!.uid!, controller.listenListTypes[controller.secondCurrentTabIndex.value].type ?? '');
                          }
                          return false;
                        },
                        child: AnimatedReorderableGridView<_ListenDetailReorderItem>(
                          key: ValueKey(controller.listenListDetailVersion.value),
                          items: items,
                          padding: EdgeInsets.fromLTRB(70.wMin, 0.wMin, 70.wMin, 150.wMin + MediaQuery.of(context).padding.bottom),
                          shrinkWrap: false,
                          scrollDirection: Axis.vertical,
                          physics: const AlwaysScrollableScrollPhysics(),
                          dragStartDelay: const Duration(milliseconds: 200),
                          sliverGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 32.wMin,
                            crossAxisSpacing: 32.wMin,
                            childAspectRatio: 4,
                          ),
                          isSameItem: (a, b) => a.key == b.key,
                          onReorder: (int oldIndex, int newIndex) async {
                            final len = controller.listenListDetail.length;
                            if (len <= 1) return;
                            if (oldIndex < 0 || oldIndex >= len) return;
                            if (newIndex < 0) return;

                            var targetIndex = newIndex;
                            if (targetIndex > len) targetIndex = len;

                            if (targetIndex < 0 || targetIndex >= len) return;

                            final moved = controller.listenListDetail.removeAt(oldIndex);
                            controller.listenListDetail.insert(targetIndex, moved);
                            controller.listenListDetail.refresh();
                            var playListId = 0;
                            if (entity != null) {
                              playListId = entity!.uid!;
                            }
                            final uid = moved.contentId;
                            final type = moved.contentType;
                            if (uid == null || type == null) return;

                            await FavouriteRequest.sortPlayListContent(
                              playListId: playListId,
                              uid: uid,
                              type: type,
                              index: targetIndex.toString(),
                            );
                          },
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return KeyedSubtree(
                              key: ValueKey(item.key),
                              child: _playListItem(item.entity),
                            );
                          },
                        ),
                      ))),
            ],
          ),
        );
      },
    );
  }

  Widget buildListenListTypeWidget(int index) {
    return TapScaleWidget(
      onTap: () {
        if (controller.secondCurrentTabIndex.value != index) {
          controller.secondTabController?.animateTo(index);
          controller.secondCurrentTabIndex.value = index;
          controller.getListenListDetail(entity == null ? 0 : entity!.uid!, controller.listenListTypes[index].type ?? '', reset: true);
        }
      },
      sclae: 1,
      child: AnimatedBuilder(
        animation: controller.secondTabController?.animation ?? const AlwaysStoppedAnimation(0),
        builder: (context, child) {
          double progress = controller.secondTabController?.animation?.value ?? 0;

          // 计算当前tab的透明度
          // 当动画值接近当前索引时，透明度增加；当动画值远离当前索引时，透明度减少
          double opacity = 0.0;
          Color backgroundColor = AppTheme.cBgQuaternary;
          Color textColor = AppTheme.cTextTertiary;

          // 如果动画值在当前索引附近（前后0.5范围内）
          if (progress >= index - 0.5 && progress <= index + 0.5) {
            // 计算透明度：越接近当前索引，透明度越高
            opacity = 1.0 - (index - progress).abs() * 2;
            // 确保透明度在0.0到1.0之间
            opacity = opacity.clamp(0.0, 1.0);
            textColor = AppTheme.cTextBrand;
          }

          return AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            padding: EdgeInsets.symmetric(horizontal: 20.wMin, vertical: 10.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.wMin),
              color: backgroundColor.addOpacity(opacity),
            ),
            child: Text(
              controller.listenListTypes[index].titles?[0].text ?? '',
              style: TextStyle(
                fontSize: 24.wMin,
                color: textColor,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _playListItem(FavouriteListenListDetailItemEntity item) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.wMin),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceSecondary.color,
          border: Border.all(color: AppTheme.cBorderPrimary.color, strokeAlign: BorderSide.strokeAlignOutside),
        ),
        child: Row(
          children: [
            Container(height: double.infinity, child: AspectRatio(aspectRatio: 1, child: _buildLeftTagThumb(item))),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(12.wMin, 16.wMin, 0, 8.wMin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (item.tags != null && item.tags!.isNotEmpty)
                          Wrap(
                            spacing: 4.wMin,
                            children: item.tags!.map((tag) {
                              final themeText = StyleUtils.getCurrentThemeText(tag.style);
                              return Container(
                                height: 24.wMin,
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.wMin,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.wMin),
                                  color: ColorUtils.parseColor(themeText?.backgroundColor) ?? AppTheme.cTextInverse.color,
                                ),
                                child: Text(
                                  getGrene(tag.gloss!, 'zh'),
                                  style: TextStyle(
                                    fontSize: (themeText?.fontsize ?? 16).wMin,
                                    color: ColorUtils.parseColor(themeText?.color) ?? AppTheme.cInverseTextLight.color,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        Spacer(),
                        GestureDetector(
                            onTap: () {
                              controller.collectTo(item, entity == null ? 0 : entity!.uid!);
                            },
                            child: Container(
                                height: 34.wMin,
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.wMin,
                                ),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.wMin),
                                    color: AppTheme.cSurfaceQuaternary.color,
                                    border: Border.all(color: AppTheme.cBorderTertiary.color, width: 0.6.wMin)),
                                child: Text('收藏到', style: TextStyle(fontSize: 16.wMin, color: AppTheme.cTextPrimary.color)))),
                        if (entity != null)
                          GestureDetector(
                              onTap: () {
                                controller.remove(entity!.uid!, item.contentId!, item.contentType!);
                              },
                              child: Padding(
                                padding: EdgeInsets.only(left: 12.wMin),
                                child: SvgPicture.asset('assets/svg/public/icon_delete.svg',
                                    colorFilter: ColorFilter.mode(AppTheme.cFeedbackErrorIcon.color, BlendMode.srcIn), width: 32.wMin, height: 32.wMin),
                              )),
                      ],
                    ),
                    SizedBox(height: 24.wMin),
                    Text((item.title ?? '暂无内容'), style: TextStyle(fontSize: 32.wMin, fontWeight: FontWeight.w600, color: AppTheme.cTextPrimary.color), maxLines: 1),
                    if (item.content != null)
                      Text(
                        item.content!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 22.wMin,
                          color: AppTheme.cTextTertiary.color,
                        ),
                      ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 24.wMin,
                      children: [
                        FavouriteButton(
                            contentId: item.contentId!,
                            isFavourited: item.isFavourited ?? false,
                            contentType: item.contentType ?? 'EN_SONG',
                            playListId: 0,
                            fromPlaylist: entity == null ? 0 : entity!.uid!,
                            onRefresh: (needRefresh) {
                              if (needRefresh) {
                                controller.freshSingle(item, entity != null);
                              }
                            }),
                        _btn(item),
                      ],
                    ),
                    SizedBox(height: 8.wMin)
                  ],
                ),
              ),
            ),
            SizedBox(width: 16.wMin)
          ],
        ),
      ),
    );
  }

  Widget _buildLeftTagThumb(FavouriteListenListDetailItemEntity? item) {
    return CachedImageWidget(item!.imageUrl ?? '', errorWidget: buildEmptyWidget(), placeholder: buildLoadingWidget(), fadeInDuration: Duration.zero);
  }

  Widget _btn(FavouriteListenListDetailItemEntity item) {
    return GestureDetector(
      onTap: () async {
        if (item.contentType == ElementsCardType.song.value) {
          controller.songPlay(item, entity);
        } else if (item.contentType == 'EN_REVEAL' || item.contentType == ElementsCardType.text.value) {
          controller.readReveal(item, entity);
        } else {
          controller.songPlay(item, entity);
        }
      },
      child: Container(
        height: 48.wMin,
        padding: EdgeInsets.only(left: 16.wMin, right: 8.wMin),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.wMin),
            color: item.cardRights?.rights == 'NO_RIGHTS' ? AppTheme.cFeedbackWarningBackground.color : AppTheme.cSurfaceQuaternary.color,
            border: Border.all(color: item.cardRights?.rights == 'NO_RIGHTS' ? AppTheme.cFeedbackWarningBackground.color : AppTheme.cBorderTertiary.color, width: 0.6.wMin)),
        child: Row(
          children: [
            Text(
                item.cardRights?.rights == 'NO_RIGHTS'
                    ? '去解锁'
                    : (item.contentType == 'EN_REVEAL' || item.contentType == ElementsCardType.text.value)
                        ? '听读'
                        : '播放',
                style: TextStyle(
                    fontSize: 22.wMin,
                    fontWeight: item.cardRights?.rights == 'NO_RIGHTS' ? FontWeight.w600 : FontWeight.w400,
                    color: item.cardRights?.rights == 'NO_RIGHTS' ? AppTheme.cFeedbackWarningText : AppTheme.cTextPrimary.color)),
            SizedBox(width: 2.wMin),
            SvgPicture.asset('assets/svg/user_center/icon_chevron_right1.svg',
                width: 20.wMin,
                height: 20.wMin,
                colorFilter: item.cardRights?.rights == 'NO_RIGHTS'
                    ? ColorFilter.mode(AppTheme.cFeedbackWarningIcon.color, BlendMode.srcIn)
                    : ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn))
          ],
        ),
      ),
    );
  }

  String getGrene(List<LangTextEntity?> item, String condition) {
    var systemCondition = LangPreference.fromRawValue(UserStore.to.userInfo.value.config?.extensionConfig!.translationType ?? '').langCode;
    if (systemCondition.isNotEmpty) {
      condition = systemCondition;
    }
    for (var glossItem in item) {
      if (glossItem!.lang == condition) {
        return glossItem.text!;
      }
    }
    return '';
  }
}
