

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';

class ListenAndReadOperationButtonWidget extends StatefulWidget {
  final VoidCallback? onPlay;
  final VoidCallback? onRecord;
  final VoidCallback? onPlayback;
  final bool platbackIsShow;
  /// 录音失败回调
  final VoidCallback? onRecordFailure;
  final MicrophoneController? microphoneController;
  const ListenAndReadOperationButtonWidget({
    super.key,
    this.onPlay,
    this.onRecord,
    this.onPlayback,
    this.platbackIsShow = false,
    this.onRecordFailure,
    this.microphoneController,

  });

  @override
  State<ListenAndReadOperationButtonWidget> createState() => _ListenAndReadOperationButtonWidgetState();
}

class _ListenAndReadOperationButtonWidgetState extends State<ListenAndReadOperationButtonWidget> {


  @override
  void initState(){
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 180.wMin,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TapScaleWidget(
          onTap: widget.onPlay,
          sclae: 1.05,
          child: _buildOperationButtonItemWidget(
            svgPath: 'assets/svg/public/icon_play_hollow_out.svg',
          ),
        ),
        MicrophoneWidget(
          controller: widget.microphoneController,
          onRecordFailure: widget.onRecordFailure,
          onTapRecord: (){
            widget.onRecord?.call();
          },
        ),
        Opacity(
          opacity: widget.platbackIsShow ? 1.0 : 0.3,
          child: IgnorePointer(
            ignoring: !widget.platbackIsShow,
            child: TapScaleWidget(
              onTap: widget.onPlayback,
              sclae: 1.05,
              child: _buildOperationButtonItemWidget(
                svgPath: 'assets/svg/public/icon_recording_playback.svg',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOperationButtonItemWidget({
    required String svgPath,
    Color backgroundColor = AppTheme.cSurfaceQuaternary,
  }){
    return Container(
      width: 76.wMin,
      height: 76.wMin,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
      ),
      child: SvgPicture.asset(
        svgPath,
        width: 28.wMin,
        height: 28.wMin,
        colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
      ),
    );
  }
  
}