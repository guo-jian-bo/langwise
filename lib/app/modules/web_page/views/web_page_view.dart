import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:themed/themed.dart';

import 'package:get/get.dart';

import '../../../../common/widgets/widgets.dart';
import '../../../../log_widget.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/utils.dart';
import '../../../routes/routes.dart';
import '../codes/web_handler_code.dart';
import '../bindings/web_page_binding.dart';
import '../controllers/web_page_controller.dart';
import '../models/web_result.dart';

class WebPageView extends GetView<WebPageController> {
  final String tagText;
  const WebPageView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      WebPageView(tagText: tag),
      binding: WebPageBinding(tagText: tag),
      routeName: Routes.WEB_PAGE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Obx((){
      Color? backgroundColor = controller.backgroundColor.value;
      return Scaffold(
        backgroundColor: backgroundColor ?? AppTheme.cBgPrimary,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(context),
            if(!controller.hideAppBarLoadProgress.value) _buildLoadProgress(),
            Expanded(
              child: _buildWebWidget(context),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAppBar(BuildContext context){
    return Obx((){
      if(controller.hideAppBar.value) return Container();
      
      bool canGoBack = controller.canGoBack.value;
      bool canGoForward = controller.canGoForward.value;
      return Container(
        height: kToolbarHeight + MediaQuery.of(context).padding.top,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          left: MediaQuery.of(context).padding.left + 15,
          right: MediaQuery.of(context).padding.right + 15,
        ),
        color: controller.backgroundColor.value ?? AppTheme.cBgPrimary,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              children: [
                TapScaleWidget(
                  onTap: () => controller.closeWebPage(),
                  sclae: 1.1,
                  child: _buildIconButtonWidget("assets/svg/public/x.svg"),
                ),
                Opacity(
                  opacity: canGoBack ? 1 : 0.6,
                  child: TapScaleWidget(
                    onTap: canGoBack ? () => controller.goBack() : null,
                    sclae: 1.1,
                    child: _buildIconButtonWidget("assets/svg/public/icon_arrow_back.svg"),
                  ),
                ),
                Opacity(
                  opacity: canGoForward ? 1 : 0.6,
                  child: TapScaleWidget(
                    onTap: canGoForward ? () => controller.goForward() : null,
                    sclae: 1.1,
                    child: _buildIconButtonWidget("assets/svg/public/icon_arrow_right.svg"),
                  ),
                ),
                TapScaleWidget(
                  onTap: () => controller.reload(),
                  sclae: 1.1,
                  child: _buildIconButtonWidget("assets/svg/public/icon_refresh.svg"),
                ),
              ],
            ),
            Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 40 * 4 + 15),
              child: Text(
                controller.webTitle.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  color: controller.appBarTitleColor.value ?? AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildIconButtonWidget(String svg){
    return Obx((){
      Color? appBarIconColor = controller.appBarIconColor.value;
      return Container(
        color: Colors.transparent,
        alignment: Alignment.center,
        width: 40,
        height: 40,
        child: SvgPicture.asset(
          svg,
          width: 20,
          height: 20,
          colorFilter: ColorFilter.mode(appBarIconColor ?? AppTheme.cFeedbackDefaultIcon, BlendMode.srcIn),
        ),
      );
    });
  }

  Widget _buildLoadProgress(){
    return LayoutBuilder(
      builder: (context, constraints) {
        return Obx((){
          double width = constraints.maxWidth;
          int loadProgress = controller.loadProgress.value;
          return Container(
            height: 4,
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: width * loadProgress / 100,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: controller.appBarLoadProgressColor.value.addOpacity(loadProgress == 100 ? 0 : 1),
              ),
            ),
          );
        });
      },
    );
  }


  Widget _buildWebWidget(BuildContext context){
    return Obx((){
      if(controller.url.isEmpty) return Container();
      if(!controller.webViewEnvironmentReady.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      return InAppWebView(
        webViewEnvironment: controller.webViewEnvironment,
        initialUrlRequest: URLRequest(url: WebUri(controller.url.value)),
        onWebViewCreated: (webViewController) {
          controller.webViewController = webViewController;
          controller.webViewController?.addJavaScriptHandler(
            handlerName: WebHandlerCode.appHandler, 
            callback: (args) async{
              WebResult result = await controller.appHandler(args, context);
              return result.toJson();
            },
          );
        },
        onLoadStart: (webViewController, url) {
          print("web -- 开始加载 : $url");
          LogManager().addLog("web -- 开始加载 : $url");
          ErrorLogUtils.to.logInfo("web -- 开始加载 : $url");
        },
        onLoadStop: (webViewController, url) {
          print("web -- 加载完成 : $url");
          LogManager().addLog("web -- 加载完成 : $url");
          ErrorLogUtils.to.logInfo("web -- 加载完成 : $url");
          webViewController.canGoBack().then((value){
            controller.canGoBack.value = value;
          });
          webViewController.canGoForward().then((value){
            controller.canGoForward.value = value;
          });
          
        },
        onProgressChanged: (webViewController, progress) {
          print("web -- 加载进度 : $progress");
          LogManager().addLog("web -- 加载进度 : $progress");
          ErrorLogUtils.to.logInfo("web -- 加载进度 : $progress");
          controller.loadProgress.value = progress;
        },
        onTitleChanged: (webViewController, title) {
          print("web -- 标题 : $title");
          controller.setWebTitle(title);
        },
        onReceivedError: (webViewController, request, error) {
          print("加载失败 : ${error.description}");
          LogManager().addLog("加载失败 : ${error.description}");
          ErrorLogUtils.to.logError("加载失败 : ${error.description}", null);
        },
        onUpdateVisitedHistory: (webViewController, url, isReload) {
          print("web -- 更新历史记录 : $url");
          webViewController.canGoBack().then((value){
            controller.canGoBack.value = value;
          });
          webViewController.canGoForward().then((value){
            controller.canGoForward.value = value;
          });
        },
        onAjaxProgress: (controller, ajaxRequest) async{
          print("web -- ajax 请求 : ${ajaxRequest.url}");
          LogManager().addLog("web -- ajax 请求 : ${ajaxRequest.url}");
          ErrorLogUtils.to.logInfo("web -- ajax 请求 : ${ajaxRequest.url}");
          return AjaxRequestAction.PROCEED;
        },
        onAjaxReadyStateChange: (controller, ajaxRequest) async{
          print("web -- ajax 响应 : ${ajaxRequest.responseText}");
          LogManager().addLog("web -- ajax 响应 : ${ajaxRequest.responseText}");
          ErrorLogUtils.to.logInfo("web -- ajax 响应 : ${ajaxRequest.responseText}");
          return AjaxRequestAction.PROCEED;
        },
        onConsoleMessage: (controller, consoleMessage) {
          print("web -- onConsoleMessage : ${consoleMessage.message}");
          LogManager().addLog("web -- onConsoleMessage : ${consoleMessage.message}");
          ErrorLogUtils.to.logInfo("web -- onConsoleMessage : ${consoleMessage.message}");
        },
        onReceivedHttpError: (controller, request, errorResponse) {
          print("web -- onReceivedHttpError : ${errorResponse.statusCode}");
          LogManager().addLog("web -- onReceivedHttpError : ${errorResponse.statusCode}");
          ErrorLogUtils.to.logError("web -- onReceivedHttpError : ${errorResponse.statusCode}", null);
        },
        onLoadResource: (controller, resource) {
          print("web -- onLoadResource : ${resource.toString()}");
          LogManager().addLog("web -- onLoadResource : ${resource.toString()}");
          ErrorLogUtils.to.logInfo("web -- onLoadResource : ${resource.toString()}");
        },
      );
    });
  }
}
