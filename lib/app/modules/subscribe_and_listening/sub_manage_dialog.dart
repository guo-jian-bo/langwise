import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/subscribe_and_listening/controller.dart';
import 'package:langwise/app/modules/subscribe_and_listening/more_article_dialog.dart';
import 'package:langwise/app/modules/subscribe_and_listening/unsubscribe_dialog.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import 'package:langwise/common/entities/user_subscribe_config_entity.dart';
import 'package:langwise/common/https/subscribe.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../../../../theme/theme.dart';

class SubManageDialog {
  static Future<bool> show(
      BuildContext context, UserSubscribeConfigEntity entity,
      {required String tagText}) async {
    bool? res = await showCupertinoDialog<bool?>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return SubManageDialogWidget(entity: entity, tagText: tagText);
      },
    );
    return res ?? false;
  }
}

class SubManageDialogWidget extends StatefulWidget {
  const SubManageDialogWidget({
    super.key,
    required this.entity,
    required this.tagText,
  });

  final UserSubscribeConfigEntity entity;
  final String tagText;

  @override
  State<SubManageDialogWidget> createState() => _SubManageDialogWidgetState();
}

class _SubManageDialogWidgetState extends State<SubManageDialogWidget> {
  late UserSubscribeConfigEntity data;

  SubListenController get _controller =>
      Get.find<SubListenController>(tag: widget.tagText);

  @override
  void initState() {
    super.initState();
    data = widget.entity;
    sliderValue = data.maxPushNum?.toDouble() ?? 20.0;
  }

  refresh() async {
    final res = await SubscribeRequest.getUserSubscribeConfig();
    if (res != null) {
      setState(() {
        data = res;
      });
    }
  }

