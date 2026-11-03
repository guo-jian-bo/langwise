import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/elements/common/elements_card_search_widget.dart';
import 'package:langwise/app/modules/subscribe_and_listening_details/difficulty_choose_dialog.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/common/entities/card_public_entity.dart';
import 'package:langwise/common/entities/song_entity.dart';
import 'package:langwise/common/enum/language_preference_enum.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/common/widgets/favourite_button.dart';
import 'package:langwise/common/widgets/guide_engine/guide_anchor.dart';
import 'package:langwise/utils/utils.dart';
import 'package:themed/themed.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../controllers/music_controller.dart';

class MusicView extends GetView<MusicController> {
  MusicView({super.key});

  /// 顶部一级分类每个 item 的 GlobalKey，仅在当前页面内部使用
  final List<GlobalKey> _topTabKeys = [];

  /// 二级分类每个 item 的 GlobalKey，仅在当前页面内部使用
  final List<GlobalKey> _secondItemKeys = [];
  bool isFirst = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppTheme.cBgPrimary.color,
        body: Obx(() {
          // 根据一级、二级分类数量同步当前页面持有的 GlobalKey 列表长度
          if (_topTabKeys.length != controller.themes.length) {
            _topTabKeys
              ..clear()
              ..addAll(List.generate(controller.themes.length, (_) => GlobalKey()));
          }

          if (_secondItemKeys.length != controller.secondThemes.length) {
            _secondItemKeys
              ..clear()
              ..addAll(List.generate(controller.secondThemes.length, (_) => GlobalKey()));
          }

          return LockOverlayWidget(
              rights: controller.rights.value,
              showBack: false,
              child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: Column(
                    children: [
                      SizedBox(height: 24.wMin),
                      SizedBox(
                        height: 48.wMin,
                        width: double.infinity,
                        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                          SizedBox(width: 70.wMin),
                          Expanded(
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: false,
                                  itemCount: controller.themes.length,
                                  itemBuilder: (ctx, idx) {
                                    final key = _topTabKeys[idx];
                                    return GestureDetector(
                                      onTap: () {
                                        if (controller.selectedIndex.value == idx) {
                                          return;
                                        }
                                        controller.selectedIndex.value = idx;
                                        controller.resetByTheme();

                                        // 点击后自动滚动，使选中项出现在视图中间附近
                                        WidgetsBinding.instance.addPostFrameCallback((_) {
                                          final context = key.currentContext;
                                          if (context == null) return;
                                          Scrollable.ensureVisible(
                                            context,
                                            duration: const Duration(milliseconds: 250),
                                            curve: Curves.easeOut,
                                            alignment: 0.5,
                                          );
                                        });
                                      },
                                      child: Container(
                                        key: key,
                                        margin: EdgeInsets.only(left: idx == 0 ? 0 : 40.wMin),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              controller.themes[idx],
                                              style: TextStyle(
                                                fontSize: 28.wMin,
                                                fontWeight: FontWeight.w500,
                                                color: AppTheme.cTextPrimary.color,
                                              ),
                                            ),
                                            SizedBox(height: 2.wMin),
                                            AnimatedContainer(
                                              height: 4.wMin,
                                              width: getTextWidth(controller.themes[idx], TextStyle(fontSize: 28.wMin, fontWeight: FontWeight.w500)) - 56.wMin,
                                              color: controller.selectedIndex.value == idx ? AppTheme.cBorderBrand.color : Colors.transparent,
                                              duration: const Duration(milliseconds: 200),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  })),
                          SizedBox(width: 100.wMin),
                          ElementsCardSearchWidget(
                            controller: controller.searchInput,
                            cornerRadius: 8,
                            btnRadius: 6,
                            leftPadding: 0,
                            rightPadding: 6,
                            hintText: '搜索歌曲',
                            onSearch: (value) {
                              controller.searchCard(value);
                            },
                            onTap: () {
                              if (controller.isSearchClick.value) return;
                              controller.isSearchClick.value = true;
                              Future.delayed(const Duration(milliseconds: 350), () {
                                controller.isSearchClick.value = false;
                              });
                            },
                          ),
                          SizedBox(width: 13.wMin),
                          GestureDetector(
                            onTap: () {
                              _showDifficultyDialog(context);
                            },
                            child: Container(
                              height: 54.wMin,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.wMin), color: Color(0x14FFFFFF), border: Border.all(color: Color(0xFF5B6167))),
                              child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                                SizedBox(width: 22.wMin),
                                Text('${controller.settingDifficulty.value == controller.userDifficulty.value ? '推荐' : ''}难度',
                                    style: TextStyle(fontSize: 24.wMin, color: AppTheme.cTextPrimary.color)),
                                SizedBox(width: 4.wMin),
                                Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
                                    decoration: BoxDecoration(
                                        color: StatusUtils.getCefrBackgroundColor(controller.difficultyList[controller.settingDifficulty.value]).color2,
                                        borderRadius: BorderRadius.circular(4.wMin)),
                                    child: Text(controller.difficultyList[controller.settingDifficulty.value], style: TextStyle(fontSize: 16.wMin, color: Colors.white))),
                                SizedBox(width: 4.wMin),
                                Icon(Icons.keyboard_arrow_down, color: AppTheme.cTextPrimary.color, size: 20.wMin),
                                SizedBox(width: 8.wMin)
                              ]),
                            ),
                          ),
                          SizedBox(width: 70.wMin),
                        ]),
                      ),
                      SizedBox(height: 32.wMin),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 70.wMin),
                        width: double.infinity,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child: controller.isExpanded.value
                                    ? Wrap(
                                        spacing: 0.wMin,
                                        runSpacing: 0.wMin,
                                        children: List.generate(controller.secondThemes.length, (e) {
                                          return SizedBox(height: 52.wMin, child: buildSecondTabWidget(e));
                                        }).toList(),
                                      )
                                    : SizedBox(
                                        height: 52.wMin,
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            children: List.generate(controller.secondThemes.length, (e) {
                                              final key = _secondItemKeys[e];
                                              return buildSecondTabWidget(e, key: key);
                                            }).toList(),
                                          ),
                                        ))),
                            SizedBox(width: 8.wMin),
                            SizedBox(
                              height: 52.wMin,
                              child: TapScaleWidget(
                                onTap: () {
                                  if (controller.isExpanded.value) {
                                    // 从展开切换为折叠时，让当前选中的项滚动到可视区域
                                    controller.isExpanded.value = false;
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      final int index = controller.secondSelectedIndex.value.clamp(0, controller.secondThemes.length - 1);
                                      if (index < 0 || index >= _secondItemKeys.length) return;

                                      final key = _secondItemKeys[index];
                                      final context = key.currentContext;
                                      if (context == null) return;

                                      Scrollable.ensureVisible(
                                        context,
                                        duration: const Duration(milliseconds: 250),
                                        curve: Curves.easeOut,
                                        alignment: 0.5,
                                      );
                                    });
                                  } else {
                                    controller.isExpanded.value = true;
                                  }
                                },
                                sclae: 1,
                                child: Icon(
                                  controller.isExpanded.value ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                  size: 20.wMin,
                                  color: AppTheme.cTextSecondary.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: 20.wMin),
                          child: RefreshIndicator(
                            onRefresh: controller.refreshSongs,
                            child: NotificationListener<ScrollNotification>(
                              onNotification: (ScrollNotification notification) {
                                if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 100 && notification is ScrollEndNotification) {
                                  controller.loadSong();
                                }
                                return false;
                              },
                              child: GridView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: EdgeInsets.fromLTRB(70.wMin, 20.wMin, 70.wMin, 150.wMin + MediaQuery.of(context).padding.bottom),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 32.wMin,
                                  crossAxisSpacing: 32.wMin,
                                  childAspectRatio: 4,
                                ),
                                itemCount: controller.songList.length,
                                itemBuilder: (context, index) {
                                  final item = controller.songList[index];
                                  if(!(item.favourite??false)&&isFirst){
                                    isFirst = false;
                                    return GuideAnchor(
                                      id: 'favourite_btn',
                                      route: Routes.APPLICATION,
                                      child: _musicCardItem(item),
                                    );
                                  }else{
                                  return _musicCardItem(item);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )));
        }));
  }

  Widget buildSecondTabWidget(int index, {Key? key}) {
    return TapScaleWidget(
      key: key,
      onTap: () {
        if (controller.secondSelectedIndex.value != index) {
          controller.secondTabController?.animateTo(index);
          controller.secondSelectedIndex.value = index;
          controller.resetBySecondTheme();
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
              controller.secondThemes[index],
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

  Widget _musicCardItem(SongDetailsItem item) {
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
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
                          decoration: BoxDecoration(color: Color(0xCC8B5CF6), borderRadius: BorderRadius.circular(4.wMin)),
                          child: Text(
                            item.contentTypeTitle ?? "Song",
                            style: TextStyle(
                              fontSize: 16.wMin,
                              color: AppTheme.cInverseTextLight.color,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        SizedBox(width: 4.wMin),
                        if (item.difficulty != null && item.difficulty?.min != null)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
                            margin: EdgeInsets.only(right: 4.wMin),
                            decoration: BoxDecoration(color: StatusUtils.getDifficultyBackgroundColor(item.difficulty!.min).color1, borderRadius: BorderRadius.circular(4.wMin)),
                            child: Text(
                              controller.dif[item.difficulty?.min]!,
                              style: TextStyle(
                                fontSize: 16.wMin,
                                color: AppTheme.cInverseTextLight.color,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        if (item.difficulty != null && item.difficulty!.max != item.difficulty!.min)
                          Row(
                            children: [
                              Text('-', style: TextStyle(color: AppTheme.cTextInverse.color)),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
                                margin: EdgeInsets.only(left: 4.wMin, right: 4.wMin),
                                decoration:
                                    BoxDecoration(color: StatusUtils.getDifficultyBackgroundColor(item.difficulty!.max).color1, borderRadius: BorderRadius.circular(4.wMin)),
                                child: Text(
                                  controller.dif[item.difficulty?.max]!,
                                  style: TextStyle(
                                    fontSize: 16.wMin,
                                    color: AppTheme.cTextInverse.color,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        if (item.tags != null && item.tags!.isNotEmpty)
                          Wrap(
                            spacing: 4.wMin,
                            children: item.tags!.map((tag) {
                              final themeText = StyleUtils.getCurrentThemeText(tag!.style);
                              return Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.wMin,
                                  vertical: 4.wMin,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.wMin),
                                  color: ColorUtils.parseColor(themeText?.backgroundColor) ?? AppTheme.cTextInverse.color,
                                ),
                                child: Text(
                                  getGrene(tag.gloss ?? [], 'zh'),
                                  style: TextStyle(
                                    fontSize: (themeText?.fontsize ?? 16).wMin,
                                    color: ColorUtils.parseColor(themeText?.color) ?? AppTheme.cInverseTextLight.color,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                    SizedBox(height: 24.wMin),
                    Text(item.title ?? '暂无内容', style: TextStyle(fontSize: 32.wMin, fontWeight: FontWeight.w600, color: AppTheme.cTextPrimary.color), maxLines: 2),
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
                      spacing: 8.wMin,
                      children: [
                        FavouriteButton(
                            contentId: item.contentId!,
                            isFavourited: item.favourite ?? false,
                            onRefresh: (needRefresh) {
                              if (needRefresh) {
                                controller.freshSingleSong(item);
                              }
                            }),
                        GestureDetector(
                          onTap: () async {
                            bool experience = await LockUtils.checkExperienceApp(Get.context!);
                            if (experience) return;
                            List<Map<String, dynamic>> songParam = [];
                            for (var song in controller.songList) {
                              songParam.add({
                                "contentId": song.contentId,
                                "contentType": song.contentType,
                              });
                            }
                            JumpPageUtils.jumpSongMv(
                              contents: songParam,
                              contentId: item.contentId,
                              contentType: item.contentType,
                            ).then((_) {
                              controller.refreshSongs();
                            });
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
                                Text('播放', style: TextStyle(fontSize: 22.wMin, color: AppTheme.cTextPrimary.color)),
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

  String getGrene(List<LanguageText?> item, String condition) {
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

  //右上角难度弹窗
  void _showDifficultyDialog(BuildContext context) {
    DifficultyChooseDialog.show(context, 'music');
  }

  Widget _buildLeftTagThumb(SongDetailsItem? item) {
    return CachedImageWidget(item!.imageUrl ?? '', errorWidget: buildEmptyWidget(), placeholder: buildLoadingWidget(), fadeInDuration: Duration.zero);
  }

  double getTextWidth(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr, // 必须指定方向
    )..layout(); // 先 layout 才能拿到 size

    return textPainter.size.width;
  }
}
