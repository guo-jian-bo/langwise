
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';

/// 选择通知模版
class ManageSelectNoticeTempDialog{

  static Future<NotifyTempEntity?> show({
    required BuildContext context,
    int? initUid,
    String? title,
    String? buttonText,
  }) async{
    return await showCupertinoDialog<NotifyTempEntity?>(
      context: context,
      builder: (context) {
        return ManageSelectNoticeTempDialogWidget(initUid: initUid, title: title, buttonText: buttonText);
      },
    );
  }

}


class ManageSelectNoticeTempDialogWidget extends StatefulWidget {
  final int? initUid;
  final String? title;
  final String? buttonText;
  const ManageSelectNoticeTempDialogWidget({super.key, this.initUid, this.title, this.buttonText});

  @override
  State<ManageSelectNoticeTempDialogWidget> createState() => _ManageSelectNoticeTempDialogWidgetState();
}

class _ManageSelectNoticeTempDialogWidgetState extends State<ManageSelectNoticeTempDialogWidget> {

  /// 选择的uid
  NotifyTempEntity? selected;

  List<GroupNotifyTempEntityEntityList> noticeTempList = [];

  @override
  void initState() {
    super.initState();
    getNoticeTempList();
  }

  /// 获取消息模版列表
  Future<void> getNoticeTempList() async{
    try {
      ToastUtils.showLoading();
      GroupNotifyTempEntityEntity? res = await AccountConsoleRequest.getNoticeTempSendList();
      if(res == null) return;
      List<GroupNotifyTempEntityEntityList?> list = res.list??[];
      for(var item in list){
        if(item == null) continue;
        noticeTempList.add(item);
        item.templates?.forEach((element) {
          if(element?.uid == widget.initUid){
            selected = element;
          }
        });
      }
      if(mounted) setState(() {});

    } finally{
      ToastUtils.hideLoading();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DialogUserWidget(
      title: widget.title ?? "选择通知模版",
      width: 1680.wMin,
      child: SizedBox(
        height: 800.wMin,
        child: Column(
          children: [
            Expanded(child: _buildListWidget()),
            Container(
              height: 1.wMin,
              color: AppTheme.cBorderPrimary.color,
            ),
            SizedBox(height: 24.wMin),
            _buildButtonsWidget(),
            SizedBox(height: 24.wMin),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonsWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.wMin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ButtonWidget(
            text: widget.buttonText ?? "确认选择",
            padding: EdgeInsets.symmetric(vertical: 12.wMin, horizontal: 32.wMin),
            borderRadius: 8.wMin,
            fontSize: 24.wMin,
            fontWeight: FontWeight.w500,
            sclae: 1.02,
            onTap: () {
              if(selected == null) {
                ToastUtils.showToast(text: "请选择模版");
                return;
              }
              Get.back(result: selected);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListWidget(){
    return ListView.separated(
      itemCount: noticeTempList.length,
      padding: EdgeInsets.only(left: 32.wMin, right: 32.wMin, bottom: 24.wMin),
      separatorBuilder: (context, index) => SizedBox(height: 24.wMin),
      itemBuilder: (context, index) {
        return _buildListGropWidget(noticeTempList[index]);
      },
    );
  }

  Widget _buildListGropWidget(GroupNotifyTempEntityEntityList temp){
    List<NotifyTempEntity?> templates = temp.templates??[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          temp.title??"",
          style: TextStyle(
            fontSize: 20.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextTertiary.color,
          ),
        ),
        SizedBox(height: 10.wMin),
        GridView.builder(
          itemCount: templates.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12.wMin,
            crossAxisSpacing: 12.wMin,
            mainAxisExtent: 152.wMin,
          ),
          itemBuilder: (context, index) {
            return _buildListGropItemWidget(templates[index]);
          },
        ),

      ],
    );
  }

  Widget _buildListGropItemWidget(NotifyTempEntity? item){
    bool isSelected = item?.uid == selected?.uid;
    return TapScaleWidget(
      onTap: () {
        selected = item;
        if(mounted) setState(() {});
      },
      sclae: 1,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: isSelected ? AppTheme.cSurfaceBrand.color.withValues(alpha: 0.1) : AppTheme.cSurfaceLayerBase.color,
          border: Border.all(
            color: isSelected ? AppTheme.cSurfaceBrand.color.withValues(alpha: 0.6) : AppTheme.cBorderNone.color,
            width: 1.wMin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item?.name??"",
                    style: TextStyle(
                      fontSize: 28.wMin,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.cTextPrimary.color,
                    ),
                  ),
                ),
                SizedBox(width: 12.wMin),
                SvgPicture.asset(
                  isSelected ? "assets/svg/public/icon_radio.svg" : "assets/svg/public/icon_radio_un.svg",
                  width: 32.wMin,
                  colorFilter: isSelected ? null : ColorFilter.mode(AppTheme.cSurfaceQuaternary.color, BlendMode.srcIn),
                ),
              ],
            ),
            SizedBox(height: 6.wMin),
            Text(
              item?.notifyTitle??"",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 20.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextSecondary.color,
              ),
            ),
      
          ],
        ),
      ),
    );
  }



}

