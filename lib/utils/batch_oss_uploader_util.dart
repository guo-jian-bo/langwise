import 'dart:async';

import 'oss_upload_file_utils/oss_upload_file_utils.dart';

class BatchOssUploaderUtil {
  /// 批量上传（全并发模式）
  /// [imagePaths] 图片路径数组
  /// [onProgress] 单个文件进度回调 (索引, 当前进度)
  /// [onTotalProgress] 整体进度回调 (0.0-1.0)
  static Future<List<UploadResult>> upload({
    required List<String> imagePaths,
    void Function(int index, double progress)? onProgress,
    void Function(double totalProgress)? onTotalProgress,
  }) async {
    final progressMap = <int, double>{};
    final total = imagePaths.length;

    // 生成所有上传任务
    final tasks = imagePaths.asMap().entries.map((entry) => _uploadWithToken(
          index: entry.key,
          filePath: entry.value,
          onProgress: (progress) {
            progressMap[entry.key] = progress;
            onProgress?.call(entry.key, progress);
            _updateTotalProgress(progressMap, total, onTotalProgress);
          },
        ));

    // 并发执行并等待结果
    return Future.wait(tasks);
  }

  /// 单个文件完整上传流程
  static Future<UploadResult> _uploadWithToken({
    required int index,
    required String filePath,
    required void Function(double progress) onProgress,
  }) async {
    try {

      final resp = await OssUploadFileUtils.uploadUserFile(
        filePath: filePath,
        onSendProgress: (sent, total) => onProgress(sent / total),
      );

      if(resp == null) {
        return UploadResult.failure(index, filePath, '上传失败');
      }

      return UploadResult.success(index, filePath, resp.key);
    } catch (e) {
      return UploadResult.failure(index, filePath, e.toString());
    }
  }

  /// 更新整体进度
  static void _updateTotalProgress(
    Map<int, double> progresses,
    int total,
    void Function(double progress)? callback,
  ) {
    if (callback == null) return;

    final sum = progresses.values.fold(0.0, (acc, p) => acc + p);
    callback(sum / total);
  }
}

/// 上传结果模型
class UploadResult {
  final int index;
  final bool success;
  final String? key;
  final String? error;
  final String filePath;

  UploadResult.success(this.index, this.filePath, this.key)
      : success = true,
        error = null;

  UploadResult.failure(this.index, this.filePath, this.error)
      : success = false,
        key = null;

  @override
  String toString() => '[$index] ${success ? "成功" : "失败"} ${error ?? key}';
}

/// 使用示例：
/*
BatchOssUploader.upload(
  imagePaths: ['/path/1.jpg', '/path/2.jpg'],
  onProgress: (index, progress) {
    print('文件$index 进度：${(progress * 100).toStringAsFixed(1)}%');
  },
  onTotalProgress: (progress) {
    print('总进度：${(progress * 100).toStringAsFixed(1)}%');
  },
).then((results) {
  results.forEach((result) {
    if (result.success) {
      print('成功上传：${result.key}');
    } else {
      print('上传失败：${result.error}');
    }
  });
});
*/
