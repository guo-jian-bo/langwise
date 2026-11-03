
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../common/commons.dart';

class ManageKnowledgeAudioListDialg{

  static Future<EnKnowledgeEntityIpaAudioList?> showWord({
    required BuildContext context,
    required EnKnowledgeEntity data,
  }) async{

    return await showCupertinoDialog<EnKnowledgeEntityIpaAudioList?>(
      context: context,
      builder: (context) {
        return ManageKnowledgeAudioListDialgWordWidget(
          data: data,
        );
      },
    );
    
  }

  static Future<EnKnowledgeEntityAudioExpressionList?> showAudioList({
    required BuildContext context,
    required EnKnowledgeEntity data,
    required String title,
  }) async{

    return await showCupertinoDialog<EnKnowledgeEntityAudioExpressionList?>(
      context: context,
      builder: (context) {
        return ManageKnowledgeAudioListDialgPhraseWidget(
          data: data,
          title: title,
        );
      },
    );
    
  }

  /// 音频/字幕列表
  static Future<EnKnowledgeEntityAudioExpressionList?> showAudioSubtitleList({
    required BuildContext context,
    required EnKnowledgeEntity data,
  }) async{

    return await showCupertinoDialog<EnKnowledgeEntityAudioExpressionList?>(
      context: context,
      builder: (context) {
        return ManageKnowledgeAudioListDialgAudioSubtitleWidget(
          data: data,
        );
      },
    );
    
  }

}


class ManageKnowledgeAudioListDialgAudioSubtitleWidget extends StatefulWidget {
  final EnKnowledgeEntity data;
  const ManageKnowledgeAudioListDialgAudioSubtitleWidget({super.key, required this.data});

  @override
  State<ManageKnowledgeAudioListDialgAudioSubtitleWidget> createState() => _ManageKnowledgeAudioListDialgAudioSubtitleWidgetState();
}

