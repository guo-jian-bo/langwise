import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../../theme/theme.dart';
import '../../../../../routes/routes.dart';
import '../../../common/commons.dart';
import '../bindings/manage_quiz_template_binding.dart';
import '../controllers/manage_quiz_template_controller.dart';

class ManageQuizTemplateView extends StatelessWidget {
  final String tag;
  final ManageQuizTemplateController controller;

  const ManageQuizTemplateView({
    super.key,
    required this.tag,
    required this.controller,
  });

  static Future<dynamic> to({dynamic arguments}) async {
    final String tag = '${Routes.MANAGE_QUIZ_TEMPLATE}_${DateTime.now().millisecondsSinceEpoch}';
    final binding = ManageQuizTemplateBinding(tag: tag);
    binding.dependencies();
    final controller = Get.find<ManageQuizTemplateController>(tag: tag);
    final result = await Get.to<dynamic>(
      () => ManageQuizTemplateView(tag: tag, controller: controller),
      arguments: arguments,
      preventDuplicates: false,
    );
    if (Get.isRegistered<ManageQuizTemplateController>(tag: tag)) {
      Get.delete<ManageQuizTemplateController>(tag: tag);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ManageScaffold(
          backgroundColor: const Color(0xff050916),
          resizeToAvoidBottomInset: false,
          body: Column(
            children: [
              Expanded(
                child: Obx(() {
                  return GridView.builder(
                    controller: controller.gridViewController,
                    itemCount: controller.questionDataList.length,
                    padding: EdgeInsets.all(24.wMin),
                    physics: const ClampingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 24.wMin,
                      crossAxisSpacing: 24.wMin,
                      childAspectRatio: 376 / 325,
                    ),
                    itemBuilder: (context, index) {
                      return _ManageQuizTemplateQuizWidget(
                        data: controller.questionDataList[index],
                        onTap: () {
                          controller.showDetilConfig(context, controller.questionDataList[index]);
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ManageQuizTemplateQuizWidget extends StatefulWidget {
  final ManageQuizTemplateEntity data;
  final void Function()? onTap;
  const _ManageQuizTemplateQuizWidget({required this.data, this.onTap});

  @override
  State<_ManageQuizTemplateQuizWidget> createState() => __ManageQuizTemplateQuizWidgetState();
}

class __ManageQuizTemplateQuizWidgetState extends State<_ManageQuizTemplateQuizWidget>
    with AutomaticKeepAliveClientMixin {
  void showTips(BuildContext ctx) {
    BotToast.showAttachedWidget(
      targetContext: ctx,
      backgroundColor: Colors.transparent,
      onlyOne: true,
      preferDirection: PreferDirection.bottomCenter,
      verticalOffset: 4.wMin,
      attachedBuilder: (cancelFunc) {
        return Container(
          padding: EdgeInsets.all(16.wMin),
          constraints: BoxConstraints(
            minWidth: 200.wMin,
            maxWidth: 900.wMin,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.wMin),
            color: AppTheme.cSurfaceQuaternary.color,
            border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
          ),
          child: Container(
            margin: EdgeInsets.only(top: 8.wMin),
            child: Text(
              widget.data.template?.description ?? "",
              style: TextStyle(
                fontSize: 16.wMin,
                color: AppTheme.cTextSecondary.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return TapScaleWidget(
      sclae: 1.03,
      onTap: widget.onTap,
      child: Container(
        padding: EdgeInsets.all(6.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.wMin),
          color: const Color(0xff22293C),
          border: Border.all(width: 0.5.wMin, color: const Color(0xff4B5268)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.data.template?.name ?? "",
              style: TextStyle(
                fontSize: 18.wMin,
                color: const Color(0xffEBEFF5),
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 8.wMin),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Builder(builder: (ctx) {
                    return MouseRegion(
                      onEnter: (event) {
                        showTips(ctx);
                      },
                      onExit: (event) {
                        BotToast.cleanAll();
                      },
                      child: TapScaleWidget(
                        onTap: Platform.isMacOS || Platform.isWindows || Platform.isLinux
                            ? null
                            : () {
                                showTips(ctx);
                              },
                        sclae: 1,
                        child: Text(
                          widget.data.template?.description ?? "",
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16.wMin,
                            color: const Color(0xffACB4C0),
                            fontWeight: FontWeight.w400,
                            height: 1,
                          ),
                        ),
                      ),
                    );
                  }),
                  const Spacer(),
                  QuizPublicQuizWidget(
                    borderRadius: 12.wMin,
                    data: widget.data.exercise,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
