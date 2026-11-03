import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/date_time_picker_widget.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

class WishDialog {
  static Future<bool> show({required BuildContext context}) async {
    bool? res = await showCupertinoDialog(
      context: context,
      builder: (context) {
        return const WishDialogWidget();
      },
    );

    return res ?? false;
  }
}

class WishDialogWidget extends StatefulWidget {
  const WishDialogWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return WishDialogWidgetState();
  }
}

class WishDialogWidgetState extends State<WishDialogWidget> {
  DateTime startTime = DateTime.now();
  late DateTime endTime;
  TextEditingController startEditController = TextEditingController();
  TextEditingController endEditController = TextEditingController();
  TextEditingController desController = TextEditingController();

  int _targetStars = 0;
  TextEditingController targetStarsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    endTime = startTime;
    startEditController.text = DateFormatUtil.formatStr(startTime, locale: Get.locale);
    endEditController.text = DateFormatUtil.formatStr(endTime, locale: Get.locale);
    targetStarsController.text = _targetStars.toString();
  }

  @override
  void dispose() {
    startEditController.dispose();
    endEditController.dispose();
    desController.dispose();
    targetStarsController.dispose();
    super.dispose();
  }

  int _clampTargetStars(int value) {
    if (value < 0) return 0;
    if (value > 999) return 999;
    return value;
  }

  void _setTargetStars(int value) {
    final int clamped = _clampTargetStars(value);
    setState(() {
      _targetStars = clamped;
      targetStarsController.value = TextEditingValue(
        text: clamped.toString(),
        selection: TextSelection.collapsed(offset: clamped.toString().length),
      );
    });
  }

  void _onTargetStarsChanged(String text) {
    final int? parsed = int.tryParse(text);
    final int next = _clampTargetStars(parsed ?? 0);

    if (next != _targetStars) {
      setState(() {
        _targetStars = next;
      });
    }

    if (parsed == null || next.toString() != text) {
      targetStarsController.value = TextEditingValue(
        text: next.toString(),
        selection: TextSelection.collapsed(offset: next.toString().length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cOverlayBackground.color,
      child: Center(
        child: Stack(
          children: [
            Container(
              width: 800.wMin,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.wMin),
                color: AppTheme.cSurfaceSecondary.color,
                border: Border.all(color: AppTheme.cFeedbackWarningBorder.color, width: 4.wMin),
              ),
              padding: EdgeInsets.fromLTRB(80.wMin, 112.wMin, 80.wMin, 48.wMin),
              child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('设置我的星愿',
                          style: TextStyle(
                            fontSize: 36.wMin,
                            color: AppTheme.cTextPrimary.color,
                            fontWeight: FontWeight.w600,
                          )),
                      SizedBox(height: 56.wMin),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('星愿描述', style: TextStyle(fontSize: 28.wMin, fontWeight: FontWeight.w500, color: AppTheme.cTextPrimary.color)),
                          SizedBox(height: 8.wMin),
                          Container(
                            padding: EdgeInsets.all(16.wMin),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.wMin), color: AppTheme.cSurfaceTertiary.color),
                            child: TextField(
                              controller: desController,
                              style: TextStyle(fontSize: 28.wMin, fontWeight: FontWeight.w400, color: AppTheme.cTextPrimary.color),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: '请描述你的星愿',
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                                hintStyle: TextStyle(fontSize: 28.wMin, fontWeight: FontWeight.w400, color: AppTheme.cTextTertiary.color),
                              ),
                            ),
                          ),
                          SizedBox(height: 24.wMin),
                          Text('起止日期', style: TextStyle(fontSize: 28.wMin, fontWeight: FontWeight.w500, color: AppTheme.cTextPrimary.color)),
                          SizedBox(height: 8.wMin),
                          Builder(
                            builder: (ctx) {
                              return GestureDetector(
                                onTap: () {
                                  return;
                                },
                                child: Container(
                                  padding: EdgeInsets.all(16.wMin),
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.wMin), color: AppTheme.cSurfaceTertiary.color),
                                  child: Row(
                                    children: [
                                      Text('开始:', style: TextStyle(fontSize: 28.wMin, fontWeight: FontWeight.w400, color: AppTheme.cTextPrimary.color)),
                                      SizedBox(width: 8.wMin),
                                      Expanded(
                                          child: IgnorePointer(
                                        child: TextField(
                                          controller: startEditController,
                                          style: TextStyle(fontSize: 28.wMin, fontWeight: FontWeight.w400, color: AppTheme.cTextPrimary.color),
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: '请选择开始日期',
                                            contentPadding: EdgeInsets.zero,
                                            isDense: true,
                                            hintStyle: TextStyle(fontSize: 28.wMin, fontWeight: FontWeight.w400, color: AppTheme.cTextTertiary.color),
                                          ),
                                        ),
                                      ))
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 16.wMin),
                          Builder(
                            builder: (ctx) {
                              return GestureDetector(
                                onTap: () {
                                  setEndTime(ctx);
                                },
                                child: Container(
                                  padding: EdgeInsets.all(16.wMin),
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.wMin), color: AppTheme.cSurfaceTertiary.color),
                                  child: Row(
                                    children: [
                                      Text('结束:', style: TextStyle(fontSize: 28.wMin, fontWeight: FontWeight.w400, color: AppTheme.cTextPrimary.color)),
                                      SizedBox(width: 8.wMin),
                                      Expanded(
                                          child: IgnorePointer(
                                        child: TextField(
                                          controller: endEditController,
                                          style: TextStyle(fontSize: 28.wMin, fontWeight: FontWeight.w400, color: AppTheme.cTextPrimary.color),
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: '请选择结束日期',
                                            contentPadding: EdgeInsets.zero,
                                            isDense: true,
                                            hintStyle: TextStyle(fontSize: 28.wMin, fontWeight: FontWeight.w400, color: AppTheme.cTextTertiary.color),
                                          ),
                                        ),
                                      ))
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 24.wMin),
                          Text('目标星星', style: TextStyle(fontSize: 28.wMin, fontWeight: FontWeight.w500, color: AppTheme.cTextPrimary.color)),
                          SizedBox(height: 8.wMin),
                          Container(
                            height: 74.wMin,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.wMin), color: AppTheme.cSurfaceTertiary.color),
                            child: Row(children: [
                              SizedBox(width: 16.wMin),
                              GestureDetector(
                                onTap: () {
                                  _setTargetStars(_targetStars - 1);
                                },
                                child: Container(
                                    width: 42.wMin,
                                    height: 42.wMin,
                                    decoration: BoxDecoration(color: AppTheme.cSurfaceQuaternary, borderRadius: BorderRadius.all(Radius.circular(4.wMin))),
                                    child: SvgPicture.asset('assets/svg/user_center/icon_ninus.svg',
                                        width: 29.wMin, height: 29.wMin, colorFilter: const ColorFilter.mode(AppTheme.cTextQuaternary, BlendMode.srcIn))),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: targetStarsController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 36.wMin, fontWeight: FontWeight.w600, color: AppTheme.cTextPrimary.color),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(3),
                                  ],
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    isDense: true,
                                  ),
                                  onChanged: _onTargetStarsChanged,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _setTargetStars(_targetStars + 1);
                                },
                                child: Container(
                                    width: 42.wMin,
                                    height: 42.wMin,
                                    decoration: BoxDecoration(color: AppTheme.cSurfaceQuaternary, borderRadius: BorderRadius.all(Radius.circular(4.wMin))),
                                    child: SvgPicture.asset('assets/svg/user_center/icon_plus.svg',
                                        width: 29.wMin, height: 29.wMin, colorFilter: const ColorFilter.mode(AppTheme.cTextQuaternary, BlendMode.srcIn))),
                              ),
                              SizedBox(width: 16.wMin),
                            ]),
                          )
                        ],
                      ),
                      SizedBox(height: 68.wMin),
                      GestureDetector(
                          onTap: () {
                            //todo:请求接口
                            Get.back();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 192.wMin, vertical: 20.wMin),
                            decoration: BoxDecoration(
                              color: AppTheme.cSurfaceWarning,
                              borderRadius: BorderRadius.circular(12.wMin),
                            ),
                            child: Text(
                              '生成契约',
                              style: TextStyle(fontSize: 24.wMin, fontWeight: FontWeight.w600, color: AppTheme.cInverseTextLight.color),
                            ),
                          ))
                    ],
                  ),
            
            ),
            _closeBtn()
          ],
        ),
      ),
    );
  }

  Widget _closeBtn() {
    return Positioned(
        right: 16.wMin,
        top: 16.wMin,
        child: TapScaleWidget(
          sclae: 1.05,
          onTap: () => Get.back(),
          child: Container(
            width: 52.wMin,
            height: 52.wMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.cSurfaceTertiary.color,
            ),
            child: SvgPicture.asset(
              "assets/svg/public/x.svg",
              width: 44.wMin,
              height: 44.wMin,
            ),
          ),
        ));
  }

  void setStartTime(BuildContext ctx) {
    DateTimePickerUtils.showDateCalender(
      context: ctx,
      initialDate: startTime,
      minDate: DateTime.now(),
      maxDate: DateTime.now().add(const Duration(days: 365)),
      onTap: (date) {
        setState(() {
          startTime = date;
          startEditController.text = DateFormatUtil.formatStr(startTime, locale: Get.locale);

          if (endTime.isBefore(startTime)) {
            endTime = startTime;
            endEditController.text = DateFormatUtil.formatStr(endTime, locale: Get.locale);
          }
        });
      },
    );
  }

  void setEndTime(BuildContext ctx) {
    DateTimePickerUtils.showDateCalender(
      context: ctx,
      initialDate: endTime,
      minDate: startTime,
      maxDate: startTime.add(const Duration(days: 365)),
      onTap: (date) {
        setState(() {
          endTime = date;
          endEditController.text = DateFormatUtil.formatStr(endTime, locale: Get.locale);
        });
      },
    );
  }
}
