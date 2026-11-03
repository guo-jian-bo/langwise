import 'dart:io';

// import 'package:jverify/jverify.dart';
/// 极光验证工具类
class JverifyUtils {
  
  // static Jverify jverify = Jverify();

  /// 初始化
  static void init() {
    if(!Platform.isIOS && !Platform.isAndroid) return;
    // jverify.setDebugMode(true);
    // jverify.setup(appKey: Config.jPushAppKey ,channel: Config.jPushChannel);
  }

  /// 判断当前手机网络环境是否可以使用认证
  static Future<bool> isNetworkAvailable() async {
    if(!Platform.isIOS && !Platform.isAndroid) return false;
    // Map<dynamic, dynamic> result = await jverify.checkVerifyEnable();
    // if(result.isEmpty) return false;
    // return result['result'] == true;
    return false;
  }

  /// 获取当前在线的sim卡所在运营商及token。如果获取成功代表可以用来验证手机号
  static Future<String?> getSimInfo() async {
    if(!Platform.isIOS && !Platform.isAndroid) return null;
    // Map<dynamic, dynamic> result = await jverify.getToken();
    // if(result.isEmpty) return null;
    // int? _code = result["code"]; // 返回码，2000代表获取成功，其他为失败，详见错误码描述
    // String? _token = result["message"]; // 成功时为token，可用于调用验证手机号接口。token有效期为1分钟，超过时效需要重新获取才能使用。失败时为失败信息
    // // String? _operator = result["operator"]; // 成功时为对应运营商，CM代表中国移动，CU代表中国联通，CT代表中国电信。失败时可能为null
    
    // if(_code != 2000) return null;
    // if(_token == null) return null;
    // return _token;
    return null;
  }

  /// 预取号，提升一键登录成功率
  static Future<bool> preLogin({int timeoutMs = 10000}) async {
    if (!Platform.isIOS && !Platform.isAndroid) return false;
    // final Map<dynamic, dynamic> result = await jverify.preLogin(timeOut: timeoutMs);
    // final int? code = result['code'] as int?;
    // final String? msg = result['message'] as String?;
    // print('JVerify preLogin: code=$code, message=$msg');
    // return code == 7000;
    return false;
  }

  /// 清理预取号缓存（例如 6006 过期时）
  static Future<void> clearPreLoginCache() async {
    if (!Platform.isIOS && !Platform.isAndroid) return;
    // jverify.clearPreLoginCache();
  }


  /// 唤起一键登录
  static Future<void> showJverifyLoginView() async {
    if(!Platform.isIOS && !Platform.isAndroid) return;

    bool preOk = await preLogin(timeoutMs: 5000);
    if (!preOk) {
      // 预取失败时尝试清理后重试一次
      await clearPreLoginCache();
      preOk = await preLogin(timeoutMs: 5000);
      if (!preOk) {
        print('预取号失败，取消一键登录（建议检查蜂窝数据、VPN/代理与弱网环境）');
        return;
      }
    }

    // jverify.loginAuthSyncApi2(
    //   autoDismiss: true,
    //   loginAuthcallback: (event) {
    //     print('一键登录回调: code=${event.code}, message=${event.message}');
    //   },
    // );
  }

