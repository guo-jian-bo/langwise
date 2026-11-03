import 'dart:io';
import 'package:flip_card/flip_card.dart';
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
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/https/https.dart';
import '../../application/common/nav_buttons_widget.dart';
import '../../elements/dictionary/controllers/dictionary_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../common/elements_cards/elements_type_card_widget.dart';
import '../../../../common/enum/elements_card_type.dart';
import '../model/elements_detils_data_model.dart';

/// 集卡结果
class ElementsCollectResultDialog {
  /// 检查是否有新卡
  /// [isCollectCard] 是否是获取新卡片
  static Future<bool> checkNewCard({
    required BuildContext context,
    bool isCollectCard = true,
  }) async {
    List<ElementsCardEntityDatas>? list;
    try {
      ToastUtils.showLoading();
      if (isCollectCard) {
        list = await ElementsRequest.getUpdateCardList();
      }

      if (list == null || list.isEmpty) {
        final missionController = TagRoutes.findLast<MissionControlCenterController>(Routes.MISSION_CONTROL_CENTER);
        if (missionController != null) {
          missionController.refreshMissionListOnly(showLoading: false, scrollToCurrent: false);
        }
        // if (Get.isRegistered<HomeController>()) {
        //   Get.find<HomeController>().initHomeCardList();
        // }
        return false;
      }
    } finally {
      ToastUtils.hideLoading();
    }
    await show(context: context, datas: list);
    return true;
  }

  static Future<void> show({
    required BuildContext context,
    required List<ElementsCardEntityDatas> datas,
  }) async {
    await showCupertinoDialog(
      context: context,
      builder: (context) {
        return ElementsCollectResultDialogWidget(datas: datas);
      },
    );
  }
}

class ElementsCollectResultDialogWidget extends StatefulWidget {
  final List<ElementsCardEntityDatas> datas;
  const ElementsCollectResultDialogWidget({super.key, required this.datas});

  @override
  State<ElementsCollectResultDialogWidget> createState() => _ElementsCollectResultDialogWidgetState();
}

class _ElementsCollectResultDialogWidgetState extends State<ElementsCollectResultDialogWidget> with TickerProviderStateMixin {
  final GlobalKey _cardBooksKey = GlobalKey();

  UserStore userStore = UserStore.to;

  /// 显示收集动画
  bool _showCollectAnimation = false;

  /// 列表是否显示完成
  bool _isListShowCompleted = false;

  List<ElementsDetilsDataModel> datas = [];
  List<_CardAnimDataModel> cardpileDatas = [];

  @override
  void initState() {
    super.initState();
    getCardList();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      runListAnimation();
    });
  }

  Future<void> getCardList() async {
    for (int i = 0; i < widget.datas.length; i++) {
      datas.add(ElementsDetilsDataModel(
        type: ElementsCardType.fromRawValue(widget.datas[i].contentType ?? ""),
        data: widget.datas[i],
      ));
    }

    List<ElementsDetilsDataModel> temp = datas.length > 10 ? datas.sublist(0, 10) : datas;

    for (int i = 0; i < temp.length; i++) {
      cardpileDatas.add(_CardAnimDataModel(
        key: GlobalKey(),
        data: temp[i],
        offset: Offset(-(i * 10.wMin), i * (15.wMin)),
      ));
    }

    readCard();
  }

  /// 运行列表动画
  Future<void> runListAnimation() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    _isListShowCompleted = true;
    if (mounted) setState(() {});
  }

  /// 运行集卡动画
  Future<void> runCollectAnimation() async {
    _showCollectAnimation = true;
    if (mounted) setState(() {});

    await Future.delayed(const Duration(milliseconds: 1000));

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

  Future<void> readCard() async {
    try {
      List<Map<String, dynamic>> reqData = [];
      for (int i = 0; i < widget.datas.length; i++) {
        reqData.add({
          "type": widget.datas[i].contentType,
          "uid": widget.datas[i].contentId,
        });
      }
      await ElementsRequest.cuCardAlready(reqData);
      final missionController = TagRoutes.findLast<MissionControlCenterController>(Routes.MISSION_CONTROL_CENTER);
      await missionController?.refreshMissionListOnly(showLoading: false, scrollToCurrent: false);

    } catch (_) {}
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
      child: PlatformBackdropFilterWidget(
        sigmaX: 5.wMin,
        sigmaY: 5.wMin,
        child: Scaffold(
          backgroundColor: AppTheme.cOverlayBackground.color.withValues(alpha: 0.1),
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
              child: ElementsTypeCardWidget(
                key: cardpileDatas[index].key,
                side: CardSide.BACK,
                disableTap: true,
                data: cardpileDatas[index].data,
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
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 40.wMin,
          right: 40.wMin,
          top: MediaQuery.of(context).padding.top + 100.wMin,
          bottom: MediaQuery.of(context).padding.bottom + 200.wMin,
        ),
        child: Wrap(
          spacing: 16.wMin,
          runSpacing: 16.wMin,
          alignment: WrapAlignment.start,
          runAlignment: WrapAlignment.center,
          children: List.generate(datas.length, (index) {
            return _buildCardWidget(index, datas[index]);
          }),
        ),
      ),
    );
  }

  Widget _buildCardWidget(int index, ElementsDetilsDataModel data) {
    return SizedBox(
      height: 520.wMin,
      child: AspectRatio(
        aspectRatio: 325.82 / 520.00,
        child: ListAnimationWidget(
          index: index,
          delay: const Duration(milliseconds: 50),
          duration: const Duration(milliseconds: 200),
          verticalOffset: 400.wMin,
          child: ElementsTypeCardWidget(
            disableTap: true,
            data: data,
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
          onTap: () {
            if (!_isListShowCompleted) return;
            runCollectAnimation();
          },
        ),
      ),
    );
  }
}

class _CardAnimDataModel {
  Offset offset;
  double scale = 1.0;
  GlobalKey key;
  ElementsDetilsDataModel data;

  _CardAnimDataModel({
    required this.key,
    required this.data,
    this.offset = Offset.zero,
  });
}
