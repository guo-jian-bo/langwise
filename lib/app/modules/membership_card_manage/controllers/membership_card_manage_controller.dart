import 'package:api/entities/response.dart';
import 'package:get/get.dart';
import 'package:langwise/common/https/membership_card_manage.dart';
import '../models/membership_card_manage_model.dart';

class MembershipCardManageController extends GetxController {
  RxInt currentIndex = 0.obs;
  Rx<MembershipCardManageModel> model = MembershipCardManageModel().obs;

  @override
  void onInit() {
    super.onInit();

    initData();
  }

  initData() async {
    final ResponseEntity<MembershipCardManageModel>? res =
        await MembershipCardManageApi.membershipCardDetails();
    if (res?.data == null) {
      return;
    }
    model.value = res!.data!;
  }
}
