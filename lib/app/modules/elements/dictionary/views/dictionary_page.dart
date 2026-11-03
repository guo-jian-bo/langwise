import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../../common/elements_cards/elements_public_card.dart';
import '../bindings/dictionary_binding.dart';
import '../controllers/dictionary_controller.dart';

class DictionaryPage extends GetView<DictionaryController> {
  static const bool _showCardStarArea = true;
  final String tagText;
  const DictionaryPage({
    super.key,
    this.tagText = Routes.DICTIONARY,
  });

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return Get.to<T>(
      () => DictionaryPage(tagText: tag),
      binding: DictionaryBinding(tagText: tag),
      routeName: Routes.DICTIONARY,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
        return LockOverlayWidget(
          rights: controller.rights.value,
          showBack: true,
          child: Scaffold(
            backgroundColor: AppTheme.cBgPrimary.color,
            bottomNavigationBar: _buildBottomNavigationBar(context),
            body: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      90.wMin,
                      0,
                      90.wMin,
                      24.wMin,
                    ),
                    child: _buildBody(context),
                  ),
                ),
              ],
            ),
          ),
        );
      })
    ;
  }

  Widget _buildHeader(BuildContext context) {
    return BreadcrumbWidget(
      actionWidget: Obx(() {
        final String currentHelpVideoUrl = controller.helpVideoUrl.value.trim();
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GeneralSettingButtonWidget(),
            if (currentHelpVideoUrl.isNotEmpty) SizedBox(width: 12.wMin),
            if (currentHelpVideoUrl.isNotEmpty)
              HelpIVideoIconWidget(
                helpVideoUrl: currentHelpVideoUrl,
                size: 40.wMin,
              ),
          ],
        );
      }),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (controller.isLoading.value && controller.items.isEmpty) {
      return const SizedBox();
    }
    if (controller.isNotData.value) {
      return _buildNotDataWidget();
    }
    final bool allowResetCard = controller.hasLearnedFilterSelected();
    return RefreshIndicator(
      onRefresh: () => controller.refreshList(showLoading: false),
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification is ScrollUpdateNotification && notification.metrics.pixels >= notification.metrics.maxScrollExtent - 1000.wMin) {
            controller.loadMore();
          }
          return false;
        },
        child: GridView.builder(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: controller.items.length,
          // padding: EdgeInsets.only(
          //   top: 12.wMin,
          //   bottom: 24.wMin,
          //   left: 90.wMin,
          //   right: 90.wMin,
          // ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 24.wMin,
            crossAxisSpacing: 24.wMin,
            childAspectRatio: _showCardStarArea ? 346 / 567 : 346 / 546,
          ),
          itemBuilder: (context, index) {
            final GlobalKey cardKey = GlobalKey();
            return ElementsDictReadCard(
              key: cardKey,
              data: controller.items[index],
              showCardStarArea: _showCardStarArea,
              onLongPress: !allowResetCard
                  ? null
                  : () => controller.showResetLearnMask(
                        context,
                        controller.items[index],
                        cardKey,
                      ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotDataWidget() {
    return Container(
      alignment: Alignment.center,
      child: NotDataWidget(
        other: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "没有找到相关内容",
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
            Text(
              "换个关键词，或调整筛选条件，再试一次。",
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextTertiary.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(90.wMin, 0, 90.wMin, 20.wMin),
        child: _buildBottomBar(context),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Obx(() {
      final bool showDictation =
          controller.hasLearnedFilterSelected() && controller.items.isNotEmpty;
      return LayoutBuilder(
        builder: (context, constraints) {
          final double dictationSpacing = showDictation ? 12.wMin : 0;
          final double dictationWidth = showDictation ? 148.wMin : 0;
          final double filterWidth = constraints.maxWidth - dictationWidth - dictationSpacing;
          return Row(
            children: [
              SizedBox(
                width: filterWidth,
                child: FilterStripWidget(
                  endText: showDictation && controller.count.value > 0 ? '已学:${controller.count.value}个' : null,
                  width: filterWidth,
                  sorts: _buildFilterSorts(),
                  conditions: _buildFilterConditions(),
                  searchs: _buildFilterSearchs(),
                  onSorts: (sorts) {
                    final selection = _resolveSelectedSortSelection(sorts);
                    final String groupCode = selection.$1;
                    final String value = selection.$2;
                    if (groupCode.isEmpty || value.isEmpty) return;
                    controller.applySortSelection(
                      groupCode: groupCode,
                      value: value,
                    );
                  },
                  onConditions: (conditions) {
                    controller.applyConditionSelections(
                      _resolveSelectedConditions(conditions),
                    );
                  },
                  onSearch: controller.submitSearch,
                  onReset: (_, __) {
                    controller.searchController.clear();
                    controller.resetFilters();
                  },
                ),
              ),
              if (showDictation) SizedBox(width: 12.wMin),
              if (showDictation) _buildDictationButton(),
            ],
          );
        },
      );
    });
  }

  Map<String, FilterSortsData> _buildFilterSorts() {
    final Map<String, FilterSortsData> resp = <String, FilterSortsData>{};
    for (final ZhenduScriptQueryMetaGroupEntity group in controller.buildOrderGroups()) {
      final String groupCode = (group.groupCode ?? '').trim();
      if (groupCode.isEmpty || group.items.isEmpty) continue;
      resp[groupCode] = FilterSortsData(
        title: group.groupName ?? groupCode,
        sorts: group.items
            .map((item) => FilterSortsItem(
                  name: item.name ?? (item.value ?? ''),
                  selected: controller.isSortSelected(
                    groupCode,
                    item.value ?? '',
                  ),
                  isDefault: false,
                  direction: (item.value ?? '').startsWith('-') ? FilterSortDirection.down : FilterSortDirection.up,
                ))
            .toList(),
      );
    }
    return resp;
  }

  Map<String, FilterConditionsData> _buildFilterConditions() {
    final Map<String, FilterConditionsData> resp = <String, FilterConditionsData>{};
    for (final ZhenduScriptQueryMetaGroupEntity group in controller.buildFilterGroups()) {
      final String groupCode = (group.groupCode ?? '').trim();
      if (groupCode.isEmpty || group.items.isEmpty) continue;
      resp[groupCode] = FilterConditionsData(
        title: group.groupName ?? groupCode,
        isSingle: (group.component ?? '').trim() == 'radio',
        component: group.component,
        filterGroup: group.filterGroup,
        radioGroup: group.radioGroup ?? false,
        visibleWhen: _buildConditionVisibility(group.groupName),
        conditions: group.items
            .map((item) => FilterConditionsItem(
                  name: item.name ?? (item.value ?? ''),
                  value: item.value ?? '',
                  selected: controller.isFilterSelected(
                    groupCode,
                    item.value ?? '',
                  ),
                ))
            .toList(),
      );
    }
    return resp;
  }

  bool Function(Map<String, FilterConditionsData> conditions)? _buildConditionVisibility(String? groupName) {
    final String currentGroupName = (groupName ?? '').trim();
    if (currentGroupName != '上次学习时间' && currentGroupName != '首次学习时间') {
      return null;
    }
    return (Map<String, FilterConditionsData> conditions) {
      for (final FilterConditionsData data in conditions.values) {
        for (final FilterConditionsItem item in data.conditions) {
          if (!item.selected) continue;
          if ((item.value?.toString() ?? '').trim() == 'LEARNED') {
            return true;
          }
        }
      }
      return false;
    };
  }

  Map<String, FilterSearchsData> _buildFilterSearchs() {
    return {
      'content': FilterSearchsData(
        controller: controller.searchController,
        title: '搜索',
        hintText: controller.buildCurrentSearchHintText(),
      ),
    };
  }

  (String, String) _resolveSelectedSortSelection(
    Map<String, FilterSortsData> sorts,
  ) {
    for (final MapEntry<String, FilterSortsData> entry in sorts.entries) {
      final FilterSortsItem? selected = entry.value.sorts.firstWhereOrNull((e) => e.selected);
      if (selected == null) continue;
      return (
        entry.key,
        controller.findSortItemValueByName(entry.key, selected.name),
      );
    }
    return ('', '');
  }

  Map<String, List<String>> _resolveSelectedConditions(
    Map<String, FilterConditionsData> conditions,
  ) {
    final Map<String, List<String>> resp = <String, List<String>>{};
    for (final MapEntry<String, FilterConditionsData> entry in conditions.entries) {
      final List<String> values =
          entry.value.conditions.where((e) => e.selected).map((e) => e.value?.toString() ?? '').where((e) => e.isNotEmpty).toList();
      if (values.isEmpty) continue;
      resp[entry.key] = values;
    }
    return resp;
  }

  Widget _buildDictationButton() {
    return TapScaleWidget(
      onTap: controller.goDictate,
      sclae: 1.02,
      child: Container(
        height: 64.wMin,
        padding: EdgeInsets.symmetric(horizontal: 24.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: AppTheme.cSurfaceInfo.color.withValues(alpha: 0.15),
          border: Border.all(
            color: AppTheme.cSurfaceInfo.color.withValues(alpha: 0.2),
            width: 1.wMin,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/svg/public/icon_earphones.svg',
              width: 32.wMin,
              colorFilter: ColorFilter.mode(
                AppTheme.cSurfaceInfo.color,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: 6.wMin),
            Text(
              '听写',
              style: TextStyle(
                color: AppTheme.cSurfaceInfo.color,
                fontSize: 24.wMin,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
