import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/mission_control_center/controllers/mission_control_center_controller.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/https/https.dart';
import '../../../../common/public_controller/config_controller.dart';
import '../../application/common/nav_buttons_widget.dart';
import '../common/elements_card_box_widget.dart';
import '../common/elements_cards/elements_public_card.dart';
import '../../elements/dictionary/controllers/dictionary_controller.dart';
import '../../home/controllers/home_controller.dart';

/// 集卡结果
class ElementsCollectResultDialog {
  static const int _pageSize = 10;

  /// 检查是否有新卡
  /// [isCollectCard] 是否是获取新卡片
  static Future<bool> checkNewCard({
    required BuildContext context,
    bool isCollectCard = true,
  }) async {
    List<KnowledgeCommonEntityList>? list;
    Map<String, dynamic>? requestParameters;
    try {
      ToastUtils.showLoading();
      if (isCollectCard) {
        ConfigController configController = Get.find<ConfigController>();
        requestParameters = {
          "style": Uri.encodeComponent(configController.currentShowStyleCode.value),
          "mediaMode": configController.currentShowResource.value == ResourceTypeEnum.image ? 0 : 1,
        };
        list = await ElementsRequest.getUpdateCardList(parameters: {
          ...requestParameters,
          "offset": 0,
          "limit": _pageSize,
        });
      }

      if (list == null || list.isEmpty) {
        final missionController = TagRoutes.findLast<MissionControlCenterController>(Routes.MISSION_CONTROL_CENTER);
        if (missionController != null) {
          missionController.refreshMissionListOnly(showLoading: false, scrollToCurrent: false);
        }
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().initHomeCardList();
        }
        // if (Get.isRegistered<HomeController>()) {
        //   Get.find<HomeController>().initHomeCardList();
        // }
        return false;
      }
    } finally {
      ToastUtils.hideLoading();
    }
    if (!context.mounted) return false;
    await show(
      context: context,
      datas: list,
      requestParameters: requestParameters,
    );
    return true;
  }

  static Future<void> show({
    required BuildContext context,
    required List<KnowledgeCommonEntityList> datas,
    Map<String, dynamic>? requestParameters,
  }) async {
    await showCupertinoDialog(
      context: context,
      builder: (context) {
        return ElementsCollectResultDialogWidget(
          datas: datas,
          requestParameters: requestParameters,
          pageSize: _pageSize,
        );
      },
    );
  }
}

class ElementsCollectResultDialogWidget extends StatefulWidget {
  final List<KnowledgeCommonEntityList> datas;
  final Map<String, dynamic>? requestParameters;
  final int pageSize;
  const ElementsCollectResultDialogWidget({
    super.key,
    required this.datas,
    this.requestParameters,
    required this.pageSize,
  });

  @override
  State<ElementsCollectResultDialogWidget> createState() => _ElementsCollectResultDialogWidgetState();
}

class _ElementsCollectResultDialogWidgetState extends State<ElementsCollectResultDialogWidget> with TickerProviderStateMixin {
  final GlobalKey _cardBooksKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  UserStore userStore = UserStore.to;

  /// 显示收集动画
  bool _showCollectAnimation = false;

  /// 列表是否显示完成
  bool _isListShowCompleted = false;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  bool _hasReportedRead = false;

  List<KnowledgeCommonEntityList> datas = [];
  List<_CardAnimDataModel> cardpileDatas = [];

