import 'package:flutter/material.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

class ManageTitleCheckTextEntity{
  String text;
  bool seelcted;
  bool activation;
  GlobalKey? key;
  ManageTitleCheckTextEntity({
    required this.text,
    this.seelcted = false,
    this.activation = true,
    this.key,
  });
}

class ManageTitleCheckTextWidget extends StatelessWidget {
  final String? title;
  final bool isFocus;
  final bool error;
  final EdgeInsets? itemPadding;
  final List<ManageTitleCheckTextEntity> textList;
  final void Function(int index)? onTap;
  const ManageTitleCheckTextWidget({
    super.key, 
    this.title, 
    required this.textList,
    this.itemPadding, 
    this.onTap, 
    this.isFocus = false, 
    this.error = false, 
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Visibility(
          visible: title != null,
          child: Container(
            margin: EdgeInsets.only(bottom: 12.wMin),
            child: Text(
              title ?? "",
              style: TextStyle(
                fontSize: 14.wMin,
                color: const Color(0xffEBEEF3),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        AnimatedContainer(
          width: double.infinity,
          duration: const Duration(milliseconds: 100),
          padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 8.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.wMin),
            color: Colors.transparent,
            border: Border.all(
              width: 1.wMin,
              color: error ? const Color(0xffFF9262) : (isFocus ? const Color(0xff2388FF) : const Color(0xff4B5268)),
            ),
          ),
          child: Wrap(
            spacing: 8.wMin,
            runSpacing: 8.wMin,
            children: List.generate(textList.length, (index){
              double alpha = 1;
              Color backColor = const Color(0xff141828);
              if(textList[index].seelcted){
                backColor = const Color(0xffFF7F2B);
              }
              
              if(!textList[index].activation){
                alpha = 0.6;
              }
          
              return TapScaleWidget(
                onTap: onTap == null ? null : () {
                  if(!textList[index].activation) return;
                  onTap?.call(index);
                },
                sclae: 1.05,
                child: Container(
                  key: textList[index].key,
                  padding: itemPadding??EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 8.wMin),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.wMin),
                    color: backColor.withValues(alpha: alpha),
                  ),
                  child: Text(
                    textList[index].text,
                    style: TextStyle(
                      fontSize: 22.wMin,
                      color: const Color(0xffEBEFF5),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              );
          
            }),
          ),
        )
      ],
    );
  }
}
