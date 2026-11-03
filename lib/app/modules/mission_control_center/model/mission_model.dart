import 'package:flutter/material.dart';

import '../../../../common/entities/entities.dart';


enum MissionType{
  /// 目标
  target,
  /// 任务
  mission,
  /// 测试
  test,
}

class MissionModel{
  TaskMissionEntityMissions missions;
  List<TaskMissionEntityExercises>? exercises;

  GlobalKey missionKey = GlobalKey();

  MissionType missionType = MissionType.mission;


  MissionModel({
    required this.missions,
    this.exercises,
  });
}