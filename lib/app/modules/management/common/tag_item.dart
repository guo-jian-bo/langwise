import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

/// 标签项组件
class TagItem extends StatelessWidget {
  final int index;
  final String value;
  final bool readOnly;
  final Function(int) onDelete;

  const TagItem({
    super.key,
    required this.index,
    required this.value,
    this.readOnly = false,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 12.ww),
      padding: EdgeInsets.symmetric(horizontal: 8.ww, vertical: 8.wh),
      decoration: BoxDecoration(
        color: const Color(0xff49557A),
        borderRadius: BorderRadius.circular(4.wMin),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 14.wMin,
              color: const Color(0xffEBEEF3),
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(width: 4.ww),
          GestureDetector(
            onTap: () => onDelete(index),
            child: Container(
              width: 16.wMin,
              height: 16.wMin,
              decoration: const BoxDecoration(
                color: Color(0xff19213D),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.close,
                size: 12.wMin,
                color: const Color(0xff767E95),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
