
import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:math';

import 'image_animation_builds.dart';



enum ImageAnimationSwitchType {
  /// 顺序切换
  order,
  /// 随机切换
  random,
}

class ImageAnimationSwitcherController {
  _ImageAnimationSwitcherState? _state;

  /// 暂停切换
  void pause(){
    _state?._pauseSwitching();
  }

  /// 继续切换
  void resume(){
    _state?._resumeSwitching();
  }
}

class ImageAnimationSwitcher extends StatefulWidget {
  final ImageAnimationSwitcherController? controller;
  final List<Widget> images;
  final int initIndex;
  /// widget切换
  final ImageAnimationSwitchType widgetSwitchType;
  final BoxFit fit;
  /// 每个动画之前的切换时长
  final Duration switchInterval;
  /// 每次动画结束停留时间
  final Duration stayInterval;
  final void Function(int index)? onIndexChanged;
  /// 要切换句子的时候的回调 接受制定下标 currentSwitchInterval:当前动画的持续时长 currentIndex:当前下标
  final Future<int?>? Function(Duration? currentSwitchInterval, int currentIndex)? onSwitchIndex;
  
  const ImageAnimationSwitcher({
    super.key,
    this.controller,
    required this.images,
    this.initIndex = 0,
    this.widgetSwitchType = ImageAnimationSwitchType.random,
    this.fit = BoxFit.cover,
    this.switchInterval = const Duration(seconds: 1),
    this.stayInterval = const Duration(seconds: 1),
    this.onIndexChanged,
    this.onSwitchIndex,
  });

  @override
  State<ImageAnimationSwitcher> createState() => _ImageAnimationSwitcherState();
}

class _ImageAnimationSwitcherState extends State<ImageAnimationSwitcher> with TickerProviderStateMixin {
  AnimationController? _controller;
  final Random _random = Random();
  int _currentIndex = 0;
  MVAnimation? _currentAnimation;

  Timer? _switchTimer;
  Timer? _stayTimer;

  /// 是否显示黑屏 切换图片的时候不那么突兀
  bool showBlackScreen = false;

  /// 持续回调知识点下标timer
  Timer? _knowledgeIndexTimer;

  // 动画库 - 每个动画都有不同的时长
  final List<MVAnimation> _animationLibrary = [

    KenBurnsEffectAnimation(),
    DollyZoomAnimation(),
    TranslationAnimation(direction: Alignment.centerLeft),
    TranslationAnimation(direction: Alignment.centerRight),
    TranslationAnimation(direction: Alignment.topCenter),
    TranslationAnimation(direction: Alignment.bottomCenter),
    TranslationAnimation(direction: Alignment.topLeft),
    TranslationAnimation(direction: Alignment.topRight),
    TranslationAnimation(direction: Alignment.bottomLeft),
    TranslationAnimation(direction: Alignment.bottomRight),
  ];

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
    _currentIndex = widget.initIndex;
    
    // 初始控制器，后续会根据动画时长动态调整
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _controller?.addStatusListener((status) {
      if(status == AnimationStatus.completed){
        print('动画完成');
        _switching();
      }
    });
    
