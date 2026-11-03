import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../controllers/management_message_controller.dart';

class ManageSettingDialog{

  static Future<void> show(BuildContext context) async{
    return await showCupertinoDialog(
      context: context,
      builder: (context) {
        return const ManageSettingDialogWidget();
      },
    );
  }

}

class ManageSettingDialogWidget extends StatefulWidget {
  const ManageSettingDialogWidget({super.key});

  @override
  State<ManageSettingDialogWidget> createState() => _ManageSettingDialogWidgetState();
}

class _ManageSettingDialogWidgetState extends State<ManageSettingDialogWidget> {
  final ManageMessageController _messageController = Get.find<ManageMessageController>();

  @override
  Widget build(BuildContext context) {
    return DialogUserWidget(
      title: "后台管理设置",
      width: 800.wMin,
      child: Container(
        height: 600.wMin,
        padding: EdgeInsets.symmetric(horizontal: 32.wMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMessageWidget(),
            SizedBox(height: 32.wMin),
          ],
        ),
      ),
    );
  }

  /// 设置消息
  Widget _buildMessageWidget(){
    return Obx((){
      return CardTitleSwitchWidget(
        title: "是否打开应用内消息通知", 
        subContent: "仅后台管理消息生效",
        value: _messageController.isShowMessage.value,
        padding: EdgeInsets.all(16.wMin),
        backColor: AppTheme.cSurfaceTertiary.color,
        onChanged: (value) {
          _messageController.toggleShowMessage();
        },
      );
    });
  }

}