import '../../../routes/routes.dart';
import '../utils/manage_auth_utils.dart';

/// 底部导航栏
enum ManageNavEnum {
  study(
    value: "study",
    name: "学习",
    route: Routes.MANAGE_STUDY,
    authCodes: [
      ManageAuthCode.coursePages,
      ManageAuthCode.courseLevelPages,
      ManageAuthCode.courseModulePages,
      ManageAuthCode.courseUnitPages,
      ManageAuthCode.courseLessonPages,
      ManageAuthCode.courseLessonTemplatePages,
      ManageAuthCode.exercisePage,
      ManageAuthCode.exerciseTemplateList,
    ],
  ),
  content(
    value: "content",
    name: "内容",
    route: Routes.MANAGE_CONTENT,
    authCodes: [
      ManageAuthCode.accentList,
      ManageAuthCode.enWordPages,
      ManageAuthCode.enPhrasePages,
      ManageAuthCode.enSentencePages,
      ManageAuthCode.enTextPages,
      ManageAuthCode.enSongPages,
      ManageAuthCode.enRevealsPages,
      ManageAuthCode.courseLessonTemplateConfigPages,
    ],
  ),
  review(
    value: "review",
    name: "审核",
    route: Routes.MANAGE_REVIEW,
    authCodes: [],
  ),
  users(
    value: "users",
    name: "用户",
    route: Routes.MANAGE_USERS,
    authCodes: [
      ManageAuthCode.apiTagsParamsList,
    ],
  ),
  operations(
    value: "operations",
    name: "运营",
    route: Routes.MANAGE_OPERATIONS,
    authCodes: [
      ManageAuthCode.staffConsoleMemberPages, 
      ManageAuthCode.staffConsoleSummary,
      ManageAuthCode.notifyTemplatePages, 
      ManageAuthCode.channelTicketTemplatePages,
      ManageAuthCode.channelPages,
      ManageAuthCode.channelUserPages,
    ],
  );

  final String value;
  final String name;
  final String route;
  final List<String> authCodes;
  const ManageNavEnum({
    required this.value,
    required this.name,
    required this.route,
    required this.authCodes,
  });
}

