import 'dart:async';
import 'dart:io';

import 'package:camera_macos/camera_macos.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:wise_camera/photo_capture.dart';

import '../../utils/utils.dart';
import 'widgets.dart';

/// 统一的视频录制弹层。
class CameraVideoRecordingDialog {
  /// 打开视频录制弹层并返回录制结果。
  static Future<File?> show({
    required BuildContext context,
    Duration maxDuration = const Duration(seconds: 30),
  }) async {
    String? selectedCameraId;
    if (Platform.isMacOS || Platform.isWindows) {
      selectedCameraId = await selectCamera(context: context);
      if (selectedCameraId == null) return null;
    }
    if (!context.mounted) return null;
    await _setMobilePortraitOrientation();
    if (!context.mounted) return null;
    try {
      return await showGeneralDialog<File?>(
        context: context,
        barrierDismissible: false,
        barrierLabel: 'camera_video_recording_dialog',
        barrierColor: Colors.black,
        pageBuilder: (context, animation, secondaryAnimation) {
          return CameraVideoRecordingPage(
            maxDuration: maxDuration,
            selectedCameraId: selectedCameraId,
          );
        },
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      );
    } finally {
      await _setMobileLandscapeOrientation();
    }
  }

  /// 选择摄像头
  static Future<String?> selectCamera({
    required BuildContext context,
  }) async {
    if (Platform.isMacOS) {
      List<CameraMacOSDevice> videoDevices = await CameraMacOS.instance.listDevices(
        deviceType: CameraMacOSDeviceType.video,
      );
      if (!context.mounted) return null;
      if (videoDevices.isEmpty) {
        ToastUtils.showToast(text: "未检测到可用的摄像头");
        return null;
      }

      final CameraDevice? device = await CameraListWidgetManager.showUser(
        context: context,
        title: "选择摄像头",
        devices: videoDevices
            .map((e) => CameraDevice(
                  id: e.deviceId,
                  name: e.localizedName,
                  position: e.manufacturer,
                ))
            .toList(),
      );
      if (device == null || device.id == null) return null;
      return device.id;
    }

    if (Platform.isWindows) {
      final List<CameraDescription> cameras = await availableCameras();
      if (!context.mounted) return null;
      if (cameras.isEmpty) {
        ToastUtils.showToast(text: "未检测到可用的摄像头");
        return null;
      }
      if (cameras.length == 1) return cameras.first.name;

      final CameraDevice? device = await CameraListWidgetManager.showUser(
        context: context,
        title: "选择摄像头",
        devices: cameras.map((e) => CameraDevice(name: e.name)).toList(),
      );
      if (device == null || (device.name ?? "").isEmpty) return null;
      return device.name;
    }

    return null;
  }

  /// 移动端在录制页内统一切到竖屏。
  static Future<void> _setMobilePortraitOrientation() async {
    if (!(Platform.isAndroid || Platform.isIOS)) return;
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  /// 移动端退出录制弹窗后恢复为项目默认横屏。
  static Future<void> _setMobileLandscapeOrientation() async {
    if (!(Platform.isAndroid || Platform.isIOS)) return;
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await Future<void>.delayed(const Duration(milliseconds: 80));
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
}

/// 视频录制页面。
class CameraVideoRecordingPage extends StatefulWidget {
  final Duration maxDuration;
  final String? selectedCameraId;

  /// 统一的视频录制页面。
  const CameraVideoRecordingPage({
    super.key,
    required this.maxDuration,
    this.selectedCameraId,
  });

  @override
  State<CameraVideoRecordingPage> createState() => _CameraVideoRecordingPageState();
}

class _CameraVideoRecordingPageState extends State<CameraVideoRecordingPage> {
  CameraController? _cameraController;
  CameraMacOSController? _macosController;
  Player? _previewPlayer;
  VideoController? _previewVideoController;
  List<CameraDescription> _cameraDescriptions = [];
  List<CameraMacOSDevice> _macosDevices = [];
  CameraDescription? _currentCameraDescription;
  String? _currentMacosDeviceId;
  File? _recordedFile;
  Timer? _recordTimer;
  StreamSubscription<bool>? _previewPlayingSubscription;
  StreamSubscription<bool>? _previewCompletedSubscription;
  Duration _recordDuration = Duration.zero;
  bool _isLoading = true;
  bool _isRecording = false;
  bool _isClosing = false;
  bool _isPreviewPlaying = false;
  bool _isPreviewLoading = false;
  bool _isPreviewMounted = false;
  bool _isPreviewOpened = false;
  bool _isSwitchingCamera = false;
  String? _errorText;

  /// 是否使用 macOS 自定义实现。
  bool get _isMacOS => Platform.isMacOS;

  /// 是否为需要处理方向的移动端。
  bool get _isMobile => Platform.isAndroid || Platform.isIOS;

  /// 仅移动端允许切换前后摄像头。
  bool get _canSwitchCamera => (Platform.isAndroid || Platform.isIOS) && _cameraDescriptions.length > 1;

  /// 当前是否处于录制完成后的预览态。
  bool get _isPreviewMode => _recordedFile != null;

  @override
  void initState() {
    super.initState();
    unawaited(CameraVideoRecordingDialog._setMobilePortraitOrientation());
    _initializeCamera();
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    unawaited(_disposeControllers());
    unawaited(_disposePreviewPlayer());
    super.dispose();
  }

  /// 初始化当前平台对应的摄像头预览。
  Future<void> _initializeCamera() async {
    try {
      _errorText = null;
      if (_isMacOS) {
        await _initializeMacOSCamera();
      } else {
        await _initializeDefaultCamera();
      }
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorText = '摄像头初始化失败';
      });
      ToastUtils.showToast(text: '摄像头初始化失败');
    }
  }

