import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:get/get.dart';

import 'package:api/entities/entities.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/values/values.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:langwise/app/modules/management/dialog/manage_create_book/manage_create_book_dialog.dart';
import 'package:langwise/app/modules/management/dialog/manage_edit_book/manage_edit_book_dialog.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/mixins/mixins.dart';
import 'package:langwise/common/static/static_data.dart';
import 'package:langwise/common/stores/stores.dart';
import 'package:langwise/utils/utils.dart';
import 'package:wise_camera/photo_capture.dart';

import '../../utils/manage_breadcrumb_utils.dart';
import '../../utils/manage_page_registry.dart';
import 'state.dart';
import 'views/chapter_management.dart';
import 'views/macos_camera_widget.dart';
import 'views/preview_page.dart';
import 'views/word_image_upload_widget.dart';

class ManageBookScanController extends BaseController with FilterMixin, ManageBreadcrumbMixin {
  final String tag;
  ManageBookScanController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_BOOK_SCAN;

  @override
  String get breadcrumbTitle => '教材词汇扫描';

  final ManageScanState state = ManageScanState();

  String? _publisher, _isbn;

  // 操作的具体书籍对象ID/章节ID
  int? _targetBookId, _targetChapterId;

  int? get targetBookId => _targetBookId;

  int? get targetChapterId => _targetChapterId;

  // 排序
  List<StaticDataEntity> sortList = [
    StaticDataEntity(name: "UID", value: "uid"),
    StaticDataEntity(name: "年级", value: "grade"),
    StaticDataEntity(name: "创建时间", value: "created"),
  ];

