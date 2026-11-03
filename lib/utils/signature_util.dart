import 'dart:developer';

import 'package:lib_common/common.dart' show AlgorithmsUtils;

class SignatureUtil {
  static String generateSignature(String appId, String appSecret, int seconds) {
    final signatureParam = "WISEappId=$appId&timestamp=$seconds";
    log("signatureParam = $signatureParam");
    String signature = AlgorithmsUtils.hmacSha256(appSecret, signatureParam);
    log("end calc signature = $signature");
    return signature;
  }
}
