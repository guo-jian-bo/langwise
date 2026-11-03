import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/generated/assets.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

class EditStructureCell extends StatefulWidget {
  final String? title;
  final String? icon;
  final VoidCallback? onTap;

  const EditStructureCell({super.key, this.title, this.icon, this.onTap});

  @override
  State<EditStructureCell> createState() => _EditStructureCellState();
}

class _EditStructureCellState extends State<EditStructureCell> with SafeSetStateMixin {
  EditStructureCellType _editStructureCellType = EditStructureCellType.normal;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: OptimizeUtils.noneThrottle(() {
        safeSetState(() {
          _editStructureCellType = EditStructureCellType.tap;
        });

        0.1.delay(() {
          widget.onTap?.call();
          safeSetState(() {
            _editStructureCellType = EditStructureCellType.normal;
          });
        });
      }, 300),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onHover: (event) {
          safeSetState(() {
            _editStructureCellType = EditStructureCellType.hover;
          });
        },
        onExit: (event) {
          safeSetState(() {
            _editStructureCellType = EditStructureCellType.normal;
          });
        },
        child: Container(
          height: 32.wh,
          margin: EdgeInsets.only(top: 4.wh, bottom: 4.wh),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.wMin),
            color: const Color(0xFF353E5C), // 底色
          ),
          foregroundDecoration: _editStructureCellType.isHover
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(8.wMin),
                  color: const Color.fromRGBO(255, 255, 255, 0.15), // 浅白色蒙层
                )
              : (_editStructureCellType.isTap
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(8.wMin),
                      color: const Color.fromRGBO(25, 33, 61, 0.3), // 浅白色蒙层
                    )
                  : null),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Gaps.getWidth(8.ww),
              buildImage(widget.icon ?? Assets.managerEdit, width: 18.wMin, height: 18.wMin),
              Gaps.getWidth(5.ww),
              Text(
                widget.title ?? '',
                style: TextStyle(
                  color: const Color(0xffEBEEF3),
                  fontSize: 14.wMin,
                  fontWeight: FontWeight.w400,
                  height: 1.0,
                ),
              ),
              Gaps.getWidth(8.ww),
            ],
          ),
        ),
      ),
    );
  }
}

enum EditStructureCellType {
  // normal
  normal(0),
  // hover
  hover(1),
  // 点击
  tap(2);

  final int value;

  const EditStructureCellType(this.value);

  // 工厂方法
  factory EditStructureCellType.fromTitle(int value) {
    return EditStructureCellType.values.firstWhere(
      (type) => type.value == value,
      // 默认值
      orElse: () => EditStructureCellType.normal,
    );
  }
}

extension EditStructureCellTypeExtension on EditStructureCellType {
  bool get isNormal => this == EditStructureCellType.normal;

  bool get isHover => this == EditStructureCellType.hover;

  bool get isTap => this == EditStructureCellType.tap;
}
