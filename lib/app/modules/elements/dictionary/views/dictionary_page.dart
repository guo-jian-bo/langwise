import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../../common/elements_card_groove.dart';
import '../bindings/dictionary_binding.dart';
import '../controllers/dictionary_controller.dart';

class DictionaryPage extends GetView<DictionaryController> {
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
                      right: 24.wMin,
                      bottom: bottomInset + 120.wMin,
                      child: IgnorePointer(
                        ignoring: hasLock,
                        child: _buildFloatingActions(context),
                      ),
                    ),
                    Positioned(
                      left: 90.wMin,
                      right: 90.wMin,
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

  Widget _buildHeader(BuildContext context, {required bool hasLock}) {
    return BreadcrumbWidget(
      actionWidget: IgnorePointer(
        ignoring: hasLock,
        child: Obx(() {
          final String? helpVideoUrl = controller.currentHelpVideoUrl;
          if ((helpVideoUrl ?? '').isEmpty) return const SizedBox();
          return HelpIVideoIconWidget(
            helpVideoUrl: helpVideoUrl,
            size: 40.wMin,
          );
        }),
      ),
    );
  }

  Widget _buildBody(BuildContext context, {required double bottomInset}) {
   
    if (controller.isLoading.value && controller.datas.isEmpty) {
      return const SizedBox();
    }
    if (controller.datas.isEmpty) {
      return _buildNotDataWidget();
    }
    return RefreshIndicator(
      onRefresh: () => controller.refreshList(showLoading: false),
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification is ScrollUpdateNotification &&
              notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent - 1000.wMin) {
            controller.loadMore();
          }
          return false;
        },
        child: GridView.builder(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: controller.datas.length,
          padding: EdgeInsets.only(
            top: 12.wMin,
            bottom: 170.wMin + bottomInset,
            left: 90.wMin,
            right: 90.wMin,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 24.wMin,
            crossAxisSpacing: 24.wMin,
            childAspectRatio: 346 / 576,
          ),
          itemBuilder: (context, index) {
            return ElementsCardGroove(
              index: index,
              data: controller.datas[index],
              disableImagePreview: true,
              useOptimizedTextLayout: true,
              cardHeight: 564.wMin,
              onLongPress: (data, cardKey) {
                data?.key = cardKey;
                controller.showDeleteMask(context, data);
              },
            );
          },
        ),
      ),
    );
  }
    Widget _buildNotDataWidget(){
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

  Widget _buildFloatingActions(BuildContext context) {
    final ConfigController configController = Get.find<ConfigController>();
    return Obx(() {
      final String bilingualTitle =
          _bilingualTitle(configController.userSetting.value.expandLang);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CardLearningButtonsItemWidget(
            title: '词素',
            svg: 'assets/svg/elements/icon_morpheme.svg',
            color: const Color(0xff22C55E),
            index: 0,
            onTap: () {
              TagRoutes.toNamed(
                Routes.DICTIONARY_MORPHEME,
                tagText: Routes.DICTIONARY_MORPHEME,
              );
            },
          ),
          SizedBox(height: 12.wMin),
          CardLearningStyleButtonWidget(
            onSubmit: () {
              controller.refreshList(showLoading: true);
            },
          ),
          SizedBox(height: 12.wMin),
          CardLearningButtonsItemWidget(
            title: bilingualTitle,
            svg: 'assets/svg/public/icon_translation.svg',
            color: const Color(0xff38BDF8),
            index: 1,
            onTap: () async {
              final MeaningDisplayModeDialogResult? result =
                  await MeaningDisplayModeDialog.show(context: context);
              if (result == null) return;
              configController.setLearLangSetting(
                result.code,
                LearModePreference.extension,
              );
            },
          ),
          if (controller.hasLearnedFilterSelected) ...[
            SizedBox(height: 12.wMin),
            CardLearningButtonsWidget(
              showPreview: false,
              showFlash: false,
              showDownload: false,
              onDictation: controller.goDictate,
            ),
          ],
        ],
      );
    });
  }

  Widget _buildBottomBar(BuildContext context) {
    return Obx(() {
      final Map<String, FilterSearchsData> searchs = _buildFilterSearchs();
      controller.maybeShowFilterStripGuide(context);
      return Container(
        key: controller.bottomBarGuideKey,
        child: FilterStripWidget(
          endText: controller.hasLearnedFilterSelected&&controller.count.value>0? '已学:${controller.count.value}个'
              : null,
          width: MediaQuery.of(context).size.width - 32.wMin,
          sorts: _buildFilterSorts(),
          conditions: _buildFilterConditions(),
          searchs: searchs,
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
      );
    });
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
            .map((item) => FilterSortsItem(
                  name: item.name ?? (item.value ?? ''),
                  selected: controller.isSortSelected(
                    groupCode,
                    item.value ?? '',
                  ),
                  isDefault: false,
                  direction: (item.value ?? '').startsWith('-')
                      ? FilterSortDirection.down
                      : FilterSortDirection.up,
                ))
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

  bool Function(Map<String, FilterConditionsData> conditions)?
      _buildConditionVisibility(String? groupName) {
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
        hintText: controller.currentSearchHintText,
      ),
    };
  }

  (String, String) _resolveSelectedSortSelection(
    Map<String, FilterSortsData> sorts,
  ) {
    for (final MapEntry<String, FilterSortsData> entry in sorts.entries) {
      final FilterSortsItem? selected =
          entry.value.sorts.firstWhereOrNull((e) => e.selected);
      if (selected == null) continue;
      return (
        entry.key,
        controller.sortItemValueByName(entry.key, selected.name),
      );
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

  String _bilingualTitle(dynamic preference) {
    final String code = (preference?.code ?? '').toString();
    if (code == 'original') return '原文语言';
    if (code == 'translation') return '译文语言';
    if (code == 'none') return '隐藏文本';
    return '双语对照';
  }
}
