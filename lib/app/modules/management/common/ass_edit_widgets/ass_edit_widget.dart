import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../common/enum/enum.dart';
import '../../manage_content/manage_audio_subtitle_editor/models/audio_dialogue_model.dart';
import 'ass_media_subtitle_editor_widget.dart';
import 'editor_sidebar_btn_widget.dart';
import 'models/ass_waveform_dialogue_model.dart';

class AssEditWidget extends StatefulWidget {
  final String mediaUrl;
  final String ass;
  final String? translateAss;
  final ResourceTypeEnum mediaType;
  final double playbackRate;
  /// 隐藏添加句子
  final bool hideAddSentence;
  /// 隐藏翻译
  final bool hideTranslation;
  /// 右边浮动的工具栏按钮
  final List<EditorSidebarBtnWidget>? rightToolButtons;
  final ValueChanged<AssEditorChangeResult>? onChanged;
  /// 浮动在包络线上方的widget
  final Widget? envelopeTopFloatWidget;
  const AssEditWidget({
    super.key,
    required this.mediaUrl,
    required this.ass,
    this.translateAss,
    required this.mediaType,
    this.playbackRate = 1.0,
    this.onChanged,
    this.hideAddSentence = false,
    this.hideTranslation = false,
    this.rightToolButtons,
    this.envelopeTopFloatWidget,
  });


  @override
  State<AssEditWidget> createState() => _AssEditWidgetState();
}

class _AssEditWidgetState extends State<AssEditWidget> {


  AssWaveformDialogueModel _mapDialogue(DialogueModel dialogue) {
    return AssWaveformDialogueModel(
      index: dialogue.index,
      startTime: dialogue.startTime,
      endTime: dialogue.endTime,
      kTagText: dialogue.kTagText,
      text: dialogue.text,
      kTagList: (dialogue.kTagList ?? <KTagModel>[])
          .map(
            (KTagModel tag) => AssWaveformKTagModel(
              startTime: tag.startTime,
              duration: tag.duration,
              kTagText: tag.kTagText,
              text: tag.text,
              isEdit: tag.isEdit,
            ),
          )
          .toList(),
      isEdit: dialogue.isEdit,
      layerIndex: dialogue.layerIndex,
      prefixStr: dialogue.prefixStr,
      zhDialogueStr: dialogue.zhDialogueStr,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: AssMediaSubtitleEditorWidget(
        mediaUrl: widget.mediaUrl,
        ass: widget.ass,
        translateAss: widget.translateAss,
        mediaType: widget.mediaType,
        playbackRate: widget.playbackRate,
        hideAddSentence: widget.hideAddSentence,
        hideTranslation: widget.hideTranslation,
        rightToolButtons: widget.rightToolButtons,
        envelopeTopFloatWidget: widget.envelopeTopFloatWidget,
        onChanged: widget.onChanged == null
            ? null
            : (AssMediaSubtitleEditorValue value) {
                widget.onChanged!(
                  AssEditorChangeResult(
                    ass: value.ass,
                    translateAss: value.translateAss,
                    dialogueList:
                        value.dialogueList.map(_mapDialogue).toList(),
                  ),
                );
              },
      ),
    );
  }
}
