import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../theme/theme.dart';
import '../../../../utils/utils.dart';
import '../../widgets.dart';
import 'model/writing_board_data.dart';

class WritImageUploadWidget extends StatefulWidget {
  final WritingBoardMediaAnswerData? mediaData;
  final void Function(List<WritingBoardMediaItemData> items)? onItemsChanged;
  final WritingBoardEditPolicyMacro editPolicy;

  const WritImageUploadWidget({
    super.key,
    this.mediaData,
    this.onItemsChanged,
    this.editPolicy = WritingBoardEditPolicyMacro.stageRule,
  });

  @override
  State<WritImageUploadWidget> createState() => _WritImageUploadWidgetState();
}

class _WritImageUploadWidgetState extends State<WritImageUploadWidget> {
  List<WritingBoardMediaItemData> get _items => widget.mediaData?.items ?? const <WritingBoardMediaItemData>[];

  int get _maxCount => widget.mediaData?.maxCount ?? 0;

  bool get _isReadOnly => widget.editPolicy == WritingBoardEditPolicyMacro.readOnly;

  bool get _canAddMore => !_isReadOnly && (_maxCount <= 0 || _items.length < _maxCount);

  Future<void> _selectImage() async {
    File? imagePath = await ImagePickerUtils.pickImage(context);
    if (imagePath == null) return;
    _appendImage(imagePath);
  }

  Future<void> _takeImage() async {
    File? imagePath = await ImagePickerUtils.takePhotos(context: context);
    if (imagePath == null) return;
    _appendImage(imagePath);
  }

  void _appendImage(File file) {
    if (!_canAddMore) return;
    final nextItems = List<WritingBoardMediaItemData>.from(_items)..add(WritingBoardMediaItemData(localPath: file.path));
    if (mounted) setState(() {});
    widget.onItemsChanged?.call(nextItems);
  }

  void _removeImage(int index) {
    final nextItems = List<WritingBoardMediaItemData>.from(_items)..removeAt(index);
    if (mounted) setState(() {});
    widget.onItemsChanged?.call(nextItems);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 853.wMin,
      padding: EdgeInsets.all(24.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32.wMin),
        color: AppTheme.cSurfaceBg.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "交图片",
                style: TextStyle(
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
              Text(
                "${_items.length}/${_maxCount <= 0 ? '-' : _maxCount}",
                style: TextStyle(
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextTertiary.color,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.wMin),
          Container(
            height: 340.wMin,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.wMin),
              color: AppTheme.cSurfaceLayerElevated.color,
              border: Border.all(color: AppTheme.cBorderThin.color, width: 1.wMin),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.all(24.wMin),
              child: Row(
                spacing: 16.wMin,
                children: [
                  ...List.generate(_items.length, _buildImageCard),
                  if (_canAddMore) _buildActionPanel(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard(int index) {
    final item = _items[index];
    return SizedBox(
      width: 300.wMin,
      height: 300.wMin,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.wMin),
              child: Container(
                color: Colors.black,
                child: _buildImageContent(item, fit: BoxFit.contain),
              ),
            ),
          ),
          if (!_isReadOnly)
            Positioned(
              top: 10.wMin,
              right: 10.wMin,
              child: _buildDeleteButton(() {
                _removeImage(index);
              }),
            ),
        ],
      ),
    );
  }

  Widget _buildActionPanel() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 16.wMin,
      children: [
        _buildButtonWidget(
          text: "选择图片",
          svg: "assets/svg/public/icon_image1.svg",
          onTap: _selectImage,
        ),
        _buildButtonWidget(
          text: "拍照上传",
          svg: "assets/svg/public/icon_camera1.svg",
          fillColor: true,
          onTap: _takeImage,
        ),
      ],
    );
  }

  Widget _buildImageContent(WritingBoardMediaItemData item, {required BoxFit fit}) {
    if ((item.localPath?.isNotEmpty ?? false)) {
      return Image.file(
        File(item.localPath!),
        fit: fit,
      );
    }
    return CachedImageWidget(
      item.url ?? '',
      fit: fit,
      placeholder: buildEmptyWidget(),
      errorWidget: buildEmptyWidget(),
      borderRadius: BorderRadius.circular(24.wMin),
    );
  }

  Widget _buildDeleteButton(void Function() onTap) {
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.05,
      child: Container(
        width: 42.wMin,
        height: 42.wMin,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black54,
        ),
        child: SvgPicture.asset(
          "assets/svg/public/icon_delete.svg",
          width: 20.wMin,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
      ),
    );
  }

  Widget _buildButtonWidget({
    required String text,
    required String svg,
    bool fillColor = false,
    void Function()? onTap,
  }) {
    return ButtonWidget(
      text: text,
      width: 421.wMin,
      height: 64.wMin,
      color: AppTheme.cSurfaceWarning.color.withValues(alpha: fillColor ? 0.8 : 0.12),
      borderRadius: 8.wMin,
      fontColor: fillColor ? Colors.white : AppTheme.cTextPrimary.color,
      fontSize: 20.wMin,
      fontWeight: FontWeight.w500,
      sclae: 1.03,
      leftIcon: Container(
        margin: EdgeInsets.only(right: 8.wMin),
        child: SvgPicture.asset(
          svg,
          width: 22.wMin,
          colorFilter: ColorFilter.mode(
            fillColor ? Colors.white : AppTheme.cSurfaceWarning.color,
            BlendMode.srcIn,
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}
