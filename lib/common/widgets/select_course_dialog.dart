import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../../theme/theme.dart';
import '../entities/entities.dart';
import '../https/https.dart';
import 'widgets.dart';

class SelectCourseDialog {
  static Future<JoinedCoursesEntity?> show({
    required BuildContext context,
    int? initCourseId,
    List<int>? disableCourseIds,
    String? unselectedHitText,
  }) async {
    return await showCupertinoDialog<JoinedCoursesEntity?>(
      context: context,
      useRootNavigator: false,
      builder: (context) {
        return SelectCourseDialogWidget(
          initCourseId: initCourseId, 
          disableCourseIds: disableCourseIds,
          unselectedHitText: unselectedHitText,
        );
      },
    );
  }
}

class SelectCourseDialogWidget extends StatefulWidget {
  final int? initCourseId;
  final List<int>? disableCourseIds;
  final String? unselectedHitText;
  const SelectCourseDialogWidget({super.key, this.initCourseId, this.disableCourseIds, this.unselectedHitText});

  @override
  State<SelectCourseDialogWidget> createState() => _SelectCourseDialogWidgetState();
}

class _SelectCourseDialogWidgetState extends State<SelectCourseDialogWidget> with SafeSetStateMixin {
  JoinedCoursesEntity? selectCourse;

  List<JoinedCoursesEntity> joinedCoursesList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getJoinedCoursesList();
  }

  Future<void> getJoinedCoursesList() async {
    List<JoinedCoursesEntity>? list = await StudyPlanRequest.getJoinedCoursesList();
    
    if(list == null) {
      isLoading = false;
      if(mounted) setState(() {});
      return;
    }

    joinedCoursesList = list;

    if(widget.initCourseId != null) {
      selectCourse = joinedCoursesList.firstWhereOrNull((element) => element.courseId == widget.initCourseId);
    }

    isLoading = false;

    if(mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return CardDialogBoxWidget(
      title: "选择课程",
      onCancel: () => Get.back(),
      onConfirm: () {
        if(selectCourse == null){
          ToastUtils.showToast(text: "请选择课程");
          return;
        }
        Get.back(result: selectCourse);
      },
      child: isLoading ? Center(
          child: SpinKitFadingCircle(
            color: AppTheme.cBgBrand,
            size: 100.wMin,
          ),
        ) : GridView.builder(
        itemCount: joinedCoursesList.length,
        padding: EdgeInsets.only(left: 40.wMin, right: 40.wMin, top: 16.wMin),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 18.wMin,
          crossAxisSpacing: 24.wMin,
          childAspectRatio: 308 / 369,
        ),
        itemBuilder: (context, index) {
          return buildCardWidget(joinedCoursesList[index]);
        },
      ),
    );
  }

  Widget buildCardWidget(JoinedCoursesEntity data) {
    return TapScaleWidget(
      onTap: () {
        if(data.courseId == null) return;
        if(widget.disableCourseIds?.contains(data.courseId)??false){
          return ToastUtils.showToast(text: widget.unselectedHitText??"此课程已被添加");
        }
        safeSetState(() {
          selectCourse = data;
        });
      },
      sclae: 1.01,
      child: Opacity(
        opacity: (widget.disableCourseIds?.contains(data.courseId)??false) ? 0.6 : 1,
        child: Container(
          padding: EdgeInsets.all(16.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.wMin),
            color: AppTheme.cBgTertiary,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      data.courseName ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 24.wMin,
                        color: AppTheme.cTextPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  CardSelectDotWidget(
                    isSelected: selectCourse?.courseId == data.courseId,
                    size: 32
                  ),
                ],
              ),
              SizedBox(height: 16.wMin),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6.wMin),
                      child: CachedImageWidget(
                        data.courseCoverUrl??"",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
