import 'package:get/get.dart';

import 'controller.dart';

class SignInUpBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignInUpController>(() => SignInUpController());
  }
}
