import '../../../../../../common/entities/entities.dart';

class ManageReviewAudioModel{
  AudioReviewEntityList data;

  /// 选择的音频id
  int? selectAudioId;

  /// 播放音频的id
  int? playAudioId;

  /// 已有音频
  AudioReviewEntityListAudios? publishedAudio;

  /// 已有音频是否正在播放
  bool publishedAudioPlay;

  ManageReviewAudioModel({
    required this.data,
    this.selectAudioId,
    this.playAudioId,
    this.publishedAudio,
    this.publishedAudioPlay = false,
  });

}