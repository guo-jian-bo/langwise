import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_button.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../common/entities/entities.dart';





class ManageEnWordAudioSyllableDialog {
  static Future<ManageEnglishContentManagementWordAudioModel?> show({
    required BuildContext context,
    required ManageEnglishContentManagementWordAudioModel item,
  }) async {
    return await showCupertinoDialog<
        ManageEnglishContentManagementWordAudioModel?>(
      context: context,
      builder: (context) =>
          ManageEnWordAudioSyllableDialogWidget(
              item: item),
    );
  }
}

class ManageEnWordAudioSyllableDialogWidget
    extends StatefulWidget {
  final ManageEnglishContentManagementWordAudioModel item;

  const ManageEnWordAudioSyllableDialogWidget(
      {super.key, required this.item});

  @override
  State<ManageEnWordAudioSyllableDialogWidget>
      createState() =>
          _ManageEnWordAudioSyllableDialogWidgetState();
}

class _ManageEnWordAudioSyllableDialogWidgetState
    extends State<ManageEnWordAudioSyllableDialogWidget> {
  List<int> allGraphemes = []; //所有的graphemes
  List<int> allIpas = []; //所有的ipas
  List<int> notSelectGraphemes = []; //不能选择的graphemes
  List<int> notSelectIpas = []; //不能选择的ipas
  List<int> selectedGraphemes = []; //选中的graphemes
  List<int> selectedIpas = []; //选中的ipas

  @override
  void initState() {
    super.initState();

    for (var i = 0; i < (widget.item.content?.length ?? 0); i++) {
      allGraphemes.add(i);
    }
    for (var i = 0; i < (widget.item.ipa?.length ?? 0); i++) {
      allIpas.add(i);
    }
    
    List<ManageEnglishContentManagementWordAudioSoundBlockDTOSyllableModel>
        syllables = widget.item.soundBlockDTO?.syllables ?? [];
    for (var i = 0; i < syllables.length; i++) {
      ManageEnglishContentManagementWordAudioSoundBlockDTOSyllableModel
          syllable = syllables[i];
      List<int> positions = syllable.positions ?? [];
      for (var j = 0; j < positions.length; j++) {
        notSelectGraphemes.add(positions[j]);
      }

      List<int> ipaPositions = syllable.ipaPositions ?? [];
      for (var j = 0; j < ipaPositions.length; j++) {
        notSelectIpas.add(ipaPositions[j]);
      } 
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30.ww, vertical: 30.wh),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.wMin),
            border: Border.all(
              color: const Color(0xff444B5F),
              width: 1.wMin, // 边框宽度
            ),
            color: const Color(0xff181B25),
          ),
          width: 1000.ww,
          height: 600.wh,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '添加词典音节划分',
                style: TextStyle(fontSize: 24.wMin, color: Colors.white),
              ),
              SizedBox(height: 20.wMin),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 30.wMin,
                  vertical: 20.wMin,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF23253A),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: _buildContentWidget(),
              ),
              SizedBox(height: 40.wMin),
              _buildBottomWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentWidget() {
    String ipaStr = widget.item.ipa ?? '';
    String graphemeStr = widget.item.content ?? '';

    String grapheme = '';
    for (var i = 0; i < selectedGraphemes.length; i++) {
      if (i > 0) {
        if (selectedGraphemes[i] - selectedGraphemes[i - 1] != 1) {
          grapheme += '_' + graphemeStr[selectedGraphemes[i]];
          continue;
        }
      }
      grapheme += graphemeStr[selectedGraphemes[i]];
    }

    String ipa = '';
    for (var i = 0; i < selectedIpas.length; i++) {
      ipa += ipaStr[selectedIpas[i]];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '选择字母',
          style: TextStyle(fontSize: 14.wMin, color: Colors.white),
        ),
        SizedBox(height: 10.wMin),
        _buildChooseLetterWidget(),
        SizedBox(height: 10.wMin),
        Text(
          '选择IPA',
          style: TextStyle(fontSize: 14.wMin, color: Colors.white),
        ),
        SizedBox(height: 10.wMin),
        _buildChooseIpaWidget(),
        SizedBox(height: 20.wMin),
        Text(
          '预览',
          style: TextStyle(fontSize: 14.wMin, color: Colors.white),
        ),
        SizedBox(height: 10.wMin),
        Row(
          children: [
            Text(
              grapheme,
              style: TextStyle(fontSize: 28.wMin, color: Colors.white),
            ),
            const SizedBox(width: 15),
            Text(
              selectedIpas.isEmpty ? '' : '/$ipa/',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 20.wMin,
                fontFamily: 'AndikaRegular',
              ),
            ),
            const SizedBox(width: 15),
            Text(
              selectedGraphemes.isEmpty
                  ? ''
                  : '位置: ${selectedGraphemes.join(',')}',
              style: TextStyle(color: Colors.white54, fontSize: 16.wMin),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildChooseLetterWidget() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < allGraphemes.length; i++)
              _buildLetterWidget(allGraphemes[i]),
          ],
        ),
        SizedBox(height: 5.wMin),
        Text(
          '已选字母位置: ${selectedGraphemes.join(',')}',
          style: TextStyle(color: Colors.white54, fontSize: 14.wMin),
        ),
      ],
    );
  }

  Widget _buildLetterWidget(int letterIndex) {
    Color backgroundColor = Colors.transparent;
    Color textColor = Colors.white;
    if (notSelectGraphemes.contains(letterIndex)) {
      textColor = Colors.grey;
    }

    if (selectedGraphemes.contains(letterIndex)) {
      backgroundColor = Colors.blue.withOpacity(0.5);
    }

    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (notSelectGraphemes.contains(letterIndex)) {
              return;
            }

            if (selectedGraphemes.contains(letterIndex)) {
              selectedGraphemes.remove(letterIndex);
            } else {
              selectedGraphemes.add(letterIndex);
            }

            setState(() {});
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 5.wMin),
            color: backgroundColor,
            child: Text(
              widget.item.content![letterIndex],
              style: TextStyle(fontSize: 30.wMin, color: textColor),
            ),
          ),
        ),
        SizedBox(width: 10.wMin),
      ],
    );
  }

  Widget _buildChooseIpaWidget() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < allIpas.length; i++)
              _buildIpaWidget(allIpas[i]),
          ],
        ),
        SizedBox(height: 5.wMin),
        Text(
          '已选字母位置: ${selectedIpas.join(',')}',
          style: TextStyle(color: Colors.white54, fontSize: 14.wMin),
        ),
      ],
    );
  }

  Widget _buildIpaWidget(int ipaIndex) {
    Color backgroundColor = Colors.transparent;
    Color textColor = Colors.blue;
    if (notSelectIpas.contains(ipaIndex)) {
      textColor = Colors.grey;
    }

    if (selectedIpas.contains(ipaIndex)) {
      backgroundColor = Colors.blue.withOpacity(0.5);
    }

    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (notSelectIpas.contains(ipaIndex)) {
              return;
            }

            if (selectedIpas.contains(ipaIndex)) {
              selectedIpas.remove(ipaIndex);
            } else {
              selectedIpas.add(ipaIndex);
            }

            setState(() {});
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 5.wMin),
            color: backgroundColor,
            child: Text(
              widget.item.ipa![ipaIndex],
              style: TextStyle(fontSize: 30.wMin, color: textColor),
            ),
          ),
        ),
        SizedBox(width: 10.wMin),
      ],
    );
  }

  Widget _buildBottomWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ManageButton(
          text: "取消",
          width: 80.ww,
          height: 40.wh,
          borderColor: const Color(0xff666F8D),
          style: TextStyle(
            fontSize: 14.wMin,
            color: const Color(0xffEBEEF3),
            fontWeight: FontWeight.w400,
          ),
          onTap: () {
            Get.back();
          },
        ),
        SizedBox(width: 15.wMin),
        ManageButton(
          text: "确定",
          width: 80.ww,
          height: 40.wh,
          color: const Color(0xff2388FF),
          borderColor: Colors.transparent,
          style: TextStyle(
            fontSize: 14.wMin,
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
          onTap: () {
            if (selectedGraphemes.isEmpty) {
              ToastUtils.showManageToast(text: '请选择新增音节的字母');
              return;
            }

            List<int> selectedIndex = [];
            List<String> selectedGraphemeList = [];
            for (int i = 0; i < allGraphemes.length; i++) {
              if (selectedGraphemes.contains(allGraphemes[i])) {
                selectedIndex.add(i);
                selectedGraphemeList.add(widget.item.content![i]);
              }
            }

            List<String> selectedIpaList = [];
            for (int i = 0; i < allIpas.length; i++) {
              if (selectedIpas.contains(allIpas[i])) {
                selectedIpaList.add(widget.item.ipa![i]);
              }
            }

            ManageEnglishContentManagementWordAudioSoundBlockDTOSyllableModel
                syllable =
                ManageEnglishContentManagementWordAudioSoundBlockDTOSyllableModel(
              ipa: selectedIpaList.join(''),
              graphemes: selectedGraphemeList.join(''),
              positions: selectedIndex,
              published: false,
            );

            if (widget.item.soundBlockDTO?.syllables != null) {
              widget.item.soundBlockDTO?.syllables?.add(syllable);
            } else {
              widget.item.soundBlockDTO?.syllables = [syllable];
            }

            Get.back(result: widget.item);
          },
        ),
      ],
    );
  }
}
