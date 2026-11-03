import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';


class ElementsCardBodyWidget extends StatefulWidget {
  final Widget? child;
  const ElementsCardBodyWidget(
      {super.key,
      this.child,
 });

  @override
  State<ElementsCardBodyWidget> createState() => _ElementsCardBodyWidgetState();
}

class _ElementsCardBodyWidgetState extends State<ElementsCardBodyWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
            margin: EdgeInsets.all(4.wMin),
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(16.wMin),
              child: widget.child,
            ),
          );
  }
}
