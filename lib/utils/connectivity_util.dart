import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityUtil {

  static Future<bool> checkConnectivity() async {
    final List<ConnectivityResult> result = await (Connectivity().checkConnectivity());
    print('---检查网络状态result:$result---');
    return _hasNet(result);
  }

  static bool _hasNet(List<ConnectivityResult> state) {
    return !state.contains(ConnectivityResult.none);
  }
}
