import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../theme/theme.dart';
import 'widgets.dart';

class HelpIVideoIconWidget extends StatefulWidget {
  final String? helpVideoUrl;
  final EdgeInsetsGeometry? padding;
  final double? size;
  const HelpIVideoIconWidget({
    this.helpVideoUrl,
    this.padding,
    this.size,
    super.key,
  });

  @override
  State<HelpIVideoIconWidget> createState() => _HelpIVideoIconWidgetState();
}

class _HelpIVideoIconWidgetState extends State<HelpIVideoIconWidget> {
  /// 点击help按钮 播放视频
  Future<void> playHelpVideo(BuildContext context) async {
    print("播放视频地址：${widget.helpVideoUrl}");

    if (widget.helpVideoUrl == null || widget.helpVideoUrl == "") return;
    await PlayVideoDialog.show(
      context: context,
      videoUrl: widget.helpVideoUrl!,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.helpVideoUrl == null || widget.helpVideoUrl == "") {
      return Container();
    }
    return TapScaleWidget(
      sclae: 1.05,
      onTap: () {
        playHelpVideo(context);
      },
      child: Container(
        padding: widget.padding ?? EdgeInsets.zero,
        color: Colors.transparent,
        child: SvgPicture.asset(
          "assets/svg/user_center/icon_info.svg",
          width: widget.size ?? 44.wMin,
          height: widget.size ?? 44.wMin,
          colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
        ),
      ),
    );
  }
}
