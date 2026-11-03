/*
 * 星云视图组件 (NebulaViewWidget) 的实现与优化
 * 
 * 需求概述：
 * 1. 中心球体显示前缀"dis-"
 * 2. 多个轨道围绕中心球体旋转，每个轨道有不同的颜色和标签
 * 3. 每个轨道上有多个行星，显示带有"dis-"前缀的单词
 * 4. 点击行星可以查看单词的翻译
 * 5. 动画平滑连续，没有突然重置的感觉
 * 6. 轨道标签跟随轨道旋转，始终可见
 * 7. 行星文字保持水平可读
 * 8. 根据轨道半径自动计算能容纳的最大行星数量
 * 
 * 实现过程：
 * 1. 基础结构设计：创建数据模型类，使用SingleTickerProviderStateMixin和AnimationController
 * 2. 动画控制优化：使用repeat()方法实现无限循环，设置较长的动画周期
 * 3. 轨道与标签：使用CustomPaint绘制轨道，标签使用Container和Text组合
 * 4. 行星布局与交互：计算最大行星数量，使用角度偏移避免遮挡
 * 5. 颜色统一：每个轨道使用同一种颜色，只是透明度不同
 * 6. 性能优化：限制每个轨道显示的行星数量，避免过度拥挤
 */

import 'dart:math' as math;
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/common/stores/stores.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:langwise/utils/utils.dart';
import 'package:themed/themed.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:langwise/theme/theme.dart';

import '../entities/entities.dart';

/// 轨道上的行星数据模型
class PlanetData {
  final String word;
  final List<LanguageText?>? gloss;
  final String? pos; // 轨道标签（如"动词"、"名词"、"形容词"）
  final String? posTitle; // 轨道标签（如"动词"、"名词"、"形容词"）
  final CardMorphemeDetilsEntityContentList? data;

  const PlanetData({
    required this.word,
    this.gloss,
    this.pos,
    this.posTitle,
    this.data,
  });
}

/// 轨道数据模型
class OrbitData {
  final String pos; // 轨道标签（如"动词"、"名词"、"形容词"）
  final String? posTitle; // 轨道标签（如"动词"、"名词"、"形容词"）
  final List<PlanetData> planets; // 轨道上的行星

  const OrbitData({
    required this.pos,
    this.posTitle,
    required this.planets,
  });
}

class NebulaViewWidget extends StatefulWidget {
  final List<OrbitData> orbits;
  final String? content;
  final String? type;
  final List<LanguageConfigColorEntityInfo?>? colorConfigs;
  final void Function()? onTapCenter;
  final void Function(PlanetData data)? onTapWord;
  
  /// 星云视图
  const NebulaViewWidget({
    super.key, 
    this.onTapCenter, 
    required this.orbits, 
    this.content, 
    this.type,
    this.colorConfigs,
    this.onTapWord,
  });

  @override
  State<NebulaViewWidget> createState() => _NebulaViewWidgetState();
}

class _NebulaViewWidgetState extends State<NebulaViewWidget> with TickerProviderStateMixin {
  final ConfigController configController = Get.find<ConfigController>();

  late AnimationController _controller;
  late AnimationController _borderController;
  int? _selectedOrbitIndex;
  int? _selectedPlanetIndex;

  // --- 控制参数 ----
  
  /// 行星之间的最小弧长间距
  final double minPlanetArcSpacing = 20.wMin;
  
  /// 每个轨道上显示的最大行星数量，如果设置为-1则根据轨道半径自动计算
  final int maxPlanetsPerOrbit = -1;

  /// 转速 每层轨道速度增加
  final double orbitSpeedFactor = 0.15;

  final TransformationController transformationController = TransformationController();
  


