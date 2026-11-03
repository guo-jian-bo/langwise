
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../app/modules/application/controllers/message_controller.dart';
import '../../app/modules/management/controllers/management_message_controller.dart';
import '../../common/entities/entities.dart';
import '../../common/https/https.dart';
import '../../theme/theme.dart';
import '../utils.dart';

/// mqtt 消息通知的弹窗
class MqttNotificationToast{

  /// 右上角 toast 消息
  static void Function() showToast({
    required PushMessageEntity message,
    void Function(dynamic result)? onPageBack,
  }){

    return BotToast.showCustomNotification(
      align: Alignment.topRight,
      onlyOne: false,
      duration: const Duration(seconds: 5),
      dismissDirections: [DismissDirection.startToEnd],
      wrapToastAnimation: (controller, cancelFunc, widget) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: const Offset(0, 0)).animate(CurvedAnimation(
            parent: controller,
            curve: Curves.decelerate, // 入场时减速，感觉更平滑
          )),
          child: widget,
        );
      },
      toastBuilder: (cancelFunc) {
        return NotificationToastWidget(cancelFunc: cancelFunc, message: message, onPageBack: onPageBack);
      },
    );

  }

  static Future<void> showModal({
    required List<PushMessageEntity> messages,
    void Function(dynamic result)? onPageBack,
  }) async{
    if(messages.isEmpty) return;

    BotToast.showAnimationWidget(
      allowClick: false,
      onlyOne: false,
      backgroundColor: Colors.black54,
      wrapAnimation: (controller, cancelFunc, widget) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: controller,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
          child: widget,
        );
      },
      wrapToastAnimation: (controller, cancelFunc, widget) {
        final CurvedAnimation curvedAnimation = CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1).animate(curvedAnimation),
            child: widget,
          ),
        );
      },
      toastBuilder: (cancelFunc) {
        return NotificationModalWidget(
          messages: messages,
          cancelFunc: cancelFunc,
          onPageBack: onPageBack,
        );
      },
      animationDuration: const Duration(milliseconds: 300),
    );

  }
}


class NotificationToastWidget extends StatefulWidget {
  final void Function() cancelFunc;
  final void Function(dynamic result)? onPageBack;
  final PushMessageEntity message;
  const NotificationToastWidget({super.key, required this.cancelFunc, required this.message, this.onPageBack});

  @override
  State<NotificationToastWidget> createState() => _NotificationToastWidgetState();
}

class _NotificationToastWidgetState extends State<NotificationToastWidget> {

  /// 是否已经点击 点击之后禁用点击
  bool isClick = false;

  /// 点击通知
  Future<void> checkNotification() async{
    // 如果有新手任务进行中就不允许点击
    // if(GuideManager.instance.isGuiding) return;

    if(isClick) return;
    isClick = true;
    if(mounted) setState(() {});
    readMessage();

    if(widget.message.displayOperate == null || widget.message.displayOperate == 0){

      if(widget.message.jump != null){
        // 如果jump不为null 直接跳转页面
        widget.cancelFunc.call();
        dynamic res = await JumpPageUtils.jumpPage(widget.message);
        widget.onPageBack?.call(res);
      }else{
        // 如果jump为null 弹出默认弹窗
        if(widget.message.title == null && widget.message.content == null) return;
        if(Get.context == null) return;
        widget.cancelFunc.call();

        MqttNotificationToast.showModal(messages: [widget.message], onPageBack: widget.onPageBack);

      }
      
    }else if(widget.message.displayOperate == 1){

      // 一定弹model，如果jump != null 显示按钮“去查看”
      if(widget.message.title == null && widget.message.content == null) return;
      if(Get.context == null) return;
      widget.cancelFunc.call();
      MqttNotificationToast.showModal(messages: [widget.message], onPageBack: widget.onPageBack);

    }else if(widget.message.displayOperate == 2){
      if(widget.message.jump == null){
        widget.cancelFunc.call();
      }else{
        widget.cancelFunc.call();
        dynamic res = await JumpPageUtils.jumpPage(widget.message);
        widget.onPageBack?.call(res);
      }
    }else if(widget.message.displayOperate == 3){
      widget.cancelFunc.call();
    }

  }

