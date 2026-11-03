import '../../app/routes/routes.dart';
import 'entities.dart';


class NotifyTempEntity {
/*
{
  "uid": 4,
  "name": "name",
  "type": "learnContinue",
  "notifyTitle": "push 标题",
  "notifyDesc": "push 内容",
  "notifyContentType": "md",
  "notifyContentTypeTitle": "Markdown",
  "notifyContent": "# 🎉 欢迎来到《乃师》！送你一份见面礼。\n\n## Hi 新同学，很兴遇见你！\n\n送你 **Max 会员**，全场会员功能都为你敞开。  \n感受情景化学习英语的乐趣，走进 **「甄听」** 与 **「甄读」** 的世界，  \n让语言在真实语境中自然生长。\n\n趁这个机会，尽情探索吧。  \n**乃师** 陪你，让每天都有新收获。\n\n### 在以下页面可以看到会员时长：\n![我的](1.png)\n![会员时长](2.png)",
  "notifyJump": {
    "type": "",
    "url": ""
  },
  "notifyDisplay": 1,
  "typeContentId": 4,
  "access": "NORMAL",
  "created": "2026-07-13T06:16:22.535+00:00",
  "updated": "2026-07-13T06:16:22.535+00:00"
} 
*/

  int? uid;
  String? name;
  String? type;
  String? notifyTitle;
  String? notifyDesc;
  String? notifyContentType;
  String? notifyContentTypeTitle;
  String? notifyContent;
  PushMessageEntityJump? notifyJump;
  int? notifyDisplay;
  int? typeContentId;
  String? access;
  String? created;
  String? updated;

  /// 根据notifyJump?.code获取页面的名称
  String? get jumpPageCodeTitle {
    if(notifyJump?.code == null) return null;
    if(notifyJump?.code == null) return null;
    if(notifyJump?.code == AppRoutesCode.webView){
      String portrait = notifyJump?.params?['portrait'] == true ? "竖屏" : "横屏";
      String openExternalBrowser = notifyJump?.params?['openExternalBrowser'] == true ? "在外部浏览器打开" : "在应用内打开";
      String hideAppBar = notifyJump?.params?['hideAppBar'] == true ? "隐藏AppBar" : "显示AppBar";
      return "url: ${notifyJump?.params?['url']??''}, $portrait, $openExternalBrowser, $hideAppBar";
    }
    final AppRoutesGroupData? jumpType = _findJumpTypeByCode(notifyJump?.code??'');
    return "${jumpType?.title??''} ${notifyJump?.code??''}";
  }

  AppRoutesGroupData? _findJumpTypeByCode(String code){
    return AppRoutesGroup.webViewMap[code] ??
        AppRoutesGroup.learningMap[code] ??
        AppRoutesGroup.contentMap[code] ??
        AppRoutesGroup.userMap[code];
  }

  /// 获取链接地址
  String? get jumpUrl {
    if(notifyJump?.code == null) return null;
    if(notifyJump?.code == AppRoutesCode.webView){
      return "url: ${notifyJump?.params?['url']??''}, portrait: ${notifyJump?.params?['portrait']}";
    }
    return notifyJump?.code??'';
  }

  /// 获取链接类型
  String? get jumpType {
    if(notifyJump?.code == null) return null;
    if(notifyJump?.code == AppRoutesCode.webView){
      return "H5链接";
    }
    return "DeepLink";
  }

  NotifyTempEntity({
    this.uid,
    this.name,
    this.type,
    this.notifyTitle,
    this.notifyDesc,
    this.notifyContentType,
    this.notifyContentTypeTitle,
    this.notifyContent,
    this.notifyJump,
    this.notifyDisplay,
    this.typeContentId,
    this.access,
    this.created,
    this.updated,
  });
  NotifyTempEntity.fromJson(Map<String, dynamic> json) {
    uid = json['uid']?.toInt();
    name = json['name']?.toString();
    type = json['type']?.toString();
    notifyTitle = json['notifyTitle']?.toString();
    notifyDesc = json['notifyDesc']?.toString();
    notifyContentType = json['notifyContentType']?.toString();
    notifyContentTypeTitle = json['notifyContentTypeTitle']?.toString();
    notifyContent = json['notifyContent']?.toString();
    notifyJump = (json['notifyJump'] != null) ? PushMessageEntityJump.fromJson(json['notifyJump']) : null;
    notifyDisplay = json['notifyDisplay']?.toInt();
    typeContentId = json['typeContentId']?.toInt();
    access = json['access']?.toString();
    created = json['created']?.toString();
    updated = json['updated']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = uid;
    data['name'] = name;
    data['type'] = type;
    data['notifyTitle'] = notifyTitle;
    data['notifyDesc'] = notifyDesc;
    data['notifyContentType'] = notifyContentType;
    data['notifyContentTypeTitle'] = notifyContentTypeTitle;
    data['notifyContent'] = notifyContent;
    if (notifyJump != null) {
      data['notifyJump'] = notifyJump!.toJson();
    }
    data['notifyDisplay'] = notifyDisplay;
    data['typeContentId'] = typeContentId;
    data['access'] = access;
    data['created'] = created;
    data['updated'] = updated;
    return data;
  }
}
