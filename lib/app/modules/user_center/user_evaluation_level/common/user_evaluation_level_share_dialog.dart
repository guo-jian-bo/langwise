

import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/widgets/widgets.dart';

/// 分享弹窗
class UserEvaluationLevelShareDialog{

  static Future<void> show({
    required BuildContext context,
    required Uint8List imageBytes,
  }) async{

    await showCupertinoDialog(
      context: context,
      builder: (context) {
        return UserEvaluationLevelShareDialogWidget(imageBytes: imageBytes);
      },
    );

  }

}

class UserEvaluationLevelShareDialogWidget extends StatefulWidget {
  final Uint8List imageBytes;
  const UserEvaluationLevelShareDialogWidget({super.key, required this.imageBytes});

  @override
  State<UserEvaluationLevelShareDialogWidget> createState() => _UserEvaluationLevelShareDialogWidgetState();
}

class _UserEvaluationLevelShareDialogWidgetState extends State<UserEvaluationLevelShareDialogWidget> {


  @override
  Widget build(BuildContext context) {
    return ShareBoxWidget(
      shareTitle: "${UserStore.to.userInfo.value.memberName??""} 的评测结果",
      shareText: "${UserStore.to.userInfo.value.memberName??""} 分享了他的评测结果",
      childWidth: 800.wMin,
      childDecoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.cBgBrand.color.withValues(alpha: 0.3),
            AppTheme.cBgBrand.color.withValues(alpha: 0),
          ],
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(8.wMin),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            Image.memory(
              widget.imageBytes,
              width: double.infinity,
              fit: BoxFit.fitWidth,
            ),
            Positioned(
              left: 24.wMin,
              top: 24.wMin,
              child: _buildUserHardWidget(),
            ),
          ],
        ),
      ),
    );

  }

  Widget _buildUserHardWidget(){
    if(UserStore.to.userInfo.value.memberAvatarUrl == null){
      return Container();
    }
    return Column(
      children: [
        Container(
          width: 54.wMin,
          height: 54.wMin,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(width: 2.wMin, color: AppTheme.cBorderBrand.color),
          ),
          child: ClipOval(
            child: CachedImageWidget(
              UserStore.to.userInfo.value.memberAvatarUrl??"",
              fit: BoxFit.cover,
              placeholder: SvgPicture.asset(
                "assets/svg/public/icon_user.svg",
                width: 54.wMin,
                height: 54.wMin,
              ),
              errorWidget: SvgPicture.asset(
                "assets/svg/public/icon_user.svg",
                width: 54.wMin,
                height: 54.wMin,
              ),
            ),
          ),
        ),
      ],
    );
  }

  
}
