import 'package:langwise/common/widgets/data_table_widget/data_sources.dart';
import 'package:quiz_play/models/quiz_model.dart';
import '../../../../../common/entities/entities.dart';

class ManageExerciseQuizModel extends Dessert {
  String? testType;
  String? type;
  String? purpose;
  String? reason;
  List<QuizModelContentList?>? contentList;
  List<QuizModelStems?>? stems;
  List<QuizModelOptions?>? options;
  List<QuizModelQuestions?>? questions;
  List<QuizModelGloss?>? guide;
  QuizModelConfig? config;
  int? estimatedTime;
  String? status;
  String? access;
  bool? correct;
  String? updated;
  String? created;
  ManageEnglishContentManagementSongDifficulty? difficulty;

  /// correct=正确 fail=失败 skipping=跳过
  String? result;
  QuizModelContext? context;
  int? missionIndex;
  int? score;
  int? inLessonCount;

  /// 此题目用的时长 秒
  double? duration;

  /// 是否可以编辑题目
  bool? editable;

  /// 优秀
  bool get isExcellent => result == 'excellent';

  /// 良好
  bool get isGood => result == 'good';

  /// 较差
  bool get isPoor => result == 'poor';

  /// 已经学习
  bool get isLearned => status == 'LEARNED';

  /// 正在学习
  bool get isLearning => status == 'LEARNING';

  /// 未学习
  bool get isUnlearned => status == 'UNLEARNED';

  /// 是否上架
  bool get accessNormal => access == "NORMAL";

  /// 是否下架
  bool get accessInternal => access == "INTERNAL";

  /// 是否删除
  bool get accessDelete => access == "DELETE";

  /// 上下架状态
  String get accessStr {
    if (access == "NORMAL") {
      return "上架";
    } else if (access == "INTERNAL") {
      return "下架";
    } else if (access == "DELETE") {
      return "删除";
    } else {
      return "";
    }
  }

  ManageExerciseQuizModel({
    required int uid,
    this.type,
    this.purpose,
    this.reason,
    this.contentList,
    this.stems,
    this.options,
    this.questions,
    this.guide,
    this.config,
    this.status,
    this.access,
    this.correct,
    this.result,
    this.estimatedTime,
    this.context,
    this.missionIndex,
    this.score,
    this.duration,
    this.editable,
    this.updated,
    this.created,
    this.difficulty,
    this.inLessonCount,
  }) : super(uid: uid);

  ManageExerciseQuizModel.fromJson(Map<String, dynamic> json) : super(uid: json['uid']?.toInt() ?? 0) {
    testType = json['testType']?.toString();
    type = json['type']?.toString();
    purpose = json['purpose']?.toString();
    reason = json['reason']?.toString();
    status = json['status']?.toString();
    access = json['access']?.toString();
    correct = json['correct'];
    result = json['result']?.toString();
    if (json['contentList'] != null) {
      final v = json['contentList'];
      final arr0 = <QuizModelContentList>[];
      v.forEach((v) {
        arr0.add(QuizModelContentList.fromJson(v));
      });
      contentList = arr0;
    }

    if (json['stems'] != null) {
      final v = json['stems'];
      final arr0 = <QuizModelStems>[];
      v.forEach((v) {
        arr0.add(QuizModelStems.fromJson(v));
      });
      stems = arr0;
    }
    if (json['options'] != null) {
      final v = json['options'];
      final arr0 = <QuizModelOptions>[];
      v.forEach((v) {
        arr0.add(QuizModelOptions.fromJson(v));
      });
      options = arr0;
    }
    if (json['questions'] != null) {
      final v = json['questions'];
      final arr0 = <QuizModelQuestions>[];
      v.forEach((v) {
        arr0.add(QuizModelQuestions.fromJson(v));
      });
      questions = arr0;
    }
    if (json['guide'] != null) {
      final v = json['guide'];
      final arr0 = <QuizModelGloss>[];
      v.forEach((v) {
        arr0.add(QuizModelGloss.fromJson(v));
      });
      guide = arr0;
    }

    config = (json['config'] != null) ? QuizModelConfig.fromJson(json['config']) : null;
    estimatedTime = json['estimatedTime']?.toInt();
    context = (json['context'] != null) ? QuizModelContext.fromJson(json['context']) : null;
    missionIndex = json['missionIndex']?.toInt();
    score = json['score']?.toInt();
    duration = json['duration']?.toDouble();
    editable = json['editable'];
    updated = json['updated']?.toString();
    created = json['created']?.toString();
    difficulty = (json['difficulty'] != null) ? ManageEnglishContentManagementSongDifficulty.fromJson(json['difficulty']) : null;
    inLessonCount = json['inLessonCount']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = uid;
    data['testType'] = testType;
    data['type'] = type;
    data['purpose'] = purpose;
    data['reason'] = reason;

    if (contentList != null) {
      final v = contentList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['contentList'] = arr0;
    }

    if (stems != null) {
      final v = stems;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['stems'] = arr0;
    }
    if (options != null) {
      final v = options;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['options'] = arr0;
    }
    if (questions != null) {
      final v = questions;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['questions'] = arr0;
    }
    if (guide != null) {
      final v = guide;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['guide'] = arr0;
    }

    if (config != null) {
      data['config'] = config!.toJson();
    }
    data['status'] = status;
    data['access'] = access;
    data['correct'] = correct;
    data['result'] = result;
    data['estimatedTime'] = estimatedTime;
    if (context != null) {
      data['context'] = context!.toJson();
    }
    data['missionIndex'] = missionIndex;
    data['score'] = score;
    data['duration'] = duration;
    data['editable'] = editable;
    data['updated'] = updated;
    data['created'] = created;
    if (difficulty != null) {
      data['difficulty'] = difficulty!.toJson();
    }
    data['inLessonCount'] = inLessonCount;
    return data;
  }
}
