import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/zhendu/widgets/zhendu_script_card_widget.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/stores/user.dart';
import '../bindings/zhendu_theater_list_binding.dart';
import '../controllers/zhendu_theater_list_controller.dart';
import '../../../../routes/routes.dart';
import '../../../../routes/tag_routes.dart';

class ZhenduTheaterListView extends GetView<ZhenduTheaterListController> {
  final String tagText;
  const ZhenduTheaterListView({
    super.key,
    required this.tagText,
  });

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    final theater =
        arguments is Map<String, dynamic> ? arguments['theater'] : null;
    if (theater is! ZhenduTheaterEntity) {
      return null;
    }
    return Get.to<T>(
      () => ZhenduTheaterListView(tagText: tag),
      binding: ZhenduTheaterListBinding(
        tagText: tag,
        theater: theater,
      ),
      routeName: Routes.ZHENDU_THEATER_LIST,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: AppTheme.cBgPrimary.color,
          body: Obx(() {
            final rights = controller.pageRights.value;
            final hasLock = _hasLockRights(rights);
            return Stack(
              children: [
                Positioned.fill(
                  child: _buildPageBody(
                    context,
                    bottomInset: bottomInset,
                    rights: rights,
                    hasLock: hasLock,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: const BreadcrumbWidget(),
                ),
              ],
            );
          }),
        ));
  }

  bool _hasLockRights(LockEntity? rights) {
    if (rights == null) return false;
    return rights.isLock || rights.isNoRights;
  }

  Widget _buildPageBody(
    BuildContext context, {
    required double bottomInset,
    required LockEntity? rights,
    required bool hasLock,
  }) {
    final status = controller.loadStatus.value;
    return Stack(
      children: [
        _buildHero(context),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 96.wMin + MediaQuery.of(context).padding.top),
            // Padding(
            //   padding: EdgeInsets.fromLTRB(94.wMin, 8.wMin, 24.wMin, 8.wMin),
            //   child: Text(
            //     controller.getHeroTitle(),
            //     style: TextStyle(
            //       fontSize: 32.wMin,
            //       color: AppTheme.cTextPrimary.color,
            //     ),
            //   ),
            // ),
            Padding(
              padding: EdgeInsets.only(left: 94.wMin, right: 24.wMin),
              child: Text(
                controller.getHeroDescription(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 28.wMin,
                  color: AppTheme.cTextTertiary.color,
                ),
              ),
            ),
            SizedBox(height: 24.wMin),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      ignoring: hasLock,
                      child: _buildBodyByStatus(
                        context,
                        status: status,
                        bottomInset: bottomInset,
                      ),
                    ),
                  ),
                  if ((status == 0 || status == 4) && controller.hasFilterMeta)
                    Positioned(
                      left: 16.wMin,
                      right: 16.wMin,
                      bottom: bottomInset + 20.wMin,
                      child: IgnorePointer(
                        ignoring: hasLock,
                        child: _buildBottomQueryBar(context),
                      ),
                    ),
                  if (hasLock)
                    Positioned.fill(
                      child: LockOverlayWidget(
                        rights: rights,
                        showBack: false,
                        child: const SizedBox.expand(),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBodyByStatus(
    BuildContext context, {
    required int status,
    required double bottomInset,
  }) {
    if (status == -1) {
      return _buildLoadingState();
    }
    if (status == 1) {
      return _buildFailureState();
    }
    if (status == 4) {
      return const Center();
    }
    return RefreshIndicator(
      onRefresh: controller.initPage,
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification is ScrollUpdateNotification &&
              notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent - 1000.wMin) {
            controller.loadMore();
          }
          return false;
        },
        child: SingleChildScrollView(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            bottom:
                (controller.hasFilterMeta ? 120.wMin : 24.wMin) + bottomInset,
          ),
          child: Column(
            children: [
              _buildContent(context),
              _buildPagingFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center();
  }

  Widget _buildFailureState() {
    return NotDataWidget(
      message: '加载失败',
      buttonText: '重试',
      onButton: controller.initPage,
    );
  }

  Widget _buildHero(BuildContext context) {
    final heroImage = controller.theater.backgroundImage ?? '';

    return SizedBox(
      height: 230.wMin,
      child: Stack(
        children: [
          Positioned.fill(
            child: heroImage.trim().isEmpty
                ? Container(color: AppTheme.cBgSecondary.color)
                : CachedImageWidget(
                    heroImage,
                    fit: BoxFit.cover,
                    placeholder: buildLoadingWidget(fit: BoxFit.cover),
                    errorWidget: buildNetworkWidget(fit: BoxFit.cover),
                  ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _heroAccent().withValues(alpha: 0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.cBgPrimary.color.withValues(alpha: 0.18),
                    AppTheme.cBgPrimary.color.withValues(alpha: 0.34),
                    AppTheme.cBgPrimary.color.withValues(alpha: 0.92),
                    AppTheme.cBgPrimary.color,
                  ],
                  stops: const [0.0, 0.34, 0.84, 1.0],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.topCenter,
              child: FractionallySizedBox(
                widthFactor: 0.56,
                heightFactor: 0.42,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topCenter,
                      radius: 1.0,
                      colors: [
                        const Color(0xFFFFF4D2).withValues(alpha: 0.18),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.72],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1100.wMin ? 3 : (width >= 720.wMin ? 2 : 1);
        final paddingX =
            switch (columns) { 3 => 50.wMin, 2 => 64.wMin, _ => 20.wMin };
        final itemHeight = 700.wMin;
        return Padding(
          padding: EdgeInsets.fromLTRB(paddingX, 20, paddingX, 0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 26.wMin,
              crossAxisSpacing: 50.wMin,
              mainAxisExtent: itemHeight,
            ),
            itemCount: controller.items.length,
            itemBuilder: (context, index) {
              final item = controller.items[index];
              return ZhenduScriptCardWidget(
                item: item,
                theaterCategory: controller.theater.category,
                coverUrl: controller.getResolvedCoverUrl(item),
                thumbUrl: controller.getResolvedThumbUrl(item),
                onTap: () async {
                  final mRights = item.cardRights;
                  if (mRights == null) return;
                  final lock = await LockUtils.checkLock(
                    mRights,
                    Get.context!,
                  );
                  if (lock) return;
                  UserStore.to.getUserInfo();
                  final scriptId = item.uid;
                  if (scriptId == null) return;
                  await TagRoutes.toNamed(
                    Routes.ZHENDU_SHOW_DETAIL,
                    tagText: '${Routes.ZHENDU_SHOW_DETAIL}_$scriptId',
                    arguments: {
                      'contentId': scriptId,
                      'locate': item.locate,
                      'styleId': item.styleId,
                      'dialect': item.dialect,
                    },
                  );
                  if (Get.currentRoute == Routes.ZHENDU_THEATER_LIST) {
                    await controller.initPage();
                  }
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBottomQueryBar(BuildContext context) {
    return Obx(() {
      return FilterStripWidget(
        width: MediaQuery.of(context).size.width - 32.wMin,
        sorts: _buildFilterSorts(),
        conditions: _buildFilterConditions(),
        searchs: _buildFilterSearchs(),
        onSorts: (sorts) {
          final selection = _resolveSelectedSortSelection(sorts);
          final groupCode = selection.$1;
          final value = selection.$2;
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
        onSearch: () {
          controller.commitQuery();
        },
        onReset: (_, __) {
          controller.onResetQuery();
        },
      );
    });
  }

  Widget _buildPagingFooter() {
    return SizedBox(height: 12.wMin);
  }

  Map<String, FilterSortsData> _buildFilterSorts() {
    final resp = <String, FilterSortsData>{};
    for (final group in controller.orderGroups) {
      final groupCode = (group.groupCode ?? '').trim();
      if (groupCode.isEmpty || group.items.isEmpty) continue;
      resp[groupCode] = FilterSortsData(
        title: group.groupName ?? groupCode,
        sorts: group.items.map((item) {
          final value = item.value ?? '';
          return FilterSortsItem(
            name: item.name ?? value,
            selected: controller.isSortSelected(groupCode, value),
            isDefault: false,
            direction: value.startsWith('-')
                ? FilterSortDirection.down
                : FilterSortDirection.up,
          );
        }).toList(),
      );
    }
    return resp;
  }

  Map<String, FilterConditionsData> _buildFilterConditions() {
    final resp = <String, FilterConditionsData>{};
    for (final group in controller.filterGroups) {
      final groupCode = (group.groupCode ?? '').trim();
      if (groupCode.isEmpty || group.items.isEmpty) continue;
      resp[groupCode] = FilterConditionsData(
        title: group.groupName ?? groupCode,
        isSingle: false,
        conditions: group.items.map((item) {
          final value = item.value ?? '';
          return FilterConditionsItem(
            name: item.name ?? value,
            value: value,
            selected: controller.isFilterSelected(groupCode, value),
          );
        }).toList(),
      );
    }
    return resp;
  }

  Map<String, FilterSearchsData> _buildFilterSearchs() {
    return {
      'keyword': FilterSearchsData(
        controller: controller.searchController,
        title: '内容搜索',
        hintText: controller.currentSearchHintText,
      ),
    };
  }

  (String, String) _resolveSelectedSortSelection(
    Map<String, FilterSortsData> sorts,
  ) {
    for (final entry in sorts.entries) {
      final selected = entry.value.sorts.firstWhereOrNull((e) => e.selected);
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
    final resp = <String, List<String>>{};
    for (final entry in conditions.entries) {
      final values = entry.value.conditions
          .where((e) => e.selected)
          .map((e) => e.value?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
      if (values.isEmpty) continue;
      resp[entry.key] = values;
    }
    return resp;
  }

  Color _heroAccent() {
    final c = controller.theater.category ?? '';
    if (c == 'context') return const Color(0xFF10B981);
    if (c == 'semantic') return const Color(0xFFA855F7);
    return const Color(0xFFF59E0B);
  }
}
