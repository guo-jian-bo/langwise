
import 'package:flutter/material.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';


class EvaluationTitleWidget extends StatelessWidget {
  final String title;
  final String? subTitle;
  const EvaluationTitleWidget({super.key, required this.title, this.subTitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          spacing: 32.wMin,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              spacing: 10.wMin,
              children: [
                _buildTitleLineWidget(),
                _buildTitleLineWidget(),
              ],
            ),
            ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.cTextPrimary.color,
                    AppTheme.cTextPrimary.color.withValues(alpha: 0.5),
                  ],
                  stops: const [0.18, 0.84],
                ).createShader(bounds);
              },
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 56.wMin,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.cTextPrimary.color,
                  height: 1.25,
                ),
              ),
            ),
            Column(
              spacing: 10.wMin,
              children: [
                _buildTitleLineWidget(false),
                _buildTitleLineWidget(false),
              ],
            ),
          ],
        ),
        Visibility(
          visible: subTitle != null,
          child: Container(
            margin: EdgeInsets.only(top: 4.wMin),
            child: Text(
              subTitle??"",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextSecondary.color,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleLineWidget([bool isLeft = true]){
    return Container(
      height: 2.wMin,
      width: 56.wMin,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: isLeft ? Alignment.centerRight : Alignment.centerLeft,
          end: isLeft ? Alignment.centerLeft : Alignment.centerRight,
          colors: [
            AppTheme.cTextPrimary.color.withValues(alpha: 0.8),
            AppTheme.cBgBrand.color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}