class ManageEnglishContentManagementWordAudioPhonemeModel {
  String? phoneme;
  double? duration;
  int? size;
  String? url;
  bool? dialog;
  String? audio_key;

  ManageEnglishContentManagementWordAudioPhonemeModel({
    this.phoneme,
    this.duration,
    this.size,
    this.url,
    this.dialog,
    this.audio_key,
  });

  factory ManageEnglishContentManagementWordAudioPhonemeModel.fromJson(
      Map<String, dynamic> json) {
    return ManageEnglishContentManagementWordAudioPhonemeModel(
      phoneme: json['phoneme'],
      duration: json['duration'],
      size: json['size'],
      url: json['url'],
      dialog: json['dialog'],
      audio_key: json['audio_key'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['phoneme'] = phoneme;
    data['duration'] = duration;
    data['size'] = size;
    data['url'] = url;
    data['dialog'] = dialog;
    data['audio_key'] = audio_key;
    return data;
  }
}
