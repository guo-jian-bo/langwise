import 'dart:async';

import 'package:get/get.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/https/https.dart';
import '../../../../utils/utils.dart';

class LessonQuizAiQueueEntity {
  int unConfirm;
  int pending;

  /// ai题目列表
  List<AiQuizModel> aiQuizList;

  LessonQuizAiQueueEntity({
    this.unConfirm = 0,
    this.pending = 0,
    this.aiQuizList = const [],
  });
}

class ManageAiQueueController extends GetxController {
  StreamSubscription? _subscription;

  /// lessonId的AI队列信息的映射
  final RxMap<int, LessonQuizAiQueueEntity> queueMap = <int, LessonQuizAiQueueEntity>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _subscription = WebsocketUtils.instance.websocketStreamController.stream.listen((data) {
      if (data.module != WebSocketMessageModule.question) return;
      if (data.jump?.code == null) return;
      Map<String, dynamic>? params = data.jump?.params;
      if (params == null || params.isEmpty) return;
      int? lessonId = params['lessonId'];
      if (lessonId == null) return;
      getQueueList(lessonId);
    });
  }

  /// 获取AI生成题目队列列表
  Future<void> getQueueList(int? lessonId) async {
    if (lessonId == null) return;

    List<AiQuizModel>? quizList = await AiQueueRequest.getAiQuizList({
      "lessonId": lessonId,
    });
    if (quizList == null) return;

    int unConfirmCount = 0;
    int pendingCount = 0;
    for (AiQuizModel model in quizList) {
      if (model.status == 1) {
        pendingCount++;
      } else if (model.status == 2) {
        unConfirmCount++;
      }
    }

    queueMap[lessonId] = LessonQuizAiQueueEntity(
      unConfirm: unConfirmCount,
      pending: pendingCount,
      aiQuizList: quizList,
    );
    queueMap.refresh();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
