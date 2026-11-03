
import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:quiz_play/utils/utils.dart';

import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';

class AudioErrorWidget extends StatelessWidget {
  final AudioErrorType? errType;
  /// 重试回调
  final void Function()? retryCallback;
  const AudioErrorWidget({super.key, this.errType, this.retryCallback});

  @override
  Widget build(BuildContext context) {

    if(errType == null) return Container();
    if(errType == AudioErrorType.audioContextError || errType == AudioErrorType.disposeError) return Container(); 
    Color iconColor = AppTheme.cSurfaceError.color.withValues(alpha: 0.6);
    if(errType == AudioErrorType.completeTimeout){
      iconColor = AppTheme.cSurfaceWarning.color;
    }else if(errType == AudioErrorType.initTimeout){
      iconColor = AppTheme.cSurfaceError.color;
    }
    
    return Container(
      margin: EdgeInsets.only(left: 16.wMin),
      child: TapScaleWidget(
        onTap: retryCallback,
        sclae: 1.03,
        child: Icon(
          Icons.audiotrack_outlined,
          color: iconColor,
          size: 32.wMin,
        ),
      ),
    );
  }
}