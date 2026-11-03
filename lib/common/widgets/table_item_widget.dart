import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'unit_item_widget.dart';

class UnitItemWidgetManager {
  static void show({
    required BuildContext context,
    required List<dynamic> list,
    int defaultIndex = 0,
    double? width,
    void Function(int index)? onTap,
  }) {
    BotToast.showAttachedWidget(
      targetContext: context,
      preferDirection: PreferDirection.bottomLeft,
      verticalOffset: 8.0,
      allowClick: false,
      onlyOne: true,
      attachedBuilder: (cancelFunc) {
        return UnitItemWidgetOptionWidget(
          list: list,
          defaultIndex: defaultIndex,
          width: width,
          onTap: (index) {
            cancelFunc.call();
            onTap?.call(index);
          },
        );
      },
    );
  }
}

class UnitItemWidgetOptionWidget extends StatefulWidget {
  final List<dynamic> list;

  // 记录上一次选中的索引
  final int defaultIndex;
  final double? width;
  final void Function(int index)? onTap;

  const UnitItemWidgetOptionWidget(
      {super.key, required this.list, required this.defaultIndex, this.width, this.onTap});

  @override
  State<UnitItemWidgetOptionWidget> createState() => _UnitItemWidgetOptionWidgetState();
}

class _UnitItemWidgetOptionWidgetState extends State<UnitItemWidgetOptionWidget> with SafeSetStateMixin {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: widget.width,
        constraints: BoxConstraints(maxHeight: 280.wh, minHeight: 100.wh),
        decoration: BoxDecoration(
          border: Border.all(width: 1.wMin, color: const Color(0xff444B5F)),
          borderRadius: BorderRadius.circular(8.wMin),
          color: const Color(0xff353E5C),
        ),
        padding: EdgeInsets.only(top: 8.wh, bottom: 8.wh),
        child: AnimationLimiter(
          child: OptimizedListView<String>(
              list: widget.list.map((element) => element.toString()).toList(),
              // 自适应高度
              shrinkWrap: true,
              builder: (BuildContext context, ValueKey key, int index, String item) {
                return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 300),
                    child: SlideAnimation(
                        child: FadeInAnimation(
                            child: UnitItemWidget(
                      index: index,
                      title: item,
                      onTap: (int i) {
                        widget.onTap?.call(i);
                      },
                    ))));
              }),
        ),
      ),
    );
  }
}
