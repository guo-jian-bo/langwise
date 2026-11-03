import 'dart:io';
import 'package:data_table_2/data_table_2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/data_table_widget/data_sources.dart';
import 'package:langwise/utils/utils.dart';
import 'package:mime/mime.dart';
import 'package:wise_http/wise_http.dart';

import '../../utils/oss_upload_file_utils/oss_upload_file_utils.dart';

abstract class BaseController extends GetxController {
  final List<String> allowedExtensions = ['bmp', 'webp', 'gif', 'jpeg', 'jpg', 'png', 'heic', 'heif'];

  /// 创建方式
  final RxInt createWay = 0.obs;

  final CancelToken cancelToken = CancelToken();

  // 每页请求的数量
  final int limit = 30;

  // 列表加载数据
  int offset = 0;

  // table控制器
  AsyncDataTableSource? dessertDataSourceAsync;

  // 搜索
  String? title, des;

  List<String> uids = [];

  // 默认从课程跳转过来
  int get sourcePageId => _sourcePageId;
  int _sourcePageId = 0;

  // 性能追踪相关变量
  late String _controllerTag;
  Stopwatch? _initStopwatch;

  @override
  void onInit() {
    super.onInit();
    

    // 开始追踪控制器初始化性能
    _controllerTag = runtimeType.toString();
    _initStopwatch = _startPerformanceTrace('${_controllerTag}.init');

    // 跟踪控制器对象（用于内存泄漏检测）
    if (Get.isRegistered<PerformanceService>()) {
      PerformanceService.to.trackObject(this, tag: _controllerTag);
    }
  }

  @override
  void onReady() {
    super.onReady();
    print("sourcePageId: $_sourcePageId");

    // 结束控制器初始化性能追踪
    _endPerformanceTrace('$_controllerTag.init', _initStopwatch);
  }

  @override
  void onClose() {
    //cancelToken.cancel();

    // 停止跟踪控制器对象
    if (Get.isRegistered<PerformanceService>()) {
      PerformanceService.to.stopTracking(this);
    }

    super.onClose();
  }

  /// 开始性能追踪
  Stopwatch _startPerformanceTrace(String tag) {
    if (Get.isRegistered<PerformanceService>()) {
      return PerformanceService.to.startTrace(tag);
    }
    return Stopwatch()..start();
  }

  /// 结束性能追踪
  void _endPerformanceTrace(String tag, Stopwatch? stopwatch, {int? expectedDurationMs}) {
    if (stopwatch != null && Get.isRegistered<PerformanceService>()) {
      PerformanceService.to.endTrace(tag, stopwatch, expectedDurationMs: expectedDurationMs);
    }
  }

  // 选择文件
  Future<String?> onPickFile({required BuildContext context, FileType type = FileType.custom}) async {
    try {

      File? result = await ImagePickerUtils.pickImage(context);

      final String? path = result?.path;
      if (path == null) {
        return null;
      }

      if (_validateImageFile(path)) {
        // 文件有效
        
        return path;
      } else {
        // 文件无效
        ToastUtils.showToast(text: '请选择文件');
        return null;
      }
    } catch (e) {
      debugPrint('封面选择错误: $e');
      ToastUtils.showToast(text: '选择文件失败，请重试');
      return null;
    }
  }

  // 获取上传图片token
  void onGetToken(String filePath, {bool needLength = false, Function(String?, int?)? callback}) {

    try {
      final File originalFile = File(filePath);

      OssUploadFileUtils.uploadManageFile(
        filePath: filePath,
      ).then((value){
        if (value == null) {
          return;
        }
        
        callback?.call(value.key, needLength ? originalFile.lengthSync() : null);

      });
    } catch (e) {
      ToastUtils.showToast(text: '上传图片失败');
    }
  }


  // 验证文件有效性
  bool _validateImageFile(String path) {
    // 1. 扩展名验证（快速过滤）
    final ext = path.split('.').last.toLowerCase();
    if (!allowedExtensions.contains(ext)) return false;

    // 2. MIME类型验证（深度校验）
    final mime = lookupMimeType(path);
    return mime?.startsWith('image/') ?? false;
  }

  // 异步数据处理器
  void onSetDataSourceAsync(AsyncDataTableSource? source) {
    dessertDataSourceAsync = source;
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
      onRefresh();
    }
  }

  // 名字
  void onSetName(String name, {bool isSubmit = false}) {
    title = name;

    if (isSubmit) {
      onRefresh();
    }
  }

  // 描述
  void onSetDes(String d, {bool isSubmit = false}) {
    des = d;

    if (isSubmit) {
      onRefresh();
    }
  }

  // 刷新
  void onRefresh() {
    dessertDataSourceAsync?.refresh();
  }

  // 页面来源
  void onSetSourcePage(int? type) {
    if (type != null) {
      _sourcePageId = type;
    }
  }

  // 目标页面ID
  int get targetPageId => sourcePageId;
}
