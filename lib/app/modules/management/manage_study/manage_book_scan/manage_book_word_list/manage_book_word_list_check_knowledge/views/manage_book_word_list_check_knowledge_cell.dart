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

  bool _isTextOverflow({
    required String text,
    required TextStyle style,
    required double maxWidth,
    required int maxLines,
    required TextDirection textDirection,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines,
      textDirection: textDirection,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth);
    return painter.didExceedMaxLines;
  }

  @override
  Widget build(BuildContext context) {
    final String content = wordModel.content ?? '';
    final TextStyle contentStyle = TextStyle(
      fontSize: 20.wMin,
      color: const Color(0xFFFDFDFD),
      fontWeight: FontWeight.w500,
    );
    return Container(
      color: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
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
          SizedBox(height: 8.wMin),
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isOverflow = _isTextOverflow(
                text: content,
                style: contentStyle,
                maxWidth: constraints.maxWidth-10.wMin,
                maxLines: 1,
                textDirection: Directionality.of(context),
              );

              final Widget text = Text(
                content,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: contentStyle,
              );

              if (content.isEmpty || !isOverflow) {
                return text;
              }

              return Tooltip(
                message: content,
                waitDuration: const Duration(milliseconds: 250),
                showDuration: const Duration(seconds: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF111213).withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(8.wMin),
                  border: Border.all(
                    color: const Color(0xFF2C2D2F),
                    width: 1.wMin,
                  ),
                ),
                textStyle: TextStyle(
                  fontSize: 18.wMin,
                  color: const Color(0xFFFDFDFD),
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
                child: Builder(
                  builder: (ctx) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () async {
                        final RenderBox button =
                            ctx.findRenderObject() as RenderBox;
                        final RenderBox overlay = Overlay.of(ctx)
                            .context
                            .findRenderObject() as RenderBox;
                        final Offset offset = button.localToGlobal(
                          Offset.zero,
                          ancestor: overlay,
                        );
                        await showMenu<void>(
                          context: ctx,
                          menuPadding: EdgeInsets.zero,
                          clipBehavior: Clip.antiAlias,
                          color: const Color(0xFF111213),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.wMin),
                            side: BorderSide(
                              color: const Color(0xFF2C2D2F),
                              width: 1.wMin,
                            ),
                          ),
                          constraints: BoxConstraints(
                            maxWidth: 420.wMin,
                            maxHeight: 240.wMin,
                          ),
                          position: RelativeRect.fromLTRB(
                            offset.dx,
                            offset.dy + button.size.height + 6.wMin,
                            offset.dx + button.size.width,
                            offset.dy + button.size.height,
                          ),
                          items: [
                            PopupMenuItem<void>(
                              enabled: false,
                              padding: EdgeInsets.zero,
                              child: Padding(
                                padding: EdgeInsets.all(14.wMin),
                                child: Text(
                                  content,
                                  style: TextStyle(
                                    fontSize: 18.wMin,
                                    color: const Color(0xFFFDFDFD),
                                    fontWeight: FontWeight.w500,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                      child: text,
                    );
                  },
                ),
              );
            },
          ),
          SizedBox(height: 4.wMin),
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
        isShowText: false,
      ),
    );
  }
}
