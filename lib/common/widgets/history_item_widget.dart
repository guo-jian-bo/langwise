import 'package:flutter/material.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/generated/assets.dart';
import 'package:ui_essentials/ui_essentials.dart';

/// 历史记录项组件
///
/// 用于显示图片历史记录，支持单选功能
/// 选中时显示蓝色边框，未选中时无边框
class HistoryItemWidget extends StatefulWidget {
  /// 历史图片数据
  final ImageItem historyImage;

  /// 是否选中
  final bool isSelected;

  /// 点击选中回调
  /// 参数：索引
  final Function(int index)? onSelected;

  /// 索引
  final int index;

  /// 默认提示词
  final String? defaultPrompt;

  /// 批次数量（可选，如果提供则显示批次数量，否则显示索引+1）
  final int? batchCount;

  const HistoryItemWidget({
    Key? key,
    required this.historyImage,
    required this.isSelected,
    required this.index,
    this.onSelected,
    this.defaultPrompt,
    this.batchCount,
  }) : super(key: key);

  @override
  State<HistoryItemWidget> createState() => _HistoryItemWidgetState();
}

class _HistoryItemWidgetState extends State<HistoryItemWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onSelected?.call(widget.index);
      },
      child: Container(
        width: 192.ww,
        decoration: BoxDecoration(
          color: const Color(0xFF364153), // bg-gray-700
          borderRadius: BorderRadius.circular(8.wMin),
          // 选中时显示蓝色边框，未选中时无边框
          border: widget.isSelected
              ? Border.all(
                  color: const Color(0xff2388FF),
                  width: 2.wMin,
                )
              : Border.all(
                  color: Colors.transparent,
                  width: 2.wMin,
                ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 预览图片
            SizedBox(
              width: 192.ww,
              height: 128.wh,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8.wMin),
                          topRight: Radius.circular(8.wMin),
                        ),
                        color: const Color(0xFF4B5563),
                      ),
                      child: CachedImageWidget(
                        widget.historyImage.imageUrl ?? '',
                        width: double.infinity,
                        height: double.infinity,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8.wMin),
                          topRight: Radius.circular(8.wMin),
                        ),
                        fit: BoxFit.cover,
                        placeholder: buildLoadingWidget(),
                        errorWidget: buildImage(
                          Assets.managerImageNotFound,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  // 右上角数字圆圈
                  Positioned(
                    top: 8.ww,
                    right: 8.ww,
                    child: Container(
                      width: 24.wMax,
                      height: 24.wMax,
                      decoration: const BoxDecoration(
                        color: Color(0xff2388FF),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        // 优先显示批次数量
                        '${widget.batchCount}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.wMin,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 历史记录信息
            Padding(
              padding: EdgeInsets.all(12.wMin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    widget.historyImage.newCreated,
                    style: TextStyle(
                      color: const Color(0xFFD1D5DB),
                      fontWeight: FontWeight.w400,
                      fontSize: 12.wMin,
                    ),
                  ),
                  Text(
                    widget.historyImage.prompt ?? widget.defaultPrompt ?? '默认提示词',
                    style: TextStyle(
                      color: const Color(0xFFD1D5DB),
                      fontWeight: FontWeight.w400,
                      fontSize: 14.wMin,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "${widget.historyImage.localeTitle} ${widget.historyImage.styleTitle}",
                    style: TextStyle(
                      color: const Color(0xFF99A1AF),
                      fontWeight: FontWeight.w400,
                      fontSize: 12.wMin,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
