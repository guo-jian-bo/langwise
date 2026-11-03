
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

class ElementsProgressWidget extends StatefulWidget {
  final String svg;
  final String name;
  final String value;
  final double progress;
  const ElementsProgressWidget({super.key, required this.svg, required this.name, required this.value, this.progress = 0.3});

  @override
  State<ElementsProgressWidget> createState() => _ElementsProgressWidgetState();
}

class _ElementsProgressWidgetState extends State<ElementsProgressWidget> {

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40.wMin,
          height: 40.wMin,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.cFeedbackInfoBackground,
          ),
          child: SvgPicture.asset(widget.svg, width: 24.wMin),
        ),
        SizedBox(width: 8.wMin),
        Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    widget.name,
                    style: TextStyle(
                      fontSize: 24.wMin,
                      color: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    widget.value,
                    style: TextStyle(
                      fontSize: 20.wMin,
                      color: AppTheme.cTextTertiary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.wMin),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    alignment: Alignment.centerLeft,
                    height: 12.wMin,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999.wMin),
                      color: AppTheme.cBgBrand.withValues(alpha: 0.1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999.wMin),
                      child: Stack(
                        children: [
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 100),
                            left: -(constraints.maxWidth - (constraints.maxWidth * widget.progress / 100)),
                            child: Container(
                              height: 12.wMin,
                              width: constraints.maxWidth,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999.wMin),
                                color: AppTheme.cBgBrand,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  );
                }
              ),
            ],
          ),
        ),
      ],
    );
  }
}