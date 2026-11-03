import 'dart:async';

import 'package:audio_player_ex/audio_player_ex.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';
import 'package:resource_cache_package/resource_cache_package.dart';

import '../common/public_controller/config_controller.dart';


class PreviewAudioUtils {
  factory PreviewAudioUtils() => _getInstance();

  static PreviewAudioUtils get instance => _getInstance();

  static PreviewAudioUtils? _instance;

  AudioPlayerEx? _audioPlayerEx;
  StreamSubscription<PlayerState>? _stateSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<void>? _completeSubscription;

  bool isPlaying = false;

  String? currentUrl;
  Source? _currentSource;
  bool _preferRemoteSource = false;

  double _playbackRate = 1.0;

  double? _volume;

  Duration _currentPosition = Duration.zero;

  Duration _currentDuration = Duration.zero;

  Future<void> Function()? _onNext;

  Future<void> Function()? _onPrevious;

  final StreamController<bool> _playCompleteStream =
      StreamController<bool>.broadcast();

  final StreamController<bool> playingStream = StreamController.broadcast();

  final StreamController<Duration> durationStream = StreamController.broadcast();

  final StreamController<Duration> positionStream = StreamController.broadcast();

  Stream<bool> get playCompleteStream => _playCompleteStream.stream.distinct();

  Stream<bool> get pauseResumeStream => playingStream.stream.distinct();

  // 单例模式实现
  static PreviewAudioUtils _getInstance() {
    _instance ??= PreviewAudioUtils._internal();
    return _instance!;
  }

  PreviewAudioUtils._internal() {
    _audioPlayerEx = AudioPlayerEx();
    unawaited(_audioPlayerEx!.setAudioContext());

    _stateSubscription = _audioPlayerEx?.onPlayerStateChanged.listen((state) {
      final bool playing = state == PlayerState.playing;
      isPlaying = playing;
      playingStream.add(isPlaying);
      if (playing) {
        _playCompleteStream.add(false);
      }
    });

    _durationSubscription = _audioPlayerEx?.onDurationChanged.listen((duration) {
      _currentDuration = duration;
      durationStream.add(duration);
    });

    _positionSubscription = _audioPlayerEx?.onPositionChanged.listen((position) {
      print("cs-position = $position");
      _currentPosition = position;
      positionStream.add(position);
    });

    _completeSubscription = _audioPlayerEx?.onPlayerComplete.listen((_) async {
      print("cs-completed = true");
      print("cs-position = $_currentPosition");
      print("cs-duration = $_currentDuration");
      await Future.delayed(const Duration(milliseconds: 300));
      isPlaying = false;
      playingStream.add(false);
      _playCompleteStream.add(true);
    });
  }

  /// 打开音频
  Future<void> open(String? audioUrl, {bool play = false}) async {
    if (audioUrl == null) return;
    currentUrl = audioUrl;
    final bool useRemoteSource = _preferRemoteSource && GetPlatform.isIOS;
    final String? filePath = useRemoteSource
        ? null
        : await CacheManagerUtils.instance.getFile(audioUrl, ResourceType.audio);
    final Source source =
        filePath != null ? DeviceFileSource(filePath) : UrlSource(audioUrl);
    _currentSource = source;
    final double safeRate = _playbackRate.clamp(0.5, 2.0).toDouble();

    if (play) {
      await _audioPlayerEx?.play(
        source: source,
        volume: _volume,
        playbackRate: safeRate,
      );
      return;
    }

    await _audioPlayerEx?.setSource(source);
    await _audioPlayerEx?.setPlaybackRate(safeRate);
    if (_volume != null) {
      await _audioPlayerEx?.setVolume(_volume!);
    }
  }

  /// 播放暂停
  Future<void> playOrPause(String? audioUrl, {double? playbackRate, bool autoPlay = false}) async {
    if (currentUrl != audioUrl) {
      final double expandAudioSpeed = playbackRate ??
          Get.find<ConfigController>().userSetting.value.expandAudioSpeed;
      _playbackRate = expandAudioSpeed;
      await open(audioUrl, play: autoPlay);
      return;
    }

    if (_audioPlayerEx?.isPlaying == true) {
      await _audioPlayerEx?.pause();
      return;
    }
    await resume();
  }

  Future<void> prepare({
    required String url,
    String? title,
    String? artist,
    String? album,
    Uri? image,
    Duration? duration,
    double? playSpeed,
    bool preferRemoteSource = false,
    bool showSkipControls = true,
    List<int>? androidCompactActionIndices = const [0, 1, 2],
  }) async {
    if (url.isEmpty) return;
    currentUrl = url;
    _preferRemoteSource = preferRemoteSource;
    _currentDuration = duration ?? Duration.zero;
    if (playSpeed != null) {
      _playbackRate = playSpeed;
    }
    await stop();
    await open(url, play: false);
  }

  Future<void> resume() async {
    if (currentUrl == null) return;
    final Source? source = _currentSource;
    if (source == null) return;
    final double safeRate = _playbackRate.clamp(0.5, 2.0).toDouble();

    if (_audioPlayerEx?.isPaused == true) {
      await _audioPlayerEx?.setPlaybackRate(safeRate);
      if (_volume != null) {
        await _audioPlayerEx?.setVolume(_volume!);
      }
      await _audioPlayerEx?.resume();
      return;
    }

    await _audioPlayerEx?.play(
      source: source,
      volume: _volume,
      playbackRate: safeRate,
    );
  }

  /// 暂停
  Future<void> pause() async {
    await _audioPlayerEx?.pause();
  }

  Future<void> stop() async {
    await _audioPlayerEx?.stop();
    _currentPosition = Duration.zero;
    positionStream.add(_currentPosition);
  }

  Future<void> hardStop() async {
    await stop();
  }

  Future<void> stopB() async {
    await stop();
    currentUrl = null;
  }

  /// 设置播放速度
  Future<void> setRate(double value) async {
    _playbackRate = value;
    await _audioPlayerEx?.setPlaybackRate(value.clamp(0.5, 2.0).toDouble());
  }

  Future<void> setPlaybackRate(double value) async {
    await setRate(value);
  }

  Future<double> getPlaybackRate() async {
    return _playbackRate;
  }

  /// 设置播放位置
  Future<void> seek(Duration position) async {
    _currentPosition = position;
    await _audioPlayerEx?.seek(position);
  }

  Future<Duration> getDuration() async {
    return _currentDuration;
  }

  Future<Duration> getCurrentPosition() async {
    return _currentPosition;
  }

  Future<void> setVolume(double volume) async {
    _volume = (volume.clamp(0.0, 100.0).toDouble()) / 100.0;
    await _audioPlayerEx?.setVolume(_volume!);
  }

  void updateLyric(String lyric) {}

  void updateImage(String? image) {}

  void setNavigationHandlers({
    Future<void> Function()? onNext,
    Future<void> Function()? onPrevious,
  }) {
    _onNext = onNext;
    _onPrevious = onPrevious;
  }

  Future<void> playNext() async {
    await _onNext?.call();
  }

  Future<void> playPrevious() async {
    await _onPrevious?.call();
  }

  Future<void> dispose() async {
    _onNext = null;
    _onPrevious = null;
    await stop();
    await _stateSubscription?.cancel();
    await _durationSubscription?.cancel();
    await _positionSubscription?.cancel();
    await _completeSubscription?.cancel();
    _stateSubscription = null;
    _durationSubscription = null;
    _positionSubscription = null;
    _completeSubscription = null;
    await _audioPlayerEx?.dispose();
    _audioPlayerEx = null;
  }
}
