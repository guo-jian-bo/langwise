import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/performance_monitor_utils.dart';
import 'package:langwise/utils/performance_service.dart';

/// 性能监控悬浮窗组件
///
/// 在应用界面上显示实时性能指标，包括FPS、内存使用、构建频率和API调用频率
/// 仅在调试模式下显示，或者通过[showInRelease]参数强制显示
class PerformanceOverlayWidget extends StatefulWidget {
  final Widget child;
  final bool showInRelease;
  final bool showMemory;
  final bool showFps;
  final bool showBuilds;
  final Color backgroundColor;
  final Color textColor;
  final Color warningColor;
  final Color criticalColor;

  const PerformanceOverlayWidget({
    Key? key,
    required this.child,
    this.showInRelease = false,
    this.showMemory = true,
    this.showFps = true,
    this.showBuilds = true,
    this.backgroundColor = Colors.black54,
    this.textColor = const Color(0xff22C55E),
    this.warningColor = Colors.orange,
    this.criticalColor = Colors.red,
  }) : super(key: key);

  @override
  State<PerformanceOverlayWidget> createState() => _PerformanceOverlayWidgetState();
}

class _PerformanceOverlayWidgetState extends State<PerformanceOverlayWidget> {
  // 直接引用PerformanceMonitorUtils的Rx变量
  late final RxDouble _fps;
  late final RxDouble _memory;
  late final RxInt _buildCount;

  // 是否显示
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();

    // 只在调试模式或明确要求时显示
    if (kProfileMode || kDebugMode || widget.showInRelease) {
      _setupMonitoring();
    }
  }

  void _setupMonitoring() {
    final utils = PerformanceMonitorUtils.instance;

    if (Get.isRegistered<PerformanceService>()) {
      PerformanceService.to;
    }

    if ((kProfileMode || kReleaseMode) && (kProfileMode || widget.showInRelease)) {
      utils.startMonitoring(
        includeMemory: widget.showMemory,
        includeRender: widget.showFps,
        includeBuilds: widget.showBuilds,
      );
    }

    _fps = utils.fps;
    _memory = utils.memoryMB;
    _buildCount = utils.buildsPerSecond;
  }

  // 不再需要手动更新指标，因为直接使用了PerformanceMonitorUtils的Rx变量

  @override
  Widget build(BuildContext context) {
    // 在非调试模式且未明确要求时，直接返回子组件
    if ((!kDebugMode && !kProfileMode && !widget.showInRelease) || !_isVisible) {
      return widget.child;
    }

    return Stack(
      children: [
        // 原始内容
        widget.child,

        // 性能指标悬浮窗
        Positioned(
          top: 0,
          left: 0,
          child: Material(
            color: widget.backgroundColor,
            borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(8),
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  _isVisible = !_isVisible;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Obx(() => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.showFps)
                          Text(
                            'FPS: ${_fps.value.toStringAsFixed(1)}',
                            style: TextStyle(
                              color: _getFpsColor(_fps.value),
                              fontSize: 12,
                            ),
                          ),
                        if (widget.showMemory)
                          Text(
                            '内存: ${_memory.value.toStringAsFixed(1)} MB',
                            style: TextStyle(
                              color: _getMemoryColor(_memory.value),
                              fontSize: 12,
                            ),
                          ),
                        if (widget.showBuilds)
                          Text(
                            '构建: ${_buildCount.value}/s',
                            style: TextStyle(
                              color: _getBuildColor(_buildCount.value),
                              fontSize: 12,
                            ),
                          ),
                      ],
                    )),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getFpsColor(double fps) {
    if (fps < 30) {
      return widget.criticalColor;
    } else if (fps < 45) {
      return widget.warningColor;
    }
    return widget.textColor;
  }

  Color _getMemoryColor(double memoryMB) {
    if (memoryMB > 300) {
      return widget.criticalColor;
    } else if (memoryMB > 150) {
      return widget.warningColor;
    }
    return widget.textColor;
  }

  Color _getBuildColor(int buildCount) {
    if (buildCount > 60) {
      return widget.criticalColor;
    } else if (buildCount > 30) {
      return widget.warningColor;
    }
    return widget.textColor;
  }
}
