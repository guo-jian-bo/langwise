import 'package:api/entities/response.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';
import 'package:langwise/common/https/membership_card_manage.dart';
import '../models/membership_card_manage_model.dart';

class MembershipCardManageController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  MembershipCardManageController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.MEMBERSHIP_CARD_MANAGE;

  @override
  String get breadcrumbTitle => '会员卡管理';

  RxInt currentIndex = 0.obs;
  Rx<MembershipCardManageModel> model = MembershipCardManageModel().obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);

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
