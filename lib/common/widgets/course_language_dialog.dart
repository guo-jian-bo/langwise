import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:langwise/common/values/values.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

class CourseLanguageDialog{
  static void show({
    required BuildContext context,
    LanguageEntity? defaultLanguageEntity,
    void Function(LanguageEntity? languageEntity)? onTap,
  }){
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CourseLanguageWidget(
          defaultLanguageEntity: defaultLanguageEntity,
          onTap: onTap,
        );
      },
    );
  }
}


class CourseLanguageWidget extends StatefulWidget {
  final LanguageEntity? defaultLanguageEntity;
  final Function(LanguageEntity? languageEntity)? onTap;

  const CourseLanguageWidget({super.key, this.defaultLanguageEntity, this.onTap});

  @override
  State<CourseLanguageWidget> createState() => _CourseLanguageWidgetState();
}

class _CourseLanguageWidgetState extends State<CourseLanguageWidget> with SafeSetStateMixin {
  final List<LanguageEntity> _languages = [];

  @override
  void initState() {
    super.initState();
    _languages.addAll(CommonUtil.languages());
    for (int i = 0; i < _languages.length; i++) {
      final LanguageEntity oldEntity = _languages[i];
      if (widget.defaultLanguageEntity?.title == oldEntity.title) {
        _languages[i] = oldEntity.copyWith(isSelected: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: 576.ww,
          height: 650.wh,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.wMin),
            color: Colours.black_262F38,
          ),
          child: Column(
            children: [
              Gaps.getHeight(Dimens.dn_24.wh),
              Text(
                '课程',
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Colours.white_FFFFFF,
                  fontSize: Dimens.font_sp28.wMin,
                  fontWeight: FontWeight.w500,
                  height: 1.0,
                ),
              ),
              Gaps.getHeight(Dimens.dn_8.wh),
              Container(
                height: 1.wMin,
                color: Colours.blue_E5F5FF,
              ),
              Gaps.getHeight(Dimens.dn_10.wh),
              Expanded(
                  child: AnimationLimiter(
                child: OptimizedListView(
                    list: _languages,
                    builder: (BuildContext context, ValueKey key, int index, LanguageEntity item) {
                      return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 300),
                          child: SlideAnimation(
                              child: FadeInAnimation(
                                  child: _buildItemWidget(item, onTap: (LanguageEntity selectedItem) {
                            for (int i = 0; i < _languages.length; i++) {
                              final LanguageEntity oldEntity = _languages[i];
                              _languages[i] = oldEntity.copyWith(isSelected: false);
                            }

                            if (item == selectedItem) {
                              safeSetState(() {
                                _languages[index] = selectedItem.copyWith(isSelected: true);
                              });
                            }
                          }))));
                    }),
              )),
              Container(
                height: 1.wMin,
                color: Colours.blue_E5F5FF,
              ),
              Gaps.getHeight(Dimens.dn_24.wh),
              TapScaleWidget(
                sclae: 1.1,
                child: Container(
                  height: 46.wh,
                  margin: EdgeInsets.only(left: 24.ww, right: 24.ww, bottom: Dimens.dn_24.wh),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _allowNext ? Colours.blue_1AA6F3 : Colours.blue_C2E6FF.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(10.wMin),
                  ),
                  child: Text(
                    '继续',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _allowNext ? Colours.white_FFFFFF : Colours.white_FFFFFF.withOpacity(0.5),
                      fontSize: Dimens.font_sp20.wMin,
                      fontWeight: FontWeight.w400,
                      height: 1.0,
                    ),
                  ),
                ),
                onTap: _allowNext
                    ? OptimizeUtils.noneThrottle(() {
                        Navigator.pop(context);
                        widget.onTap?.call(_languages.firstWhereOrNull((element) => element.isSelected));
                      }, 100)
                    : null,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemWidget(LanguageEntity item, {required ValueChanged<LanguageEntity>? onTap}) {
    return GestureDetector(
      onTap: () {
        onTap?.call(item);
      },
      child: Container(
        padding: EdgeInsets.only(left: 16.ww),
        margin: EdgeInsets.only(left: 24.ww, right: 24.ww, bottom: 8.wh),
        height: 60.wh,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(width: 1.wMin, color: item.isSelected ? Colours.blue_016394 : Colours.blue_E5F5FF),
          borderRadius: BorderRadius.circular(8.wMin),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildImage(item.flag ?? '', width: 24.wh, height: 24.wh),
            Gaps.getWidth(Dimens.dn_8.ww),
            Text(
              item.title ?? '',
              textAlign: TextAlign.start,
              style: TextStyle(
                color: Colours.white_FFFFFF,
                fontSize: Dimens.font_sp16.wMin,
                fontWeight: FontWeight.w400,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _allowNext => _languages.any((element) => element.isSelected);
}
