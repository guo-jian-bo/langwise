
import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/theme/theme.dart';
import 'package:media_kit/media_kit.dart';
import 'package:resource_cache_package/resource_cache_package.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:flutter/material.dart';
import 'package:wise_http/wise_http.dart';

import '../../utils/utils.dart';
import 'widgets.dart';

class AudioPlayUiWidget extends StatefulWidget {
  final String? audioUrl;
  final bool showDownload;
  const AudioPlayUiWidget({super.key, required this.audioUrl, this.showDownload = true});

  @override
  State<AudioPlayUiWidget> createState() => _AudioPlayUiWidgetState();
}

class _AudioPlayUiWidgetState extends State<AudioPlayUiWidget> with RouteAware {

  /// 静态引用：当前正在播放的实例，保证同一时间只有一个在播放
  static _AudioPlayUiWidgetState? _currentlyPlaying;

  Player? _player;

  bool _isPlaying = false;
  StreamSubscription<bool>? _playingSub;

  Duration _duration = Duration.zero;
  StreamSubscription<Duration>? _durationSub;

  Duration _position = Duration.zero;
  StreamSubscription<Duration>? _positionSub;
  ModalRoute<dynamic>? _route;

  List<IconDropdownCheckData<double>> items = [
    IconDropdownCheckData<double>(title: "0.25x", value: 0.25),
    IconDropdownCheckData<double>(title: "0.5x", value: 0.5),
    IconDropdownCheckData<double>(title: "0.75x", value: 0.75),
    IconDropdownCheckData<double>(title: "正常", value: 1.0),
    IconDropdownCheckData<double>(title: "1.25x", value: 1.25),
    IconDropdownCheckData<double>(title: "1.5x", value: 1.5),
    IconDropdownCheckData<double>(title: "1.75x", value: 1.75),
    IconDropdownCheckData<double>(title: "2x", value: 2.0),
  ];

  int curretnSpeedIndex = 3;

  @override
  void initState() {
    super.initState();
    _initPlayer();
    _openAudio();
  }

