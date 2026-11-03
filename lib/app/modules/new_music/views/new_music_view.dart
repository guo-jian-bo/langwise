import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/subscribe_and_listening_details/difficulty_choose_dialog.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/widgets/favourite_button.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/utils.dart';
import '../bindings/new_music_binding.dart';
import '../controllers/new_music_controller.dart';

class NewMusicView extends GetView<NewMusicController> {
  final String tagText;
  const NewMusicView({super.key, this.tagText = Routes.MUSIC});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return Get.to<T>(
      () => NewMusicView(tagText: tag),
      binding: NewMusicBinding(tagText: tag),
      routeName: Routes.MUSIC,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.of(context).padding.bottom;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.cBgPrimary.color,
        body: Obx(() {
          final bool hasLock =
              controller.rights.value.isLock || controller.rights.value.isNoRights;
          return Column(
            children: [
              _buildHeader(context, hasLock: hasLock),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: IgnorePointer(
                        ignoring: hasLock,
                        child: _buildBody(context, bottomInset: bottomInset),
                      ),
                    ),
                    Positioned(
                      left: 16.wMin,
                      right: 16.wMin,
                      bottom: bottomInset + 20.wMin,
                      child: IgnorePointer(
                        ignoring: hasLock,
                        child: _buildBottomBar(context),
                      ),
                    ),
                    if (hasLock)
                      Positioned.fill(
                        child: LockOverlayWidget(
                          rights: controller.rights.value,
                          showBack: false,
                          child: const SizedBox.expand(),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildBody(BuildContext context, {required double bottomInset}) {
    if (controller.isLoading.value && controller.songList.isEmpty) {
      return const SizedBox();
    }
    if (controller.isNotData.value) {
      return const NotDataWidget(message: '这里还没有歌曲哦');
    }
    return RefreshIndicator(
      onRefresh: () => controller.refreshSongs(showLoading: false),
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification is ScrollUpdateNotification &&
              notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent - 1000.wMin) {
            controller.loadSong();
          }
          return false;
        },
        child: GridView.builder(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            40.wMin,
            20.wMin,
            40.wMin,
            170.wMin + bottomInset,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 32.wMin,
            crossAxisSpacing: 32.wMin,
            childAspectRatio: 4,
          ),
          itemCount: controller.songList.length,
          itemBuilder: (context, index) {
            return _musicCardItem(controller.songList[index]);
          },
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Obx(() {
      return FilterStripWidget(
        width: MediaQuery.of(context).size.width - 32.wMin,
        sorts: _buildFilterSorts(),
        conditions: _buildFilterConditions(),
        searchs: _buildFilterSearchs(),
        onSorts: (sorts) {
          final (String groupCode, String value) =
              _resolveSelectedSortSelection(sorts);
          if (groupCode.isEmpty || value.isEmpty) return;
          controller.applySortSelection(groupCode: groupCode, value: value);
        },
        onConditions: (conditions) {
          controller.applyConditionSelections(
            _resolveSelectedConditions(conditions),
          );
        },
        onSearch: controller.submitSearch,
        onReset: (_, __) {
          controller.resetFilters();
        },
      );
    });
  }

  Widget _buildHeader(BuildContext context, {required bool hasLock}) {
    return BreadcrumbWidget(
      actionWidget: IgnorePointer(
        ignoring: hasLock,
        child: _buildDifficultyButton(context),
      ),
    );
  }

  Map<String, FilterSortsData> _buildFilterSorts() {
    final Map<String, FilterSortsData> resp = <String, FilterSortsData>{};
    for (final ZhenduScriptQueryMetaGroupEntity group
        in controller.orderGroups) {
      final String groupCode = (group.groupCode ?? '').trim();
      if (groupCode.isEmpty || group.items.isEmpty) continue;
      resp[groupCode] = FilterSortsData(
        title: group.groupName ?? groupCode,
        sorts: group.items
            .map(
              (item) => FilterSortsItem(
                name: item.name ?? (item.value ?? ''),
                selected: controller.isSortSelected(
                  groupCode,
                  item.value ?? '',
                ),
                direction: (item.value ?? '').startsWith('-')
                    ? FilterSortDirection.down
                    : FilterSortDirection.up,
              ),
            )
            .toList(),
      );
    }
    return resp;
  }

  Map<String, FilterConditionsData> _buildFilterConditions() {
    final Map<String, FilterConditionsData> resp =
        <String, FilterConditionsData>{};
    for (final ZhenduScriptQueryMetaGroupEntity group
        in controller.filterGroups) {
      final String groupCode = (group.groupCode ?? '').trim();
      if (groupCode.isEmpty || group.items.isEmpty) continue;
      resp[groupCode] = FilterConditionsData(
        title: group.groupName ?? groupCode,
        isSingle: (group.component ?? '').trim() == 'radio',
        component: group.component,
        filterGroup: group.filterGroup,
        radioGroup: group.radioGroup ?? false,
        conditions: group.items
            .map(
              (item) => FilterConditionsItem(
                name: item.name ?? (item.value ?? ''),
                value: item.value ?? '',
                selected: controller.isFilterSelected(
                  groupCode,
                  item.value ?? '',
                ),
              ),
            )
            .toList(),
      );
    }
    return resp;
  }

  Map<String, FilterSearchsData> _buildFilterSearchs() {
    return <String, FilterSearchsData>{
      'content': FilterSearchsData(
        controller: controller.searchController,
        title: '内容搜索',
        hintText: controller.currentSearchHintText,
      ),
    };
  }

  (String, String) _resolveSelectedSortSelection(
    Map<String, FilterSortsData> sorts,
  ) {
    for (final MapEntry<String, FilterSortsData> entry in sorts.entries) {
      for (final FilterSortsItem item in entry.value.sorts) {
        if (!item.selected) continue;
        return (
          entry.key,
          controller.sortItemValueByName(entry.key, item.name),
        );
      }
    }
    return ('', '');
  }

  Map<String, List<String>> _resolveSelectedConditions(
    Map<String, FilterConditionsData> conditions,
  ) {
    final Map<String, List<String>> resp = <String, List<String>>{};
    for (final MapEntry<String, FilterConditionsData> entry
        in conditions.entries) {
      final List<String> values = entry.value.conditions
          .where((e) => e.selected)
          .map((e) => e.value?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
      if (values.isEmpty) continue;
      resp[entry.key] = values;
    }
    return resp;
  }

  Widget _buildDifficultyButton(BuildContext context) {
    return Obx(() {
      return RecommendDifficultyButtonWidget(
        currentDifficulty: controller.settingDifficulty.value,
        recommendedDifficulty: controller.userDifficulty.value,
        difficultyList: controller.difficultyList,
        onTap: () {
          _showDifficultyDialog(context);
        },
      );
    });
  }

  void _showDifficultyDialog(BuildContext context) {
    DifficultyChooseDialog.show(
      context,
      'new_music',
      tagText: tagText,
    );
  }

  Widget _musicCardItem(SongDetailsItem item) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.wMin),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceSecondary.color,
          border: Border.all(
            color: AppTheme.cBorderPrimary.color,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  await _openSong(item);
                },
              ),
            ),
            Row(
              children: [
                SizedBox(
                  height: double.infinity,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: _buildLeftTagThumb(item),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(12.wMin, 16.wMin, 0, 8.wMin),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.wMin,
                                vertical: 2.wMin,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xCC8B5CF6),
                                borderRadius: BorderRadius.circular(4.wMin),
                              ),
                              child: Text(
                                item.contentTypeTitle ?? 'Song',
                                style: TextStyle(
                                  fontSize: 16.wMin,
                                  color: AppTheme.cInverseTextLight.color,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            SizedBox(width: 4.wMin),
                            if (item.difficulty?.min != null)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.wMin,
                                  vertical: 2.wMin,
                                ),
                                margin: EdgeInsets.only(right: 4.wMin),
                                decoration: BoxDecoration(
                                  color: StatusUtils.getDifficultyBackgroundColor(
                                    item.difficulty!.min,
                                  ).color1,
                                  borderRadius: BorderRadius.circular(4.wMin),
                                ),
                                child: Text(
                                  _difficultyLabel(item.difficulty!.min),
                                  style: TextStyle(
                                    fontSize: 16.wMin,
                                    color: AppTheme.cInverseTextLight.color,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            if (item.difficulty != null &&
                                item.difficulty!.max != item.difficulty!.min)
                              Row(
                                children: [
                                  Text(
                                    '-',
                                    style: TextStyle(
                                      color: AppTheme.cTextInverse.color,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.wMin,
                                      vertical: 2.wMin,
                                    ),
                                    margin: EdgeInsets.only(
                                      left: 4.wMin,
                                      right: 4.wMin,
                                    ),
                                    decoration: BoxDecoration(
                                      color: StatusUtils
                                          .getDifficultyBackgroundColor(
                                        item.difficulty!.max,
                                      ).color1,
                                      borderRadius:
                                          BorderRadius.circular(4.wMin),
                                    ),
                                    child: Text(
                                      _difficultyLabel(item.difficulty!.max),
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
                                children:
                                    item.tags!.whereType<SongEntityTags>().map(
                                  (tag) {
                                    final ThemeTextStyleEntity? themeText =
                                        StyleUtils.getCurrentThemeText(tag.style);
                                    return Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.wMin,
                                        vertical: 4.wMin,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(4.wMin),
                                        color: ColorUtils.parseColor(
                                              themeText?.backgroundColor,
                                            ) ??
                                            AppTheme.cTextInverse.color,
                                      ),
                                      child: Text(
                                        _getTagText(
                                            tag.gloss ?? <LanguageText?>[]),
                                        style: TextStyle(
                                          fontSize:
                                              (themeText?.fontsize ?? 16).wMin,
                                          color: ColorUtils.parseColor(
                                                themeText?.color,
                                              ) ??
                                              AppTheme.cInverseTextLight.color,
                                        ),
                                      ),
                                    );
                                  },
                                ).toList(),
                              ),
                          ],
                        ),
                        SizedBox(height: 24.wMin),
                        Text(
                          item.title ?? '暂无内容',
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 32.wMin,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.cTextPrimary.color,
                          ),
                        ),
                        if ((item.content ?? '').isNotEmpty)
                          Text(
                            item.content!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 22.wMin,
                              color: AppTheme.cTextTertiary.color,
                            ),
                          ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            FavouriteButton(
                              styleId: item.styleId,
                              dialect: item.dialect,
                              contentId: item.contentId!,
                              isFavourited: item.favourite ?? false,
                              onRefresh: (needRefresh) {
                                if (!needRefresh) return;
                                controller.freshSingleSong(item);
                              },
                            ),
                            SizedBox(width: 16.wMin),
                            GestureDetector(
                              onTap: () async {
                                await _openSong(item);
                              },
                              child: Container(
                                height: 48.wMin,
                                padding: EdgeInsets.only(
                                  left: 16.wMin,
                                  right: 8.wMin,
                                  top: 6.wMin,
                                  bottom: 6.wMin,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.wMin),
                                  color: AppTheme.cSurfaceQuaternary.color,
                                  border: Border.all(
                                    color: AppTheme.cBorderTertiary.color,
                                    width: 0.6.wMin,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '播放',
                                      style: TextStyle(
                                        fontSize: 22.wMin,
                                        color: AppTheme.cTextPrimary.color,
                                      ),
                                    ),
                                    SizedBox(width: 2.wMin),
                                    SvgPicture.asset(
                                      'assets/svg/user_center/icon_chevron_right1.svg',
                                      width: 20.wMin,
                                      height: 20.wMin,
                                      colorFilter: ColorFilter.mode(
                                        AppTheme.cTextPrimary.color,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.wMin),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 16.wMin),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openSong(SongDetailsItem item) async {
    if (item.contentId == null) return;
    final bool experience = await LockUtils.checkExperienceApp(
      Get.context!,
    );
    if (experience) return;
    final List<Map<String, dynamic>> songParam = controller.songList
        .map(
          (song) => <String, dynamic>{
            'contentId': song.contentId,
            'contentType': song.contentType,
            'styleId': song.styleId,
            'dialect': song.dialect,
          },
        )
        .toList();
    JumpPageUtils.jumpSongMv(
      contents: songParam,
      contentId: item.contentId,
      contentType: item.contentType,
      styleId: item.styleId,
      dialect: item.dialect,
    ).then((_) {
      controller.refreshSongs(showLoading: false);
    });
  }

  Widget _buildLeftTagThumb(SongDetailsItem item) {
    return CachedImageWidget(
      item.imageUrl ?? '',
      errorWidget: buildEmptyWidget(),
      placeholder: buildLoadingWidget(),
      fadeInDuration: Duration.zero,
    );
  }

  String _difficultyLabel(int? value) {
    switch (value) {
      case 0:
        return 'Pre A1';
      case 1:
        return 'A1';
      case 2:
        return 'A2';
      case 3:
        return 'B1';
      case 4:
        return 'B2';
      case 5:
        return 'C1';
      case 6:
        return 'C2';
      default:
        return '';
    }
  }

  String _getTagText(List<LanguageText?> items) {
    for (final LanguageText? glossItem in items) {
      if (glossItem?.lang == 'zh') {
        return glossItem?.text ?? '';
      }
    }
    for (final LanguageText? glossItem in items) {
      if (glossItem?.lang == 'en') {
        return glossItem?.text ?? '';
      }
    }
    return items.firstWhereOrNull((e) => (e?.text ?? '').isNotEmpty)?.text ??
        '';
  }
}
