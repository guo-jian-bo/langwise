
import 'dart:async';
import 'dart:io';

import 'package:audio_player_ex/audio_player_ex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/app/modules/management/common/manage_auth_box_widget.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/https/https.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../utils/oss_upload_file_utils/oss_update_response_entity.dart';
import '../../../../utils/oss_upload_file_utils/oss_upload_file_utils.dart';
import '../../../../utils/utils.dart';
import '../../../routes/routes.dart';
import '../utils/utils.dart';

class ManageEnKnowledgeAudioListWidget extends StatefulWidget {
  final List<EnKnowledgeEntityAudioList?>? audioList;
  final String? contentType;
  final int? contentId;
  final Function()? onRefreshServiceData;
  /// 是否显示上传按钮
  final bool isShowUploadBtn;
  const ManageEnKnowledgeAudioListWidget({
    super.key,
    required this.audioList,
    required this.contentType,
    required this.contentId,
    this.onRefreshServiceData,
    this.isShowUploadBtn = false,
  });

  @override
  State<ManageEnKnowledgeAudioListWidget> createState() => _ManageEnKnowledgeAudioListWidgetState();
}

class _ManageEnKnowledgeAudioListWidgetState extends State<ManageEnKnowledgeAudioListWidget> {

  bool isPlaying = false;

  StreamSubscription<bool>? _playingSub;

  @override
  void initState() {
    super.initState();

    _playingSub = VideoPlayerAudioUtils.instance.playingStream.stream.listen((play) {
      isPlaying = play;
      if(mounted) setState(() {});
    });
  }

    @override
  void dispose() {
    super.dispose();
    VideoPlayerAudioUtils.instance.pause();
    _playingSub?.cancel();
  }

