import 'package:flutter/material.dart';
import 'package:langwise/app/modules/management/common/manage_ipa_input_widget.dart';
import 'package:langwise/common/entities/entities.dart' show EnWordPronounceEntitySyllable;
import 'package:ui_essentials/ui_essentials.dart';

/// 音节项组件
class SyllableItemWidget extends StatelessWidget {
  final EnWordPronounceEntitySyllable syllable;
  
  /// IPA错误重置回调
  final void Function(EnWordPronounceEntitySyllable syllable)? onIpaError;
  
  /// 字母错误重置回调
  final void Function(EnWordPronounceEntitySyllable syllable)? onGraphemesError;
  
  /// 位置错误重置回调
  final void Function(EnWordPronounceEntitySyllable syllable)? onPositionError;

  const SyllableItemWidget({
    Key? key, 
    required this.syllable,
    this.onIpaError,
    this.onGraphemesError,
    this.onPositionError,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ManageIPAInputWidget(
            title: "IPA",
            hintText: "请输入音节",
            controller: syllable.ipaTextController,
            readOnly: false,
            error: syllable.ipaError,
            onTap: () {
              if (onIpaError != null) {
                onIpaError!(syllable);
              }
            },
          ),
        ),
        SizedBox(width: 12.ww),
        Expanded(
          child: ManageIPAInputWidget(
            title: "字母",
            hintText: "请输入字母",
            controller: syllable.graphemesTextController,
            readOnly: false,
            error: syllable.graphemesError,
            onTap: () {
              if (onGraphemesError != null) {
                onGraphemesError!(syllable);
              }
            },
          ),
        ),
        SizedBox(width: 12.ww),
        Expanded(
          child: ManageIPAInputWidget(
            title: "位置",
            hintText: "请输入位置,用逗号分隔",
            controller: syllable.positionController,
            readOnly: false,
            error: syllable.positionError,
            onTap: () {
              if (onPositionError != null) {
                onPositionError!(syllable);
              }
            },
          ),
        ),
      ],
    );
  }
}