  /// 初始化 iOS、Android、Windows 的统一相机控制器。
  Future<void> _initializeDefaultCamera() async {
    _cameraDescriptions = await availableCameras();
    if (_cameraDescriptions.isEmpty) {
      throw Exception('No camera available');
    }
    if (Platform.isWindows && (widget.selectedCameraId ?? '').isNotEmpty) {
      _currentCameraDescription = _cameraDescriptions.where((camera) => camera.name == widget.selectedCameraId).firstOrNull;
    }
    _currentCameraDescription ??= _findPreferredCamera(_cameraDescriptions);
    final CameraController controller = CameraController(
      _currentCameraDescription!,
      ResolutionPreset.high,
      enableAudio: true,
    );
    await controller.initialize();
    await _lockControllerToPortrait(controller);
    await controller.prepareForVideoRecording();
    await _cameraController?.dispose();
    _cameraController = controller;
  }

  /// 将当前录制控制器锁定到竖屏，避免移动端录制方向漂移。
  Future<void> _lockControllerToPortrait(CameraController controller) async {
    if (!_isMobile || !controller.value.isInitialized) return;
    try {
      await controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
    } catch (_) {}
  }

  /// 进入录制态前恢复竖屏并重新锁定当前控制器方向。
  Future<void> _restorePortraitOrientation() async {
    if (!_isMobile) return;
    await CameraVideoRecordingDialog._setMobilePortraitOrientation();
    final CameraController? controller = _cameraController;
    if (controller != null && controller.value.isInitialized) {
      await _lockControllerToPortrait(controller);
    }
  }

  /// 初始化 macOS 相机设备列表。
  Future<void> _initializeMacOSCamera() async {
    _macosDevices = await CameraMacOS.instance.listDevices(
      deviceType: CameraMacOSDeviceType.video,
    );
    if (_macosDevices.isEmpty) {
      throw Exception('No macOS camera available');
    }
    final String selectedCameraId = widget.selectedCameraId ?? '';
    if (selectedCameraId.isNotEmpty) {
      _currentMacosDeviceId = _macosDevices.where((device) => device.deviceId == selectedCameraId).firstOrNull?.deviceId;
    }
    _currentMacosDeviceId ??= _macosDevices.first.deviceId;
  }

  /// 查找优先使用的摄像头，优先后摄，其次前摄，再兜底第一个。
  CameraDescription _findPreferredCamera(List<CameraDescription> cameras) {
    for (final CameraDescription camera in cameras) {
      if (camera.lensDirection == CameraLensDirection.back) return camera;
    }
    for (final CameraDescription camera in cameras) {
      if (camera.lensDirection == CameraLensDirection.front) return camera;
    }
    return cameras.first;
  }

  /// 释放当前页面持有的所有相机控制器。
  Future<void> _disposeControllers() async {
    await _unlockControllerCaptureOrientation();
    try {
      await _cameraController?.dispose();
    } catch (_) {}
    try {
      await _macosController?.destroy();
    } catch (_) {}
    _cameraController = null;
    _macosController = null;
  }

  /// 关闭页面前解除相机方向锁定，避免退出后全局方向未恢复。
  Future<void> _unlockControllerCaptureOrientation() async {
    if (!_isMobile) return;
    final CameraController? controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;
    try {
      await controller.unlockCaptureOrientation();
    } catch (_) {}
  }

