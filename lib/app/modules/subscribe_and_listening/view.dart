import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/subscribe_and_listening/sub_history_dialog.dart';
import 'package:langwise/app/modules/subscribe_and_listening/subscribe_dialog.dart';
import 'package:langwise/app/modules/subscribe_and_listening/unsubscribe_dialog.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/lock_utils.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:video_player/video_player.dart';
import '../../../common/widgets/widgets.dart';
import 'controller.dart';

class SubListenPage extends GetView<SubListenController> {
  SubListenPage({super.key});

  /// 顶部主题每个 item 的 GlobalKey，仅在当前页面内部使用
  final List<GlobalKey> _tabKeys = [];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // 根据主题数量同步当前页面持有的 GlobalKey 列表长度
      if (_tabKeys.length != controller.themes.length) {
        _tabKeys
          ..clear()
          ..addAll(List.generate(controller.themes.length, (_) => GlobalKey()));
      }

      return LockOverlayWidget(
          rights: controller.rights.value,
          showBack: false,
          child: Scaffold(
              backgroundColor: AppTheme.cSurfacePrimary.color,
              body: Column(
                children: [
                  SizedBox(height: 24.wMin),
                  SizedBox(
                    height: 54.wMin,
                    width: double.infinity,
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      SizedBox(width: 70.wMin),
                      Expanded(
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: false,
                              itemCount: controller.themes.length,
                              itemBuilder: (ctx, idx) {
                                final key = _tabKeys[idx];
                                return GestureDetector(
                                  onTap: () {
                                    if (controller.selectedIndex.value != idx) {
                                      controller.selectedIndex.value = idx;
                                      if (idx == 0) {
                                        controller.genre.value = '';
                                      } else {
                                        controller.genre.value = getGrene(controller.themes[idx].name ?? [], 'en', ignore: true);
                                      }
                                      controller.refreshUserRevealsPage();

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
                                    }
                                  },
                                  child: Container(
                                    key: key,
                                    margin: EdgeInsets.only(right: 40.wMin),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(height: 6.wMin),
                                        Text(
                                          getGrene(controller.themes[idx].name ?? [], 'zh'),
                                          style: TextStyle(
                                            fontSize: 28.wMin,
                                            fontWeight: FontWeight.w500,
                                            color: AppTheme.cTextPrimary.color,
                                          ),
                                        ),
                                        SizedBox(height: 2.wMin),
                                        AnimatedContainer(
                                          height: 4.wMin,
                                          width:
                                              getTextWidth(getGrene(controller.themes[idx].name ?? [], 'zh'), TextStyle(fontSize: 28.wMin, fontWeight: FontWeight.w500)) - 56.wMin,
                                          color: controller.selectedIndex.value == idx ? AppTheme.cBorderBrand.color : Colors.transparent,
                                          duration: const Duration(milliseconds: 200),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              })),
                      // Expanded(
                      //     child: ListView(
                      //         shrinkWrap: false,
                      //         scrollDirection: Axis.horizontal,
                      //         children: List.generate(controller.themes.length, (e) {
                      //           return buildTabWidget(e);
                      //         }).toList())),
                      SizedBox(width: 280.wMin),
                      // ElementsCardSearchWidget(
                      //   controller: controller.searchInput,
                      //   hintText: '搜索主题',
                      //   onSearch: (value) {
                      //     controller.searchCard(value);
                      //   },
                      //   onTap: () {
                      //     if (controller.isSearchClick.value) return;
                      //     controller.isSearchClick.value = true;
                      //     Future.delayed(const Duration(milliseconds: 350), () {
                      //       controller.isSearchClick.value = false;
                      //     });
                      //   },
                      // ),
                      Row(children: [
                        _appBarBtn(),
                        SizedBox(width: 24.wMin),
                        GestureDetector(
                          onTap: () {
                            _showSubHistoryDialog(context);
                          },
                          child: Container(
                            height: 52.wMin,
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(horizontal: 24.wMin),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.wMin), color: Colors.transparent, border: Border.all(color: Color(0xFF5B6167))),
                            child: Text('历史记录', style: TextStyle(fontSize: 24.wMin, color: AppTheme.cTextPrimary.color, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        SizedBox(width: 24.wMin),
                        GestureDetector(
                          onTap: () {
                            _showSubManageDialog(context);
                          },
                          child: Container(
                            height: 52.wMin,
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(horizontal: 24.wMin),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.wMin), color: AppTheme.cSurfaceInfo.color),
                            child: Text('订阅管理', style: TextStyle(fontSize: 24.wMin, color: AppTheme.cInverseTextLight.color, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        SizedBox(width: 70.wMin),
                      ]),
                    ]),
                  ),
                  SizedBox(height: 24.wMin),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      padding: EdgeInsets.only(top: 40.wMin),
                      decoration: BoxDecoration(color: AppTheme.cBgPrimary.color, borderRadius: BorderRadius.vertical(top: Radius.circular(40.wMin))),
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Align(
                            child: RefreshIndicator(
                              onRefresh: controller.refreshUserRevealsPage,
                              child: NotificationListener<ScrollNotification>(
                                  onNotification: (ScrollNotification notification) {
                                    if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 100 && notification is ScrollEndNotification) {
                                      // 底部加载更多，暂时复用同一个请求方法
                                      controller.getUserRevealsPage();
                                    }
                                    return false;
                                  },
                                  child: GridView.builder(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    padding: EdgeInsets.fromLTRB(70.wMin, 20.wMin, 70.wMin, 150.wMin + MediaQuery.of(context).padding.bottom),
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                      mainAxisSpacing: 32.wMin,
                                      crossAxisSpacing: 32.wMin,
                                      childAspectRatio: 426 / 560,
                                    ),
                                    itemCount: controller.reveals.length,
                                    itemBuilder: (context, index) {
                                      var item = controller.reveals[index];
                                      return _cardItem(item);
                                    },
                                  )
                                  // child: SingleChildScrollView(
                                  //   physics: const AlwaysScrollableScrollPhysics(),
                                  //   child: Container(
                                  //     padding: EdgeInsets.only(left: 32.wMin,right: 32.wMin, top: 0.wMin, bottom: 180.wMin),
                                  //     child: Wrap(
                                  //         spacing: 32.wMin,
                                  //         runSpacing: 32.wMin,
                                  //         children: List.generate(controller.reveals.length, (index) {
                                  //           var item = controller.reveals[index];
                                  //           return _cardItem(item);
                                  //         }).toList()),
                                  //   ),
                                  // ),
                                  ),
                            ),
                          ),
                          // Positioned(bottom: 150.wMin, child: _searchBar()),
                        ],
                      ),
                    ),
                  ),
                ],
              )));
    });
  }

  //右上角历史记录弹窗
  void _showSubHistoryDialog(BuildContext context) {
    controller.loadUserRevealPushRecord().then((_) {
      SubHistoryDialog.show(context);
    });
  }

  //右上角订阅管理弹窗
  void _showSubManageDialog(BuildContext context) {
    controller.getUserSubscribeConfig();
  }

  Widget _appBarBtn() {
    return Container(
        height: 52.wMin,
        padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 4.wMin),
        decoration: BoxDecoration(
            // borderRadius: BorderRadius.circular(8.wMin),
            // color: AppTheme.cFeedbackWarningBackground,
            ),
        child: Row(children: [
          SvgPicture.asset("assets/svg/elements/icon_money.svg", height: 28.wMin, width: 28.wMin),
          SizedBox(width: 8.wMin),
          Text(
            '${UserStore.to.userInfo.value.points ?? 0}学点',
            style: TextStyle(fontSize: 18.wMin, color: AppTheme.cFeedbackWarningText.color),
          )
        ]));
  }

  Widget _cardItem(UserRevealCollectionEntity item) {
    return GestureDetector(
      onTap: () {
        if (item.collectionId != null) {
          TagRoutes.toNamed(
            Routes.APP_SUBSCRIBE_LISTENING_DETAILS,
            arguments: {
              'collectionId': item.collectionId,
              'title': getGrene(item.themeName?.gloss ?? [], 'zh'),
              'description': getGrene(item.depiction ?? [], 'zh'),
            },
          );
        }
      },
      child: Container(
        width: 426.wMin,
        height: 560.wMin,
        padding: EdgeInsets.all(16.wMin),
        decoration:
            BoxDecoration(color: AppTheme.cSurfaceSecondary.color, border: Border.all(color: AppTheme.cBorderSecondary.color), borderRadius: BorderRadius.circular(16.wMin)),
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
                    gradient:
                        LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, stops: [0.6, 1], colors: [Color(0x00000000), Color(0xFF000000).withOpacity(0.7)]),
                  ),
                ),
              ),
              Positioned(
                  left: 10.wMin,
                  top: 10.wMin,
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.wMin), color: Color(0xFF131617).withAlpha(64), backgroundBlendMode: BlendMode.overlay),
                    child: Text(getGrene(item.genreName?.gloss ?? [], 'zh'),
                        style: TextStyle(
                            fontSize: 22.wMin,
                            fontWeight: FontWeight.w600,
                            shadows: [Shadow(blurRadius: 4.wMin, color: const Color(0x1A000000), offset: Offset(0, 2.wMin))],
                            color: Colors.white)),
                  )),
              if (item.isNewContent ?? false)
                Positioned(
                    right: 10.wMin,
                    top: 10.wMin,
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.wMin), color: AppTheme.cSurfaceError),
                      child: Text('new', style: TextStyle(fontSize: 22.wMin, fontWeight: FontWeight.w600, color: AppTheme.cInverseTextLight.color)),
                    )),
              Positioned(
                  bottom: 12.wMin,
                  left: 10.wMin,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(getGrene(item.themeName?.gloss ?? [], 'zh', ignore: true),
                        style: TextStyle(
                            fontSize: 40.wMin,
                            shadows: [Shadow(blurRadius: 4.wMin, color: const Color(0x1A000000), offset: Offset(0, 2.wMin))],
                            color: AppTheme.cInverseTextLight.color)),
                    Text(
                      getGrene(item.themeName?.gloss ?? [], 'en', ignore: true),
                      style: TextStyle(fontSize: 22.wMin, color: AppTheme.cInverseTextLight.color.withAlpha(205)),
                    ),
                    SizedBox(height: 4.wMin),
                    Container(
                      width: 374.wMin,
                      child: Text(
                        getGrene(item.depiction ?? [], 'zh'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 18.wMin, color: AppTheme.cInverseTextLight.color.withAlpha(205)),
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
                        child: Text('暂无最新文章', style: TextStyle(color: AppTheme.cTextSecondary.color, fontSize: 22.wMin)),
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
                              style: TextStyle(color: AppTheme.cTextSecondary.color, fontSize: 22.wMin),
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
                  style: TextStyle(color: AppTheme.cTextTertiary.color, fontSize: 18.wMin),
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
                        color: item.isSubscribe! ? AppTheme.cFeedbackSuccessBackground.color : AppTheme.cSurfaceTertiary.color, borderRadius: BorderRadius.circular(99.wMin)),
                    child: Text(
                      item.isSubscribe! ? '已订阅' : '订阅',
                      style: TextStyle(color: item.isSubscribe! ? AppTheme.cFeedbackSuccessText.color : AppTheme.cTextBrand.color, fontSize: 24.wMin, fontWeight: FontWeight.w600),
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

  void cancelSub(UserRevealCollectionEntity entity) {
    UnSubScribeDialog.show(Get.context!, entity.collectionId!, getGrene(entity.themeName?.gloss ?? [], 'zh')).then((res) {
      if (res == 'DELETED') {
        //todo:改成订阅
        entity.isSubscribe = false;
        controller.reveals.refresh();
      }
    });
  }

  void subScribe(UserRevealCollectionEntity entity) {
    SubScribeDialog.show(Get.context!, entity).then((res) {
      if (res == 'NORMAL') {
        //todo:改变已订阅
        entity.isSubscribe = true;
        // 触发界面更新
        controller.reveals.refresh();
      }
    });
  }

  String getGrene(List<ManageSubscribeNameItem> item, String condition, {bool ignore = false}) {
    var systemCondition = LangPreference.fromRawValue(UserStore.to.userInfo.value.config?.extensionConfig!.translationType ?? '').langCode;
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
