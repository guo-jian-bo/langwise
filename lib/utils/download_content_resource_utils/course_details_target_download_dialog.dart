import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:open_file/open_file.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../common/entities/entities.dart';
import '../../common/enum/enum.dart';
import '../../common/https/https.dart';
import '../../common/widgets/widgets.dart';
import '../../app/routes/routes.dart';
import '../../app/routes/tag_routes.dart';
import 'course_details_target_download_pay_dialog.dart';

class CourseDetailsTargetDownloadDialog {
  static Future<void> show({
    required BuildContext context,
    required List<CourseDetailsTargetContentTypeModel> knowledgeList,
    required String moduleName,
    required String unitName,
  }) async {
    KnowledgeDownloadInfoEntity? entity = await getKnowledgePrice();
    if (entity == null) return;
    bool isLocal = await LockUtils.checkLock(entity.rights, context);
    if (isLocal) return;

    await showCupertinoDialog(
      context: context,
      builder: (context) {
        return CourseDetailsTargetDownloadDialogWidget(
          knowledgeList: knowledgeList,
          knowledgeDownloadInfoEntity: entity,
          moduleName: moduleName,
          unitName: unitName,
        );
      },
    );
  }

  /// 获取知识点的价格
  static Future<KnowledgeDownloadInfoEntity?> getKnowledgePrice() async {
    try {
      ToastUtils.showLoading();
      KnowledgeDownloadInfoEntity? entity = await OfficialCourseDetailsRequest.getKnowledgePrice(data: {});
      if (entity == null) return null;
      return entity;
    } finally {
      ToastUtils.hideLoading();
    }
  }
}

class CourseDetailsTargetDownloadDialogWidget extends StatefulWidget {
  final List<CourseDetailsTargetContentTypeModel> knowledgeList;
  final KnowledgeDownloadInfoEntity knowledgeDownloadInfoEntity;
  final String moduleName;
  final String unitName;

  const CourseDetailsTargetDownloadDialogWidget({
    super.key,
    required this.knowledgeList,
    required this.knowledgeDownloadInfoEntity,
    required this.moduleName,
    required this.unitName,
  });

  @override
  State<CourseDetailsTargetDownloadDialogWidget> createState() => _CourseDetailsTargetDownloadDialogWidgetState();
}

class _CourseDetailsTargetDownloadDialogWidgetState extends State<CourseDetailsTargetDownloadDialogWidget> {
  /// 资源类型
  List<KnowledgeDownloadInfoEntityContentServicePackages> downloadInfoList = [];

  /// 选择的资源类型
  List<KnowledgeResourceType> selectedDownloadTypes = [];

  /// 选择的知识点类型
  List<ElementsCardType> selectedTypes = [];

  /// 每个内容需要的学点数量
  int contentLearnPoint = 0;

  /// 选择的知识点数量
  int selectedKnowledgeCount = 0;

  /// 下载的进度
  DowmloadKnowledgeProgress downloadProgress = DowmloadKnowledgeProgress();

  /// 是否正在下载
  bool isDownloading = false;

  @override
  void initState() {
    super.initState();

    for (var item in widget.knowledgeList) {
      if (item.orgKnowledges.isNotEmpty) {
        selectedTypes.add(item.type);
        selectedKnowledgeCount += item.orgKnowledges.length;
      }
    }

    getKnowledgePrice();
  }

  /// 获取知识点的价格
  Future<void> getKnowledgePrice() async {
    try {
      KnowledgeDownloadInfoEntity entity = widget.knowledgeDownloadInfoEntity;
      List<KnowledgeDownloadInfoEntityContentServicePackages?>? contentServicePackage = entity.contentServicePackages;
      if (contentServicePackage == null) return;
      for (var item in contentServicePackage) {
        if (item == null) continue;
        downloadInfoList.add(item);

        if (item.recourseCode != null) {
          selectedDownloadTypes.add(KnowledgeResourceType.fromRawValue(item.recourseCode!));
        }
      }
      calculateContentLearnPoint();
      if (mounted) setState(() {});
    } finally {}
  }

  /// 选择知识点类型
  void selectTypeItem(ElementsCardType type) {
    if (selectedTypes.contains(type)) {
      selectedTypes.remove(type);
    } else {
      selectedTypes.add(type);
    }

    selectedKnowledgeCount = 0;
    for (var item in widget.knowledgeList) {
      if (selectedTypes.contains(item.type)) {
        selectedKnowledgeCount += item.orgKnowledges.length;
      }
    }
    calculateContentLearnPoint();

    if (mounted) setState(() {});
  }

