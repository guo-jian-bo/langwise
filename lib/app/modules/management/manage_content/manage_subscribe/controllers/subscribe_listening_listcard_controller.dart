import 'package:api/entities/config.dart';
import 'package:api/entities/response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/status/http_status.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/static/static_data.dart';
import 'package:langwise/common/https/subscribe.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:wise_http/wise_http.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../common/enum/enum.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../controllers/manage_setting_controller.dart';
import '../../../dialog/dialogs.dart';
import '../../../utils/manage_breadcrumb_utils.dart';
import '../../../utils/manage_page_registry.dart';
import '../../../../../routes/routes.dart';
import '../../../common/dialogs/song_lyrics_dialog.dart';
import '../views/sublist_filter_dialog.dart';
import '../views/subscribe_listening_publish_dialog.dart';
import '../views/subscribe_listening_push_type_dialog.dart';

class RevealGroup {
  RevealGroup({required this.groupId, required this.items});

  final String groupId;
  final List<ArticleEntity> items;
}

class SubscribeListeningListcardController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  SubscribeListeningListcardController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_SUBSCRIBE_LISTCARD;

  @override
  String get breadcrumbTitle => '文章列表';

  // 排序
  List<StaticDataEntity> sortList = [
    StaticDataEntity(name: "UID", value: "contentId"),
    StaticDataEntity(name: "创建时间", value: "created"),
  ];

  SortDialogResult staticDataEntity = SortDialogResult(selectBasisIndex: 1, selectSortIndex: 1);
  List<String> difficultyList = ['Pre A1', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  int isLaunchCondition = -1;
  int difficultyCondition = -1;
  int isContentCheckedCondition = -1;
  int isAudioCheckedCondition = -1;
  int isImageCheckedCondition = -1;
  int imageLocked = -1;
  int videChecked = -1;
  SubScribeFilterResult? filterResult;
  RxInt checkedContentNum = 0.obs;
  RxInt checkedAudioNum = 0.obs;
  RxInt pageSize = 10.obs;
  RxInt currentPage = 1.obs;
  RxInt totalCount = 0.obs;
  int? collectionId;
  String? themeZh;
  String? themeEn;
  List<ManageSubscribeReference?>? links;
  String? description;
  RxSet<int> expandedIndexSet = <int>{}.obs;
  String? mGroupId;
  String? title;
  List<String> uids = [];
  Rx<ManageSubscribeRevealDetailEntity> revealData = ManageSubscribeRevealDetailEntity().obs;
  TextEditingController collectionIdController = TextEditingController();
  TextEditingController pageJumpController = TextEditingController();

  /// 一键展开/折叠
  final RxBool isAllExpand = false.obs;

  @override
  void onInit() {
    super.onInit();
    
    final args = Get.arguments as Map<String, dynamic>?;
    collectionId = args != null ? args['collectionId'] as int? : null;
    collectionIdController.text = collectionId?.toString() ?? '';
    themeZh = args?['themeZh'] as String?;
    themeEn = args?['themeEn'] as String?;
    if(themeZh != null){
      initBreadcrumb(tag, title: "$breadcrumbTitle($themeZh)");
    }else{
      initBreadcrumb(tag);
    }

    links = args?['links'] as List<ManageSubscribeReference?>?;
    description = args?['description'] as String?;
    String? uid = args?['uid']?.toString();
    if(uid != null){
      uids = [uid];
    }

    List<int?>? uidsList = args?['uids']?.cast<int?>();
    if(uidsList != null){
      uids = uidsList.map((e) => e?.toString() ?? '').toList();
    }
    
    initData();
  }

  initData() async {
    var data = await fetchRevealGrouped();
    if (data == null) {
      revealData.value = ManageSubscribeRevealDetailEntity();
      return;
    }
    revealData.value = data;
    totalCount.value = data.enGroupRevealContents?.count ?? 0;
    checkedContentNum.value = data.finishContentNum ?? 0;
    checkedAudioNum.value = data.finishAudioNum ?? 0;
    String? name = data.revealThemeName?.firstWhereOrNull((e) => e.lang == "zh")?.text;
    if(name != null){
      initBreadcrumb(tag, title: "$breadcrumbTitle($name)");
    }
  }

  /// 一键展开/折叠
  void onAllExpand(){
    isAllExpand.value = !isAllExpand.value;

    List<ManageSubscribeGroupRevealItem> datas = revealData.value.enGroupRevealContents?.datas??[];

    if(isAllExpand.value){
      for(int i = 0; i < datas.length; i++){
        expandedIndexSet.add(i);
      }
    }else{
      expandedIndexSet.clear();
    }
    
  }

  void _resetPageAndFetch() {
    currentPage.value = 1;
    pageJumpController.text = '1';
    initData();
  }

  /// 排序弹窗
  Future<void> sortCourse(BuildContext context) async {
    SortDialog.show(
      context: context,
      basisList: sortList,
      init: staticDataEntity,
      onSort: (data) {
        staticDataEntity = data;
        initData();
      },
    );
  }

  int get totalPages {
    if (pageSize.value <= 0) return 1;
    if (totalCount <= 0) return 1;
    int pages = ((totalCount.value - 1) ~/ pageSize.value) + 1;
    return pages;
  }

  void changePageSize(int size) {
    if (size <= 0) return;
    pageSize.value = size;
    currentPage.value = 1;
    pageJumpController.text = '1';
    initData();
  }

  void goToPage(int page) {
    if (page < 1) page = 1;
    if (totalPages > 0 && page > totalPages) page = totalPages;
    pageJumpController.text = page.toString();
    if (page == currentPage.value) return;
    currentPage.value = page;
    initData();
  }

  void goPrevPage() {
    if (currentPage.value <= 1) return;
    goToPage(currentPage.value - 1);
  }

  void goNextPage() {
    if (currentPage.value >= totalPages) return;
    goToPage(currentPage.value + 1);
  }

  /// 生成要展示的一串页码（带前后收缩）
  List<int> buildVisiblePages() {
    final int total = totalPages;
    if (total <= 7) {
      return List<int>.generate(total, (i) => i + 1);
    }

    final int current = currentPage.value;
    final List<int> pages = [1];

    int start = current - 1;
    int end = current + 1;

    if (start <= 2) {
      start = 2;
      end = 4;
    } else if (end >= total - 1) {
      end = total - 1;
      start = total - 3;
    }

    for (int i = start; i <= end; i++) {
      pages.add(i);
    }

    if (!pages.contains(total)) {
      pages.add(total);
    }

    return pages.toSet().toList()..sort();
  }

  /// 筛选
  void showFilter(BuildContext context) {
    filterResult ??= SubScribeFilterResult(
      difficultys: [],
      isLaunch: isLaunchCondition,
      isContentChecked: isContentCheckedCondition,
      isAudioChecked: isAudioCheckedCondition,
      isImageChecked: isImageCheckedCondition,
      imageLocked: imageLocked,
      videChecked: videChecked,
    );

    SublistFilterDialog.show(
      context: context,
      initFilterResult: filterResult,
      onSure: (result) {
        filterResult = result;
        initData();
      },
    );
  }

  void showContentChecked() {
    isContentCheckedCondition = 0;
    isAudioCheckedCondition = -1;
    if (filterResult != null) {
      filterResult!.isContentChecked = 0;
      filterResult!.isAudioChecked = -1;
    }
    _resetPageAndFetch();
  }

  void showAudioChecked() {
    isAudioCheckedCondition = 0;
    isContentCheckedCondition = -1;
    if (filterResult != null) {
      filterResult!.isAudioChecked = 0;
      filterResult!.isContentChecked = -1;
    }
    _resetPageAndFetch();
  }

  //分组名称
  void onSetGroup(String groupId, {bool isSubmit = false}) {
    mGroupId = groupId;

    if (isSubmit) {
      _resetPageAndFetch();
    }
  }

  // 名字
  void onSetName(String name, {bool isSubmit = false}) {
    title = name;

    if (isSubmit) {
      _resetPageAndFetch();
    }
  }

  // collectionId
  void onSetCollectionId(String mCollectionId, {bool isSubmit = false}) {
    if (mCollectionId.trim().isEmpty) {
      collectionId = null;
      collectionIdController.text = '';
    } else {
      collectionId = int.tryParse(mCollectionId.trim());
    }

    if (isSubmit) {
      _resetPageAndFetch();
    }
  }

  // uid
  void onSetId(String uid, {bool isSubmit = false}) {
    if (uid.trim().isEmpty) {
      uids = [];
    } else {
      if (uid.trim().contains(',')) {
        final List<String> s = uid.trim().split(',');
        uids = s;
      } else if (uid.trim().contains(' ')) {
        final List<String> s = uid.trim().split(' ');
        uids = s;
      } else {
        uids = [uid];
      }
    }

    if (isSubmit) {
      _resetPageAndFetch();
    }
  }

  // 跳转音频字幕编辑器页面
  void toAudioEditPage(List? audioList, int? currentAudioIndex, String? type) {
    ManagePageRegistry.jumpTo(
      Routes.MANAGE_AUDIO_SUBTITLE_EDITOR,
      arguments: {
        "audioList": audioList,
        "currentAudioIndex": currentAudioIndex,
        "type": type,
        "collectionId": collectionId,
      },
    ).then((value) {
      initData();
    });
  }

  /// 查看歌词
  void onViewFullLyrics(ArticleEntity entity) {
    ManageEnglishContentManagementSongModel enItem = ManageEnglishContentManagementSongModel(
        uid: entity.contentId,
        title: entity.title,
        content: entity.content,
        difficulty: ManageEnglishContentManagementSongDifficulty.fromJson(entity.difficulty),
        lyrics: entity.lyrics,
        genre: entity.genre,
        theme: entity.theme);

    ManageEnglishContentManagementSongLyricsDialog.show(context: Get.context!, item: enItem);
  }

  ///设置推送时间
  Future<void> setPublishTime(int mInitType, String group, DateTime settingDay, bool isLaunch) async {
    final int? type = await SubscribeListeningPushTypeDialog.show(
      context: Get.context!,
      initialType: mInitType,
      group: group,
      collectionId: collectionId!,
      settingDay: settingDay,
      isLaunch: isLaunch,
    );
    if (type == null || type == 0) return;
    initData();
  }

  /// 查看知识点
  void onViewKnowledge(BuildContext context, EnTextEntity entity) {
    ManagePageRegistry.jumpTo(
      Routes.MANAGE_CORE_KNOWLEDGE,
      arguments: {
        "uid": entity.uid,
        "type": entity.contentType,
      },
    ).then((value) {
      // 刷新
    });
  }

  /// 查看提示词
  Future<void> showPrompt(BuildContext context,ArticleEntity article) async {
    if(article.prompt==null){
      ToastUtils.showToast(text: "提示词为空");
      return;
    }
    PromptInputDialog.show(
      context: context, 
      prompt: article.prompt!,
      showCancel: false,
      readOnly: true,
      confirmText: "关闭",
    );
  }

  /// 图片管理
  Future<void> adminEditImageFunction(UnitKnowledgePointsEntityKnowledgeList knowledge, {int quizOrImage = 1}) async {
    int? styleId = Get.find<ManageSettingController>().selectedStyleId.value;
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_KNOWLEDGE_RELATED_DETAILS,
      arguments: {
        'type': knowledge.contentType,
        'uid': knowledge.contentId,
        'semanticId': knowledge.semanticId,
        "quizOrImage": quizOrImage,
        "styleId": quizOrImage == 0 ? null : styleId,
      },
    );

    initData();
  }

  Future<ManageSubscribeRevealDetailEntity?> fetchRevealGrouped() async {
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "offset": (currentPage.value - 1) * pageSize.value,
        "limit": pageSize.value,
      };

      if (filterResult != null) {
        isLaunchCondition = filterResult!.isLaunch ?? -1;
        isContentCheckedCondition = filterResult!.isContentChecked ?? isContentCheckedCondition;
        isAudioCheckedCondition = filterResult!.isAudioChecked ?? isAudioCheckedCondition;
        isImageCheckedCondition = filterResult!.isImageChecked ?? isImageCheckedCondition;
        imageLocked = filterResult!.imageLocked ?? imageLocked;
        videChecked = filterResult!.videChecked ?? videChecked;
        if (filterResult?.difficultys != null && filterResult!.difficultys!.isNotEmpty) {
          difficultyCondition = filterResult!.difficultys?.first ?? -1;
        }
      }
      String orderCondition = "";
      if (staticDataEntity.sort != null && staticDataEntity.basis != null) {
        orderCondition = "${staticDataEntity.sort?.value ?? ''}${staticDataEntity.basis?.value ?? ''}";
      } else {
        orderCondition = "-created";
      }

      int? styleId = await ManageSettingController.to.getDefaultStyleId();

      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: {
          "uids": uids.isEmpty ? null : uids,
          "title": title,
          'collectionId': collectionId,
          'group': mGroupId,
          'styleId': styleId,
          "locked": imageLocked == -1 ? null : (imageLocked == 1),
          "checked": videChecked == -1 ? null : (videChecked == 0),
          "mediaMode": ManageSettingController.to.defaultResources.value == ResourceTypeEnum.image ? 0 : 1,
          'isLaunch': isLaunchCondition == -1
              ? null
              : isLaunchCondition == 0
                  ? true
                  : false,
          'difficulty': difficultyCondition == -1 ? null : difficultyCondition,
          "order": orderCondition,
          'isContentReview': isContentCheckedCondition == -1
              ? null
              : isContentCheckedCondition == 0
                  ? false
                  : true,
          'isAudioReview': isAudioCheckedCondition == -1
              ? null
              : isAudioCheckedCondition == 0
                  ? false
                  : true,
        },
      );

      final dynamic response = await WiseHttp().request(
        '/language-console/en/reveals/page/group/enReveals',
        Method.post,
        parameters: config.parameters,
        data: config.data,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
      );

      if (response == null) {
        return null;
      }

      final ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        if (responseEntity.message != null) {
          ToastUtils.showToast(text: responseEntity.message ?? '');
        }
        return null;
      }

      if (responseEntity.data == null) {
        return null;
      }

      final Map<String, dynamic> data = responseEntity.data as Map<String, dynamic>;

      // 直接使用实体类解析 JSON，不在控制器里做分组逻辑
      return ManageSubscribeRevealDetailEntity.fromJson(data);
    } catch (_) {
      return null;
    } finally{
      ToastUtils.hideLoading();
    }
  }

  void add() {
    ManagePageRegistry.jumpTo(
      Routes.MANAGE_SUBSCRIBE_CREATE,
      arguments: {'id': collectionId, 'themeZh': themeZh, 'themeEn': themeEn, 'description': description, 'links': links},
    );
  }

  void createWithOriginInfo(ManageSubscribeGroupRevealItem? data, ArticleEntity entity) {
    ManagePageRegistry.jumpTo(
      Routes.MANAGE_SUBSCRIBE_CREATE,
      arguments: {
        'id': collectionId,
        'themeZh': revealData.value.contentCollection?.title,
        'themeEn': revealData.value.contentCollection?.theme,
        'description': revealData.value.contentCollection?.description,
        'links': links,
        'originText': entity.sourceContent,
        'originLink': entity.sourceUrl,
        'group': entity.group ?? ''
      },
    ).then((value) {
      initData();
    });
  }

  Future<void> editArticle(BuildContext context, ArticleEntity articleEntity) async {
    bool result = await SubscribeListeningPublishDialog.show(context: context, articleEntity: articleEntity, collectionId: collectionId ?? 0) ?? false;
    if (result) {
      initData();
    }
  }

  void showOriginArticle(BuildContext context) {
    //  SubscribeOriginArticleDialog.show(context: context, articleEntity: ArticleEntity());
  }

  void deleteArticle(int uid, String title) {
    Get.dialog(Material(
        color: AppTheme.cOverlayBackground,
        child: Center(
          child: Stack(
            children: [
              Container(
                  width: 640.wMin,
                  padding: EdgeInsets.all(32.wMin),
                  decoration: BoxDecoration(
                    color: AppTheme.cSurfaceSecondary.color,
                    border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary),
                    borderRadius: BorderRadius.circular(24.wMin),
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('删除文章', style: TextStyle(fontSize: 32.wMin, fontWeight: FontWeight.w600, color: AppTheme.cTextPrimary.color)),
                    SizedBox(height: 8.wMin),
                    Text('确定删除「$title」吗？', style: TextStyle(fontSize: 24.wMin, color: AppTheme.cTextSecondary.color)),
                    SizedBox(height: 48.wMin),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      GestureDetector(
                        onTap: () {
                          Get.back(result: '');
                        },
                        child: Container(
                            width: 282.wMin,
                            height: 72.wMin,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: AppTheme.cSurfaceQuaternary.color, borderRadius: BorderRadius.circular(12.wMin)),
                            child: Text('取消', style: TextStyle(fontSize: 28.wMin, fontWeight: FontWeight.w500, color: AppTheme.cTextPrimary.color))),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await SubscribeRequest.deleteReveal(contentId: uid, collectionId: collectionId);
                          Get.back(result: '');
                          initData();
                        },
                        child: Container(
                            width: 282.wMin,
                            height: 72.wMin,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: AppTheme.cSurfaceInfo.color, borderRadius: BorderRadius.circular(12.wMin)),
                            child: Text('确定', style: TextStyle(fontSize: 28.wMin, fontWeight: FontWeight.w500, color: AppTheme.cInverseTextLight.color))),
                      )
                    ])
                  ])),
              Positioned(
                  top: 10.wMin,
                  right: 10.wMin,
                  child: TapScaleWidget(
                    sclae: 1.05,
                    onTap: () => Get.back(result: ''),
                    child: Container(
                      width: 42.wMin,
                      height: 42.wMin,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.cSurfaceTertiary.color,
                      ),
                      child: SvgPicture.asset(
                        "assets/svg/public/x.svg",
                        width: 24.wMin,
                        height: 24.wMin,
                      ),
                    ),
                  )),
            ],
          ),
        )));
  }

  @override
  void onClose() {
    super.onClose();
  }
}
