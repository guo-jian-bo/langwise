import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../theme/theme.dart';
import '../../utils/utils.dart';

class RecommendDifficultyButtonWidget extends StatelessWidget {
  final int currentDifficulty;
  final int recommendedDifficulty;
  final List<String> difficultyList;
  final VoidCallback onTap;

  const RecommendDifficultyButtonWidget({
    super.key,
    required this.currentDifficulty,
    required this.recommendedDifficulty,
    required this.difficultyList,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (difficultyList.isEmpty) {
      return const SizedBox.shrink();
    }
    final int difficultyIndex =
        currentDifficulty.clamp(0, difficultyList.length - 1);
    final String difficultyLabel = difficultyList[difficultyIndex];
    final bool isRecommended = difficultyIndex == recommendedDifficulty;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52.wMin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          color: const Color(0x14FFFFFF),
          border: Border.all(color: const Color(0xFF5B6167)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 8.wMin),
            Text(
              '${isRecommended ? '推荐' : ''}难度',
              style: TextStyle(
                fontSize: 24.wMin,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
            SizedBox(width: 4.wMin),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 8.wMin,
                vertical: 4.wMin,
              ),
              decoration: BoxDecoration(
                color: StatusUtils.getCefrBackgroundColor(difficultyLabel).color2,
                borderRadius: BorderRadius.circular(4.wMin),
              ),
              child: Text(
                difficultyLabel,
                style: TextStyle(
                  fontSize: 16.wMin,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 4.wMin),
            SvgPicture.asset(
              'assets/svg/public/icon_w_arrow_right.svg',
              width: 24.wMin,
              height: 24.wMin,
            ),
            SizedBox(width: 8.wMin),
          ],
        ),
      ),
    );
  }
}
