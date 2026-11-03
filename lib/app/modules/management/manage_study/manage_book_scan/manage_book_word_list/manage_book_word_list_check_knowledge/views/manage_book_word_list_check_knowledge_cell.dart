import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/knowledge.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'package:langwise/common/widgets/widgets.dart';

class ManageBookWordListCheckKnowledgeCell extends StatelessWidget {
  final Knowledge wordModel;
  final bool isDragging;

  const ManageBookWordListCheckKnowledgeCell(
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
                wordModel.imageUrl != null
                    ? CachedImageWidget(
                        wordModel.imageUrl!,
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
              color: const Color(0xFFFDFDFD),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            wordModel.definition ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18.wMin,
              color: const Color(0xFFFDFDFD),
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