  /// 选择资源类型
  void selectDownloadTypeItem(KnowledgeDownloadInfoEntityContentServicePackages package) {
    KnowledgeResourceType type = KnowledgeResourceType.fromRawValue(package.recourseCode ?? "");
    if (selectedDownloadTypes.contains(type)) {
      selectedDownloadTypes.remove(type);
    } else {
      if (package.recourseCode == null) return;
      selectedDownloadTypes.add(type);
    }

    calculateContentLearnPoint();
    if (mounted) setState(() {});
  }

  /// 计算每个内容需要的学点数量
  void calculateContentLearnPoint() {
    contentLearnPoint = 0;

    List<KnowledgeDownloadInfoEntityContentServicePackages> selectedPackages =
        downloadInfoList.where((element) => selectedDownloadTypes.contains(KnowledgeResourceType.fromRawValue(element.recourseCode ?? ""))).toList();
    for (var item in selectedPackages) {
      if (item.price == null) continue;
      contentLearnPoint += item.price!;
    }
  }

  /// 确认下载按钮
  Future<void> confirmDownload() async {
    if ((!Platform.isWindows && !Platform.isMacOS)) {
      ToastUtils.showToast(text: "请在电脑端(Windows/MacOS)打开并下载资源");
      return;
    }

    if (selectedKnowledgeCount == 0) {
      ToastUtils.showToast(text: "请选择要下载的知识点类别");
      return;
    }
    if (selectedDownloadTypes.isEmpty) {
      ToastUtils.showToast(text: "请选择要下载的资源类型");
      return;
    }

    // 1.先选择文件夹
    // 2.显示下载弹窗进度页面
    // 3.在下载进度弹窗页面展示下载百分比（总资源数量/当前下载资源数量），下载完成后展示正在压缩等
    // 4.完成后弹出询问弹出是否打开文件所在目录

    getSelectedDownloadPrice();
  }