    _setRandomAnimation();
    _startAutoPlay(nextImg: false);

  }

  @override
  void dispose() {
    _knowledgeIndexTimer?.cancel();
    _controller?.dispose();
    _controller = null;
    _switchTimer?.cancel();
    _stayTimer?.cancel();
    super.dispose();
  }
  
  void _startAutoPlay({bool nextImg = false, double from = 0}) {
    
    if(nextImg) _setNextImage();

    _controller?.forward(from: from);
    
  }


  /// 切换中
  void _switching(){
    _switchTimer?.cancel();
    _stayTimer?.cancel();
    _stayTimer = Timer(widget.stayInterval, (){
      if(!mounted) return;

      // 先调用回调 让外部有机会切换index
      if(widget.onSwitchIndex != null){
        
        _startKnowledgeIndexTimer(
          onComplete: (index) {
            if(!mounted) return;
            showBlackScreen = true;
            if(mounted) setState(() {});

            _switchTimer = Timer(widget.switchInterval, (){
              if(!mounted) return;
              showBlackScreen = false;
              int len = widget.images.length;
              int nextIdx = len > 0 ? (index % len) : 0;
              _currentIndex = nextIdx;
              if(mounted) setState(() {});
              widget.onIndexChanged?.call(_currentIndex);
              if(mounted) setState(() {});
              _currentAnimation = _animationLibrary[_random.nextInt(_animationLibrary.length)];
              _controller?.duration = _currentAnimation!.duration;
              _startAutoPlay();
            });
          },
        );
        return;
      }

      showBlackScreen = true;
      if(mounted) setState(() {});

      _switchTimer = Timer(widget.switchInterval, (){
        if(!mounted) return;
        showBlackScreen = false;
        if(mounted) setState(() {});
        _setRandomAnimation();
        _startAutoPlay();
      });

    });
  }


  /// 随机动画
  void _setRandomAnimation(){
    // 随机选择动画
    _currentAnimation = _animationLibrary[_random.nextInt(_animationLibrary.length)];
    
    _controller?.duration = _currentAnimation!.duration;
  }
  
  /// 持续回调知识点下标（优化：避免递归创建Timer导致内存泄漏）
  void _startKnowledgeIndexTimer({required void Function(int index) onComplete}) {
    _knowledgeIndexTimer?.cancel();
    _pollKnowledgeIndex(onComplete);
  }

  /// 轮询获取知识点下标
  Future<void> _pollKnowledgeIndex(void Function(int index) onComplete) async {
    if (!mounted) {
      _knowledgeIndexTimer?.cancel();
      return;
    }
    
    int? onIndex = await widget.onSwitchIndex?.call(_currentAnimation?.duration, _currentIndex);
    
    if (!mounted) return;
    
    if (onIndex != null) {
      _knowledgeIndexTimer?.cancel();
      onComplete.call(onIndex);
      return;
    }
    
    // 使用单次Timer而非Timer.periodic，避免并发和递归问题
    _knowledgeIndexTimer = Timer(const Duration(milliseconds: 100), () {
      _pollKnowledgeIndex(onComplete);
    });
  }

  /// 获取下一个image
  Future<void> _setNextImage() async{
    if (widget.images.length <= 1) return;
    if(!mounted) return;

    if(widget.widgetSwitchType == ImageAnimationSwitchType.order){
      _currentIndex = (_currentIndex) + 1;
      _currentIndex = _currentIndex % widget.images.length;
    }else{
      int nextIndex = _random.nextInt(widget.images.length - 1);
      if (nextIndex >= _currentIndex) {
        nextIndex += 1;
      }
      _currentIndex = nextIndex;
    }
    widget.onIndexChanged?.call(_currentIndex);

    if(mounted) setState(() {});
  }
  
  /// 暂停切换
  void _pauseSwitching(){
    _switchTimer?.cancel();
    _stayTimer?.cancel();
    _knowledgeIndexTimer?.cancel();
    _controller?.stop();
  }

  /// 继续切换
  void _resumeSwitching(){
    _setRandomAnimation();
    _startAutoPlay(from: _controller?.value ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) return const SizedBox();
    if(_controller == null) return const SizedBox();

    return ClipRect(
      child: FittedBox(
        fit: widget.fit,
        alignment: const Alignment(0, -0.7),
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _controller!,
              builder: (context, child) {
                if (_currentAnimation == null) {
                  return widget.images[_currentIndex % widget.images.length];
                }
                
                return _currentAnimation!.buildAnimation(
                  context,
                  _controller!,
                  widget.images[_currentIndex % widget.images.length],
                );
              },
            ),
            Positioned.fill(
              child: AnimatedOpacity(
                duration: widget.switchInterval,
                opacity: showBlackScreen ? 1 : 0,
                child: Container(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    
  }

}

