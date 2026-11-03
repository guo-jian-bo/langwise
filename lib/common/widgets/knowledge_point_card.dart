import 'package:flutter/material.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

/// 知识点暂存区卡片组件
/// 用于显示知识点暂存区的容器
class KnowledgePointCard extends StatelessWidget {
  /// 子组件
  final Widget? child;

  /// 构造函数
  const KnowledgePointCard({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180.ww,
      height: 242.wh,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        gradient: const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          stops: [0.564, 1.3698],
          colors: [
            Color(0xFF18191A), // --dark-1-surface-secondary
            Color(0xFF082F49), // --color-LW-brand-sky-7
          ],
        ),
      ),
      child: Text('知识点暂存区',
          style: TextStyle(color: AppTheme.cStaticPrimary, fontWeight: FontWeight.w500, fontSize: 20.wMin)),
    );
  }
}
