

import 'package:just_waveform/just_waveform.dart';

abstract class AudioWaveformData {
  Duration get duration;
  int get flags;
  int positionToPixel(Duration position);
  int getPixelMin(int pixel);
  int getPixelMax(int pixel);
}

class JustAudioWaveformData implements AudioWaveformData {
  final Waveform waveform;

  const JustAudioWaveformData(this.waveform);

  @override
  Duration get duration => waveform.duration;

  @override
  int get flags => waveform.flags;

  @override
  int positionToPixel(Duration position) => waveform.positionToPixel(position).toInt();

  @override
  int getPixelMin(int pixel) => waveform.getPixelMin(pixel);

  @override
  int getPixelMax(int pixel) => waveform.getPixelMax(pixel);
}

