
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../../../routes/routes.dart';
import '../controllers/manage_setting_controller.dart';
import '../dialog/dialogs.dart';
import '../utils/utils.dart';
import 'commons.dart';

class KnowledgeVideoToolVuttonsWidget extends StatelessWidget {
  final int? uid;
  final int? semanticId;
  final String? type;
  final EnKnowledgeEntitySemanticsRelationImage? relationImage;
  final EnKnowledgeEntityRelationVideo? relationVideo;
  final void Function()? onRefresh;
  const KnowledgeVideoToolVuttonsWidget({
    super.key, 
    this.relationVideo, 
    this.relationImage, 
    this.onRefresh, 
    this.uid, 
    this.semanticId, 
    this.type,
  });

  @override
  Widget build(BuildContext context) {
    final ManageSettingController settingController = Get.find<ManageSettingController>();

    bool locked = relationImage?.locked == true;
    List<String> authCodes = [locked ? ManageAuthCode.contentReviewImageUnlock : ManageAuthCode.contentReviewImageLock];
    bool isNullId = relationImage?.uid == null;
    if(settingController.defaultResources.value == ResourceTypeEnum.video){
      locked = relationVideo?.locked == true;
      authCodes = [locked ? ManageAuthCode.videoReviewVideoUnlock : ManageAuthCode.videoReviewVideoLock];
      isNullId = relationVideo?.uid == null;
    }

    return Column(
      children: [

        Visibility(
          visible: !isNullId,
          child: ManageAuthBoxWidget(
            authCodes: authCodes,
            margin: EdgeInsets.only(bottom: 8.wMin),
            child: TapScaleWidget(
              onTap: () async{
                if(settingController.defaultResources.value == ResourceTypeEnum.video){
                  if(relationVideo?.uid == null) return;
                  await ManagePageRegistry.jumpTo(
                    Routes.MANAGE_REVIEW_VIDEO_DETILS,
                    arguments: {
                      "videoRelationId": relationVideo?.uid,
                      "isAdminPage": true,
                    },
                  );
                  onRefresh?.call();
                }else{
                  bool res = await ManageLockBigImageDialog.show(
                    context: context, 
                    imageUrl: relationImage?.imageUrl,
                    relationImageId: relationImage?.uid,
                    locked: relationImage?.locked,
                  );
                  if(!res) return;
                  onRefresh?.call();
                }
                
              },
              sclae: 1.1,
              child: Container(
                width: 36.wMin,
                height: 36.wMin,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.wMin),
                  color: AppTheme.cInverseOverlay2.color,
                  border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
                ),
                child: SvgPicture.asset(
                  locked ? "assets/svg/manage/icon_resource_lock.svg" : "assets/svg/manage/icon_resource_unlock.svg",
                  width: 18.wMin,
                ),
              ),
            ),
          ),
        ),

        Visibility(
          visible: settingController.defaultResources.value == ResourceTypeEnum.video && isNullId,
          child: ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.videoReviewGenerateFrameStart, ManageAuthCode.videoReviewGenerateStartEndFrames],
            child: TapScaleWidget(
              onTap: () async{
                if(uid == null || type == null) return;
                int? styleId = await settingController.getDefaultStyleId();
                String? localeTitle = settingController.getCurrentStyleAreaName();
                String? title = "$localeTitle ${settingController.selectedStyleKey.value}";
                ManageCreateVideoDialog.show(
                  context: context,
                  uid: uid,
                  type: type,
                  semanticId: semanticId,
                  subTitle: title,
                  styleIds: styleId == null ? null : [styleId],
                );
              },
              sclae: 1.1,
              child: Container(
                width: 36.wMin,
                height: 36.wMin,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.wMin),
                  color: AppTheme.cInverseOverlay2.color,
                  border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
                ),
                child: SvgPicture.asset(
                  "assets/svg/public/icon_add_plus.svg",
                  width: 24.wMin,
                ),
              ),
            ),
          ),
        ),


      ],
    );
  }
}