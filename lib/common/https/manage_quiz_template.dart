
import 'package:api/api.dart';
import 'package:get/get_connect/http/src/status/http_status.dart';
import 'package:quiz_play/models/models.dart';
import 'package:wise_http/wise_http.dart';

import '../../utils/utils.dart';
import '../entities/entities.dart';

class ManageQuizTemplateRequest{

  static Future<List<ManageQuizTemplateEntity>?> getQuizTemplateList() async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/exercise/template/list", 
        Method.get, 
        headers: config.headers, 
        requireToken: config.requireToken,
        requireCache: config.requireCache,
      );
      if(response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if(responseEntity.code != HttpStatus.ok) {
        if(responseEntity.message != null){
          ToastUtils.showManageToast(text: responseEntity.message??"", type: ManageToastType.error);
        }
        return null;
      }
      if(responseEntity.data == null) return null;
      List? list = responseEntity.data['list'];
      if(list == null) return null;
      List<ManageQuizTemplateEntity> result = [];
      for(int i = 0; i < list.length; i++){
        result.add(ManageQuizTemplateEntity.fromJson(list[i]));
      }
      return result;
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }


  /// 根据配置获取题目变形数据
  static Future<List<QuizModel>?> getQuizDeformationData(Map<String, dynamic> data) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/exercise/template/query/config", 
        Method.post, 
        headers: config.headers, 
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
        parameters: config.parameters,
      ).catchError((_){});
      if(response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if(responseEntity.code != HttpStatus.ok) {
        if(responseEntity.message != null){
          ToastUtils.showManageToast(text: responseEntity.message??"", type: ManageToastType.error);
        }
        return null;
      }
      if(responseEntity.data == null) return null;
      List? list = responseEntity.data['list'];
      if(list == null) return null;
      List<QuizModel> result = [];
      for(int i = 0; i < list.length; i++){
        result.add(QuizModel.fromJson(list[i]));
      }
      return result;
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

}