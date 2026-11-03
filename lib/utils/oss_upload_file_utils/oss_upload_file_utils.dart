// # 资源上传接口文档

// ## 1. 用户端获取上传 Token

// **接口地址**：`POST /resource/token`

// **接口说明**：用户端上传文件前获取上传凭证（Token）。

// **请求参数 (Body)**：

// | 参数名 | 类型 | 必填 | 说明 | 可选值 |
// | :--- | :--- | :--- | :--- | :--- |
// | `type` | String | 是 | 文件类型 | `image`: 图片<br>`voice`: 录音<br>`log`: 日志 |

// ---

// ## 2. 管理端获取上传 Token

// **接口地址**：`POST /resource/console/token`

// **接口说明**：管理端上传文件前获取上传凭证（Token）。

// **请求参数 (Body)**：

// | 参数名 | 类型 | 必填 | 说明 | 详细描述 |
// | :--- | :--- | :--- | :--- | :--- |
// | `type` | String | 是 | 资源类型 | `image`: 隐私图片<br>`publicImage`: 公共图片（直接展示）<br>`video`: 视频<br>`track`: 音频<br>`version`: APP 软件包 |
// | `module` | String | 否 | 业务模块 | 根据 `type` 的不同，可选值有所区别（见下表） |
// | `format` | String | 是 | 文件格式 | 例如：jpg, mp3, mp4 等 |
// | `key` | String | 是 | 文件名 | 包含文件格式后缀的文件全名 | 使用MD5 前端获取

// **Module 参数说明**：

// *   **当 `type = image` 时，`module` 可选值：**
//     *   `course`: 课程
//     *   `module`: 课程模块
//     *   `lesson`: 课程课时
//     *   `exercise`: 题目
//     *   `book`: 书籍
//     *   `bookPage`: 书页

// *   **当 `type = track` 时，`module` 可选值：**
//     *   包含上述 `image` 的所有模块
//     *   `enAudio`: 英语音频



import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;

import 'package:api/api.dart';
import 'package:wise_http/wise_http.dart';

import '../utils.dart';
import 'oss_update_response_entity.dart';
import 'oss_upload_token_entity.dart';



/// 用户端文件类型
enum OssUploadUserType {
  /// 图片类型
  image(type: "image"),
  /// 语音类型
  voice(type: "voice"),
  /// 日志类型
  log(type: "log");

  const OssUploadUserType({required this.type});
  final String type;
}


/// 管理端文件类型
enum OssFileManageType {
  /// 隐私图片
  image("image"),
  /// 视频
  video("video"),
  /// 音频
  track("track"),
  /// APP软件包
  version("version");

  /// 公共图片
  // publicImage("publicImage");

  const OssFileManageType(this.type);
  final String type;
}

/// 管理端文件模块
enum OssFileManageModule {
  /// 课程
  course("course"),
  /// 课程模块
  module("module"),
  /// 知识点
  knowledge("knowledge"),
  /// 课程课时
  lesson("lesson"),
  /// 题目
  exercise("exercise"),
  /// 书籍
  book("book"),
  /// 书页
  bookPage("bookPage"),
  /// 英语音频 - type = track
  enAudio("enAudio"), 
  /// 剧本演员
  actor("actor"),
  /// 视觉项目
  scriptTmp("scriptTmp");
  
  const OssFileManageModule(this.value);
  final String value;
}


/// OSS文件上传工具类
class OssUploadFileUtils {



