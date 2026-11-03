
import 'package:flutter/material.dart';

import '../../../../../common/widgets/widgets.dart';

class PhonicsCourseImageWidget extends StatefulWidget {
  final String imagePath;
  final Widget child;
  const PhonicsCourseImageWidget({super.key, required this.imagePath, required this.child});

  @override
  State<PhonicsCourseImageWidget> createState() => _PhonicsCourseImageWidgetState();
}

class _PhonicsCourseImageWidgetState extends State<PhonicsCourseImageWidget> {

  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (event) {
        setState(() {
          _isHovered = false;
        });
      },
      child: Stack(
        children: [
          AnimatedScale(
            scale: _isHovered ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: CachedImageWidget(
              widget.imagePath,
              placeholder: buildEmptyWidget(),
              errorWidget: buildEmptyWidget(),
              fadeInDuration: Duration.zero,
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}