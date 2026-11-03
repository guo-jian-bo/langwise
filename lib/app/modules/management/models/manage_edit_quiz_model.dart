import 'package:langwise/common/entities/manage_quiz_template_entity.dart';
import 'package:quiz_play/models/quiz_model.dart';

class ManageEditQuizModel {
  QuizModel? exercise; // 题目数据
  ManageQuizTemplateEntityTemplate? template; // 模板数据

  ManageEditQuizModel({this.exercise, this.template});

  factory ManageEditQuizModel.fromJson(Map<String, dynamic> json) {
    return ManageEditQuizModel(
      exercise: json['exercise'] != null ? QuizModel.fromJson(json['exercise']) : null,
      template: json['template'] != null ? ManageQuizTemplateEntityTemplate.fromJson(json['template']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exercise': exercise?.toJson(),
      'template': template?.toJson(),
    };
  }
}