  /// 释放预览播放器及其监听。
  Future<void> _disposePreviewPlayer() async {
    final Player? currentPlayer = _previewPlayer;
    final StreamSubscription<bool>? currentPlayingSubscription = _previewPlayingSubscription;
    final StreamSubscription<bool>? currentCompletedSubscription = _previewCompletedSubscription;

    _previewPlayer = null;
    _previewVideoController = null;
    _previewPlayingSubscription = null;
    _previewCompletedSubscription = null;
    _isPreviewPlaying = false;
    _isPreviewLoading = false;
    _isPreviewMounted = false;
    _isPreviewOpened = false;

    await currentPlayingSubscription?.cancel();
    await currentCompletedSubscription?.cancel();
    await currentPlayer?.dispose();
  }

  /// 页面仍然存活时再触发刷新，避免异步回调越界更新。
  void _safeSetState() {
    if (!mounted || _isClosing) return;
    setState(() {});
  }

  /// 确保预览播放器已经挂载到页面中。
  Future<void> _ensurePreviewPlayerMounted() async {
    if (_previewPlayer != null) return;

    final Player player = Player();
    final VideoController controller = VideoController(player);

    _previewPlayer = player;
    _previewVideoController = controller;
    _isPreviewMounted = true;

    await _previewPlayingSubscription?.cancel();
    _previewPlayingSubscription = player.stream.playing.listen((playing) {
      if (_previewPlayer != player) return;
      _isPreviewPlaying = playing;
      _safeSetState();
    });

    await _previewCompletedSubscription?.cancel();
    _previewCompletedSubscription = player.stream.completed.listen((completed) async {
      if (_previewPlayer != player || !completed) return;
      try {
        await player.pause();
        await player.seek(Duration.zero);
      } catch (_) {}
      _isPreviewPlaying = false;
      _safeSetState();
    });

    _safeSetState();
  }

  /// 打开本地录制结果用于预览。
  Future<void> _openPreviewFile(File file) async {
    await _disposePreviewPlayer();
    await _ensurePreviewPlayerMounted();
    if (_previewPlayer == null) return;

    _isPreviewLoading = true;
    _safeSetState();

    try {
      await _previewPlayer!.open(Media(file.path), play: false);
      _isPreviewOpened = true;
    } catch (_) {
      ToastUtils.showToast(text: '视频预览加载失败');
    } finally {
      _isPreviewLoading = false;
      _safeSetState();
    }
  }

