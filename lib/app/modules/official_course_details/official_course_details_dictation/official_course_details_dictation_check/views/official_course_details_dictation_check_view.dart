import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../../../../../routes/routes.dart';
import '../bindings/official_course_details_dictation_check_binding.dart';
import '../../../common/official_course_details_target_widgets.dart';
import '../controllers/official_course_details_dictation_check_controller.dart';

class OfficialCourseDetailsDictationCheckView extends GetView<OfficialCourseDetailsDictationCheckController> {
  final String tagText;
  const OfficialCourseDetailsDictationCheckView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      () => OfficialCourseDetailsDictationCheckView(tagText: tag),
      binding: OfficialCourseDetailsDictationCheckBinding(tagText: tag),
      routeName: Routes.OFFICIAL_COURSE_DETAILS_DICTATION_CHECK,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary.color,
      body: Column(
        children: [
          const BreadcrumbWidget(),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.only(
                left: 70.wMin,
                right: 70.wMin,
                top: 24.wMin,
                bottom: MediaQuery.of(context).padding.bottom + 24.wMin,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 16.wMin,
                crossAxisSpacing: 16.wMin,
                mainAxisExtent: 220.wMin,
              ),
              itemCount: controller.knowledgeList.length,
              itemBuilder: (context, index) {
                return KnowledgeCardItemWidget(
                  knowledge: controller.knowledgeList[index],
                  allKnowledge: const [],
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  

}