  /// 读消息
  void readMessage(){
    if(widget.message.categoryIsManage){
      bool isRegisteredManage = Get.isRegistered<ManageMessageController>();
      if(isRegisteredManage){
        Get.find<ManageMessageController>().readMessage(widget.message);
      }else{
        readMessageReq();
      }
    }else{
      bool isRegistered = Get.isRegistered<MessageController>();
      if(isRegistered) {
        Get.find<MessageController>().readMessage(widget.message);
      }
    }
  }

  /// 读消息
  Future<void> readMessageReq() async{
    if(widget.message.read == 1) return;
    if(widget.message.uid == null) return;
    try {
      bool res = await AccountUtil.readMessage([widget.message.uid!]);
      if(!res) return;
      widget.message.read = 1;
    } catch (_) {
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 640.wMin + 22.wMin,
      margin: EdgeInsets.only(right: 20.wMin, top: 20.wMin), 
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          IgnorePointer(
            ignoring: isClick,
            child: TapScaleWidget(
              onTap: () {
                checkNotification();
              },
              sclae: 1,
              child: Container(
                width: 640.wMin,
                height: 122.wMin,
                padding: EdgeInsets.symmetric(horizontal: 20.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.wMin),
                  color: AppTheme.cInverseOverlay2.color,
                  border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      offset: Offset(0, 6.wMin),
                      blurRadius: 10.wMin,
                    ),
                  ],
                ),
                child: _buildContentWidget(),
              ),
            ),
          ),

          Positioned(
            left: 0,
            top: 0,
            child: _buildCancelWidget(),
          ),

        ],
      ),
    );
  }

  Widget _buildContentWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 12.wMin,
      children: [
        Text(
          widget.message.title??"",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 28.wMin,
            color: AppTheme.cTextPrimary.color,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          widget.message.content??"",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 22.wMin,
            color: AppTheme.cTextPrimary.color.withValues(alpha: 0.8),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildCancelWidget(){
    return TapScaleWidget(
      onTap: widget.cancelFunc,
      sclae: 1,
      child: Container(
        width: 38.wMin,
        height: 38.wMin,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.cInverseOverlay2.color,
          border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
        ),
        child: SvgPicture.asset(
          "assets/svg/public/x.svg",
          width: 18.wMin,
          colorFilter: ColorFilter.mode(AppTheme.cTextTertiary.color, BlendMode.srcIn),
        ),
      
      ),
    );
  }

}


class NotificationModalWidget extends StatefulWidget {
  final List<PushMessageEntity> messages;
  final void Function() cancelFunc;
  final void Function(dynamic result)? onPageBack;
  const NotificationModalWidget({
    super.key,
    required this.messages,
    required this.cancelFunc,
    this.onPageBack,
  });

  @override
  State<NotificationModalWidget> createState() => _NotificationModalWidgetState();
}

class _NotificationModalWidgetState extends State<NotificationModalWidget> {
  
  final PageController _pageController = PageController();

  int _currentPage = 0;

  List<PushMessageEntity> _messages = [];

  @override
  void initState(){
    super.initState();
    _messages = widget.messages;
    _getMessageDetail();

    _pageController.addListener(() {
      // 四舍五入
      _currentPage = _pageController.page?.round()?? 0;
      if(mounted) setState(() {});
    });

  }

  @override
  void dispose(){
    super.dispose();
    _pageController.dispose();
  }


  /// 获取消息详情
  Future<void> _getMessageDetail() async{
    if(widget.messages.isEmpty) return;
    try {

      List<int> uids = [];
      for(int i = 0; i < _messages.length; i++){
        if((_messages[i].content??"").isNotEmpty) continue;
        if(_messages[i].uid == null) continue;
        uids.add(_messages[i].uid!);
      }
      if(uids.isEmpty) return;

      Map<String, dynamic> parameters = {
        "offset": 0,
        "limit": 50,
        "order": "-uid",
        "notifyIds": uids,
      };

      ListResponseEntity<PushMessageEntity>? res = await AccountUtil.getMessageList(parameters: parameters);
      if(res == null) return;
      List<PushMessageEntity> datas = res.datas??[];
      for(int i = 0; i < _messages.length; i++){
        for(int j = 0; j < datas.length; j++){
          if(_messages[i].uid == datas[j].uid){
            _messages[i].content = datas[j].content;
            break;
          }
        }
      }
      if(mounted) setState(() {});
      
    } catch (_) {
      
    }
  }


