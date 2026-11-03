import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/music/views/music_view.dart';
import 'package:langwise/app/modules/subscribe_and_listening/view.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/widgets/guide_engine/guide_manager.dart';
import 'package:langwise/common/widgets/guide_engine/guide_anchor.dart';
import 'package:langwise/common/widgets/guide_engine/guide_task_float_widget.dart';
import '../../../../theme/theme.dart';
import '../../elements/elements_detils/views/elements_detils_view.dart';
import '../../home/views/home_view.dart';
import '../../specialty/views/specialty_view.dart';
import '../common/nav_buttons_widget.dart';
import '../controllers/application_controller.dart';

class ApplicationView extends GetView<ApplicationController> {
  const ApplicationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary,
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: Obx(() {
        List<Widget> navPage = [
          const HomeView(), 
          SubListenPage(), 
          MusicView(), 
          const ElementsDetilsView(), 
          const SpecialtyView(),
        ];
        
        // if (controller.userStore.userInfo.value.isImageReview) {
        //   navPage.add(const ImageModerationPage());
        // }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) {
            final currentIndex = controller.navIndex.value;
            final isNewWidget = child.key == ValueKey(currentIndex);
            Animation<Offset> slide = Tween<Offset>(
              begin: Offset(controller.previousIndex > currentIndex ? 1 : -1, 0),
              end: Offset.zero,
            ).animate(animation);
            Animation<double> slideFade = Tween<double>(begin: 0, end: 1).animate(animation);
            if (isNewWidget) {
              slide = Tween<Offset>(
                begin: Offset(controller.previousIndex > currentIndex ? -1 : 1, 0),
                end: Offset.zero,
              ).animate(animation);
              slideFade = Tween<double>(begin: 0, end: 1).animate(animation);
            }
            return FadeTransition(
              opacity: slideFade,
              child: SlideTransition(position: slide, child: child),
            );
          },
          child: SizedBox(
            key: ValueKey(controller.navIndex.value),
            child: navPage[controller.navIndex.value],
          ),
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Obx(() {
        final guideManager = GuideManager.instance;
        guideManager.refreshTick.value;

        final tasks = guideManager.tasks;
        final hasActive = tasks.isNotEmpty && tasks.any((t) => !t.isDone);
        if (!hasActive) return const SizedBox.shrink();
        return Padding(
          padding: EdgeInsets.only(bottom: 0.wMin),
          child: GuideAnchor(
            id: GuideManager.taskListEntryAnchorId,
            route: Routes.APPLICATION,
            action: () {
              final highlightTaskId = GuideManager.instance.pendingEntryHighlightTaskId;
              GuideTaskFloatWidget.showTaskListSheet(highlightTaskId: highlightTaskId);
            },
            child: Badge(
              child: const GuideTaskFloatWidget(text:'新手任务'),
              isLabelVisible: tasks.where((t) => !t.isDone).isNotEmpty,
              label: Text(tasks.where((t) => !t.isDone).length.toString(),style: TextStyle(fontSize: 18.wMin),),
            ),
          ),
        );
      }),
      bottomNavigationBar: const NavButtonsWidget(),
    );
  }
}
