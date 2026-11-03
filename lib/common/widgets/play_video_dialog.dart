import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';


import '../../theme/theme.dart';

class PlayVideoDialog{

  static Future<void> show({
    required BuildContext context,
    required String videoUrl,
  }) async{
    await showCupertinoDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) {
        return PlayVideoDialogWidget(videoUrl: videoUrl);
      },
    );
  }

}

class PlayVideoDialogWidget extends StatefulWidget {
  final String videoUrl;
  const PlayVideoDialogWidget({super.key, required this.videoUrl});

  @override
  State<PlayVideoDialogWidget> createState() => _PlayVideoDialogWidgetState();
}

class _PlayVideoDialogWidgetState extends State<PlayVideoDialogWidget> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cOverlayBackground,
      child: VideoPlayerWidget(
        playList: [
          MediaModel(
            resource: widget.videoUrl,
          ),
        ],
      ),
    );
  }
}