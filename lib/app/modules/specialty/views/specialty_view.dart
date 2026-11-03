import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../common/widgets/widgets.dart';
import '../../../routes/routes.dart';
import '../../application/controllers/application_controller.dart';
import '../bindings/specialty_binding.dart';
import '../controllers/specialty_controller.dart';
import '../phonics_course/controllers/phonics_course_controller.dart';
import '../phonics_course/views/phonics_course_view.dart';

class SpecialtyView extends StatefulWidget {
  final String tagText;
  const SpecialtyView({
    super.key,
    this.tagText = Routes.SPECIALTY,
  });

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return Get.to<T>(
      () => SpecialtyView(tagText: tag),
      binding: SpecialtyBinding(tagText: tag),
      routeName: Routes.SPECIALTY,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  State<SpecialtyView> createState() => _SpecialtyViewState();
}

class _SpecialtyViewState extends State<SpecialtyView> {
  static const String _embeddedPhonicsTag = 'specialty_embedded_phonics_course';
  int _lastSyncedEntryVersion = -1;

  SpecialtyController get controller =>
      Get.find<SpecialtyController>(tag: widget.tagText);

  PhonicsCourseController _ensureEmbeddedPhonicsController() {
    if (Get.isRegistered<PhonicsCourseController>(tag: _embeddedPhonicsTag)) {
      return Get.find<PhonicsCourseController>(tag: _embeddedPhonicsTag);
    }
    return Get.put(
      PhonicsCourseController(),
      tag: _embeddedPhonicsTag,
    );
  }

  Future<void> _syncEmbeddedPhonicsCourse({bool force = false}) async {
    final int? courseId = controller.defaultPhonicsCourseId;
    if (courseId == null) return;

    final PhonicsCourseController phonicsController =
        _ensureEmbeddedPhonicsController();
    await phonicsController.configureCourse(
      courseId: courseId,
      force: force,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Obx(() {
        final int entryVersion = controller.phonicsEntryVersion.value;
        Widget bodyWidget = const SizedBox.shrink();
        if (controller.homeReqError.value == 0 &&
            controller.defaultPhonicsCourseId != null) {
          _ensureEmbeddedPhonicsController();
          if (_lastSyncedEntryVersion != entryVersion) {
            _lastSyncedEntryVersion = entryVersion;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _syncEmbeddedPhonicsCourse(force: true);
            });
          }
          bodyWidget = const PhonicsCourseView(
            controllerTag: _embeddedPhonicsTag,
            showBackButton: false,
          );
        } else if (controller.homeReqError.value != -1) {
          bodyWidget = _buildErrorWidget();
        }

        return Column(
          children: [
            const BreadcrumbWidget(),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom,
                ),
                child: bodyWidget,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildErrorWidget() {
    String errText = "";
    if (controller.homeReqError.value == 1) {
      errText = "网络链接不稳定，请检查网络后重试";
    }
    if (controller.homeReqError.value == 2) {
      errText = "网络连接超时，请检查网络后重试";
    }
    if (controller.homeReqError.value == 3) {
      errText = "请求失败，请刷新重试";
    }
    if (controller.homeReqError.value == 4) {
      errText = "暂无数据！";
    }
    return NotDataWidget(
      key: const ValueKey("specialtyErrorWidget"),
      message: errText,
      other: ButtonWidget(
        text: "刷新",
        width: 300.wMin,
        height: 56.wMin,
        borderRadius: 8.wMin,
        sclae: 1.01,
        fontSize: 24.wMin,
        onTap: () {
          controller.homeReqError.value = -1;
          if (Get.isRegistered<ApplicationController>()) {
            Get.find<ApplicationController>().refreshData();
          }
        },
      ),
    );
  }
}
