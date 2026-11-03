import 'dart:math';

import 'package:flutter/material.dart';
import 'config/MeteoriteConfig.dart';
import 'config/StarsConfig.dart';
import 'meteor/Meteorite.dart';
import 'meteor/MeteoriteCompleteListener.dart';
import 'stars/BaseStar.dart';
import 'stars/StarCompleteListener.dart';
import 'stars/StarConstraints.dart';
import 'utils/RandomUtils.dart';

class StarsViewPainter extends CustomPainter implements StarCompleteListener, MeteoriteCompleteListener {

  StarsViewPainter( ValueNotifier<bool> shouldRepaint, {
    this.starsConfig = const StarsConfig(),
    this.meteoriteConfig = const MeteoriteConfig()
  }): super(repaint: shouldRepaint){
    _repaint = shouldRepaint;
    _starConstraints = StarConstraints(
      minStarSize: starsConfig.minStarSize,
      maxStarSize: starsConfig.maxStarSize,
      bigStarThreshold: 259821
    );
  }

  final StarsConfig starsConfig;
  final MeteoriteConfig meteoriteConfig;

  late ValueNotifier<bool> _repaint;
  late StarConstraints _starConstraints;

  final Random _random = Random();

  double _screenWidth = 0.0;
  double _screenHeight = 0.0;
  bool _initialized = false;

  final Map<int, BaseStar> _starMaps = <int, BaseStar>{};

  Meteorite? _meteorite;
  int _meteoriteTick = 0;
  bool _meteoriteOnScreen = false;

  void handleChange(){
    debugPrint('ORIENTATION CHANGED');
    _initialized = false;
  }

  int _initialDelayTick = 0;     // 新增：初始延迟计数器
  bool _firstMeteoriteCreated = false;  // 新增：是否已创建第一个流星
  
  void start(){
    for(int i = 0; i <= starsConfig.starCount; i++){
      final BaseStar _star = _createStar(i);
      _starMaps[i] = _star;
    }

    // 移除立即创建流星的逻辑
    // if(meteoriteConfig.enabled){
    //   _createMeteorite();
    // }
  }
  
  @override
  void paint(Canvas canvas, Size size) {
    if(!_initialized){
      _screenWidth = size.width;
      _screenHeight = size.height;
      debugPrint('WIDTH: $_screenWidth HEIGHT: $_screenHeight');
      _initialized = true;
      start();
    }

    if(meteoriteConfig.enabled){
      // 处理初始延迟
      if (!_firstMeteoriteCreated) {
        _initialDelayTick++;
        // 假设60fps，将毫秒转换为帧数
        int delayFrames = (meteoriteConfig.initialDelay * 60 / 1000).round();
        if (_initialDelayTick > delayFrames) {
          _createMeteorite();
          _firstMeteoriteCreated = true;
        }
      } else {
        // 后续流星的间隔逻辑
        if(!_meteoriteOnScreen) {
          _meteoriteTick++;
        }
        if(_meteoriteTick > meteoriteConfig.intervalDelay){
          _createMeteorite();
        }
      }
    }

    if(_repaint.value){
      _updateFrame(canvas, size);
    }else{
      _updateFrame(canvas, size);
    }

  }

  void _updateFrame(Canvas canvas, Size size){
    for(final BaseStar star in _starMaps.values.toList()){
      star.draw(canvas);
    }
    _meteorite?.updateFrame(size.width, size.height);
    _meteorite?.draw(canvas);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  @override
  void onStarAnimationComplete(int id) {
    _starMaps.remove(id);
    _starMaps[id] = _createStar(id);
  }

  BaseStar _createStar(int id){

    starsConfig.colors.randomElement(_random);

    return BaseStar(
      id: id,
      random: _random,
      color: starsConfig.colors.randomElement(_random),
      x: doubleInRange(_random, 0.0, _screenWidth),
      y: doubleInRange(_random, 0.0, _screenHeight),
      starListener: this,
      starConstraints: _starConstraints
    );
  }

  void _createMeteorite(){
    _meteoriteTick = 0;
    _meteoriteOnScreen = true;
    
    // 根据屏幕尺寸调整所有参数
    double sizeFactor = 1.0;
    double strokeFactor = 1.0;
    double speedFactor = 1.0;  // 新增速度因子
    
    if (_screenWidth < 600) { // 手机屏幕
      sizeFactor = 0.3;
      strokeFactor = 0.5;
      speedFactor = 0.8;  // 手机端稍微慢一点
    } else if (_screenWidth < 1200) { // 平板屏幕
      sizeFactor = 0.6;
      strokeFactor = 0.7;
      speedFactor = 0.9;
    }
    
    double adjustedMinSize = meteoriteConfig.minMeteoriteSize * sizeFactor;
    double adjustedMaxSize = meteoriteConfig.maxMeteoriteSize * sizeFactor;
    double adjustedStrokeWidth = 2.0 * strokeFactor;
    
    // 使用配置的速度参数
    double meteoriteSpeed = doubleInRange(_random, 
        meteoriteConfig.minMeteoriteSpeed * speedFactor, 
        meteoriteConfig.maxMeteoriteSpeed * speedFactor);
    
    _meteorite = Meteorite(
        smallestWidth: 2,
        starSize: doubleInRange(_random, adjustedMinSize, adjustedMaxSize),
        strokeWidth: adjustedStrokeWidth,
        maxTrailLength: _screenWidth < 600 ? 60 : 180,
        speed: meteoriteSpeed,  // 使用计算出的速度
        startX: _screenWidth,
        startY: doubleInRange(_random, 0, _screenHeight),
        listener: this,
        random: _random,
        color: meteoriteConfig.colors.randomElement(_random)
    );
  }

  @override
  void onMeteoriteComplete() {
    _meteorite = null;
    _meteoriteTick = 0;
    _meteoriteOnScreen = false;
  }



}