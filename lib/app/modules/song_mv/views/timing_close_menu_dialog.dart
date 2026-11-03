import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/widgets/widgets.dart';

class TimingCloseMenuModel{

  /// 0=多少分钟 1=几首
  final int type;
  /// type=0时为分钟 type=1时为首
  final int value;
  /// 名字
  final String name;

  TimingCloseMenuModel({this.type = 0, required this.value, required this.name});
}


class TimingCloseMenuDialog{

  static Future<int?> show({
    required BuildContext context,
    required List<TimingCloseMenuModel> list,
    int? selectedIndex,
  }) async {
    return await showCupertinoDialog<int?>(
      context: context,
      useRootNavigator: false,
      builder: (context) {
        return TimingCloseMenuDialogWidget(
          list: list,
          selectedIndex: selectedIndex,
        );
      },
    );
  }

}

class TimingCloseMenuDialogWidget extends StatefulWidget {
  final List<TimingCloseMenuModel> list;
  final int? selectedIndex;
  const TimingCloseMenuDialogWidget({super.key, required this.list, required this.selectedIndex});

  @override
  State<TimingCloseMenuDialogWidget> createState() => _TimingCloseMenuDialogWidgetState();
}

class _TimingCloseMenuDialogWidgetState extends State<TimingCloseMenuDialogWidget> {

  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedIndex;
  }

  
  @override
  Widget build(BuildContext context) {
    return CardDialogBoxWidget(
      title: "定时关闭",
      onCancel: () => Get.back(),
      onConfirm: () {
        Get.back(result: selectedIndex);
      },
      height: 640.wMin,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 32.wMin, vertical: 10.wMin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12.wMin,
          children: List.generate(widget.list.length, (index) {
            return _buildItemWidget(widget.list[index], index);
          }),
        ),
      ),
    );
  }

  Widget _buildItemWidget(TimingCloseMenuModel model, int index){
    return TapScaleWidget(
      sclae: 1.01,
      onTap: () {
        selectedIndex = index;
        if(mounted) setState(() {});
      },
      child: Container(
        height: 64.wMin,
        padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 8.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.wMin),
          color: AppTheme.cSurfaceTertiary.color,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                model.name,
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: AppTheme.cTextPrimary.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: selectedIndex == index ? 1 : 0,
              child: SvgPicture.asset(
                "assets/svg/public/icon_check.svg",
                width: 32.wMin,
              ),
            )


          ],
        ),
      ),
    );
  }

}