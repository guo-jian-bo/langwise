import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../../../../common/static/static_data.dart';
import '../../../../common/widgets/widgets.dart';

class ManageFilterMultipleSelectionWidget extends StatelessWidget {
  final String? title;
  final List<StaticDataEntity> datas;
  final List<int> selecteds;
  final double? itemWidth;
  final void Function(int index)? onTapIndex;
  const ManageFilterMultipleSelectionWidget({
    super.key, 
    this.title, 
    required this.datas, 
    required this.selecteds, 
    this.onTapIndex, 
    this.itemWidth,
  });

  @override
  Widget build(BuildContext context) {
    Widget buildTitle() {
      return Visibility(
        visible: title != null,
        child: Container(
          margin: EdgeInsets.only(bottom: 10.wh),
          child: Text(
            title??"",
            style: TextStyle(
              fontSize: 18.wMin,
              color: const Color(0xffEBEEF3),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTitle(),
          Wrap(
            spacing: 8.ww,
            runSpacing: 8.wh,
            children: List.generate(datas.length, (index) {
              return TapScaleWidget(
                onTap: () => onTapIndex?.call(index),
                sclae: 1,
                child: Container(
                  width: itemWidth??116.ww,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 8.ww, vertical: 8.wh),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.wMin),
                    color: selecteds.contains(index)
                        ? const Color(0xff2388FF).withValues(alpha: 0.1)
                        : const Color(0xff41465A),
                    border: Border.all(
                      width: 1.wMin,
                      color: selecteds.contains(index)
                          ? const Color(0xff2388FF).withValues(alpha: 0.5)
                          : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    datas[index].name,
                    style: TextStyle(
                      fontSize: 18.wMin,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