class _ManageKnowledgeAudioListDialgAudioSubtitleWidgetState extends State<ManageKnowledgeAudioListDialgAudioSubtitleWidget> {
  @override
  Widget build(BuildContext context) {
    return ManageDialogBoxWidget(
      title: "${widget.data.title??''} 的全部音频列表",
      width: 600.wMin,
      child: Container(
        constraints: BoxConstraints(
          minHeight: 400.wMin,
          maxHeight: 950.wMin,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.wMin),
          child: _buildListWidgt(),
        ),
      ),
    );
  }


  Widget _buildListWidgt(){
    List<EnKnowledgeEntityAudioExpressionList?> audioExpressionList = widget.data.audioExpressionList??[];

    return Column(
      spacing: 16.wMin,
      children: List.generate(audioExpressionList.length, (index){
        return _buildAudioItemWidget(audioExpressionList[index]);
      }),
    );
  }

  Widget _buildAudioItemWidget(EnKnowledgeEntityAudioExpressionList? audio){
    if(audio == null) return Container();

    return TapScaleWidget(
      onTap: () {
        Get.back(result: audio);
      },
      sclae: 1.01,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          color: AppTheme.cSurfaceTertiary.color,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${audio.name??''} (${audio.accent??''})",
                    style: TextStyle(
                      fontSize: 24.wMin,
                      color: AppTheme.cTextPrimary.color,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Row(
                    spacing: 40.wMin,
                    children: [
                      _buildIconTextWidget(
                        name: '音频',
                        isCheck: audio.published ?? false,
                      ),
                      _buildIconTextWidget(
                        name: '字幕',
                        isCheck: audio.assPublished == 1,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SvgPicture.asset(
              "assets/svg/public/icon_w_arrow_right.svg",
              width: 24.wMin,
              colorFilter: ColorFilter.mode(
                AppTheme.cTextTertiary.color,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildIconTextWidget({
    required String name,
    bool isCheck = false,
  }){
    return Row(
      spacing: 8.wMin,
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 20.wMin,
            color: isCheck ? AppTheme.cSurfaceSuccess.color : AppTheme.cTextTertiary.color,
            fontWeight: FontWeight.w400,
          ),
        ),
        Icon(
          Icons.check, 
          color: isCheck ? AppTheme.cSurfaceSuccess.color : AppTheme.cTextTertiary.color, 
          size: 18.wMin,
        ),
      ],
    );
  }
}


class ManageKnowledgeAudioListDialgPhraseWidget extends StatefulWidget {
  final EnKnowledgeEntity data;
  final String title;
  const ManageKnowledgeAudioListDialgPhraseWidget({super.key, required this.data, required this.title});

  @override
  State<ManageKnowledgeAudioListDialgPhraseWidget> createState() => _ManageKnowledgeAudioListDialgPhraseWidgetState();
}

class _ManageKnowledgeAudioListDialgPhraseWidgetState extends State<ManageKnowledgeAudioListDialgPhraseWidget> {
  @override
  Widget build(BuildContext context) {
    return ManageDialogBoxWidget(
      title: "${widget.title} 的全部音频列表",
      width: 600.wMin,
      child: Container(
        constraints: BoxConstraints(
          minHeight: 400.wMin,
          maxHeight: 800.wMin,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.wMin),
          child: _buildListWidgt(),
        ),
      ),
    );
  }

  Widget _buildListWidgt(){
    List<EnKnowledgeEntityAudioExpressionList?> audioExpressionList = widget.data.audioExpressionList??[];

    return Column(
      spacing: 16.wMin,
      children: List.generate(audioExpressionList.length, (index){
        return _buildAudioItemWidget(audioExpressionList[index]);
      }),
    );
  }

  Widget _buildAudioItemWidget(EnKnowledgeEntityAudioExpressionList? audio){
    if(audio == null) return Container();

    return TapScaleWidget(
      onTap: () {
        Get.back(result: audio);
      },
      sclae: 1.01,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          color: AppTheme.cSurfaceTertiary.color,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${audio.name??''} (${audio.accent??''})",
                    style: TextStyle(
                      fontSize: 24.wMin,
                      color: AppTheme.cTextPrimary.color,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Row(
                    spacing: 40.wMin,
                    children: [
                      _buildIconTextWidget(
                        name: '音频',
                        isCheck: audio.published ?? false,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SvgPicture.asset(
              "assets/svg/public/icon_w_arrow_right.svg",
              width: 24.wMin,
              colorFilter: ColorFilter.mode(
                AppTheme.cTextTertiary.color,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildIconTextWidget({
    required String name,
    bool isCheck = false,
  }){
    return Row(
      spacing: 8.wMin,
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 20.wMin,
            color: isCheck ? AppTheme.cSurfaceSuccess.color : AppTheme.cTextTertiary.color,
            fontWeight: FontWeight.w400,
          ),
        ),
        Icon(
          Icons.check, 
          color: isCheck ? AppTheme.cSurfaceSuccess.color : AppTheme.cTextTertiary.color, 
          size: 18.wMin,
        ),
      ],
    );
  }

}


class ManageKnowledgeAudioListDialgWordWidget extends StatefulWidget {
  final EnKnowledgeEntity data;
  const ManageKnowledgeAudioListDialgWordWidget({super.key, required this.data});

  @override
  State<ManageKnowledgeAudioListDialgWordWidget> createState() => _ManageKnowledgeAudioListDialgWordWidgetState();
}

class _ManageKnowledgeAudioListDialgWordWidgetState extends State<ManageKnowledgeAudioListDialgWordWidget> {

  @override
  Widget build(BuildContext context) {
    return ManageDialogBoxWidget(
      title: "${widget.data.content??''} 的全部音频列表",
      width: 600.wMin,
      child: Container(
        constraints: BoxConstraints(
          minHeight: 400.wMin,
          maxHeight: 950.wMin,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.wMin),
          child: _buildListWidgt(),
        ),
      ),
    );
  }


  Widget _buildListWidgt(){
    List<EnKnowledgeEntityIpaAudioList?> ipaAudioList = widget.data.ipaAudioList??[];

    return Column(
      spacing: 16.wMin,
      children: List.generate(ipaAudioList.length, (index){
        return _buildAudioItemWidget(ipaAudioList[index]);
      }),
    );
  }

  Widget _buildAudioItemWidget(EnKnowledgeEntityIpaAudioList? audio){
    if(audio == null) return Container();

    return TapScaleWidget(
      onTap: () {
        Get.back(result: audio);
      },
      sclae: 1.01,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          color: AppTheme.cSurfaceTertiary.color,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${audio.name??''} (${audio.accent??''})",
                    style: TextStyle(
                      fontSize: 24.wMin,
                      color: AppTheme.cTextPrimary.color,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Row(
                    spacing: 40.wMin,
                    children: [
                      _buildIconTextWidget(
                        name: '音频',
                        isCheck: audio.wordPublished ?? false,
                      ),
                      _buildIconTextWidget(
                        name: '音节',
                        isCheck: audio.syllablesPublished ?? false,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SvgPicture.asset(
              "assets/svg/public/icon_w_arrow_right.svg",
              width: 24.wMin,
              colorFilter: ColorFilter.mode(
                AppTheme.cTextTertiary.color,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildIconTextWidget({
    required String name,
    bool isCheck = false,
  }){
    return Row(
      spacing: 8.wMin,
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 20.wMin,
            color: isCheck ? AppTheme.cSurfaceSuccess.color : AppTheme.cTextTertiary.color,
            fontWeight: FontWeight.w400,
          ),
        ),
        Icon(
          Icons.check, 
          color: isCheck ? AppTheme.cSurfaceSuccess.color : AppTheme.cTextTertiary.color, 
          size: 18.wMin,
        ),
      ],
    );
  }


}