  /// 上传用户图片
  /// 用于上传用户相关的图片文件
  static Future<OssUpdateResponseEntity?> uploadUserFile({
    OssUploadUserType fileType = OssUploadUserType.image,
    required String filePath,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    // 实现上传用户图片的逻辑
    
    try {
      File file = File(filePath);
      if (!(await file.exists())) {
        return null;
      }

      // 获取文件扩展名
      final String extensionName = getFileExtension(filePath);

      // key 使用文件的md5
      String fileMd5 = await getFileMD5(file);

      final String fileName = "$fileMd5$extensionName";

      OssUploadTokenEntity? tokenInfo = await getUserAssetsToken(
        fileType: fileType,
        md5FileName: "$fileMd5$extensionName",
      );
      if (tokenInfo == null) return null;
      if(tokenInfo.host == null || tokenInfo.host!.isEmpty) {
        return null;
      }

      String key = "${tokenInfo.ossKey}";

      Map<String, dynamic> formMap = {
        "name": fileName,
        "policy": tokenInfo.policy,
        "OSSAccessKeyId": tokenInfo.ossAccessKeyId,
        "success_action_status": "200",
        "signature": tokenInfo.signature,
        "key": key,
        "file": await MultipartFile.fromFile(filePath, filename: fileName),
      };

      final formData = FormData.fromMap(formMap);

      dynamic response = await AssistHttp().request(
        tokenInfo.host!, 
        Method.post,
        requireToken: true,
        data: formData,
        onSendProgress: onSendProgress,
      );

      ErrorLogUtils.to.logError("上传图片，上传信息：${ErrorLogUtils.to.toSingleLineJsonSafe(formData)}，上传结果：${ErrorLogUtils.to.toSingleLineJsonSafe(response)}", null);

      if (response == null) {
        ToastUtils.showToast(text: "上传失败");
        return null;
      }
      if(response.statusCode != HttpStatus.ok){
        ToastUtils.showToast(text: "上传失败 ${response.statusCode}");
        return null;
      }

      return OssUpdateResponseEntity(
        key: key, 
        url: tokenInfo.url,
        data: response.data,
        md5: fileMd5,
      );
    } catch (e) {
      return null;
    }
  }


  /// 上传文件-管理端
  /// 上传用户图片
  /// 用于上传用户相关的图片文件
  static Future<OssUpdateResponseEntity?> uploadManageFile({
    OssFileManageType fileType = OssFileManageType.image,
    OssFileManageModule fileModule = OssFileManageModule.course,
    required String filePath,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    // 实现上传管理端文件的逻辑
    
    try {
      File file = File(filePath);
      if (!(await file.exists())) {
        return null;
      }

      // 获取文件扩展名
      final String extensionName = getFileExtension(filePath);

      // key 使用文件的md5
      String fileMd5 = await getFileMD5(file);

      final String fileName = "$fileMd5$extensionName";

      OssUploadTokenEntity? tokenInfo = await getManageAssetsToken(
        fileType: fileType,
        fileModule: fileModule,
        format: extensionName.substring(1), // 去掉点号
        md5FileName: "$fileMd5$extensionName",
      );
      if (tokenInfo == null) return null;
      if(tokenInfo.host == null || tokenInfo.host!.isEmpty) {
        return null;
      }

      String key = "${tokenInfo.ossKey}";

      final formData = FormData.fromMap({
        "name": fileName,
        "policy": tokenInfo.policy,
        "OSSAccessKeyId": tokenInfo.ossAccessKeyId,
        "success_action_status": "200",
        "signature": tokenInfo.signature,
        "key": key,
        "file": await MultipartFile.fromFile(filePath, filename: fileName),
      });

      dynamic response = await AssistHttp().request(
        tokenInfo.host!, 
        Method.post,
        requireToken: true,
        data: formData,
        onSendProgress: onSendProgress,
      );
      if (response == null) return null;
      if(response.statusCode != HttpStatus.ok) return null;

      return OssUpdateResponseEntity(
        key: key, 
        url: tokenInfo.url,
        data: response.data,
        md5: fileMd5,
      );
    } catch (e) {
      return null;
    }
  }


  /// 获取用户端token
  static Future<OssUploadTokenEntity?> getUserAssetsToken({
    OssUploadUserType fileType = OssUploadUserType.image,
    required String md5FileName,
  }) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: {'type': fileType.type, "key": md5FileName}
      );
      dynamic response = await WiseHttp().request(
        "/accounts/resource/token",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      
      return OssUploadTokenEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      ToastUtils.showToast(text: '上传图片失败');
      return null;
    }
  }




  /// 获取管理端token
  static Future<OssUploadTokenEntity?> getManageAssetsToken({
    OssFileManageType fileType = OssFileManageType.image,
    OssFileManageModule fileModule = OssFileManageModule.course,
    required String format,
    required String md5FileName,
  }) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: {
          'type': fileType.type,
          'format': format,
          'module': fileModule.value,
          'key': md5FileName,
        }
      );
      dynamic response = await WiseHttp().request(
        "/accounts/resource/console/token",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      
      return OssUploadTokenEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      ToastUtils.showToast(text: '获取管理端token失败');
      return null;
    }
  }



  /// 获取文件扩展名
  /// @param filePath 文件路径
  /// @return 文件扩展名（包含点号）
  static String getFileExtension(String filePath) {
    // 使用 path.extension 提取文件扩展名
    return path.extension(filePath);
  }

  static Future<String> getFileMD5(File file) async {
  // 适合小文件（一次性读取）
  // final bytes = await file.readAsBytes();
  // return md5.convert(bytes).toString();
  
  // 方法2：适合大文件（流式处理，节省内存）
  final stream = file.openRead();
  final digest = await md5.bind(stream).first;
  return digest.toString().toUpperCase();
}


}
