import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:ui_essentials/ui_essentials.dart';

///全局首定制得刷新请求头和尾

class Refresh {
  Refresh() {
    EasyRefresh.defaultHeaderBuilder = () => ClassicHeader(
        dragText: 'Pull to refresh',
        armedText: 'Release ready',
        readyText: 'Refreshing...',
        processingText: 'Refreshing...',
        processedText: 'Succeeded',
        noMoreText: 'No more',
        failedText: 'Failed',
        showMessage: false,
        textStyle:
            TextStyle(fontSize: 16.wMin, color: const Color(0xffEDF0F4), fontWeight: FontWeight.w400, height: 1.0));
    EasyRefresh.defaultFooterBuilder = () => ClassicFooter(
        dragText: 'Pull to load',
        armedText: 'Release ready',
        readyText: 'Loading...',
        processingText: 'Loading...',
        processedText: 'Succeeded',
        noMoreText: 'No more',
        failedText: 'Failed',
        showMessage: false,
        textStyle:
            TextStyle(fontSize: 16.wMin, color: const Color(0xffEDF0F4), fontWeight: FontWeight.w400, height: 1.0));
  }
}