  SortDialogResult staticDataEntity = SortDialogResult(selectBasisIndex: 0, selectSortIndex: 1);

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
  }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  void _initData() {
    update(["manage_word_scan"]);
  }

  // 书内页列表
  void onFetchBookPages(int bookId, int chapterId) async {
    try {
      final response = await BookUtil.pages(bookId: bookId, chapterId: chapterId, config: RequestConfig(requireToken: true, cancelToken: cancelToken));
      final List<WordImageEntity> list = (response.data?.list ?? []);
      // 只保存网络数据
      state.scanImages = list;
      // 如果有临时图片，再添加临时图片
      if (state.tempScanImages.isNotEmpty) {
        state.scanImages.addAll(state.tempScanImages);
      }
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message ?? "书内页列表失败");
    } catch (e) {
      print(e.toString());
      ToastUtils.showManageToast(text: e.toString());
    }
  }

  // 获取数据
  Future<DesertsFakeWebServiceResponse<BookResponseEntity>> onFetchPages(int currentPage, int startingAt, int count, String sortedBy, bool sortedAsc, bool noData) async {
    print('---异步获取数据startingAt:$startingAt, count:$count---');
    /*
     todo 每次调取接口, 服务器都将总数50 * kDesserts.length返回, 并且也返回本次请求的数据list
     count: 每页条数, 默认20条
     调取接口时, 将每页请求的条数告诉服务器, 否则每行会有相同的key, 页面报错
     */
    try {
      String? order;
      if (staticDataEntity.sort != null && staticDataEntity.basis != null) {
        order = "${staticDataEntity.sort?.value ?? ''}${staticDataEntity.basis?.value ?? ''}";
      }

      order ??= "-uid";

      final response = await BookUtil.fetchBooks(
          config: RequestConfig(parameters: {
        'offset': startingAt,
        'limit': count,
        "order": order
      }, data: {
        "uid": uids.isEmpty ? null : uids,
        "title": title,
        "isbn": _isbn,
        "publisher": _publisher,
      }, requireToken: true, cancelToken: cancelToken));
      print("hasData:${response.data?.hasData}");
      if (!(response.data?.hasData ?? false)) {
        return DesertsFakeWebServiceResponse<BookResponseEntity>(0, []);
      }
      return DesertsFakeWebServiceResponse<BookResponseEntity>(response.data!.count!, (response.data?.datas ?? []));
    } catch (e) {
      return DesertsFakeWebServiceResponse<BookResponseEntity>(0, []);
    }

    // return DesertsFakeWebServiceResponse<PhoneticRuleEntity>(
    //     // 50 * _phoneticRules.length, // 总共500个元素
    //     1000,
    //     // 1 * _phoneticRules.length, // 总共500个元素
    //     List.generate(count, (index) => _phoneticRules[(startingAt + index) % _phoneticRules.length]));
  }

  // 添加
  void add() {
    ManageBookCreateViewManager.show(context: Get.context!)?.then((value) {
      if (value != null) {
        // 刷新
        onRefresh();
      }
    });
  }

  /// 筛选
  void showFilter(BuildContext context) {
    print('--筛选--');
    // onShowFilter(context,
    //     selectLanguageIndex: _selectLanguageIndex,
    //     selectListingStatusIndex: _selectListingStatusIndex,
    //     selectAuthorIndex: _selectAuthorIndex, listener: ManageAllCourseFilterListener(
    //         onConfirmTap: (List<int> languageIndex, int listingStatusIndex, List<int> authorIndex) {
    //   _selectLanguageIndex = languageIndex;
    //   _selectListingStatusIndex = listingStatusIndex;
    //   _selectAuthorIndex = authorIndex;
    // }));
  }

  /// 排序
  void toSort(BuildContext context) {
    SortDialog.show(
      context: context,
      basisList: sortList,
      init: staticDataEntity,
      onSort: (data) {
        staticDataEntity = data;
        onRefresh();
      },
    );
  }

  // 出版社
  void onSetPublisher(String publisher, {bool isSubmit = false}) {
    _publisher = publisher;
    if (isSubmit) {
      onRefresh();
    }
  }

  // isbn
  void onSetIsbn(String isbn, {bool isSubmit = false}) {
    _isbn = isbn;
    if (isSubmit) {
      onRefresh();
    }
  }

  // 词汇扫描
  void toScanWord(BuildContext context, int? bookId, int? glossaryChapterId, {bool editEnable = false, bool fromUploadPage = false}) async {
    _targetBookId = bookId;
    _targetChapterId = glossaryChapterId;
    final bool hasCameraPermission = await PermissionUtils.camera(context);
    print("---[$runtimeType] 是否有相机权限: $hasCameraPermission");
    if (!hasCameraPermission) {
      return;
    }

    // 根据不同平台使用不同的相机实现
    if (Platform.isIOS || Platform.isAndroid) {
      return;
      // 使用移动平台的相机实现
      // _toScanWordMobile(context, editEnable: editEnable, fromUploadPage: fromUploadPage);
    } else if (Platform.isMacOS) {
      // 使用macOS平台的相机实现
      if (!CameraUtil().hasCamera) {
        final List<CameraDevice> devices = await CameraUtil().camera?.getCameras() ?? [];
        CameraListWidgetManager.show(
            context: Get.context!,
            devices: devices,
            onTap: (device) {
              CameraUtil().deviceId = device.id ?? '';
              _toScanWordMacOS(context, editEnable: editEnable, fromUploadPage: fromUploadPage);
            });
      } else {
        _toScanWordMacOS(context, editEnable: editEnable, fromUploadPage: fromUploadPage);
      }
    } else {
      ToastUtils.showManageToast(text: '暂不支持该平台');
    }
  }

  // macOS平台的扫描实现
  void _toScanWordMacOS(BuildContext context, {bool editEnable = false, bool fromUploadPage = false}) {
    MacosCameraManager.show(
        context: context,
        onContinueTap: (ui.Image v1, ui.Image v2) {
          // 预览
          _toPreview(context, v1, v2, editEnable: editEnable, fromUploadPage: fromUploadPage);
        })?.then((value) {
      print('---macOS取消拍照fromUploadPage:$fromUploadPage---');
      if (fromUploadPage) {
        return;
      }
      if (value != null && value) {
        onCleanScanWord();
      }
    });
  }

  // 移动平台(iOS/Android)的扫描实现
  // void _toScanWordMobile(BuildContext context, {bool editEnable = false, bool fromUploadPage = false}) {
  //   MobileCameraManager.show(
  //       // context: Get.context!,
  //       context: context,
  //       onContinueTap: (ui.Image v1, ui.Image v2) {
  //         // 预览
  //         _toPreview(context, v1, v2, editEnable: editEnable, fromUploadPage: fromUploadPage);
  //       })?.then((value) {
  //     print('---移动平台(iOS/Android)取消拍照fromUploadPage:$fromUploadPage---');
  //     if (fromUploadPage) {
  //       return;
  //     }
  //     if (value != null && value) {
  //       onCleanScanWord();
  //     }
  //   });
  // }

  // 预览页面
  void _toPreview(BuildContext context, ui.Image v1, ui.Image v2, {bool editEnable = false, bool fromUploadPage = false}) {
    ManagePreviewManager.show(
        context: context,
        v1: v1,
        v2: v2,
        onContinueTap: (String? f1, int? s1, String? f2, int? s2) {
          print('---待上传的单词表,f1:${f1 ?? ''},f2:${f2 ?? ''}---');
          if (ObjectUtil.isNotEmpty(f1?.trim())) {
            state.tempScanImages.add(WordImageEntity(url: f1!, size: s1));
          }
          if (ObjectUtil.isNotEmpty(f2?.trim())) {
            state.tempScanImages.add(WordImageEntity(url: f2!, size: s2));
          }
          print('---待上传的单词表,fromUploadPage:$fromUploadPage,tempScanImages:${state.tempScanImages}---');
          Get.back();
          // 如果是从上传页面来的，直接返回并刷新
          if (fromUploadPage) {
            onFetchBookPages(_targetBookId ?? 0, _targetChapterId ?? 0);
          }
        },
        onStopTap: (String? f1, int? s1, String? f2, int? s2) {
          if (ObjectUtil.isNotEmpty(f1?.trim())) {
            state.tempScanImages.add(WordImageEntity(url: f1!, size: s1));
          }
          if (ObjectUtil.isNotEmpty(f2?.trim())) {
            state.tempScanImages.add(WordImageEntity(url: f2!, size: s2));
          }
          Get.back();
          Get.back();
          print('---单词表,停止拍摄, 待上传的单词表,fromUploadPage:$fromUploadPage,tempScanImages:${state.tempScanImages}---');
          // 如果是从上传页面来的，直接返回并刷新
          if (fromUploadPage) {
            onFetchBookPages(_targetBookId ?? 0, _targetChapterId ?? 0);
          } else {
            // 首次打开上传页面
            toWordImageUpload(context, bookId: _targetBookId, chapterId: _targetChapterId, editEnable: editEnable);
          }
        });
  }

  //跳转到模块
  void toModule(BookResponseEntity item) {
    ManagePageRegistry.jumpTo(
      Routes.MANAGE_MODULE_DETILS,
      arguments: {
        "moduleId": item.moduleId,
        "moduleName": item.moduleName ?? '',
        "language": 'en',
      },
    );
  }

  // 单词表上传页面
  void toWordImageUpload(BuildContext context, {int? bookId, int? chapterId, bool editEnable = false}) {
    ChapterManagement.show(
        context: context,
        textbookId: bookId,
        onOpenPageManagement: (int bookId, int chapterId) {
          _targetBookId = bookId;
          _targetChapterId = chapterId;
          // 先清空scanImages，避免数据重复
          state.scanImages.clear();
          WordImageUploadManager.show(bookId: bookId, chapterId: chapterId, editEnable: editEnable, context: context).then((value) {
            if (value != null && value) {
              onRefresh();
            }
            // todo 取消时,清空临时保存的待上传图片
            onCleanScanWord();
          });
        });
  }

  // 编辑教材
  void onEdit(BookResponseEntity entity) {
    ManageBookEditManager.show(context: Get.context!, entity: entity)?.then((value) {
      if (value != null) {
        onRefresh();
      }
    });
  }

  // 词汇列表
  void toWordList({int? moduleId, int? bookId, String? bookName, bool editEnable = false}) {
    ManagePageRegistry.jumpTo(
      Routes.MANAGE_WORD_LIST,
      arguments: {"moduleId": moduleId, "bookId": bookId, "bookName": bookName, "editEnable": editEnable},
    ).then((value) {
      if (value != null && value) {
        onRefresh();
      }
    }).whenComplete(() {
      onCleanScanWord();
    });
  }

  // 确认并分析
  void onConfirmAnalyze() async {
    try {
      final response = await BookUtil.analysis(bookId: _targetBookId ?? 0, config: RequestConfig(requireToken: true, cancelToken: cancelToken));
      if (response?.data != null) {
        Get.back(result: true);
        onCleanScanWord();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  /*
  确认: 先将单词上传到oss, 再批量增删书内页
   */
  void onConfirm({bool analyze = false}) {
    if (state.scanImages.isEmpty) {
      ToastUtils.showManageToast(text: '待上传书内页不能为空');
      return;
    }

    if (!state.scanImages.every((element) => element.index != null)) {
      ToastUtils.showManageToast(text: '请填写页码');
      return;
    }

    ToastUtils.showLoading();
    /*
    批量上传
   */
    // 已经上传完成的图片实体
    final List<WordImageEntity> hasUploadedWordImageEntities = state.scanImages.where((element) => element.hasUid).toList();

    // 待上传的图片实体
    final List<WordImageEntity> notUploadedWordImageEntities = state.scanImages.where((element) => !element.hasUid).toList();

    if (notUploadedWordImageEntities.isEmpty) {
      print('没有需要上传的文件, 直接批量增删书内页');
      _onBatch(hasUploadedWordImageEntities.map((entity) => {"uid": entity.uid, "key": entity.key, "index": entity.index, "size": entity.size}).toList(), analyze: analyze);
      return;
    }

    BatchOssUploaderUtil.upload(
      imagePaths: notUploadedWordImageEntities.map((element) => element.url ?? '').toList(),
      onProgress: (index, progress) {
        print('文件$index 进度：${(progress * 100).toStringAsFixed(1)}%');
      },
      onTotalProgress: (progress) {
        print('总进度：${(progress * 100).toStringAsFixed(1)}%');
      },
    ).then((results) {
      final List bookPages = [];

      // 已经上传成功的图片实体
      bookPages.addAll(hasUploadedWordImageEntities.map((entity) => {"uid": entity.uid, "key": entity.key, "index": entity.index, "size": entity.size}).toList());

      bool isUploadSuccess = true;
      for (int i = 0; i < results.length; i++) {
        final UploadResult result = results[i];
        if (result.success) {
          print('成功上传：${result.key}');
          final WordImageEntity entity = notUploadedWordImageEntities[i];
          isUploadSuccess = true;
          if (result.key != null) {
            bookPages.add({"key": result.key, "index": entity.index, "size": entity.size});
          }
        } else {
          isUploadSuccess = false;
          print('上传失败：${result.error}');
          break;
        }
      }

      if (isUploadSuccess) {
        _onBatch(bookPages, analyze: analyze);
      } else {
        ToastUtils.showManageToast(text: "图片上传失败,请重新上传");
        ToastUtils.hideLoading();
      }
    }).catchError((error) {
      ToastUtils.hideLoading();
    });
  }

  // 批量增删书内页
  void _onBatch(List bookPages, {bool analyze = false}) async {
    try {
      if (bookPages.isEmpty) {
        print('待上传书内页为空');
        ToastUtils.showManageToast(text: '待上传书内页不能为空');
        return;
      }

      final response = await BookUtil.batch(
          bookId: _targetBookId ?? 0,
          chapterId: _targetChapterId ?? 0,
          config: RequestConfig(data: jsonEncode({'bookPages': bookPages}), requireToken: true, cancelToken: cancelToken));
      if (response.data != null) {
        ToastUtils.showManageToast(text: '保存成功');
        Get.back(result: true);
      } else {
        ToastUtils.showManageToast(text: response.message ?? '保存失败');
      }
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message ?? "保存失败");
    } catch (e) {
      ToastUtils.showToast(text: "保存失败");
    } finally {
      ToastUtils.hideLoading();
    }
  }

  // 添加本地文件
  Future<String?> onAddCover(BuildContext context) async {
    showCupertinoDialog(
      context: context,
      builder: (_) => Container(),
    );

    final String? path = await onPickFile(context: context);

    if (path == null) {
      Get.back();
      return null;
    }

    Get.back();

    onGetToken(path, needLength: true, callback: (String? key, int? size) {
      // 添加到临时待上传的图片数据源
      state.scanImages.add(WordImageEntity(
        key: key,
        size: size,
        url: path,
      ));
      debugPrint('--key: $key--');
    });
    return path;
  }

  /// 更改书籍扫描词类型状态
  ///
  /// [item] - 需要更新状态的书籍对象
  /// [type] - 新的扫描词类型
  void changeWordType(BookResponseEntity item, ScanWordType status) async {
    try {
      ToastUtils.showLoading();

      // 调用API更新状态
      final response =
          await BookUtil.changeStatus(bookId: item.uid, config: RequestConfig(data: {'status': status.value, "type": item.type}, requireToken: true, cancelToken: cancelToken));
      if (response.data != null) {
        ToastUtils.showToast(text: "状态更新成功", type: ToastType.success);
        // 刷新数据
        onRefresh();
      } else {
        ToastUtils.showToast(text: response.message ?? "更新状态失败");
      }
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message ?? "更新状态失败");
    } catch (e) {
      ToastUtils.showToast(text: "更新状态失败: ${e.toString()}");
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 设置状态筛选
  void setStatusFilter(ScanWordType? status) {
    state.statusFilter = status;
    // 更新状态筛选组件
    update(['status_filter']);
    // 直接调用onRefresh重新加载数据，让后端处理状态筛选
    onRefresh();
  }

  // 取消上传/清空拍摄的照片
  void onCleanScanWord() {
    _targetBookId = null;
    _targetChapterId = null;
    state.scanImages.clear();
    onCleanTempScanImage();
    print("清空所有缓存数据/_targetBookId/_targetChapterId");
  }

  void onCleanTempScanImage() {
    for (final WordImageEntity entity in [...state.tempScanImages]) {
      unawaited(_onDeleteScanImage(entity));
    }
    state.tempScanImages.clear();
    print("清空拍摄的照片");
  }

  Future<void> _onDeleteScanImage(WordImageEntity entity) async {
    if (!entity.isUrl && File(entity.url!).existsSync()) {
      File(entity.url!).delete();
      print("异步删除图片文件:${entity.url}");
    }
  }

  @override
  void onClose() {
    super.onClose();
    onCleanScanWord();
    cancelToken.cancel("教材词汇扫描取消");
    print("教材词汇扫描取消");
  }
}
