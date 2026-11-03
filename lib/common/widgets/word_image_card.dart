import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/generated/assets.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

class WordImageCardWidget extends StatefulWidget {
  final int index;
  final WordImageEntity wordImageEntity;
  final Function(int index)? onDeleteTap;
  final Function(int index, WordImageEntity wordImageEntity)? onTap;
  final Function(int index, WordImageEntity wordImageEntity)? onChanged;

  const WordImageCardWidget(
      {super.key, required this.index, required this.wordImageEntity, this.onTap, this.onDeleteTap, this.onChanged});

  @override
  State<StatefulWidget> createState() => _WordImageCardWidgetState();
}

class _WordImageCardWidgetState extends State<WordImageCardWidget> {
  final TextEditingController _editingController = TextEditingController();

  final FocusNode focusNode = FocusNode();

  // 关键状态追踪
  WordImageEntity? _lastReceivedEntity;

  @override
  void initState() {
    super.initState();
    _editingController.text = widget.wordImageEntity.index?.toString() ?? '';
    _lastReceivedEntity = widget.wordImageEntity;
  }

  @override
  Widget build(BuildContext context) {
    return TapScaleWidget(
        onTap: () {
          widget.onTap?.call(widget.index, widget.wordImageEntity);
        },
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xff141828),
            borderRadius: BorderRadius.circular(8.wMin),
          ),
          padding: EdgeInsets.only(top: 10.wh, left: 8.ww, right: 8.ww, bottom: 10.wh),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Stack(
                children: [
                  Container(
                    width: 216.ww,
                    height: 228.ww,
                    decoration: BoxDecoration(
                      color: const Color(0xff141828),
                      borderRadius: BorderRadius.circular(8.wMin),
                    ),
                    child: Container(
                        width: 146.ww,
                        height: 205.wh,
                        padding: EdgeInsets.only(top: 7.wh, bottom: 7.wh),
                        decoration: BoxDecoration(
                          color: const Color(0xff4B5268).withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4.wMin),
                        ),
                        child: _buildImageWidget()),
                  ),
                  Positioned(
                      top: 5,
                      right: 5,
                      child: GestureDetector(
                        // 添加按钮点击区域扩展
                        behavior: HitTestBehavior.opaque,
                        onTap: OptimizeUtils.noneThrottle(() {
                          widget.onDeleteTap?.call(widget.index);
                        }, 200),
                        child: buildImage(Assets.managerDelete, width: 44.wMax, height: 44.wMax),
                      )),
                ],
              ),
              Gaps.getHeight(3.wh),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '本页页码',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: const Color(0xffACB4C0),
                      fontSize: Dimens.font_sp16.wMin,
                      fontWeight: FontWeight.w400,
                      height: 1.0,
                    ),
                  ),
                  Container(
                      width: 60.wMax,
                      height: 32.wMax,
                      alignment: const Alignment(0, 0),
                      decoration: BoxDecoration(
                        color: const Color(0xff141828),
                        borderRadius: BorderRadius.circular(4.wMin),
                        border: Border.all(width: (0.5).wMin, color: const Color(0xff616B85)),
                      ),
                      child: TextField(
                        controller: _editingController,
                        focusNode: focusNode,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          // 限制输入为数字
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        maxLength: 4,
                        style: TextStyle(
                          fontSize: 14.wMin,
                          color: const Color(0xffEBEEF3),
                          fontWeight: FontWeight.w400,
                        ),
                        textAlignVertical: TextAlignVertical.center,
                        textInputAction: TextInputAction.done,
                        cursorColor: Colors.white,
                        decoration: InputDecoration(
                          isDense: true,
                          counterText: "",
                          hintText: '',
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          hintStyle: TextStyle(
                              fontSize: 14.wMin,
                              fontWeight: FontWeight.w400,
                              color: const Color.fromRGBO(255, 255, 255, 0.4),
                              textBaseline: TextBaseline.alphabetic),
                        ),
                        onChanged: (value) {
                          print("--页码onChanged,value:$value");
                          // 实时解析输入
                          final newIndex = value.trim().isNotEmpty ? int.tryParse(value) : null;
                          final newEntity = widget.wordImageEntity.copyWith(index: newIndex);

                          // 立即更新外部数据
                          widget.onChanged?.call(widget.index, newEntity);
                        },
                        onEditingComplete: () {
                          // 手动提交最终值
                          final value = _editingController.text;
                          print("---页码输入完成value:$value");
                          final newIndex = value.trim().isNotEmpty ? int.tryParse(value) : null;
                          widget.onChanged?.call(widget.index, widget.wordImageEntity.copyWith(index: newIndex));
                        },
                      ))
                ],
              ),
            ],
          ),
        ));
  }

  Widget _buildImageWidget() {
    if (widget.wordImageEntity.isUrl) {
      return CachedImageWidget(widget.wordImageEntity.url ?? '', // 保证图片按比例填充但不溢出
          fit: BoxFit.contain,
          width: 146.ww,
          height: 205.wh,
          borderRadius: BorderRadius.circular(4.wMin),
          placeholder: buildLoadingWidget(),
          errorWidget: buildImage(
            Assets.customCoursePlaceholder,
            width: 146.ww,
            height: 205.wh,
          ));
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(4.wMin),
      child: buildFileImage(
        widget.wordImageEntity.url ?? "",
        filterQuality: FilterQuality.medium,
        // 保证图片按比例填充但不溢出
        fit: BoxFit.contain,
        width: 146.ww,
        height: 205.wh,
        errorBuilder: ((
          BuildContext context,
          Object error,
          StackTrace? stackTrace,
        ) {
          return buildImage(
            Assets.customCoursePlaceholder,
            width: 146.ww,
            height: 205.wh,
          );
        }),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant WordImageCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 关键逻辑：仅在外源数据真实变化时更新
    if (widget.wordImageEntity != _lastReceivedEntity) {
      _lastReceivedEntity = widget.wordImageEntity;
      _editingController.text = widget.wordImageEntity.index?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    super.dispose();
    _editingController.dispose();
    focusNode.dispose();
  }
}
