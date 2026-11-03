import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/utils/manage_auth_utils.dart';

class ManageAuthBoxWidget extends StatelessWidget {
  /// 权限code [ManageAuthCode]
  final List<String> authCodes;
  /// 是否任意权限满足即可，默认为 false，表示需要同时满足所有权限
  final bool isAny;
  /// 取消权限判断，默认为 false
  final bool isCancel;
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  /// 管理端判断widget是否显示
  const ManageAuthBoxWidget({
    super.key,
    required this.authCodes,
    this.isAny = false,
    this.isCancel = false,
    this.child,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    if(isCancel){
      return Container(
        padding: padding,
        margin: margin,
        child: child,
      );
    }
    return Obx((){
      // bool isAdmin = UserStore.to.userInfo.value.isAdmin; // auth待定
      // if(!isAdmin){
        if(isAny){
          if (!ManageAuthUtils.isAnyAuth(authCodes)) return const SizedBox.shrink();
        }else{
          if (!ManageAuthUtils.isAuths(authCodes)) return const SizedBox.shrink();
        }
      // }
      return Container(
        padding: padding,
        margin: margin,
        child: child,
      );
    });
  }
}