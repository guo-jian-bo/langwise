import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'dialog_box_widget.dart';

class ImageConvertCreateDialogResult {
  final List<int> styleIds;
  final int numberOfImages;
  final String prompt;
  final int tabIndex;

  const ImageConvertCreateDialogResult({
    required this.styleIds,
    required this.numberOfImages,
    required this.prompt,
    required this.tabIndex,
  });
}

enum ImageConvertCreateDialogMode {
  convert,
  create,
}

class ImageConvertCreateDialog {
  static Future<ImageConvertCreateDialogResult?> show({
    required BuildContext context,
    required String title,
    required ImageConvertCreateDialogMode mode,
    required ImageStyleConfigV2ResponseData data,
    List<int> initialSelectedStyleIds = const [],
    List<int> disabledStyleIds = const [],
    int initialNumberOfImages = 1,
  }) async {
    return await Get.dialog<ImageConvertCreateDialogResult>(
      _ImageConvertCreateDialogWidget(
        title: title,
        mode: mode,
        data: data,
        initialSelectedStyleIds: initialSelectedStyleIds,
        disabledStyleIds: disabledStyleIds,
        initialNumberOfImages: initialNumberOfImages,
      ),
      barrierDismissible: true,
    );
  }
}

class _ImageConvertCreateDialogWidget extends StatefulWidget {
  final String title;
  final ImageConvertCreateDialogMode mode;
  final ImageStyleConfigV2ResponseData data;
  final List<int> initialSelectedStyleIds;
  final List<int> disabledStyleIds;
  final int initialNumberOfImages;

  const _ImageConvertCreateDialogWidget({
    required this.title,
    required this.mode,
    required this.data,
    required this.initialSelectedStyleIds,
    required this.disabledStyleIds,
    required this.initialNumberOfImages,
  });

  @override
  State<_ImageConvertCreateDialogWidget> createState() => _ImageConvertCreateDialogWidgetState();
}

class _ImageConvertCreateDialogWidgetState extends State<_ImageConvertCreateDialogWidget> {
  final Set<int> _styleTabSelectedStyleIds = <int>{};
  final Set<int> _promptTabSelectedStyleIds = <int>{};
  final Set<int> _disabledStyleIds = <int>{};
  late int _numberOfImages;
  final TextEditingController _promptController = TextEditingController();
  bool _promptNotEmpty = false;
  int _tabIndex = 0;

  static const Color _cPanel = Color(0xff232737);
  static const Color _cText = Color(0xffBAC0CC);

