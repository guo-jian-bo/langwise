import 'package:get/get.dart';

class SignInUpState {
  final RxString _callingCode = '86'.obs;
  String get callingCode => _callingCode.value;
  set callingCode(value) => _callingCode.value = value;

  final RxBool _isChecked = false.obs;
  bool get isChecked => _isChecked.value;
  set isChecked(value) => _isChecked.value = value;

  // 倒计时
  final RxBool _isCountDown = false.obs;
  bool get isCountDown => _isCountDown.value;
  set isCountDown(value) => _isCountDown.value = value;

  final _currentTime = 60.obs;
  set currentTime(value) => _currentTime.value = value;
  get currentTime => _currentTime.value;
}
