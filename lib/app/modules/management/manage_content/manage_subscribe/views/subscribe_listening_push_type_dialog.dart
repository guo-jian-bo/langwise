import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_button.dart';
import 'package:langwise/common/https/subscribe.dart';
import 'package:langwise/common/widgets/date_time_picker_widget.dart';
import 'package:langwise/utils/date_format_util.dart';
import 'package:ui_essentials/ui_essentials.dart';

/// 推送类型：0 = 立即推送, 1 = 定时推送
class SubscribeListeningPushTypeDialog {
  static Future<int?> show({
    required BuildContext context,
    int initialType = 0,
    required String group,
    required int collectionId,
    required DateTime settingDay,
    required bool isLaunch,
  }) async {
    return await showCupertinoDialog<int?>(
      context: context,
      builder: (context) => _SubscribeListeningPushTypeDialogWidget(
        initialType: initialType,
        group: group,
        collectionId: collectionId,
        settingDay: settingDay,
        isLaunch: isLaunch,
      ),
    );
  }
}

class _SubscribeListeningPushTypeDialogWidget extends StatefulWidget {
  final int initialType;
  final String group;
  final int collectionId;
  final DateTime settingDay;
  final bool isLaunch;

  const _SubscribeListeningPushTypeDialogWidget({
    required this.initialType,
    required this.group,
    required this.collectionId,
    required this.settingDay,
    required this.isLaunch,
  });

  @override
  State<_SubscribeListeningPushTypeDialogWidget> createState() => _SubscribeListeningPushTypeDialogWidgetState();
}

class _SubscribeListeningPushTypeDialogWidgetState extends State<_SubscribeListeningPushTypeDialogWidget> {
  late int _pushType;
  late int _launchType = 0;
  final List<String> _options = ['立即推送', '公历日期', '农历日期'];
  final List<String> _launchOptions = ['批量上架', '批量下架'];
  late DateTime _selectedPublishedDate;

  @override
  void initState() {
    super.initState();
    _pushType = widget.initialType;
    _launchType = widget.isLaunch ? 0 : 1;
    _selectedPublishedDate = DateTime(widget.settingDay.year, widget.settingDay.month, widget.settingDay.day);
  }

  Future<void> _pickPublishedDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = DateTime(now.year - 1, 1, 1);
    final DateTime lastDate = DateTime(now.year + 10, 12, 31);

    DateTime initialDate = _selectedPublishedDate;
    if (initialDate.isBefore(firstDate)) initialDate = firstDate;
    if (initialDate.isAfter(lastDate)) initialDate = lastDate;

    DateTimePickerUtils.showDateCalender(context: context, initialDate: initialDate, minDate: firstDate, maxDate: lastDate, onTap: (date) {
      setState(() {
        _selectedPublishedDate = date;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          width: 600.ww,
          padding: EdgeInsets.all(24.wMin),
          decoration: BoxDecoration(
            color: const Color(0xFF26292A),
            borderRadius: BorderRadius.circular(24.wMin),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '批量推送及上架',
                style: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 24.wMin),
              Text(
                '推送类型',
                style: TextStyle(
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 12.wMin),
              Row(
                  spacing: 8.wMin,
                  children: _launchOptions.asMap().keys.map((e) {
                    return Expanded(
                        child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _launchType = e;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: _launchType == e
                                    ? e == 0
                                        ? const Color(0xFF44AF5C)
                                        : const Color(0xFFFF2D46)
                                    : const Color(0xFF353E5C),
                              ),
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(vertical: 6.wMin),
                              child: Text(_launchOptions[e], style: TextStyle(color: Colors.white, fontSize: 16.wMin, fontWeight: FontWeight.w400)),
                            )));
                  }).toList()),
              SizedBox(height: 18.wMin),
              Text(
                '推送类型',
                style: TextStyle(
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 12.wMin),
              Row(
                spacing: 4.wMin,
                children: _options.asMap().keys.map((index) {
                  return Expanded(
                      child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _pushType = index;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.wMin),
                        color: _pushType == index ? const Color(0xA62388FF) : const Color(0xFF353E5C),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 6.wMin),
                      alignment: Alignment.center,
                      child: Text(_options[index], style: TextStyle(color: Colors.white, fontSize: 16.wMin, fontWeight: FontWeight.w400)),
                    ),
                  ));
                }).toList(),
              ),
              SizedBox(height: 18.wMin),
              if (_pushType != 0) ...[
                _buildDateSelectors(),
                SizedBox(height: 18.wMin),
              ],
              _buildBottomButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelectors() {
    final String dateText = DateFormatUtil.formatStr(
      _selectedPublishedDate,
      newPattern: 'yyyy-MM-dd',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '推送日期',
          style: TextStyle(
            fontSize: 16.wMin,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 12.wMin),
        Builder(
          builder: (context) {
            return GestureDetector(
              onTap: () => _pickPublishedDate(context),
              child: Container(
                height: 36.wMin,
                padding: EdgeInsets.symmetric(horizontal: 12.wMin),
                decoration: BoxDecoration(
                  color: const Color(0xFF353E5C),
                  borderRadius: BorderRadius.circular(4.wMin),
                ),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        dateText,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.wMin,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.calendar_month,
                      color: Colors.white,
                      size: 18.wMin,
                    ),
                  ],
                ),
              ),
            );
          }
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ManageButton(
          text: '取消',
          width: 80.ww,
          height: 40.wh,
          color: Colors.transparent,
          borderColor: const Color(0xFF767E95),
          style: TextStyle(
            fontSize: 16.wMin,
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
          onTap: () {
            Get.back();
          },
        ),
        SizedBox(width: 16.ww),
        ManageButton(
          text: '确定',
          width: 80.ww,
          height: 40.wh,
          color: const Color(0xFF2388FF),
          borderColor: Colors.transparent,
          style: TextStyle(
            fontSize: 16.wMin,
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
          onTap: () async {
            String pushTime = "";
            Map<String, String> caType = {"立即推送": "IMMEDIATELY", "公历日期": "GREGORIAN", "农历日期": "LUNAR"};
            if (_pushType == 0) {
              pushTime = DateFormatUtil.formatStr(
                DateTime.now(),
                newPattern: "yyyy-MM-dd HH:mm:ss",
              );
            } else {
              pushTime = DateFormatUtil.formatStr(
                _selectedPublishedDate,
                newPattern: "yyyy-MM-dd HH:mm:ss",
              );
            }
            var res = await SubscribeRequest.updateGroupContent({
              "group": widget.group,
              "access": _launchType == 0 ? 'NORMAL' : 'INTERNAL',
              "collectionId": widget.collectionId,
              "calendarType": caType[_options[_pushType]]!,
              "publishedDate": pushTime,
              "contentType": "EN_REVEAL"
            });
            Get.back(result: res);
          },
        ),
      ],
    );
  }
}