  /// 设置自定义UI
  static void setCustomUI() {
    if(!Platform.isIOS && !Platform.isAndroid) return;
    // bool isiOS = Platform.isIOS;

    // JVUIConfig uiConfig = JVUIConfig();

    // // 导航栏
    // uiConfig.navColor = Colors.tealAccent.value;
    // uiConfig.navText = "返回";
    // uiConfig.navTextColor = AppTheme.cTextPrimary.color.value;
    // uiConfig.navReturnImgPath = "icon_back";

    // uiConfig.logoWidth = 100;
    // uiConfig.logoHeight = 80;
    // //uiConfig.logoOffsetX = isiOS ? 0 : null;//(screenWidth/2 - uiConfig.logoWidth/2).toInt();
    // uiConfig.logoOffsetY = 10;
    // uiConfig.logoVerticalLayoutItem = JVIOSLayoutItem.ItemSuper;
    // uiConfig.logoHidden = false;
    // uiConfig.logoImgPath = "logo";

    // uiConfig.numberFieldWidth = 200;
    // uiConfig.numberFieldHeight = 40 ;
    // //uiConfig.numFieldOffsetX = isiOS ? 0 : null;//(screenWidth/2 - uiConfig.numberFieldWidth/2).toInt();
    // uiConfig.numFieldOffsetY = isiOS ? 20 : 120;
    // uiConfig.numberVerticalLayoutItem = JVIOSLayoutItem.ItemLogo;
    // uiConfig.numberColor = Colors.blue.value;
    // uiConfig.numberSize = 18;

    // uiConfig.sloganOffsetY = isiOS ? 20 : 160;
    // uiConfig.sloganVerticalLayoutItem = JVIOSLayoutItem.ItemNumber;
    // uiConfig.sloganTextColor = Colors.black.value;
    // uiConfig.sloganTextSize = 15;

    // uiConfig.logBtnWidth = 220;
    // uiConfig.logBtnHeight = 50;
    // //uiConfig.logBtnOffsetX = isiOS ? 0 : null;//(screenWidth/2 - uiConfig.logBtnWidth/2).toInt();
    // uiConfig.logBtnOffsetY = isiOS ? 20 : 230;
    // uiConfig.logBtnVerticalLayoutItem = JVIOSLayoutItem.ItemSlogan;
    // uiConfig.logBtnText = "登录按钮";
    // uiConfig.logBtnTextColor = Colors.brown.value;
    // uiConfig.logBtnTextSize = 16;
    // // uiConfig.loginBtnNormalImage = "login_btn_normal";//图片必须存在
    // // uiConfig.loginBtnPressedImage = "login_btn_press";//图片必须存在
    // // uiConfig.loginBtnUnableImage = "login_btn_unable";//图片必须存在

    // uiConfig.privacyState = false;//设置默认勾选
    // uiConfig.privacyCheckboxSize = 20;
    // // uiConfig.checkedImgPath = "check_image";//图片必须存在
    // // uiConfig.uncheckedImgPath = "uncheck_image";//图片必须存在
    // uiConfig.privacyCheckboxInCenter = true;
    // //uiConfig.privacyCheckboxHidden = false;
    // uiConfig.textVerAlignment = 1;

    // uiConfig.privacyOffsetY = 15; // 距离底部距离
    // uiConfig.privacyVerticalLayoutItem = JVIOSLayoutItem.ItemSuper;
    // uiConfig.clauseName = "协议1";
    // uiConfig.clauseUrl = "http://www.baidu.com";
    // uiConfig.clauseBaseColor = Colors.black.value;
    // uiConfig.clauseNameTwo = "协议二";
    // uiConfig.clauseUrlTwo = "http://www.hao123.com";
    // uiConfig.clauseColor = Colors.red.value;
    // uiConfig.privacyText = ["1极", "4证"];
    // uiConfig.privacyTextSize = 13;
    // uiConfig.privacyItem = [
    //     JVPrivacy("自定义协议1", "http://www.baidu.com",
    //               beforeName: "==", afterName: "++", separator: "*"),
    //           JVPrivacy("自定义协议2", "http://www.baidu.com", separator: "、")
    //     ];
    // //uiConfig.privacyWithBookTitleMark = true;
    // //uiConfig.privacyTextCenterGravity = false;
    // uiConfig.authStatusBarStyle = JVIOSBarStyle.StatusBarStyleDarkContent;
    // uiConfig.privacyStatusBarStyle = JVIOSBarStyle.StatusBarStyleDefault;
    // uiConfig.modelTransitionStyle =
    // JVIOSUIModalTransitionStyle.CrossDissolve;

    // uiConfig.statusBarColorWithNav = true;
    // uiConfig.virtualButtonTransparent = true;

    // uiConfig.privacyStatusBarColorWithNav = true;
    // uiConfig.privacyVirtualButtonTransparent = true;

    // uiConfig.needStartAnim = true;
    // uiConfig.needCloseAnim = true;

    // uiConfig.privacyNavColor =  Colors.red.value;;
    // uiConfig.privacyNavTitleTextColor = Colors.blue.value;
    // uiConfig.privacyNavTitleTextSize = 16;
    // uiConfig.privacyNavTitleTitle1 = "协议1 web页标题";
    // uiConfig.privacyNavTitleTitle2 = "协议2 web页标题";
    // uiConfig.privacyNavReturnBtnImage = "icon_back";//图片必须存在;


    // jverify.setCustomAuthorizationView(true, uiConfig, landscapeConfig: uiConfig);
  }


}
