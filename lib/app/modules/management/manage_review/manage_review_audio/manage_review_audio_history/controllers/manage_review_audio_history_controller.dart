import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/widgets/date_time_picker_widget.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../utils/utils.dart';
import '../../models/manage_review_audio_model.dart';


class ManageReviewAudioHistoryController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageReviewAudioHistoryController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_REVIEW_AUDIO_HISTORY;

  @override
  String get breadcrumbTitle => '审核历史';

  /// 是否是管理员进入
  bool fromAdmin = false;
  
  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);

  /// 审核员列表
  final RxList<ContentReviewReviewerEntity> auditorList = RxList<ContentReviewReviewerEntity>();

  final RxList<ManageReviewAudioModel> reviewList = RxList<ManageReviewAudioModel>();
  final RxInt totalCount = 0.obs;
  int offset = 0;
  int limit = 20;
  final PagerController pagerController = PagerController();

  /// 筛选的用户id
  final RxInt selectedUserId = (-1).obs;

  final Player player = Player();
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<bool>? _playingSub;
  final RxBool audioPlaying = false.obs;
  final Rx<Duration> audioPosition = Duration.zero.obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    DateTime now = DateTime.now();
    startDate.value = DateTime(now.year, now.month, now.day, 0, 0, 0).subtract(const Duration(days: 6));
    endDate.value = DateTime(now.year, now.month, now.day, 23, 59, 59);

    if(Get.arguments != null){
      fromAdmin = Get.arguments['fromAdmin']??false;
    }

    getAuditorList();
    getReviewHistoryList();
    listenAudio();
  }

  /// 监听音频播放
  void listenAudio(){

    _positionSub = player.stream.position.listen((e){
      audioPosition.value = e;
    });

    _playingSub = player.stream.playing.listen((e){
      audioPlaying.value = e;
    });

  }

  /// 获取审核员列表
  Future<void> getAuditorList() async{
    if(!fromAdmin) return;
    List<ContentReviewReviewerEntity>? list = await LanguageUtil.getAudioAuditorList();
    if(list == null) return;
    auditorList.clear();
    auditorList.add(ContentReviewReviewerEntity(uid: -1, userId: -1, userName: "全部审核员"));
    auditorList.addAll(list);
  }

  /// 查询审核历史
  Future<void> getReviewHistoryList() async {
    try {
      ToastUtils.showLoading();

      Map<String, dynamic> params = {
        "offset": offset,
        "limit": limit,
      };
      Map<String, dynamic> reqData = {};

      if(startDate.value != null && endDate.value != null){
        reqData['startDate'] = DateFormatUtil.formatStr(startDate.value!, newPattern: "yyyy-MM-dd HH:mm:ss");
        reqData['endDate'] = DateFormatUtil.formatStr(endDate.value!, newPattern: "yyyy-MM-dd HH:mm:ss");
      }

      ListResponseEntity<AudioReviewEntityList>? response;

      if(fromAdmin){
        // null = 自己 -1 = 全部
        reqData['userId'] = selectedUserId.value;
        response = await LanguageConsoleRequest.getAudioReviewHistoryList(params, reqData);
      }else{
        response = await LanguageUtil.getAudioReviewHistoryList(params, reqData);
      }

      if(response == null) return;
      totalCount.value = response.count??0;

      List<AudioReviewEntityList?> list = response.datas ?? [];
      reviewList.clear();
      for(AudioReviewEntityList? item in list){
        if(item == null) continue;
        reviewList.add(ManageReviewAudioModel(
          data: item,
          selectAudioId: item.publishedAudio?.audioId,
        ));
      }

    } finally{
      ToastUtils.hideLoading();
    }
  }


  /// 分页器回调
  void pagerCallback(int page, int pageSize) {
    offset = (page - 1) * pageSize;
    limit = pageSize;
    getReviewHistoryList();
  }


  /// 筛选时间
  Future<void> filterTime(BuildContext context) async {
    DateTimePickerUtils.showStartEndCalender(
      context: context,
      minDate: DateTime(2024, 11, 18),
      maxDate: DateTime.now(),
      initialStartDate: startDate.value,
      initialEndDate: endDate.value,
      onTap: (startDate, endDate) {
        var _startDate = DateTime(startDate.year, startDate.month, startDate.day, 0, 0, 0);
        var _endDate = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        this.startDate.value = _startDate;
        this.endDate.value = _endDate;
        pagerController.jumpToPage(1);
      },
    );
  }

  /// 筛选审核员
  void filterAuditor(int? userId){
    if(userId == null) return;
    selectedUserId.value = userId;
    pagerController.jumpToPage(1);
  }

  /// 清空筛选时间
  void clearFilterTime() {
    startDate.value = null;
    endDate.value = null;
    pagerController.jumpToPage(1);
  }


  /// 播放音频
  Future<void> playAudio(ManageReviewAudioModel data, AudioReviewEntityListAudios? audio) async{
    if(audio == null) return;
    if(audio.audioUrl == null) return;

    if(data.playAudioId == audio.audioId){

      if(audioPlaying.value){
        await player.pause();
      }else{
        await player.play();
      }

    }else{
      audioPosition.value = Duration.zero;
      for(int i = 0; i < reviewList.length; i++){
        reviewList[i].playAudioId= null;
      }
      data.playAudioId = audio.audioId;
      reviewList.refresh();
      await player.open(Media(audio.audioUrl!), play: true);
    }
    
  }


  /// 查看统计
  Future<void> toStatistics() async{
    dynamic result = await ManagePageRegistry.jumpTo(Routes.MANAGE_REVIEW_AUDIO_STATISTICS);
    if(result == null) return;
    selectedUserId.value = result;
    pagerController.jumpToPage(1);
  }

  @override
  void onClose() {
    // TODO: 清理逻辑
    _positionSub?.cancel();
    _playingSub?.cancel();
    player.dispose();
    super.onClose();
  }
}