  void _submitAndClose() {
    if (sliderValue != data.maxPushNum?.toDouble()) {
      SubscribeRequest.userUpdateDailyPushMax(max: sliderValue.toInt());
    }
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        color: AppTheme.cOverlayBackground,
        child: Center(
            child: ClipRRect(
                borderRadius: BorderRadius.circular(24.wMin),
                child: Container(
                    width: 1000.wMin,
                    height: 920.wMin,
                    decoration: BoxDecoration(
                      color: AppTheme.cSurfaceSecondary.color,
                      borderRadius: BorderRadius.circular(24.wMin),
                      border: Border.all(
                          width: 1.wMin, color: AppTheme.cBorderPrimary),
                    ),
                    child: Stack(children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                            40.wMin, 40.wMin, 40.wMin, 124.wMin),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Text('订阅管理',
                                    style: TextStyle(
                                        fontSize: 32.wMin,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.cTextPrimary.color)),
                              ),
                              SizedBox(height: 8.wMin),
                              Align(
                                alignment: Alignment.center,
                                child: Text('统一管理每日推送、额外加推和已订阅主题',
                                    style: TextStyle(
                                        fontSize: 22.wMin,
                                        color: AppTheme.cTextTertiary.color)),
                              ),
                              SizedBox(height: 24.wMin),
                              Expanded(
                                child: SingleChildScrollView(
                                    child: Column(children: [
                                  _card(child: _todayPush()),
                                  SizedBox(height: 16.wMin),
                                  if (data.isOnceMorePush ?? false)
                                    _card(child: _additionPush()),
                                  SizedBox(height: 16.wMin),
                                  _card(child: _dailyPushLimit()),
                                  SizedBox(height: 16.wMin),
                                  Container(
                                      padding: EdgeInsets.all(16.wMin),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(12.wMin),
                                        border: Border.all(
                                            color: AppTheme
                                                .cBorderSecondary.color),
                                        color: AppTheme.cSurfaceTertiary.color,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              '已订阅主题（${data.collectionSubscribe?.length ?? 0}）',
                                              style: TextStyle(
                                                  fontSize: 28.wMin,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppTheme
                                                      .cTextPrimary.color)),
                                          SizedBox(height: 16.wMin),
                                          ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              itemBuilder: (ctx, idx) {
                                                return Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 12.wMin),
                                                  child: _card(
                                                    bgColor: AppTheme
                                                        .cSurfaceSecondary
                                                        .color,
                                                    child: _subItem(
                                                        data.collectionSubscribe?[
                                                                idx] ??
                                                            UserCollectionSubscribeEntity()),
                                                  ),
                                                );
                                              },
                                              itemCount: data
                                                      .collectionSubscribe
                                                      ?.length ??
                                                  0),
                                        ],
                                      )),
                                ])),
                              ),
                            ]),
                      ),
                      Positioned(
                          top: 10.wMin, right: 10.wMin, child: _backIcon()),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: 92.wMin,
                          padding: EdgeInsets.symmetric(
                              horizontal: 40.wMin, vertical: 12.wMin),
                          decoration: BoxDecoration(
                            color: AppTheme.cSurfaceTertiary.color,
                            border: Border(
                                top: BorderSide(
                                    color: AppTheme.cBorderPrimary.color)),
                          ),
                          child: GestureDetector(
                            onTap: _submitAndClose,
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppTheme.cTextBrand.color,
                                borderRadius: BorderRadius.circular(12.wMin),
                              ),
                              child: Text('完成',
                                  style: TextStyle(
                                    fontSize: 24.wMin,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.cInverseTextLight.color,
                                  )),
                            ),
                          ),
                        ),
                      ),
                    ])))));
  }

  Widget _card({Widget? child, Color bgColor = Colors.transparent}) {
    return Container(
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        border: Border.all(color: AppTheme.cBorderSecondary.color),
        color: bgColor,
      ),
      child: child,
    );
  }

  Widget _backIcon() {
    return TapScaleWidget(
      sclae: 1.05,
      onTap: () => Get.back(),
      child: Container(
        width: 42.wMin,
        height: 42.wMin,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.cSurfaceTertiary.color,
        ),
        child: SvgPicture.asset(
          "assets/svg/public/x.svg",
          width: 24.wMin,
          height: 24.wMin,
        ),
      ),
    );
  }

  //今日主动推送
  Widget _todayPush() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('今日主动推送',
                    style: TextStyle(
                        fontSize: 28.wMin,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.cTextPrimary.color)),
                Text.rich(
                  style: TextStyle(
                      fontSize: 22.wMin, color: AppTheme.cTextQuaternary.color),
                  TextSpan(children: [
                    TextSpan(text: '系统已自动推送'),
                    TextSpan(
                        text: '${data.pushSubscribeNum}',
                        style: TextStyle(
                            fontSize: 28.wMin,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.cTextBrand.color)),
                    TextSpan(text: '篇'),
                    TextSpan(
                        text: '（暂无更多新文章）',
                        style: TextStyle(
                            color: AppTheme.cFeedbackWarningText.color)),
                  ]),
                )
              ]),
          Spacer(),
          IntrinsicWidth(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.wMin),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: EdgeInsets.all(4.wMin),
                    color: AppTheme.cSurfaceInfo.color,
                    child: Text(
                      '每日上限',
                      style: TextStyle(
                          fontSize: 22.wMin,
                          color: AppTheme.cInverseTextLight.color),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(4.wMin),
                    alignment: Alignment.center,
                    color: AppTheme.cFeedbackInfoBackground.color,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${data.maxPushNum ?? 10}',
                          style: TextStyle(
                              fontSize: 28.wMin,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.cTextBrand.color),
                        ),
                        Text(
                          '篇/天',
                          style: TextStyle(
                              fontSize: 16.wMin,
                              color: AppTheme.cTextSecondary.color),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
        Text(
          '${data.pushSubscribeNum ?? 0}/${data.pushSum ?? 10}',
          style:
              TextStyle(fontSize: 22.wMin, color: AppTheme.cTextPrimary.color),
        ),
        SizedBox(height: 6.wMin),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.ww),
          child: LinearProgressIndicator(
            value: data.pushSubscribeNum != null &&
                    data.pushSum != null &&
                    data.pushSum! > 0
                ? data.pushSubscribeNum! / data.pushSum!
                : 0,
            backgroundColor: AppTheme.cSurfaceQuaternary.color,
            valueColor:
                AlwaysStoppedAnimation<Color>(AppTheme.cSurfaceInfo.color),
            minHeight: 10.wh,
          ),
        ),
      ],
    );
  }

  //额外推送
  Widget _additionPush() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('额外推送',
                style: TextStyle(
                    fontSize: 28.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cTextPrimary.color)),
            Spacer(),
            GestureDetector(
              onTap: () {
                MoreArticleDialog.show(Get.context!, sliderValue)
                    .then((result) {
                  if (result) {
                    refresh();
                  }
                });
              },
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 7.wMin),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.wMin),
                    color: AppTheme.cFeedbackInfoBackground.color),
                child: Row(children: [
                  Text('再来一批（${sliderValue.ceil()}篇）',
                      style: TextStyle(
                          fontSize: 22.wMin,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.cTextBrand.color)),
                  Icon(Icons.arrow_forward_ios,
                      color: AppTheme.cTextBrand.color, size: 20.wMin),
                ]),
              ),
            )
          ],
        ),
        SizedBox(height: 16.wMin),
        Text('今天读完了还想再读？可以手动请求额外推送一批文章',
            style: TextStyle(
                fontSize: 22.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cTextSecondary.color)),
        SizedBox(height: 8.wMin),
        Row(
          children: [
            Container(
                width: 8.wMin,
                height: 8.wMin,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.cTextTertiary.color)),
            SizedBox(width: 8.wMin),
            Text('根据您的难度等级智能匹配文章',
                style: TextStyle(
                    fontSize: 22.wMin, color: AppTheme.cTextTertiary.color)),
          ],
        ),
        Row(
          children: [
            Container(
                width: 8.wMin,
                height: 8.wMin,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.cTextTertiary.color)),
            SizedBox(width: 8.wMin),
            Text('推送时不扣学点，阅读时每篇扣除100学点',
                style: TextStyle(
                    fontSize: 22.wMin, color: AppTheme.cTextTertiary.color)),
          ],
        ),
        Row(
          children: [
            Container(
                width: 8.wMin,
                height: 8.wMin,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.cTextTertiary.color)),
            SizedBox(width: 8.wMin),
            Text('可随时在订阅管理中取消订阅',
                style: TextStyle(
                    fontSize: 22.wMin, color: AppTheme.cTextTertiary.color)),
          ],
        )
      ],
    );
  }

  int min = 1;
  int max = 20;
  double sliderValue = 10;

  //每日推送上限
  Widget _dailyPushLimit() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text('每日推送上限',
            style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextPrimary.color)),
        Spacer(),
        Text.rich(
          style: TextStyle(
              fontSize: 22.wMin, color: AppTheme.cTextSecondary.color),
          TextSpan(children: [
            TextSpan(
                text: '${sliderValue.ceil()}',
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cTextBrand.color)),
            TextSpan(text: '篇/天'),
          ]),
        )
      ]),
      Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                if (sliderValue > min) {
                  sliderValue--;
                }
              });
            },
            child: Container(
              width: 40.wMin,
              height: 40.wMin,
              alignment: Alignment.center,
              child: SvgPicture.asset(
                'assets/svg/manage/icon_minus_sign.svg',
                width: 20.wMin,
                height: 20.wMin,
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.wMin),
                  color: AppTheme.cSurfaceQuaternary.color),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                  thumbColor: AppTheme.cInversePrimary.color,
                  activeTickMarkColor: Colors.transparent,
                  inactiveTickMarkColor: Colors.transparent,
                  inactiveTrackColor: AppTheme.cSurfaceQuaternary.color,
                  activeTrackColor: AppTheme.cInversePrimary.color),
              child: Slider(
                  max: max.toDouble(),
                  min: min.toDouble(),
                  divisions: max - min,
                  value: sliderValue.toDouble(),
                  onChanged: (v) {
                    setState(() {
                      sliderValue = v;
                    });
                  }),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                if (sliderValue < max) {
                  sliderValue++;
                }
              });
            },
            child: Container(
              width: 40.wMin,
              height: 40.wMin,
              alignment: Alignment.center,
              child: SvgPicture.asset('assets/svg/manage/icon_add.svg',
                  width: 20.wMin, height: 20.wMin),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.wMin),
                  color: AppTheme.cSurfaceQuaternary.color),
            ),
          )
        ],
      ),
      Text('推送时不扣费，阅读时每篇100学点',
          style:
              TextStyle(fontSize: 22.wMin, color: AppTheme.cTextTertiary.color))
    ]);
  }

  //订阅项
  Widget _subItem(UserCollectionSubscribeEntity item) {
    return Row(
      children: [
        SizedBox(width: 12.wMin),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.themeZhName ?? '',
                style: TextStyle(
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.cTextPrimary.color)),
            Text('${item.collectionPushNum}篇',
                style: TextStyle(
                    fontSize: 22.wMin, color: AppTheme.cTextTertiary.color)),
          ],
        ),
        Spacer(),
        Row(children: [
          GestureDetector(
            onTap: () {
              if (item.collectionId != null) {
                TagRoutes.toNamed(
                  Routes.APP_SUBSCRIBE_LISTENING_DETAILS,
                  arguments: {
                    'collectionId': item.collectionId,
                    'title': item.themeZhName,
                    'description': ''
                  },
                );
              }
            },
            child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 22.wMin, vertical: 7.wMin),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.wMin),
                    color: AppTheme.cSurfaceQuaternary.color),
                child: Text('查看',
                    style: TextStyle(
                        fontSize: 18.wMin,
                        color: AppTheme.cTextSecondary.color))),
          ),
          SizedBox(width: 8.wMin),
          GestureDetector(
            onTap: () {
              UnSubScribeDialog.show(
                      Get.context!, item.collectionId!, item.themeZhName ?? '',
                      tagText: widget.tagText)
                  .then((res) {
                if (res == 'DELETED') {
                  refresh();
                  var list = _controller.reveals.toList();
                  for (var ls in list) {
                    if (ls.collectionId == item.collectionId) {
                      ls.isSubscribe = false;
                      break;
                    }
                  }
                  _controller.reveals.refresh();
                }
              });
            },
            child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 22.wMin, vertical: 7.wMin),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.wMin),
                    color: AppTheme.cFeedbackErrorBackground.color),
                child: Text('取消',
                    style: TextStyle(
                        fontSize: 18.wMin,
                        color: AppTheme.cFeedbackErrorText.color))),
          )
        ])
      ],
    );
  }
}
