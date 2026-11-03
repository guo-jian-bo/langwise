
import 'package:flutter/material.dart';

import '../../../../../common/widgets/widgets.dart';

class PhonicsCourseImageWidget extends StatelessWidget {
  final String imagePath;
  final Widget child;
  const PhonicsCourseImageWidget({
    super.key,
    required this.imagePath,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CachedImageWidget(
          imagePath,
          placeholder: buildEmptyWidget(),
          errorWidget: buildEmptyWidget(),
          fadeInDuration: Duration.zero,
        ),
        child,
      ],
    );
  }
}