  @override
  void initState() {
    super.initState();
    initCardList();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      runListAnimation();
    });
  }

  void initCardList() {
    datas.addAll(widget.datas);
    _hasMore = widget.requestParameters != null && widget.datas.length >= widget.pageSize;
    _rebuildCardpileDatas();
  }

  /// 运行列表动画
  Future<void> runListAnimation() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    _isListShowCompleted = true;
    if (mounted) setState(() {});
  }

  /// 运行集卡动画
  Future<void> runCollectAnimation() async {
    _rebuildCardpileDatas();
    _showCollectAnimation = true;
    if (mounted) setState(() {});

    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    RenderBox? stackBox = context.findRenderObject() as RenderBox?;
    if (stackBox == null) return;
    Size stackSize = stackBox.size;

    // 获取目标位置（导航栏图标）
    RenderBox? targetBox = _cardBooksKey.currentContext?.findRenderObject() as RenderBox?;
    if (targetBox == null) return;

    Size targetSize = targetBox.size;
    Offset end = stackBox.globalToLocal(targetBox.localToGlobal(Offset.zero));
    end = end - Offset((stackSize.width - targetSize.width) / 2, 100.wMin);
    // 纵向对齐到图标中心，避免以左上角导致位置偏差
    end = end + Offset(0, targetSize.height / 2);

    for (int i = cardpileDatas.length - 1; i >= 0; i--) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) break;
      GlobalKey key = cardpileDatas[i].key;
      RenderBox? box = key.currentContext?.findRenderObject() as RenderBox?;
      if (box == null) continue;
      Size boxSize = box.size;
      // 开始位置就是当前卡片的offset位置
      Offset begin = cardpileDatas[i].offset;
      Offset offset = end - Offset(0, boxSize.height / 2);

      toOffset(
        begin: begin,
        end: offset,
        onUpdate: (offset, value) {
          cardpileDatas[i].scale = 1.0 - value * 0.95; // 缩放到0.2而不是0
          cardpileDatas[i].offset = offset;
          if (mounted) setState(() {});
        },
        onCompleted: () {
          cardpileDatas.removeAt(i);
          if (mounted) setState(() {});
          if (cardpileDatas.isEmpty) {
            Future.delayed(const Duration(milliseconds: 500), () async {
              Get.back(result: true);
            });
          }
        },
      );
    }
  }

  Future<void> reportLoadedCards() async {
    if (_hasReportedRead || datas.isEmpty) return;
    try {
      List<Map<String, dynamic>> reqData = [];
      for (int i = 0; i < datas.length; i++) {
        reqData.add({
          "type": datas[i].contentType,
          "uid": datas[i].contentId,
        });
      }
      await ElementsRequest.cuCardAlready(reqData);
      _hasReportedRead = true;
      final missionController = TagRoutes.findLast<MissionControlCenterController>(Routes.MISSION_CONTROL_CENTER);
      await missionController?.refreshMissionListOnly(showLoading: false, scrollToCurrent: false);

      if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().initHomeCardList();
      }
      final DictionaryController? dictionaryController = DictionaryController.registered;
      if (dictionaryController != null) {
        await dictionaryController.refreshList(showLoading: false);
      }
    } catch (_) {}
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || widget.requestParameters == null) return;
    _isLoadingMore = true;
    if (mounted) setState(() {});
    try {
      final List<KnowledgeCommonEntityList>? list = await ElementsRequest.getUpdateCardList(parameters: {
        ...widget.requestParameters!,
        "offset": datas.length,
        "limit": widget.pageSize,
      });
      if (list == null || list.isEmpty) {
        _hasMore = false;
      } else {
        datas.addAll(list);
        _hasMore = list.length >= widget.pageSize;
      }
    } finally {
      _isLoadingMore = false;
      if (mounted) setState(() {});
    }
  }

  void _rebuildCardpileDatas() {
    cardpileDatas = [];
    final List<KnowledgeCommonEntityList> temp = datas.length > 10 ? datas.sublist(0, 10) : datas;
    for (int i = 0; i < temp.length; i++) {
      cardpileDatas.add(_CardAnimDataModel(
        key: GlobalKey(),
        offset: Offset(-(i * 10.wMin), i * (15.wMin)),
      ));
    }
  }

  Future<void> handleContinueTap() async {
    if (!_isListShowCompleted) return;
    await reportLoadedCards();
    if (!mounted) return;
    await runCollectAnimation();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void toOffset({
    required Offset begin,
    required Offset end,
    int milliseconds = 200,
    Curve curve = Curves.linear,
    void Function(Offset, double)? onUpdate,
    void Function()? onCompleted,
  }) {
    final AnimationController matchController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: milliseconds),
    );

    final Animation<Offset> animation = Tween<Offset>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: matchController,
      curve: curve,
    ));

    matchController.addListener(() {
      onUpdate?.call(animation.value, matchController.value);
    });

    matchController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        matchController.dispose();
        onCompleted?.call();
      }
    });
    matchController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppTheme.cOverlayBackground.color,
        extendBody: true,
        body: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _showCollectAnimation ? _buildCardpileWidget() : _buildCardListWidget(),
          ),
        ),
        bottomNavigationBar: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _showCollectAnimation ? _buildNavWidget() : _buildButtonWidget(),
        ),
      ),
    );
  }

  /// 卡堆
  Widget _buildCardpileWidget() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      padding: EdgeInsets.only(top: 100.wMin),
      child: Stack(
        alignment: Alignment.topCenter,
        children: List.generate(cardpileDatas.length, (index) {
          return Transform.translate(
            offset: cardpileDatas[index].offset,
            child: Transform.scale(
              scale: cardpileDatas[index].scale,
              child: SizedBox(
                height: 520.wMin,
                child: AspectRatio(
                  aspectRatio: 325.82 / 520.00,
                  child: ElementsCardBackWidget(
                    key: cardpileDatas[index].key,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNavWidget() {
    return Container(
      key: const ValueKey(true),
      child: GestureDetector(
        onTap: () {
          // runCollectAnimation();
        },
        child: NavButtonsWidget(
          disableButton: true,
          // 关键修复：将GlobalKey绑定到“要素”图标，而不是整个Nav容器
          cardsKey: _cardBooksKey,
          opactiyButton: true,
        ),
      ),
    );
  }

  Widget _buildCardListWidget() {
    return IgnorePointer(
      ignoring: !_isListShowCompleted,
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification is ScrollUpdateNotification &&
              notification.metrics.pixels >= notification.metrics.maxScrollExtent - 600.wMin) {
            loadMore();
          }
          return false;
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.only(
            left: 40.wMin,
            right: 40.wMin,
            top: MediaQuery.of(context).padding.top + 100.wMin,
            bottom: MediaQuery.of(context).padding.bottom + 200.wMin,
          ),
          child: Column(
            children: [
              Wrap(
                spacing: 16.wMin,
                runSpacing: 16.wMin,
                alignment: WrapAlignment.start,
                runAlignment: WrapAlignment.center,
                children: List.generate(datas.length, (index) {
                  return _buildCardWidget(index, datas[index]);
                }),
              ),
              if (_isLoadingMore)
                Padding(
                  padding: EdgeInsets.only(top: 24.wMin),
                  child: const CupertinoActivityIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardWidget(int index, KnowledgeCommonEntityList data) {
    final bool showCardStarArea = data.memberStudy?.starInfo != null;
    return SizedBox(
      height: (showCardStarArea ? 567 : 546).wMin,
      child: AspectRatio(
        aspectRatio: showCardStarArea ? 346 / 567 : 346 / 546,
        child: ListAnimationWidget(
          index: index,
          delay: const Duration(milliseconds: 50),
          duration: const Duration(milliseconds: 200),
          verticalOffset: 400.wMin,
          child: ElementsDictReadCard(
            data: data,
            showCardStarArea: showCardStarArea,
          ),
        ),
      ),
    );
  }

  Widget _buildButtonWidget() {
    return Container(
      key: const ValueKey(false),
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(top: 10.wMin),
      height: (Platform.isIOS || Platform.isAndroid ? 150.wMin : 170.wMin) + MediaQuery.of(context).padding.bottom,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _isListShowCompleted ? 1.0 : 0.0,
        child: ButtonWidget(
          text: "继续",
          color: AppTheme.cBgBrand,
          width: 720.wMin,
          height: 64.wMin,
          fontSize: 28.wMin,
          fontColor: AppTheme.cStaticWhite,
          fontWeight: FontWeight.w500,
          borderRadius: 12.wMin,
          sclae: 1.01,
          onTap: OptimizeUtils.noneThrottle(() {
            handleContinueTap();
          }, 1000),
        ),
      ),
    );
  }
}

class _CardAnimDataModel {
  Offset offset;
  double scale = 1.0;
  GlobalKey key;

  _CardAnimDataModel({
    required this.key,
    this.offset = Offset.zero,
  });
}
