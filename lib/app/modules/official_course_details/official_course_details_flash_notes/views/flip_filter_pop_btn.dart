import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/icon_dropdown_widget.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'official_course_details_flash_setting_dialog.dart';

class FlipFilterPopButton extends StatefulWidget {
  final bool isIosAwait;

  /// 当前展示模式值
  final Rx<FlashSettingCardShowType> value;

  /// 选中新的展示模式时的回调
  final void Function(FlashSettingCardShowType value) onChanged;

  const FlipFilterPopButton({
    super.key,
    this.isIosAwait = true,
    required this.value,
    required this.onChanged,
  });

  @override
  State<FlipFilterPopButton> createState() => _FlipFilterPopButtonState();
}

class _FlipFilterPopButtonState extends State<FlipFilterPopButton> {
  late final List<IconDropdownCheckData<FlashSettingCardShowType>> _items;

  @override
  void initState() {
    super.initState();
    _items = FlashSettingCardShowType.values
        .map(
          (e) => IconDropdownCheckData<FlashSettingCardShowType>(
            value: e,
            title: e.value,
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final current = widget.value.value;
      final int selectIndex = _items.indexWhere((e) => e.value == current);
      return IconDropdownCheckWidget(
        items: _items,
        width: 268.wMin,
        selectIndex: selectIndex < 0 ? 0 : selectIndex,
        sclae: 1.01,
        fontSize: 28.wMin,
        itemHeight: 70.wMin,
        alignRight: true,
        isIosAwait: widget.isIosAwait,
        child: _buildDrapBoyWidget(
          _items[(selectIndex < 0 ? 0 : selectIndex)].title,
        ),
        onTap: (data, index) {
          widget.onChanged(data.value as FlashSettingCardShowType);
        },
      );
    });
  }

  Widget _buildDrapBoyWidget(String title) {
    return Container(
      padding: EdgeInsets.all(10.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: AppTheme.cSurfaceSecondary.color,
      ),
      child: Row(
        spacing: 8.wMin,
        children: [
          Text(
            "正面显示:$title",
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w600,
              color: AppTheme.cTextPrimary,
            ),
          ),
          SvgPicture.asset(
            "assets/svg/public/icon_arrow_down.svg",
            width: 36.wMin,
            colorFilter: const ColorFilter.mode(AppTheme.cTextPrimary, BlendMode.srcIn),
          ),
        ],
      ),
    );
  }
}
