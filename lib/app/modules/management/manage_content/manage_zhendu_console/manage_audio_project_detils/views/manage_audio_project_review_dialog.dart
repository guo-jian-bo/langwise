import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:video_player/video_player.dart';

import '../../../../../../../theme/theme.dart';
import '../../../../common/commons.dart';

/// 试听音频审核
class ManageAudioProjectReviewDialog{

  static Future<bool> show({
    required BuildContext context,
    required List<int?> audioTaskIds,
  }) async{
    bool? res = await showCupertinoDialog<bool?>(
      context: context,
      builder: (context) {
        return ManageAudioProjectReviewDialogWidget(audioTaskIds: audioTaskIds);
      },
    );
    return res??false;
  }

}


class ManageAudioProjectReviewDialogWidget extends StatefulWidget {
  final List<int?> audioTaskIds;
  const ManageAudioProjectReviewDialogWidget({super.key, required this.audioTaskIds});

  @override
  State<ManageAudioProjectReviewDialogWidget> createState() => _ManageAudioProjectReviewDialogWidgetState();
}

class _ManageAudioProjectReviewDialogWidgetState extends State<ManageAudioProjectReviewDialogWidget> {

  Player _player = Player();

  int? selectIndex;

  int? _currentPlayIndex;
  bool _isPlaying = false;

  StreamSubscription<bool>? _playingSub;

  @override
  void initState(){
    super.initState();
    _listenAudio();
    _getAudioList();
  }

  @override
  void dispose(){
    super.dispose();
    _playingSub?.cancel();
    _player.dispose();
  }

  /// 监听音频播放状态
  void _listenAudio(){
    _playingSub = _player.stream.playing.listen((e){
      _isPlaying = e;
      if(mounted) setState(() {});
    });
  }


  /// 获取音频审核列表
  Future<void> _getAudioList() async{
    
  }


  @override
  Widget build(BuildContext context) {
    return ManageDialogBoxWidget(
      title: "试听音频审核",
      width: 1200.wMin,
      onCancel: () => Get.back(),
      confirmText: "重新生成",
      confirmColor: AppTheme.cSurfaceBrand.color,
      onConfirm: () {

      },
      confirmText1: "审核通过",
      confirmColor1: AppTheme.cSurfaceSuccess.color,
      onConfirm1: () {

      },
      child: Container(
        height: 480.wMin,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 24.wMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildContentWidget(),
            SizedBox(height: 12.wMin),
            Container(height: 1.wMin, color: AppTheme.cBorderPrimary.color),
            SizedBox(height: 12.wMin),
            Expanded(
              child: Row(
                spacing: 24.wMin,
                children: [
                  _buildAudioListWidget(),
                  Expanded(
                    child: Column(
                      spacing: 24.wMin,
                      children: [
                        _buildTaskWidget(),
                        _buildSelectAudioWidget(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.wMin),
          ],
        ),
      ),
    );
  }


  Widget _buildContentWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SelectableText(
          "dialogueId: 600190",
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextTertiary.color,
          ),
        ),
        SelectableText(
          "One morning, in the garden, two children found a mysterious map.",
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
      ],
    );
  }

  /// 音频列表
  Widget _buildAudioListWidget(){
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.wMin),
      child: Container(
        width: 600.wMin,
        height: double.infinity,
        color: AppTheme.cSurfaceTertiary.color,
        child: ListView.separated(
          itemCount: 4,
          padding: EdgeInsets.zero,
          separatorBuilder: (context, index) {
            return Container(height: 1.wMin, color: AppTheme.cBorderSecondary.color);
          },
          itemBuilder: (context, index) {
            return _buildAudioitemWidget(index);
          },
        ),
      ),
    );
  }

  Widget _buildAudioitemWidget(int index){
    return TapScaleWidget(
      onTap: () {
        selectIndex = index;
        if(mounted) setState(() {});
      },
      sclae: 1,
      backColor: AppTheme.cSurfaceQuaternary.color,
      child: Container(
        height: 100.wMin,
        padding: EdgeInsets.symmetric(horizontal: 16.wMin),
        color: selectIndex == index ? AppTheme.cFeedbackInfoBackground.color : Colors.transparent,
        child: Row(
          children: [

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: 4.wMin,
                children: [
                  Text(
                    "音频 ${index + 1}",
                    style: TextStyle(
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextPrimary.color,
                    ),
                  ),
                  Text(
                    "3.22s / audio_uid: 9700011",
                    style: TextStyle(
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextTertiary.color,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 4.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                color: AppTheme.cSurfaceQuinary.color,
              ),
              child: Text(
                "3.22s",
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
            ),

            SizedBox(width: 12.wMin),

            TapScaleWidget(
              onTap: () {
                
              },
              sclae: 1.03,
              child: Container(
                width: 58.wMin,
                height: 58.wMin,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.cSurfaceBrand.color,
                ),
                child: Icon(
                  _isPlaying && _currentPlayIndex == index ? Icons.pause : Icons.play_arrow_rounded,
                  size: 32.wMin,
                  color: Colors.white,
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }


  Widget _buildTaskWidget(){
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.wMin),
        child: Container(
          padding: EdgeInsets.all(16.wMin),
          width: double.infinity,
          color: AppTheme.cSurfaceTertiary.color,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12.wMin,
            children: [
              SelectableText(
                "当前任务",
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextTertiary.color,
                ),
              ),
              SelectableText(
                "audio_task_id: 970001",
                style: TextStyle(
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
              SelectableText(
                "审核时间: 2026-03-23 00:30",
                style: TextStyle(
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
              SelectableText(
                "审核员: 301",
                style: TextStyle(
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
      
            ],
          ),
        ),
      ),
    );
  }

  /// 已选音频
  Widget _buildSelectAudioWidget(){
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.wMin),
        child: Container(
          padding: EdgeInsets.all(16.wMin),
          width: double.infinity,
          color: AppTheme.cSurfaceTertiary.color,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12.wMin,
            children: [
              SelectableText(
                "已选音频",
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextTertiary.color,
                ),
              ),
              SelectableText(
                "audio_uid: 9700012",
                style: TextStyle(
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
              SelectableText(
                "已选音频",
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextTertiary.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}