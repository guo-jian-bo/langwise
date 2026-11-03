import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/subscribe_and_listening/controller.dart';
import 'package:langwise/common/entities/manage_subscribe_entity.dart';
import 'package:langwise/common/entities/theme_style_entity.dart';
import 'package:langwise/common/entities/user_reveals_entity.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/utils/style_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:video_player/video_player.dart';
import '../../../../theme/theme.dart';

class SubScribeDialog {
  static Future<String> show(
    BuildContext context,
    UserRevealCollectionEntity entity, {
    required String tagText,
  }) async {
    String? res = await showCupertinoDialog<String?>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return SubscribeDialogWidget(entity: entity, tagText: tagText);
      },
    );
    return res ?? '';
  }
}

class SubscribeDialogWidget extends StatefulWidget {
  const SubscribeDialogWidget({
    super.key,
    required this.entity,
    required this.tagText,
  });

  final UserRevealCollectionEntity entity;
  final String tagText;

  @override
  State<SubscribeDialogWidget> createState() => _SubscribeDialogWidgetState();
}

class _SubscribeDialogWidgetState extends State<SubscribeDialogWidget> {
  late ThemeTextStyleEntity? themeText;

  SubListenController get _controller =>
      Get.find<SubListenController>(tag: widget.tagText);

  @override
  void initState() {
    super.initState();
    themeText = StyleUtils.getCurrentThemeText(widget.entity.txtStyle);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        color: AppTheme.cOverlayBackground,
        child: Center(
            child: ClipRRect(
          borderRadius: BorderRadius.circular(24.wMin),
          child: Container(
            width: 720.wMin,
            decoration: BoxDecoration(
              color: AppTheme.cSurfaceSecondary.color,
              border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceSecondary.color, strokeAlign: BorderSide.strokeAlignOutside),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [_header(), _body(), _bottomBtn(), SizedBox(height: 48.wMin)]),
          ),
        )));
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(image: DecorationImage(image: NetworkImage(widget.entity.taskAvatarUrl ?? ''), fit: BoxFit.cover)),
      padding: EdgeInsets.only(left: 40.wMin),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        SizedBox(height: 24.wMin),
        Container(
            padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.wMin), color: Color(0xFF131617).withAlpha(64), backgroundBlendMode: BlendMode.overlay),
            child: Text(getGrene(widget.entity.genreName?.gloss ?? [], 'zh'),
                style: TextStyle(fontSize: 22.wMin, shadows: [Shadow(blurRadius: 4.wMin, color: const Color(0x1A000000), offset: Offset(0, 2.wMin))], color: Colors.white))),
        SizedBox(height: 16.wMin),
        Text(widget.entity.themeName?.gloss?.firstWhere((g) => g.lang == 'zh', orElse: () => ManageSubscribeNameItem(lang: 'zh', text: '')).text ?? "环球视野",
            style: TextStyle(fontSize: 48.wMin, fontWeight: FontWeight.w600, color: AppTheme.cInverseTextLight.color)),
        Text(widget.entity.themeName?.gloss?.firstWhere((g) => g.lang == 'en', orElse: () => ManageSubscribeNameItem(lang: 'en', text: '')).text ?? "Global View",
            style: TextStyle(fontSize: 22.wMin, color: AppTheme.cInverseTextLight.color.withAlpha(205))),
        SizedBox(height: 16.wMin),
        Container(
            padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 4.wMin),
            decoration: BoxDecoration(
              color: AppTheme.cTextPrimary.color.withAlpha(25),
              borderRadius: BorderRadius.circular(4.wMin),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset('assets/svg/elements/icon_total_article.svg',
                    color: AppTheme.cTextPrimary.color, width: 24.wMin, height: 24.wMin, colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                SizedBox(width: 4.wMin),
                Text("${widget.entity.count ?? 0}篇", style: TextStyle(fontSize: 16.wMin, color: Colors.white)),
              ],
            )),
        SizedBox(height: 24.wMin),
      ]),
    );
  }

  List<String> messages = ["每天自动推送该主题的新文章到任务列表", "根据您的难度等级智能匹配文章", "推送时不扣学点，阅读时每篇扣除100学点", "可随时在订阅管理中取消订阅"];

  String getGrene(List<ManageSubscribeNameItem> item, String condition) {
    var systemCondition = LangPreference.fromRawValue(UserStore.to.userInfo.value.config?.extensionConfig!.translationType ?? '').langCode;
    if (systemCondition.isNotEmpty) {
      condition = systemCondition;
    }
    for (var glossItem in item) {
      if (glossItem.lang == condition) {
        return glossItem.text!;
      }
    }
    return '';
  }

  Widget _body() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 40.wMin, vertical: 24.wMin),
        child: Column(children: [
          Text(getGrene(widget.entity.depiction ?? [], 'zh'),
              maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 22.wMin, color: AppTheme.cTextTertiary.color)),
          SizedBox(height: 24.wMin),
          Divider(color: AppTheme.cBorderPrimary.color),
          SizedBox(height: 24.wMin),
          Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.wMin),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.wMin), color: AppTheme.cFeedbackInfoBackground.color),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("订阅后将获得", style: TextStyle(fontSize: 24.wMin, fontWeight: FontWeight.w600, color: AppTheme.cTextBrand.color)),
                  SizedBox(height: 8.wMin),
                ]..addAll(List.generate(4, (e) {
                    return Padding(
                      padding: EdgeInsets.only(top: 8.wMin),
                      child: Row(
                        children: [
                          Container(
                            width: 8.wMin,
                            height: 8.wMin,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.cTextBrand.color),
                          ),
                          SizedBox(width: 8.wMin),
                          Text(messages[e], style: TextStyle(fontSize: 22.wMin, color: AppTheme.cTextSecondary.color)),
                        ],
                      ),
                    );
                  }).toList()),
              )),
          SizedBox(height: 24.wMin),
          if (widget.entity.title != null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.wMin),
                color: AppTheme.cSurfaceTertiary.color,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.wMin),
                      decoration: BoxDecoration(color: AppTheme.cSurfaceError.color, borderRadius: BorderRadius.circular(4.wMin)),
                      alignment: Alignment.center,
                      child: Text('new', style: TextStyle(color: Colors.white, fontSize: 18.wMin)),
                    ),
                    SizedBox(width: 4.wMin),
                    Text(
                      '最新文章',
                      style: TextStyle(color: AppTheme.cTextTertiary.color, fontSize: 16.wMin),
                    )
                  ]),
                  SizedBox(height: 8.wMin),
                  Text('${widget.entity.title}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppTheme.cTextSecondary.color, fontSize: 18.wMin)),
                ],
              ),
            ),
          SizedBox(height: 24.wMin),
          Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.wMin),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.wMin), color: AppTheme.cFeedbackInfoBackground.color, border: Border.all(color: AppTheme.cFeedbackInfoBorder.color)),
              child: Row(children: [
                SvgPicture.asset(
                  'assets/svg/manage/icon_info_circle.svg',
                  width: 24.wMin,
                  height: 24.wMin,
                  color: AppTheme.cSurfaceInfo.color,
                ),
                SizedBox(width: 8.wMin),
                Text('每天自动推送该主题的新文章到任务列表', style: TextStyle(fontSize: 18.wMin, color: AppTheme.cTextBrand.color)),
              ])),
        ]));
  }

  Widget _bottomBtn() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      GestureDetector(
        onTap: () {
          Get.back(result: '');
        },
        child: Container(
            width: 315.wMin,
            height: 72.wMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppTheme.cSurfaceQuaternary.color, borderRadius: BorderRadius.circular(12.wMin)),
            child: Text('取消', style: TextStyle(fontSize: 28.wMin, fontWeight: FontWeight.w500, color: AppTheme.cTextPrimary.color))),
      ),
      SizedBox(width: 10.wMin),
      GestureDetector(
        onTap: () {
          _subThis();
        },
        child: Container(
            width: 315.wMin,
            height: 72.wMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppTheme.cSurfaceInfo.color, borderRadius: BorderRadius.circular(12.wMin)),
            child: Text('确认订阅', style: TextStyle(fontSize: 28.wMin, fontWeight: FontWeight.w500, color: AppTheme.cInverseTextLight.color))),
      )
    ]);
  }

  //todo:订阅
  void _subThis() {
    _controller.toggleSubscribe(
      collectionId: widget.entity.collectionId!,
      isSubscribed: true,
    );
  }
}
