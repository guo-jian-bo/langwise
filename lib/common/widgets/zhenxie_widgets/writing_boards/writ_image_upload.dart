import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
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
  final WritingBoardModeEnum mode;
  final String? title;
  final String? subTitle;

  const WritImageUploadWidget({
    super.key,
    this.mediaData,
    this.onItemsChanged,
    this.mode = WritingBoardModeEnum.task,
    this.title,
    this.subTitle,
  });

  @override
  State<WritImageUploadWidget> createState() => _WritImageUploadWidgetState();
}

class _WritImageUploadWidgetState extends State<WritImageUploadWidget> {
  List<WritingBoardMediaItemData> get _items => widget.mediaData?.items ?? const <WritingBoardMediaItemData>[];

  int get _maxCount => widget.mediaData?.maxCount ?? 0;

  bool get _isReadOnly => widget.mode.isReadOnlyMode;

  bool get _canAddMore => !_isReadOnly && (_maxCount <= 0 || _items.length < _maxCount);

  Future<void> _selectImage() async {
    final File? imagePath = await ImagePickerUtils.pickProcessedImage(context: context, showCrop: false);
    if (imagePath == null) return;
    _appendImage(imagePath);
  }

  Future<void> _takeImage() async {
    final File? imagePath = await ImagePickerUtils.takeProcessedPhoto(context: context, showCrop: false);
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 24.wMin),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    widget.title ?? "交图片",
                    style: TextStyle(
                      fontSize: 24.wMin,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.cZhenxieFontTertiary.color,
                    ),
                  ),
                  SizedBox(width: 16.wMin),
                  Text(
                    widget.subTitle ?? "",
                    style: TextStyle(
                      fontSize: 16.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cZhenxieFontSecondary.color,
                    ),
                  ),
                ],
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
        ),
        Container(
          width: double.infinity,
          alignment: Alignment.center,
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
    );
  }

  Widget _buildImageCard(int index) {
    final item = _items[index];
    return SizedBox(
      width: 340.wMin,
      height: 340.wMin,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.wMin),
              child: TapScaleWidget(
                onTap: () {
                  String currentUrl = item.url ?? item.localPath ?? '';
                  List<String> imageUrls = [];
                  for (var i = 0; i < _items.length; i++) {
                    if(_items[i].url != null){
                      imageUrls.add(_items[i].url ?? '');
                    }else if(_items[i].localPath != null){
                      imageUrls.add(_items[i].localPath!);
                    }  
                  }
                  if(imageUrls.isEmpty) return;
                  int index = imageUrls.indexOf(currentUrl);
                  if (index == -1) {
                    index = 0;
                  }
                  ShowBigResourceDialog.showImage(
                    context: context, 
                    index: index,
                    imageUrls: imageUrls,
                  );
                },
                sclae: 1,
                child: Container(
                  color: AppTheme.cZhenxieBackgroundPrimary.color,
                  child: _buildImageContent(item, fit: BoxFit.contain),
                ),
              ),
            ),
          ),
          if (!_isReadOnly)
            Positioned(
              top: 10.wMin,
              left: 10.wMin,
              child: _buildDeleteButton(() {
                _removeImage(index);
              }),
            ),
        ],
      ),
    );
  }

  Widget _buildActionPanel() {
    return DottedBorder(
      radius: Radius.circular(24.wMin),
      borderType: BorderType.RRect,
      padding: EdgeInsets.zero,
      color: AppTheme.cZhenxieBorderPrimary.color,
      dashPattern: [5.wMin, 5.wMin],
      strokeWidth: 1.5.wMin,
      child: Container(
        height: 340.wMin,
        width: 340.wMin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.wMin),
          color: AppTheme.cZhenxieBackgroundPrimary.color,
        ),
        child: Column(
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
              onTap: _takeImage,
            ),
          ],
        ),
      ),
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
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.4),
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
    void Function()? onTap,
  }) {
    return ButtonWidget(
      text: text,
      width: 243.wMin,
      height: 64.wMin,
      color: AppTheme.cZhenxieBorderPrimary.color,
      borderRadius: 99,
      fontColor: AppTheme.cZhenxieFontPrimary.color,
      fontSize: 20.wMin,
      fontWeight: FontWeight.w500,
      sclae: 1.03,
      border: Border.all(
        color: AppTheme.cZhenxieBorderPrimary.color,
        width: 1.wMin,
      ),
      leftIcon: Container(
        margin: EdgeInsets.only(right: 8.wMin),
        child: SvgPicture.asset(
          svg,
          width: 22.wMin,
          colorFilter: ColorFilter.mode(
            AppTheme.cZhenxieFontPrimary.color,
            BlendMode.srcIn,
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}
