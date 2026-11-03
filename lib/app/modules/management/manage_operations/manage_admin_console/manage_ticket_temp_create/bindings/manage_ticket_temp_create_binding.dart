import 'package:get/get.dart';

import '../controllers/manage_ticket_temp_create_controller.dart';

class ManageTicketTempCreateBinding extends Bindings {
  final String tag;
  ManageTicketTempCreateBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageTicketTempCreateController>(
      () => ManageTicketTempCreateController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
