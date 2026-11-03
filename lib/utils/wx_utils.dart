import 'dart:io';
import 'dart:typed_data';

import 'package:fluwx/fluwx.dart';
import 'package:langwise/utils/toast_utils.dart';

import 'cache_manager_utils.dart';
import '../config.dart';

class WxUtils {
  /// 微信实例
  static final Fluwx _fluwx = Fluwx();
  
  /// 初始化微信
  /// 仅在 Android 和 iOS 平台生效
  static Future<void> initWechat() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    if (Config.wechatAppId.trim().isEmpty) return;

    try {

      String universalLink = "${Config.wechatUniversalLink}openapp/";
      await _fluwx.registerApi(
        appId: Config.wechatAppId, // 微信开放平台 AppID
        universalLink: Platform.isIOS ? universalLink: null,
      );
    } catch (error, stackTrace) {
      print('initWechat error: $error, stackTrace: $stackTrace');
    }
  }

  /// 打开客服链接
  static Future<bool> openCustomerServiceUrl(String customerServiceUrl) async {
    if (!Platform.isAndroid && !Platform.isIOS) return false;
    if (customerServiceUrl.isEmpty) return false;
    final bool isInstalled = await _fluwx.isWeChatInstalled;
    if (!isInstalled) {
      ToastUtils.showToast(text: "请先安装微信");
      return false;
    }

    final bool opened = await _fluwx.open(
      target: CustomerServiceChat(
        corpId: Config.wechatCorpId, // 哪家企业
        url: customerServiceUrl, // 打开哪个客服入口
      ),
    );
    if (!opened) {
      ToastUtils.showToast(text: "打开企业微信客服失败");
    }
    return opened;
  }


  /// 微信分享
  static Future<bool> shareImage({
    required Uint8List imageBytes,
    required String title,
    WeChatScene scene = WeChatScene.session,
  }) async {
    if (!Platform.isAndroid && !Platform.isIOS) return false;
    if (imageBytes.isEmpty) return false;
    final bool isInstalled = await _fluwx.isWeChatInstalled;
    if (!isInstalled) {
      ToastUtils.showToast(text: "请先安装微信");
      return false;
    }

    final WeChatImageToShare imageToShare = await _buildImageToShare(imageBytes);
    final bool shared = await _fluwx.share(
      WeChatShareImageModel(
        imageToShare,
        scene: scene,
        title: title,
      ),
    );
    if (!shared) {
      ToastUtils.showToast(text: "分享失败");
    }
    return shared;
  }

  /// 构建微信分享图片
  static Future<WeChatImageToShare> _buildImageToShare(Uint8List imageBytes) async {
    if (!Platform.isAndroid) {
      return WeChatImageToShare(uint8List: imageBytes);
    }

    // Android shares through Binder. Passing large in-memory bytes can overflow
    // the transaction buffer, so WeChat image share uses a temp file instead.
    final String shareDirPath = await CacheManagerUtils.instance.getShareDirPath();
    final File tempFile = File(
      '$shareDirPath${Platform.pathSeparator}wechat_share_image.png',
    );
    await tempFile.writeAsBytes(imageBytes, flush: true);
    return WeChatImageToShare(localImagePath: tempFile.path);
  }

}
