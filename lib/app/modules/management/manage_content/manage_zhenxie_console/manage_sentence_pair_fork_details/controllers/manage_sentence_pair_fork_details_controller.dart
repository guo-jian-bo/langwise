import 'package:get/get.dart';

import '../../../../../../routes/routes.dart';
import '../../../../utils/utils.dart';

class ManageSentencePairForkDetailsController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageSentencePairForkDetailsController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_SENTENCE_PAIR_FORK_DETAILS;

  @override
  String get breadcrumbTitle => '句间配链分叉详情';

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    // TODO: 初始化逻辑
  }

  /// 打开配对
  Future<void> toPairDetails() async{
    ManagePageRegistry.jumpTo(Routes.MANAGE_SENTENCE_PAIR_DETAILS);
  } 

  @override
  void onClose() {
    // TODO: 清理逻辑
    super.onClose();
  }
}