  @override
  void initState() {
    super.initState();
    _styleTabSelectedStyleIds.addAll(widget.initialSelectedStyleIds);
    _promptTabSelectedStyleIds.addAll(widget.initialSelectedStyleIds);
    _disabledStyleIds.addAll(widget.disabledStyleIds);
    _numberOfImages = widget.initialNumberOfImages <= 0 ? 1 : widget.initialNumberOfImages;
    _promptNotEmpty = _promptController.text.trim().isNotEmpty;
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Set<int> get _currentSelectedStyleIds {
    if (widget.mode != ImageConvertCreateDialogMode.create) {
      return _styleTabSelectedStyleIds;
    }
    return _tabIndex == 1 ? _promptTabSelectedStyleIds : _styleTabSelectedStyleIds;
  }

  bool get _isPromptTab => widget.mode == ImageConvertCreateDialogMode.create && _tabIndex == 1;

  void _toggleStyle(int id, bool checked) {
    if (_disabledStyleIds.contains(id)) return;
    setState(() {
      if (checked) {
        if (_isPromptTab && _promptNotEmpty) {
          _promptTabSelectedStyleIds
            ..clear()
            ..add(id);
          return;
        }

        _currentSelectedStyleIds.add(id);
      } else {
        _currentSelectedStyleIds.remove(id);
      }
    });
  }

  void _onPromptChanged(String v) {
    final next = v.trim().isNotEmpty;
    if (_promptNotEmpty == next) return;
    setState(() {
      _promptNotEmpty = next;
      if (_promptNotEmpty && widget.mode == ImageConvertCreateDialogMode.create) {
        if (_promptTabSelectedStyleIds.length > 1) {
          final keep = _promptTabSelectedStyleIds.first;
          _promptTabSelectedStyleIds
            ..clear()
            ..add(keep);
        }
      }
    });
  }

  void _inc() {
    if (_numberOfImages > 3) return;
    setState(() {
      _numberOfImages += 1;
    });
  }

  void _dec() {
    setState(() {
      if (_numberOfImages > 1) {
        _numberOfImages -= 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final entries = widget.data.groups.entries.toList();

    return DialogBoxWidget(
      title: widget.title,
      width: 560.wMin,
      onCancel: () => Get.back(),
      isEnabled: _tabIndex==0?_currentSelectedStyleIds.isNotEmpty: (_currentSelectedStyleIds.isNotEmpty && _promptNotEmpty),
      onDefine: () {
        final selectedStyleIds = _currentSelectedStyleIds;
        if (selectedStyleIds.isEmpty) {
          ToastUtils.showToast(text: '请选择风格');
          return;
        }

        final prompt = _isPromptTab ? _promptController.text.trim() : '';
        if (_isPromptTab && prompt.isEmpty) {
          ToastUtils.showToast(text: '请输入提示词');
          return;
        }

        Get.back(
          result: ImageConvertCreateDialogResult(
            styleIds: selectedStyleIds.toList(),
            numberOfImages: _numberOfImages,
            prompt: prompt,
            tabIndex: _tabIndex,
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.wMin, 8.wMin, 24.wMin, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNumberSelector(),
              SizedBox(height: 16.wMin),
            if (widget.mode == ImageConvertCreateDialogMode.create) ...[
              SizedBox(
                height: 44.wMin,
                child: Row(
                  children: [
                    _buildTab(title: '选择风格和地区', index: 0),
                    SizedBox(width: 12.wMin),
                    _buildTab(title: '按Prompt生成', index: 1),
                  ],
                ),
              ),
              SizedBox(height: 12.wMin),
            ],
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 520.wMin),
              child: _buildTabBody(entries: entries),
            ),
            SizedBox(height: 8.wMin),
          ],
        ),
      ),
    );
  }

  Widget _buildTab({required String title, required int index}) {
    final bool selected = _tabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _tabIndex = index;
          });
        },
        child: Container(
          height: 44.wMin,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF2388FF) : const Color(0xFF353E5C),
            borderRadius: BorderRadius.circular(8.wMin),
          ),
          child: Text(title, style: TextStyle(color: Colors.white, fontSize: 16.wMin)),
        ),
      ),
    );
  }

  Widget _buildTabBody({required List<MapEntry<String, List<ImageStyleConfigV2Item>>> entries}) {
    if (widget.mode == ImageConvertCreateDialogMode.convert) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(entries.length, (index) {
            final entry = entries[index];
            return _buildGroup(entry.key, entry.value);
          }),
        ),
      );
    }

    if (_tabIndex == 1) {
      return _buildPromptPanel(entries: entries);
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('选择生成风格（可多选）', style: TextStyle(color: _cText, fontSize: 16.wMin)),
          SizedBox(height: 16.wMin),
          ...List.generate(entries.length, (index) {
            final entry = entries[index];
            return _buildGroup(entry.key, entry.value);
          }),
        ],
      ),
    );
  }

  Widget _buildPromptPanel({required List<MapEntry<String, List<ImageStyleConfigV2Item>>> entries}) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: _cPanel,
              borderRadius: BorderRadius.circular(8.wMin),
              border: Border.all(color: const Color(0xFF353E5C)),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 8.wMin),
            child: TextField(
              controller: _promptController,
              minLines: 4,
              maxLines: 8,
              style: TextStyle(color: Colors.white, fontSize: 14.wMin),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: '请输入提示词',
                hintStyle: TextStyle(color: const Color(0xFFBAC0CC).withValues(alpha: 0.6), fontSize: 14.wMin),
              ),
              onChanged: _onPromptChanged,
            ),
          ),
          SizedBox(height: 16.wMin),
          Text('选择参考风格（单选）', style: TextStyle(color: _cText, fontSize: 16.wMin)),
          SizedBox(height: 16.wMin),
          ...List.generate(entries.length, (index) {
            final entry = entries[index];
            return _buildGroup(entry.key, entry.value, selectedStyleIds: _promptTabSelectedStyleIds);
          }),
        ],
      ),
    );
  }

  Widget _buildNumberSelector() {
    return Row(
      children: [
        Text(
          '每个风格生成数量',
          style: TextStyle(color: _cText, fontSize: 16.wMin),
        ),
        const Spacer(),
        _buildStepperButton('assets/svg/manage/icon_minus_sign.svg', _dec),
        SizedBox(width: 10.wMin),
        Text(
          _numberOfImages.toString(),
          style: TextStyle(color: Colors.white, fontSize: 24.wMin, fontWeight: FontWeight.w500),
        ),
        SizedBox(width: 10.wMin),
        _buildStepperButton('assets/svg/public/icon_add.svg', _inc),
      ],
    );
  }

  Widget _buildStepperButton(String svgIcon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24.wMin,
        height: 24.wMin,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Color(0xFF353E5C), borderRadius: BorderRadius.circular(4.wMin)),
        child: SvgPicture.asset(svgIcon, width: 24.wMin, height: 24.wMin),
      ),
    );
  }

  Widget _buildGroup(String title, List<ImageStyleConfigV2Item> items, {Set<int>? selectedStyleIds}) {
    if (items.isEmpty) return const SizedBox.shrink();

    final selected = selectedStyleIds ?? _styleTabSelectedStyleIds;

    final bool hasSelection = items.any((e) => selected.contains(e.uid));

    return Padding(
      padding: EdgeInsets.only(bottom: 16.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGroupHeader(title: title, checked: hasSelection),
          SizedBox(height: 8.wMin),
          Wrap(
            spacing: 8.wMin,
            runSpacing: 8.wMin,
            children: items.map((e) {
              final id = e.uid;
              final checked = selected.contains(id);
              final disabled = _disabledStyleIds.contains(id);
              final label = e.localeTitle ?? "";

              return _buildCheckItem(
                label: label,
                image: e.iconUrls == null || e.iconUrls!.isEmpty ? "" : e.iconUrls?.first ?? '',
                checked: checked,
                disabled: disabled,
                onChanged: (v) {
                  if (disabled) return;
                  setState(() {
                    if (selectedStyleIds != null) {
                      if (v) {
                        selectedStyleIds
                          ..clear()
                          ..add(id);
                      } else {
                        selectedStyleIds.remove(id);
                      }
                      return;
                    }

                    _toggleStyle(id, v);
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem({
    required String label,
    required bool checked,
    required bool disabled,
    required String image,
    required ValueChanged<bool> onChanged,
  }) {
    final showCurrent = disabled && widget.mode == ImageConvertCreateDialogMode.convert;

    return InkWell(
      onTap: disabled ? null : () => onChanged(!checked),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.wMin),
        height: 38.wMin,
        decoration: BoxDecoration(
          color: disabled ? const Color(0x332B3146) : const Color(0x59353E5C),
          borderRadius: BorderRadius.circular(8.wMin),
          border: Border.all(width: 1.wMin, color: checked ? const Color(0xFF2388FF) : Colors.transparent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(image, height: 22.wMin, errorBuilder: (ctx, _, StackTrace? trace) {
              return buildEmptyWidget();
            }),
            Text(
              label,
              style: TextStyle(color: Color(0xFFBAC0CC), fontSize: 16.wMin),
            ),
            if (showCurrent) ...[
              SizedBox(width: 8.wMin),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
                child: Text(
                  '当前',
                  style: TextStyle(color: Color(0xFFBAC0CC), fontSize: 16.wMin, fontWeight: FontWeight.w400),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildGroupHeader({required String title, required bool checked}) {
    return Container(
      height: 38.wMin,
      padding: EdgeInsets.symmetric(horizontal: 8.wMin),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: checked ? Color(0xFF2388FF) : Color(0xCC353E5C),
        borderRadius: BorderRadius.circular(4.wMin),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.wMin,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (checked)
            Icon(
              Icons.check,
              size: 22.wMin,
              color: Colors.white,
            ),
        ],
      ),
    );
  }
}