  /// 获取选中资源的价格信息
  Future<void> getSelectedDownloadPrice() async {
    try {
      List<Map<String, dynamic>> selectedKnowledgeList = [];

      for (var item in widget.knowledgeList) {
        if (selectedTypes.contains(item.type)) {
          List<CourseDetailsTargetContentTypeKnowledgeModel> knowledges = item.knowledges;
          for (var knowledge in knowledges) {
            selectedKnowledgeList.add({
              "type": knowledge.knowledge.contentType,
              "uid": knowledge.knowledge.contentId,
              "semanticId": knowledge.knowledge.semanticId,
            });
          }
        }
      }

      List<String> selectedDownloadList = [];

      for (var item in downloadInfoList) {
        if (item.recourseCode == null) continue;
        if (selectedDownloadTypes.contains(KnowledgeResourceType.fromRawValue(item.recourseCode!))) {
          selectedDownloadList.add(item.recourseCode!);
        }
      }

      Map<String, dynamic> reqData = {
        "contentList": selectedKnowledgeList,
        "resources": selectedDownloadList,
      };

      ToastUtils.showLoading();
      KnowledgeDownloadInfoEntity? entity = await OfficialCourseDetailsRequest.getKnowledgePrice(data: reqData);
      if (entity == null) return;
      List<KnowledgeDownloadInfoEntityContentServicePackages?> contentServicePackages = entity.contentServicePackages ?? [];
      for (var item in contentServicePackages) {
        if (item == null) continue;
        for (var downloadInfo in downloadInfoList) {
          if (downloadInfo.recourseCode == item.recourseCode) {
            downloadInfo.quantity = item.quantity;
            downloadInfo.price = item.price;
            downloadInfo.durationTitle = item.durationTitle;
            break;
          }
        }
      }

      CourseDetailsTargetDownloadPayDialogAction res = await CourseDetailsTargetDownloadPayDialog.show(
        context: context,
        entity: entity,
      );
      if (res == CourseDetailsTargetDownloadPayDialogAction.cancel) return;
      if (res == CourseDetailsTargetDownloadPayDialogAction.goToRecharge) {
        dynamic result = await TagRoutes.toNamed(
          Routes.RECHARGE_NAIBI,
          arguments: {
            "pageType": 1,
          },
        );
        if (result == null) return;
        if (result != true) return;
        return getSelectedDownloadPrice();
      }
      if (res == CourseDetailsTargetDownloadPayDialogAction.confirmPay) {
        getKnowledgeDownloadInfo(reqData);
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 请求知识点下载信息
  Future<void> getKnowledgeDownloadInfo(Map<String, dynamic>? reqData) async {
    String? selectDirectory = await FilePicker.getDirectoryPath();
    if (selectDirectory == null) return;

    try {
      ToastUtils.showLoading();
      TodayKnowledgeEntity? res = await OfficialCourseDetailsRequest.getKnowledgeDownloadInfo(
        data: reqData,
      );
      if (res == null) return;
      startDownload(res, selectDirectory);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 开始下载
  Future<void> startDownload(TodayKnowledgeEntity entity, String selectDirectory) async {
    List<UnitKnowledgePointsEntityKnowledgeList?>? knowledgeList = entity.list;
    if (knowledgeList == null || knowledgeList.isEmpty) return;
    String moduleName = FileUtils.sanitizePathSegment(widget.moduleName);
    String unitName = FileUtils.sanitizePathSegment(widget.unitName);
    String downloadRootFolderName = "$moduleName${Platform.pathSeparator}$unitName";

    List<UnitKnowledgePointsEntityKnowledgeList> downloadDatas = [];
    for (var item in knowledgeList) {
      if (item == null) continue;
      downloadDatas.add(item);
    }

    isDownloading = true;
    if (mounted) setState(() {});
    String savePath = "$selectDirectory${Platform.pathSeparator}$downloadRootFolderName";
    bool res = await DownloadKnowledgeUtils.downloadKnowledgePoints(
      knowledgeList: downloadDatas,
      savePath: savePath,
      isDownloadAudio: selectedDownloadTypes.contains(KnowledgeResourceType.audio),
      isDownloadImage: selectedDownloadTypes.contains(KnowledgeResourceType.image),
      isDownloadSubtitle: selectedDownloadTypes.contains(KnowledgeResourceType.lrc),
      onProgress: (progress) {
        downloadProgress = progress;
        if (mounted) setState(() {});
      },
    );
    isDownloading = false;
    if (mounted) setState(() {});

    if (!res) {
      ToastUtils.showToast(text: "下载失败");
      return;
    }

    Get.back();

    bool ask = await AskDialog.showUserAsk(
      context: context,
      title: "下载完成",
      content: "是否打开文件所在目录？",
    );
    if (!ask) return;
    OpenFile.open(savePath);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Material(
        color: AppTheme.cOverlayBackground.color,
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.wMin),
            child: Container(
              width: 884.wMin,
              decoration: BoxDecoration(
                color: AppTheme.cSurfaceSecondary.color,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.cBlackAlpha10.color,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTitleWidget(),
                      _buildCategoryWidget(),
                      _buildDownloadContentWidget(),
                      SizedBox(height: 48.wMin),
                      _buildButtonsWidget(),
                      SizedBox(height: 24.wMin),
                    ],
                  ),
                  Positioned(
                    right: 24.wMin,
                    top: 24.wMin,
                    child: TapScaleWidget(
                      sclae: 1.05,
                      onTap: () => Get.back(),
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
                    ),
                  ),
                  Visibility(
                    visible: isDownloading,
                    child: Positioned.fill(
                      child: Container(
                        color: AppTheme.cInverseOverlay.color,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: isDownloading,
                    child: Positioned.fill(
                      child: Container(
                        padding: EdgeInsets.only(top: 100.wMin + 200.wMin),
                        child: Column(
                          children: [
                            _buildDownloadContentWidget(),
                            SizedBox(height: 24.wMin),
                            Text(
                              "内容下载中，请勿修改选项哦～",
                              style: TextStyle(
                                fontSize: 22.wMin,
                                fontWeight: FontWeight.w400,
                                color: AppTheme.cTextPrimary.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleWidget() {
    return Container(
      height: 100.wMin,
      alignment: Alignment.center,
      child: Text(
        "下载学习内容",
        style: TextStyle(
          fontSize: 32.wMin,
          fontWeight: FontWeight.w600,
          color: AppTheme.cTextPrimary.color,
        ),
      ),
    );
  }

  /// 选择类别
  Widget _buildCategoryWidget() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.wMin),
      height: 200.wMin,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "选择类别",
            style: TextStyle(
              fontSize: 28.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          SizedBox(height: 8.wMin),
          Row(
            spacing: 8.wMin,
            children: List.generate(widget.knowledgeList.length, (index) {
              return _buildCategoryItemWidget(widget.knowledgeList[index]);
            }),
          ),
          SizedBox(height: 8.wMin),
          Text.rich(TextSpan(
            style: TextStyle(
              fontSize: 22.wMin,
              color: AppTheme.cTextTertiary.color,
              fontWeight: FontWeight.w400,
            ),
            children: [
              const TextSpan(text: "已选择"),
              TextSpan(
                  text: " $selectedKnowledgeCount ",
                  style: TextStyle(
                    color: AppTheme.cTextBrand.color,
                  )),
              const TextSpan(text: "个知识点"),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildCategoryItemWidget(CourseDetailsTargetContentTypeModel item) {
    bool isSelected = selectedTypes.contains(item.type);
    return Expanded(
      child: TapScaleWidget(
        onTap: () {
          selectTypeItem(item.type);
        },
        sclae: 1.01,
        child: Container(
          height: 82.wMin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.wMin),
            color: isSelected ? AppTheme.cFeedbackInfoBackground.color : AppTheme.cSurfaceTertiary.color,
            border: Border.all(
              width: 1.6.wMin,
              color: AppTheme.cBorderBrand.color.withValues(
                alpha: isSelected ? 1 : 0,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                item.title,
                style: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppTheme.cTextBrand.color : AppTheme.cTextPrimary.color,
                ),
              ),
              Text(
                "${item.orgKnowledges.length}个",
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                  color: isSelected ? AppTheme.cTextBrand.color : AppTheme.cTextTertiary.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 下载内容
  Widget _buildDownloadContentWidget() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 24.wMin),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "下载内容",
            style: TextStyle(
              fontSize: 28.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          SizedBox(height: 8.wMin),
          Column(
            spacing: 8.wMin,
            children: List.generate(downloadInfoList.length, (index) {
              if (downloadInfoList[index].price == null) return Container();
              return _buildDownloadContentItemWidget(
                package: downloadInfoList[index],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadContentItemWidget({
    required KnowledgeDownloadInfoEntityContentServicePackages package,
  }) {
    bool isSelected = selectedDownloadTypes.contains(KnowledgeResourceType.fromRawValue(package.recourseCode ?? ""));
    int count = package.quantity ?? 0;
    int download = 0;
    if (package.recourseCode == KnowledgeResourceType.audio.value) {
      download = downloadProgress.audio;
    } else if (package.recourseCode == KnowledgeResourceType.image.value) {
      download = downloadProgress.image;
    } else if (package.recourseCode == KnowledgeResourceType.lrc.value) {
      download = downloadProgress.subtitle;
    }

    if (download > count) download = count;

    return TapScaleWidget(
      onTap: isDownloading
          ? null
          : () {
              selectDownloadTypeItem(package);
            },
      sclae: 1.001,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.wMin),
          color: AppTheme.cSurfaceTertiary.color,
        ),
        child: Row(
          children: [
            Opacity(
              opacity: isDownloading ? 0.6 : 1,
              child: SvgPicture.asset(
                isSelected ? "assets/svg/public/icon_check_b.svg" : "assets/svg/public/icon_uncheck_box.svg",
                width: 38.wMin,
              ),
            ),
            SizedBox(width: 8.wMin),
            Text(
              package.title ?? "",
              style: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
            Expanded(
              child: Visibility(
                visible: isDownloading && isSelected,
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    "正在下载 $download/$count",
                    style: TextStyle(
                      fontSize: 22.wMin,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.cTextBrand.color,
                    ),
                  ),
                ),
              ),
            ),
            Text(
              "${package.price ?? 0} 点/${package.durationTitle ?? '个'}",
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextTertiary.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonsWidget() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.wMin),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ButtonWidget(
              text: "取消",
              borderRadius: 12.wMin,
              height: 72.wMin,
              width: double.infinity,
              color: AppTheme.cSurfaceQuaternary.color,
              fontColor: AppTheme.cTextPrimary.color,
              fontSize: 28.wMin,
              fontWeight: FontWeight.w500,
              sclae: 1.01,
              onTap: () => Get.back(),
            ),
          ),
          SizedBox(width: 12.wMin),
          Expanded(
            child: Column(
              children: [
                ButtonWidget(
                  text: "下载",
                  borderRadius: 12.wMin,
                  height: 72.wMin,
                  width: double.infinity,
                  color: AppTheme.cSurfaceInfo.color,
                  fontColor: AppTheme.cInverseTextLight.color,
                  fontSize: 28.wMin,
                  fontWeight: FontWeight.w500,
                  sclae: 1.01,
                  onTap: () => confirmDownload(),
                ),
                Visibility(
                  visible: (!Platform.isWindows && !Platform.isMacOS),
                  child: Text(
                    "仅支持电脑端下载",
                    style: TextStyle(
                      fontSize: 22.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cSurfaceWarning.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 下载弹窗相关的知识点转换工具。
class CourseDetailsTargetDownloadConvertUtils {
  /// 将单元目标知识点列表转换为下载弹窗所需的分类数据。
  static List<CourseDetailsTargetContentTypeModel> buildKnowledgeTypeListFromCourseUnitTarget(List<KnowledgeCommonEntityList> list) {
    final Map<ElementsCardType, List<CourseDetailsTargetContentTypeKnowledgeModel>> groupedKnowledgeMap = <ElementsCardType, List<CourseDetailsTargetContentTypeKnowledgeModel>>{};
    for (final KnowledgeCommonEntityList item in list) {
      final ElementsCardType type = ElementsCardType.fromRawValue(item.contentType ?? "");
      if (type == ElementsCardType.none) continue;
      groupedKnowledgeMap.putIfAbsent(type, () => <CourseDetailsTargetContentTypeKnowledgeModel>[]);
      groupedKnowledgeMap[type]!.add(CourseDetailsTargetContentTypeKnowledgeModel(
        knowledge: _convertKnowledgeForDownload(item),
        key: GlobalKey(),
      ));
    }

    final List<CourseDetailsTargetContentTypeModel> result = <CourseDetailsTargetContentTypeModel>[];
    _addKnowledgeTypeIfNeeded(result, groupedKnowledgeMap, ElementsCardType.word, columnCount: 3);
    _addKnowledgeTypeIfNeeded(result, groupedKnowledgeMap, ElementsCardType.phrase, columnCount: 3);
    _addKnowledgeTypeIfNeeded(result, groupedKnowledgeMap, ElementsCardType.sentence, columnCount: 2);
    _addKnowledgeTypeIfNeeded(result, groupedKnowledgeMap, ElementsCardType.song, columnCount: 2);
    _addKnowledgeTypeIfNeeded(result, groupedKnowledgeMap, ElementsCardType.text, columnCount: 2);
    _addKnowledgeTypeIfNeeded(result, groupedKnowledgeMap, ElementsCardType.reveal, columnCount: 2);
    _addKnowledgeTypeIfNeeded(result, groupedKnowledgeMap, ElementsCardType.composition, columnCount: 2);
    _addKnowledgeTypeIfNeeded(result, groupedKnowledgeMap, ElementsCardType.script, columnCount: 2);
    return result;
  }

  /// 按类型向下载弹窗列表中追加分类。
  static void _addKnowledgeTypeIfNeeded(
    List<CourseDetailsTargetContentTypeModel> result,
    Map<ElementsCardType, List<CourseDetailsTargetContentTypeKnowledgeModel>> groupedKnowledgeMap,
    ElementsCardType type, {
    required int columnCount,
  }) {
    final List<CourseDetailsTargetContentTypeKnowledgeModel> knowledges = groupedKnowledgeMap[type] ?? <CourseDetailsTargetContentTypeKnowledgeModel>[];
    if (knowledges.isEmpty) return;
    result.add(CourseDetailsTargetContentTypeModel(
      title: type.name,
      knowledges: knowledges,
      orgKnowledges: knowledges.map((e) => e.knowledge).toList(),
      columnCount: columnCount,
      type: type,
    ));
  }

  /// 将单元目标知识点转换为下载弹窗兼容的实体。
  static UnitKnowledgePointsEntityKnowledgeList _convertKnowledgeForDownload(KnowledgeCommonEntityList item) {
    return UnitKnowledgePointsEntityKnowledgeList(
      uid: item.content?.uid,
      contentType: item.contentType,
      contentTypeTitle: item.contentTypeTitle?.gloss?.firstOrNull?.text,
      contentId: item.contentId,
      styleId: item.content?.styleId,
      dialect: item.content?.dialect,
      title: item.title,
      semanticId: item.content?.semanticId,
      posTitle: item.posTitle,
      imageUrl: item.coverImage?.url,
      access: item.rights?.access,
      favorited: item.favorited,
    );
  }
}