  // 模拟数据 - 实际应用中可以从外部传入
  // final List<OrbitData> _orbits = const [
  //   OrbitData(
  //     pos: 'adv',
  //     posTitle: '副词',
  //     color: Color(0xFFF59E0B),
  //     planets: [
  //       PlanetData(word: 'cover', translation: '揭露', color: Color(0xFFF59E0B)),
  //       PlanetData(word: 'like', translation: '不喜欢', color: Color(0xFFF59E0B)),
  //       PlanetData(word: 'arm', translation: '解除武装', color: Color(0xFFF59E0B)),
  //       PlanetData(word: 'agree', translation: '不同意', color: Color(0xFFF59E0B)),
  //       PlanetData(word: 'connect', translation: '断开连接', color: Color(0xFFF59E0B)),
  //     ],
  //   ),
  //   OrbitData(
  //     pos: 'noun',
  //     posTitle: '名词',
  //     color: Color(0xFF3B82F6),
  //     planets: [
  //       PlanetData(word: 'comfort', translation: '不舒服', color: Color(0xFF3B82F6)),
  //       PlanetData(word: 'belife', translation: '不信任', color: Color(0xFF3B82F6)),
  //       PlanetData(word: 'order', translation: '混乱', color: Color(0xFF3B82F6)),
  //     ],
  //   ),
  //   OrbitData(
  //     pos: 'adj',
  //     posTitle: '形容词',
  //     color: Color(0xff00BC7D),
  //     planets: [
  //       PlanetData(word: 'honest', translation: '不诚实', color: Color(0xff00BC7D)),
  //       PlanetData(word: 'loyal', translation: '不忠诚', color: Color(0xff00BC7D)),
  //       PlanetData(word: 'pleased', translation: '不满意', color: Color(0xff00BC7D)),
  //     ],
  //   ),
  // ];

  // 用于存储动画开始时间，确保连续旋转
  DateTime? _animationStartTime;
  // 存储暂停时的动画值，用于恢复动画时保持连续性
  double? _pausedValue;
  // 存储暂停时的时间点
  DateTime? _pausedTime;
  
