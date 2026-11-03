

import 'package:api/api.dart';
import 'package:wise_http/wise_http.dart';

class AuthRequest{
  
  /// 获取服务器的时间戳 返回时间戳(1783590899)
  static Future<int?> getServerTimestamp() async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/auth/date",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
      ).catchError((_) {});
      if (response == null) return null;
      int? timestamp = int.tryParse(response["date"].toString());
      return timestamp;
    } catch (e) {
      return null;
    }
  }

}