  /// 音频定稿
  Future<void> audioLocked(BuildContext context, EnKnowledgeEntityAudioList? data) async{
    if(data == null) return;
    bool askRes = await AskDialog.showUserAsk(
      context: context,
      title: "温馨提示",
      content: "确定要将此音频定稿吗？",
    );
    if(!askRes) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "relationUid": data.audioRelationId,
      };
      bool res = await LanguageConsoleRequest.finalDraftAudio(parameters: parameters);
      if(!res) return;
      ToastUtils.showToast(text: "定稿成功", type: ToastType.success);
      widget.onRefreshServiceData?.call();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 音频取消定稿
  Future<void> audioUnLocked(BuildContext context, EnKnowledgeEntityAudioList? data) async{
    if(data == null) return;
    bool askRes = await AskDialog.showUserAsk(
      context: context,
      title: "温馨提示",
      content: "确定要将此音频取消定稿吗？",
    );
    if(!askRes) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "relationUid": data.audioRelationId,
      };
      bool res = await LanguageConsoleRequest.unlockDraftAudio(parameters: parameters);
      if(!res) return;
      ToastUtils.showToast(text: "取消定稿成功", type: ToastType.success);
      widget.onRefreshServiceData?.call();
    } finally{
      ToastUtils.hideLoading();
    }
  }


  /// 创建 短语/句子/文字 音频
  Future<void> audioReviewTaskVoiceSegmentCreate(EnKnowledgeEntityAudioList? data) async{
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "contentId": widget.contentId,
        "type": widget.contentType,
        "dialect": data?.dialect,
      };
      String? res = await LanguageConsoleRequest.audioReviewTaskVoiceSegmentCreate(data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: res, type: ToastType.success);
      widget.onRefreshServiceData?.call();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 创建 歌曲/甄听 音频
  Future<void> audioReviewTaskMusicMinimaxCreate(EnKnowledgeEntityAudioList? data) async{
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "contentId": widget.contentId,
        "type": widget.contentType,
      };
      String? res = await LanguageConsoleRequest.audioReviewTaskMusicMinimaxCreate(data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: res, type: ToastType.success);
      widget.onRefreshServiceData?.call();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 新建字幕
  Future<void> assReviewCreateAlign(EnKnowledgeEntityAudioList? data) async{

    if(data?.audioId == null) return ToastUtils.showToast(text: "请先审核音频");

    try {
      ToastUtils.showLoading();

      Map<String, dynamic> reqData = {
        "audioUid": data?.audioId,
      };
      String? res = await LanguageConsoleRequest.assReviewCreateAudioAlign(data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: res, type: ToastType.success);
      widget.onRefreshServiceData?.call();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 新建翻译
  Future<void> assReviewCreateTranslate(EnKnowledgeEntityAudioList? data) async{
    if(data?.assId == null)  return ToastUtils.showToast(text: "请先审核字幕");

    try {
      ToastUtils.showLoading();

      Map<String, dynamic> reqData = {
        "assId": data?.assId,
      };
      String? res = await LanguageConsoleRequest.assReviewCreateTranslate(data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: res, type: ToastType.success);
      widget.onRefreshServiceData?.call();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 去 音频 审核列表
  Future<void> toAudioReview(EnKnowledgeEntityAudioList? data) async{
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_REVIEW_AUDIO,
      arguments: {
        "taskIds": data?.audioTaskIds,
      },
    );
    widget.onRefreshServiceData?.call();
  }

  /// 去 字幕 审核列表
  Future<void> toAssReview(EnKnowledgeEntityAudioList? data) async{
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_REVIEW_ASS,
      arguments: {
        "taskIds": data?.assTaskIds,
      },
    );
    widget.onRefreshServiceData?.call();
  }

  /// 去 审核字幕详情
  Future<void> toAssDetils(EnKnowledgeEntityAudioList? data) async{
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_REVIEW_ASS_DETILS,
      arguments: {
        "assId": data?.assId,
        "hideAddSentence": false,
      },
    );
    widget.onRefreshServiceData?.call();
  }

  /// 去 审核翻译详情
  Future<void> toTranslasteDetils(EnKnowledgeEntityAudioList? data) async{
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_REVIEW_ASS_TRANSLATE,
      arguments: {
        "assId": data?.assId,
      },
    );
    widget.onRefreshServiceData?.call();
  }


  /// 上传音频
  Future<void> uploadAudio(EnKnowledgeEntityAudioList? data) async{
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
    );
    if (result == null) return;
    File file = File(result.files.single.path!);

    try {
      ToastUtils.showLoading();
      OssUpdateResponseEntity? record = await OssUploadFileUtils.uploadManageFile(
        filePath: file.path,
        fileModule: OssFileManageModule.narration,
        fileType: OssFileManageType.track,
      );
      if (record == null) return;
      AudioPlayerEx audioPlayer = AudioPlayerEx();
      await audioPlayer.setSource(DeviceFileSource(file.path));
      Duration? duration = await audioPlayer.getDuration();
      String seconds = DateFormatUtil.millisecondsToSecondsWithDecimal(duration?.inMilliseconds??0);

      int size = await file.length();

      Map<String, dynamic> reqData = {
        "subContent": {
          "uid": widget.contentId,
          "type": widget.contentType,
        },
        "fileKey": record.key,
        "dialect": data?.dialect,
        "size": size,
        "duration": seconds,
      };
      bool res = await LanguageConsoleRequest.uploadKnowledgeAudio(data: reqData);
      if(!res) return;

      ToastUtils.showToast(text: '音频上传成功');
      widget.onRefreshServiceData?.call();


    } finally{
      ToastUtils.hideLoading();
    }

    ToastUtils.showManageToast(text: '音频上传成功');
    widget.onRefreshServiceData?.call();
  }




  @override
  Widget build(BuildContext context) {
    if((widget.audioList??[]).isEmpty) return Container();
    return SizedBox(
      width: 600.wMin,
      child: Column(
        spacing: 10.wMin,
        children: List.generate(widget.audioList!.length, (index){

          return _buildListItemWidget(widget.audioList![index]);

        }),
      ),
    );
  }


  Widget _buildListItemWidget(EnKnowledgeEntityAudioList? data){

    if(data == null) return Container();

    String? audioUrl = data.audioUrl;
    bool isCurrent = audioUrl == VideoPlayerAudioUtils.instance.currentUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.wMin),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.wMin),
          border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
        ),
        child: Column(
          children: [
      
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 4.wMin),
              color: AppTheme.cSurfaceTertiary.color,
              child: Row(
                children: [
      
                  TapScaleWidget(
                    onTap: () async{
                      if(audioUrl == null) return;

                      VideoPlayerAudioUtils.instance.playOrPause(audioUrl, autoPlay: true);

                    },
                    sclae: 1.1,
                    child: Container(
                      color: Colors.transparent,
                      child: Icon(
                        isPlaying && isCurrent ? Icons.pause : Icons.play_arrow_rounded,
                        size: 20.wMin,
                        color: AppTheme.cTextPrimary.color,
                      ),
                    ),
                  ),
      
                  SizedBox(width: 6.wMin),
      
                  SelectableText(
                    data.dialect??"",
                    style: TextStyle(
                      fontSize: 16.wMin,
                      color: AppTheme.cTextPrimary.color,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
      
                  SizedBox(width: 6.wMin),
      
                  SelectableText(
                    "aid: ${data.audioId??''}",
                    style: TextStyle(
                      fontSize: 14.wMin,
                      color: AppTheme.cTextPrimary.color.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
      
                  const Spacer(),

                  Visibility(
                    visible: widget.isShowUploadBtn,
                    child: ManageAuthBoxWidget(
                      authCodes: const [ManageAuthCode.adminKnowledgeAudioUploadAudio],
                      child: ButtonWidget(
                        text: "上传音频",
                        color: AppTheme.cInverseOverlay2.color,
                        fontSize: 16.wMin,
                        borderRadius: 6.wMin,
                        height: 36.wMin,
                        padding: EdgeInsets.symmetric(horizontal: 10.wMin),
                        fontColor: AppTheme.cTextPrimary.color,
                        onTap: () {
                          uploadAudio(data);
                        },
                      ),
                    ),
                  ),

                  ManageAuthBoxWidget(
                    authCodes: [data.locked == true ? ManageAuthCode.adminAudioReviewAudioUnlock : ManageAuthCode.adminAudioReviewAudioLock],
                    margin: EdgeInsets.only(left: 10.wMin),
                    child: TapScaleWidget(
                      onTap: () {
                        if(data.locked == true){
                          audioUnLocked(context, data);
                        }else{
                          audioLocked(context, data);
                        }
                      },
                      sclae: 1.03,
                      child: Container(
                        width: 36.wMin,
                        height: 36.wMin,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.wMin),
                          color: AppTheme.cInverseOverlay2.color,
                          border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
                        ),
                        child: SvgPicture.asset(
                          data.locked == true ? "assets/svg/manage/icon_resource_lock.svg" : "assets/svg/manage/icon_resource_unlock.svg",
                          width: 18.wMin,
                        ),
                      ),
                    ),
                  ),
      
                ],
              ),
            ),

            Container(
              height: 40.wMin,
              padding: EdgeInsets.symmetric(horizontal: 10.wMin),
              child: Row(
                children: [

                  _buildAssButtonItemWidget(
                    status: data.audioState??-1,
                    name: "音频",
                    data: data,
                    type: 0,
                  ),

                  Container(width: 1.wMin, color: AppTheme.cBorderPrimary.color),

                  _buildAssButtonItemWidget(
                    status: data.assState??-1,
                    name: "字幕",
                    data: data,
                    type: 1,
                  ),

                  Container(width: 1.wMin, color: AppTheme.cBorderPrimary.color),

                  _buildAssButtonItemWidget(
                    status: data.translateState??-1,
                    name: "翻译",
                    data: data,
                    type: 2,
                  ),

                ],
              ),
            ),


      
          ],
        ),
      ),
    );

  }




  Widget _buildAssButtonItemWidget({
    required int status,
    required String name,
    required int type,
    required EnKnowledgeEntityAudioList? data,
  }){

    if(status == -1){
      return Expanded(child: Container());
    }

    String svg = "assets/svg/manage/icon_to_be_generated.svg"; //待生成
    String statusText = "待生成";
    Widget textButton = _buildStatus0ButtonWidget(type, data);
    if(status == 1){
      svg = "assets/svg/manage/icon_pending_review.svg"; //待审核
      statusText = "待审核";
      textButton = _buildStatus1ButtonWidget(type, data);
    }else if(status == 2){
      svg = "assets/svg/manage/icon_reviewed.svg"; //已审核
      statusText = "已审核";
      textButton = _buildStatus2ButtonWidget(type, data);
    }

    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.wMin),
        child: Row(
          children: [
            SvgPicture.asset(
              svg,
              width: 16.wMin,
            ),
            SizedBox(width: 4.wMin),
            Text(
              "$name$statusText",
              style: TextStyle(
                fontSize: 16.wMin,
                color: AppTheme.cTextPrimary.color.withValues(alpha: 0.8),
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(width: 4.wMin),
            textButton,
          ],
        ),
      ),
    );
  }

  /// 待生成的按钮
  Widget _buildStatus0ButtonWidget(int type, EnKnowledgeEntityAudioList? data){
    ElementsCardType contentType = ElementsCardType.fromRawValue(widget.contentType??"");
    bool isAuth = false;
    if(type == 0){
      if(contentType == ElementsCardType.phrase || contentType == ElementsCardType.sentence || contentType == ElementsCardType.text){
        isAuth = ManageAuthUtils.isAuth(ManageAuthCode.adminAudioReviewTaskVoiceSegmentCreate);
      }else if(contentType == ElementsCardType.reveal || contentType == ElementsCardType.song){
        isAuth = ManageAuthUtils.isAuth(ManageAuthCode.adminAudioReviewTaskMusicMinimaxCreate);
      }
    }else if(type == 1){
      isAuth = ManageAuthUtils.isAuth(ManageAuthCode.adminAssReviewTaskAlignAudioCreate);
    }else if(type == 2){
      isAuth = ManageAuthUtils.isAuth(ManageAuthCode.adminAssReviewTaskTranslateCreate);
    }
    

    if(!isAuth) return Container();

    return TapScaleWidget(
      onTap: (){

        if(type == 0){
          if(contentType == ElementsCardType.phrase || contentType == ElementsCardType.sentence || contentType == ElementsCardType.text){
            print("创建 短语/句子/文字 音频");
            audioReviewTaskVoiceSegmentCreate(data);
          }else if(contentType == ElementsCardType.reveal || contentType == ElementsCardType.song){
            print("创建 歌曲/甄听 音频");
            audioReviewTaskMusicMinimaxCreate(data);
          }
        }else if(type == 1){
          assReviewCreateAlign(data);
        }else if(type == 2){
          assReviewCreateTranslate(data);
        }

        
      },
      sclae: 1.1,
      child: Container(
        width: 28.wMin,
        height: 28.wMin,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2.wMin),
          color: AppTheme.cInverseOverlay2.color,
        ),
        child: SvgPicture.asset(
          "assets/svg/manage/icon_add_blue.svg",
          width: 20.wMin,
        ),
      ),
    );

  }

  /// 待审核的按钮
  Widget _buildStatus1ButtonWidget(int type, EnKnowledgeEntityAudioList? data){
    bool isAuth = false;
    if(type == 0){//音频
      isAuth = UserStore.to.rolePermissions.value.userIsAudioReviewer || UserStore.to.rolePermissions.value.userIsAudioSuperReviewer;
    }else if(type == 1 || type == 2){
      isAuth = UserStore.to.rolePermissions.value.userIsAssReviewer || UserStore.to.rolePermissions.value.userIsAssSuperReviewer;
    }

    if(!isAuth) return Container();

    return TapScaleWidget(
      onTap: (){
        if(type == 0){//音频
          print("去 音频 审核列表");
          toAudioReview(data);
        }else if(type == 1 || type == 2){
          print("去 字幕 审核列表");
          toAssReview(data);
        }
      },
      sclae: 1.1,
      child: Container(
        width: 28.wMin,
        height: 28.wMin,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2.wMin),
          color: AppTheme.cInverseOverlay2.color,
        ),
        child: SvgPicture.asset(
          "assets/svg/manage/icon_review.svg",
          width: 20.wMin,
        ),
      ),
    );

  }

  /// 已审核的按钮
  Widget _buildStatus2ButtonWidget(int type, EnKnowledgeEntityAudioList? data){
    ElementsCardType contentType = ElementsCardType.fromRawValue(widget.contentType??"");

    List<int?> taskIds = [];
    // 待审核的ids
    if(type == 0){ // 音频
      taskIds = data?.audioTaskIds??[];
    }else { // 字幕
      taskIds = data?.assTaskIds??[];
    }

    bool isRevoewAuth = false;
    if(type == 0){//音频
      isRevoewAuth = UserStore.to.rolePermissions.value.userIsAudioReviewer || UserStore.to.rolePermissions.value.userIsAudioSuperReviewer;
    }else if(type == 1 || type == 2){
      isRevoewAuth = UserStore.to.rolePermissions.value.userIsAssReviewer || UserStore.to.rolePermissions.value.userIsAssSuperReviewer;
    }

    return Row(
      children: [

        Visibility(
          visible: (type == 0 || type == 1) && taskIds.isNotEmpty && isRevoewAuth,
          child: Container(
            margin: EdgeInsets.only(right: 6.wMin),
            child: TapScaleWidget(
              onTap: (){
                if(type == 0){
                  toAudioReview(data);
                }else{
                  toAssReview(data);
                }
                
              },
              sclae: 1.1,
              child: Container(
                width: 28.wMin,
                height: 28.wMin,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2.wMin),
                  color: AppTheme.cInverseOverlay2.color,
                ),
                child: SvgPicture.asset(
                  "assets/svg/manage/icon_review.svg",
                  width: 20.wMin,
                ),
              ),
            ),
          ),
        ),

        Visibility(
          visible: type == 0,
          child: ManageAuthBoxWidget(
            authCodes: [getCreateAuth()],
            child: TapScaleWidget(
              onTap: () {
                // 创建
                if(contentType == ElementsCardType.phrase || contentType == ElementsCardType.sentence || contentType == ElementsCardType.text){
                  print("创建 短语/句子/文字 音频");
                  audioReviewTaskVoiceSegmentCreate(data);
                }else if(contentType == ElementsCardType.reveal || contentType == ElementsCardType.song){
                  print("创建 歌曲/甄听 音频");
                  audioReviewTaskMusicMinimaxCreate(data);
                }
              },
              sclae: 1.1,
              child: Container(
                width: 28.wMin,
                height: 28.wMin,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2.wMin),
                  color: AppTheme.cInverseOverlay2.color,
                ),
                child: SvgPicture.asset(
                  "assets/svg/manage/icon_add_blue.svg",
                  width: 20.wMin,
                ),
              ),
            ),
          ),
        ),

        Visibility(
          visible: type != 0,
          child: ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.adminAssReviewAssDetail],
            child: TapScaleWidget(
              onTap: (){
                if(type == 1){
                  print("去 审核字幕详情");
                  toAssDetils(data);
                }else if(type == 2){
                  print("去 审核翻译详情");
                  toTranslasteDetils(data);
                }
              },
              sclae: 1.1,
              child: Container(
                width: 28.wMin,
                height: 28.wMin,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2.wMin),
                  color: AppTheme.cInverseOverlay2.color,
                ),
                child: SvgPicture.asset(
                  "assets/svg/manage/icon_edit.svg",
                  width: 20.wMin,
                ),
              ),
            ),
          ),
        ),
      ],
    );
    
  }

  String getCreateAuth(){
    ElementsCardType contentType = ElementsCardType.fromRawValue(widget.contentType??"");
    if(contentType == ElementsCardType.phrase || contentType == ElementsCardType.sentence || contentType == ElementsCardType.text){
      return ManageAuthCode.adminAudioReviewTaskVoiceSegmentCreate;
    }else if(contentType == ElementsCardType.reveal || contentType == ElementsCardType.song){
      return ManageAuthCode.adminAudioReviewTaskMusicMinimaxCreate;
    }
    return "";
  }
  


}
