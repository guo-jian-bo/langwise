import 'package:wise_http/wise_http.dart';

import 'toast_utils.dart';

class DioExceptionUtils{

  static DioExceptionType handleDioException(DioException e, {bool showToast = true}){
    // 处理不同类型的网络异常
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        if(showToast) ToastUtils.showToast(text: '连接超时，请检查网络连接');
        return DioExceptionType.connectionTimeout;
      case DioExceptionType.sendTimeout:
        if(showToast) ToastUtils.showToast(text: '发送超时，请重试');
        return DioExceptionType.sendTimeout;
      case DioExceptionType.receiveTimeout:
        if(showToast) ToastUtils.showToast(text: '接收超时，请重试');
        return DioExceptionType.receiveTimeout; 
      case DioExceptionType.connectionError:
        if(showToast) ToastUtils.showToast(text: '网络连接异常，请检查网络设置');
        return DioExceptionType.connectionError;
      case DioExceptionType.badResponse:
        if(showToast) ToastUtils.showToast(text: '服务器响应异常：${e.response?.statusCode}');
        return DioExceptionType.badResponse;
      case DioExceptionType.unknown:
        // 处理未知异常，通常是网络连接问题
        if (e.message?.contains('Failed host lookup') == true) {
          if(showToast) ToastUtils.showToast(text: '无法连接到服务器，请检查网络');
        } else if (e.message?.contains('SocketException') == true) {
          if(showToast) ToastUtils.showToast(text: '网络连接中断');
        } else {
          if(showToast) ToastUtils.showToast(text: '网络请求失败：${e.message}');
        }
        return DioExceptionType.unknown;
      default:
        if(showToast) ToastUtils.showToast(text: '网络请求异常');
        return DioExceptionType.unknown;
    }
  }

}