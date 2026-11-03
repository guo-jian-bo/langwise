import 'package:flutter/material.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

class ManageHoverIconButtonWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  const ManageHoverIconButtonWidget({super.key, required this.child, this.onTap, this.scale = 1.05});

  @override
  State<ManageHoverIconButtonWidget> createState() => _ManageHoverIconButtonWidgetState();
}

class _ManageHoverIconButtonWidgetState extends State<ManageHoverIconButtonWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (event) {
        setState(() {
          _isHovered = false;
        });
      },
      child: TapScaleWidget(
        sclae: widget.scale,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0xff4B5268).withValues(alpha: 0.4) : Colors.transparent,
            borderRadius: BorderRadius.circular(4.wMin),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