  /// 切换到下一个可用摄像头。
  Future<void> _switchCamera() async {
    if (_isPreviewMode || _isRecording || _isLoading || _isSwitchingCamera || !_canSwitchCamera) return;
    setState(() {
      _isLoading = true;
      _isSwitchingCamera = true;
    });
    try {
      if (_isMacOS) {
        final int currentIndex = _macosDevices.indexWhere(
          (CameraMacOSDevice device) => device.deviceId == _currentMacosDeviceId,
        );
        final int nextIndex = currentIndex == -1 ? 0 : (currentIndex + 1) % _macosDevices.length;
        _currentMacosDeviceId = _macosDevices[nextIndex].deviceId;
        await _macosController?.destroy();
        _macosController = null;
      } else {
        final int currentIndex = _cameraDescriptions.indexOf(_currentCameraDescription!);
        final int nextIndex = (currentIndex + 1) % _cameraDescriptions.length;
        _currentCameraDescription = _cameraDescriptions[nextIndex];
        final CameraController? previousController = _cameraController;
        _cameraController = null;
        await previousController?.dispose();
        final CameraController controller = CameraController(
          _currentCameraDescription!,
          ResolutionPreset.high,
          enableAudio: true,
        );
        await controller.initialize();
        await _lockControllerToPortrait(controller);
        await controller.prepareForVideoRecording();
        _cameraController = controller;
      }
    } catch (_) {
      ToastUtils.showToast(text: '切换摄像头失败');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSwitchingCamera = false;
        });
      }
    }
  }

  /// 处理录制按钮点击逻辑。
  Future<void> _handleRecordAction() async {
    if (_isLoading || _isPreviewMode) return;
    if (_isRecording) {
      await _stopRecording();
      return;
    }
    await _startRecording();
  }

  /// 开始录制视频。
  Future<void> _startRecording() async {
    try {
      await _restorePortraitOrientation();
      if (_isMacOS) {
        if (_macosController == null) {
          ToastUtils.showToast(text: '摄像头还没有准备好');
          return;
        }
        await _macosController!.recordVideo(
          enableAudio: true,
        );
      } else {
        final CameraController? controller = _cameraController;
        if (controller == null || !controller.value.isInitialized) {
          ToastUtils.showToast(text: '摄像头还没有准备好');
          return;
        }
        await controller.startVideoRecording();
      }
      _recordTimer?.cancel();
      _recordDuration = Duration.zero;
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        final Duration nextDuration = Duration(seconds: timer.tick);
        if (!mounted) return;
        setState(() {
          _recordDuration = nextDuration;
        });
        if (nextDuration >= widget.maxDuration) {
          await _stopRecording();
        }
      });
      if (!mounted) return;
      setState(() {
        _isRecording = true;
      });
    } catch (_) {
      ToastUtils.showToast(text: '开始录制失败');
    }
  }

  /// 停止录制视频。
  Future<void> _stopRecording() async {
    try {
      _recordTimer?.cancel();
      File? file;
      if (_isMacOS) {
        final CameraMacOSFile? result = await _macosController?.stopRecording();
        if (result?.url != null) file = File(result!.url!);
      } else {
        final CameraController? controller = _cameraController;
        if (controller != null && controller.value.isRecordingVideo) {
          final XFile result = await controller.stopVideoRecording();
          file = File(result.path);
        }
      }
      if (!mounted) return;
      setState(() {
        _isRecording = false;
      });
      if (file != null) await _enterPreviewMode(file);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isRecording = false;
      });
      ToastUtils.showToast(text: '停止录制失败');
    }
  }

  /// 进入录制完成后的预览态。
  Future<void> _enterPreviewMode(File file) async {
    if (!(await file.exists())) {
      ToastUtils.showToast(text: '录制文件不存在');
      return;
    }
    _recordedFile = file;
    _recordDuration = Duration.zero;
    _safeSetState();
    await _openPreviewFile(file);
  }

  /// 切换预览播放状态。
  Future<void> _togglePreviewPlay() async {
    if (_isPreviewLoading || !_isPreviewMode || _previewPlayer == null || !_isPreviewOpened) return;

    try {
      if (_isPreviewPlaying) {
        await _previewPlayer!.pause();
      } else {
        await _previewPlayer!.play();
      }
    } catch (_) {
      ToastUtils.showToast(text: '视频播放失败');
    }
  }

  /// 放弃当前预览并回到录制态。
  Future<void> _retryRecordVideo() async {
    final File? recordedFile = _recordedFile;
    _recordedFile = null;
    await _disposePreviewPlayer();
    await _restorePortraitOrientation();
    if (recordedFile != null) {
      try {
        await recordedFile.delete();
      } catch (_) {}
    }
    _safeSetState();
  }

  /// 确认应用当前预览视频。
  Future<void> _applyRecordedVideo() async {
    final File? recordedFile = _recordedFile;
    if (recordedFile == null) return;
    if (!(await recordedFile.exists())) {
      ToastUtils.showToast(text: '录制文件不存在');
      return;
    }
    if (!mounted || _isClosing) return;
    _isClosing = true;
    await _unlockControllerCaptureOrientation();
    if (!mounted) return;
    Navigator.of(context).pop(recordedFile);
  }

  /// 关闭页面时释放录制状态。
  Future<void> _closePage() async {
    if (_isClosing) return;
    _isClosing = true;
    _recordTimer?.cancel();
    await _disposePreviewPlayer();
    if (_isRecording) {
      try {
        if (_isMacOS) {
          await _macosController?.stopRecording();
        } else {
          final CameraController? controller = _cameraController;
          if (controller != null && controller.value.isRecordingVideo) {
            await controller.stopVideoRecording();
          }
        }
      } catch (_) {}
    }
    await _unlockControllerCaptureOrientation();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  /// 格式化录制时长。
  String _buildDurationText(Duration duration) {
    final String minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final String seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// 构建顶部操作栏。
  Widget _buildTopBarWidget() {
    if (_isRecording && !_isPreviewMode) return const SizedBox.shrink();
    final bool canSwitchCamera = !_isPreviewMode && _canSwitchCamera;
    final bool showRightButton = _isPreviewMode || canSwitchCamera;
    final IconData leftIcon = _isPreviewMode ? Icons.refresh_rounded : Icons.close;
    final IconData rightIcon = _isPreviewMode ? Icons.check_rounded : Icons.cameraswitch_rounded;
    final void Function() leftAction = _isPreviewMode ? _retryRecordVideo : _closePage;
    final void Function()? rightAction = _isPreviewMode ? _applyRecordedVideo : (canSwitchCamera ? _switchCamera : null);
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTopButtonWidget(
                icon: leftIcon,
                onTap: leftAction,
              ),
              if (showRightButton)
                _buildTopButtonWidget(
                  icon: rightIcon,
                  onTap: rightAction,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建顶部圆形操作按钮。
  Widget _buildTopButtonWidget({
    required IconData icon,
    void Function()? onTap,
  }) {
    final bool isEnabled = onTap != null;
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.04,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: isEnabled ? 0.35 : 0.2),
          border: Border.all(
            width: 1,
            color: Colors.white.withValues(alpha: isEnabled ? 0.18 : 0.08),
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: Colors.white.withValues(alpha: isEnabled ? 1 : 0.4),
        ),
      ),
    );
  }

  /// 构建底部控制区。
  Widget _buildBottomBarWidget() {
    if (_isPreviewMode) {
      return _buildPreviewBottomBarWidget();
    }
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _buildDurationText(_recordDuration),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 2),
              Text(
                _isRecording ? '点击结束录制' : '点击开始录制，最长 ${widget.maxDuration.inSeconds} 秒',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.78),
                ),
              ),
              SizedBox(height: 10),
              TapScaleWidget(
                onTap: _handleRecordAction,
                sclae: 1.03,
                child: Container(
                  width: 60,
                  height: 60,
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(width: 4, color: Colors.white),
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: _isRecording ? 30 : 56,
                      height: _isRecording ? 30 : 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3B30),
                        borderRadius: BorderRadius.circular(_isRecording ? 6 : 99),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建预览态底部控制区。
  Widget _buildPreviewBottomBarWidget() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 16, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '预览录制结果',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.92),
                ),
              ),
              SizedBox(height: 10),
              _buildPreviewPlayButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建预览态底部播放按钮。
  Widget _buildPreviewPlayButton() {
    return TapScaleWidget(
      onTap: _togglePreviewPlay,
      sclae: 1.04,
      child: Container(
        width: 60,
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.14),
          border: Border.all(
            width: 1,
            color: Colors.white.withValues(alpha: 0.25),
          ),
        ),
        child: Icon(
          _isPreviewPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          size: 38,
          color: Colors.white,
        ),
      ),
    );
  }

  /// 构建页面主体。
  Widget _buildBodyWidget() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    if (_errorText != null) {
      return Center(
        child: Text(
          _errorText!,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      );
    }
    if (_isPreviewMode) return _buildPreviewWidget();
    return _isMacOS ? _buildMacOSPreviewWidget() : _buildDefaultPreviewWidget();
  }

  /// 构建录制完成后的本地预览。
  Widget _buildPreviewWidget() {
    if (_previewVideoController == null || !_isPreviewMounted) {
      return const SizedBox.shrink();
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _togglePreviewPlay,
      child: Stack(
        children: [
          Positioned.fill(
            child: Video(
              controller: _previewVideoController!,
              fill: Colors.black,
              controls: (_) => Container(),
            ),
          ),
          if (_isPreviewLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
        ],
      ),
    );
  }

  /// 构建 iOS、Android、Windows 的统一预览。
  Widget _buildDefaultPreviewWidget() {
    final CameraController? controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink();
    }
    final Size previewSize = controller.value.previewSize ?? const Size(720, 1280);
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
        final double previewAspectRatio = isPortrait
            ? previewSize.height / previewSize.width
            : previewSize.width / previewSize.height;
        double width = constraints.maxWidth;
        double height = width / previewAspectRatio;
        if (height < constraints.maxHeight) {
          height = constraints.maxHeight;
          width = height * previewAspectRatio;
        }
        return Center(
          child: ClipRect(
            child: OverflowBox(
              alignment: Alignment.center,
              minWidth: width,
              maxWidth: width,
              minHeight: height,
              maxHeight: height,
              child: SizedBox(
                width: width,
                height: height,
                child: CameraPreview(controller),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 构建 macOS 的视频预览。
  Widget _buildMacOSPreviewWidget() {
    if (_currentMacosDeviceId == null) return const SizedBox.shrink();
    return Center(
      child: SizedBox.expand(
        child: CameraMacOSView(
          key: ValueKey<String>(_currentMacosDeviceId!),
          deviceId: _currentMacosDeviceId,
          cameraMode: CameraMacOSMode.video,
          enableAudio: true,
          resolution: PictureResolution.high,
          videoFormat: VideoFormat.mp4,
          fit: BoxFit.cover,
          isVideoMirrored: true,
          onCameraInizialized: (CameraMacOSController controller) {
            _macosController = controller;
          },
          onCameraLoading: (_) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildBodyWidget(),
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.42),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.56),
                  ],
                  stops: const [0, 0.42, 1],
                ),
              ),
            ),
          ),
          _buildTopBarWidget(),
          _buildBottomBarWidget(),
        ],
      ),
    );
  }
}
