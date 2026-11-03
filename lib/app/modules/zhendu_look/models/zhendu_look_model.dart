import '../../../../common/entities/entities.dart';
import '../../../../common/widgets/player_widgets/player_ass_widget.dart';

// 应该是 帧图片 对应 多个 ass句子
class ZhenduLookModel{
  /// ass 句子
  List<PlayerAssData<List<SentenceParsingWordsEntityList>?>> assDatas;

  /// 帧图片
  ZhenduDetilEntityExtraFrames frameData;

  ZhenduLookModel({
    required this.assDatas,
    required this.frameData,
  });
}