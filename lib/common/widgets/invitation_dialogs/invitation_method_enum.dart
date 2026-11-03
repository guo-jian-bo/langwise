
import 'dart:ui';

enum InvitationMethodEnum{
  /// 手机号邀请
  phone("assets/svg/public/icon_phone.svg", Color(0xffF97316)),
  /// 二维码邀请
  qrcode("assets/svg/public/icon_qrcode.svg", Color(0xffF59E0B)),
  /// 微信邀请方式
  wechat("assets/svg/public/icon_link.svg", Color(0xff22C55E));

  final String iconPath;
  final Color color;

  const InvitationMethodEnum(this.iconPath, this.color);
}