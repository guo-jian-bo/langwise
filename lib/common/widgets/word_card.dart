import 'package:flutter/material.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/values/values.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

class WordCard extends StatelessWidget {
  final BaseKnowledge entitySemantics;
  final ValueChanged<BaseKnowledge> onDelTap;

  const WordCard({super.key, required this.entitySemantics, required this.onDelTap});

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Stack(
        // 使用Stack实现层叠布局
        clipBehavior: Clip.none, // 允许子元素溢出父容器
        children: [
          // 原有容器作为背景层
          Container(
            height: 50.wh,
            padding: EdgeInsets.only(
              left: 10.ww,
              // 右侧增加间距防止文字被按钮覆盖
              right: 24.ww,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.wMin),
              border: Border.all(
                color: const Color(0xff4B5268),
                width: 1.wMin,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              entitySemantics.content ?? "",
              overflow: TextOverflow.ellipsis,
              style: TextStyleExtension.ts_16_w400_EDF0F4,
            ),
          ),

          // 删除按钮定位层
          Positioned(
            right: 0.ww, // 向右微调位置
            top: 0.wh, // 向上微调位置
            child: TapScaleWidget(
              onTap: () {
                // 触发删除回调
                debugPrint("删除句型标签: ${entitySemantics.uid}");
                // 此处应调用状态管理删除逻辑，例如：
                onDelTap.call(entitySemantics);
              },
              child: SizedBox(
                width: 24.wMin,
                height: 24.wMin,
                child: Icon(
                  Icons.close,
                  size: 18.wMin,
                  color: const Color(0xFFB2BAC2),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
