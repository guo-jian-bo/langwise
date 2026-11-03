
import 'package:flutter/material.dart';

class RotationTransitionController{
  _RotationTransitionWidgetState? _state;

  /// 暂停旋转
  void pause(){
    if(_state == null) return;
    if(_state?.mounted == false) return;
    _state?.pause();
  }

  /// 恢复旋转
  void resume(){
    if(_state == null) return;
    if(_state?.mounted == false) return;
    _state?.resume();
  }
}

class RotationTransitionWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final RotationTransitionController? controller;
  final bool autoStart;
  const RotationTransitionWidget({
    super.key, 
    required this.child, 
    this.duration = const Duration(seconds: 5),
    this.controller,
    this.autoStart = false,
  });

  @override
  State<RotationTransitionWidget> createState() => _RotationTransitionWidgetState();
}

class _RotationTransitionWidgetState extends State<RotationTransitionWidget> with SingleTickerProviderStateMixin{

  late AnimationController _borderController;

  @override
  void initState() {
    super.initState();
    _borderController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    widget.controller?._state = this;
    if (widget.autoStart) {
      _borderController.repeat(reverse: false);
    }
  }

  @override
  void didUpdateWidget(covariant RotationTransitionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(oldWidget.duration != widget.duration){
      _borderController.duration = widget.duration;
    }
  }

  @override
  void dispose() {
    _borderController.dispose();
    super.dispose();
  }

  /// 暂停
  void pause(){
    _borderController.stop();
  }

  /// 恢复
  void resume(){
    _borderController.repeat(reverse: false);
  }


  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _borderController, curve: Curves.linear),
      ),
      child: widget.child,
    );
  }
}