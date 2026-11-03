import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_button.dart';
import 'package:langwise/app/modules/management/common/manage_select_option_widget.dart';
import 'package:langwise/common/https/subscribe.dart';
import 'package:ui_essentials/ui_essentials.dart';

/// 推送类型：0 = 立即推送, 1 = 定时推送
class SubscribePushSettingDialog {
  static Future<bool?> show({
    required BuildContext context,
    required int collectionId,
  }) async {
    return await showCupertinoDialog<bool?>(
      context: context,
      builder: (context) => _SubscribePushSettingDialogWidget(
        collectionId: collectionId,
      ),
    );
  }
}

class _SubscribePushSettingDialogWidget extends StatefulWidget {
  final int collectionId;

  const _SubscribePushSettingDialogWidget({
    required this.collectionId,
  });

  @override
  State<_SubscribePushSettingDialogWidget> createState() => __SubscribePushSettingDialogWidgetState();
}

class __SubscribePushSettingDialogWidgetState extends State<_SubscribePushSettingDialogWidget> {
  late int _pushType;
  final List<String> _options = ['从先到后推送', '从后到先推送', '随机'];

  @override
  void initState() {
    super.initState();
    _pushType = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          width: 520.ww,
          padding: EdgeInsets.symmetric(horizontal: 32.ww, vertical: 32.wh),
          decoration: BoxDecoration(
            color: const Color(0xFF26292A),
            borderRadius: BorderRadius.circular(24.wMin),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '设置推送方式',
                style: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 24.wMin),
              Text(
                '推送方式',
                style: TextStyle(
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 12.wMin),
              ManageSelectWidget(
                title: '',
                hintText: '请选择推送方式',
                value: _options[_pushType],
                readOnly: false,
                required: true,
                options: _options,
                onChanged: (String value, int index) {
                  setState(() {
                    _pushType = index;
                  });
                },
              ),
              SizedBox(height: 32.wMin),
              _buildBottomButtons(),
              SizedBox(height: 24.wMin),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ManageButton(
          text: '取消',
          width: 100.ww,
          height: 40.wh,
          color: Colors.white,
          borderColor: const Color(0xFFE5E7EB),
          style: TextStyle(
            fontSize: 16.wMin,
            color: const Color(0xFF111827),
            fontWeight: FontWeight.w400,
          ),
          onTap: () {
            Get.back();
          },
        ),
        SizedBox(width: 16.ww),
        ManageButton(
          text: '保存',
          width: 120.ww,
          height: 40.wh,
          color: const Color(0xFF2563EB),
          borderColor: Colors.transparent,
          style: TextStyle(
            fontSize: 16.wMin,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          onTap: () async {
            Map<String, String> caType = {"从先到后推送": "HEAD", "从后到先推送": "TAIL", "随机": "RANDOM"};
            final res = await SubscribeRequest.updateCollectionPushType(
              collectionId: widget.collectionId,
              pushType: caType[_options[_pushType]] ?? 'HEAD',
            );
            if (res != null && res.data == '修改成功') {
              Get.back(result: true);
            }
          },
        ),
      ],
    );
  }
}
