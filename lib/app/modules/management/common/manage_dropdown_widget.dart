import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/widgets/widgets.dart';

class ManageDropdownWidget extends StatefulWidget {
  final String? title;
  final String? name;
  final int selectedIndex;
  final List<String> values;
  final MainAxisAlignment valueMainAxisAlignment;
  final void Function(int index)? onChange;
  final String? hintText;
  final bool error;
  final bool disable;
  const ManageDropdownWidget({
    super.key, 
    this.title, 
    this.name, 
    this.selectedIndex = 0, 
    this.valueMainAxisAlignment = MainAxisAlignment.end,
    required this.values, 
    this.onChange, 
    this.error = false, 
    this.disable = false, 
    this.hintText, 
  });

  @override
  State<ManageDropdownWidget> createState() => _ManageDropdownWidgetState();
}

class _ManageDropdownWidgetState extends State<ManageDropdownWidget> {
  bool isFocus = false;

  @override
  Widget build(BuildContext context) {
    Color valueColor = Colors.white;
    if(widget.disable){
      valueColor = const Color(0xff697179);
    }else if(widget.selectedIndex == -1){
      valueColor = const Color(0xffA4ABB8);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Visibility(
          visible: widget.title != null,
          child: Container(
            margin: EdgeInsets.only(bottom: 12.wh),
            child: Text(
              widget.title ?? "",
              style: TextStyle(
                fontSize: 14.wMin,
                color: const Color(0xffEBEEF3),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        IgnorePointer(
          ignoring: widget.disable,
          child: IconDropdownCheckWidget(
            onTap: (data, index) {
              widget.onChange?.call(index);
            },
            onShowMenu: () {
              isFocus = true;
              if(mounted) setState(() {});
            },
            onHideMenu: () {
              isFocus = false;
              if(mounted) setState(() {});
            },
            backColor: const Color(0xff353E5C),
            hoverColor: const Color(0xff49557A),
            highlightColor: const Color(0xff49557A),
            borderolor: const Color(0xff767E95),
            dividerColor: Colors.transparent,
            sclae: 1.01,
            itemHeight: 50.wMin,
            fontColor: const Color(0xffEBEEF3),
            fontSize: 16.wMin,
            selectIndex: widget.selectedIndex,
            items: List.generate(widget.values.length, (index){
              return IconDropdownCheckData(
                title: widget.values[index],
              );
            }),
            child: AnimatedContainer(
              height: 50.wh,
              duration: const Duration(milliseconds: 100),
              padding: EdgeInsets.symmetric(horizontal: 12.ww),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.wMin),
                color: Colors.transparent,
                border: Border.all(
                  width: 1.wMin,
                  color: widget.error ? const Color(0xffFF9262) : (isFocus ? const Color(0xff2388FF) : const Color(0xff4B5268)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Visibility(
                    visible: widget.name != null,
                    child: Container(
                      margin: EdgeInsets.only(right: 12.wh),
                      child: Text(
                        widget.name ?? "",
                        style: TextStyle(
                          fontSize: 14.wMin,
                          color: const Color(0xffBAC0CC),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: widget.valueMainAxisAlignment,
                      children: [
                        Text(
                          widget.selectedIndex == -1 ? (widget.hintText??"") : widget.values[widget.selectedIndex],
                          style: TextStyle(
                            fontSize: 16.wMin,
                            color: valueColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(width: 20.wMin),
                        Icon(
                          Icons.keyboard_arrow_down, 
                          color: Colors.white.withValues(alpha: 0.4),
                          size: 20.wMin,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

      ],
    );
  }
}
