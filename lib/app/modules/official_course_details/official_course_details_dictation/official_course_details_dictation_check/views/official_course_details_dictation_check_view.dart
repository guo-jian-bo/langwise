import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../common/official_course_details_target_widgets.dart';
import '../controllers/official_course_details_dictation_check_controller.dart';

class OfficialCourseDetailsDictationCheckView extends GetView<OfficialCourseDetailsDictationCheckController> {
  const OfficialCourseDetailsDictationCheckView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary.color,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 24.wMin,
              left: 40.wMin,
            ),
            child: const BackWidget(title: "核对答案"),
          ),
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
                  allKnowledge: [],
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  

}
