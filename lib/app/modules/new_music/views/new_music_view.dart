import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
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
              _buildHeader(),
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
            90.wMin,
            20.wMin,
            90.wMin,
            170.wMin + bottomInset,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 24.wMin,
            crossAxisSpacing: 24.wMin,
            childAspectRatio: 417 / 639,
          ),
          itemCount: controller.songList.length,
          itemBuilder: (context, index) {
            return KnowledgeCardWidget(
              knowledgeData: controller.songList[index],
              onReturned: () => controller.refreshSongs(showLoading: false),
            );
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

  Widget _buildHeader() {
    return BreadcrumbWidget(
      actionWidget: GeneralSettingButtonWidget(),
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
}
