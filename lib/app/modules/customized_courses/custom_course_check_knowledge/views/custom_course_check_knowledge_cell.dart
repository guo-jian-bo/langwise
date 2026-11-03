import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/common/widgets/animation_play_icon_widget.dart';
import 'package:langwise/common/widgets/build_image.dart';
import 'package:langwise/common/widgets/status_tag_widgets.dart';
import '../../../../../common/widgets/widgets.dart';
import '../models/custom_course_check_knowledge_word_model.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../../../../../theme/theme.dart';

class CustomCourseCheckKnowledgeCell extends StatelessWidget {
  final CustomCourseCheckKnowledgeWordModel wordModel;
  final bool isDragging;

  const CustomCourseCheckKnowledgeCell(
      {super.key, required this.wordModel, this.isDragging = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180.wMin,
            height: 180.wMin,
            child: Stack(
              children: [
                wordModel.coverUrl != null
                    ? CachedImageWidget(
                        wordModel.coverUrl!,
                        fit: BoxFit.fill,
                        width: double.infinity,
                        height: double.infinity,
                      )
                    : buildEmptyWidget(),
                _buildDifficultyLabel(),
                _buildAudioButton(),
              ],
            ),
          ),
          Text(
            wordModel.content ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 20.wMin,
              color: AppTheme.cTextPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            wordModel.definition ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18.wMin,
              color: AppTheme.cTextPrimary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyLabel() {
    if (wordModel.difficulty == null) {
      return const SizedBox.shrink();
    }
    return Positioned(
      top: 10.wMin,
      left: 10.wMin,
      child: StatusTagDifficultyWidget(
        difficulty: wordModel.difficulty,
        language: Get.find<ConfigController>().userSetting.value.learningLang,
        fontSize: 14.wMin,
      ),
    );
  }

  Widget _buildAudioButton() {
    if (wordModel.audioUrl == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 0,
      bottom: 0,
      child: PlayLottieIconWidget(
        size: 30.wMin,
        audioUrl: wordModel.audioUrl,
        backgroundColor: Colors.blue,
      ),
    );
  }
}
