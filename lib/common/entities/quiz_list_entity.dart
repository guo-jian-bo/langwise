import 'package:quiz_play/models/models.dart';

class QuizListEntity{
  List<QuizModel?>? list;

  QuizListEntity({
    this.list,
  });

  QuizListEntity.fromJson(Map<String, dynamic> json) {
    if (json['list'] != null) {
      final v = json['list'];
      final arr0 = <QuizModel>[];
      v.forEach((v) {
        arr0.add(QuizModel.fromJson(v));
      });
      list = arr0;
    }
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
    return data;
  }
}