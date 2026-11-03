import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:langwise/utils/log_utils/error_log_utils.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:wise_http/wise_http.dart';

import '../common/entities/entities.dart';
import '../common/https/https.dart';
import '../common/widgets/widgets.dart';

class TestNetworkUtils{

  /// 测试n秒之后才能再次测试
  static const int testIntervalSeconds = 5;
  static bool _isTesting = false;
  static DateTime? _nextAvailableTestTime;

  /// 测试网络连接
  static Future<void> testNetwork(BuildContext context) async {
    if (_isTesting) {
      ToastUtils.showToast(
        text: "网络测试进行中，请稍候",
        type: ToastType.warning,
      );
      return;
    }

    final int remainingSeconds = _getRemainingCooldownSeconds();
    if (remainingSeconds > 0) {
      ToastUtils.showToast(
        text: "请在 $remainingSeconds 秒后再次测试",
        type: ToastType.warning,
      );
      return;
    }

    _isTesting = true;

    final allStopwatch = Stopwatch()..start();

    String msgText = "";

    try {
      ToastUtils.showLoading();

      msgText += "外部测试：\n";
      msgText += await testNetworkReq("https://www.baidu.com");
      msgText += "\n";

      msgText += "内部测试：\n";
      msgText += await testApp();
      msgText += "\n";

      msgText += "DNS测试：\n";
      msgText += await testDns("114.114.114.114", 53);

    } finally{
      allStopwatch.stop();
      _isTesting = false;
      _nextAvailableTestTime = DateTime.now().add(
        const Duration(seconds: testIntervalSeconds),
      );
      ToastUtils.hideLoading();
    }

    if (!context.mounted) return;

    await AskDialog.showUserAsk(
      context: context,
      title: "检查完成",
      content: msgText,
      define: "我知道了",
      showCancel: false,
    );

  }

  /// 测试接口
  static Future<String> testApp() async{
    String msgText = "";
    for(int i = 0; i < 3; i++){
      final stopwatch = Stopwatch()..start();
      CustomerInfoEntity? customerInfoEntity = await UserRequest.getCustomerInfo(showToast: false);
      stopwatch.stop();
      if(customerInfoEntity == null) {
        ErrorLogUtils.to.logInfo("[测试网络] --- 第${i+1}次连接客服接口, 连接失败, 耗时：${stopwatch.elapsedMilliseconds}ms");
        msgText += "第 ${i+1} 次测试连接【连接失败】——失败(${stopwatch.elapsedMilliseconds}ms)\n";
        continue;
      }
      ErrorLogUtils.to.logInfo("[测试网络] --- 第${i+1}次连接首页接口, 连接成功, 耗时：${stopwatch.elapsedMilliseconds}ms");
      msgText += "第 ${i+1} 次测试连接【连接成功】——${getNetworkSpeedName(stopwatch.elapsedMilliseconds)}(${stopwatch.elapsedMilliseconds}ms)\n";
    }
    return msgText;
  }

  /// 测试dns连通性 返回失败次数
  static Future<String> testDns(String host, int port) async{
    String msgText = "";
    for(int i = 0; i < 3; i++){
      final stopwatch = Stopwatch()..start();
      Socket? socket;
      try {
        socket = await Socket.connect(
          host,
          port,
          timeout: const Duration(seconds: 5),
        );
        stopwatch.stop();
        ErrorLogUtils.to.logInfo("[测试网络] --- 第${i+1}次连接$host:$port, 连接成功, 耗时：${stopwatch.elapsedMilliseconds}ms");
        msgText += "第 ${i+1} 次测试连接【连接成功】——${getNetworkSpeedName(stopwatch.elapsedMilliseconds)}(${stopwatch.elapsedMilliseconds}ms)\n";
      } on SocketException catch (e) {
        stopwatch.stop();
        ErrorLogUtils.to.logInfo("[测试网络] --- 第${i+1}次连接$host:$port, 连接失败 ${e.message}, 耗时：${stopwatch.elapsedMilliseconds}ms");
        msgText += "第 ${i+1} 次测试连接【连接失败】——失败(${stopwatch.elapsedMilliseconds}ms)\n";
      } on TimeoutException {
        stopwatch.stop();
        ErrorLogUtils.to.logInfo("[测试网络] --- 第${i+1}次连接$host:$port, 连接超时, 耗时：${stopwatch.elapsedMilliseconds}ms");
        msgText += "第 ${i+1} 次测试连接【连接超时】——超时(${stopwatch.elapsedMilliseconds}ms)\n";
      } catch (e) {
        stopwatch.stop();
        ErrorLogUtils.to.logInfo("[测试网络] --- 第${i+1}次连接$host:$port, 连接异常 $e, 耗时：${stopwatch.elapsedMilliseconds}ms");
        msgText += "第 ${i+1} 次测试连接【连接异常】——异常(${stopwatch.elapsedMilliseconds}ms)\n";
      } finally {
        await socket?.close();
      }
    }
    return msgText;
  }

  /// 测试接口发送 返回结果文案
  static Future<String> testNetworkReq(String url) async{
    String msgText = "";
    for(int i = 0; i < 3; i++){
      final stopwatch = Stopwatch()..start();
      dynamic response = await AssistHttp().request(url, Method.get);
      stopwatch.stop();
      int elapsedMilliseconds = stopwatch.elapsedMilliseconds;
      if (response == null) {
        ErrorLogUtils.to.logInfo("[测试网络] --- 第${i+1}次连接$url, 连接失败, 耗时：${stopwatch.elapsedMilliseconds}ms");
        msgText += "第 ${i+1} 次测试连接【连接失败】——失败(${elapsedMilliseconds}ms)\n";
        continue;
      }
      if(response.statusCode != HttpStatus.ok){
        ErrorLogUtils.to.logInfo("[测试网络] --- 第${i+1}次连接$url, 连接失败 ${response.statusCode}, 耗时：${elapsedMilliseconds}ms");
        msgText += "第 ${i+1} 次测试连接【连接失败】——失败(${response.statusCode},${elapsedMilliseconds}ms)\n";
        continue;
      }
      ErrorLogUtils.to.logInfo("[测试网络] --- 第${i+1}次连接$url, 连接成功, 耗时：${stopwatch.elapsedMilliseconds}ms");
      msgText += "第 ${i+1} 次测试连接【连接成功】——${getNetworkSpeedName(elapsedMilliseconds)}(${elapsedMilliseconds}ms)\n";
    }
    return msgText;

  }


  /// 判断网络速度名称
  static String getNetworkSpeedName(int elapsedMilliseconds){
    if(elapsedMilliseconds <= 30){
      return "极快";
    }
    if(elapsedMilliseconds <= 100){
      return "优秀";
    }
    if(elapsedMilliseconds <= 300){
      return "正常";
    }
    if(elapsedMilliseconds <= 800){
      return "较慢";
    }
    if(elapsedMilliseconds <= 1000){
      return "很慢";
    }
    return "极慢";
  }

  static int _getRemainingCooldownSeconds() {
    if (_nextAvailableTestTime == null) return 0;

    final Duration remaining = _nextAvailableTestTime!.difference(DateTime.now());
    if (remaining <= Duration.zero) return 0;

    return remaining.inSeconds + (remaining.inMilliseconds % 1000 == 0 ? 0 : 1);
  }

}