  void _initPlayer() {
    _player = Player();

    _playingSub = _player!.stream.playing.listen((playing) {
      if (_isPlaying != playing) {
        _isPlaying = playing;
        if(mounted) setState(() {});
      }
    });

    _durationSub = _player!.stream.duration.listen((duration) {
      if (_duration != duration) {
        _duration = duration;
        if(mounted) setState(() {});
      }
    });

    _positionSub = _player!.stream.position.listen((position) {
      if (_position != position) {
        _position = position;
        if(mounted) setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(covariant AudioPlayUiWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.audioUrl != oldWidget.audioUrl) {
      _stopIfPlaying();
      _isPlaying = false;
      _duration = Duration.zero;
      _position = Duration.zero;
      _openAudio();
      if(mounted) setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ModalRoute<dynamic>? route = ModalRoute.of(context);
    if (_route == route) return;
    if (_route != null) {
      AppPages.observer.unsubscribe(this);
    }
    _route = route;
    if (route is PageRoute) {
      AppPages.observer.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    AppPages.observer.unsubscribe(this);
    if (_currentlyPlaying == this) {
      _currentlyPlaying = null;
    }
    _playingSub?.cancel();
    _durationSub?.cancel();
    _positionSub?.cancel();
    _player?.dispose();
    _player = null;
    super.dispose();
  }

  @override
  void didPushNext() {
    _stopIfPlaying();
  }

  /// 加载音频（不播放），用于预先获取时长
  Future<void> _openAudio() async {
    if (widget.audioUrl == null || _player == null) return;
    String? filePath = await CacheManagerUtils.instance.getFile(widget.audioUrl, ResourceType.audio);
    if (filePath != null) {
      await _player!.open(Media(filePath), play: false);
    } else {
      await _player!.open(Media(widget.audioUrl!), play: false);
    }
  }

  /// 停止当前正在播放的其他实例
  static Future<void> _stopOther(_AudioPlayUiWidgetState requester) async {
    if (_currentlyPlaying != null && _currentlyPlaying != requester) {
      await _currentlyPlaying!._player?.pause();
    }
    _currentlyPlaying = requester;
  }

  /// 如果自己正在播放则停止
  void _stopIfPlaying() {
    if (_currentlyPlaying == this) {
      _player?.pause();
      _currentlyPlaying = null;
    }
  }

  Future<void> showSpeed(BuildContext ctx) async {
    IconDropdownDialog.showCheck(
      context: ctx,
      selectIndex: curretnSpeedIndex,
      items: items,
      width: 150.wMin,
      itemHeight: 44.wMin,
      onTap: (data, index) {
        curretnSpeedIndex = index;
        if(mounted) setState(() {});
        _player?.setRate(items[curretnSpeedIndex].value ?? 1.0);
      },
    );
  }

  /// 下载音频
  Future<void> downloadAudio() async {
    if (widget.audioUrl == null) return;

    String? selectDirectory = await FilePicker.getDirectoryPath();
    if (selectDirectory == null) return;

    try {
      ToastUtils.showLoading();
      // 先检查本地有没有音频资源 如果有就直接复制到下载目录
      String? localFilePath = await CacheManagerUtils.instance.getFile(widget.audioUrl, ResourceType.audio);
      String audioName = getFileName(url: widget.audioUrl) ?? "${DateTime.now().millisecond}.mp3";
      String saveFilePath = "$selectDirectory${Platform.pathSeparator}$audioName";
      if (await File(saveFilePath).exists()) {
        return;
      }
      if (localFilePath != null) {
        await File(localFilePath).copy(saveFilePath);
        ToastUtils.showToast(text: "下载成功", type: ToastType.success);
        return;
      }
      // 本地没有资源 就从网络下载
      Response res = await WiseHttp().download(
        widget.audioUrl!,
        saveFilePath,
      );
      if (res.statusCode == 200) {
        ToastUtils.showToast(text: "下载成功", type: ToastType.success);
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  ///获取资源名称
  String? getFileName({
    required String? url,
  }) {
    if (url == null) return null;
    Uri uri = Uri.parse(url);
    return uri.pathSegments.last.split("/").last;
  }

  @override
  Widget build(BuildContext context) {
    final int durationMs = _duration.inMilliseconds;
    final double progress = durationMs <= 0
        ? 0
        : (_position.inMilliseconds / durationMs).clamp(0.0, 1.0).toDouble();

    return Row(
      children: [

        TapScaleWidget(
          onTap: () async {
            if (widget.audioUrl == null || _player == null) return;
            await _stopOther(this);
            await _player!.setRate(items[curretnSpeedIndex].value ?? 1.0);
            await _player!.playOrPause();
          },
          sclae: 1.03,
          child: Container(
            width: 32.wMin,
            height: 32.wMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.cSurfaceQuaternary.color,
            ),
            child: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow_rounded,
              size: 20.wMin,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
        ),

        SizedBox(width: 6.wMin),

        SizedBox(
          width: 110.wMin,
          child: Text(
            "${DateFormatUtil.convertSecondsToMinSec(_position.inSeconds)} / ${DateFormatUtil.convertSecondsToMinSec(_duration.inSeconds)}",
            style: TextStyle(
              fontSize: 14.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),

        Expanded(
          child: SizedBox(
            height: 40.wMin,
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 6.wMin,
                thumbShape: SliderComponentShape.noOverlay,
                overlayShape: SliderComponentShape.noOverlay,
                tickMarkShape: SliderTickMarkShape.noTickMark,
              ),
              child: Slider(
                value: progress,
                activeColor: AppTheme.cTextPrimary.color,
                inactiveColor: AppTheme.cTextPrimary.color.withValues(alpha: 0.2),
                onChanged: durationMs <= 0 ? null : (value) {
                  final int seekMs = (durationMs * value).round();
                  final Duration seekPosition = Duration(milliseconds: seekMs);
                  _player?.seek(seekPosition);
                },
              ),
            ),
          ),
        ),

        SizedBox(width: 6.wMin),

        Builder(
          builder: (ctx) {
            return TapScaleWidget(
              onTap: () {
                showSpeed(ctx);
              },
              sclae: 1.03,
              child: Container(
                color: Colors.transparent,
                width: 40.wMin,
                height: 40.wMin,
                alignment: Alignment.center,
                child: Icon(
                  Icons.more_vert_outlined,
                  size: 20.wMin,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
            );
          }
        ),

        Visibility(
          visible: (Platform.isMacOS || Platform.isWindows) && widget.showDownload,
          child: Container(
            margin: EdgeInsets.only(left: 6.wMin),
            child: TapScaleWidget(
              onTap: () {
                downloadAudio();
              },
              sclae: 1.03,
              child: Container(
                color: Colors.transparent,
                width: 40.wMin,
                height: 40.wMin,
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  "assets/svg/public/icon_download_simple.svg",
                  width: 24.wMin,
                  colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                ),
              ),
            ),
          ),
        ),

      ],
    );
  }
}
