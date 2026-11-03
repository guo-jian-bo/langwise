import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/user_center_option_entity.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/common/values/storage.dart';
import 'package:langwise/common/widgets/icon_dropdown_widget.dart';
import 'package:langwise/theme/theme.dart';
import 'package:lib_common/utils/storage_util.dart';
import 'package:ui_essentials/ui_essentials.dart';

class RhythmFilterPopButton extends StatefulWidget {
  final bool isIosAwait;

  // 当前节奏值（比如 pauseInterval / playInterval）
  final Rx<double> value;

  // 选中新的节奏时的回调
  final void Function(double value) onChanged;

  const RhythmFilterPopButton({
    super.key,
    this.isIosAwait = true,
    required this.value,
    required this.onChanged,
  });

  @override
  State<RhythmFilterPopButton> createState() => _RhythmFilterPopButtonState();
}

class _RhythmFilterPopButtonState extends State<RhythmFilterPopButton> {
  final ConfigController controller = Get.find<ConfigController>();
  List<IconDropdownCheckData<double>> rhythmSettingMenu = [
    IconDropdownCheckData<double>(value: 15, title: "极慢"),
    IconDropdownCheckData<double>(value: 12.5, title: "较慢"),
    IconDropdownCheckData<double>(value: 10, title: "适中"),
    IconDropdownCheckData<double>(value: 7.5, title: "较快"),
    IconDropdownCheckData<double>(value: 5, title: "极快"),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final current = widget.value.value;
      List<UserPreferenceIntervalSpeedOption>? menu = controller.userSetting.value.intervalMenu;
      if (menu == null) return Container();
      rhythmSettingMenu.clear();
      rhythmSettingMenu = menu.map((e) => IconDropdownCheckData<double>(value: e.value, title: e.title ?? "")).toList();
      final selectIndex = rhythmSettingMenu.indexWhere((e) => e.value == current);

      return IconDropdownCheckWidget(
        items: rhythmSettingMenu,
        width: 268.wMin,
        selectIndex: selectIndex < 0 ? 0 : selectIndex,
        sclae: 1.01,
        fontSize: 28.wMin,
        itemHeight: 70.wMin,
        alignRight: true,
        isIosAwait: widget.isIosAwait,
        child: _buildDrapBoyWidget(
          rhythmSettingMenu[(selectIndex < 0 ? 0 : selectIndex)].title,
        ),
        onTap: (data, index) {
          StorageUtil().setDouble(INTERVAL_SPEED_KEY, data.value);
          widget.onChanged(data.value);
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
            "切换节奏:$title",
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