  @override
  void initState() {
    super.initState();
    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 50),
    );
    
    // 记录动画开始时间
    _animationStartTime = DateTime.now();
    
    // 使用无限循环，确保动画连续
    _controller.repeat(reverse: false);
    
    // 添加状态监听器，确保动画不会停止
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.repeat(reverse: false);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      
      RenderBox? mainRenderBox = context.findRenderObject() as RenderBox?;
      if (mainRenderBox != null) {

        // 计算居中所需的偏移量
        double dx = (mainRenderBox.size.width - 5000.0) / 2;
        double dy = (mainRenderBox.size.height - 5000.0) / 2;
        
        // 应用变换以水平居中显示
        transformationController.value = Matrix4.identity()
          ..translate(dx, dy);

        if(mounted) setState(() {});
      }
    });
  }

  @override
  void dispose() {
    PlayAudioUtils.instance.stopAll();
    _controller.dispose();
    _borderController.dispose();
    super.dispose();
  }


  /// 暂停旋转动画
  void pauseAnimation() {
    // 如果动画已经暂停，则不需要操作
    if (!_controller.isAnimating) return;
    
    // 存储当前动画值和暂停时间
    _pausedValue = _controller.value;
    _pausedTime = DateTime.now();
    
    // 停止动画控制器
    _controller.stop();

    _borderController.repeat(reverse: false);
  }

  /// 继续旋转动画
  void resumeAnimation() {
    // 如果控制器已经在运行，则不需要操作
    if (_controller.isAnimating) return;

    _borderController.stop();
    
    // 如果有暂停的值和时间，则计算新的动画起始时间以保持连续性
    if (_pausedValue != null && _pausedTime != null && _animationStartTime != null) {
      // 计算暂停的持续时间
      final pauseDuration = DateTime.now().difference(_pausedTime!);
      
      // 更新动画开始时间，加上暂停的时间，确保动画连续
      _animationStartTime = _animationStartTime!.add(pauseDuration);
      
      // 从当前位置继续动画
      _controller.forward();
    } else {
      // 如果没有暂停值，则重新开始动画
      _controller.repeat(reverse: false);
      _animationStartTime = DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    final centerSize = _calculateCenterSize();
    double maxRadius = 5000.0;
    
    return GestureDetector(
      onTap: () {
        if(_selectedOrbitIndex == null && _selectedPlanetIndex == null) return;
        _selectedOrbitIndex = null;
        _selectedPlanetIndex = null;
        
        resumeAnimation();
        setState(() {});
      },
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: InteractiveViewer(
          transformationController: transformationController,
          constrained: false,
          maxScale: 2,
          minScale: 0.3,
          boundaryMargin: const EdgeInsets.all(1000),
          child: Container(
            width: maxRadius,
            height: maxRadius,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              // color: Colors.yellow.withValues(alpha: 0.1),
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return SizedBox(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                              
                      // 绘制所有轨道
                      ..._buildOrbits(maxRadius, centerSize),
                              
                      // 中心球体
                      _buildCenterBallWidget(),
                      
                      // 绘制所有行星
                      ..._buildPlanets(maxRadius, centerSize),
                      
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // 计算中心球体大小
  double _calculateCenterSize() {
    String text = widget.content ?? "";
    final TextStyle textStyle = TextStyle(
      fontSize: 32.wMin,
      fontWeight: FontWeight.w600,
      color: AppTheme.cStaticWhite,
    );

    // 获取文字的宽度
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final double textWidth = textPainter.size.width;
    final double textHeight = textPainter.size.height;

    final double size = math.max(textWidth, textHeight) + 20.wMin;
    return size;
  }
  

  /// 中心球体
  Widget _buildCenterBallWidget() {
    
    Color color = StatusUtils.getMorphemeTagColor(widget.type);

    final double size = _calculateCenterSize();

    return TapScaleWidget(
      onTap: widget.onTapCenter,
      sclae: 1.03,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Text(
          widget.content ?? "",
          style: TextStyle(
            fontSize: 32.wMin,
            fontWeight: FontWeight.w600,
            color: AppTheme.cStaticWhite,
          ),
        ),
      ),
    );
  }

  // 构建所有轨道
  List<Widget> _buildOrbits(double maxRadius, double centerSize) {
    final List<Widget> orbits = [];
    double currentRadius = centerSize + 60.wMin; // 第一个轨道的半径

    for (int i = 0; i < widget.orbits.length; i++) {
      final orbit = widget.orbits[i];
      
      // 计算轨道上行星的最大尺寸，用于确定下一个轨道的半径
      double maxPlanetSize = 0;
      for (final planet in orbit.planets) {
        final TextPainter textPainter = TextPainter(
          text: TextSpan(
            text: planet.word,
            style: TextStyle(fontSize: 16.wMin, fontWeight: FontWeight.w500),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        maxPlanetSize = math.max(maxPlanetSize, textPainter.size.width + 20.wMin);
      }

      LanguageConfigColorModel? colorInfo = StatusUtils.getConfigColorForAbbr(widget.colorConfigs, orbit.pos);
      
      // 添加旋转的轨道和标签
      orbits.add(
        RotationTransition(
          // 直接使用控制器的值作为旋转角度，确保无缝连接
          turns: _controller,

          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // 轨道
              CustomPaint(
                painter: OrbitPainter(
                  radius: currentRadius,
                  color: (colorInfo?.color?.borderColor??AppTheme.cBgBrand).addOpacity(0.3),
                  dashPattern: [5.wMin, 5.wMin],
                ),
              ),
              
              // 标签（跟随轨道旋转）
              Positioned(
                top: currentRadius - 14.wMin, // 定位在轨道正上方，并稍微提高位置
                child: Container(
                  height: 28.wMin,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 6.wMin),
                  decoration: BoxDecoration(
                    color: colorInfo?.color?.bgColor.withValues(alpha: 0.2), // 使用轨道颜色作为背景，但透明度较高
                    borderRadius: BorderRadius.circular(4.wMin),
                    border: Border.all(width: 1.wMin, color: colorInfo?.color?.borderColor??AppTheme.cBgBrand),
                  ),
                  child: Text(
                    orbit.posTitle??"",
                    style: TextStyle(
                      color: AppTheme.cTextSecondary,
                      fontSize: 16.wMin,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      
      // 更新下一个轨道的半径
      // 根据行星大小动态调整轨道间距
      final orbitSpacing = maxPlanetSize * 1.6; // 轨道间距 = 行星大小 * 1.5
      currentRadius += orbitSpacing;
      
    }
    
    return orbits;
  }

  // 构建所有行星
  List<Widget> _buildPlanets(double maxRadius, double centerSize) {
    

    final List<Widget> planets = [];
    double currentRadius = centerSize + 60.wMin; // 第一个轨道的半径

    for (int orbitIndex = 0; orbitIndex < widget.orbits.length; orbitIndex++) {
      final orbit = widget.orbits[orbitIndex];
      final int planetCount = orbit.planets.length;
      
      // 计算轨道上行星的最大尺寸
      double maxPlanetSize = 0;
      for (final planet in orbit.planets) {
        final TextPainter textPainter = TextPainter(
          text: TextSpan(
            text: planet.word,
            style: TextStyle(fontSize: 16.wMin, fontWeight: FontWeight.w500),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        maxPlanetSize = math.max(maxPlanetSize, textPainter.size.width + 20.wMin);
      }
      
      // 计算轨道能容纳的最大行星数量
      // 完全根据轨道半径和行星大小来计算
      
      // 计算轨道周长
      final circumference = 2 * math.pi * currentRadius;
      
      // 计算每个行星实际需要的空间，包括行星本身和间距
      // 在这里，我们使用行星大小加上一个小的间距
      final planetWithSpacing = maxPlanetSize + minPlanetArcSpacing;
      
      // 计算轨道上最多能放置的行星数量
      // 公式：轨道周长 / 每个行星占用的空间（包括间距）
      int maxPlanets = math.max(1, (circumference / planetWithSpacing).floor());
      
      // 限制最大数量不超过实际行星数量
      maxPlanets = math.min(planetCount, maxPlanets);
      
      // 限制显示的行星数量
      final displayPlanetCount = math.min(planetCount, maxPlanets);
      
      // 添加行星
      for (int planetIndex = 0; planetIndex < displayPlanetCount; planetIndex++) {
        final planet = orbit.planets[planetIndex];
        
        // 计算行星在轨道上的位置，从偏移角度开始，避免遮挡标签
        // 将起始角度从-π/2（12点钟方向）偏移
        const startOffset = math.pi * 30 / 180; // 将角度转换为弧度
        // 均匀分布行星，确保它们之间的角度间距相等
        final baseAngle = -math.pi/2 + startOffset + (planetIndex * (2 * math.pi / displayPlanetCount));
        
        // 使用动画控制器的值计算角度，而不是依赖时间差
        // 这样可以确保暂停和恢复时位置保持一致
        final speedFactor = 1.0 + (orbitIndex * orbitSpeedFactor); // 每层轨道速度增加15%
        
        // 计算从动画开始到现在的时间差（毫秒）
        final rotationAngle = _controller.value * math.pi * 2 * speedFactor;
        
        // 结合基础角度和旋转角度
        final currentAngle = baseAngle + rotationAngle;
        
        final x = math.cos(currentAngle) * currentRadius;
        final y = math.sin(currentAngle) * currentRadius;
        
        final isSelected = _selectedOrbitIndex == orbitIndex && 
                           _selectedPlanetIndex == planetIndex;
        
        // 计算行星大小
        final planetSize = _calculatePlanetSize(planet, isSelected);

        double top = y - planetSize / 2 - 15.wMin;
        double left = x - planetSize / 2 - 15.wMin;

        
        planets.add(
          Positioned(
            left: left + maxRadius / 2,
            top: top + maxRadius / 2,
            // 使用z-index确保外层行星不被内层遮挡
            child: Transform(
              transform: Matrix4.identity()..translate(0.0, 0.0, 10.0 * (orbitIndex + 1)),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      if(widget.onTapWord != null){
                        widget.onTapWord?.call(planet);
                      }else{
                        if(_selectedOrbitIndex == null && _selectedPlanetIndex == null) return;
                        // 取消选择
                        _selectedOrbitIndex = null;
                        _selectedPlanetIndex = null;
                        resumeAnimation();
                      }
                      
                    } else {
                      // 选择行星
                      _selectedOrbitIndex = orbitIndex;
                      _selectedPlanetIndex = planetIndex;
                      pauseAnimation();

                      String? national = UserStore.to.userInfo.value.config?.national;

                      List<CardMorphemeDetilsEntityContentListPronunciations?>? pronunciations = planet.data?.pronunciations;
                      String? audioUrl;
                      for(int i = 0; i < (pronunciations?.length??0); i++){
                        if(pronunciations?[i]?.national == national){
                          audioUrl = pronunciations?[i]?.audioUrl;
                        }
                      }
                      
                      PlayAudioUtils.instance.playSingle(audioUrl);

                    }
                  });
                },
                child: _buildPlanetWidget(planet, isSelected),
              ),
            ),
          ),
        );
      }
      
      // 更新下一个轨道的半径
      // 根据行星大小动态调整轨道间距
      final orbitSpacing = maxPlanetSize * 1.6; // 轨道间距 = 行星大小 * 1.5
      currentRadius += orbitSpacing;

    }
    
    return planets;
  }
  
  // 计算行星大小
  double _calculatePlanetSize(PlanetData planet, bool isSelected) {
    final TextStyle textStyle = TextStyle(
      fontSize: 18.wMin,
      fontWeight: FontWeight.w500,
      color: AppTheme.cStaticWhite,
    );

    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: planet.word, style: textStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final double textWidth = textPainter.size.width;
    return textWidth + 20.wMin;
  }

  // 构建单个行星
  Widget _buildPlanetWidget(PlanetData planet, bool isSelected) {

    Color color = StatusUtils.getMorphemeTagColor(widget.type);

    LanguageConfigColorModel? colorInfo2 = StatusUtils.getConfigColorForAbbr(widget.colorConfigs, planet.pos);

    final TextStyle textStyle = TextStyle(
      fontSize: isSelected ? 24.wMin : 18.wMin,
      fontWeight: FontWeight.w500,
      color: AppTheme.cTextPrimary,
    );

    final fixWidth = 200.wMin;
    
    String? content = widget.content?.replaceAll("-", "");
    int index = planet.word.indexOf(content ?? "");

    String before = "";
    String after = "";

    if(index != -1){
      after = planet.word.substring(index + (content ?? "").length); // "dis" 之后的部分
      before = planet.word.substring(0, index); // "dis" 之前的部分
    }else{
      return Container();
    }
    
    // 计算行星大小
    final double size = _calculatePlanetSize(planet, isSelected);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      alignment: Alignment.center,
      transform: Matrix4.translationValues(
        isSelected ? -((fixWidth - size) / 2) : 0,
        isSelected ? -((fixWidth - size) / 2) : 0,
        0,
      ),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          RotationTransition(
            turns: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: _borderController, curve: Curves.linear),
            ),
            child: AnimatedOpacity(
              opacity: isSelected ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: DottedBorder(
                color: colorInfo2?.color?.borderColor??AppTheme.cBgBrand, // 要用词性的颜色
                borderType: BorderType.Circle,
                padding: EdgeInsets.zero,
                dashPattern: [3.wMin, 3.wMin],
                strokeWidth: 1.wMin,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: (isSelected ? fixWidth : size) + 30.wMin, 
                  height: (isSelected ? fixWidth : size) + 30.wMin,
                ),
              ),
            ),
          ),
          AnimatedContainer(
            width: isSelected ? fixWidth : size,
            height: isSelected ? fixWidth : size,
            duration: const Duration(milliseconds: 300),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorInfo2?.color?.borderColor.withValues(alpha: isSelected ? 0 : 0.1), //要用词性的颜色
              shape: BoxShape.circle,
              border: Border.all(
                color: colorInfo2?.color?.borderColor??Colors.transparent, // 要用词性的颜色
                width: isSelected ? 2.wMin : 1.wMin,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorInfo2?.color?.bgColor.withValues(alpha: isSelected ? 0.2 : 0)??Colors.transparent, // 要用词性的颜色
                  offset: const Offset(0, 0),
                  blurRadius: 10.wMin,
                  spreadRadius: 10.wMin,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedDefaultTextStyle(
                  style: textStyle,
                  duration: const Duration(milliseconds: 300),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: before),
                        TextSpan(
                          text: content ?? "",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                        TextSpan(text: after),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Visibility(
                  visible: isSelected && planet.gloss != null,
                  child: Obx((){
                    LanguageText? gloss = LearningLangUtils.getShowForNone(planet.gloss);
                    
                    if(gloss == null) return Container();
                    return Text(
                      gloss.text??"",
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.wMin,
                        color: AppTheme.cTextSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 轨道绘制器
class OrbitPainter extends CustomPainter {
  final double radius;
  final Color color;
  final List<double> dashPattern;
  final double strokeWidth = 0.5.wMin;

  OrbitPainter({
    required this.radius,
    required this.color,
    required this.dashPattern,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // 绘制虚线轨道
    final path = Path();
    path.addOval(Rect.fromCircle(center: center, radius: radius));
    
    canvas.drawPath(
      dashPath(path, dashPattern: dashPattern),
      paint,
    );
  }

  @override
  bool shouldRepaint(OrbitPainter oldDelegate) {
    return oldDelegate.radius != radius ||
           oldDelegate.color != color;
  }

  // 创建虚线路径
  Path dashPath(Path path, {required List<double> dashPattern}) {
    final dashPath = Path();
    final dashLength = dashPattern[0];
    final gapLength = dashPattern[1];
    final distance = dashLength + gapLength;
    
    var metrics = path.computeMetrics().toList();
    for (var metric in metrics) {
      var totalLength = metric.length;
      var currentDistance = 0.0;
      
      while (currentDistance < totalLength) {
        var start = currentDistance;
        var end = currentDistance + dashLength;
        if (end > totalLength) end = totalLength;
        
        var extractPath = metric.extractPath(start, end);
        dashPath.addPath(extractPath, Offset.zero);
        
        currentDistance += distance;
      }
    }
    
    return dashPath;
  }
}