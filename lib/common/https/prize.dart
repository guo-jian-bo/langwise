import 'dart:io';

import 'package:api/entities/config.dart';
import 'package:api/entities/response.dart';
import 'package:langwise/common/entities/prize.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:wise_http/wise_http.dart';

class PrizeRequest {
  static Future<PrizeData?> getPrizeList() async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      var response = await WiseHttp().request(
        "/activity-console/task/prize/list",
        Method.post,
        requireToken: config.requireToken,
        headers: config.headers,
        data: {},
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return PrizeData.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> createPrize({required String name,required String description, required String type, required int value, required int duration, required String durationType}) async {
    try {
      var data = {
        'name':name,
        'description':description,
        'type':type
      };

      if(PrizeType.isReturnVal(type)){
        data['value'] = "$value";
      }else{
        data['duration'] = "$duration";
        data['durationType'] = durationType;
      }
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );

      var response = await WiseHttp().request(
        "/activity-console/task/prize/create",
        Method.post,
        requireToken: config.requireToken,
        headers: config.headers,
        data: config.data,
        parameters: config.parameters,
      );
      if(response==null)return false;
       ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return false;
      }
      if (responseEntity.data == null) return false;
      return true;
    } catch (e) {
      return false;
    }
  }
}
