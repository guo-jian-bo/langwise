import 'package:quiz_play/quiz_play.dart';

class PreviewQuizEntity {
/*
{
  "list": [],
  "async": 0
} 
*/

  List<QuizModel?>? list;
  int? async;

  PreviewQuizEntity({
    this.list,
    this.async,
  });
  PreviewQuizEntity.fromJson(Map<String, dynamic> json) {
    if (json['list'] != null) {
      final v = json['list'];
      final arr0 = <QuizModel>[];
      v.forEach((v) {
        arr0.add(QuizModel.fromJson(v));
      });
      list = arr0;
    }
    async = json['async']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (list != null) {
      final v = list;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['list'] = arr0;
    }
    data['async'] = async;
    return data;
  }
}
