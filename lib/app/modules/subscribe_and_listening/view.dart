import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/subscribe_and_listening/sub_history_dialog.dart';
import 'package:langwise/app/modules/subscribe_and_listening/subscribe_dialog.dart';
import 'package:langwise/app/modules/subscribe_and_listening/unsubscribe_dialog.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/lock_utils.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:video_player/video_player.dart';
import '../../../common/widgets/widgets.dart';
import 'bindings.dart';
import 'controller.dart';

class SubListenPage extends GetView<SubListenController> {
  final String tagText;
  const SubListenPage({
    super.key,
    this.tagText = Routes.APP_SUBSCRIBE_LISTENING,
  });

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return Get.to<T>(
      () => SubListenPage(tagText: tag),
      binding: SubListenBinding(tagText: tag),
      routeName: Routes.APP_SUBSCRIBE_LISTENING,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.of(context).padding.bottom;
    return Obx(() {
      final bool hasLock = controller.rights.value.isLock || controller.rights.value.isNoRights;
      final bool isDetails = controller.isInCollectionDetails;
      return Scaffold(
        backgroundColor: AppTheme.cBgPrimary.color,
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      ignoring: hasLock,
                      child: _buildBody(
                        context,
                        bottomInset: bottomInset,
                        isDetails: isDetails,
                      ),
                    ),
                  ),
                  if (!isDetails)
                    Positioned(
                      right: 24.wMin,
                      bottom: bottomInset + 24.wMin,
                      child: IgnorePointer(
                        ignoring: hasLock,
                        child: _buildFloatingButtons(context),
                      ),
                    ),
                  if (isDetails)
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
        ),
      );
    });
  }

  Widget _buildHeader(BuildContext context) {
    return BreadcrumbWidget();
  }

  Widget _buildBody(
    BuildContext context, {
    required double bottomInset,
    required bool isDetails,
  }) {
    if (isDetails) {
      if (controller.contentIsLoading.value && controller.contentItems.isEmpty) {
        return const SizedBox();
      }
      if (controller.contentIsNotData.value) {
        return const NotDataWidget(message: '这里还没有时文内容哦');
      }
      return RefreshIndicator(
        onRefresh: () => controller.refreshContentPage(showLoading: false),
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) {
            if (notification is ScrollUpdateNotification &&
                notification.metrics.pixels >=
                    notification.metrics.maxScrollExtent - 1000.wMin) {
              controller.loadContentPage(showLoading: false);
            }
            return false;
          },
          child: GridView.builder(
            key: const PageStorageKey<String>('sublisten_content_grid'),
            controller: controller.contentScrollController,
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
            itemCount: controller.contentItems.length,
            itemBuilder: (context, index) {
              return KnowledgeCardWidget(
                knowledgeData: controller.contentItems[index],
                onReturned: () =>
                    controller.refreshContentPage(showLoading: false),
              );
            },
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refreshUserRevealsPage,
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification is ScrollUpdateNotification &&
              notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent - 1000.wMin) {
            controller.getUserRevealsPage();
          }
          return false;
        },
        child: GridView.builder(
          key: const PageStorageKey<String>('sublisten_reveals_grid'),
          controller: controller.revealsScrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            90.wMin,
            20.wMin,
            90.wMin,
            170.wMin + bottomInset,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 32.wMin,
            crossAxisSpacing: 32.wMin,
            childAspectRatio: 426 / 560,
          ),
          itemCount: controller.reveals.length,
          itemBuilder: (context, index) {
            final item = controller.reveals[index];
            return _cardItem(item);
          },
        ),
      ),
    );
  }

  Widget _buildFloatingButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildFloatingButton(
          title: '历史记录',
          icon: Icons.history_rounded,
          textColor: AppTheme.cInverseTextLight.color,
          fillColor: Colors.white.withValues(alpha: 0.08),
          borderColor: Colors.white.withValues(alpha: 0.18),
          onTap: () => _showSubHistoryDialog(context),
        ),
        SizedBox(height: 16.wMin),
        _buildFloatingButton(
          title: '订阅管理',
          icon: Icons.swap_horiz_rounded,
          textColor: AppTheme.cTextBrand.color,
          fillColor: AppTheme.cTextBrand.color.withValues(alpha: 0.12),
          borderColor: AppTheme.cTextBrand.color.withValues(alpha: 0.32),
          onTap: () => _showSubManageDialog(context),
        ),
      ],
    );
  }

  Widget _buildFloatingButton({
    required String title,
    required VoidCallback onTap,
    required Color fillColor,
    required Color borderColor,
    required Color textColor,
    required IconData icon,
  }) {
    return TapScaleWidget(
      sclae: 1.02,
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: PlatformBackdropFilterWidget(
          sigmaX: 10.wMin,
          sigmaY: 10.wMin,
          child: Container(
            height: 64.wMin,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 22.wMin),
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: borderColor,
                width: 1.wMin,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 28.wMin,
                  color: textColor,
                ),
                SizedBox(width: 8.wMin),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //右上角历史记录弹窗
  void _showSubHistoryDialog(BuildContext context) {
    controller.loadUserRevealPushRecord().then((_) {
      SubHistoryDialog.show(
        context,
        tagText: tagText,
      );
    });
  }

  //右上角订阅管理弹窗
  void _showSubManageDialog(BuildContext context) {
    controller.getUserSubscribeConfig();
  }

  Widget _cardItem(UserRevealCollectionEntity item) {
    return GestureDetector(
      onTap: () {
        final int? id = item.collectionId;
        if (id == null) return;
        controller.enterCollection(
          collectionId: id,
          title: getGrene(item.themeName?.gloss ?? [], 'zh', ignore: true),
          description: getGrene(item.depiction ?? [], 'zh', ignore: true),
        );
      },
      child: Container(
        width: 426.wMin,
        height: 560.wMin,
        padding: EdgeInsets.all(16.wMin),
        decoration: BoxDecoration(
            color: AppTheme.cSurfaceSecondary.color,
            border: Border.all(color: AppTheme.cBorderSecondary.color),
            borderRadius: BorderRadius.circular(16.wMin)),
        child: Column(
          children: [
            Stack(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.wMin),
                child: Container(
                  width: double.infinity,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: CachedImageWidget(
                      item.avatarUrl ?? "",
                      errorWidget: buildEmptyWidget(),
                      placeholder: buildLoadingWidget(),
                      fadeInDuration: Duration.zero,
                    ),
                  ),
                ),
              ),
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [
                          0.6,
                          1
                        ],
                        colors: [
                          Color(0x00000000),
                          Color(0xFF000000).withOpacity(0.7)
                        ]),
                  ),
                ),
              ),
              Positioned(
                  left: 10.wMin,
                  top: 10.wMin,
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(
                        horizontal: 8.wMin, vertical: 4.wMin),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.wMin),
                        color: Color(0xFF131617).withAlpha(64),
                        backgroundBlendMode: BlendMode.overlay),
                    child: Text(getGrene(item.genreName?.gloss ?? [], 'zh'),
                        style: TextStyle(
                            fontSize: 22.wMin,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(
                                  blurRadius: 4.wMin,
                                  color: const Color(0x1A000000),
                                  offset: Offset(0, 2.wMin))
                            ],
                            color: Colors.white)),
                  )),
              if (item.isNewContent ?? false)
                Positioned(
                    right: 10.wMin,
                    top: 10.wMin,
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.wMin, vertical: 4.wMin),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.wMin),
                          color: AppTheme.cSurfaceError),
                      child: Text('new',
                          style: TextStyle(
                              fontSize: 22.wMin,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.cInverseTextLight.color)),
                    )),
              Positioned(
                  bottom: 12.wMin,
                  left: 10.wMin,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            getGrene(item.themeName?.gloss ?? [], 'zh',
                                ignore: true),
                            style: TextStyle(
                                fontSize: 40.wMin,
                                shadows: [
                                  Shadow(
                                      blurRadius: 4.wMin,
                                      color: const Color(0x1A000000),
                                      offset: Offset(0, 2.wMin))
                                ],
                                color: AppTheme.cInverseTextLight.color)),
                        Text(
                          getGrene(item.themeName?.gloss ?? [], 'en',
                              ignore: true),
                          style: TextStyle(
                              fontSize: 22.wMin,
                              color: AppTheme.cInverseTextLight.color
                                  .withAlpha(205)),
                        ),
                        SizedBox(height: 4.wMin),
                        Container(
                          width: 374.wMin,
                          child: Text(
                            getGrene(item.depiction ?? [], 'zh'),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 18.wMin,
                                color: AppTheme.cInverseTextLight.color
                                    .withAlpha(205)),
                          ),
                        )
                      ])),
            ]),
            SizedBox(height: 16.wMin),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.wMin),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: AppTheme.cSurfaceTertiary.color,
                  borderRadius: BorderRadius.circular(8.wMin),
                ),
                child: item.title == null
                    ? Padding(
                        padding: EdgeInsets.only(left: 4.wMin),
                        child: Text('暂无最新文章',
                            style: TextStyle(
                                color: AppTheme.cTextSecondary.color,
                                fontSize: 22.wMin)),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SvgPicture.asset(
                            'assets/svg/elements/icon_total_article.svg',
                            width: 24.wMin,
                            height: 24.wMin,
                            color: AppTheme.cTextPrimary.color,
                          ),
                          SizedBox(width: 4.wMin),
                          Expanded(
                            child: Text(
                              '${item.title}',
                              maxLines: 1,
                              style: TextStyle(
                                  color: AppTheme.cTextSecondary.color,
                                  fontSize: 22.wMin),
                            ),
                          )
                        ],
                      ),
              ),
            ),
            SizedBox(height: 16.wMin),
            Row(
              children: [
                Text(
                  '${item.count ?? 0}篇',
                  style: TextStyle(
                      color: AppTheme.cTextTertiary.color, fontSize: 18.wMin),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    if (item.isSubscribe ?? false) {
                      cancelSub(item);
                    } else {
                      subScribe(item);
                    }
                  },
                  child: Container(
                    width: 180.wMin,
                    height: 56.wMin,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: item.isSubscribe!
                            ? AppTheme.cFeedbackSuccessBackground.color
                            : AppTheme.cSurfaceTertiary.color,
                        borderRadius: BorderRadius.circular(8.wMin)),
                    child: Text(
                      item.isSubscribe! ? '已订阅' : '订阅',
                      style: TextStyle(
                          color: item.isSubscribe!
                              ? AppTheme.cFeedbackSuccessText.color
                              : AppTheme.cTextBrand.color,
                          fontSize: 24.wMin,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                )
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.start,
                //   children: [
                //     SvgPicture.asset(
                //       'assets/svg/elements/icon_timepass.svg',
                //       width: 24.wMin,
                //       height: 24.wMin,
                //     ),
                //     SizedBox(width: 4.wMin),
                //     Text(
                //       '几天前',
                //       style: TextStyle(color: Color(0xFFACB5BC), fontSize: 16.wMin),
                //     )
                //   ],
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Obx(() {
      final Map<String, FilterSortsData> sorts = _buildFilterSorts();
      final Map<String, FilterConditionsData> conditions = _buildFilterConditions();
      final Map<String, FilterSearchsData> searchs = _buildFilterSearchs();
      return FilterStripWidget(
        width: MediaQuery.of(context).size.width - 32.wMin,
        sorts: sorts,
        conditions: conditions,
        searchs: searchs,
        onSorts: (sorts) {
          final (String groupCode, String value) =
              _resolveSelectedSortSelection(sorts);
          if (groupCode.isEmpty || value.isEmpty) return;
          controller.applyContentSortSelection(groupCode: groupCode, value: value);
        },
        onConditions: (conditions) {
          final bool shouldExit = _shouldExitByTopicConditions(conditions);
          if (shouldExit) {
            controller.exitCollection();
            return;
          }
          controller.applyContentConditionSelections(
            _resolveSelectedConditions(conditions),
          );
        },
        onSearch: controller.submitContentSearch,
        onReset: (_, __) {
          controller.resetContentFilters();
        },
      );
    });
  }

  Map<String, FilterSortsData> _buildFilterSorts() {
    final Map<String, FilterSortsData> resp = <String, FilterSortsData>{};
    for (final ZhenduScriptQueryMetaGroupEntity group
        in controller.contentOrderGroups) {
      final String groupCode = (group.groupCode ?? '').trim();
      if (groupCode.isEmpty || group.items.isEmpty) continue;
      resp[groupCode] = FilterSortsData(
        title: group.groupName ?? groupCode,
        sorts: group.items
            .map(
              (item) => FilterSortsItem(
                name: item.name ?? (item.value ?? ''),
                selected: controller.isContentSortSelected(
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
        in controller.contentFilterGroups) {
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
                selected: controller.isContentFilterSelected(
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
      'title': FilterSearchsData(
        controller: controller.contentSearchController,
        title: '搜索',
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

  bool _shouldExitByTopicConditions(
    Map<String, FilterConditionsData> conditions,
  ) {
    final FilterConditionsData? topic = conditions['theme'];
    if (topic == null) return false;
    final bool selected = topic.conditions.any((e) => e.selected);
    return !selected;
  }

  void cancelSub(UserRevealCollectionEntity entity) {
    UnSubScribeDialog.show(
            Get.context!,
            entity.collectionId!,
            getGrene(entity.themeName?.gloss ?? [], 'zh'),
            tagText: tagText)
        .then((res) {
      if (res == 'DELETED') {
        //todo:改成订阅
        entity.isSubscribe = false;
        controller.reveals.refresh();
      }
    });
  }

  void subScribe(UserRevealCollectionEntity entity) {
    SubScribeDialog.show(Get.context!, entity, tagText: tagText)
        .then((res) {
      if (res == 'NORMAL') {
        //todo:改变已订阅
        entity.isSubscribe = true;
        // 触发界面更新
        controller.reveals.refresh();
      }
    });
  }

  String getGrene(List<ManageSubscribeNameItem> item, String condition,
      {bool ignore = false}) {
    var systemCondition = LangPreference.fromRawValue(UserStore
                .to.userInfo.value.config?.extensionConfig!.translationType ??
            '')
        .langCode;
    if (systemCondition.isNotEmpty && !ignore) {
      condition = systemCondition;
    }
    for (var glossItem in item) {
      if (glossItem.lang == condition) {
        return glossItem.text!;
      }
    }
    return '';
  }

  double getTextWidth(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr, // 必须指定方向
    )..layout(); // 先 layout 才能拿到 size
    var mWidth = textPainter.size.width;
    return mWidth;
  }
}
