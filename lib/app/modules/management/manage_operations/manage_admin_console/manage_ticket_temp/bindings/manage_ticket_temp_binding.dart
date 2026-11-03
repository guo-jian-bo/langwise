import 'package:get/get.dart';

import '../controllers/manage_ticket_temp_controller.dart';

class ManageTicketTempBinding extends Bindings {
  final String tag;
  ManageTicketTempBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageTicketTempController>(
      () => ManageTicketTempController(tag: tag),
      tag: tag,
    );
  }
}
