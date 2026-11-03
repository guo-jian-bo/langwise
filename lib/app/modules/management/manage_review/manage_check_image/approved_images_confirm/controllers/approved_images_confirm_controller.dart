import 'package:get/get.dart';
import 'package:langwise/common/entities/content_review_image_entities.dart';
import 'package:langwise/common/https/content_review_image.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../../routes/routes.dart';
import '../../../../utils/manage_breadcrumb_utils.dart';

class ApprovedImagesConfirmController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ApprovedImagesConfirmController({required this.tag});

  static ApprovedImagesConfirmController get to => Get.find<ApprovedImagesConfirmController>();

  final RxList<ContentReviewApprovedImage> images = <ContentReviewApprovedImage>[].obs;
  int relationUid = 0;
  int taskId = 0;
  int imageId = 0;
  int selectedImageId = 0;
  String selectedImageUrl = '';

  @override
  String get breadcrumbRoute => Routes.APPROVED_IMAGES_CONFIRM;
  
  @override
  String get breadcrumbTitle => '确认审核';

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    
    final args = (Get.arguments ?? {}) as Map;
    final list = (args['images'] as List?)?.cast<ContentReviewApprovedImage>() ?? const <ContentReviewApprovedImage>[];
    relationUid = args['relationUid'];
    taskId = args['taskId'];
    imageId = args['imageId'];
    selectedImageId = args['selectedImageId'] ?? 0;
    selectedImageUrl = (args['selectedImageUrl'] ?? '').toString();
    images.assignAll(list);
  }

  Future<void> submit() async {
    try {
      ToastUtils.showLoading();
      var res = await ContentReviewImageUtil.approve(
        relationUid: relationUid,
        imageId: imageId,
        taskId: taskId,
      );
      if (res != null) {
        Get.back(result: true);
      }
    } finally{
      ToastUtils.hideLoading();
    }
    
  }

  void closePage() {
    Get.back(result: false);
  }

  @override
  void onClose() {
    super.onClose();
  }

}
