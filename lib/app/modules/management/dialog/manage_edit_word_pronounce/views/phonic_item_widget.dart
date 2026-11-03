import 'package:flutter/material.dart';
import 'package:langwise/app/modules/management/common/manage_ipa_input_widget.dart';
import 'package:langwise/common/entities/entities.dart' show EnWordPronounceEntityPhonic;
import 'package:ui_essentials/ui_essentials.dart';

/// 音素项组件
class PhonicItemWidget extends StatelessWidget {
  final EnWordPronounceEntityPhonic phonic;
  
  /// IPA错误重置回调
  final void Function(EnWordPronounceEntityPhonic phonic)? onIpaError;
  
  /// 字母错误重置回调
  final void Function(EnWordPronounceEntityPhonic phonic)? onGraphemesError;
  
  /// 位置错误重置回调
  final void Function(EnWordPronounceEntityPhonic phonic)? onPositionError;

  const PhonicItemWidget({
    Key? key, 
    required this.phonic,
    this.onIpaError,
    this.onGraphemesError,
    this.onPositionError,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      key: PageStorageKey<String>(phonic.uuid),
      children: [
        Expanded(
          child: ManageIPAInputWidget(
            title: "IPA",
            hintText: "请输入音素",
            controller: phonic.ipaTextController,
            readOnly: false,
            error: phonic.ipaError,
            onTap: () {
              if (onIpaError != null) {
                onIpaError!(phonic);
              }
            },
          ),
        ),
        SizedBox(width: 12.ww),
        Expanded(
          child: ManageIPAInputWidget(
            title: "字母",
            hintText: "请输入字母",
            controller: phonic.graphemesTextController,
            readOnly: false,
            error: phonic.graphemesError,
            onTap: () {
              if (onGraphemesError != null) {
                onGraphemesError!(phonic);
              }
            },
          ),
        ),
        SizedBox(width: 12.ww),
        Expanded(
          child: ManageIPAInputWidget(
            title: "位置",
            hintText: "请输入位置,用逗号分隔",
            controller: phonic.positionController,
            readOnly: false,
            error: phonic.positionError,
            onTap: () {
              if (onPositionError != null) {
                onPositionError!(phonic);
              }
            },
          ),
        ),
      ],
    );
  }
}