  @override
  Widget build(BuildContext context) {
    return Overlay(
      initialEntries: [
        OverlayEntry(
          canSizeOverlay: true,
          builder: (_) {
            return Material(
              type: MaterialType.transparency,
              child: Center(
                child: _buildMsgBodyWidget(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMsgBodyWidget(){

    bool prevDisabled = _currentPage <= 0;
    bool nextDisabled = _currentPage >= _messages.length - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 24.wMin,
      children: [
        _buildNextPrevWidget(
          svg: "assets/svg/public/icon_arrow_back.svg",
          disabled: prevDisabled,
          onTap: () {
            _pageController.previousPage(duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
          },
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            _buildMsgBodyListWidget(),
            _buildCloseWidget(),
          ],
        ),
        _buildNextPrevWidget(
          svg: "assets/svg/public/icon_arrow_right.svg",
          disabled: nextDisabled,
          onTap: () {
            _pageController.nextPage(duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
          },
        ),
      ],
    );
  }


  Widget _buildMsgBodyListWidget(){
    return Container(
      width: 1400.wMin,
      height: 1000.wMin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.wMin),
        border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
        color: AppTheme.cSurfaceSecondary.color,
      ),
      child: PageView.builder(
        controller: _pageController,
        itemCount: _messages.length,
        physics: const ClampingScrollPhysics(),
        itemBuilder: (context, index){
          return _buildMsgContentItemWidget(_messages[index]);
        },
      ),
    );
  }


  Widget _buildMsgContentItemWidget(PushMessageEntity message){
    return Column(
      children: [
    
        Container(
          padding: EdgeInsets.symmetric(horizontal: 84.wMin, vertical: 16.wMin),
          child: Text(
            message.title??"",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 38.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(height: 1.wMin, color: AppTheme.cBorderPrimary.color),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(32.wMin),
            child: Container(
              width: double.infinity,
              color: Colors.transparent,
              child: _buildMsgContentTextWidget(message),
            ),
          ),
        ),
        Container(height: 1.wMin, color: AppTheme.cBorderPrimary.color),
        Container(
          padding: EdgeInsets.all(24.wMin),
          alignment: Alignment.center,
          child: _buildButtonsWidget(message),
        ),
      ],
    );
  }

  Widget _buildMsgContentTextWidget(PushMessageEntity message){
    if(message.isContentMd){
      return AppMarkdownWidget(
        data: message.content ?? "",
      );
    }
    return Text(
      message.content??"",
      style: TextStyle(
        fontSize: 28.wMin,
        color: AppTheme.cTextPrimary.color,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  

  /// 上下条按钮
  Widget _buildNextPrevWidget({
    required String svg,
    bool disabled = false,
    VoidCallback? onTap,
  }){
    return IgnorePointer(
      ignoring: disabled,
      child: TapScaleWidget(
        sclae: 1.05,
        onTap: onTap,
        child: Container(
          width: 68.wMin,
          height: 68.wMin,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.cSurfacePrimary.color,
            border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
          ),
          child: SvgPicture.asset(
            svg,
            width: 38.wMin,
            colorFilter: ColorFilter.mode(
              AppTheme.cTextPrimary.color.withValues(alpha: disabled ? 0.4 : 1), 
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonsWidget(PushMessageEntity message){
    if(message.jump == null){
      return ButtonWidget(
        text: "知道了",
        height: 72.wMin,
        width: 500.wMin,
        borderRadius: 12.wMin,
        color: AppTheme.cSurfaceInfo.color,
        fontWeight: FontWeight.w500,
        fontSize: 28.wMin,
        sclae: 1.01,
        onTap: () {
          widget.cancelFunc.call();
        },
      );
    }
    return ButtonWidget(
      text: "去查看",
      height: 72.wMin,
       width: 500.wMin,
      borderRadius: 12.wMin,
      color: AppTheme.cSurfaceInfo.color,
      fontWeight: FontWeight.w500,
      fontSize: 28.wMin,
      sclae: 1.02,
      onTap: () async{
        widget.cancelFunc.call();
        dynamic res = await JumpPageUtils.jumpPage(message);
        widget.onPageBack?.call(res);
      },
    );
  }

  Widget _buildCloseWidget(){
    return Positioned(
      right: 22.wMin,
      top: 22.wMin,
      child: TapScaleWidget(
        sclae: 1.05,
        onTap: widget.cancelFunc,
        child: Container(
          width: 48.wMin,
          height: 48.wMin,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.cSurfaceQuaternary.color,
          ),
          child: SvgPicture.asset(
            "assets/svg/public/x.svg",
            width: 24.wMin,
            height: 24.wMin,
            colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }


}
