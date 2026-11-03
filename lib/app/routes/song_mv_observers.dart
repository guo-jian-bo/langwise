

import 'package:flutter/material.dart';

import '../../common/public_controller/mv_player_global_float_controller.dart';
import 'routes.dart';

class SongMvObservers<R extends Route<dynamic>> extends RouteObserver<R> {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    var name = route.settings.name ?? '';

    if(name == Routes.LISTEN_AND_READ 
    || name == Routes.OFFICIAL_COURSE_DETAILS_DICTATION
    || name == Routes.OFFICIAL_COURSE_DETAILS_FLASH_NOTES
    || name == Routes.OFFICIAL_COURSE_DETAILS_PREVIEW
    || name == Routes.PRACTICE_QUESTIONS
    || name == Routes.PRACTICE_QUESTIONS_EVAL){
      MvPlayerGlobalFloatController.to.stop();
    }
    
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    // var name = route.settings.name ?? '';
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    var newName = newRoute?.settings.name ?? '';
    // var oldName = oldRoute?.settings.name ?? '';

    if(newName == Routes.LISTEN_AND_READ 
    || newName == Routes.OFFICIAL_COURSE_DETAILS_DICTATION
    || newName == Routes.OFFICIAL_COURSE_DETAILS_FLASH_NOTES
    || newName == Routes.OFFICIAL_COURSE_DETAILS_PREVIEW
    || newName == Routes.PRACTICE_QUESTIONS
    || newName == Routes.PRACTICE_QUESTIONS_EVAL){
      MvPlayerGlobalFloatController.to.stop();
    }

  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    // var name = route.settings.name ?? '';

  }
}